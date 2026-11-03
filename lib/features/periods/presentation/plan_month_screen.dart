import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../app/theme/kakeibo_colors.dart';
import '../../../app/theme/kakeibo_text.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/money/amount_input.dart';
import '../../../core/money/money_field.dart';
import '../../../core/money/money_text.dart';
import '../../../core/pillars/pillar_style.dart';
import '../../../core/pillars/pillars_provider.dart';
import '../data/period_providers.dart';
import '../data/period_repository.dart';

/// Kakeibo questions 1 & 2: how much do I have, how much will I save?
/// (PRD FR-10 – FR-16, MASTER.md §8).
class PlanMonthScreen extends ConsumerStatefulWidget {
  const PlanMonthScreen({super.key});

  @override
  ConsumerState<PlanMonthScreen> createState() => _PlanMonthScreenState();
}

class _Row {
  _Row({String label = '', int cents = 0, this.recurring = true})
      : label = TextEditingController(text: label),
        amount = TextEditingController(text: MoneyField.textFor(cents));

  final TextEditingController label;
  final TextEditingController amount;
  bool recurring;

  int get cents => AmountInput.parseCents(amount.text) ?? 0;

  void dispose() {
    label.dispose();
    amount.dispose();
  }
}

class _PlanMonthScreenState extends ConsumerState<PlanMonthScreen> {
  PeriodPlan? _plan;
  final List<_Row> _incomes = [];
  final List<_Row> _fixed = [];
  final _savings = TextEditingController();
  final Map<int, TextEditingController> _budgets = {
    for (final id in [1, 2, 3, 4]) id: TextEditingController(),
  };
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = ref.read(periodRepositoryProvider);
    final period = await repo.ensureCurrentPeriod();
    final plan = await repo.loadPlan(period.id);
    if (!mounted) return;
    setState(() {
      _plan = plan;
      final planned = plan.incomes.where((i) => i.isPlanned).toList();
      _incomes.addAll(planned.isEmpty
          ? [_Row(label: 'Salary')]
          : planned.map((i) => _Row(label: i.label, cents: i.amount)));
      _fixed.addAll(plan.fixedCosts.isEmpty
          ? [_Row(label: 'Rent')]
          : plan.fixedCosts
              .map((f) => _Row(label: f.label, cents: f.amount, recurring: f.isRecurring)));
      _savings.text = MoneyField.textFor(plan.period.savingsGoal);
      for (final e in _budgets.entries) {
        e.value.text = MoneyField.textFor(plan.budgets[e.key] ?? 0);
      }
    });
  }

  @override
  void dispose() {
    for (final r in [..._incomes, ..._fixed]) {
      r.dispose();
    }
    _savings.dispose();
    for (final c in _budgets.values) {
      c.dispose();
    }
    super.dispose();
  }

  int get _incomeTotal => _incomes.fold(0, (a, r) => a + r.cents);
  int get _fixedTotal => _fixed.fold(0, (a, r) => a + r.cents);
  int get _savingsGoal => AmountInput.parseCents(_savings.text) ?? 0;
  int get _spendable => _incomeTotal - _fixedTotal - _savingsGoal;
  int get _budgetTotal =>
      _budgets.values.fold(0, (a, c) => a + (AmountInput.parseCents(c.text) ?? 0));

  void _refresh([String? _]) => setState(() {});

  /// FR-15 helper: split spendable evenly across the four pillars.
  void _splitEvenly() {
    final spendable = _spendable;
    if (spendable <= 0) return;
    final share = spendable ~/ 4;
    final remainder = spendable - share * 4;
    setState(() {
      for (final id in [1, 2, 3, 4]) {
        _budgets[id]!.text = MoneyField.textFor(share + (id == 1 ? remainder : 0));
      }
    });
  }

  Future<void> _save() async {
    final plan = _plan;
    if (plan == null) return;
    setState(() => _saving = true);
    String labelOr(_Row r, String fallback) =>
        r.label.text.trim().isEmpty ? fallback : r.label.text.trim();
    final draft = PlanDraft(
      incomes: [
        for (final r in _incomes)
          if (r.cents > 0) (label: labelOr(r, 'Income'), amount: r.cents),
      ],
      fixedCosts: [
        for (final r in _fixed)
          if (r.cents > 0)
            (label: labelOr(r, 'Fixed cost'), amount: r.cents, recurring: r.recurring),
      ],
      savingsGoal: _savingsGoal,
      budgets: {
        for (final e in _budgets.entries) e.key: AmountInput.parseCents(e.value.text) ?? 0,
      },
    );
    await ref.read(periodRepositoryProvider).savePlan(plan.period.id, draft);
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Plan saved. Have a mindful month.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final plan = _plan;
    final range = plan?.range;
    final fmt = DateFormat('d MMM');

    return Scaffold(
      appBar: AppBar(title: const Text('Plan your month')),
      body: plan == null
          ? const SizedBox.shrink()
          : Column(
              children: [
                _SpendableHeader(
                  income: _incomeTotal,
                  fixed: _fixedTotal,
                  savings: _savingsGoal,
                  subtitle: '${fmt.format(range!.start)} – ${fmt.format(range.end)}',
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                        Space.gutter, Space.s4, Space.gutter, Space.s6),
                    children: [
                      _Section(
                        number: 1,
                        title: 'How much money do I have?',
                        hint: 'Take-home income for this month.',
                        child: _RowList(
                          rows: _incomes,
                          addLabel: 'Add income',
                          onChanged: _refresh,
                          onAdd: () => setState(() => _incomes.add(_Row())),
                          onRemove: (r) => setState(() => _incomes.remove(r..dispose())),
                        ),
                      ),
                      _Section(
                        title: 'Fixed costs',
                        hint: 'Bills that are the same every month, like rent, '
                            'loans and subscriptions. They are not logged as spends.',
                        child: _RowList(
                          rows: _fixed,
                          addLabel: 'Add fixed cost',
                          showRecurring: true,
                          onChanged: _refresh,
                          onAdd: () => setState(() => _fixed.add(_Row())),
                          onRemove: (r) => setState(() => _fixed.remove(r..dispose())),
                        ),
                      ),
                      _Section(
                        number: 2,
                        title: 'How much would I like to save?',
                        hint: 'Decide before you spend. Keep it realistic.',
                        child: MoneyField(
                          controller: _savings,
                          label: 'Savings goal',
                          onChanged: _refresh,
                        ),
                      ),
                      _Section(
                        title: 'Split across the four pillars',
                        hint: 'Optional. A rough guide for each kind of spending.',
                        trailing: TextButton(
                          onPressed: _spendable > 0 ? _splitEvenly : null,
                          child: const Text('Split evenly'),
                        ),
                        child: _BudgetFields(
                          controllers: _budgets,
                          spendable: _spendable,
                          assigned: _budgetTotal,
                          onChanged: _refresh,
                        ),
                      ),
                    ],
                  ),
                ),
                SafeArea(
                  top: false,
                  minimum: const EdgeInsets.fromLTRB(
                      Space.gutter, Space.s2, Space.gutter, Space.s3),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _saving ? null : _save,
                      child: Text(plan.period.status == 'planning' ? 'Start my month' : 'Save plan'),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

/// Sticky live summary: Spendable = Income − Fixed − Savings (FR-14).
class _SpendableHeader extends StatelessWidget {
  const _SpendableHeader({
    required this.income,
    required this.fixed,
    required this.savings,
    required this.subtitle,
  });

  final int income;
  final int fixed;
  final int savings;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final spendable = income - fixed - savings;
    Widget line(String label, int cents, {String sign = ''}) => Row(
          children: [
            Expanded(child: Text(label, style: context.text.bodySmall)),
            Text(sign, style: context.text.bodySmall),
            MoneyText(cents, style: context.text.bodySmall, hideZeroDecimals: true),
          ],
        );
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(bottom: BorderSide(color: c.divider)),
      ),
      padding: const EdgeInsets.fromLTRB(Space.gutter, Space.s3, Space.gutter, Space.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(subtitle, style: context.text.bodySmall),
          const SizedBox(height: Space.s1),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: Text('Spendable', style: context.text.titleMedium)),
              MoneyText(spendable, style: context.moneyText.moneyM, hideZeroDecimals: true),
            ],
          ),
          const SizedBox(height: Space.s2),
          line('Income', income),
          line('Fixed costs', fixed, sign: '− '),
          line('Savings goal', savings, sign: '− '),
          if (spendable < 0) ...[
            const SizedBox(height: Space.s2),
            Row(
              children: [
                Icon(Symbols.warning_rounded, size: IconSizes.sm, color: c.caution),
                const SizedBox(width: Space.s1),
                Expanded(
                  child: Text(
                    'Your savings goal is more than what is left after fixed costs.',
                    style: context.text.bodySmall?.copyWith(color: c.caution),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    this.number,
    required this.title,
    required this.hint,
    required this.child,
    this.trailing,
  });

  final int? number;
  final String title;
  final String hint;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: Space.s6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (number != null) ...[
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: c.seal, width: 1.5),
                  ),
                  child: Text('$number',
                      style: context.text.labelLarge?.copyWith(color: c.seal)),
                ),
                const SizedBox(width: Space.s3),
              ],
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(title, style: context.text.titleLarge),
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: Space.s1),
          Text(hint, style: context.text.bodySmall),
          const SizedBox(height: Space.s3),
          child,
        ],
      ),
    );
  }
}

class _RowList extends StatelessWidget {
  const _RowList({
    required this.rows,
    required this.addLabel,
    required this.onChanged,
    required this.onAdd,
    required this.onRemove,
    this.showRecurring = false,
  });

  final List<_Row> rows;
  final String addLabel;
  final ValueChanged<String> onChanged;
  final VoidCallback onAdd;
  final ValueChanged<_Row> onRemove;
  final bool showRecurring;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      children: [
        for (final r in rows)
          Padding(
            padding: const EdgeInsets.only(bottom: Space.s3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: TextField(
                    controller: r.label,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                ),
                const SizedBox(width: Space.s2),
                Expanded(
                  flex: 5,
                  child: MoneyField(controller: r.amount, label: 'Amount', onChanged: onChanged),
                ),
                IconButton(
                  tooltip: 'Remove',
                  onPressed: () => onRemove(r),
                  icon: Icon(Symbols.close_rounded, color: c.ink3),
                ),
              ],
            ),
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: onAdd,
            icon: const Icon(Symbols.add_rounded),
            label: Text(addLabel),
          ),
        ),
        if (showRecurring && rows.isNotEmpty)
          Text('Fixed costs are copied to next month automatically.',
              style: context.text.bodySmall),
      ],
    );
  }
}

class _BudgetFields extends ConsumerWidget {
  const _BudgetFields({
    required this.controllers,
    required this.spendable,
    required this.assigned,
    required this.onChanged,
  });

  final Map<int, TextEditingController> controllers;
  final int spendable;
  final int assigned;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final pillars = ref.watch(pillarsProvider).value ?? const [];
    final diff = spendable - assigned;
    return Column(
      children: [
        for (final p in pillars)
          Padding(
            padding: const EdgeInsets.only(bottom: Space.s3),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: c.container(PillarStyle.color(c, p.id)),
                  ),
                  child: Icon(PillarStyle.icon(p.id),
                      size: 20, color: PillarStyle.color(c, p.id)),
                ),
                const SizedBox(width: Space.s3),
                Expanded(flex: 4, child: Text(p.name, style: context.text.titleMedium)),
                Expanded(
                  flex: 5,
                  child: MoneyField(controller: controllers[p.id]!, onChanged: onChanged),
                ),
              ],
            ),
          ),
        if (assigned > 0 && diff != 0)
          Row(
            children: [
              Icon(Symbols.info_rounded, size: IconSizes.sm, color: c.ink3),
              const SizedBox(width: Space.s1),
              MoneyText(diff.abs(), style: context.text.bodySmall, hideZeroDecimals: true),
              Text(diff > 0 ? ' unassigned' : ' over-assigned',
                  style: context.text.bodySmall),
            ],
          ),
      ],
    );
  }
}
