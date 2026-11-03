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
import '../../expenses/data/expense_repository.dart';
import '../../expenses/presentation/quick_add_sheet.dart';
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
    final visible =
        filter == null ? expenses : expenses.where((e) => e.pillarId == filter).toList();

    final byDay = <String, List<Expense>>{};
    for (final e in visible) {
      byDay.putIfAbsent(e.date, () => []).add(e);
    }

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(Space.gutter, Space.s3, Space.gutter, 0),
          sliver: SliverToBoxAdapter(
            child: Text('Spends', style: context.text.headlineSmall),
          ),
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
                          _ExpenseRow(
                            expense: e,
                            pillarName: pillars
                                    .where((p) => p.id == e.pillarId)
                                    .firstOrNull
                                    ?.name ??
                                '',
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
              avatar: Icon(PillarStyle.icon(p.id),
                  size: 18, color: selected == p.id ? c.bg : PillarStyle.color(c, p.id)),
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
  bool shouldRebuild(_FilterBar old) =>
      old.selected != selected || old.pillars != pillars;
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
            child: Semantics(
              header: true,
              child: Text(label, style: context.text.labelLarge),
            ),
          ),
          MoneyText(total, style: context.text.bodySmall),
        ],
      ),
    );
  }
}

class _ExpenseRow extends ConsumerWidget {
  const _ExpenseRow({required this.expense, required this.pillarName});

  final Expense expense;
  final String pillarName;

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(expenseRepositoryProvider);
    final messenger = ScaffoldMessenger.of(context);
    await repo.softDelete(expense.id);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(
      content: const Text('Expense deleted'),
      action: SnackBarAction(label: 'Undo', onPressed: () => repo.restore(expense.id)),
    ));
  }

  Future<void> _menu(BuildContext context, WidgetRef ref) async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Symbols.edit_rounded),
              title: const Text('Edit'),
              onTap: () => Navigator.pop(context, 'edit'),
            ),
            ListTile(
              leading: Icon(Symbols.delete_rounded, color: context.colors.over),
              title: Text('Delete', style: TextStyle(color: context.colors.over)),
              onTap: () => Navigator.pop(context, 'delete'),
            ),
          ],
        ),
      ),
    );
    if (!context.mounted) return;
    if (choice == 'edit') showQuickAddSheet(context, editing: expense);
    if (choice == 'delete') _delete(context, ref);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final accent = PillarStyle.color(c, expense.pillarId);
    final mood = Mood.fromName(expense.mood);
    final methods = ref.watch(paymentMethodsProvider).value ?? const <PaymentMethod>[];
    final method = methods.where((m) => m.id == expense.paymentMethodId).firstOrNull;
    final caption = [pillarName, ?method?.name, ?mood?.label].join(' · ');
    final isRefund = expense.type == 'refund';

    return Dismissible(
      key: ValueKey(expense.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: Space.s5),
        color: c.container(c.over),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Delete', style: context.text.labelLarge?.copyWith(color: c.over)),
            const SizedBox(width: Space.s2),
            Icon(Symbols.delete_rounded, color: c.over),
          ],
        ),
      ),
      onDismissed: (_) => _delete(context, ref),
      child: InkWell(
        onTap: () => showQuickAddSheet(context, editing: expense),
        onLongPress: () => _menu(context, ref),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 64),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Space.s4, vertical: Space.s3),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: c.container(accent)),
                  child: Icon(PillarStyle.icon(expense.pillarId), size: 20, color: accent),
                ),
                const SizedBox(width: Space.s3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(expense.note ?? pillarName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.bodyLarge),
                      Text(caption,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.bodySmall),
                    ],
                  ),
                ),
                const SizedBox(width: Space.s2),
                MoneyText(isRefund ? -expense.amount : expense.amount,
                    style: context.text.titleMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
