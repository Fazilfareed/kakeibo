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
import '../../../core/widgets/empty_state.dart';
import '../../expenses/data/expense_providers.dart';
import '../../expenses/presentation/expense_tile.dart';
import '../../periods/data/period_providers.dart';

/// Pillar filter on the Spends tab (null = all).
final spendsFilterProvider = NotifierProvider<_Filter, int?>(_Filter.new);

class _Filter extends Notifier<int?> {
  @override
  int? build() => null;

  // ignore: use_setters_to_change_properties
  void set(int? pillarId) => state = pillarId;
}

/// This month's spends, grouped by day (MASTER.md §7.10).
class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(currentPeriodProvider).value;
    final filter = ref.watch(spendsFilterProvider);
    final pillars = ref.watch(pillarsProvider).value ?? const <Pillar>[];
    final expenses = period == null
        ? const <Expense>[]
        : ref.watch(periodExpensesProvider(period.id)).value ?? const <Expense>[];
    final visible = filter == null
        ? expenses
        : expenses.where((e) => e.pillarId == filter).toList();

    final byDay = <String, List<Expense>>{};
    for (final e in visible) {
      byDay.putIfAbsent(e.date, () => []).add(e);
    }

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(Space.gutter, Space.s3, Space.gutter, 0),
          sliver: SliverToBoxAdapter(child: Text('Spends', style: context.text.headlineSmall)),
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: _FilterBar(pillars: pillars, selected: filter, ref: ref),
        ),
        if (visible.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Align(
              alignment: const Alignment(0, -0.4),
              child: EmptyState(
                icon: Symbols.receipt_long_rounded,
                title: filter == null ? 'No expenses yet' : 'Nothing in this pillar',
                message: filter == null
                    ? 'Tap + to log your first one.'
                    : 'Spends in this pillar this month will show here.',
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(Space.gutter, 0, Space.gutter, 96),
            sliver: SliverList.list(
              children: [
                for (final day in byDay.entries) ...[
                  _DayHeader(date: day.key, items: day.value),
                  Card(
                    child: Column(
                      children: [
                        for (final (i, e) in day.value.indexed) ...[
                          if (i > 0) const Divider(indent: 68),
                          ExpenseTile(
                            expense: e,
                            pillarName:
                                pillars.where((p) => p.id == e.pillarId).firstOrNull?.name ?? '',
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _FilterBar extends SliverPersistentHeaderDelegate {
  _FilterBar({required this.pillars, required this.selected, required this.ref});

  final List<Pillar> pillars;
  final int? selected;
  final WidgetRef ref;

  @override
  double get minExtent => 60;
  @override
  double get maxExtent => 60;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final c = context.colors;
    void pick(int? id) => ref.read(spendsFilterProvider.notifier).set(id);
    return Container(
      color: c.bg,
      alignment: Alignment.centerLeft,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: Space.gutter, vertical: Space.s2),
        children: [
          ChoiceChip(
            label: const Text('All'),
            selected: selected == null,
            showCheckmark: false,
            onSelected: (_) => pick(null),
          ),
          for (final p in pillars) ...[
            const SizedBox(width: Space.s2),
            ChoiceChip(
              avatar: Icon(
                PillarStyle.icon(p.id),
                size: 18,
                color: selected == p.id ? c.bg : PillarStyle.color(c, p.id),
              ),
              label: Text(p.name),
              selected: selected == p.id,
              showCheckmark: false,
              onSelected: (s) => pick(s ? p.id : null),
            ),
          ],
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_FilterBar old) => old.selected != selected || old.pillars != pillars;
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.date, required this.items});

  final String date;
  final List<Expense> items;

  @override
  Widget build(BuildContext context) {
    final day = LocalDate.parse(date);
    final today = LocalDate.dateOnly(DateTime.now());
    final label = day == today
        ? 'Today'
        : day == today.subtract(const Duration(days: 1))
        ? 'Yesterday'
        : DateFormat('EEE, d MMM').format(day);
    final total = items.fold(0, (a, e) => a + (e.type == 'refund' ? -e.amount : e.amount));
    return Padding(
      padding: const EdgeInsets.fromLTRB(Space.s1, Space.s4, Space.s1, Space.s2),
      child: Row(
        children: [
          Expanded(
            child: Semantics(header: true, child: Text(label, style: context.text.labelLarge)),
          ),
          MoneyText(total, style: context.text.bodySmall),
        ],
      ),
    );
  }
}
