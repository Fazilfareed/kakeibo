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
  });

  final int pillarId;

  /// Positive cents.
  final int amount;

  /// Local date `yyyy-MM-dd`.
  final String date;
  final String? note;
  final Mood? mood;
  final int? paymentMethodId;
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

  Future<int> add(ExpenseDraft draft) async {
    final periodId = await _periodIdFor(draft.date);
    final stamp = LocalDate.nowStamp();
    return _db
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
            createdAt: stamp,
            updatedAt: stamp,
          ),
        );
  }

  Future<void> update(int id, ExpenseDraft draft) async {
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
        updatedAt: Value(LocalDate.nowStamp()),
      ),
    );
  }

  /// Hides an expense; [restore] brings it back (undo, FR-24).
  Future<void> softDelete(int id) => _setDeleted(id, LocalDate.nowStamp());

  Future<void> restore(int id) => _setDeleted(id, null);

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
