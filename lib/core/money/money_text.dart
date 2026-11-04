import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/kakeibo_colors.dart';
import '../../features/settings/domain/app_preferences.dart';
import 'currency_format.dart';

/// Displays an amount in cents using the user's currency format. The symbol is
/// drawn smaller and in `ink2` (MASTER.md §3); negatives use a true minus sign
/// and the `over` colour.
class MoneyText extends ConsumerWidget {
  const MoneyText(
    this.cents, {
    super.key,
    this.style,
    this.hideZeroDecimals = false,
    this.symbolScale = 0.55,
    this.textAlign,
  });

  final int cents;
  final TextStyle? style;
  final bool hideZeroDecimals;
  final double symbolScale;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatter = ref.watch(moneyFormatterProvider);
    final parts = formatter.parts(cents, hideZeroDecimals: hideZeroDecimals);
    final c = context.colors;
    final base = (style ?? DefaultTextStyle.of(context).style).copyWith(
      color: parts.isNegative ? c.over : null,
    );
    final symbolStyle = base.copyWith(
      color: parts.isNegative ? c.over : c.ink2,
      fontSize: (base.fontSize ?? 16) * symbolScale,
    );
    final gap = parts.space ? ' ' : '';
    final sign = parts.isNegative ? '−' : '';
    final symbol = TextSpan(text: parts.symbol, style: symbolStyle);
    final number = TextSpan(text: parts.number);

    return Semantics(
      label: formatter.semanticLabel(cents),
      excludeSemantics: true,
      child: Text.rich(
        TextSpan(
          style: base,
          children: parts.position == SymbolPosition.before
              ? [TextSpan(text: sign), symbol, TextSpan(text: gap), number]
              : [TextSpan(text: sign), number, TextSpan(text: gap), symbol],
        ),
        textAlign: textAlign,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.fade,
      ),
    );
  }
}
