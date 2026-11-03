import 'package:flutter/material.dart';

/// Font families bundled in assets/fonts (SIL OFL).
abstract final class Fonts {
  static const display = 'Lora';
  static const ui = 'Inter';
}

/// Builds a style for a variable font. Flutter needs an explicit `wght` axis
/// value for variable fonts, so weight is set both ways.
TextStyle fontStyle(
  String family, {
  required double size,
  required double height,
  required int weight,
  Color? color,
  bool tabular = false,
}) {
  return TextStyle(
    fontFamily: family,
    fontSize: size,
    height: height / size,
    fontWeight: FontWeight.values[(weight ~/ 100) - 1],
    fontVariations: [FontVariation.weight(weight.toDouble())],
    fontFeatures: tabular ? const [FontFeature.tabularFigures()] : null,
    color: color,
  );
}

/// App-specific text styles that don't map onto Material's TextTheme
/// (MASTER.md §3).
@immutable
class KakeiboText extends ThemeExtension<KakeiboText> {
  const KakeiboText({
    required this.displayMoney,
    required this.moneyM,
    required this.reflection,
  });

  /// Hero amount on the dashboard, Inter 600 40/44 with tabular figures.
  final TextStyle displayMoney;

  /// Card and summary amounts, Inter 600 22/28 with tabular figures.
  final TextStyle moneyM;

  /// Reflection questions and answers, Lora 400 18/28.
  final TextStyle reflection;

  factory KakeiboText.withInk(Color ink) => KakeiboText(
        displayMoney: fontStyle(Fonts.ui,
            size: 40, height: 44, weight: 600, color: ink, tabular: true),
        moneyM: fontStyle(Fonts.ui,
            size: 22, height: 28, weight: 600, color: ink, tabular: true),
        reflection:
            fontStyle(Fonts.display, size: 18, height: 28, weight: 400, color: ink),
      );

  @override
  KakeiboText copyWith({
    TextStyle? displayMoney,
    TextStyle? moneyM,
    TextStyle? reflection,
  }) {
    return KakeiboText(
      displayMoney: displayMoney ?? this.displayMoney,
      moneyM: moneyM ?? this.moneyM,
      reflection: reflection ?? this.reflection,
    );
  }

  @override
  KakeiboText lerp(ThemeExtension<KakeiboText>? other, double t) {
    if (other is! KakeiboText) return this;
    return KakeiboText(
      displayMoney: TextStyle.lerp(displayMoney, other.displayMoney, t)!,
      moneyM: TextStyle.lerp(moneyM, other.moneyM, t)!,
      reflection: TextStyle.lerp(reflection, other.reflection, t)!,
    );
  }
}

/// Material text theme mapped to the design-system type scale.
TextTheme buildTextTheme(Color ink, Color ink2) {
  return TextTheme(
    // headline: Lora 600 26/32
    headlineSmall:
        fontStyle(Fonts.display, size: 26, height: 32, weight: 600, color: ink),
    // title: Lora 600 20/26
    titleLarge:
        fontStyle(Fonts.display, size: 20, height: 26, weight: 600, color: ink),
    titleMedium:
        fontStyle(Fonts.ui, size: 16, height: 24, weight: 600, color: ink),
    // body: Inter 400 16/24
    bodyLarge: fontStyle(Fonts.ui, size: 16, height: 24, weight: 400, color: ink),
    bodyMedium: fontStyle(Fonts.ui, size: 16, height: 24, weight: 400, color: ink),
    // caption: Inter 400 13/18
    bodySmall: fontStyle(Fonts.ui, size: 13, height: 18, weight: 400, color: ink2),
    // label: Inter 500 14/20
    labelLarge: fontStyle(Fonts.ui, size: 14, height: 20, weight: 500, color: ink),
    labelMedium:
        fontStyle(Fonts.ui, size: 13, height: 18, weight: 500, color: ink2),
    labelSmall: fontStyle(Fonts.ui, size: 12, height: 16, weight: 500, color: ink2),
  );
}

extension KakeiboTextContext on BuildContext {
  KakeiboText get moneyText => Theme.of(this).extension<KakeiboText>()!;
  TextTheme get text => Theme.of(this).textTheme;
}
