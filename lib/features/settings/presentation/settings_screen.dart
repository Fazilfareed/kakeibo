import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../app/router.dart';
import '../../../app/theme/kakeibo_colors.dart';
import '../../../app/theme/kakeibo_text.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/dev/sample_month.dart';
import '../../../core/db/database_provider.dart';
import '../../backup/data/auto_backup.dart';
import '../../backup/presentation/backup_actions.dart';
import '../../checkin/data/checkin_providers.dart';
import '../../guide/domain/guide_state.dart';
import '../../guide/presentation/coach_marks.dart';
import '../../periods/data/period_providers.dart';
import '../../lock/presentation/security_settings_card.dart';
import '../../reminders/presentation/reminder_settings_card.dart';
import '../data/settings_repository.dart';
import '../domain/app_preferences.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final themeMode = ref.watch(themeModeProvider);
    final formatter = ref.watch(moneyFormatterProvider);
    final weekStart = ref.watch(weekStartDayProvider);
    final all = ref.watch(settingsProvider).value ?? const <String, String>{};
    final lastBackup = all[lastBackupKey];
    final autoOn = all[AutoBackup.keyEnabled] == 'true' && all[AutoBackup.keyFolderUri] != null;
    final autoError = (all[AutoBackup.keyError] ?? '').isNotEmpty;

    return ListView(
      padding: const EdgeInsets.fromLTRB(Space.gutter, Space.s3, Space.gutter, 96),
      children: [
        Text('Settings', style: context.text.headlineSmall),
        const SizedBox(height: Space.s5),
        const _SectionLabel('Money'),
        Card(
          child: ListTile(
            leading: const Icon(Symbols.payments_rounded),
            title: const Text('Currency format'),
            subtitle: Text('Sri Lankan Rupee · ${formatter.formatCents(1250000)}'),
            trailing: Icon(Symbols.chevron_right_rounded, color: c.ink3),
            onTap: () => context.push(Routes.currencyFormat),
          ),
        ),
        const SizedBox(height: Space.s5),
        const _SectionLabel('Routine'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(Space.s4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Month starts on', style: context.text.titleMedium),
                          Text(
                            all['pending_month_start_day'] != null
                                ? 'Day ${all['pending_month_start_day']} from next month'
                                : 'Your salary day, if you have one',
                            style: context.text.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    DropdownButton<int>(
                      value: int.tryParse(all['month_start_day'] ?? '') ?? 1,
                      underline: const SizedBox.shrink(),
                      items: [
                        for (var d = 1; d <= 28; d++)
                          DropdownMenuItem(value: d, child: Text('Day $d')),
                      ],
                      onChanged: (d) async {
                        if (d == null) return;
                        final messenger = ScaffoldMessenger.of(context);
                        final now = await ref.read(periodRepositoryProvider).setMonthStartDay(d);
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              now
                                  ? 'This month now starts on day $d.'
                                  : 'From next month, months start on day $d.',
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const Divider(height: Space.s6),
                Text('Week starts on', style: context.text.titleMedium),
                const SizedBox(height: Space.s1),
                Text('Used for the weekly check-in.', style: context.text.bodySmall),
                const SizedBox(height: Space.s3),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<int>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(value: DateTime.monday, label: Text('Monday')),
                      ButtonSegment(value: DateTime.saturday, label: Text('Saturday')),
                      ButtonSegment(value: DateTime.sunday, label: Text('Sunday')),
                    ],
                    selected: {weekStart},
                    onSelectionChanged: (s) =>
                        ref.read(settingsRepositoryProvider).set('week_start_day', '${s.first}'),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: Space.s5),
        const _SectionLabel('Reminders'),
        const ReminderSettingsCard(),
        const SizedBox(height: Space.s5),
        const _SectionLabel('Security'),
        const SecuritySettingsCard(),
        const SizedBox(height: Space.s5),
        const _SectionLabel('Appearance'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(Space.s4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Theme', style: context.text.titleMedium),
                const SizedBox(height: Space.s3),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<ThemeMode>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(value: ThemeMode.system, label: Text('System')),
                      ButtonSegment(value: ThemeMode.light, label: Text('Light')),
                      ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
                    ],
                    selected: {themeMode},
                    onSelectionChanged: (s) =>
                        ref.read(settingsRepositoryProvider).set(themeKey, s.first.name),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: Space.s5),
        const _SectionLabel('Data'),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                secondary: const Icon(Symbols.event_repeat_rounded),
                title: const Text('Automatic weekly backup'),
                subtitle: Text(
                  !autoOn
                      ? 'Off'
                      : autoError
                      ? "Couldn't reach ${all[AutoBackup.keyFolderName]}. Choose the folder again."
                      : 'To ${all[AutoBackup.keyFolderName]} · keeps the last ${AutoBackup.keep}',
                  style: autoError ? TextStyle(color: c.over) : null,
                ),
                value: autoOn,
                onChanged: (v) => v
                    ? BackupActions.chooseAutoBackupFolder(context, ref)
                    : BackupActions.turnOffAutoBackup(ref),
              ),
              if (autoOn) ...[
                const Divider(indent: 56),
                ListTile(
                  leading: const Icon(Symbols.folder_open_rounded),
                  title: const Text('Change backup folder'),
                  onTap: () => BackupActions.chooseAutoBackupFolder(context, ref),
                ),
              ],
              const Divider(indent: 56),
              ListTile(
                leading: const Icon(Symbols.backup_rounded),
                title: const Text('Back up now'),
                subtitle: Text(BackupActions.lastBackupLabel(lastBackup)),
                onTap: () => BackupActions.backUp(context, ref),
              ),
              const Divider(indent: 56),
              ListTile(
                leading: const Icon(Symbols.settings_backup_restore_rounded),
                title: const Text('Restore from a backup'),
                subtitle: const Text('Replaces the data on this phone'),
                onTap: () => BackupActions.restore(context, ref),
              ),
              const Divider(indent: 56),
              ListTile(
                leading: const Icon(Symbols.table_view_rounded),
                title: const Text('Export spends'),
                subtitle: const Text('A CSV file for spreadsheets'),
                onTap: () => BackupActions.exportCsv(context, ref),
              ),
              const Divider(indent: 56),
              ListTile(
                leading: Icon(Symbols.delete_forever_rounded, color: c.over),
                title: Text('Delete all data', style: TextStyle(color: c.over)),
                onTap: () => BackupActions.deleteAll(context, ref),
              ),
            ],
          ),
        ),
        if (kDebugMode) ...[
          const SizedBox(height: Space.s5),
          const _SectionLabel('Developer (debug builds only)'),
          Card(
            child: ListTile(
              leading: const Icon(Symbols.science_rounded),
              title: const Text('Add a sample past month'),
              subtitle: const Text('Creates a closed month with spends, to try the reflection.'),
              onTap: () async {
                final messenger = ScaffoldMessenger.of(context);
                final added = await SampleMonth.add(ref.read(appDatabaseProvider));
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(added ? 'Sample month added.' : 'A sample month already exists.'),
                  ),
                );
              },
            ),
          ),
        ],
        const SizedBox(height: Space.s5),
        const _SectionLabel('Help'),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Symbols.help_rounded),
                title: const Text('Help Center'),
                subtitle: const Text('Kakeibo basics, how-tos and questions'),
                trailing: Icon(Symbols.chevron_right_rounded, color: c.ink3),
                onTap: () => context.push(Routes.help),
              ),
              const Divider(indent: 56),
              ListTile(
                leading: const Icon(Symbols.replay_rounded),
                title: const Text('Replay guide'),
                subtitle: const Text('The welcome tour and screen tips again'),
                onTap: () async {
                  await ref.read(settingsRepositoryProvider).setAll(all.guideReset);
                  CoachMarks.reset();
                  if (context.mounted) context.push(Routes.replayGuide);
                },
              ),
              const Divider(indent: 56),
              SwitchListTile(
                secondary: const Icon(Symbols.lightbulb_rounded),
                title: const Text('Tip of the day on Home'),
                value: all.tipsOn,
                onChanged: (v) =>
                    ref.read(settingsRepositoryProvider).set(GuideKeys.tipsEnabled, '$v'),
              ),
              const Divider(indent: 56),
              ListTile(
                leading: const Icon(Symbols.bug_report_rounded),
                title: const Text('Export diagnostics'),
                subtitle: const Text(
                  'Errors logged on this phone, to share if something goes wrong',
                ),
                onTap: () => BackupActions.exportDiagnostics(context),
              ),
            ],
          ),
        ),
        const SizedBox(height: Space.s5),
        const _SectionLabel('About'),
        const Card(
          child: ListTile(
            leading: Icon(Symbols.info_rounded),
            title: Text('Kakeibo'),
            subtitle: Text('Version 1.0.0 · Your data stays on this phone.'),
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: Space.s1, bottom: Space.s2),
      child: Semantics(
        header: true,
        child: Text(
          text.toUpperCase(),
          style: context.text.labelSmall?.copyWith(letterSpacing: 1.2),
        ),
      ),
    );
  }
}
