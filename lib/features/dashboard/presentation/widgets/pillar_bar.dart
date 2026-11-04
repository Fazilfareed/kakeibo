import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../app/theme/kakeibo_colors.dart';
import '../../../../app/theme/kakeibo_text.dart';
import '../../../../app/theme/tokens.dart';
import '../../../../core/money/money_text.dart';
import '../../../../core/pillars/pillar_style.dart';
import '../../../settings/domain/app_preferences.dart';

/// One pillar's spent-vs-planned bar (MASTER.md §7.5). The state is shown by
/// colour, icon and text together. Tapping it opens that pillar's spends.
class PillarBar extends ConsumerWidget {
  const PillarBar({
    super.key,
    required this.pillarId,
    required this.name,
    required this.spentCents,
    required this.plannedCents,
    this.onTap,
  });

  final int pillarId;
  final String name;
  final int spentCents;
  final int plannedCents;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final accent = PillarStyle.color(c, pillarId);
    final hasBudget = plannedCents > 0;
    final ratio = hasBudget ? spentCents / plannedCents : 0.0;

    final money = ref.watch(moneyFormatterProvider);
    final overCents = spentCents - plannedCents;

    final (Color fill, IconData? stateIcon, String? stateText) = switch (ratio) {
      _ when !hasBudget => (c.ink3, null, 'No budget set'),
      // MASTER.md §7.5: past 100% the bar is full and says by how much.
      > 1.0 => (
        c.over,
        Symbols.cancel_rounded,
        '+${money.formatCents(overCents, hideZeroDecimals: true)} over',
      ),
      >= 0.75 => (c.caution, Symbols.warning_rounded, 'Getting close'),
      _ => (accent, null, null),
    };
    final stateColor = fill == accent ? c.ink3 : fill;

    final label = [
      name,
      hasBudget
          ? '${money.semanticLabel(spentCents)} of ${money.semanticLabel(plannedCents)} spent, '
                '${(ratio * 100).round()} percent'
          : '${money.semanticLabel(spentCents)} spent',
      if (ratio > 1.0) '${money.semanticLabel(overCents)} over budget' else ?stateText,
    ].join(', ');

    return Semantics(
      label: label,
      button: onTap != null,
      onTap: onTap,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Radii.sm),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: Space.s2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  ExcludeSemantics(
                    child: Icon(PillarStyle.icon(pillarId), size: 20, color: accent),
                  ),
                  const SizedBox(width: Space.s2),
                  Expanded(child: Text(name, style: context.text.titleMedium)),
                  MoneyText(spentCents, style: context.text.bodySmall, hideZeroDecimals: true),
                  if (hasBudget) ...[
                    Text(' / ', style: context.text.bodySmall),
                    MoneyText(plannedCents, style: context.text.bodySmall, hideZeroDecimals: true),
                  ],
                ],
              ),
              const SizedBox(height: Space.s2),
              ClipRRect(
                borderRadius: BorderRadius.circular(Radii.full),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(end: ratio.clamp(0.0, 1.0)),
                  duration: MediaQuery.disableAnimationsOf(context)
                      ? Duration.zero
                      : Motion.progress,
                  curve: Motion.enter,
                  builder: (context, value, _) => LinearProgressIndicator(
                    value: value,
                    minHeight: 10,
                    backgroundColor: c.surfaceSunken,
                    color: fill,
                  ),
                ),
              ),
              const SizedBox(height: Space.s1),
              Row(
                children: [
                  Text(
                    hasBudget ? '${(ratio * 100).round()}%' : '',
                    style: context.text.labelSmall?.copyWith(color: c.ink3),
                  ),
                  const Spacer(),
                  if (stateText != null) ...[
                    if (stateIcon != null) ...[
                      Icon(stateIcon, size: IconSizes.sm, color: stateColor),
                      const SizedBox(width: Space.s1),
                    ],
                    Text(stateText, style: context.text.labelSmall?.copyWith(color: stateColor)),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
