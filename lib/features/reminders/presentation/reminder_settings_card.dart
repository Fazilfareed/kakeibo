import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../app/theme/kakeibo_colors.dart';
import '../../../app/theme/kakeibo_text.dart';
import '../../../app/theme/tokens.dart';
import '../../settings/data/settings_repository.dart';
import '../data/reminder_providers.dart';
import '../domain/reminder_planner.dart';

/// Settings → Reminders (PRD §6.9). Turning reminders on explains why first,
/// then asks Android for permission (FR-86).
class ReminderSettingsCard extends ConsumerWidget {
  const ReminderSettingsCard({super.key});

  Future<void> _turnOn(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Turn on reminders?'),
        content: const Text(
          'Kakeibo can nudge you to log the day’s spending, check in each week and '
          'reflect at the end of the month. Reminders are set on this phone; nothing is sent '
          'anywhere.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Not now')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final granted = await ref.read(notificationServiceProvider).requestPermission();
    ref.invalidate(notificationsAllowedProvider);
    await ref.read(settingsRepositoryProvider).set(ReminderSettings.keyOn, 'true');
    if (!granted && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notifications are off for Kakeibo. Reminders will show on Home instead.'),
        ),
      );
    }
  }

  Future<void> _pickTime(
    BuildContext context,
    WidgetRef ref,
    String key,
    ({int hour, int minute}) current,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: current.hour, minute: current.minute),
    );
    if (picked == null) return;
    await ref
        .read(settingsRepositoryProvider)
        .set(key, ReminderSettings.formatTime((hour: picked.hour, minute: picked.minute)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final s = ref.watch(reminderSettingsProvider);
    final allowed = ref.watch(notificationsAllowedProvider).value ?? true;
    final repo = ref.read(settingsRepositoryProvider);
    void set(String key, bool v) => repo.set(key, '$v');
    String time(({int hour, int minute}) t) =>
        TimeOfDay(hour: t.hour, minute: t.minute).format(context);

    return Card(
      child: Column(
        children: [
          SwitchListTile(
            secondary: const Icon(Symbols.notifications_rounded),
            title: const Text('Reminders'),
            subtitle: Text(s.on ? 'On' : 'Off'),
            value: s.on,
            onChanged: (v) => v ? _turnOn(context, ref) : set(ReminderSettings.keyOn, false),
          ),
          if (s.on) ...[
            if (!allowed)
              Padding(
                padding: const EdgeInsets.fromLTRB(Space.s4, 0, Space.s4, Space.s3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Symbols.notifications_off_rounded, size: IconSizes.sm, color: c.caution),
                    const SizedBox(width: Space.s2),
                    Expanded(
                      child: Text(
                        'Notifications are turned off for Kakeibo in Android settings, so '
                        'reminders show as cards on Home instead.',
                        style: context.text.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            const Divider(indent: 56),
            _TimedSwitch(
              title: 'Log my spending',
              subtitle: 'Skipped on days you’ve already logged',
              value: s.daily,
              time: time(s.dailyTime),
              onChanged: (v) => set(ReminderSettings.keyDaily, v),
              onTime: () => _pickTime(context, ref, ReminderSettings.keyDailyTime, s.dailyTime),
            ),
            _TimedSwitch(
              title: 'Anything else today?',
              subtitle: 'A late nudge for cash spends',
              value: s.evening,
              time: time(s.eveningTime),
              onChanged: (v) => set(ReminderSettings.keyEvening, v),
              onTime: () => _pickTime(context, ref, ReminderSettings.keyEveningTime, s.eveningTime),
            ),
            SwitchListTile(
              title: const Text('Weekly check-in'),
              subtitle: Text('Last day of each week, ${time(ReminderSettings.weeklyTime)}'),
              value: s.weekly,
              onChanged: (v) => set(ReminderSettings.keyWeekly, v),
            ),
            SwitchListTile(
              title: const Text('Plan and reflect'),
              subtitle: const Text('When a month starts and ends'),
              value: s.monthly,
              onChanged: (v) => set(ReminderSettings.keyMonthly, v),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(Space.s4, Space.s1, Space.s4, Space.s4),
              child: Text(
                'If reminders don’t arrive, open Android Settings → Apps → Kakeibo '
                '→ Battery and choose No restrictions.',
                style: context.text.bodySmall,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TimedSwitch extends StatelessWidget {
  const _TimedSwitch({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.time,
    required this.onChanged,
    required this.onTime,
  });

  final String title;
  final String subtitle;
  final bool value;
  final String time;
  final ValueChanged<bool> onChanged;
  final VoidCallback onTime;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Space.s4, Space.s2, Space.s2, Space.s2),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.text.bodyLarge),
                Text(subtitle, style: context.text.bodySmall),
              ],
            ),
          ),
          TextButton(
            onPressed: value ? onTime : null,
            child: Text(time, semanticsLabel: '$title at $time. Change time'),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
