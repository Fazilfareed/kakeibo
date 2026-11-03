import 'package:flutter/material.dart';

import '../../app/theme/kakeibo_colors.dart';
import '../../app/theme/kakeibo_text.dart';
import '../../app/theme/tokens.dart';

/// Icon, title, one line of guidance and an optional action (MASTER.md §7.13).
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Space.s5, vertical: Space.s6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ExcludeSemantics(child: Icon(icon, size: IconSizes.xl, color: c.ink3)),
          const SizedBox(height: Space.s4),
          Text(title, style: context.text.titleLarge, textAlign: TextAlign.center),
          const SizedBox(height: Space.s2),
          Text(
            message,
            style: context.text.bodyMedium?.copyWith(color: c.ink2),
            textAlign: TextAlign.center,
          ),
          if (action != null) ...[
            const SizedBox(height: Space.s5),
            action!,
          ],
        ],
      ),
    );
  }
}
