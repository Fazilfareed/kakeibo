import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/kakeibo_colors.dart';
import '../../../app/theme/kakeibo_text.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/db/app_database.dart';
import '../../../core/money/money_text.dart';
import '../../../core/pillars/pillar_style.dart';
import '../../../core/pillars/pillars_provider.dart';
import '../../periods/data/period_providers.dart';
import '../data/checkin_providers.dart';

/// Weekly check-in (PRD §6.5, S7): this week by pillar, then one short note.
class CheckinScreen extends ConsumerStatefulWidget {
  const CheckinScreen({super.key});

  @override
  ConsumerState<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends ConsumerState<CheckinScreen> {
  final _note = TextEditingController();
  bool _loadedNote = false;
  bool _saving = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _save(int periodId, DateTime weekStart) async {
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    await ref.read(checkinRepositoryProvider).save(periodId, weekStart, _note.text);
    navigator.pop();
    messenger.removeCurrentSnackBar();
    messenger.showSnackBar(const SnackBar(content: Text('Check-in saved. See you next week.')));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final period = ref.watch(currentPeriodProvider).value;
    final summary = ref.watch(currentSummaryProvider);
    final week = ref.watch(currentWeekProvider);
    final totals = ref.watch(currentWeekTotalsProvider).value ?? const <int, int>{};
    final existing = ref.watch(currentCheckinProvider);
    final pillars = ref.watch(pillarsProvider).value ?? const <Pillar>[];

    if (!_loadedNote && existing.hasValue) {
      _loadedNote = true;
      _note.text = existing.value?.note ?? '';
    }

    final ready = period != null && summary != null && week != null;
    final fmt = DateFormat('d MMM');
    final weekTotal = totals.values.fold(0, (a, b) => a + b);

    return Scaffold(
      appBar: AppBar(title: const Text('Weekly check-in')),
      body: !ready
          ? const SizedBox.shrink()
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      Space.gutter,
                      Space.s4,
                      Space.gutter,
                      Space.s6,
                    ),
                    children: [
                      Text(
                        week.start == week.end
                            ? fmt.format(week.start)
                            : '${fmt.format(week.start)} – ${fmt.format(week.end)}',
                        style: context.text.bodySmall,
                      ),
                      const SizedBox(height: Space.s1),
                      Text('This week you spent', style: context.text.bodyMedium),
                      MoneyText(
                        weekTotal,
                        style: context.moneyText.displayMoney,
                        hideZeroDecimals: true,
                      ),
                      const SizedBox(height: Space.s1),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          MoneyText(
                            summary.remaining.abs(),
                            style: context.text.bodySmall?.copyWith(color: c.ink),
                            hideZeroDecimals: true,
                          ),
                          Text(
                            '${summary.remaining < 0 ? ' over' : ' left'} this month · '
                            '${summary.daysLeft} '
                            '${summary.daysLeft == 1 ? 'day' : 'days'} to go',
                            style: context.text.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: Space.s5),
                      Card(
                        child: Column(
                          children: [
                            for (final (i, p) in pillars.indexed) ...[
                              if (i > 0) const Divider(indent: 56),
                              _PillarWeekRow(pillar: p, cents: totals[p.id] ?? 0),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: Space.s6),
                      Semantics(
                        header: true,
                        child: Text(
                          'Are you on track? One thing to watch this week?',
                          style: context.text.titleLarge,
                        ),
                      ),
                      const SizedBox(height: Space.s3),
                      TextField(
                        controller: _note,
                        minLines: 3,
                        maxLines: null,
                        maxLength: 200,
                        textCapitalization: TextCapitalization.sentences,
                        style: context.moneyText.reflection,
                        decoration: const InputDecoration(
                          hintText: 'For example: on track, but watch eating out',
                        ),
                      ),
                    ],
                  ),
                ),
                SafeArea(
                  top: false,
                  minimum: const EdgeInsets.fromLTRB(
                    Space.gutter,
                    Space.s2,
                    Space.gutter,
                    Space.s3,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _saving ? null : () => _save(period.id, week.start),
                      child: Text(existing.value == null ? 'Save check-in' : 'Update check-in'),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _PillarWeekRow extends StatelessWidget {
  const _PillarWeekRow({required this.pillar, required this.cents});

  final Pillar pillar;
  final int cents;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final accent = PillarStyle.color(c, pillar.id);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Space.s4, vertical: Space.s3),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(shape: BoxShape.circle, color: c.container(accent)),
            child: Icon(PillarStyle.icon(pillar.id), size: 18, color: accent),
          ),
          const SizedBox(width: Space.s3),
          Expanded(child: Text(pillar.name, style: context.text.bodyLarge)),
          MoneyText(cents, style: context.text.titleMedium, hideZeroDecimals: true),
        ],
      ),
    );
  }
}
