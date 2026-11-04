import '../../../core/date/local_date.dart';
import '../../periods/domain/period_math.dart';

/// Weeks for the check-in (FR-42): they start on the user's chosen weekday
/// and are clipped to the period, so the first and last week may be shorter.
abstract final class WeekMath {
  /// [startWeekday] uses [DateTime.monday] (1) … [DateTime.sunday] (7).
  static DateRange weekContaining(DateTime day, int startWeekday, DateRange period) {
    final d = LocalDate.dateOnly(day);
    final back = (d.weekday - startWeekday) % 7;
    var start = DateTime(d.year, d.month, d.day - back);
    var end = DateTime(start.year, start.month, start.day + 6);
    if (start.isBefore(period.start)) start = period.start;
    if (end.isAfter(period.end)) end = period.end;
    return DateRange(start, end);
  }

  /// The week before [week] within the same period, or null for the first.
  static DateRange? previous(DateRange week, int startWeekday, DateRange period) {
    if (!week.start.isAfter(period.start)) return null;
    final dayBefore = DateTime(week.start.year, week.start.month, week.start.day - 1);
    return weekContaining(dayBefore, startWeekday, period);
  }
}
