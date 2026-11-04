import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/features/periods/domain/period_math.dart';
import 'package:kakeibo/features/reminders/domain/reminder_planner.dart';

void main() {
  final nov = DateRange(DateTime(2026, 11, 1), DateTime(2026, 11, 30));

  ReminderContext ctx({
    DateTime? now,
    bool logged = false,
    bool checkedIn = false,
    bool planned = true,
    DateRange? period,
  }) => ReminderContext(
    now: now ?? DateTime(2026, 11, 4, 13, 0), // a Wednesday
    period: period ?? nov,
    periodPlanned: planned,
    weekStartDay: DateTime.monday,
    loggedToday: logged,
    checkedInThisWeek: checkedIn,
  );

  List<PlannedReminder> of(List<PlannedReminder> all, ReminderKind k) =>
      all.where((r) => r.kind == k).toList();

  test('nothing is scheduled until reminders are turned on', () {
    expect(ReminderPlanner.plan(const ReminderSettings(), ctx()), isEmpty);
  });

  test('daily reminders for 7 days; logging today drops only today (FR-80)', () {
    const s = ReminderSettings(on: true, weekly: false, monthly: false);
    final all = of(ReminderPlanner.plan(s, ctx()), ReminderKind.daily);
    expect(all.length, 7);
    expect(all.first.at, DateTime(2026, 11, 4, 21));
    expect(all.last.at, DateTime(2026, 11, 10, 21));

    final logged = of(ReminderPlanner.plan(s, ctx(logged: true)), ReminderKind.daily);
    expect(logged.length, 6);
    expect(logged.first.at, DateTime(2026, 11, 5, 21));
  });

  test('times already passed today are skipped; ids are stable per day', () {
    const s = ReminderSettings(on: true, weekly: false, monthly: false);
    final late = ReminderPlanner.plan(s, ctx(now: DateTime(2026, 11, 4, 21, 30)));
    expect(late.first.at, DateTime(2026, 11, 5, 21));
    expect(late.first.id, 101);
  });

  test('evening reminder is optional (FR-85)', () {
    const s = ReminderSettings(
      on: true,
      daily: false,
      weekly: false,
      monthly: false,
      evening: true,
    );
    final all = ReminderPlanner.plan(s, ctx(logged: true));
    expect(all.length, 7, reason: 'still asks for cash even after logging');
    expect(all.first.at, DateTime(2026, 11, 4, 22, 30));
  });

  test('weekly check-in on the last day of the week, unless done (FR-81)', () {
    const s = ReminderSettings(on: true, daily: false, monthly: false);
    final weekly = ReminderPlanner.plan(s, ctx());
    expect(weekly.map((r) => r.at), [DateTime(2026, 11, 8, 19)]);
    expect(weekly.single.route, '/checkin');

    // Done this week: the next one is beyond the 7-day window.
    expect(ReminderPlanner.plan(s, ctx(checkedIn: true)), isEmpty);
    // From Monday, the next week end is inside the 7-day window.
    final monday = ReminderPlanner.plan(s, ctx(now: DateTime(2026, 11, 9, 10)));
    expect(monday.map((r) => r.at), [DateTime(2026, 11, 15, 19)]);
  });

  test('plan and reflect when a month starts and ends (FR-82)', () {
    const s = ReminderSettings(on: true, daily: false, weekly: false);
    final endOfMonth = ReminderPlanner.plan(s, ctx(now: DateTime(2026, 11, 27, 10)));
    expect(endOfMonth.map((r) => (r.kind, r.at)), [
      (ReminderKind.plan, DateTime(2026, 12, 1, 9)),
      (ReminderKind.reflect, DateTime(2026, 12, 1, 19)),
    ]);
    expect(ReminderPlanner.plan(s, ctx()), isEmpty, reason: 'month end is weeks away');

    final unplanned = ReminderPlanner.plan(s, ctx(now: DateTime(2026, 11, 1, 7), planned: false));
    expect(unplanned.single.at, DateTime(2026, 11, 1, 9));
  });

  test('times are parsed and formatted safely', () {
    expect(ReminderSettings.parseTime('07:05'), (hour: 7, minute: 5));
    expect(ReminderSettings.parseTime('25:00'), isNull);
    expect(ReminderSettings.parseTime('soon'), isNull);
    expect(ReminderSettings.formatTime((hour: 7, minute: 5)), '07:05');
    final s = ReminderSettings.fromMap({
      ReminderSettings.keyOn: 'true',
      ReminderSettings.keyDailyTime: '20:15',
      ReminderSettings.keyWeekly: 'false',
    });
    expect(s.on, isTrue);
    expect(s.dailyTime, (hour: 20, minute: 15));
    expect(s.weekly, isFalse);
    expect(s.monthly, isTrue);
  });
}
