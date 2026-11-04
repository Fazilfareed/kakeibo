import 'package:intl/intl.dart';

/// Local calendar dates stored as `yyyy-MM-dd` text (PRD NFR-14).
abstract final class LocalDate {
  static final DateFormat _iso = DateFormat('yyyy-MM-dd');

  /// Midnight of [d] in local time, without the time-of-day part.
  static DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static String format(DateTime d) => _iso.format(d);

  static DateTime parse(String s) => dateOnly(DateTime.parse(s));

  static String today([DateTime? now]) => format(now ?? DateTime.now());

  /// Whole days from [a] to [b] (b − a), ignoring daylight-saving shifts.
  static int daysBetween(DateTime a, DateTime b) =>
      DateTime.utc(b.year, b.month, b.day).difference(DateTime.utc(a.year, a.month, a.day)).inDays;

  /// UTC timestamp for `created_at` / `updated_at` columns.
  static String nowStamp() => DateTime.now().toUtc().toIso8601String();
}
