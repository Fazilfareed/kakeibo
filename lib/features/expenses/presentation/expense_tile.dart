import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../app/theme/kakeibo_colors.dart';
import '../../../app/theme/kakeibo_text.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/db/app_database.dart';
import '../../../core/money/money_text.dart';
import '../../../core/pillars/pillar_style.dart';
import '../data/expense_providers.dart';
import '../data/expense_repository.dart';
import 'quick_add_sheet.dart';

/// One spend: tap to edit, swipe left or long-press to delete with undo.
/// Used on the Spends tab and in Home's recent list.
class ExpenseTile extends ConsumerWidget {
  const ExpenseTile({super.key, required this.expense, required this.pillarName});

  final Expense expense;
  final String pillarName;

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(expenseRepositoryProvider);
    final messenger = ScaffoldMessenger.of(context);
    await repo.softDelete(expense.id);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: const Text('Expense deleted'),
        // Snack bars with an action persist by default; Undo lasts 4 s (MASTER.md §7.11).
        persist: false,
        action: SnackBarAction(label: 'Undo', onPressed: () => repo.restore(expense.id)),
      ),
    );
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
    // Without a note the title is already the pillar name, so don't repeat it.
    final caption = [if (expense.note != null) pillarName, ?method?.name, ?mood?.label].join(' · ');
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
                      Text(
                        expense.note ?? pillarName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.bodyLarge,
                      ),
                      if (caption.isNotEmpty)
                        Text(
                          caption,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.bodySmall,
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: Space.s2),
                MoneyText(
                  isRefund ? -expense.amount : expense.amount,
                  style: context.text.titleMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
