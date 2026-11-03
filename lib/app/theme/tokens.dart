import 'package:flutter/animation.dart';

/// Spacing scale on a 4/8 dp rhythm (design-system MASTER.md §4).
abstract final class Space {
  static const double s1 = 4;
  static const double s2 = 8;
  static const double s3 = 12;
  static const double s4 = 16;
  static const double s5 = 24;
  static const double s6 = 32;
  static const double s7 = 48;
  static const double s8 = 64;

  /// Horizontal screen gutter on phones (< 600 dp wide).
  static const double gutter = 20;

  /// Horizontal screen gutter on wider windows.
  static const double gutterWide = 32;

  /// Content never grows wider than this; it is centred instead.
  static const double maxContentWidth = 560;

  /// Minimum touch target (Android guideline).
  static const double minTouch = 48;
}

/// Corner radii (MASTER.md §4).
abstract final class Radii {
  static const double sm = 8;
  static const double md = 14;
  static const double lg = 24;
  static const double full = 999;
}

/// Icon sizes (MASTER.md §5).
abstract final class IconSizes {
  static const double sm = 16;
  static const double md = 24;
  static const double lg = 32;
  static const double xl = 48;
}

/// Motion tokens (MASTER.md §6). Check [MediaQuery.disableAnimationsOf]
/// before running anything longer than [tapFeedback].
abstract final class Motion {
  static const Duration tapFeedback = Duration(milliseconds: 90);
  static const Duration micro = Duration(milliseconds: 150);
  static const Duration standard = Duration(milliseconds: 250);
  static const Duration standardExit = Duration(milliseconds: 200);
  static const Duration sheet = Duration(milliseconds: 300);
  static const Duration sheetExit = Duration(milliseconds: 220);
  static const Duration number = Duration(milliseconds: 400);
  static const Duration progress = Duration(milliseconds: 600);
  static const Duration page = Duration(milliseconds: 300);

  static const Curve enter = Curves.easeOutCubic;
  static const Curve exit = Curves.easeInCubic;
  static const Curve sheetCurve = Curves.easeOutQuart;
}
