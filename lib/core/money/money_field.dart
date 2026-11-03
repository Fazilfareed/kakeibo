import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/kakeibo_colors.dart';
import '../../app/theme/kakeibo_text.dart';
import '../../features/settings/domain/app_preferences.dart';
import 'amount_input.dart';
import 'currency_format.dart';

/// Right-aligned amount text field with the user's currency symbol
/// (MASTER.md §7.9). Read the value with [AmountInput.parseCents].
class MoneyField extends ConsumerWidget {
  const MoneyField({
    super.key,
    required this.controller,
    this.label,
    this.onChanged,
    this.textInputAction = TextInputAction.next,
  });

  final TextEditingController controller;
  final String? label;
  final ValueChanged<String>? onChanged;
  final TextInputAction textInputAction;

  /// Text for an existing cents value (empty for zero).
  static String textFor(int cents) {
    if (cents == 0) return '';
    final input = AmountInput.fromCents(cents);
    return input.raw;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final format = ref.watch(currencyFormatProvider);
    final symbol = Text(format.symbol,
        style: context.text.bodyMedium?.copyWith(color: context.colors.ink2));
    return TextField(
      controller: controller,
      textAlign: TextAlign.right,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: textInputAction,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
        TextInputFormatter.withFunction((oldValue, newValue) =>
            AmountInput.parseCents(newValue.text) != null || newValue.text.isEmpty
                ? newValue
                : oldValue),
      ],
      style: context.moneyText.moneyM.copyWith(fontSize: 18),
      decoration: InputDecoration(
        labelText: label,
        hintText: '0',
        prefix: format.position == SymbolPosition.before ? symbol : null,
        suffix: format.position == SymbolPosition.after ? symbol : null,
      ),
      onChanged: onChanged,
    );
  }
}
