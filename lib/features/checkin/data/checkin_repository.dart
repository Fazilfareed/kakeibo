import 'package:drift/drift.dart';

import '../../../core/date/local_date.dart';
import '../../../core/db/app_database.dart';
import '../../periods/domain/period_math.dart';

/// Weekly check-ins (PRD §6.5): one note per week of a period.
class CheckinRepository {
  CheckinRepository(this._db);

  final AppDatabase _db;

  Stream<WeeklyCheckin?> watchWeek(int periodId, DateTime weekStart) =>
      (_db.select(_db.weeklyCheckins)
            ..where(
              (c) => c.periodId.equals(periodId) & c.weekStart.equals(LocalDate.format(weekStart)),
            )
            ..limit(1))
          .watchSingleOrNull();

  /// Saves (or replaces) the note for that week. A blank note still counts
  /// as a check-in.
  Future<void> save(int periodId, DateTime weekStart, String? note) => _db.transaction(() async {
    final start = LocalDate.format(weekStart);
    final t = note?.trim();
    final clean = (t == null || t.isEmpty) ? null : t;
    final existing =
        await (_db.select(_db.weeklyCheckins)
              ..where((c) => c.periodId.equals(periodId) & c.weekStart.equals(start))
              ..limit(1))
            .getSingleOrNull();
    if (existing == null) {
      await _db
          .into(_db.weeklyCheckins)
          .insert(
            WeeklyCheckinsCompanion.insert(
              periodId: periodId,
              weekStart: start,
              note: Value(clean),
            ),
          );
    } else {
      await (_db.update(
        _db.weeklyCheckins,
      )..where((c) => c.id.equals(existing.id))).write(WeeklyCheckinsCompanion(note: Value(clean)));
    }
  });

  /// Net spend per pillar for the days in [week] (refunds subtract).
  Stream<Map<int, int>> watchWeekTotals(int periodId, DateRange week) => _db
      .customSelect(
        'SELECT pillar_id, '
        "SUM(CASE WHEN type = 'refund' THEN -amount ELSE amount END) AS total "
        'FROM expenses WHERE period_id = ? AND deleted_at IS NULL '
        'AND date >= ? AND date <= ? GROUP BY pillar_id',
        variables: [
          Variable.withInt(periodId),
          Variable.withString(LocalDate.format(week.start)),
          Variable.withString(LocalDate.format(week.end)),
        ],
        readsFrom: {_db.expenses},
      )
      .watch()
      .map((rows) => {for (final r in rows) r.read<int>('pillar_id'): r.read<int>('total')});
}
