import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../app/theme/kakeibo_text.dart';
import '../../../app/theme/tokens.dart';
import '../../settings/data/settings_repository.dart';
import '../data/lock_providers.dart';
import 'lock_screen.dart';
import 'pin_setup_flow.dart';

/// Settings → Security (FR-06–08): app lock, fingerprint, lock timing and
/// changing the PIN. Turning the lock off or changing the PIN asks for it
/// first.
class SecuritySettingsCard extends ConsumerWidget {
  const SecuritySettingsCard({super.key});

  static Future<bool> _verify(BuildContext context) async {
    final ok = await Navigator.of(context, rootNavigator: true).push<bool>(
      MaterialPageRoute(
        builder: (context) =>
            LockScreen(verifyOnly: true, onUnlocked: () => Navigator.pop(context, true)),
      ),
    );
    return ok ?? false;
  }

  static Future<bool> _setUp(BuildContext context, {required bool changing}) async {
    final ok = await Navigator.of(context, rootNavigator: true).push<bool>(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text(changing ? 'Change PIN' : 'Set up app lock')),
          body: SafeArea(child: PinSetupFlow(onDone: () => Navigator.pop(context, true))),
        ),
      ),
    );
    return ok ?? false;
  }

  Future<void> _toggle(BuildContext context, WidgetRef ref, bool on) async {
    final settings = ref.read(settingsRepositoryProvider);
    final messenger = ScaffoldMessenger.of(context);
    if (on) {
      if (!await _setUp(context, changing: false)) return;
      ref.read(sessionUnlockedProvider.notifier).unlock();
      await settings.set(LockSettings.keyEnabled, 'true');
      messenger.showSnackBar(const SnackBar(content: Text('App lock is on.')));
    } else {
      if (!await _verify(context)) return;
      await ref.read(lockRepositoryProvider).clear();
      await settings.setAll({LockSettings.keyEnabled: 'false', LockSettings.keyBiometric: 'false'});
      messenger.showSnackBar(const SnackBar(content: Text('App lock is off.')));
    }
  }

  Future<void> _toggleBiometric(BuildContext context, WidgetRef ref, bool on) async {
    if (on &&
        !await ref.read(biometricsProvider).authenticate('Use fingerprint to unlock Kakeibo')) {
      return;
    }
    await ref.read(settingsRepositoryProvider).set(LockSettings.keyBiometric, '$on');
  }

  Future<void> _changePin(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    if (!await _verify(context) || !context.mounted) return;
    if (await _setUp(context, changing: true)) {
      messenger.showSnackBar(
        const SnackBar(content: Text('PIN changed. Keep the new recovery code.')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(lockSettingsProvider);
    final canBiometric = ref.watch(biometricsAvailableProvider).value ?? false;
    if (s == null) return const SizedBox.shrink();
    final timeout = s.timeout.inSeconds;

    return Card(
      child: Column(
        children: [
          SwitchListTile(
            secondary: const Icon(Symbols.lock_rounded),
            title: const Text('App lock'),
            subtitle: Text(s.enabled ? 'PIN needed to open Kakeibo' : 'Off'),
            value: s.enabled,
            onChanged: (v) => _toggle(context, ref, v),
          ),
          if (s.enabled) ...[
            if (canBiometric)
              SwitchListTile(
                secondary: const Icon(Symbols.fingerprint_rounded),
                title: const Text('Unlock with fingerprint'),
                value: s.biometric,
                onChanged: (v) => _toggleBiometric(context, ref, v),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(Space.s4, Space.s2, Space.s4, Space.s3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Lock again after', style: context.text.bodyLarge),
                  const SizedBox(height: Space.s2),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<int>(
                      showSelectedIcon: false,
                      segments: const [
                        ButtonSegment(value: 0, label: Text('At once')),
                        ButtonSegment(value: 60, label: Text('1 min')),
                        ButtonSegment(value: 300, label: Text('5 min')),
                      ],
                      selected: {
                        if (const [0, 60, 300].contains(timeout)) timeout else 60,
                      },
                      onSelectionChanged: (v) => ref
                          .read(settingsRepositoryProvider)
                          .set(LockSettings.keyTimeout, '${v.first}'),
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Symbols.password_rounded),
              title: const Text('Change PIN'),
              subtitle: const Text('You’ll get a new recovery code'),
              onTap: () => _changePin(context, ref),
            ),
          ],
        ],
      ),
    );
  }
}
