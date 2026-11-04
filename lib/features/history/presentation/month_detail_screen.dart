import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../app/router.dart';
import '../../../app/theme/kakeibo_colors.dart';
import '../../../app/theme/kakeibo_text.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/date/local_date.dart';
import '../../../core/db/app_database.dart';
import '../../../core/money/money_text.dart';
import '../../../core/pillars/pillars_provider.dart';
import '../../dashboard/presentation/widgets/pillar_bar.dart';
import '../../dashboard/presentation/widgets/savings_ring.dart';
import '../../reflection/data/reflection_providers.dart';
import '../../reflection/domain/reflection_summary.dart';
import '../../settings/domain/app_preferences.dart';

/// One past month (S10): totals, the plan by pillar, and the reflection
/// answers (FR-55). Shows "Edited after close" when spends changed after the
/// reflection froze the month (FR-58).
class MonthDetailScreen extends ConsumerWidget {
  const MonthDetailScreen({super.key, required this.periodId});

  final int periodId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(reflectionSummaryProvider(periodId)).value;
    final title = summary == null
        ? ''
        : DateFormat('MMMM yyyy').format(LocalDate.parse(summary.period.startDate));
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: summary == null ? const SizedBox.shrink() : _Body(s: summary),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.s});

  final ReflectionSummary s;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final money = ref.watch(moneyFormatterProvider);
    final pillars = ref.watch(pillarsProvider).value ?? const <Pillar>[];
    final r = s.saved;
    final done = r?.completedAt != null;
    final edited = r?.editedAfterClose ?? 0;
    final kept = ImprovementKept.fromName(r?.prevImprovementKept);
    final fmt = DateFormat('d MMM');

    return ListView(
      padding: const EdgeInsets.fromLTRB(Space.gutter, Space.s4, Space.gutter, Space.s7),
      children: [
        Text(
          '${fmt.format(LocalDate.parse(s.period.startDate))} – '
          '${fmt.format(LocalDate.parse(s.period.endDate))}',
          style: context.text.bodySmall,
        ),
        const SizedBox(height: Space.s2),
        Text(
          s.savedAmount >= 0 ? 'Saved' : 'Spent more than earned by',
          style: context.text.bodyMedium,
        ),
        Row(
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
            if (s.goalMet) ...[const SizedBox(width: Space.s4), const HankoStamp(animate: false)],
          ],
        ),
        if (s.savingsGoal > 0)
          Text(
            s.goalMet
                ? 'Goal of ${money.formatCents(s.savingsGoal, hideZeroDecimals: true)} met.'
                : '${money.formatCents(s.missedBy, hideZeroDecimals: true)} short of the '
                      '${money.formatCents(s.savingsGoal, hideZeroDecimals: true)} goal.',
            style: context.text.bodyMedium?.copyWith(color: s.goalMet ? c.success : c.ink2),
          ),
        if (done && edited != 0) ...[
          const SizedBox(height: Space.s2),
          Row(
            children: [
              Icon(Symbols.edit_note_rounded, size: IconSizes.sm, color: c.ink3),
              const SizedBox(width: Space.s1),
              Expanded(
                child: Text(
                  'Edited after close: ${edited > 0 ? '+' : '−'}'
                  '${money.formatCents(edited.abs(), hideZeroDecimals: true)} of spending. '
                  'The saved amount above is from the reflection.',
                  style: context.text.bodySmall,
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: Space.s5),
        _Row(label: 'Income', cents: s.income),
        _Row(label: 'Fixed costs', cents: s.fixed, minus: true),
        _Row(label: 'Spent', cents: s.spent, minus: true),
        if (s.savingsGoal > 0) _Row(label: 'Savings goal', cents: s.savingsGoal),
        const SizedBox(height: Space.s4),
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
        const SizedBox(height: Space.s6),
        Semantics(header: true, child: Text('Reflection', style: context.text.titleLarge)),
        const SizedBox(height: Space.s3),
        if (!done) ...[
          Text("This month's reflection isn't finished yet.", style: context.text.bodyMedium),
          const SizedBox(height: Space.s3),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton(
              onPressed: () => context.push(Routes.reflect(s.period.id)),
              child: Text(r == null ? 'Start reflection' : 'Continue reflection'),
            ),
          ),
        ] else ...[
          _Answer(question: ReflectionQuestions.q1, answer: r!.answerQ1),
          _Answer(question: ReflectionQuestions.q2, answer: r.answerQ2),
          _Answer(question: ReflectionQuestions.q3, answer: r.answerQ3),
          if (kept != null && s.previousImprovement != null)
            _Answer(question: 'Did I keep "${s.previousImprovement}"?', answer: kept.label),
          _Answer(question: ReflectionQuestions.q4, answer: r.improvement),
        ],
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.cents, this.minus = false});

  final String label;
  final int cents;
  final bool minus;

  @override
  Widget build(BuildContext context) {
    final style = context.text.bodyMedium;
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

class _Answer extends StatelessWidget {
  const _Answer({required this.question, required this.answer});

  final String question;
  final String? answer;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: Space.s5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question, style: context.text.titleSmall?.copyWith(color: c.ink2)),
          const SizedBox(height: Space.s1),
          Text(
            answer ?? 'No answer',
            style: answer == null
                ? context.text.bodyMedium?.copyWith(color: c.ink3)
                : context.moneyText.reflection,
          ),
        ],
      ),
    );
  }
}
