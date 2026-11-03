import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/core/db/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<int> insertPeriod() => db.into(db.periods).insert(PeriodsCompanion.insert(
        startDate: '2026-11-01',
        endDate: '2026-11-30',
        createdAt: '2026-11-03T00:00:00Z',
        updatedAt: '2026-11-03T00:00:00Z',
      ));

  ExpensesCompanion expense(int periodId, {int amount = 24000, int pillarId = 1}) =>
      ExpensesCompanion.insert(
        periodId: periodId,
        pillarId: pillarId,
        amount: amount,
        date: '2026-11-03',
        createdAt: '2026-11-03T00:00:00Z',
        updatedAt: '2026-11-03T00:00:00Z',
      );

  test('seeds the four pillars in order', () async {
    final pillars = await (db.select(db.pillars)
          ..orderBy([(p) => OrderingTerm.asc(p.sortOrder)]))
        .get();
    expect(pillars.map((p) => p.name), ['Needs', 'Wants', 'Culture', 'Unexpected']);
  });

  test('seeds LKR currency settings', () async {
    final rows = await db.select(db.settings).get();
    final map = {for (final r in rows) r.key: r.value};
    expect(map['currency_code'], 'LKR');
    expect(map['currency_symbol'], 'Rs');
    expect(map['currency_symbol_position'], 'before');
  });

  test('rejects zero or negative expense amounts', () async {
    final periodId = await insertPeriod();
    expect(
      () => db.into(db.expenses).insert(expense(periodId, amount: 0)),
      throwsA(isA<SqliteException>()),
    );
  });

  test('enforces foreign keys and cascades period deletes', () async {
    expect(
      () => db.into(db.expenses).insert(expense(999)),
      throwsA(isA<SqliteException>()),
    );

    final periodId = await insertPeriod();
    await db.into(db.expenses).insert(expense(periodId));
    await (db.delete(db.periods)..where((p) => p.id.equals(periodId))).go();
    expect(await db.select(db.expenses).get(), isEmpty);
  });

  test('pillars cannot be deleted while expenses use them', () async {
    final periodId = await insertPeriod();
    await db.into(db.expenses).insert(expense(periodId, pillarId: 2));
    expect(
      () => (db.delete(db.pillars)..where((p) => p.id.equals(2))).go(),
      throwsA(isA<SqliteException>()),
    );
  });
}
