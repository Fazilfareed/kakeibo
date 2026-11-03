import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../app/theme/kakeibo_colors.dart';
import '../../../app/theme/kakeibo_text.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/money/money_text.dart';
import '../../../core/pillars/pillars_provider.dart';
import 'widgets/pillar_bar.dart';

/// Home: how much is left this month (MASTER.md §8). Real numbers arrive with
/// the period and expense logic in M1–M2; for now it shows the empty state.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final now = DateTime.now();
    final pillars = ref.watch(pillarsProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(Space.gutter, Space.s3, Space.gutter, 96),
      children: [
        Text(
          '${DateFormat('d MMM').format(DateTime(now.year, now.month))} – '
          '${DateFormat('d MMM').format(DateTime(now.year, now.month + 1, 0))}',
          style: context.text.bodySmall,
        ),
        Text(DateFormat('MMMM').format(now), style: context.text.headlineSmall),
        const SizedBox(height: Space.s4),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(Space.s5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Left to spend', style: context.text.bodySmall),
                MoneyText(0, style: context.moneyText.displayMoney, hideZeroDecimals: true),
                const SizedBox(height: Space.s1),
                Text('Plan your month to see your daily allowance.',
                    style: context.text.bodySmall),
              ],
            ),
          ),
        ),
        const SizedBox(height: Space.s3),
        _ActionCard(
          icon: Symbols.target_rounded,
          accent: c.info,
          text: 'Plan your month: income, fixed costs and your savings goal.',
          actionLabel: 'Plan',
          onAction: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Month planning arrives in the next milestone.')),
          ),
        ),
        const SizedBox(height: Space.s3),
        Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(Space.s4, Space.s3, Space.s4, Space.s3),
            child: pillars.when(
              data: (list) => Column(
                children: [
                  for (final p in list)
                    PillarBar(pillarId: p.id, name: p.name, spentCents: 0, plannedCents: 0),
                ],
              ),
              loading: () => const SizedBox(height: 200),
              error: (e, _) => Text('Could not load pillars', style: context.text.bodySmall),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.accent,
    required this.text,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final Color accent;
  final String text;
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
                    Expanded(child: Text(text, style: context.text.bodyMedium)),
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
