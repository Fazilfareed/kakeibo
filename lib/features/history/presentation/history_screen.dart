import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../app/theme/kakeibo_text.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/widgets/empty_state.dart';

/// Past months and trends (built in M4).
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(Space.gutter, Space.s3, Space.gutter, 96),
      children: [
        Text('History', style: context.text.headlineSmall),
        const SizedBox(height: Space.s7),
        const EmptyState(
          icon: Symbols.trending_up_rounded,
          title: 'No months yet',
          message: 'Your first month review will appear here.',
        ),
      ],
    );
  }
}
