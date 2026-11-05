import 'package:drift/drift.dart';

import '../../../core/date/local_date.dart';
import '../../../core/db/app_database.dart';

/// Mood tag on an expense (FR-23).
enum Mood {
  worth('Worth it'),
  neutral('Neutral'),
  regret('Regret');

  const Mood(this.label);
  final String label;

  static Mood? fromName(String? name) => Mood.values.where((m) => m.name == name).firstOrNull;
}

/// What the quick-add sheet saves.
class ExpenseDraft {
  const ExpenseDraft({
    required this.pillarId,
    required this.amount,
    required this.date,
    this.note,
    this.mood,
    this.paymentMethodId,
    this.isRefund = false,
  });

  final int pillarId;

  /// Positive cents.
  final int amount;

  /// Local date `yyyy-MM-dd`.
  final String date;
  final String? note;
  final Mood? mood;
  final int? paymentMethodId;

  /// FR-28: money back, counted as negative spend in its pillar.
  final bool isRefund;

  String get type => isRefund ? 'refund' : 'expense';

  /// Net effect on spending.
  int get net => isRefund ? -amount : amount;
}

class NoPeriodForDateException implements Exception {
  const NoPeriodForDateException(this.date);
  final String date;

  @override
  String toString() => 'No period contains $date';
}

class ExpenseRepository {
  ExpenseRepository(this._db);

  final AppDatabase _db;

  static const Duration purgeAfter = Duration(days: 30);

  Future<int> add(ExpenseDraft draft) => _db.transaction(() async {
    final periodId = await _periodIdFor(draft.date);
    final stamp = LocalDate.nowStamp();
    final id = await _db
        .into(_db.expenses)
        .insert(
          ExpensesCompanion.insert(
            periodId: periodId,
            pillarId: draft.pillarId,
            amount: draft.amount,
            date: draft.date,
            note: Value(_clean(draft.note)),
            mood: Value(draft.mood?.name),
            paymentMethodId: Value(draft.paymentMethodId),
            type: Value(draft.type),
            createdAt: stamp,
            updatedAt: stamp,
          ),
        );
    await _trackFrozen(periodId, draft.net);
    return id;
  });

  Future<void> update(int id, ExpenseDraft draft) => _db.transaction(() async {
    final old = await _byId(id);
    final periodId = await _periodIdFor(draft.date);
    await (_db.update(_db.expenses)..where((e) => e.id.equals(id))).write(
      ExpensesCompanion(
        periodId: Value(periodId),
        pillarId: Value(draft.pillarId),
        amount: Value(draft.amount),
        date: Value(draft.date),
        note: Value(_clean(draft.note)),
        mood: Value(draft.mood?.name),
        paymentMethodId: Value(draft.paymentMethodId),
        type: Value(draft.type),
        updatedAt: Value(LocalDate.nowStamp()),
      ),
    );
    if (old.deletedAt == null) await _trackFrozen(old.periodId, -_net(old));
    if (old.deletedAt == null) await _trackFrozen(periodId, draft.net);
  });

  /// Hides an expense; [restore] brings it back (undo, FR-24).
  Future<void> softDelete(int id) => _db.transaction(() async {
    final old = await _byId(id);
    if (old.deletedAt != null) return;
    await _setDeleted(id, LocalDate.nowStamp());
    await _trackFrozen(old.periodId, -_net(old));
  });

  Future<void> restore(int id) => _db.transaction(() async {
    final old = await _byId(id);
    if (old.deletedAt == null) return;
    await _setDeleted(id, null);
    await _trackFrozen(old.periodId, _net(old));
  });

  /// Permanently removes soft-deleted rows older than [purgeAfter].
  Future<int> purgeDeleted({DateTime? now}) {
    final cutoff = (now ?? DateTime.now()).toUtc().subtract(purgeAfter).toIso8601String();
    return (_db.delete(
      _db.expenses,
    )..where((e) => e.deletedAt.isNotNull() & e.deletedAt.isSmallerThanValue(cutoff))).go();
  }

  /// Visible expenses of a period, newest first.
  Stream<List<Expense>> watchForPeriod(int periodId) =>
      (_db.select(_db.expenses)
            ..where((e) => e.periodId.equals(periodId) & e.deletedAt.isNull())
            ..orderBy([(e) => OrderingTerm.desc(e.date), (e) => OrderingTerm.desc(e.createdAt)]))
          .watch();

  /// Net spend per pillar for a period (refunds subtract).
  Stream<Map<int, int>> watchPillarTotals(int periodId) {
    return _db
        .customSelect(
          'SELECT pillar_id, '
          "SUM(CASE WHEN type = 'refund' THEN -amount ELSE amount END) AS total "
          'FROM expenses WHERE period_id = ? AND deleted_at IS NULL '
          'GROUP BY pillar_id',
          variables: [Variable.withInt(periodId)],
          readsFrom: {_db.expenses},
        )
        .watch()
        .map((rows) => {for (final r in rows) r.read<int>('pillar_id'): r.read<int>('total')});
  }

  /// Most recently used distinct notes, for one-tap suggestions (FR-25).
  Future<List<String>> recentNotes({int limit = 6}) async {
    final rows = await _db
        .customSelect(
          'SELECT note, MAX(created_at) AS last FROM expenses '
          "WHERE note IS NOT NULL AND note != '' AND deleted_at IS NULL "
          'GROUP BY note ORDER BY last DESC LIMIT ?',
          variables: [Variable.withInt(limit)],
          readsFrom: {_db.expenses},
        )
        .get();
    return [for (final r in rows) r.read<String>('note')];
  }

  Stream<List<PaymentMethod>> watchPaymentMethods() =>
      (_db.select(_db.paymentMethods)
            ..where((m) => m.isHidden.equals(false))
            ..orderBy([(m) => OrderingTerm.asc(m.sortOrder)]))
          .watch();

  // ---------------------------------------------------------------------------

  Future<Expense> _byId(int id) =>
      (_db.select(_db.expenses)..where((e) => e.id.equals(id))).getSingle();

  static int _net(Expense e) => e.type == 'refund' ? -e.amount : e.amount;

  /// FR-58: once a period's reflection is completed its totals are frozen, and
  /// later changes to its spending are added up in `edited_after_close`.
  Future<void> _trackFrozen(int periodId, int spendDelta) async {
    if (spendDelta == 0) return;
    await _db.customUpdate(
      'UPDATE reflections SET edited_after_close = edited_after_close + ? '
      'WHERE period_id = ? AND completed_at IS NOT NULL',
      variables: [Variable.withInt(spendDelta), Variable.withInt(periodId)],
      updates: {_db.reflections},
    );
  }

  Future<void> _setDeleted(int id, String? stamp) =>
      (_db.update(_db.expenses)..where((e) => e.id.equals(id))).write(
        ExpensesCompanion(deletedAt: Value(stamp), updatedAt: Value(LocalDate.nowStamp())),
      );

  Future<int> _periodIdFor(String date) async {
    final period =
        await (_db.select(_db.periods)
              ..where(
                (p) =>
                    p.startDate.isSmallerOrEqualValue(date) & p.endDate.isBiggerOrEqualValue(date),
              )
              ..limit(1))
            .getSingleOrNull();
    if (period == null) throw NoPeriodForDateException(date);
    return period.id;
  }

  static String? _clean(String? note) {
    final t = note?.trim();
    return (t == null || t.isEmpty) ? null : t;
  }
}
