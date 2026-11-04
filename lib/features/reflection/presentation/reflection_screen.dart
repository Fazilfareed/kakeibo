import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../app/theme/kakeibo_colors.dart';
import '../../../app/theme/kakeibo_text.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/date/local_date.dart';
import '../../../core/db/app_database.dart';
import '../../../core/money/money_text.dart';
import '../../../core/pillars/pillar_style.dart';
import '../../../core/pillars/pillars_provider.dart';
import '../../dashboard/presentation/widgets/pillar_bar.dart';
import '../../dashboard/presentation/widgets/savings_ring.dart';
import '../../settings/domain/app_preferences.dart';
import '../data/reflection_providers.dart';
import '../domain/reflection_summary.dart';

enum _Step { summary, q1, q2, q3, kept, improvement }

/// Month-end reflection wizard (PRD §6.6, MASTER.md §7.14): one question per
/// page, slower and roomier than logging. Answers are saved on every step.
class ReflectionScreen extends ConsumerWidget {
  const ReflectionScreen({super.key, required this.periodId});

  final int periodId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(reflectionSummaryProvider(periodId));
    return switch (summary) {
      AsyncData(:final value) => _Wizard(summary: value),
      AsyncError() => Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text("Couldn't load this month.")),
      ),
      _ => Scaffold(appBar: AppBar()),
    };
  }
}

class _Wizard extends ConsumerStatefulWidget {
  const _Wizard({required this.summary});

  final ReflectionSummary summary;

  @override
  ConsumerState<_Wizard> createState() => _WizardState();
}

class _WizardState extends ConsumerState<_Wizard> {
  late final ReflectionSummary s = widget.summary;
  late final _a1 = TextEditingController(text: s.saved?.answerQ1);
  late final _a2 = TextEditingController(text: s.saved?.answerQ2);
  late final _a3 = TextEditingController(text: s.saved?.answerQ3);
  late final _improvement = TextEditingController(text: s.saved?.improvement);
  late ImprovementKept? _kept = ImprovementKept.fromName(s.saved?.prevImprovementKept);

  late final List<_Step> _steps = [
    _Step.summary,
    _Step.q1,
    _Step.q2,
    _Step.q3,
    if (s.previousImprovement != null) _Step.kept,
    _Step.improvement,
  ];
  int _index = 0;
  bool _forward = true;
  bool _saving = false;

  @override
  void dispose() {
    _a1.dispose();
    _a2.dispose();
    _a3.dispose();
    _improvement.dispose();
    super.dispose();
  }

  ReflectionDraft get _draft => ReflectionDraft(
    periodId: s.period.id,
    answer1: _a1.text,
    answer2: _a2.text,
    answer3: _a3.text,
    improvementKept: _kept,
    improvement: _improvement.text,
  );

  bool get _isLast => _index == _steps.length - 1;

  Future<void> _next() async {
    FocusScope.of(context).unfocus();
    final repo = ref.read(reflectionRepositoryProvider);
    if (!_isLast) {
      setState(() {
        _forward = true;
        _index++;
      });
      await repo.saveDraft(_draft);
      return;
    }
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    await repo.complete(_draft);
    navigator.pop();
    messenger.removeCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          _improvement.text.trim().isEmpty
              ? 'Reflection saved.'
              : 'Reflection saved. Your improvement is on Home.',
        ),
      ),
    );
  }

  void _back() {
    FocusScope.of(context).unfocus();
    setState(() {
      _forward = false;
      _index--;
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final month = DateFormat('MMMM').format(LocalDate.parse(s.period.startDate));
    final step = _steps[_index];

    return PopScope(
      // Leaving keeps the draft; the Home card brings the wizard back.
      onPopInvokedWithResult: (didPop, _) {
        if (didPop && !_saving) ref.read(reflectionRepositoryProvider).saveDraft(_draft);
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'Close',
            icon: const Icon(Symbols.close_rounded),
            onPressed: () => Navigator.maybePop(context),
          ),
          title: Text('Reflect on $month'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4),
            child: Semantics(
              label: 'Step ${_index + 1} of ${_steps.length}',
              excludeSemantics: true,
              child: TweenAnimationBuilder<double>(
                tween: Tween(end: (_index + 1) / _steps.length),
                duration: Motion.standard,
                builder: (context, v, _) => LinearProgressIndicator(
                  value: v,
                  minHeight: 4,
                  backgroundColor: c.surfaceSunken,
                  color: c.ink,
                ),
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: PageTransitionSwitcher(
                duration: MediaQuery.disableAnimationsOf(context) ? Duration.zero : Motion.page,
                reverse: !_forward,
                transitionBuilder: (child, primary, secondary) => SharedAxisTransition(
                  animation: primary,
                  secondaryAnimation: secondary,
                  transitionType: SharedAxisTransitionType.horizontal,
                  fillColor: c.bg,
                  child: child,
                ),
                child: KeyedSubtree(key: ValueKey(step), child: _page(step)),
              ),
            ),
            SafeArea(
              top: false,
              minimum: const EdgeInsets.fromLTRB(Space.gutter, Space.s2, Space.gutter, Space.s3),
              child: Row(
                children: [
                  if (_index > 0) TextButton(onPressed: _back, child: const Text('Back')),
                  const Spacer(),
                  FilledButton(
                    onPressed: _saving ? null : _next,
                    child: Text(_isLast ? 'Finish' : 'Next'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _page(_Step step) => switch (step) {
    _Step.summary => _SummaryPage(summary: s),
    _Step.q1 => _QuestionPage(
      number: 1,
      question: ReflectionQuestions.q1,
      why: s.isFirstReflection ? ReflectionQuestions.why1 : null,
      controller: _a1,
    ),
    _Step.q2 => _QuestionPage(
      number: 2,
      question: ReflectionQuestions.q2,
      why: s.isFirstReflection ? ReflectionQuestions.why2 : null,
      controller: _a2,
    ),
    _Step.q3 => _QuestionPage(
      number: 3,
      question: ReflectionQuestions.q3,
      why: s.isFirstReflection ? ReflectionQuestions.why3 : null,
      controller: _a3,
      extra: _MoodLists(summary: s),
    ),
    _Step.kept => _KeptPage(
      improvement: s.previousImprovement!,
      kept: _kept,
      onChanged: (k) => setState(() => _kept = k),
    ),
    _Step.improvement => _QuestionPage(
      number: 4,
      question: ReflectionQuestions.q4,
      why: s.isFirstReflection ? ReflectionQuestions.why4 : null,
      controller: _improvement,
      hint: 'For example: cook at home on weekdays',
      maxLength: 80,
      footer: 'It will sit on your Home screen all next month.',
    ),
  };
}

/// FR-51/59: the month in numbers.
class _SummaryPage extends ConsumerWidget {
  const _SummaryPage({required this.summary});

  final ReflectionSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final s = summary;
    final money = ref.watch(moneyFormatterProvider);
    final pillars = ref.watch(pillarsProvider).value ?? const <Pillar>[];
    final overshoot = s.biggestOvershoot;
    String pillarName(int id) => pillars.where((p) => p.id == id).firstOrNull?.name ?? '';

    return ListView(
      padding: const EdgeInsets.fromLTRB(Space.gutter, Space.s6, Space.gutter, Space.s6),
      children: [
        Text(
          s.savedAmount >= 0 ? 'You saved' : 'You spent more than you earned by',
          style: context.text.bodyMedium,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: MoneyText(
                s.savedAmount.abs(),
                style: context.moneyText.displayMoney.copyWith(
                  color: s.savedAmount < 0 ? c.over : null,
                ),
                hideZeroDecimals: true,
              ),
            ),
            if (s.goalMet) ...[
              const SizedBox(width: Space.s4),
              HankoStamp(animate: !MediaQuery.disableAnimationsOf(context)),
            ],
          ],
        ),
        const SizedBox(height: Space.s2),
        if (s.savingsGoal > 0)
          Text(
            s.goalMet
                ? 'Goal of ${money.formatCents(s.savingsGoal, hideZeroDecimals: true)} reached.'
                : '${money.formatCents(s.missedBy, hideZeroDecimals: true)} short of your '
                      '${money.formatCents(s.savingsGoal, hideZeroDecimals: true)} goal.',
            style: context.text.bodyMedium?.copyWith(color: s.goalMet ? c.success : c.ink2),
          ),
        if (!s.goalMet && s.savingsGoal > 0) ...[
          const SizedBox(height: Space.s4),
          // FR-59: suggest, never force.
          Container(
            padding: const EdgeInsets.all(Space.s4),
            decoration: BoxDecoration(
              color: c.surfaceSunken,
              borderRadius: BorderRadius.circular(Radii.md),
            ),
            child: Text(
              [
                if (overshoot != null)
                  '${pillarName(overshoot.pillarId)} went '
                      '${money.formatCents(overshoot.overBy, hideZeroDecimals: true)} over its plan.',
                if (s.suggestedGoal != null)
                  'Next month you could try a goal of '
                      '${money.formatCents(s.suggestedGoal!, hideZeroDecimals: true)}'
                      '${overshoot != null ? ', or a smaller ${pillarName(overshoot.pillarId)} budget' : ''}.'
                else if (overshoot != null)
                  'A smaller ${pillarName(overshoot.pillarId)} budget next month could help.',
                "It's only a suggestion. You choose.",
              ].join(' '),
              style: context.text.bodyMedium,
            ),
          ),
        ],
        const SizedBox(height: Space.s6),
        _Line(label: 'Income', cents: s.income),
        _Line(label: 'Fixed costs', cents: s.fixed, minus: true),
        _Line(label: 'Spent', cents: s.spent, minus: true),
        const Divider(height: Space.s5),
        _Line(label: 'Left over', cents: s.savedAmount, strong: true),
        const SizedBox(height: Space.s5),
        Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(Space.s3, Space.s2, Space.s3, Space.s2),
            child: Column(
              children: [
                for (final p in pillars)
                  PillarBar(
                    pillarId: p.id,
                    name: p.name,
                    spentCents: s.spentByPillar[p.id] ?? 0,
                    plannedCents: s.plannedByPillar[p.id] ?? 0,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.label, required this.cents, this.strong = false, this.minus = false});

  final String label;
  final int cents;
  final bool strong;

  /// Shows a neutral minus sign; costs are not warnings, so no red.
  final bool minus;

  @override
  Widget build(BuildContext context) {
    final style = strong ? context.text.titleMedium : context.text.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Space.s1),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          if (minus) Text('− ', style: style?.copyWith(color: context.colors.ink2)),
          MoneyText(cents, style: style, hideZeroDecimals: true),
        ],
      ),
    );
  }
}

class _QuestionPage extends StatelessWidget {
  const _QuestionPage({
    required this.number,
    required this.question,
    required this.controller,
    this.why,
    this.hint,
    this.maxLength,
    this.footer,
    this.extra,
  });

  final int number;
  final String question;
  final TextEditingController controller;
  final String? why;
  final String? hint;
  final int? maxLength;
  final String? footer;
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ListView(
      padding: const EdgeInsets.fromLTRB(Space.gutter, Space.s6, Space.gutter, Space.s6),
      children: [
        Text('Question $number of 4', style: context.text.labelLarge?.copyWith(color: c.ink3)),
        const SizedBox(height: Space.s3),
        Semantics(header: true, child: Text(question, style: context.text.headlineSmall)),
        if (why != null) ...[
          const SizedBox(height: Space.s4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(Symbols.lightbulb_rounded, size: IconSizes.sm, color: c.ink3),
              ),
              const SizedBox(width: Space.s2),
              Expanded(child: Text(why!, style: context.text.bodySmall)),
            ],
          ),
        ],
        if (extra != null) ...[const SizedBox(height: Space.s5), extra!],
        const SizedBox(height: Space.s6),
        TextField(
          controller: controller,
          minLines: 4,
          maxLines: null,
          maxLength: maxLength,
          textCapitalization: TextCapitalization.sentences,
          style: context.moneyText.reflection,
          decoration: InputDecoration(hintText: hint ?? 'Write as much or as little as you like'),
        ),
        if (footer != null) ...[
          const SizedBox(height: Space.s2),
          Text(footer!, style: context.text.bodySmall),
        ],
      ],
    );
  }
}

/// FR-53: what was tagged Regret and Worth it this month.
class _MoodLists extends ConsumerWidget {
  const _MoodLists({required this.summary});

  final ReflectionSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pillars = ref.watch(pillarsProvider).value ?? const <Pillar>[];
    if (summary.regrets.isEmpty && summary.worthIt.isEmpty) {
      return Text(
        'Tip: tag spends as Worth it or Regret when you log them, and they will show here.',
        style: context.text.bodySmall,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (summary.worthIt.isNotEmpty)
          _MoodList(title: 'Worth it', items: summary.worthIt, pillars: pillars, good: true),
        if (summary.worthIt.isNotEmpty && summary.regrets.isNotEmpty)
          const SizedBox(height: Space.s3),
        if (summary.regrets.isNotEmpty)
          _MoodList(title: 'Regret', items: summary.regrets, pillars: pillars, good: false),
      ],
    );
  }
}

class _MoodList extends StatelessWidget {
  const _MoodList({
    required this.title,
    required this.items,
    required this.pillars,
    required this.good,
  });

  final String title;
  final List<Expense> items;
  final List<Pillar> pillars;
  final bool good;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final shown = items.take(5).toList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Space.s4, Space.s3, Space.s4, Space.s3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  good
                      ? Symbols.sentiment_satisfied_rounded
                      : Symbols.sentiment_dissatisfied_rounded,
                  size: IconSizes.sm,
                  color: good ? c.success : c.caution,
                ),
                const SizedBox(width: Space.s2),
                Text(title, style: context.text.titleSmall),
              ],
            ),
            for (final e in shown)
              Padding(
                padding: const EdgeInsets.only(top: Space.s2),
                child: Row(
                  children: [
                    Icon(
                      PillarStyle.icon(e.pillarId),
                      size: 18,
                      color: PillarStyle.color(c, e.pillarId),
                    ),
                    const SizedBox(width: Space.s2),
                    Expanded(
                      child: Text(
                        e.note ?? pillars.where((p) => p.id == e.pillarId).firstOrNull?.name ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.bodyMedium,
                      ),
                    ),
                    MoneyText(e.amount, style: context.text.bodyMedium, hideZeroDecimals: true),
                  ],
                ),
              ),
            if (items.length > shown.length)
              Padding(
                padding: const EdgeInsets.only(top: Space.s2),
                child: Text(
                  'and ${items.length - shown.length} more',
                  style: context.text.bodySmall,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// FR-57: did I keep last month's improvement?
class _KeptPage extends StatelessWidget {
  const _KeptPage({required this.improvement, required this.kept, required this.onChanged});

  final String improvement;
  final ImprovementKept? kept;
  final ValueChanged<ImprovementKept> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ListView(
      padding: const EdgeInsets.fromLTRB(Space.gutter, Space.s6, Space.gutter, Space.s6),
      children: [
        Text('Before the last question', style: context.text.labelLarge?.copyWith(color: c.ink3)),
        const SizedBox(height: Space.s3),
        Semantics(
          header: true,
          child: Text("Did I keep last month's improvement?", style: context.text.headlineSmall),
        ),
        const SizedBox(height: Space.s5),
        Text('“$improvement”', style: context.moneyText.reflection),
        const SizedBox(height: Space.s5),
        SegmentedButton<ImprovementKept>(
          segments: [
            for (final k in ImprovementKept.values) ButtonSegment(value: k, label: Text(k.label)),
          ],
          selected: {?kept},
          emptySelectionAllowed: true,
          showSelectedIcon: false,
          onSelectionChanged: (set) {
            if (set.isNotEmpty) onChanged(set.first);
          },
        ),
        const SizedBox(height: Space.s3),
        Text('Be honest. Partly is still progress.', style: context.text.bodySmall),
      ],
    );
  }
}
