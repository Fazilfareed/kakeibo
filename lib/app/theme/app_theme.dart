import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'kakeibo_colors.dart';
import 'kakeibo_text.dart';
import 'tokens.dart';

/// Builds the light or dark Material theme from the design-system tokens.
ThemeData buildTheme(Brightness brightness) {
  final c = brightness == Brightness.light
      ? KakeiboColors.light
      : KakeiboColors.dark;
  final text = buildTextTheme(c.ink, c.ink2);

  final scheme = ColorScheme(
    brightness: brightness,
    primary: c.primary,
    onPrimary: c.onPrimary,
    secondary: c.ink2,
    onSecondary: c.surface,
    tertiary: c.seal,
    onTertiary: c.onPrimary,
    error: c.over,
    onError: brightness == Brightness.light ? Colors.white : c.bg,
    surface: c.surface,
    onSurface: c.ink,
    onSurfaceVariant: c.ink2,
    surfaceContainerLowest: c.bg,
    surfaceContainerLow: c.bg,
    surfaceContainer: c.surface,
    surfaceContainerHigh: c.surfaceSunken,
    surfaceContainerHighest: c.surfaceSunken,
    outline: c.outline,
    outlineVariant: c.divider,
    scrim: c.scrim,
    inverseSurface: c.ink,
    onInverseSurface: c.bg,
  );

  final cardShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(Radii.md),
    side: BorderSide(color: c.divider),
  );
  final buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(Radii.md),
  );
  const buttonSize = Size(Space.minTouch, 52);

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: c.bg,
    canvasColor: c.bg,
    fontFamily: Fonts.ui,
    textTheme: text,
    splashFactory: InkRipple.splashFactory,
    extensions: [c, KakeiboText.withInk(c.ink)],
    appBarTheme: AppBarTheme(
      backgroundColor: c.bg,
      foregroundColor: c.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: text.headlineSmall,
      systemOverlayStyle: brightness == Brightness.light
          ? SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent)
          : SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
    ),
    cardTheme: CardThemeData(
      color: c.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: cardShape,
    ),
    dividerTheme: DividerThemeData(color: c.divider, thickness: 1, space: 1),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: c.primary,
        foregroundColor: c.onPrimary,
        minimumSize: buttonSize,
        shape: buttonShape,
        textStyle: fontStyle(Fonts.ui, size: 16, height: 24, weight: 600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        backgroundColor: c.surface,
        foregroundColor: c.ink,
        minimumSize: buttonSize,
        shape: buttonShape,
        side: BorderSide(color: c.outline),
        textStyle: fontStyle(Fonts.ui, size: 16, height: 24, weight: 600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: c.ink,
        minimumSize: const Size(Space.minTouch, Space.minTouch),
        textStyle: fontStyle(Fonts.ui, size: 14, height: 20, weight: 500),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: c.primary,
      foregroundColor: c.onPrimary,
      elevation: 2,
      highlightElevation: 3,
      shape: const CircleBorder(),
      sizeConstraints: const BoxConstraints.tightFor(width: 64, height: 64),
    ),
    bottomAppBarTheme: BottomAppBarThemeData(
      color: c.surface,
      elevation: 0,
      height: 72,
      padding: EdgeInsets.zero,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: c.surface,
      modalBackgroundColor: c.surface,
      modalBarrierColor: c.scrim,
      showDragHandle: true,
      dragHandleColor: c.divider,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.lg)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: c.ink,
      contentTextStyle:
          fontStyle(Fonts.ui, size: 14, height: 20, weight: 400, color: c.bg),
      actionTextColor: c.bg,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.sm)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: c.surfaceSunken,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radii.sm),
        borderSide: BorderSide(color: c.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radii.sm),
        borderSide: BorderSide(color: c.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radii.sm),
        borderSide: BorderSide(color: c.ink, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radii.sm),
        borderSide: BorderSide(color: c.over),
      ),
      labelStyle: text.labelLarge?.copyWith(color: c.ink2),
      helperStyle: text.bodySmall,
      errorStyle: text.bodySmall?.copyWith(color: c.over),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size(Space.minTouch, Space.minTouch)),
        side: WidgetStatePropertyAll(BorderSide(color: c.outline)),
        backgroundColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? c.ink : c.surface,
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? c.bg : c.ink,
        ),
        iconColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? c.bg : c.ink,
        ),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? c.onPrimary : c.outline,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? c.primary : c.surfaceSunken,
      ),
      trackOutlineColor: WidgetStatePropertyAll(c.outline),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? c.ink : c.outline,
      ),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: c.ink2,
      textColor: c.ink,
      minVerticalPadding: Space.s3,
      contentPadding: const EdgeInsets.symmetric(horizontal: Space.s4),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: SharedAxisPageTransitionsBuilder(
          transitionType: SharedAxisTransitionType.horizontal,
        ),
      },
    ),
  );
}
