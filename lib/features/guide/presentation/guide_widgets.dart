import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../app/router.dart';
import '../../../app/theme/kakeibo_colors.dart';
import '../../../app/theme/kakeibo_text.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/db/database_provider.dart';
import '../../backup/data/backup_repository.dart';
import '../../backup/presentation/backup_actions.dart';
import '../../expenses/presentation/quick_add_sheet.dart';
import '../../history/data/history_providers.dart';
import '../../reminders/domain/reminder_planner.dart';
import '../../settings/data/settings_repository.dart';
import '../../stats/data/stats_providers.dart';
import '../domain/guide_content.dart';
import '../domain/guide_state.dart';

/// Whether any weekly check-in was ever saved (for the checklist).
final anyCheckinProvider = StreamProvider<bool>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final q = db.selectOnly(db.weeklyCheckins)
    ..addColumns([db.weeklyCheckins.id])
    ..limit(1);
  return q.watch().map((rows) => rows.isNotEmpty);
});

/// FR-97 checklist, or null while loading.
final checklistProvider = Provider<Checklist?>((ref) {
  final settings = ref.watch(settingsProvider).value;
  final months = ref.watch(historyMonthsProvider).value;
  final dates = ref.watch(spendDatesProvider).value;
  final checkin = ref.watch(anyCheckinProvider).value;
  if (settings == null || months == null || dates == null || checkin == null) return null;
  return Checklist(
    planned: months.any((m) => m.period.status != 'planning'),
    logged: dates.isNotEmpty,
    reminders: settings[ReminderSettings.keyOn] == 'true',
    checkedIn: checkin,
    backedUp: (settings[BackupRepository.lastBackupKey] ?? '').isNotEmpty,
  );
});

/// FR-100: a "(?)" button that opens a plain-words explanation.
class InfoButton extends StatelessWidget {
  const InfoButton({super.key, required this.info});

  final InfoText info;

  static Future<void> show(BuildContext context, InfoText info) => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(Space.gutter, 0, Space.gutter, Space.s6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(header: true, child: Text(info.title, style: context.text.titleLarge)),
            const SizedBox(height: Space.s3),
            Text(info.body, style: context.text.bodyLarge),
          ],
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'What is ${info.title.toLowerCase()}?',
      visualDensity: VisualDensity.compact,
      iconSize: IconSizes.sm,
      icon: Icon(Symbols.help_rounded, color: context.colors.ink3),
      onPressed: () => show(context, info),
    );
  }
}

/// FR-97: the "Getting started" card on Home until it's done and dismissed.
class GettingStartedCard extends ConsumerWidget {
  const GettingStartedCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final list = ref.watch(checklistProvider);
    final settings = ref.watch(settingsProvider).value ?? const <String, String>{};
    if (list == null || settings.checklistDismissed) return const SizedBox.shrink();

    final items = <(bool, String, VoidCallback)>[
      (list.planned, 'Plan your month', () => context.push(Routes.plan)),
      (list.logged, 'Log your first expense', () => showQuickAddSheet(context)),
      (list.reminders, 'Turn on reminders', () => context.go(Routes.settings)),
      (list.checkedIn, 'Do a weekly check-in', () => context.push(Routes.checkin)),
      (list.backedUp, 'Make a backup', () => BackupActions.backUp(context, ref)),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Space.s4, Space.s3, Space.s2, Space.s2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text('Getting started', style: context.text.titleMedium),
                  ),
                ),
                Text('${list.done} of ${list.items.length}', style: context.text.bodySmall),
                const SizedBox(width: Space.s2),
              ],
            ),
            const SizedBox(height: Space.s1),
            for (final (done, label, action) in items)
              InkWell(
                onTap: done ? null : action,
                borderRadius: BorderRadius.circular(Radii.sm),
                child: Semantics(
                  label: '$label, ${done ? 'done' : 'not done yet'}',
                  button: !done,
                  excludeSemantics: true,
                  onTap: done ? null : action,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 48),
                    child: Row(
                      children: [
                        Icon(
                          done
                              ? Symbols.check_circle_rounded
                              : Symbols.radio_button_unchecked_rounded,
                          fill: done ? 1 : 0,
                          color: done ? c.success : c.ink3,
                          size: 22,
                        ),
                        const SizedBox(width: Space.s3),
                        Expanded(
                          child: Text(
                            label,
                            style: context.text.bodyLarge?.copyWith(
                              color: done ? c.ink3 : null,
                              decoration: done ? TextDecoration.lineThrough : null,
                            ),
                          ),
                        ),
                        if (!done) Icon(Symbols.chevron_right_rounded, color: c.ink3),
                      ],
                    ),
                  ),
                ),
              ),
            if (list.complete)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => ref
                      .read(settingsRepositoryProvider)
                      .set(GuideKeys.checklistDismissed, 'true'),
                  child: const Text('All done, hide this'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// FR-101: a gentle tip of the day; can be turned off.
class TipCard extends ConsumerWidget {
  const TipCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final settings = ref.watch(settingsProvider).value ?? const <String, String>{};
    if (!settings.tipsOn) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.fromLTRB(Space.s4, Space.s3, Space.s1, Space.s1),
      decoration: BoxDecoration(
        color: c.surfaceSunken,
        borderRadius: BorderRadius.circular(Radii.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(Symbols.lightbulb_rounded, size: IconSizes.sm, color: c.ink2),
              ),
              const SizedBox(width: Space.s2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Kakeibo tip', style: context.text.labelLarge),
                    const SizedBox(height: Space.s1),
                    Text(GuideContent.tipFor(DateTime.now()), style: context.text.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () =>
                  ref.read(settingsRepositoryProvider).set(GuideKeys.tipsEnabled, 'false'),
              child: const Text('Hide tips'),
            ),
          ),
        ],
      ),
    );
  }
}
