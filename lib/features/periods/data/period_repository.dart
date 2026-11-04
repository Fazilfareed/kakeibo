import 'package:drift/drift.dart';

import '../../../core/date/local_date.dart';
import '../../../core/db/app_database.dart';
import '../domain/period_math.dart';

/// A period together with its plan (incomes, fixed costs, pillar budgets).
class PeriodPlan {
  const PeriodPlan({
    required this.period,
    required this.incomes,
    required this.fixedCosts,
    required this.budgets,
  });

  final Period period;
  final List<Income> incomes;
  final List<FixedCost> fixedCosts;

  /// Planned cents per pillar id.
  final Map<int, int> budgets;

  DateRange get range =>
      DateRange(LocalDate.parse(period.startDate), LocalDate.parse(period.endDate));

  int get incomeTotal => incomes.fold(0, (a, i) => a + i.amount);
  int get fixedTotal => fixedCosts.fold(0, (a, f) => a + f.amount);
}

/// What the plan screen saves.
class PlanDraft {
  const PlanDraft({
    required this.incomes,
    required this.fixedCosts,
    required this.savingsGoal,
    required this.budgets,
  });

  final List<({String label, int amount})> incomes;
  final List<({String label, int amount, bool recurring})> fixedCosts;
  final int savingsGoal;
  final Map<int, int> budgets;
}

class PeriodRepository {
  PeriodRepository(this._db);

  final AppDatabase _db;

  static const _pillarIds = [1, 2, 3, 4];

  /// Makes sure a stored period contains [now], creating the first period or
  /// rolling over missed ones (PRD §12.4). Safe to call any number of times.
  Future<Period> ensureCurrentPeriod({DateTime? now}) {
    final today = LocalDate.dateOnly(now ?? DateTime.now());
    return _db.transaction(() async {
      var latest = await _latest();
      if (latest == null) {
        final startDay = await _monthStartDay();
        return _insertPeriod(PeriodMath.rangeContaining(today, startDay));
      }
      while (today.isAfter(LocalDate.parse(latest!.endDate))) {
        await (_db.update(_db.periods)..where((p) => p.id.equals(latest!.id))).write(
          PeriodsCompanion(status: const Value('closed'), updatedAt: Value(LocalDate.nowStamp())),
        );
        latest = await _createNextFrom(latest);
      }
      return latest;
    });
  }

  /// The most recent period (the current one once [ensureCurrentPeriod] ran).
  Stream<Period?> watchLatest() =>
      (_db.select(_db.periods)
            ..orderBy([(p) => OrderingTerm.desc(p.startDate)])
            ..limit(1))
          .watchSingleOrNull();

  /// FR-37/54: the improvement chosen in the previous period's reflection,
  /// shown on this period's dashboard. Null if none was set.
  Stream<String?> watchImprovementFor(Period current) => _db
      .customSelect(
        'SELECT r.improvement FROM reflections r '
        'JOIN periods p ON p.id = r.period_id '
        'WHERE p.start_date < ? ORDER BY p.start_date DESC LIMIT 1',
        variables: [Variable.withString(current.startDate)],
        readsFrom: {_db.reflections, _db.periods},
      )
      .watchSingleOrNull()
      .map((row) {
        final text = row?.readNullable<String>('improvement')?.trim();
        return text == null || text.isEmpty ? null : text;
      });

  Future<PeriodPlan> loadPlan(int periodId) async {
    final period = await (_db.select(_db.periods)..where((p) => p.id.equals(periodId))).getSingle();
    final incomes =
        await (_db.select(_db.incomes)
              ..where((i) => i.periodId.equals(periodId))
              ..orderBy([(i) => OrderingTerm.asc(i.id)]))
            .get();
    final fixed =
        await (_db.select(_db.fixedCosts)
              ..where((f) => f.periodId.equals(periodId))
              ..orderBy([(f) => OrderingTerm.asc(f.id)]))
            .get();
    final budgets = await (_db.select(
      _db.pillarBudgets,
    )..where((b) => b.periodId.equals(periodId))).get();
    return PeriodPlan(
      period: period,
      incomes: incomes,
      fixedCosts: fixed,
      budgets: {for (final b in budgets) b.pillarId: b.plannedAmount},
    );
  }

  /// The plan, reloaded whenever any of its tables change.
  Stream<PeriodPlan> watchPlan(int periodId) async* {
    yield await loadPlan(periodId);
    await for (final _ in _db.tableUpdates(
      TableUpdateQuery.onAllTables([_db.periods, _db.incomes, _db.fixedCosts, _db.pillarBudgets]),
    )) {
      yield await loadPlan(periodId);
    }
  }

  /// Replaces the period's planned incomes, fixed costs, savings goal and
  /// pillar budgets, and marks the period active.
  Future<void> savePlan(int periodId, PlanDraft draft) {
    return _db.transaction(() async {
      final period = await (_db.select(
        _db.periods,
      )..where((p) => p.id.equals(periodId))).getSingle();
      final stamp = LocalDate.nowStamp();

      await (_db.delete(
        _db.incomes,
      )..where((i) => i.periodId.equals(periodId) & i.isPlanned.equals(true))).go();
      await (_db.delete(_db.fixedCosts)..where((f) => f.periodId.equals(periodId))).go();

      await _db.batch((b) {
        b.insertAll(_db.incomes, [
          for (final i in draft.incomes)
            IncomesCompanion.insert(
              periodId: periodId,
              label: i.label,
              amount: i.amount,
              date: period.startDate,
            ),
        ]);
        b.insertAll(_db.fixedCosts, [
          for (final f in draft.fixedCosts)
            FixedCostsCompanion.insert(
              periodId: periodId,
              label: f.label,
              amount: f.amount,
              isRecurring: Value(f.recurring),
            ),
        ]);
        b.insertAllOnConflictUpdate(_db.pillarBudgets, [
          for (final id in _pillarIds)
            PillarBudgetsCompanion.insert(
              periodId: periodId,
              pillarId: id,
              plannedAmount: Value(draft.budgets[id] ?? 0),
            ),
        ]);
      });

      if (period.savingsGoal != draft.savingsGoal && period.status != 'planning') {
        await _db
            .into(_db.planChanges)
            .insert(
              PlanChangesCompanion.insert(
                periodId: periodId,
                field: 'savings_goal',
                oldValue: Value('${period.savingsGoal}'),
                newValue: Value('${draft.savingsGoal}'),
                changedAt: stamp,
              ),
            );
      }

      await (_db.update(_db.periods)..where((p) => p.id.equals(periodId))).write(
        PeriodsCompanion(
          savingsGoal: Value(draft.savingsGoal),
          savingsGoalType: const Value('amount'),
          status: Value(period.status == 'closed' ? 'closed' : 'active'),
          updatedAt: Value(stamp),
        ),
      );
    });
  }

  /// FR-18: the user has moved this month's savings aside.
  Future<void> setSavingsSetAside(int periodId, bool value) =>
      (_db.update(_db.periods)..where((p) => p.id.equals(periodId))).write(
        PeriodsCompanion(savingsSetAside: Value(value), updatedAt: Value(LocalDate.nowStamp())),
      );

  // ---------------------------------------------------------------------------

  Future<Period?> _latest() =>
      (_db.select(_db.periods)
            ..orderBy([(p) => OrderingTerm.desc(p.startDate)])
            ..limit(1))
          .getSingleOrNull();

  Future<int> _monthStartDay() async {
    final row = await (_db.select(
      _db.settings,
    )..where((s) => s.key.equals('month_start_day'))).getSingleOrNull();
    return int.tryParse(row?.value ?? '') ?? 1;
  }

  Future<Period> _insertPeriod(DateRange range, {int savingsGoal = 0}) async {
    final stamp = LocalDate.nowStamp();
    final id = await _db
        .into(_db.periods)
        .insert(
          PeriodsCompanion.insert(
            startDate: LocalDate.format(range.start),
            endDate: LocalDate.format(range.end),
            savingsGoal: Value(savingsGoal),
            createdAt: stamp,
            updatedAt: stamp,
          ),
        );
    await _db.batch(
      (b) => b.insertAll(_db.pillarBudgets, [
        for (final p in _pillarIds) PillarBudgetsCompanion.insert(periodId: id, pillarId: p),
      ]),
    );
    return (_db.select(_db.periods)..where((p) => p.id.equals(id))).getSingle();
  }

  /// Creates the period after [previous], pre-filled from its plan (FR-56).
  Future<Period> _createNextFrom(Period previous) async {
    final prevRange = DateRange(
      LocalDate.parse(previous.startDate),
      LocalDate.parse(previous.endDate),
    );
    final next = await _insertPeriod(PeriodMath.next(prevRange), savingsGoal: previous.savingsGoal);
    final plan = await loadPlan(previous.id);

    await _db.batch((b) {
      b.insertAll(_db.incomes, [
        for (final i in plan.incomes.where((i) => i.isPlanned))
          IncomesCompanion.insert(
            periodId: next.id,
            label: i.label,
            amount: i.amount,
            date: next.startDate,
          ),
      ]);
      b.insertAll(_db.fixedCosts, [
        for (final f in plan.fixedCosts.where((f) => f.isRecurring))
          FixedCostsCompanion.insert(periodId: next.id, label: f.label, amount: f.amount),
      ]);
      b.insertAllOnConflictUpdate(_db.pillarBudgets, [
        for (final e in plan.budgets.entries)
          PillarBudgetsCompanion.insert(
            periodId: next.id,
            pillarId: e.key,
            plannedAmount: Value(e.value),
          ),
      ]);
    });
    return next;
  }
}
