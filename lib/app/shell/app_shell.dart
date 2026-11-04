import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../features/expenses/presentation/quick_add_sheet.dart';
import '../theme/kakeibo_colors.dart';
import '../theme/kakeibo_text.dart';
import '../theme/tokens.dart';

/// Bottom bar with four tabs and the docked quick-add button (MASTER.md §7.2–7.3).
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _tabs = [
    (label: 'Home', icon: Symbols.home_rounded, selected: Symbols.home_rounded),
    (label: 'Spends', icon: Symbols.receipt_long_rounded, selected: Symbols.receipt_long_rounded),
    (label: 'History', icon: Symbols.bar_chart_rounded, selected: Symbols.bar_chart_rounded),
    (label: 'Settings', icon: Symbols.settings_rounded, selected: Symbols.settings_rounded),
  ];

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      // Tapping the active tab returns to its root.
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    Widget tab(int i) => Expanded(
      child: _NavItem(
        label: _tabs[i].label,
        icon: _tabs[i].icon,
        selectedIcon: _tabs[i].selected,
        selected: navigationShell.currentIndex == i,
        onTap: () => _goBranch(i),
      ),
    );

    return Scaffold(
      body: SafeArea(bottom: false, child: navigationShell),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add expense',
        onPressed: () => showQuickAddSheet(context),
        child: const Icon(Symbols.add_rounded, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: c.divider)),
        ),
        child: BottomAppBar(
          child: Row(children: [tab(0), tab(1), const SizedBox(width: 80), tab(2), tab(3)]),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final color = selected ? c.ink : c.ink2;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      // Excluding the child's semantics hides its tap, so add it here.
      onTap: onTap,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        containedInkWell: true,
        highlightShape: BoxShape.rectangle,
        child: SizedBox(
          height: 72,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: Motion.micro,
                curve: Motion.enter,
                padding: const EdgeInsets.symmetric(horizontal: Space.s4, vertical: Space.s1),
                decoration: BoxDecoration(
                  color: selected ? c.surfaceSunken : Colors.transparent,
                  borderRadius: BorderRadius.circular(Radii.full),
                ),
                child: Icon(
                  selected ? selectedIcon : icon,
                  color: color,
                  size: IconSizes.md,
                  fill: selected ? 1 : 0,
                ),
              ),
              const SizedBox(height: Space.s1),
              Text(
                label,
                style: context.text.labelSmall?.copyWith(
                  color: color,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
