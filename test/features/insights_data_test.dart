import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/core/db/app_database.dart';
import 'package:kakeibo/features/backup/data/backup_repository.dart';
import 'package:kakeibo/features/checkin/data/checkin_repository.dart';
import 'package:kakeibo/features/expenses/data/expense_repository.dart';
import 'package:kakeibo/features/history/data/history_repository.dart';
import 'package:kakeibo/features/periods/data/period_repository.dart';
import 'package:kakeibo/features/reflection/data/reflection_repository.dart';
import 'package:kakeibo/features/reflection/domain/reflection_summary.dart';

void main() {
  late AppDatabase db;
  late Directory tmp;
  late PeriodRepository periods;
  late ExpenseRepository expenses;
  late BackupRepository backup;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    tmp = await Directory.systemTemp.createTemp('kakeibo_test');
    periods = PeriodRepository(db);
    expenses = ExpenseRepository(db);
    backup = BackupRepository(db, snapshotDir: () async => tmp);
  });
  tearDown(() async {
    await db.close();
    await tmp.delete(recursive: true);
  });

  /// November and December planned; November has spends, a refund, a
  /// finished reflection and a check-in.
  Future<void> twoMonths() async {
    final nov = await periods.ensureCurrentPeriod(now: DateTime(2026, 11, 3));
    await periods.savePlan(
      nov.id,
      const PlanDraft(
        incomes: [(label: 'Salary', amount: 15000000)],
        fixedCosts: [(label: 'Rent', amount: 4000000, recurring: true)],
        savingsGoal: 2000000,
        budgets: {1: 4000000, 2: 2000000, 3: 1000000, 4: 1000000},
      ),
    );
    final lunch = await expenses.add(
      const ExpenseDraft(
        pillarId: 2,
        amount: 60000,
        date: '2026-11-04',
        note: '=cmd',
        mood: Mood.regret,
      ),
    );
    await expenses.add(const ExpenseDraft(pillarId: 1, amount: 7000000, date: '2026-11-10'));
    await db
        .into(db.expenses)
        .insert(
          ExpensesCompanion.insert(
            periodId: nov.id,
            pillarId: 2,
            amount: 10000,
            date: '2026-11-05',
            type: const Value('refund'),
            refundOfId: Value(lunch),
            createdAt: 'x',
            updatedAt: 'x',
          ),
        );
    await CheckinRepository(db).save(nov.id, DateTime(2026, 11, 2), 'On track');
    await periods.ensureCurrentPeriod(now: DateTime(2026, 12, 2));
    await ReflectionRepository(db)
        .complete(ReflectionDraft(periodId: nov.id, answer1: 'Yes', improvement: 'Cook more'));
    await db
        .into(db.settings)
        .insertOnConflictUpdate(SettingsCompanion.insert(key: 'currency_symbol', value: 'LKR'));
  }

  group('history', () {
    test('months newest first with savings, goal and frozen totals', () async {
      await twoMonths();
      final repo = HistoryRepository(db);
      final months = await repo.loadMonths();
      expect(months.map((m) => m.period.startDate), ['2026-12-01', '2026-11-01']);

      final nov = months.last;
      expect(nov.isClosed, isTrue);
      expect(nov.spent, 60000 + 7000000 - 10000);
      expect(nov.savedAmount, 15000000 - 4000000 - 7050000); // 39,500
      expect(nov.goalMet, isTrue);
      expect(nov.reflectionDone, isTrue);

      // After the reflection, a late spend changes only edited_after_close.
      await expenses.add(const ExpenseDraft(pillarId: 4, amount: 500000, date: '2026-11-20'));
      final later = (await repo.loadMonths()).last;
      expect(later.savedAmount, 3950000);
      expect(later.editedAfterClose, 500000);

      expect(lifetimeSavings(months), 3950000, reason: 'the open month is not counted');
    });

    test('watchMonths emits again when a spend is added', () async {
      await twoMonths();
      final two = HistoryRepository(db).watchMonths().take(2).toList();
      await pumpEventQueue();
      await expenses.add(const ExpenseDraft(pillarId: 1, amount: 12300, date: '2026-12-02'));
      final emitted = await two.timeout(const Duration(seconds: 5));
      expect(emitted.map((m) => m.first.spent), [0, 12300]);
    });
  });

  group('backup and restore', () {
    Map<String, Object?> withoutTime(Map<String, Object?> j) => {...j}..remove('exportedAt');

    test('a backup restores to exactly the same data', () async {
      await twoMonths();
      final original = await backup.toJson();
      final text = await backup.encode();

      final other = AppDatabase(NativeDatabase.memory());
      addTearDown(other.close);
      final otherBackup = BackupRepository(other, snapshotDir: () async => tmp);
      await PeriodRepository(other).ensureCurrentPeriod(now: DateTime(2027, 3, 1));

      await otherBackup.restore(text);
      final restored = withoutTime(await otherBackup.toJson());
      // The restored file counts as the last backup.
      final settings = Map<String, dynamic>.from(restored['settings']! as Map);
      expect(
        settings.remove(BackupRepository.lastBackupKey),
        (jsonDecode(text) as Map<String, dynamic>)['exportedAt'],
      );
      expect({...restored, 'settings': settings}, withoutTime(original));
      expect((await other.select(other.periods).get()).length, 2, reason: 'replaced, not merged');
    });

    test('inspect counts months and spends', () async {
      await twoMonths();
      final info = backup.inspect(await backup.encode());
      expect(info.months, 2);
      expect(info.spends, 3);
      final id = await expenses.add(
        const ExpenseDraft(pillarId: 1, amount: 100, date: '2026-12-02'),
      );
      await expenses.softDelete(id);
      expect(backup.inspect(await backup.encode()).spends, 3, reason: 'deleted not counted');
      expect(info.exportedAt, isNotNull);
    });

    test('wrong, damaged and newer files are refused and nothing changes', () async {
      await twoMonths();
      final before = withoutTime(await backup.toJson());
      final good = jsonDecode(await backup.encode()) as Map<String, dynamic>;

      Future<void> refused(String text, String message) async {
        await expectLater(
          backup.restore(text),
          throwsA(
            isA<BackupFormatException>().having((e) => e.message, 'message', contains(message)),
          ),
        );
      }

      await refused('not json', "isn't a Kakeibo backup");
      await refused(jsonEncode({'app': 'other'}), "isn't a Kakeibo backup");
      await refused(jsonEncode({...good, 'schemaVersion': db.schemaVersion + 1}), 'newer version');
      await refused(jsonEncode({...good}..remove('periods')), 'damaged');

      expect(withoutTime(await backup.toJson()), before);
      expect(Directory('${tmp.path}/snapshots').existsSync(), isFalse, reason: 'no snapshot');
    });

    test('a safety snapshot is kept before restoring, newest 3 only', () async {
      await twoMonths();
      final text = await backup.encode();
      for (var i = 0; i < 4; i++) {
        await backup.restore(text);
        await Future<void>.delayed(const Duration(milliseconds: 5));
      }
      final files = Directory('${tmp.path}/snapshots').listSync().whereType<File>().toList();
      expect(files.length, BackupRepository.keepSnapshots);
      final snap = jsonDecode(files.first.readAsStringSync()) as Map<String, dynamic>;
      expect(snap['app'], 'kakeibo');
    });
  });

  test('delete all keeps a snapshot and puts back the defaults', () async {
    await twoMonths();
    await backup.deleteAll();
    expect(await db.select(db.periods).get(), isEmpty);
    expect(await db.select(db.expenses).get(), isEmpty);
    expect((await db.select(db.pillars).get()).map((p) => p.name), [
      'Needs',
      'Wants',
      'Culture',
      'Unexpected',
    ]);
    expect((await db.select(db.paymentMethods).get()).length, 4);
    final settings = {for (final s in await db.select(db.settings).get()) s.key: s.value};
    expect(settings, AppDatabase.defaultSettings);
    expect(Directory('${tmp.path}/snapshots').listSync().length, 1);
  });

  group('CSV', () {
    test('cells that could run as formulas are escaped (FR-75)', () {
      expect(BackupRepository.csvCell('=SUM(A1)'), "'=SUM(A1)");
      expect(BackupRepository.csvCell('+94 77 123'), "'+94 77 123");
      expect(BackupRepository.csvCell('-x'), "'-x");
      expect(BackupRepository.csvCell('@user'), "'@user");
      expect(BackupRepository.csvCell('-150.00'), '-150.00');
      expect(BackupRepository.csvCell('Rice, dhal'), '"Rice, dhal"');
      expect(BackupRepository.csvCell('5" tile'), '"5"" tile"');
      expect(BackupRepository.csvCell('Groceries'), 'Groceries');
    });

    test('export lists every spend with plain amounts, refunds negative', () async {
      await twoMonths();
      await expenses.softDelete(
        await expenses.add(const ExpenseDraft(pillarId: 3, amount: 100, date: '2026-12-02')),
      );
      final lines = const LineSplitter().convert(await backup.exportCsv());
      expect(lines.first, 'Date,Pillar,Amount (LKR),Type,Note,Mood,Payment method');
      expect(lines.sublist(1), [
        "2026-11-04,Wants,600.00,expense,'=cmd,regret,",
        '2026-11-05,Wants,-100.00,refund,,,',
        '2026-11-10,Needs,70000.00,expense,,,',
      ]);
    });
  });
}
