import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../app/router.dart';
import '../../../app/theme/kakeibo_colors.dart';
import '../../../app/theme/kakeibo_text.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/db/app_database.dart';
import '../../../core/money/money_text.dart';
import '../../../core/pillars/pillars_provider.dart';
import '../../periods/data/period_providers.dart';
import '../../periods/domain/period_summary.dart';
import 'widgets/pillar_bar.dart';

/// Home: how much is left this month (MASTER.md §7.4, §8).
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(currentPeriodProvider).value;
    final summary = ref.watch(currentSummaryProvider);
    final pillars = ref.watch(pillarsProvider).value ?? const <Pillar>[];

    if (period == null || summary == null) {
      return const Center(child: SizedBox.shrink());
    }

    final fmt = DateFormat('d MMM');
    final planned = period.status != 'planning';

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
        _HeroCard(summary: summary, planned: planned),
        const SizedBox(height: Space.s3),
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
        Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(Space.s4, Space.s3, Space.s4, Space.s3),
            child: Column(
              children: [
                for (final p in pillars)
                  PillarBar(
                    pillarId: p.id,
                    name: p.name,
                    spentCents: summary.spentByPillar[p.id] ?? 0,
                    plannedCents: summary.plannedByPillar[p.id] ?? 0,
                  ),
              ],
            ),
          ),
        ),
        if (planned) ...[
          const SizedBox(height: Space.s2),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => context.push(Routes.plan),
              icon: const Icon(Symbols.edit_rounded, size: IconSizes.sm),
              label: const Text('Edit plan'),
            ),
          ),
        ],
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.summary, required this.planned});

  final PeriodSummary summary;
  final bool planned;

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
              Row(
                children: [
                  Icon(Symbols.cancel_rounded, size: IconSizes.sm, color: c.over),
                  const SizedBox(width: Space.s1),
                  Expanded(
                    child: Text("That's okay. It comes out of your savings this month.",
                        style: context.text.bodySmall),
                  ),
                ],
              )
            else
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  MoneyText(summary.dailyAllowance,
                      style: context.text.bodySmall?.copyWith(color: c.ink), hideZeroDecimals: true),
                  Text(' a day keeps you on track', style: context.text.bodySmall),
                ],
              ),
            if (planned) ...[
              const SizedBox(height: Space.s4),
              const Divider(),
              const SizedBox(height: Space.s3),
              Row(
                children: [
                  Expanded(child: _Stat(label: 'Spent', cents: summary.spent)),
                  Expanded(child: _Stat(label: 'Spendable', cents: summary.spendable)),
                  Expanded(child: _Stat(label: 'Saving', cents: summary.savingsGoal)),
                ],
              ),
            ],
          ],
        ),
      ),
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
      onAction: () =>
          ref.read(periodRepositoryProvider).setSavingsSetAside(periodId, true),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.accent,
    this.text,
    this.textWidget,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final Color accent;
  final String? text;
  final Widget? textWidget;
  final String actionLabel;
  final VoidCallback onAction;

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
                padding: const EdgeInsets.fromLTRB(Space.s3, Space.s2, Space.s2, Space.s2),
                child: Row(
                  children: [
                    ExcludeSemantics(child: Icon(icon, color: c.ink2)),
                    const SizedBox(width: Space.s3),
                    Expanded(child: textWidget ?? Text(text ?? '', style: context.text.bodyMedium)),
                    TextButton(onPressed: onAction, child: Text(actionLabel)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
