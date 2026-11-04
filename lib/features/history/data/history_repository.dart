import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';

/// One month in History (FR-60).
class MonthRecord {
  const MonthRecord({
    required this.period,
    required this.income,
    required this.fixed,
    required this.spentByPillar,
    required this.reflection,
  });

  final Period period;
  final int income;
  final int fixed;

  /// Net spend per pillar id (expenses minus refunds).
  final Map<int, int> spentByPillar;
  final Reflection? reflection;

  bool get isClosed => period.status == 'closed';
  bool get reflectionDone => reflection?.completedAt != null;
  int get spent => spentByPillar.values.fold(0, (a, b) => a + b);
  int get savingsGoal => period.savingsGoal;

  /// What was left over. A completed reflection keeps its frozen snapshot
  /// (FR-58); otherwise it is computed live.
  int get savedAmount => reflectionDone ? reflection!.savedAmount : income - fixed - spent;

  bool get goalMet => savedAmount >= savingsGoal && savedAmount > 0;

  /// Spend change after the reflection froze the month (FR-58).
  int get editedAfterClose => reflection?.editedAfterClose ?? 0;
}

class HistoryRepository {
  HistoryRepository(this._db);

  final AppDatabase _db;

  /// Every month, newest first, including the current one. Re-emits whenever
  /// the underlying data changes.
  Stream<List<MonthRecord>> watchMonths() async* {
    yield await loadMonths();
    await for (final _ in _db.tableUpdates(
      TableUpdateQuery.onAllTables([
        _db.periods,
        _db.incomes,
        _db.fixedCosts,
        _db.expenses,
        _db.reflections,
      ]),
    )) {
      yield await loadMonths();
    }
  }

  Future<List<MonthRecord>> loadMonths() async {
    final periods = await (_db.select(
      _db.periods,
    )..orderBy([(p) => OrderingTerm.desc(p.startDate)])).get();
    final income = await _sumBy('incomes');
    final fixed = await _sumBy('fixed_costs');
    final reflections = {for (final r in await _db.select(_db.reflections).get()) r.periodId: r};

    final spendRows = await _db
        .customSelect(
          'SELECT period_id, pillar_id, '
          "SUM(CASE WHEN type = 'refund' THEN -amount ELSE amount END) AS total "
          'FROM expenses WHERE deleted_at IS NULL GROUP BY period_id, pillar_id',
          readsFrom: {_db.expenses},
        )
        .get();
    final spent = <int, Map<int, int>>{};
    for (final r in spendRows) {
      (spent[r.read<int>('period_id')] ??= {})[r.read<int>('pillar_id')] = r.read<int>('total');
    }

    return [
      for (final p in periods)
        MonthRecord(
          period: p,
          income: income[p.id] ?? 0,
          fixed: fixed[p.id] ?? 0,
          spentByPillar: spent[p.id] ?? const {},
          reflection: reflections[p.id],
        ),
    ];
  }

  Future<Map<int, int>> _sumBy(String table) async {
    final rows = await _db
        .customSelect(
          'SELECT period_id, SUM(amount) AS total FROM $table GROUP BY period_id',
          readsFrom: {table == 'incomes' ? _db.incomes : _db.fixedCosts},
        )
        .get();
    return {for (final r in rows) r.read<int>('period_id'): r.read<int>('total')};
  }
}

/// FR-63: lifetime savings, the sum of what every closed month saved.
int lifetimeSavings(List<MonthRecord> months) =>
    months.where((m) => m.isClosed).fold(0, (a, m) => a + m.savedAmount);
