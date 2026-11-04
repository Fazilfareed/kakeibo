import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../app/theme/kakeibo_colors.dart';
import '../../../app/theme/kakeibo_text.dart';
import '../../../app/theme/tokens.dart';
import '../../backup/data/backup_providers.dart';
import '../../periods/data/period_providers.dart';
import '../data/lock_providers.dart';
import '../data/lock_repository.dart';
import 'pin_pad.dart';
import 'pin_setup_flow.dart';

enum _Mode { pin, recovery, newPin }

/// The lock screen (S2): PIN pad, fingerprint, and the forgotten-PIN path
/// (FR-07). With [verifyOnly] it just confirms the PIN for a settings change.
class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key, required this.onUnlocked, this.verifyOnly = false});

  final VoidCallback onUnlocked;
  final bool verifyOnly;

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  _Mode _mode = _Mode.pin;
  String _typed = '';
  int _length = 4;
  String? _message;
  Duration? _wait;
  Timer? _ticker;
  bool _checking = false;
  final _code = TextEditingController();

  LockRepository get _repo => ref.read(lockRepositoryProvider);

  @override
  void initState() {
    super.initState();
    _repo.pinLength().then((n) => mounted ? setState(() => _length = n) : null);
    _repo.lockoutRemaining().then(_startWait);
    if (!widget.verifyOnly) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _biometric(auto: true));
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _code.dispose();
    super.dispose();
  }

  bool get _canBiometric {
    final s = ref.read(lockSettingsProvider);
    return (s?.biometric ?? false) && (ref.read(biometricsAvailableProvider).value ?? false);
  }

  Future<void> _biometric({bool auto = false}) async {
    if (auto) await ref.read(biometricsAvailableProvider.future);
    if (!_canBiometric || !mounted) return;
    final ok = await ref.read(biometricsProvider).authenticate('Unlock Kakeibo');
    if (ok && mounted) widget.onUnlocked();
  }

  void _startWait(Duration? wait) {
    _ticker?.cancel();
    if (!mounted) return;
    setState(() => _wait = wait);
    if (wait == null) return;
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) async {
      final left = await _repo.lockoutRemaining();
      if (!mounted) return;
      setState(() => _wait = left);
      if (left == null) {
        _ticker?.cancel();
        setState(() => _message = null);
      }
    });
  }

  Future<void> _digit(String d) async {
    if (_checking || _wait != null || _typed.length >= _length) return;
    setState(() {
      _typed += d;
      _message = null;
    });
    if (_typed.length < _length) return;
    setState(() => _checking = true);
    final result = await _repo.checkPin(_typed);
    if (!mounted) return;
    setState(() {
      _checking = false;
      _typed = '';
    });
    _handle(result, wrong: 'Wrong PIN');
  }

  void _handle(UnlockResult result, {required String wrong}) {
    switch (result) {
      case Unlocked():
        if (_mode == _Mode.recovery) {
          setState(() => _mode = _Mode.newPin);
        } else {
          widget.onUnlocked();
        }
      case WrongCode(:final attemptsLeft):
        HapticFeedback.heavyImpact();
        setState(
          () => _message = attemptsLeft == 1
              ? '$wrong. 1 try left before a short wait.'
              : '$wrong. $attemptsLeft tries left.',
        );
      case LockedOut(:final wait):
        HapticFeedback.heavyImpact();
        setState(() => _message = '$wrong. Too many tries.');
        _startWait(wait);
    }
  }

  Future<void> _checkCode() async {
    if (_wait != null) return;
    final result = await _repo.checkRecoveryCode(_code.text);
    if (!mounted) return;
    _handle(result, wrong: 'That code isn’t right');
  }

  Future<void> _reset() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Kakeibo?'),
        content: const Text(
          'Without your PIN or recovery code, the only way in is to delete everything on this '
          'phone. You can then restore a backup file from Settings → Data.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: context.colors.over,
              foregroundColor: context.colors.bg,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete and reset'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(backupRepositoryProvider).deleteAll();
    await _repo.clear();
    ref.invalidate(ledgerBootstrapProvider);
    widget.onUnlocked();
  }

  String _clock(Duration d) => '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      appBar: widget.verifyOnly || _mode != _Mode.pin
          ? AppBar(
              leading: _mode == _Mode.newPin
                  ? null
                  : BackButton(
                      onPressed: () => _mode == _Mode.recovery
                          ? setState(() {
                              _mode = _Mode.pin;
                              _message = null;
                            })
                          : Navigator.maybePop(context),
                    ),
              automaticallyImplyLeading: false,
              title: Text(switch (_mode) {
                _Mode.pin => 'Enter your PIN',
                _Mode.recovery => 'Forgot PIN',
                _Mode.newPin => 'Set a new PIN',
              }),
            )
          : null,
      body: SafeArea(
        child: switch (_mode) {
          _Mode.newPin => PinSetupFlow(onDone: widget.onUnlocked),
          _Mode.recovery => ListView(
            padding: const EdgeInsets.all(Space.gutter),
            children: [
              Text('Type your recovery code', style: context.text.headlineSmall),
              const SizedBox(height: Space.s2),
              Text(
                'The 12-character code you wrote down when you set your PIN.',
                style: context.text.bodyMedium,
              ),
              const SizedBox(height: Space.s5),
              TextField(
                controller: _code,
                autofocus: true,
                textCapitalization: TextCapitalization.characters,
                // A secret: no autofill offers (Android suggested saved emails)
                // and no keyboard learning.
                autofillHints: null,
                keyboardType: TextInputType.visiblePassword,
                autocorrect: false,
                enableSuggestions: false,
                decoration: InputDecoration(
                  hintText: 'XXXX-XXXX-XXXX',
                  errorText: _wait != null ? 'Try again in ${_clock(_wait!)}' : _message,
                ),
                onSubmitted: (_) => _checkCode(),
              ),
              const SizedBox(height: Space.s4),
              FilledButton(
                onPressed: _wait == null ? _checkCode : null,
                child: const Text('Continue'),
              ),
              const SizedBox(height: Space.s7),
              Text('No code and no fingerprint?', style: context.text.titleSmall),
              const SizedBox(height: Space.s1),
              Text(
                'You can reset the app and restore your latest backup file.',
                style: context.text.bodySmall,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: _reset,
                  style: TextButton.styleFrom(foregroundColor: c.over),
                  child: const Text('Reset app'),
                ),
              ),
            ],
          ),
          _Mode.pin => LayoutBuilder(
            builder: (context, box) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: box.maxHeight),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        const SizedBox(height: Space.s5),
                        Icon(Symbols.lock_rounded, size: IconSizes.xl, color: c.ink2),
                        const SizedBox(height: Space.s3),
                        Text(
                          widget.verifyOnly ? 'Confirm it’s you' : 'Kakeibo is locked',
                          style: context.text.headlineSmall,
                        ),
                        const SizedBox(height: Space.s5),
                        PinDots(length: _length, filled: _typed.length, error: _message != null),
                        SizedBox(
                          height: 48,
                          child: Center(
                            child: Text(
                              _wait != null
                                  ? 'Try again in ${_clock(_wait!)}'
                                  : _checking
                                  ? 'Checking…'
                                  : _message ?? '',
                              style: context.text.bodySmall?.copyWith(
                                color: _message != null || _wait != null ? c.over : null,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Opacity(
                      opacity: _wait == null ? 1 : 0.4,
                      child: PinPad(
                        onDigit: _digit,
                        onBackspace: () => setState(
                          () =>
                              _typed = _typed.isEmpty ? '' : _typed.substring(0, _typed.length - 1),
                        ),
                        extra: _canBiometric
                            ? IconButton(
                                tooltip: 'Use fingerprint',
                                iconSize: 32,
                                icon: Icon(Symbols.fingerprint_rounded, color: c.ink2),
                                onPressed: _biometric,
                              )
                            : null,
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(() {
                        _mode = _Mode.recovery;
                        _message = null;
                      }),
                      child: const Text('Forgot PIN?'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        },
      ),
    );
  }
}

/// Covers the app while it is locked (MaterialApp.builder). The app below
/// keeps its state but isn't painted or read out. It locks on start and after
/// the chosen time in the background.
class AppLockGate extends ConsumerStatefulWidget {
  const AppLockGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends ConsumerState<AppLockGate> {
  DateTime? _hiddenAt;

  late final AppLifecycleListener _lifecycle = AppLifecycleListener(
    onHide: () {
      // Only time away from an unlocked app counts (the fingerprint prompt
      // itself hides the app briefly).
      if (ref.read(sessionUnlockedProvider)) _hiddenAt = DateTime.now();
    },
    onShow: () {
      final since = _hiddenAt;
      _hiddenAt = null;
      final s = ref.read(lockSettingsProvider);
      if (since == null || s == null || !s.enabled) return;
      if (DateTime.now().difference(since) >= s.timeout) {
        ref.read(sessionUnlockedProvider.notifier).lock();
      }
    },
  );

  @override
  void initState() {
    super.initState();
    _lifecycle;
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(lockSettingsProvider);
    final unlocked = ref.watch(sessionUnlockedProvider);
    // Until settings load, show only the background: never a flash of data.
    final covered = settings == null || (settings.enabled && !unlocked);
    return Stack(
      children: [
        Offstage(offstage: covered, child: widget.child),
        if (settings == null)
          ColoredBox(color: context.colors.bg, child: const SizedBox.expand())
        else if (covered)
          // Its own navigator, so the lock screen can show dialogs.
          Navigator(
            onGenerateRoute: (_) => MaterialPageRoute<void>(
              builder: (_) =>
                  LockScreen(onUnlocked: () => ref.read(sessionUnlockedProvider.notifier).unlock()),
            ),
          ),
      ],
    );
  }
}
