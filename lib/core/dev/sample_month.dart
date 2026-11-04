import 'package:drift/drift.dart';

import '../../features/periods/domain/period_math.dart';
import '../date/local_date.dart';
import '../db/app_database.dart';

/// Debug-build helper: adds a closed month before the earliest one, with a
/// plan and tagged spends, so the reflection can be tried without waiting a
/// month. Never shown in release builds.
abstract final class SampleMonth {
  /// Returns false if a sample month (or any earlier month) already exists.
  static Future<bool> add(AppDatabase db) => db.transaction(() async {
    final earliest =
        await (db.select(db.periods)
              ..orderBy([(p) => OrderingTerm.asc(p.startDate)])
              ..limit(1))
            .getSingleOrNull();
    if (earliest == null) return false;
    final firstStart = LocalDate.parse(earliest.startDate);
    if (await (db.select(
      db.periods,
    )..where((p) => p.status.equals('closed'))).get().then((rows) => rows.isNotEmpty)) {
      return false;
    }

    final dayBefore = DateTime(firstStart.year, firstStart.month, firstStart.day - 1);
    final range = PeriodMath.rangeContaining(dayBefore, firstStart.day.clamp(1, 28));
    final stamp = LocalDate.nowStamp();
    String day(int n) =>
        LocalDate.format(DateTime(range.start.year, range.start.month, range.start.day + n - 1));

    final id = await db
        .into(db.periods)
        .insert(
          PeriodsCompanion.insert(
            startDate: LocalDate.format(range.start),
            endDate: LocalDate.format(range.end),
            savingsGoal: const Value(1500000),
            savingsSetAside: const Value(true),
            status: const Value('closed'),
            createdAt: stamp,
            updatedAt: stamp,
          ),
        );
    await db.batch((b) {
      b.insert(
        db.incomes,
        IncomesCompanion.insert(periodId: id, label: 'Salary', amount: 12000000, date: day(1)),
      );
      b.insert(
        db.fixedCosts,
        FixedCostsCompanion.insert(periodId: id, label: 'Rent', amount: 4000000),
      );
      b.insertAll(db.pillarBudgets, [
        PillarBudgetsCompanion.insert(
          periodId: id,
          pillarId: 1,
          plannedAmount: const Value(3000000),
        ),
        PillarBudgetsCompanion.insert(
          periodId: id,
          pillarId: 2,
          plannedAmount: const Value(1500000),
        ),
        PillarBudgetsCompanion.insert(
          periodId: id,
          pillarId: 3,
          plannedAmount: const Value(1000000),
        ),
        PillarBudgetsCompanion.insert(
          periodId: id,
          pillarId: 4,
          plannedAmount: const Value(1000000),
        ),
      ]);
      // Spent 70,000 of 65,000 spendable: the Rs 15,000 goal is missed by 5,000.
      final spends = <(int, int, String, String?, int)>[
        (1, 1200000, 'Groceries', null, 3),
        (1, 650000, 'Electricity', null, 6),
        (1, 400000, 'Bus pass', null, 2),
        (1, 1000000, 'Groceries', null, 18),
        (2, 350000, 'Food delivery', 'regret', 9),
        (2, 850000, 'New shoes', 'regret', 14),
        (2, 150000, 'Coffee with Amaya', 'worth', 21),
        (3, 600000, 'Concert ticket', 'worth', 12),
        (3, 180000, 'Book', 'worth', 25),
        (4, 1620000, 'Phone repair', null, 16),
      ];
      b.insertAll(db.expenses, [
        for (final (pillar, amount, note, mood, d) in spends)
          ExpensesCompanion.insert(
            periodId: id,
            pillarId: pillar,
            amount: amount,
            date: day(d),
            note: Value(note),
            mood: Value(mood),
            createdAt: stamp,
            updatedAt: stamp,
          ),
      ]);
    });
    return true;
  });
}
