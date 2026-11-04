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
import '../../../core/widgets/empty_state.dart';
import '../../settings/domain/app_preferences.dart';
import '../data/history_providers.dart';
import '../data/history_repository.dart';
import 'widgets/history_charts.dart';

/// Past months and trends (PRD §6.7, S9): lifetime savings, the savings
/// trend, spend per pillar, then one card per finished month.
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final months = ref.watch(historyMonthsProvider).value;
    final pillars = ref.watch(pillarsProvider).value ?? const <Pillar>[];
    final closed = months?.where((m) => m.isClosed).toList() ?? const <MonthRecord>[];

    return ListView(
      padding: const EdgeInsets.fromLTRB(Space.gutter, Space.s3, Space.gutter, 96),
      children: [
        Text('History', style: context.text.headlineSmall),
        if (months == null)
          const SizedBox.shrink()
        else if (closed.isEmpty) ...[
          const SizedBox(height: Space.s7),
          const EmptyState(
            icon: Symbols.trending_up_rounded,
            title: 'No months yet',
            message: 'Your first month review will appear here.',
          ),
        ] else ...[
          const SizedBox(height: Space.s4),
          _LifetimeCard(closed: closed),
          if (closed.length >= 2) ...[
            const SizedBox(height: Space.s3),
            _ChartCard(
              title: 'Savings by month',
              child: SavingsTrendChart(months: closed.take(12).toList().reversed.toList()),
            ),
          ],
          const SizedBox(height: Space.s3),
          _ChartCard(
            title: 'Spending by pillar',
            subtitle: 'Tap a bar for the amount.',
            child: PillarMonthsChart(
              months: months.take(6).toList().reversed.toList(),
              pillars: pillars,
            ),
          ),
          const SizedBox(height: Space.s5),
          Semantics(header: true, child: Text('Months', style: context.text.titleLarge)),
          const SizedBox(height: Space.s2),
          for (final m in closed) ...[_MonthCard(month: m), const SizedBox(height: Space.s2)],
        ],
      ],
    );
  }
}

/// FR-63: lifetime savings.
class _LifetimeCard extends StatelessWidget {
  const _LifetimeCard({required this.closed});

  final List<MonthRecord> closed;

  @override
  Widget build(BuildContext context) {
    final met = closed.where((m) => m.goalMet).length;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Space.s5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Saved so far', style: context.text.bodySmall),
            MoneyText(
              lifetimeSavings(closed),
              style: context.moneyText.displayMoney,
              hideZeroDecimals: true,
            ),
            const SizedBox(height: Space.s1),
            Text(
              '${closed.length} ${closed.length == 1 ? 'month' : 'months'} · '
              'goal met in $met of ${closed.length}',
              style: context.text.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.title, required this.child, this.subtitle});

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Space.s4, Space.s4, Space.s4, Space.s3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: context.text.titleMedium),
            if (subtitle != null) Text(subtitle!, style: context.text.bodySmall),
            const SizedBox(height: Space.s4),
            child,
          ],
        ),
      ),
    );
  }
}

/// FR-60: one finished month.
class _MonthCard extends ConsumerWidget {
  const _MonthCard({required this.month});

  final MonthRecord month;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final money = ref.watch(moneyFormatterProvider);
    final start = LocalDate.parse(month.period.startDate);
    final title = DateFormat('MMMM yyyy').format(start);
    final (IconData icon, Color color, String status) = month.savingsGoal <= 0
        ? (Symbols.remove_rounded, c.ink3, 'No goal set')
        : month.goalMet
        ? (Symbols.check_circle_rounded, c.success, 'Goal met')
        : (
            Symbols.do_not_disturb_on_rounded,
            c.caution,
            '${money.formatCents(month.savingsGoal - month.savedAmount, hideZeroDecimals: true)} '
                'short',
          );

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(Routes.month(month.period.id)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Space.s4, Space.s3, Space.s3, Space.s3),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: context.text.titleMedium),
                    const SizedBox(height: Space.s1),
                    Wrap(
                      spacing: Space.s3,
                      runSpacing: Space.s1,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(icon, size: IconSizes.sm, color: color, fill: 1),
                            const SizedBox(width: Space.s1),
                            Flexible(
                              child: Text(
                                status,
                                style: context.text.bodySmall?.copyWith(color: color),
                              ),
                            ),
                          ],
                        ),
                        if (!month.reflectionDone)
                          Text('Reflection waiting', style: context.text.bodySmall),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Saved', style: context.text.bodySmall),
                  MoneyText(
                    month.savedAmount,
                    style: context.text.titleMedium,
                    hideZeroDecimals: true,
                  ),
                ],
              ),
              const SizedBox(width: Space.s1),
              Icon(Symbols.chevron_right_rounded, color: c.ink3),
            ],
          ),
        ),
      ),
    );
  }
}
