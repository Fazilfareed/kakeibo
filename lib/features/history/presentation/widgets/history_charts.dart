import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/kakeibo_colors.dart';
import '../../../../app/theme/kakeibo_text.dart';
import '../../../../app/theme/tokens.dart';
import '../../../../core/date/local_date.dart';
import '../../../../core/db/app_database.dart';
import '../../../../core/pillars/pillar_style.dart';
import '../../../settings/domain/app_preferences.dart';
import '../../data/history_repository.dart';

String _monthLabel(MonthRecord m) => DateFormat('MMM').format(LocalDate.parse(m.period.startDate));

/// FR-62: what each month saved, oldest to newest, as one 2 dp line with
/// 8 dp markers on a zero baseline. Single series, so no legend.
class SavingsTrendChart extends ConsumerStatefulWidget {
  const SavingsTrendChart({super.key, required this.months});

  /// Closed months, oldest first (at most 12).
  final List<MonthRecord> months;

  @override
  ConsumerState<SavingsTrendChart> createState() => _SavingsTrendChartState();
}

class _SavingsTrendChartState extends ConsumerState<SavingsTrendChart> {
  /// The tapped month; its tooltip stays until another tap.
  int? _selected;

  @override
  Widget build(BuildContext context) {
    final months = widget.months;
    final c = context.colors;
    final money = ref.watch(moneyFormatterProvider);
    final values = [for (final m in months) m.savedAmount / 100];
    final top = values.fold<double>(0, math.max);
    final bottom = values.fold<double>(0, math.min);
    final pad = math.max((top - bottom) * 0.15, 1);
    final description = [
      for (final m in months) '${_monthLabel(m)} ${money.semanticLabel(m.savedAmount)}',
    ].join(', ');
    final line = LineChartBarData(
      spots: [for (final (i, v) in values.indexed) FlSpot(i.toDouble(), v)],
      color: c.success,
      barWidth: 2,
      dotData: FlDotData(
        getDotPainter: (spot, _, _, _) =>
            FlDotCirclePainter(radius: 4, color: c.success, strokeWidth: 2, strokeColor: c.surface),
      ),
    );
    final selected = _selected != null && _selected! < months.length ? _selected : null;

    return Semantics(
      label: 'Savings by month: $description',
      excludeSemantics: true,
      child: SizedBox(
        height: 180,
        child: LineChart(
          LineChartData(
            minY: bottom - (bottom < 0 ? pad : 0),
            maxY: top + pad,
            minX: 0,
            maxX: math.max(1, months.length - 1).toDouble(),
            gridData: FlGridData(
              drawVerticalLine: false,
              getDrawingHorizontalLine: (_) => FlLine(color: c.divider, strokeWidth: 1),
            ),
            borderData: FlBorderData(show: false),
            extraLinesData: ExtraLinesData(
              horizontalLines: [HorizontalLine(y: 0, color: c.ink3, strokeWidth: 1)],
            ),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(),
              rightTitles: const AxisTitles(),
              leftTitles: const AxisTitles(),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  reservedSize: 24,
                  getTitlesWidget: (x, meta) {
                    final i = x.round();
                    if (i < 0 || i >= months.length || x != i) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: Space.s1),
                      child: Text(_monthLabel(months[i]), style: context.text.labelSmall),
                    );
                  },
                ),
              ),
            ),
            showingTooltipIndicators: [
              if (selected != null)
                ShowingTooltipIndicators([LineBarSpot(line, 0, line.spots[selected])]),
            ],
            lineTouchData: LineTouchData(
              touchSpotThreshold: 24,
              handleBuiltInTouches: false,
              touchCallback: (event, response) {
                if (event is! FlTapUpEvent) return;
                final hit = response?.lineBarSpots?.firstOrNull?.spotIndex;
                setState(() => _selected = hit == _selected ? null : hit);
              },
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (_) => c.ink,
                tooltipBorderRadius: BorderRadius.circular(Radii.sm),
                fitInsideHorizontally: true,
                getTooltipItems: (spots) => [
                  for (final s in spots)
                    LineTooltipItem(
                      '${_monthLabel(months[s.x.round()])}\n',
                      context.text.labelSmall!.copyWith(color: c.bg),
                      children: [
                        TextSpan(
                          text: money.formatCents(
                            months[s.x.round()].savedAmount,
                            hideZeroDecimals: true,
                          ),
                          style: context.text.labelLarge!.copyWith(color: c.bg),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            lineBarsData: [line],
          ),
          duration: MediaQuery.disableAnimationsOf(context) ? Duration.zero : Motion.progress,
        ),
      ),
    );
  }
}

/// FR-61: spend per pillar month over month, as small multiples: one row per
/// pillar with its own icon and name, so no pillar is told apart by colour.
/// All rows share one scale, so bar heights compare across pillars.
class PillarMonthsChart extends ConsumerWidget {
  const PillarMonthsChart({super.key, required this.months, required this.pillars});

  /// Oldest first (at most 6, the current month last).
  final List<MonthRecord> months;
  final List<Pillar> pillars;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maxSpend = months
        .expand((m) => m.spentByPillar.values)
        .fold<int>(0, math.max)
        .clamp(1, 1 << 62);
    return Column(
      children: [
        for (final (i, p) in pillars.indexed) ...[
          if (i > 0) const SizedBox(height: Space.s4),
          _PillarRow(
            pillar: p,
            months: months,
            maxSpend: maxSpend,
            showMonths: i == pillars.length - 1,
          ),
        ],
      ],
    );
  }
}

class _PillarRow extends ConsumerStatefulWidget {
  const _PillarRow({
    required this.pillar,
    required this.months,
    required this.maxSpend,
    required this.showMonths,
  });

  final Pillar pillar;
  final List<MonthRecord> months;
  final int maxSpend;
  final bool showMonths;

  @override
  ConsumerState<_PillarRow> createState() => _PillarRowState();
}

class _PillarRowState extends ConsumerState<_PillarRow> {
  /// The tapped month; its tooltip stays until another tap.
  int? _selected;

  @override
  Widget build(BuildContext context) {
    final _PillarRow(:pillar, :months, :maxSpend, :showMonths) = widget;
    final c = context.colors;
    final money = ref.watch(moneyFormatterProvider);
    final accent = PillarStyle.color(c, pillar.id);
    int spend(MonthRecord m) => m.spentByPillar[pillar.id] ?? 0;
    final description = [
      for (final m in months) '${_monthLabel(m)} ${money.semanticLabel(spend(m))}',
    ].join(', ');

    return Semantics(
      label: '${pillar.name} by month: $description',
      excludeSemantics: true,
      // Name above the bars, so long names never squeeze the chart.
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(PillarStyle.icon(pillar.id), size: 18, color: accent),
              const SizedBox(width: Space.s2),
              Expanded(child: Text(pillar.name, style: context.text.bodyMedium)),
            ],
          ),
          const SizedBox(height: Space.s1),
          SizedBox(
            height: 64,
            child: BarChart(
              BarChartData(
                maxY: maxSpend / 100,
                minY: 0,
                alignment: BarChartAlignment.spaceAround,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(
                  show: true,
                  border: Border(bottom: BorderSide(color: c.divider)),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),
                  leftTitles: const AxisTitles(),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      // Every row reserves the label space so bar heights
                      // share one scale; only the last row shows the months.
                      showTitles: true,
                      reservedSize: 20,
                      getTitlesWidget: (x, meta) => showMonths
                          ? Text(_monthLabel(months[x.toInt()]), style: context.text.labelSmall)
                          : const SizedBox.shrink(),
                    ),
                  ),
                ),
                barTouchData: BarTouchData(
                  handleBuiltInTouches: false,
                  touchCallback: (event, response) {
                    if (event is! FlTapUpEvent) return;
                    final hit = response?.spot?.touchedBarGroupIndex;
                    setState(() => _selected = hit == _selected ? null : hit);
                  },
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => c.ink,
                    tooltipBorderRadius: BorderRadius.circular(Radii.sm),
                    fitInsideHorizontally: true,
                    fitInsideVertically: true,
                    getTooltipItem: (group, _, _, _) => BarTooltipItem(
                      '${_monthLabel(months[group.x])} · '
                      '${money.formatCents(spend(months[group.x]), hideZeroDecimals: true)}',
                      context.text.labelSmall!.copyWith(color: c.bg),
                    ),
                  ),
                ),
                barGroups: [
                  for (final (i, m) in months.indexed)
                    BarChartGroupData(
                      x: i,
                      showingTooltipIndicators: [if (i == _selected) 0],
                      barRods: [
                        BarChartRodData(
                          toY: math.max(0, spend(m)) / 100,
                          width: 14,
                          color: accent,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                      ],
                    ),
                ],
              ),
              duration: MediaQuery.disableAnimationsOf(context) ? Duration.zero : Motion.progress,
            ),
          ),
        ],
      ),
    );
  }
}
