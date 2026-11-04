import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../app/theme/kakeibo_colors.dart';
import '../../../../app/theme/kakeibo_text.dart';
import '../../../../app/theme/tokens.dart';

/// Savings-goal ring (MASTER.md §7.6): 96 dp, 10 dp stroke, `success` fill on a
/// `surfaceSunken` track, percentage in the centre. With [stamped] the seal-red
/// "saved" hanko stamps in once.
class SavingsRing extends StatelessWidget {
  const SavingsRing({
    super.key,
    required this.value,
    required this.semanticsLabel,
    this.stamped = false,
  });

  /// 0–1.
  final double value;
  final String semanticsLabel;
  final bool stamped;

  static const double size = 96;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final target = value.clamp(0.0, 1.0);

    return Semantics(
      label: semanticsLabel,
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: size,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            RepaintBoundary(
              child: TweenAnimationBuilder<double>(
                tween: Tween(end: target),
                duration: reduceMotion ? Duration.zero : Motion.progress,
                curve: Motion.enter,
                builder: (context, v, _) => CustomPaint(
                  size: const Size.square(size),
                  painter: _RingPainter(value: v, track: c.surfaceSunken, fill: c.success),
                  child: Center(
                    child: Text(
                      '${(v * 100).round()}%',
                      style: context.moneyText.moneyM.copyWith(color: c.ink),
                    ),
                  ),
                ),
              ),
            ),
            if (stamped)
              Positioned(right: -10, bottom: -6, child: HankoStamp(animate: !reduceMotion)),
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.value, required this.track, required this.fill});

  final double value;
  final Color track;
  final Color fill;

  static const double stroke = 10;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final arcRect = rect.deflate(stroke / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(arcRect, 0, math.pi * 2, false, paint..color = track);
    if (value > 0) {
      canvas.drawArc(arcRect, -math.pi / 2, math.pi * 2 * value, false, paint..color = fill);
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value || old.track != track || old.fill != fill;
}

/// The "saved" seal. Scales 1.2 → 1.0 over 300 ms once per appearance.
class HankoStamp extends StatelessWidget {
  const HankoStamp({super.key, required this.animate});

  final bool animate;

  @override
  Widget build(BuildContext context) {
    final seal = context.colors.seal;
    final stamp = Transform.rotate(
      angle: -0.14,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: context.colors.surface,
          border: Border.all(color: seal, width: 1.5),
          borderRadius: BorderRadius.circular(Radii.sm),
        ),
        child: Text(
          'saved',
          style: fontStyle(Fonts.display, size: 12, height: 16, weight: 600, color: seal),
        ),
      ),
    );
    if (!animate) return stamp;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.2, end: 1.0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
      child: stamp,
    );
  }
}
