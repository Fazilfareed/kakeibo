import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../app/router.dart';
import '../../../app/theme/kakeibo_colors.dart';
import '../../../app/theme/kakeibo_text.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/pillars/pillar_style.dart';
import '../../lock/data/lock_providers.dart';
import '../../lock/presentation/pin_setup_flow.dart';
import '../../periods/data/period_providers.dart';
import '../../reminders/data/reminder_providers.dart';
import '../../reminders/domain/reminder_planner.dart';
import '../../settings/data/settings_repository.dart';
import '../../settings/domain/app_preferences.dart';
import '../domain/guide_content.dart';
import '../domain/guide_state.dart';

/// First run (PRD §7.1, FR-90–93): five tour cards, then on first run the
/// setup: month start day, reminders and an optional PIN. Skip is always
/// there; skipping the tour still leads to the setup. [replay] shows the
/// cards only.
class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key, this.replay = false});

  final bool replay;

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  final _pages = PageController();
  int _page = 0;
  int? _startDay;

  int get _tourLength => GuideContent.tour.length;
  int get _total => widget.replay ? _tourLength : _tourLength + 3;
  bool get _inTour => _page < _tourLength;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _go(int page) {
    if (page >= _total) {
      _finish();
      return;
    }
    final reduce = MediaQuery.disableAnimationsOf(context);
    reduce
        ? _pages.jumpToPage(page)
        : _pages.animateToPage(page, duration: Motion.page, curve: Motion.enter);
  }

  Future<void> _finish() async {
    final settings = ref.read(settingsRepositoryProvider);
    if (_startDay != null) {
      await ref.read(periodRepositoryProvider).setMonthStartDay(_startDay!);
    }
    await settings.set(GuideKeys.tourDone, 'true');
    if (!mounted) return;
    if (widget.replay) {
      Navigator.of(context).pop();
      return;
    }
    // FR-94: straight on to planning the first month.
    final planning = ref.read(currentPeriodProvider).value?.status == 'planning';
    context.go(Routes.home);
    if (planning) context.push(Routes.plan);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return PopScope(
      canPop: widget.replay,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: 56,
                child: Row(
                  children: [
                    if (_page > 0)
                      IconButton(
                        tooltip: 'Back',
                        icon: const Icon(Symbols.arrow_back_rounded),
                        onPressed: () => _go(_page - 1),
                      ),
                    const Spacer(),
                    if (_inTour)
                      TextButton(
                        onPressed: () => widget.replay ? _finish() : _go(_tourLength),
                        child: const Text('Skip'),
                      ),
                    const SizedBox(width: Space.s2),
                  ],
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _pages,
                  onPageChanged: (p) => setState(() => _page = p),
                  children: [
                    for (final card in GuideContent.tour) _TourPage(card: card),
                    if (!widget.replay) ...[
                      _StartDayPage(
                        day:
                            _startDay ??
                            int.tryParse(
                              ref.read(settingsProvider).value?['month_start_day'] ?? '',
                            ) ??
                            1,
                        onChanged: (d) => setState(() => _startDay = d),
                      ),
                      _RemindersPage(onDone: () => _go(_page + 1)),
                      _PinPage(onDone: () => _go(_page + 1)),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(Space.gutter, Space.s2, Space.gutter, Space.s4),
                child: Column(
                  children: [
                    if (_inTour)
                      Semantics(
                        label: 'Card ${_page + 1} of $_tourLength',
                        excludeSemantics: true,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (var i = 0; i < _tourLength; i++)
                              AnimatedContainer(
                                duration: Motion.micro,
                                width: i == _page ? 20 : 8,
                                height: 8,
                                margin: const EdgeInsets.symmetric(horizontal: 3),
                                decoration: BoxDecoration(
                                  color: i == _page ? c.ink : c.divider,
                                  borderRadius: BorderRadius.circular(Radii.full),
                                ),
                              ),
                          ],
                        ),
                      ),
                    const SizedBox(height: Space.s4),
                    // The reminders and PIN pages have their own buttons.
                    if (_inTour || _page == _tourLength)
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () => _go(_page + 1),
                          child: Text(
                            _page == _total - 1
                                ? 'Done'
                                : _page == _tourLength - 1 && !widget.replay
                                ? 'Set up'
                                : 'Next',
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TourPage extends StatelessWidget {
  const _TourPage({required this.card});

  final TourCard card;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: Space.gutter, vertical: Space.s5),
      children: [
        ExcludeSemantics(
          child: Center(
            child: Container(
              width: 168,
              height: 168,
              decoration: BoxDecoration(shape: BoxShape.circle, color: c.surfaceSunken),
              child: card.pillars
                  ? Center(
                      // A 2 × 2 grid: two 44 dp icons and one gap per row.
                      child: SizedBox(
                        width: 44 * 2 + Space.s3,
                        child: Wrap(
                          spacing: Space.s3,
                          runSpacing: Space.s3,
                          children: [
                            for (final id in const [1, 2, 3, 4])
                              Icon(PillarStyle.icon(id), size: 44, color: PillarStyle.color(c, id)),
                          ],
                        ),
                      ),
                    )
                  : Icon(card.icon, size: 72, color: c.ink2),
            ),
          ),
        ),
        const SizedBox(height: Space.s6),
        Semantics(
          header: true,
          child: Text(card.title, style: context.text.headlineMedium, textAlign: TextAlign.center),
        ),
        const SizedBox(height: Space.s3),
        Text(card.body, style: context.moneyText.reflection, textAlign: TextAlign.center),
      ],
    );
  }
}

/// FR-02/03: confirm the currency format and choose the month start day.
class _StartDayPage extends ConsumerWidget {
  const _StartDayPage({required this.day, required this.onChanged});

  final int day;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final money = ref.watch(moneyFormatterProvider);
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: Space.gutter, vertical: Space.s5),
      children: [
        Semantics(header: true, child: Text('A few settings', style: context.text.headlineMedium)),
        const SizedBox(height: Space.s5),
        Text('Money', style: context.text.titleMedium),
        const SizedBox(height: Space.s1),
        Text(
          'Amounts are in Sri Lankan Rupees and show like ${money.formatCents(1250000)}. You can '
          'change the symbol any time in Settings.',
          style: context.text.bodyMedium,
        ),
        const SizedBox(height: Space.s6),
        Text('My month starts on', style: context.text.titleMedium),
        const SizedBox(height: Space.s1),
        Text(
          'If you’re paid on a set day, start your month then. You can change it later.',
          style: context.text.bodyMedium,
        ),
        const SizedBox(height: Space.s3),
        DropdownMenu<int>(
          initialSelection: day,
          label: const Text('Day of the month'),
          expandedInsets: EdgeInsets.zero,
          onSelected: (d) => d == null ? null : onChanged(d),
          dropdownMenuEntries: [
            for (var d = 1; d <= 28; d++)
              DropdownMenuEntry(value: d, label: d == 1 ? '1 (calendar month)' : '$d'),
          ],
        ),
      ],
    );
  }
}

/// FR-86: explain first, then ask Android.
class _RemindersPage extends ConsumerWidget {
  const _RemindersPage({required this.onDone});

  final VoidCallback onDone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _ChoicePage(
      icon: Symbols.notifications_rounded,
      title: 'Gentle reminders',
      body:
          'A nudge in the evening to log the day, one to check in each week, and one when a '
          'month starts and ends. They’re set on this phone; nothing is sent anywhere. '
          'Skipped on days you’ve already logged.',
      yes: 'Turn on reminders',
      onYes: () async {
        await ref.read(notificationServiceProvider).requestPermission();
        ref.invalidate(notificationsAllowedProvider);
        await ref.read(settingsRepositoryProvider).set(ReminderSettings.keyOn, 'true');
        onDone();
      },
      onNo: onDone,
    );
  }
}

/// FR-06/07: optional PIN, which can be set later in Settings.
class _PinPage extends ConsumerWidget {
  const _PinPage({required this.onDone});

  final VoidCallback onDone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _ChoicePage(
      icon: Symbols.lock_rounded,
      title: 'Lock with a PIN?',
      body:
          'Anyone who picks up your phone could open your spending. A PIN keeps it private. '
          'You’ll get a recovery code in case you forget it.',
      yes: 'Set a PIN',
      onYes: () async {
        final ok = await Navigator.of(context, rootNavigator: true).push<bool>(
          MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(title: const Text('Set up app lock')),
              body: SafeArea(child: PinSetupFlow(onDone: () => Navigator.pop(context, true))),
            ),
          ),
        );
        if (ok == true) {
          ref.read(sessionUnlockedProvider.notifier).unlock();
          await ref.read(settingsRepositoryProvider).set(LockSettings.keyEnabled, 'true');
        }
        onDone();
      },
      onNo: onDone,
    );
  }
}

class _ChoicePage extends StatelessWidget {
  const _ChoicePage({
    required this.icon,
    required this.title,
    required this.body,
    required this.yes,
    required this.onYes,
    required this.onNo,
  });

  final IconData icon;
  final String title;
  final String body;
  final String yes;
  final VoidCallback onYes;
  final VoidCallback onNo;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: Space.gutter, vertical: Space.s5),
      children: [
        ExcludeSemantics(child: Icon(icon, size: 64, color: c.ink2)),
        const SizedBox(height: Space.s5),
        Semantics(
          header: true,
          child: Text(title, style: context.text.headlineMedium, textAlign: TextAlign.center),
        ),
        const SizedBox(height: Space.s3),
        Text(body, style: context.text.bodyLarge, textAlign: TextAlign.center),
        const SizedBox(height: Space.s6),
        FilledButton(onPressed: onYes, child: Text(yes)),
        const SizedBox(height: Space.s2),
        TextButton(onPressed: onNo, child: const Text('Not now')),
      ],
    );
  }
}
