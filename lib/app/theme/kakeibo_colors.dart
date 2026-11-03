import 'package:flutter/material.dart';

/// Semantic colour tokens (design-system MASTER.md §2). Widgets read these via
/// `context.colors` and never use raw hex values.
@immutable
class KakeiboColors extends ThemeExtension<KakeiboColors> {
  const KakeiboColors({
    required this.bg,
    required this.surface,
    required this.surfaceSunken,
    required this.ink,
    required this.ink2,
    required this.ink3,
    required this.divider,
    required this.outline,
    required this.primary,
    required this.onPrimary,
    required this.seal,
    required this.needs,
    required this.wants,
    required this.culture,
    required this.unexpected,
    required this.caution,
    required this.over,
    required this.success,
    required this.info,
    required this.scrim,
    required this.containerTint,
  });

  final Color bg;
  final Color surface;
  final Color surfaceSunken;
  final Color ink;
  final Color ink2;
  final Color ink3;
  final Color divider;
  final Color outline;
  final Color primary;
  final Color onPrimary;
  final Color seal;
  final Color needs;
  final Color wants;
  final Color culture;
  final Color unexpected;
  final Color caution;
  final Color over;
  final Color success;
  final Color info;
  final Color scrim;

  /// Opacity of a pillar colour when used as a soft container tint.
  final double containerTint;

  static const light = KakeiboColors(
    bg: Color(0xFFF6F1E7),
    surface: Color(0xFFFFFCF6),
    surfaceSunken: Color(0xFFEFE8DA),
    ink: Color(0xFF1F1C18),
    ink2: Color(0xFF5A5349),
    ink3: Color(0xFF6B6357),
    divider: Color(0xFFE3DACB),
    outline: Color(0xFF8E8475),
    primary: Color(0xFF2B2925),
    onPrimary: Color(0xFFFFFFFF),
    seal: Color(0xFFB7322C),
    needs: Color(0xFF3D6B4C),
    wants: Color(0xFFA24A22),
    culture: Color(0xFF6A568F),
    unexpected: Color(0xFF2D628C),
    caution: Color(0xFF875B0C),
    over: Color(0xFFA8322D),
    success: Color(0xFF3D6B4C),
    info: Color(0xFF2D628C),
    scrim: Color(0x661F1C18),
    containerTint: 0.12,
  );

  static const dark = KakeiboColors(
    bg: Color(0xFF151412),
    surface: Color(0xFF1F1D1A),
    surfaceSunken: Color(0xFF100F0D),
    ink: Color(0xFFEEE8DC),
    ink2: Color(0xFFB4AC9E),
    ink3: Color(0xFF948C7F),
    divider: Color(0xFF3A3631),
    outline: Color(0xFF7A7267),
    primary: Color(0xFFEEE8DC),
    onPrimary: Color(0xFF151412),
    seal: Color(0xFFE06A60),
    needs: Color(0xFF7FB08E),
    wants: Color(0xFFE39467),
    culture: Color(0xFFAE9BD6),
    unexpected: Color(0xFF7CB0DA),
    caution: Color(0xFFE0B25A),
    over: Color(0xFFEE8A84),
    success: Color(0xFF7FB08E),
    info: Color(0xFF7CB0DA),
    scrim: Color(0x99000000),
    containerTint: 0.18,
  );

  /// A pillar or status colour blended softly over [surface].
  Color container(Color accent) =>
      Color.alphaBlend(accent.withValues(alpha: containerTint), surface);

  @override
  KakeiboColors copyWith({
    Color? bg,
    Color? surface,
    Color? surfaceSunken,
    Color? ink,
    Color? ink2,
    Color? ink3,
    Color? divider,
    Color? outline,
    Color? primary,
    Color? onPrimary,
    Color? seal,
    Color? needs,
    Color? wants,
    Color? culture,
    Color? unexpected,
    Color? caution,
    Color? over,
    Color? success,
    Color? info,
    Color? scrim,
    double? containerTint,
  }) {
    return KakeiboColors(
      bg: bg ?? this.bg,
      surface: surface ?? this.surface,
      surfaceSunken: surfaceSunken ?? this.surfaceSunken,
      ink: ink ?? this.ink,
      ink2: ink2 ?? this.ink2,
      ink3: ink3 ?? this.ink3,
      divider: divider ?? this.divider,
      outline: outline ?? this.outline,
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      seal: seal ?? this.seal,
      needs: needs ?? this.needs,
      wants: wants ?? this.wants,
      culture: culture ?? this.culture,
      unexpected: unexpected ?? this.unexpected,
      caution: caution ?? this.caution,
      over: over ?? this.over,
      success: success ?? this.success,
      info: info ?? this.info,
      scrim: scrim ?? this.scrim,
      containerTint: containerTint ?? this.containerTint,
    );
  }

  @override
  KakeiboColors lerp(ThemeExtension<KakeiboColors>? other, double t) {
    if (other is! KakeiboColors) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return KakeiboColors(
      bg: l(bg, other.bg),
      surface: l(surface, other.surface),
      surfaceSunken: l(surfaceSunken, other.surfaceSunken),
      ink: l(ink, other.ink),
      ink2: l(ink2, other.ink2),
      ink3: l(ink3, other.ink3),
      divider: l(divider, other.divider),
      outline: l(outline, other.outline),
      primary: l(primary, other.primary),
      onPrimary: l(onPrimary, other.onPrimary),
      seal: l(seal, other.seal),
      needs: l(needs, other.needs),
      wants: l(wants, other.wants),
      culture: l(culture, other.culture),
      unexpected: l(unexpected, other.unexpected),
      caution: l(caution, other.caution),
      over: l(over, other.over),
      success: l(success, other.success),
      info: l(info, other.info),
      scrim: l(scrim, other.scrim),
      containerTint:
          containerTint + (other.containerTint - containerTint) * t,
    );
  }
}

extension KakeiboColorsContext on BuildContext {
  KakeiboColors get colors => Theme.of(this).extension<KakeiboColors>()!;
}
