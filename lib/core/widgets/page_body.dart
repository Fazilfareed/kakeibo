import 'package:flutter/material.dart';

import '../../app/theme/tokens.dart';

/// Scrollable page content with the standard gutter, centred at
/// [Space.maxContentWidth] on wide windows.
class PageBody extends StatelessWidget {
  const PageBody({super.key, required this.children, this.bottomInset = 96});

  final List<Widget> children;

  /// Extra space at the end so content clears the bottom bar and FAB.
  final double bottomInset;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final gutter = constraints.maxWidth >= 600 ? Space.gutterWide : Space.gutter;
        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: Space.maxContentWidth),
            child: ListView(
              padding: EdgeInsets.fromLTRB(gutter, Space.s2, gutter, bottomInset),
              children: children,
            ),
          ),
        );
      },
    );
  }
}
