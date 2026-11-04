import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../app/router.dart';
import '../../../app/theme/kakeibo_colors.dart';
import '../../../app/theme/kakeibo_text.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/date/local_date.dart';
import '../../../core/db/app_database.dart';
import '../../../core/money/money_text.dart';
import '../../../core/pillars/pillars_provider.dart';
import '../../backup/data/auto_backup.dart';
import '../../backup/presentation/backup_actions.dart';
import '../../checkin/data/checkin_providers.dart';
import '../../expenses/data/expense_providers.dart';
import '../../expenses/presentation/expense_tile.dart';
import '../../history/data/history_providers.dart';
import '../../periods/data/period_providers.dart';
import '../../periods/domain/period_summary.dart';
import '../../reflection/data/reflection_providers.dart';
import '../../settings/data/settings_repository.dart';
import '../../settings/domain/app_preferences.dart';
import '../../transactions/presentation/transactions_screen.dart';
import 'widgets/pillar_bar.dart';
import 'widgets/savings_ring.dart';

/// Settings key holding the id of the last month whose reflection was opened
/// automatically, so it opens on its own only once (FR-50).
const reflectionPromptedKey = 'reflection_prompted_period';

/// Also remembered in memory, since the setting is written asynchronously.
final _autoOpened = <int>{};

/// Home: how much is left this month (MASTER.md §7.4, §8; PRD FR-30–37).
/// Order: hero card → action cards → pillar bars → recent 5.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  /// FR-50: when a month has ended, its reflection opens once by itself.
  /// After that it waits as a card; logging is never blocked.
  void _autoOpenReflection(BuildContext context, WidgetRef ref, Period? pending) {
    final settings = ref.read(settingsProvider).value;
    if (pending == null || settings == null) return;
    if (settings[reflectionPromptedKey] == '${pending.id}' || _autoOpened.contains(pending.id)) {
      return;
    }
    _autoOpened.add(pending.id);
    ref.read(settingsRepositoryProvider).set(reflectionPromptedKey, '${pending.id}');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) context.push(Routes.reflect(pending.id));
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(currentPeriodProvider).value;
    final summary = ref.watch(currentSummaryProvider);
    final pillars = ref.watch(pillarsProvider).value ?? const <Pillar>[];

    if (period == null || summary == null) return const _Skeleton();

    final improvement = ref.watch(currentImprovementProvider).value;
    final settings = ref.watch(settingsProvider).value ?? const <String, String>{};
    final months = ref.watch(historyMonthsProvider).value;
    final firstUse = months == null || months.isEmpty
        ? null
        : LocalDate.parse(months.last.period.startDate);
    final lastBackup = AutoBackup.lastBackup(settings);
    final backupStale = AutoBackup.isStale(settings, DateTime.now(), firstUse: firstUse);
    final pending = ref.watch(pendingReflectionProvider).value;
    ref.watch(settingsProvider);
    _autoOpenReflection(context, ref, pending);
    final week = ref.watch(currentWeekProvider);
    final checkin = ref.watch(currentCheckinProvider);
    final checkedIn = checkin.value != null;
    // FR-83 stand-in until reminders arrive (M5): nudge on the week's last 2 days.
    final checkinDue =
        checkin.hasValue &&
        !checkedIn &&
        week != null &&
        LocalDate.daysBetween(LocalDate.dateOnly(summary.today), week.end) <= 1;
    final expenses = ref.watch(periodExpensesProvider(period.id)).value ?? const <Expense>[];
    final fmt = DateFormat('d MMM');
    final planned = period.status != 'planning';

    void openPillar(int? pillarId) {
      ref.read(spendsFilterProvider.notifier).set(pillarId);
      context.go(Routes.transactions);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(Space.gutter, Space.s3, Space.gutter, 96),
      children: [
        Text(
          '${fmt.format(summary.range.start)} – ${fmt.format(summary.range.end)}'
          ' · ${summary.daysLeft} ${summary.daysLeft == 1 ? 'day' : 'days'} left',
          style: context.text.bodySmall,
        ),
        Text(DateFormat('MMMM').format(summary.range.start), style: context.text.headlineSmall),
        const SizedBox(height: Space.s4),
        _HeroCard(summary: summary, planned: planned, savingsSetAside: period.savingsSetAside),
        const SizedBox(height: Space.s3),
        if (pending != null) ...[
          _ActionCard(
            icon: Symbols.auto_stories_rounded,
            accent: context.colors.seal,
            text:
                '${DateFormat('MMMM').format(LocalDate.parse(pending.startDate))} has ended. '
                'Take five quiet minutes to reflect.',
            actionLabel: 'Reflect',
            onAction: () => context.push(Routes.reflect(pending.id)),
          ),
          const SizedBox(height: Space.s3),
        ],
        if (backupStale) ...[
          _ActionCard(
            icon: Symbols.backup_rounded,
            accent: context.colors.caution,
            text: lastBackup == null
                ? 'Back up your data. If this phone is lost, a backup file is the only copy.'
                : 'Back up your data. The last backup was '
                      '${DateTime.now().difference(lastBackup).inDays} days ago.',
            actionLabel: 'Back up',
            onAction: () => BackupActions.backUp(context, ref),
          ),
          const SizedBox(height: Space.s3),
        ],
        if (!planned) ...[
          _ActionCard(
            icon: Symbols.target_rounded,
            accent: context.colors.info,
            text: 'Plan your month: income, fixed costs and your savings goal.',
            actionLabel: 'Plan',
            onAction: () => context.push(Routes.plan),
          ),
          const SizedBox(height: Space.s3),
        ] else if (summary.savingsGoal > 0 && !period.savingsSetAside) ...[
          _SaveFirstCard(periodId: period.id, goal: summary.savingsGoal),
          const SizedBox(height: Space.s3),
        ],
        if (checkinDue) ...[
          _ActionCard(
            icon: Symbols.event_available_rounded,
            accent: context.colors.info,
            text: 'Weekly check-in: how did this week go?',
            actionLabel: 'Check in',
            onAction: () => context.push(Routes.checkin),
          ),
          const SizedBox(height: Space.s3),
        ],
        if (improvement != null) ...[
          _ActionCard(
            icon: Symbols.flag_rounded,
            accent: context.colors.culture,
            textWidget: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('This month I will', style: context.text.bodySmall),
                Text(improvement, style: context.text.bodyMedium),
              ],
            ),
          ),
          const SizedBox(height: Space.s3),
        ],
        Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(Space.s3, Space.s2, Space.s3, Space.s2),
            child: Column(
              children: [
                for (final p in pillars)
                  PillarBar(
                    pillarId: p.id,
                    name: p.name,
                    spentCents: summary.spentByPillar[p.id] ?? 0,
                    plannedCents: summary.plannedByPillar[p.id] ?? 0,
                    onTap: () => openPillar(p.id),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: Space.s3),
        _RecentCard(expenses: expenses, pillars: pillars, onSeeAll: () => openPillar(null)),
        const SizedBox(height: Space.s2),
        Wrap(
          alignment: WrapAlignment.end,
          spacing: Space.s2,
          children: [
            TextButton.icon(
              onPressed: () => context.push(Routes.checkin),
              icon: Icon(
                checkedIn ? Symbols.check_circle_rounded : Symbols.event_available_rounded,
                size: IconSizes.sm,
              ),
              label: Text(checkedIn ? 'Checked in this week' : 'Weekly check-in'),
            ),
            if (planned)
              TextButton.icon(
                onPressed: () => context.push(Routes.plan),
                icon: const Icon(Symbols.edit_rounded, size: IconSizes.sm),
                label: const Text('Edit plan'),
              ),
          ],
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.summary, required this.planned, required this.savingsSetAside});

  final PeriodSummary summary;
  final bool planned;
  final bool savingsSetAside;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final over = summary.overspend > 0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Space.s5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(over ? 'Over this month' : 'Left to spend', style: context.text.bodySmall),
            MoneyText(
              over ? summary.overspend : summary.remaining,
              style: context.moneyText.displayMoney.copyWith(color: over ? c.over : null),
              hideZeroDecimals: true,
            ),
            const SizedBox(height: Space.s1),
            if (!planned)
              Text('Plan your month to see your daily allowance.', style: context.text.bodySmall)
            else if (over)
              // FR-35: honest about the cost, never shaming.
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(Symbols.cancel_rounded, size: IconSizes.sm, color: c.over),
                  ),
                  const SizedBox(width: Space.s1),
                  Expanded(
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          "That's okay. It brings your savings to ",
                          style: context.text.bodySmall,
                        ),
                        MoneyText(
                          summary.actualSavings,
                          style: context.text.bodySmall?.copyWith(color: c.ink),
                          hideZeroDecimals: true,
                        ),
                        Text(' this month.', style: context.text.bodySmall),
                      ],
                    ),
                  ),
                ],
              )
            else
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  MoneyText(
                    summary.dailyAllowance,
                    style: context.text.bodySmall?.copyWith(color: c.ink),
                    hideZeroDecimals: true,
                  ),
                  Text(' a day keeps you on track', style: context.text.bodySmall),
                ],
              ),
            if (planned) ...[
              const SizedBox(height: Space.s4),
              const Divider(),
              const SizedBox(height: Space.s4),
              if (summary.savingsGoal > 0) ...[
                _SavingsRow(summary: summary, stamped: savingsSetAside && !over),
                const SizedBox(height: Space.s4),
              ],
              Row(
                children: [
                  Expanded(
                    child: _Stat(label: 'Spent', cents: summary.spent),
                  ),
                  Expanded(
                    child: _Stat(label: 'Spendable', cents: summary.spendable),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// FR-31: savings goal with the projected end-of-month savings.
class _SavingsRow extends ConsumerWidget {
  const _SavingsRow({required this.summary, required this.stamped});

  final PeriodSummary summary;
  final bool stamped;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final money = ref.watch(moneyFormatterProvider);
    final pct = (summary.savingsProgress * 100).round();
    final onGoal = summary.projectedSavings >= summary.savingsGoal;

    final (String lead, int? amount, String tail) = switch (summary) {
      _ when summary.overspend > 0 => ('Savings now ', summary.actualSavings, '.'),
      _ when !summary.hasProjection => ('A projection appears from day 4.', null, ''),
      _ => ('At this pace you save ', summary.projectedSavings, onGoal ? ', on goal.' : '.'),
    };
    final caption = amount == null
        ? lead
        : '$lead${money.formatCents(amount, hideZeroDecimals: true)}$tail';

    return Row(
      children: [
        SavingsRing(
          value: summary.savingsProgress,
          stamped: stamped,
          semanticsLabel:
              'Savings goal ${money.semanticLabel(summary.savingsGoal)}, $pct percent. '
              '${amount == null ? lead : '$lead${money.semanticLabel(amount)}$tail'}',
        ),
        const SizedBox(width: Space.s5),
        Expanded(
          child: ExcludeSemantics(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Savings goal', style: context.text.bodySmall),
                MoneyText(
                  summary.savingsGoal,
                  style: context.text.titleLarge,
                  hideZeroDecimals: true,
                ),
                const SizedBox(height: Space.s1),
                Text(
                  caption,
                  style: context.text.bodySmall?.copyWith(
                    color: summary.overspend > 0 ? c.over : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.cents});

  final String label;
  final int cents;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: context.text.bodySmall),
        MoneyText(cents, style: context.text.titleMedium, hideZeroDecimals: true),
      ],
    );
  }
}

/// FR-33: today's total and the last 5 spends.
class _RecentCard extends StatelessWidget {
  const _RecentCard({required this.expenses, required this.pillars, required this.onSeeAll});

  final List<Expense> expenses;
  final List<Pillar> pillars;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final today = LocalDate.today();
    final todays = expenses.where((e) => e.date == today).toList();
    final todayTotal = todays.fold(0, (a, e) => a + (e.type == 'refund' ? -e.amount : e.amount));
    final recent = expenses.take(5).toList();

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(Space.s4, Space.s2, Space.s1, 0),
            child: Row(
              children: [
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text('Recent', style: context.text.titleMedium),
                  ),
                ),
                if (expenses.isNotEmpty)
                  TextButton(onPressed: onSeeAll, child: const Text('See all')),
              ],
            ),
          ),
          if (recent.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(Space.s4, Space.s2, Space.s4, Space.s4),
              child: Text('Tap + to log your first expense.', style: context.text.bodySmall),
            )
          else ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(Space.s4, 0, Space.s4, Space.s1),
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text('Today ', style: context.text.bodySmall),
                  MoneyText(todayTotal, style: context.text.bodySmall),
                  Text(
                    ' · ${todays.length} ${todays.length == 1 ? 'entry' : 'entries'}',
                    style: context.text.bodySmall,
                  ),
                ],
              ),
            ),
            for (final (i, e) in recent.indexed) ...[
              if (i > 0) const Divider(indent: 68),
              ExpenseTile(
                key: ValueKey(e.id),
                expense: e,
                pillarName: pillars.where((p) => p.id == e.pillarId).firstOrNull?.name ?? '',
              ),
            ],
          ],
        ],
      ),
    );
  }
}

/// FR-18: Kakeibo's "save first" nudge.
class _SaveFirstCard extends ConsumerWidget {
  const _SaveFirstCard({required this.periodId, required this.goal});

  final int periodId;
  final int goal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    return _ActionCard(
      icon: Symbols.savings_rounded,
      accent: c.success,
      textWidget: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text('Save first: put ', style: context.text.bodyMedium),
          MoneyText(goal, style: context.text.bodyMedium, hideZeroDecimals: true),
          Text(' aside before you spend.', style: context.text.bodyMedium),
        ],
      ),
      actionLabel: 'Done',
      onAction: () => ref.read(periodRepositoryProvider).setSavingsSetAside(periodId, true),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.accent,
    this.text,
    this.textWidget,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final Color accent;
  final String? text;
  final Widget? textWidget;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    // Rounded borders must be one colour, so the accent is a separate strip.
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(Radii.md),
        border: Border.all(color: c.divider),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ColoredBox(color: accent, child: const SizedBox(width: 4)),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  Space.s3,
                  Space.s2,
                  actionLabel == null ? Space.s4 : Space.s2,
                  Space.s2,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 48),
                  child: Row(
                    children: [
                      ExcludeSemantics(child: Icon(icon, color: c.ink2)),
                      const SizedBox(width: Space.s3),
                      Expanded(
                        child: textWidget ?? Text(text ?? '', style: context.text.bodyMedium),
                      ),
                      if (actionLabel != null)
                        TextButton(onPressed: onAction, child: Text(actionLabel!)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shown for the moment before the first data arrives (MASTER.md §6: a
/// skeleton in `surfaceSunken`, never a spinner).
class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) {
    final sunken = context.colors.surfaceSunken;
    Widget block(double height, {double? width}) => Container(
      height: height,
      width: width,
      decoration: BoxDecoration(color: sunken, borderRadius: BorderRadius.circular(Radii.md)),
    );
    return ExcludeSemantics(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Space.gutter, Space.s3, Space.gutter, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            block(14, width: 160),
            const SizedBox(height: Space.s2),
            block(28, width: 120),
            const SizedBox(height: Space.s4),
            block(260),
            const SizedBox(height: Space.s3),
            block(220),
          ],
        ),
      ),
    );
  }
}
