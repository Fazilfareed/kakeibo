import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

import '../../../core/date/local_date.dart';
import '../../checkin/data/checkin_providers.dart';
import '../../periods/data/period_providers.dart';
import '../../settings/data/settings_repository.dart';
import '../../stats/data/stats_providers.dart';
import '../domain/reminder_planner.dart';
import 'notification_service.dart';

final _log = Logger('reminders');

final notificationServiceProvider = Provider<NotificationService>((ref) => NotificationService());

final reminderSettingsProvider = Provider<ReminderSettings>(
  (ref) => ReminderSettings.fromMap(ref.watch(settingsProvider).value ?? const {}),
);

/// Whether Android lets the app post notifications. Re-checked on resume.
final notificationsAllowedProvider = FutureProvider<bool>(
  (ref) => ref.watch(notificationServiceProvider).enabled(),
);

/// Keeps the scheduled reminders in step with the ledger: watched by the
/// app root, so any change (a spend, a check-in, a setting, a new day on
/// resume) re-plans the next 7 days (FR-80). Unchanged plans aren't re-sent.
final reminderSyncProvider = Provider<void>((ref) {
  final settings = ref.watch(reminderSettingsProvider);
  final period = ref.watch(currentPeriodProvider).value;
  final summary = ref.watch(currentSummaryProvider);
  final dates = ref.watch(spendDatesProvider).value;
  final checkin = ref.watch(currentCheckinProvider);
  final weekStart = ref.watch(weekStartDayProvider);
  // Wait for this week's check-in too: while it loads, the old (empty) value
  // would schedule a check-in reminder only to cancel it a moment later.
  if (period == null || summary == null || dates == null) return;
  if (!checkin.hasValue || checkin.isLoading) return;

  final planned = ReminderPlanner.plan(
    settings,
    ReminderContext(
      now: DateTime.now(),
      period: summary.range,
      periodPlanned: period.status != 'planning',
      weekStartDay: weekStart,
      loggedToday: dates.contains(LocalDate.today()),
      checkedInThisWeek: checkin.value != null,
    ),
  );
  final key = planned.map((r) => '${r.id}@${r.at}').join('|');
  if (key == _lastPlan) return;
  _lastPlan = key;
  ref.read(notificationServiceProvider).replaceAll(planned).catchError((Object e, StackTrace st) {
    _lastPlan = null;
    _log.severe('Scheduling reminders failed', e, st);
  });
});

String? _lastPlan;
