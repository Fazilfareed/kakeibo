import 'package:drift/drift.dart';

import '../../../core/date/local_date.dart';
import '../../../core/db/app_database.dart';
import '../../expenses/data/expense_repository.dart';
import '../domain/reflection_summary.dart';

/// Month-end reflections (PRD §6.6). One row per period; it is a draft until
/// `completed_at` is set, after which its totals are frozen (FR-58).
class ReflectionRepository {
  ReflectionRepository(this._db);

  final AppDatabase _db;

  /// The latest closed period whose reflection is not finished, if any. It
  /// stays on Home as a card until it is done; logging is never blocked.
  Stream<Period?> watchPending() => _db
      .customSelect(
        'SELECT p.* FROM periods p '
        'LEFT JOIN reflections r ON r.period_id = p.id '
        "WHERE p.status = 'closed' AND r.completed_at IS NULL "
        'ORDER BY p.start_date DESC LIMIT 1',
        readsFrom: {_db.periods, _db.reflections},
      )
      .watchSingleOrNull()
      .map((row) => row == null ? null : _db.periods.map(row.data));

  Future<ReflectionSummary> load(int periodId) async {
    final period = await (_db.select(_db.periods)..where((p) => p.id.equals(periodId))).getSingle();
    final incomes = await (_db.select(
      _db.incomes,
    )..where((i) => i.periodId.equals(periodId))).get();
    final fixed = await (_db.select(
      _db.fixedCosts,
    )..where((f) => f.periodId.equals(periodId))).get();
    final budgets = await (_db.select(
      _db.pillarBudgets,
    )..where((b) => b.periodId.equals(periodId))).get();
    final expenses = await (_db.select(
      _db.expenses,
    )..where((e) => e.periodId.equals(periodId) & e.deletedAt.isNull())).get();
    final saved = await (_db.select(
      _db.reflections,
    )..where((r) => r.periodId.equals(periodId))).getSingleOrNull();

    final spent = <int, int>{};
    for (final e in expenses) {
      spent[e.pillarId] = (spent[e.pillarId] ?? 0) + (e.type == 'refund' ? -e.amount : e.amount);
    }
    List<Expense> tagged(Mood mood) =>
        expenses.where((e) => e.type != 'refund' && e.mood == mood.name).toList()
          ..sort((a, b) => b.amount.compareTo(a.amount));

    final previous = await _db
        .customSelect(
          'SELECT r.improvement FROM reflections r JOIN periods p ON p.id = r.period_id '
          'WHERE p.start_date < ? AND r.completed_at IS NOT NULL '
          'ORDER BY p.start_date DESC LIMIT 1',
          variables: [Variable.withString(period.startDate)],
          readsFrom: {_db.reflections, _db.periods},
        )
        .getSingleOrNull();
    final completedCount = await _db
        .customSelect(
          'SELECT COUNT(*) AS n FROM reflections WHERE completed_at IS NOT NULL AND period_id != ?',
          variables: [Variable.withInt(periodId)],
          readsFrom: {_db.reflections},
        )
        .getSingle();

    return ReflectionSummary(
      period: period,
      income: incomes.fold(0, (a, i) => a + i.amount),
      fixed: fixed.fold(0, (a, f) => a + f.amount),
      spentByPillar: spent,
      plannedByPillar: {for (final b in budgets) b.pillarId: b.plannedAmount},
      worthIt: tagged(Mood.worth),
      regrets: tagged(Mood.regret),
      previousImprovement: _blankToNull(previous?.readNullable<String>('improvement')),
      isFirstReflection: completedCount.read<int>('n') == 0,
      saved: saved,
    );
  }

  /// Keeps the answers so far, so leaving the wizard loses nothing.
  Future<void> saveDraft(ReflectionDraft draft) => _db.transaction(() async {
    final summary = await load(draft.periodId);
    if (summary.saved?.completedAt != null) return;
    await _upsert(draft, summary, completedAt: null);
  });

  /// Finishes the reflection and freezes its totals (FR-55, FR-58).
  Future<void> complete(ReflectionDraft draft) => _db.transaction(() async {
    final summary = await load(draft.periodId);
    await _upsert(draft, summary, completedAt: summary.saved?.completedAt ?? LocalDate.nowStamp());
  });

  Future<void> _upsert(ReflectionDraft d, ReflectionSummary s, {required String? completedAt}) {
    return _db
        .into(_db.reflections)
        .insertOnConflictUpdate(
          ReflectionsCompanion.insert(
            periodId: Value(d.periodId),
            savedAmount: s.savedAmount,
            goalMet: s.goalMet,
            answerQ1: Value(_blankToNull(d.answer1)),
            answerQ2: Value(_blankToNull(d.answer2)),
            answerQ3: Value(_blankToNull(d.answer3)),
            answerQ4: Value(_blankToNull(d.improvement)),
            prevImprovementKept: Value(d.improvementKept?.name),
            improvement: Value(_blankToNull(d.improvement)),
            completedAt: Value(completedAt),
            editedAfterClose: Value(s.saved?.editedAfterClose ?? 0),
          ),
        );
  }

  static String? _blankToNull(String? s) {
    final t = s?.trim();
    return (t == null || t.isEmpty) ? null : t;
  }
}
