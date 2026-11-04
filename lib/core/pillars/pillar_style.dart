import 'package:flutter/widgets.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../app/theme/kakeibo_colors.dart';

/// Visual identity of the four Kakeibo pillars (MASTER.md §2.2). Every pillar
/// is always shown with its icon and label, never by colour alone.
abstract final class PillarStyle {
  static const int needs = 1;
  static const int wants = 2;
  static const int culture = 3;
  static const int unexpected = 4;

  static Color color(KakeiboColors c, int pillarId) => switch (pillarId) {
    needs => c.needs,
    wants => c.wants,
    culture => c.culture,
    _ => c.unexpected,
  };

  static IconData icon(int pillarId) => switch (pillarId) {
    needs => Symbols.house_rounded,
    wants => Symbols.shopping_bag_rounded,
    culture => Symbols.menu_book_rounded,
    _ => Symbols.bolt_rounded,
  };
}
