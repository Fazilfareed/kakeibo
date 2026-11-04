import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/kakeibo_colors.dart';
import '../../../app/theme/kakeibo_text.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/money/currency_format.dart';
import '../../../core/money/money_formatter.dart';
import '../../../core/money/money_text.dart';
import '../data/settings_repository.dart';
import '../domain/app_preferences.dart';

/// FR-109: change how the symbol looks. Stored amounts are never converted.
class CurrencyFormatScreen extends ConsumerStatefulWidget {
  const CurrencyFormatScreen({super.key});

  @override
  ConsumerState<CurrencyFormatScreen> createState() => _CurrencyFormatScreenState();
}

class _CurrencyFormatScreenState extends ConsumerState<CurrencyFormatScreen> {
  static const _custom = '__custom__';
  final _customController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final symbol = ref.read(currencyFormatProvider).symbol;
    if (!CurrencyFormat.presets.contains(symbol)) _customController.text = symbol;
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  void _save(CurrencyFormat format) =>
      ref.read(settingsRepositoryProvider).setAll(format.toSettings());

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final format = ref.watch(currencyFormatProvider);
    final isPreset = CurrencyFormat.presets.contains(format.symbol);

    return Scaffold(
      appBar: AppBar(title: const Text('Currency format')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Space.gutter, Space.s2, Space.gutter, Space.s6),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(Space.s5),
              child: Column(
                children: [
                  Text('Preview', style: context.text.bodySmall),
                  const SizedBox(height: Space.s2),
                  MoneyText(1250000, style: context.moneyText.displayMoney),
                  const SizedBox(height: Space.s1),
                  MoneyText(-150000, style: context.moneyText.moneyM),
                ],
              ),
            ),
          ),
          const SizedBox(height: Space.s3),
          Text(
            'This only changes how amounts look. Your money stays in Sri Lankan Rupees and nothing is converted.',
            style: context.text.bodySmall,
          ),
          const SizedBox(height: Space.s5),
          Text('Symbol', style: context.text.titleMedium),
          const SizedBox(height: Space.s2),
          Card(
            child: RadioGroup<String>(
              groupValue: isPreset ? format.symbol : _custom,
              onChanged: (value) {
                if (value == null) return;
                if (value == _custom) {
                  final custom = _customController.text.trim();
                  if (custom.isNotEmpty) _save(format.copyWith(symbol: custom));
                  setState(() {});
                } else {
                  _save(format.copyWith(symbol: value));
                }
              },
              child: Column(
                children: [
                  for (final s in CurrencyFormat.presets)
                    RadioListTile<String>(value: s, title: Text(s)),
                  RadioListTile<String>(
                    value: _custom,
                    title: const Text('Custom'),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: Space.s2),
                      child: TextField(
                        controller: _customController,
                        maxLength: CurrencyFormat.maxCustomLength,
                        decoration: const InputDecoration(
                          labelText: 'Your symbol',
                          helperText: '1–4 characters',
                        ),
                        onChanged: (v) {
                          final t = v.trim();
                          if (t.isNotEmpty) _save(format.copyWith(symbol: t));
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: Space.s5),
          Text('Position', style: context.text.titleMedium),
          const SizedBox(height: Space.s2),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<SymbolPosition>(
              showSelectedIcon: false,
              segments: [
                for (final pos in SymbolPosition.values)
                  ButtonSegment(
                    value: pos,
                    label: Text(
                      MoneyFormatter(format.copyWith(position: pos))
                          .formatCents(10000, hideZeroDecimals: true),
                    ),
                  ),
              ],
              selected: {format.position},
              onSelectionChanged: (s) => _save(format.copyWith(position: s.first)),
            ),
          ),
          const SizedBox(height: Space.s3),
          Card(
            child: SwitchListTile(
              title: const Text('Space between symbol and number'),
              value: format.space,
              onChanged: (v) => _save(format.copyWith(space: v)),
            ),
          ),
          const SizedBox(height: Space.s3),
          Text(
            'Currency code: ${CurrencyFormat.currencyCode}',
            style: context.text.bodySmall?.copyWith(color: c.ink3),
          ),
        ],
      ),
    );
  }
}
