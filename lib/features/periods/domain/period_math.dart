import '../../../core/date/local_date.dart';

/// An inclusive range of local dates.
class DateRange {
  const DateRange(this.start, this.end);

  final DateTime start;
  final DateTime end;

  int get totalDays => LocalDate.daysBetween(start, end) + 1;

  bool contains(DateTime day) {
    final d = LocalDate.dateOnly(day);
    return !d.isBefore(start) && !d.isAfter(end);
  }

  @override
  bool operator ==(Object other) =>
      other is DateRange && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() => '${LocalDate.format(start)}..${LocalDate.format(end)}';
}

/// Period rules from PRD §12.1. The month start day is limited to 1–28 so
/// every month has that day.
abstract final class PeriodMath {
  static const int minStartDay = 1;
  static const int maxStartDay = 28;

  /// The period that contains [today] for a given [startDay].
  static DateRange rangeContaining(DateTime today, int startDay) {
    final d = LocalDate.dateOnly(today);
    final day = startDay.clamp(minStartDay, maxStartDay);
    final start = d.day >= day
        ? DateTime(d.year, d.month, day)
        : DateTime(d.year, d.month - 1, day);
    return DateRange(start, _endFor(start));
  }

  /// The period that starts the day after [previous] ends.
  static DateRange next(DateRange previous) {
    final start = previous.end.add(const Duration(days: 1));
    final s = DateTime(start.year, start.month, start.day);
    return DateRange(s, _endFor(s));
  }

  /// One month after [start], minus one day.
  static DateTime _endFor(DateTime start) =>
      DateTime(start.year, start.month + 1, start.day - 1);
}
