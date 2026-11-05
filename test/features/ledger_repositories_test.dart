import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/core/db/app_database.dart';
import 'package:kakeibo/features/expenses/data/expense_repository.dart';
import 'package:kakeibo/features/periods/data/period_repository.dart';

void main() {
  late AppDatabase db;
  late PeriodRepository periods;
  late ExpenseRepository expenses;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    periods = PeriodRepository(db);
    expenses = ExpenseRepository(db);
  });
  tearDown(() => db.close());

  Future<int> periodCount() async => (await db.select(db.periods).get()).length;

  group('ensureCurrentPeriod', () {
    test('creates the first period from the month start day', () async {
      final p = await periods.ensureCurrentPeriod(now: DateTime(2026, 11, 3));
      expect(p.startDate, '2026-11-01');
      expect(p.endDate, '2026-11-30');
      expect(p.status, 'planning');
      final plan = await periods.loadPlan(p.id);
      expect(plan.budgets.keys, unorderedEquals([1, 2, 3, 4]));
    });

    test('is idempotent', () async {
      await periods.ensureCurrentPeriod(now: DateTime(2026, 11, 3));
      await periods.ensureCurrentPeriod(now: DateTime(2026, 11, 20));
      expect(await periodCount(), 1);
    });

    test('rolls over missed months and copies the plan', () async {
      final nov = await periods.ensureCurrentPeriod(now: DateTime(2026, 11, 3));
      await periods.savePlan(
        nov.id,
        const PlanDraft(
          incomes: [(label: 'Salary', amount: 15000000)],
          fixedCosts: [
            (label: 'Rent', amount: 4000000, recurring: true),
            (label: 'Repair', amount: 500000, recurring: false),
          ],
          savingsGoal: 2000000,
          budgets: {1: 5000000, 2: 2000000, 3: 1000000, 4: 500000},
        ),
      );

      final feb = await periods.ensureCurrentPeriod(now: DateTime(2027, 2, 10));
      expect(feb.startDate, '2027-02-01');
      expect(await periodCount(), 4);

      final all = await (db.select(
        db.periods,
      )..orderBy([(p) => OrderingTerm.asc(p.startDate)])).get();
      expect(all.map((p) => p.status), ['closed', 'closed', 'closed', 'planning']);

      final plan = await periods.loadPlan(feb.id);
      expect(plan.incomeTotal, 15000000);
      expect(plan.fixedCosts.map((f) => f.label), ['Rent']);
      expect(plan.period.savingsGoal, 2000000);
      expect(plan.budgets[1], 5000000);
    });
  });

  group('month start day (FR-03)', () {
    test('an untouched first month moves at once', () async {
      await periods.ensureCurrentPeriod(now: DateTime(2026, 11, 3));
      final moved = await periods.setMonthStartDay(25, now: DateTime(2026, 11, 3));
      expect(moved, isTrue);
      final p = (await db.select(db.periods).get()).single;
      expect((p.startDate, p.endDate), ('2026-10-25', '2026-11-24'));
    });

    test('a month in use keeps its dates; the change applies at rollover', () async {
      final nov = await periods.ensureCurrentPeriod(now: DateTime(2026, 11, 3));
      await expenses.add(const ExpenseDraft(pillarId: 1, amount: 100, date: '2026-11-03'));
      expect(await periods.setMonthStartDay(25, now: DateTime(2026, 11, 3)), isFalse);
      final still = await (db.select(db.periods)..where((x) => x.id.equals(nov.id))).getSingle();
      expect(still.endDate, '2026-11-30');

      // A transition period runs to the day before the new start day, then
      // months start on the 25th.
      final dec = await periods.ensureCurrentPeriod(now: DateTime(2026, 12, 2));
      expect((dec.startDate, dec.endDate), ('2026-12-01', '2026-12-24'));
      final jan = await periods.ensureCurrentPeriod(now: DateTime(2026, 12, 26));
      expect((jan.startDate, jan.endDate), ('2026-12-25', '2027-01-24'));
    });

    test('a very short transition runs on into the following month', () async {
      await periods.ensureCurrentPeriod(now: DateTime(2026, 11, 3));
      await expenses.add(const ExpenseDraft(pillarId: 1, amount: 100, date: '2026-11-03'));
      await periods.setMonthStartDay(5, now: DateTime(2026, 11, 3));
      final next = await periods.ensureCurrentPeriod(now: DateTime(2026, 12, 2));
      expect((next.startDate, next.endDate), ('2026-12-01', '2027-01-04'));
    });
  });

  test('savePlan marks the period active and logs goal changes', () async {
    final p = await periods.ensureCurrentPeriod(now: DateTime(2026, 11, 3));
    const draft = PlanDraft(incomes: [], fixedCosts: [], savingsGoal: 100, budgets: {});
    await periods.savePlan(p.id, draft);
    expect((await periods.loadPlan(p.id)).period.status, 'active');
    expect(await db.select(db.planChanges).get(), isEmpty);

    await periods.savePlan(
      p.id,
      const PlanDraft(incomes: [], fixedCosts: [], savingsGoal: 200, budgets: {}),
    );
    final changes = await db.select(db.planChanges).get();
    expect(changes.single.oldValue, '100');
    expect(changes.single.newValue, '200');
  });

  test('improvement from last month reflection shows on the new period', () async {
    final nov = await periods.ensureCurrentPeriod(now: DateTime(2026, 11, 3));
    final dec = await periods.ensureCurrentPeriod(now: DateTime(2026, 12, 2));
    expect(await periods.watchImprovementFor(dec).first, isNull);

    await db
        .into(db.reflections)
        .insert(
          ReflectionsCompanion.insert(
            periodId: Value(nov.id),
            savedAmount: 0,
            goalMet: false,
            improvement: const Value(' No food delivery '),
            completedAt: const Value('2026-12-02T00:00:00Z'),
          ),
        );
    expect(await periods.watchImprovementFor(dec).first, 'No food delivery');
    expect(await periods.watchImprovementFor(nov).first, isNull);
  });

  group('expenses', () {
    late int periodId;

    setUp(() async {
      periodId = (await periods.ensureCurrentPeriod(now: DateTime(2026, 11, 3))).id;
    });

    ExpenseDraft draft(int pillar, int amount, {String date = '2026-11-03', String? note}) =>
        ExpenseDraft(pillarId: pillar, amount: amount, date: date, note: note);

    test('totals per pillar update as expenses are added and deleted', () async {
      await expenses.add(draft(1, 24000));
      final id = await expenses.add(draft(1, 10000));
      await expenses.add(draft(2, 5000));
      expect(await expenses.watchPillarTotals(periodId).first, {1: 34000, 2: 5000});

      await expenses.softDelete(id);
      expect(await expenses.watchPillarTotals(periodId).first, {1: 24000, 2: 5000});
      expect((await expenses.watchForPeriod(periodId).first).length, 2);

      await expenses.restore(id);
      expect(await expenses.watchPillarTotals(periodId).first, {1: 34000, 2: 5000});
    });

    test('refunds subtract from their pillar', () async {
      await expenses.add(draft(2, 50000));
      await db
          .into(db.expenses)
          .insert(
            ExpensesCompanion.insert(
              periodId: periodId,
              pillarId: 2,
              amount: 20000,
              date: '2026-11-04',
              type: const Value('refund'),
              createdAt: 'x',
              updatedAt: 'x',
            ),
          );
      expect(await expenses.watchPillarTotals(periodId).first, {2: 30000});
    });

    test('a refund from quick add lowers its pillar (FR-28)', () async {
      await expenses.add(draft(2, 50000));
      final id = await expenses.add(
        const ExpenseDraft(pillarId: 2, amount: 15000, date: '2026-11-04', isRefund: true),
      );
      expect(await expenses.watchPillarTotals(periodId).first, {2: 35000});
      final row = await (db.select(db.expenses)..where((e) => e.id.equals(id))).getSingle();
      expect(row.type, 'refund');

      // Editing it into a normal expense flips the sign back.
      await expenses.update(id, const ExpenseDraft(pillarId: 2, amount: 15000, date: '2026-11-04'));
      expect(await expenses.watchPillarTotals(periodId).first, {2: 65000});
    });

    test('rejects dates outside any period', () async {
      expect(
        () => expenses.add(draft(1, 100, date: '2026-10-31')),
        throwsA(isA<NoPeriodForDateException>()),
      );
    });

    test('blank notes are stored as null and recent notes are distinct', () async {
      await expenses.add(draft(1, 100, note: '  '));
      await expenses.add(draft(1, 100, note: 'Groceries'));
      await expenses.add(draft(2, 100, note: 'Groceries'));
      await expenses.add(draft(3, 100, note: 'Book'));
      final rows = await expenses.watchForPeriod(periodId).first;
      expect(rows.where((e) => e.note == null).length, 1);
      expect((await expenses.recentNotes()).toSet(), {'Groceries', 'Book'});
    });

    test('purges soft-deleted rows only after 30 days', () async {
      final id = await expenses.add(draft(1, 100));
      await expenses.softDelete(id);
      expect(await expenses.purgeDeleted(), 0);
      expect(await expenses.purgeDeleted(now: DateTime.now().add(const Duration(days: 31))), 1);
    });
  });
}
