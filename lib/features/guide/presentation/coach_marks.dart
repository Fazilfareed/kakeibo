import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/kakeibo_colors.dart';
import '../../../app/theme/kakeibo_text.dart';
import '../../../app/theme/tokens.dart';
import '../../settings/data/settings_repository.dart';
import '../domain/guide_state.dart';

/// Things coach marks point at (the + button lives in the app shell).
abstract final class CoachTargets {
  static final fab = GlobalKey(debugLabel: 'coach-fab');
}

class CoachStep {
  const CoachStep({required this.target, required this.title, required this.body});

  final GlobalKey target;
  final String title;
  final String body;
}

/// First-visit coach marks (FR-95, FR-99, MASTER.md §7.13): a scrim with a
/// rounded cut-out around each control and a short card. Tapping anywhere
/// moves on; each screen's marks show once and are remembered in settings.
abstract final class CoachMarks {
  static final _shownThisRun = <CoachScreen>{};

  /// Shows [steps] after this frame if [screen] hasn't had its marks yet.
  /// Steps whose target isn't on screen are skipped.
  static void maybeShow(
    BuildContext context,
    WidgetRef ref,
    CoachScreen screen,
    List<CoachStep> steps,
  ) {
    final settings = ref.read(settingsProvider).value;
    if (settings == null || !settings.tourDone || settings.coachSeen(screen)) return;
    if (_shownThisRun.contains(screen)) return;
    _shownThisRun.add(screen);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Let entry animations settle so the cut-outs land in the right place.
      await Future<void>.delayed(const Duration(milliseconds: 450));
      if (!context.mounted) return;
      final visible = steps
          .where((s) => s.target.currentContext?.findRenderObject() != null)
          .toList();
      if (visible.isEmpty) {
        _shownThisRun.remove(screen);
        return;
      }
      await ref.read(settingsRepositoryProvider).set(GuideKeys.coachSeen(screen), 'true');
      if (!context.mounted) return;
      final overlay = Overlay.of(context, rootOverlay: true);
      late OverlayEntry entry;
      entry = OverlayEntry(
        builder: (_) => _CoachOverlay(steps: visible, onDone: () => entry.remove()),
      );
      overlay.insert(entry);
    });
  }

  /// For "Replay guide": allow marks to show again this run.
  static void reset() => _shownThisRun.clear();
}

class _CoachOverlay extends StatefulWidget {
  const _CoachOverlay({required this.steps, required this.onDone});

  final List<CoachStep> steps;
  final VoidCallback onDone;

  @override
  State<_CoachOverlay> createState() => _CoachOverlayState();
}

class _CoachOverlayState extends State<_CoachOverlay> {
  int _i = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reveal());
  }

  /// Scrolls the step's control into view, then redraws the cut-out there.
  Future<void> _reveal() async {
    final target = widget.steps[_i].target.currentContext;
    if (target != null && target.mounted) {
      await Scrollable.ensureVisible(
        target,
        alignment: 0.3,
        duration: MediaQuery.disableAnimationsOf(context) ? Duration.zero : Motion.standard,
      );
    }
    if (!mounted) return;
    setState(() {});
    _announce();
  }

  void _announce() {
    if (!mounted) return;
    final s = widget.steps[_i];
    SemanticsService.sendAnnouncement(
      View.of(context),
      '${s.title}. ${s.body}',
      Directionality.of(context),
    );
  }

  void _next() {
    if (_i == widget.steps.length - 1) {
      widget.onDone();
      return;
    }
    setState(() => _i++);
    _reveal();
  }

  Rect? _targetRect() {
    final box = widget.steps[_i].target.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;
    return (box.localToGlobal(Offset.zero) & box.size).inflate(8);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final step = widget.steps[_i];
    final rect = _targetRect();
    final size = MediaQuery.sizeOf(context);
    final below = rect == null || rect.center.dy < size.height / 2;
    final reduce = MediaQuery.disableAnimationsOf(context);

    final card = Material(
      color: c.surface,
      elevation: 6,
      borderRadius: BorderRadius.circular(Radii.md),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Space.s4, Space.s4, Space.s2, Space.s2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(header: true, child: Text(step.title, style: context.text.titleMedium)),
            const SizedBox(height: Space.s1),
            Padding(
              padding: const EdgeInsets.only(right: Space.s2),
              child: Text(step.body, style: context.text.bodyMedium),
            ),
            Row(
              children: [
                Text('${_i + 1} of ${widget.steps.length}', style: context.text.bodySmall),
                const Spacer(),
                TextButton(
                  onPressed: _next,
                  child: Text(_i == widget.steps.length - 1 ? 'Got it' : 'Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    // Modal for TalkBack too: the screen behind can't be reached (FR-107).
    return BlockSemantics(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _next,
        child: Stack(
          children: [
            Positioned.fill(
              child: ExcludeSemantics(
                child: CustomPaint(painter: _ScrimPainter(rect, c.ink.withValues(alpha: 0.6))),
              ),
            ),
            AnimatedPositioned(
              duration: reduce ? Duration.zero : Motion.standard,
              curve: Motion.enter,
              left: Space.gutter,
              right: Space.gutter,
              top: below ? (rect?.bottom ?? size.height / 3) + Space.s3 : null,
              bottom: below ? null : size.height - rect.top + Space.s3,
              child: SafeArea(child: card),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScrimPainter extends CustomPainter {
  _ScrimPainter(this.hole, this.color);

  final Rect? hole;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()..addRect(Offset.zero & size);
    if (hole != null) {
      path
        ..addRRect(RRect.fromRectAndRadius(hole!, const Radius.circular(Radii.md)))
        ..fillType = PathFillType.evenOdd;
    }
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_ScrimPainter old) => old.hole != hole || old.color != color;
}
