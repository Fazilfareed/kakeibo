import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../app/router.dart';
import '../../../app/theme/kakeibo_colors.dart';
import '../../../app/theme/kakeibo_text.dart';
import '../../../app/theme/tokens.dart';
import '../data/settings_repository.dart';
import '../domain/app_preferences.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final themeMode = ref.watch(themeModeProvider);
    final formatter = ref.watch(moneyFormatterProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(Space.gutter, Space.s3, Space.gutter, 96),
      children: [
        Text('Settings', style: context.text.headlineSmall),
        const SizedBox(height: Space.s5),
        const _SectionLabel('Money'),
        Card(
          child: ListTile(
            leading: const Icon(Symbols.payments_rounded),
            title: const Text('Currency format'),
            subtitle: Text('Sri Lankan Rupee · ${formatter.formatCents(1250000)}'),
            trailing: Icon(Symbols.chevron_right_rounded, color: c.ink3),
            onTap: () => context.push(Routes.currencyFormat),
          ),
        ),
        const SizedBox(height: Space.s5),
        const _SectionLabel('Appearance'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(Space.s4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Theme', style: context.text.titleMedium),
                const SizedBox(height: Space.s3),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<ThemeMode>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(value: ThemeMode.system, label: Text('System'), icon: Icon(Symbols.smartphone_rounded)),
                      ButtonSegment(value: ThemeMode.light, label: Text('Light'), icon: Icon(Symbols.light_mode_rounded)),
                      ButtonSegment(value: ThemeMode.dark, label: Text('Dark'), icon: Icon(Symbols.dark_mode_rounded)),
                    ],
                    selected: {themeMode},
                    onSelectionChanged: (s) => ref
                        .read(settingsRepositoryProvider)
                        .set(themeKey, s.first.name),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: Space.s5),
        const _SectionLabel('About'),
        const Card(
          child: ListTile(
            leading: Icon(Symbols.info_rounded),
            title: Text('Kakeibo'),
            subtitle: Text('Version 0.1.0 · Your data stays on this phone.'),
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: Space.s1, bottom: Space.s2),
      child: Semantics(
        header: true,
        child: Text(text.toUpperCase(),
            style: context.text.labelSmall?.copyWith(letterSpacing: 1.2)),
      ),
    );
  }
}
