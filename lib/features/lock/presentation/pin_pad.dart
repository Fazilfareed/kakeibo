import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../app/theme/kakeibo_colors.dart';
import '../../../app/theme/kakeibo_text.dart';
import '../../../app/theme/tokens.dart';

/// Filled / empty dots for the digits typed so far. Read out as a count, never
/// the digits themselves.
class PinDots extends StatelessWidget {
  const PinDots({super.key, required this.length, required this.filled, this.error = false});

  final int length;
  final int filled;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      label: '$filled of $length digits entered',
      liveRegion: true,
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < length; i++)
            Container(
              width: 14,
              height: 14,
              margin: const EdgeInsets.symmetric(horizontal: Space.s2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i < filled ? (error ? c.over : c.ink) : Colors.transparent,
                border: Border.all(color: error ? c.over : c.ink2, width: 1.5),
              ),
            ),
        ],
      ),
    );
  }
}

/// A 3×4 number pad with 64 dp keys. [extra] fills the bottom-left key
/// (for example the fingerprint button).
class PinPad extends StatelessWidget {
  const PinPad({super.key, required this.onDigit, required this.onBackspace, this.extra});

  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    Widget key(String d) => _Key(
      label: d,
      onTap: () {
        HapticFeedback.selectionClick();
        onDigit(d);
      },
      child: Text(d, style: context.moneyText.moneyM),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final row in const [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
        ])
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [for (final d in row) key(d)]),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 88, height: 72, child: Center(child: extra)),
            key('0'),
            _Key(
              label: 'Delete',
              onTap: onBackspace,
              child: Icon(Symbols.backspace_rounded, color: context.colors.ink2),
            ),
          ],
        ),
      ],
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({required this.label, required this.onTap, required this.child});

  final String label;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Space.s3, vertical: Space.s1),
      // The tap is on Semantics too: excluding the InkResponse's own
      // semantics would otherwise hide it from TalkBack.
      child: Semantics(
        button: true,
        label: label,
        onTap: onTap,
        excludeSemantics: true,
        child: InkResponse(
          onTap: onTap,
          radius: 36,
          child: SizedBox(width: 64, height: 64, child: Center(child: child)),
        ),
      ),
    );
  }
}
