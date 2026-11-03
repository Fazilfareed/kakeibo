import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../app/theme/kakeibo_text.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/widgets/empty_state.dart';

/// Spends list, grouped by day (built in M1).
class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(Space.gutter, Space.s3, Space.gutter, 96),
      children: [
        Text('Spends', style: context.text.headlineSmall),
        const SizedBox(height: Space.s7),
        const EmptyState(
          icon: Symbols.receipt_long_rounded,
          title: 'No expenses yet',
          message: 'Tap + to log your first one.',
        ),
      ],
    );
  }
}
