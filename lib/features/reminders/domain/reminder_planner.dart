import '../../../core/date/local_date.dart';
import '../../checkin/domain/week_math.dart';
import '../../periods/domain/period_math.dart';

enum ReminderKind { daily, evening, weekly, plan, reflect }

/// One notification to schedule.
class PlannedReminder {
  const PlannedReminder({
    required this.id,
    required this.kind,
    required this.at,
    required this.title,
    required this.body,
    required this.route,
  });

  /// Stable per kind and day, so re-planning replaces rather than duplicates.
  final int id;
  final ReminderKind kind;

  /// Local wall-clock time.
  final DateTime at;
  final String title;
  final String body;

  /// Where tapping it opens.
  final String route;

  @override
  String toString() => '${kind.name} ${at.toIso8601String()}';
}

/// The user's reminder choices (PRD §11.2 settings).
class ReminderSettings {
  const ReminderSettings({
    this.on = false,
    this.daily = true,
    this.dailyTime = const (hour: 21, minute: 0),
    this.evening = false,
    this.eveningTime = const (hour: 22, minute: 30),
    this.weekly = true,
    this.monthly = true,
  });

  /// Master switch, off until the user turns reminders on (FR-86).
  final bool on;
  final bool daily;
  final ({int hour, int minute}) dailyTime;
  final bool evening;
  final ({int hour, int minute}) eveningTime;
  final bool weekly;

  /// Month-start "plan" and month-end "reflect" (FR-82).
  final bool monthly;

  static const keyOn = 'reminders_on';
  static const keyDaily = 'reminders_enabled.daily';
  static const keyDailyTime = 'reminder_daily_time';
  static const keyEvening = 'reminders_enabled.evening';
  static const keyEveningTime = 'reminder_evening_time';
  static const keyWeekly = 'reminders_enabled.weekly';
  static const keyMonthly = 'reminders_enabled.monthly';

  /// Weekly check-in and month reminders use fixed, calm times.
  static const weeklyTime = (hour: 19, minute: 0);
  static const planTime = (hour: 9, minute: 0);
  static const reflectTime = (hour: 19, minute: 0);

  factory ReminderSettings.fromMap(Map<String, String> m) {
    bool flag(String k, bool fallback) => m[k] == null ? fallback : m[k] == 'true';
    return ReminderSettings(
      on: flag(keyOn, false),
      daily: flag(keyDaily, true),
      dailyTime: parseTime(m[keyDailyTime]) ?? (hour: 21, minute: 0),
      evening: flag(keyEvening, false),
      eveningTime: parseTime(m[keyEveningTime]) ?? (hour: 22, minute: 30),
      weekly: flag(keyWeekly, true),
      monthly: flag(keyMonthly, true),
    );
  }

  static ({int hour, int minute})? parseTime(String? s) {
    final m = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(s ?? '');
    if (m == null) return null;
    final h = int.parse(m[1]!), min = int.parse(m[2]!);
    return (h > 23 || min > 59) ? null : (hour: h, minute: min);
  }

  static String formatTime(({int hour, int minute}) t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}

/// What the planner needs to know about the ledger right now.
class ReminderContext {
  const ReminderContext({
    required this.now,
    required this.period,
    required this.periodPlanned,
    required this.weekStartDay,
    required this.loggedToday,
    required this.checkedInThisWeek,
  });

  final DateTime now;
  final DateRange period;
  final bool periodPlanned;
  final int weekStartDay;
  final bool loggedToday;
  final bool checkedInThisWeek;
}

/// FR-80–82, FR-85: reminders for the next 7 days. Re-run on every app open
/// and whenever the ledger changes; logging a spend drops today's daily one.
abstract final class ReminderPlanner {
  static const days = 7;

  static List<PlannedReminder> plan(ReminderSettings s, ReminderContext c) {
    if (!s.on) return const [];
    final today = LocalDate.dateOnly(c.now);
    DateTime at(DateTime day, ({int hour, int minute}) t) =>
        DateTime(day.year, day.month, day.day, t.hour, t.minute);
    final out = <PlannedReminder>[];
    void add(PlannedReminder r) {
      if (r.at.isAfter(c.now)) out.add(r);
    }

    for (var i = 0; i < days; i++) {
      final day = DateTime(today.year, today.month, today.day + i);
      if (s.daily && !(i == 0 && c.loggedToday)) {
        add(
          PlannedReminder(
            id: 100 + i,
            kind: ReminderKind.daily,
            at: at(day, s.dailyTime),
            title: 'Log today’s spending',
            body: 'A few taps keeps your month honest.',
            route: '/home',
          ),
        );
      }
      if (s.evening) {
        add(
          PlannedReminder(
            id: 200 + i,
            kind: ReminderKind.evening,
            at: at(day, s.eveningTime),
            title: 'Anything else today?',
            body: 'Cash spends are the easiest to forget.',
            route: '/home',
          ),
        );
      }
    }

    // FR-81: on the last day of each week, unless this week is done.
    if (s.weekly) {
      var week = WeekMath.weekContaining(today, c.weekStartDay, c.period);
      for (var k = 0; k < 2; k++) {
        if (!(k == 0 && c.checkedInThisWeek)) {
          add(
            PlannedReminder(
              id: 300 + k,
              kind: ReminderKind.weekly,
              at: at(week.end, ReminderSettings.weeklyTime),
              title: 'Weekly check-in',
              body: 'How did this week go? One thing to watch next week?',
              route: '/checkin',
            ),
          );
        }
        if (!week.end.isBefore(c.period.end)) break;
        final next = DateTime(week.end.year, week.end.month, week.end.day + 1);
        week = WeekMath.weekContaining(next, c.weekStartDay, c.period);
      }
    }

    // FR-82: plan on the first day of a month, reflect when one has ended.
    if (s.monthly) {
      if (!c.periodPlanned) {
        add(
          PlannedReminder(
            id: 400,
            kind: ReminderKind.plan,
            at: at(c.period.start, ReminderSettings.planTime),
            title: 'Plan your month',
            body: 'Income, fixed costs and what you’ll save first.',
            route: '/plan',
          ),
        );
      }
      final nextStart = DateTime(c.period.end.year, c.period.end.month, c.period.end.day + 1);
      add(
        PlannedReminder(
          id: 401,
          kind: ReminderKind.plan,
          at: at(nextStart, ReminderSettings.planTime),
          title: 'A new month starts today',
          body: 'Take a minute to plan it.',
          route: '/plan',
        ),
      );
      add(
        PlannedReminder(
          id: 402,
          kind: ReminderKind.reflect,
          at: at(nextStart, ReminderSettings.reflectTime),
          title: 'Reflect on last month',
          body: 'Five quiet minutes: what went well, what to change.',
          route: '/home',
        ),
      );
    }

    final horizon = DateTime(today.year, today.month, today.day + days);
    return out.where((r) => r.at.isBefore(horizon)).toList()..sort((a, b) => a.at.compareTo(b.at));
  }
}
