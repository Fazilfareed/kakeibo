import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:logging/logging.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../domain/reminder_planner.dart';

final _log = Logger('reminders');

/// Local notifications (PRD §6.9). Everything is scheduled on the phone;
/// inexact alarms are used, so no exact-alarm permission is needed.
class NotificationService {
  NotificationService([FlutterLocalNotificationsPlugin? plugin])
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _ready = false;

  /// Opens the route stored on a tapped notification.
  ValueChanged<String>? onOpenRoute;

  static const _channel = AndroidNotificationDetails(
    'reminders',
    'Reminders',
    channelDescription: 'Daily log, weekly check-in and month reminders',
    importance: Importance.defaultImportance,
    priority: Priority.defaultPriority,
    category: AndroidNotificationCategory.reminder,
  );

  Future<void> init() async {
    if (_ready) return;
    tzdata.initializeTimeZones();
    try {
      final zone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(zone.identifier));
    } on Object catch (e) {
      // Fall back to UTC offsets as reported by the device.
      _log.warning('Unknown timezone, using UTC', e);
    }
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
      onDidReceiveNotificationResponse: (r) {
        if (r.payload != null) onOpenRoute?.call(r.payload!);
      },
    );
    _ready = true;

    // Opened from a notification while the app was closed.
    final launch = await _plugin.getNotificationAppLaunchDetails();
    final payload = launch?.notificationResponse?.payload;
    if ((launch?.didNotificationLaunchApp ?? false) && payload != null) {
      onOpenRoute?.call(payload);
    }
  }

  AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

  /// False when the user turned notifications off for the app (FR-83).
  Future<bool> enabled() async {
    await init();
    return await _android?.areNotificationsEnabled() ?? false;
  }

  /// Android 13+ asks the user; older versions return the current state.
  Future<bool> requestPermission() async {
    await init();
    final granted = await _android?.requestNotificationsPermission();
    return granted ?? await enabled();
  }

  /// Replaces every scheduled reminder with [reminders].
  Future<void> replaceAll(List<PlannedReminder> reminders) async {
    await init();
    await _plugin.cancelAll();
    for (final r in reminders) {
      await _plugin.zonedSchedule(
        id: r.id,
        title: r.title,
        body: r.body,
        payload: r.route,
        scheduledDate: tz.TZDateTime.from(r.at, tz.local),
        notificationDetails: const NotificationDetails(android: _channel),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
    _log.info('Scheduled ${reminders.length} reminders: $reminders');
  }
}
