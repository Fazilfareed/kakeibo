import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../app/theme/kakeibo_colors.dart';
import '../../../app/theme/kakeibo_text.dart';
import '../../../app/theme/tokens.dart';
import '../data/lock_providers.dart';
import '../data/lock_repository.dart';
import 'pin_pad.dart';

enum _Step { choose, confirm, saving, showCode, retypeCode }

/// Choose a PIN, confirm it, then see and re-type the recovery code
/// (FR-07). Used from Settings and after unlocking with the recovery code.
class PinSetupFlow extends ConsumerStatefulWidget {
  const PinSetupFlow({super.key, required this.onDone});

  /// Called once the new PIN and recovery code are saved and confirmed.
  final VoidCallback onDone;

  @override
  ConsumerState<PinSetupFlow> createState() => _PinSetupFlowState();
}

class _PinSetupFlowState extends ConsumerState<PinSetupFlow> {
  static const maxLength = 6;
  static const minLength = 4;

  _Step _step = _Step.choose;
  String _first = '';
  String _typed = '';
  String _code = '';
  String? _error;
  final _codeField = TextEditingController();

  @override
  void dispose() {
    _codeField.dispose();
    super.dispose();
  }

  void _digit(String d) {
    if (_typed.length >= maxLength) return;
    setState(() {
      _typed += d;
      _error = null;
    });
    if (_step == _Step.confirm && _typed.length == _first.length) _confirm();
  }

  void _backspace() {
    if (_typed.isEmpty) return;
    setState(() => _typed = _typed.substring(0, _typed.length - 1));
  }

  void _choose() => setState(() {
    _first = _typed;
    _typed = '';
    _step = _Step.confirm;
  });

  Future<void> _confirm() async {
    if (_typed != _first) {
      HapticFeedback.heavyImpact();
      setState(() {
        _error = 'The PINs didn’t match. Choose your PIN again.';
        _typed = '';
        _first = '';
        _step = _Step.choose;
      });
      return;
    }
    setState(() => _step = _Step.saving);
    final code = await ref.read(lockRepositoryProvider).setPin(_first);
    if (!mounted) return;
    setState(() {
      _code = code;
      _step = _Step.showCode;
    });
  }

  void _checkCode() {
    if (LockRepository.normalizeCode(_codeField.text) == LockRepository.normalizeCode(_code)) {
      widget.onDone();
    } else {
      setState(() => _error = 'That doesn’t match. Check each character and try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return switch (_step) {
      _Step.choose || _Step.confirm => _PinStep(
        title: _step == _Step.choose ? 'Choose a PIN' : 'Type it again',
        hint: _step == _Step.choose ? '4 to 6 digits' : 'To make sure it’s right',
        length: _step == _Step.choose ? maxLength : _first.length,
        filled: _typed.length,
        error: _error,
        onDigit: _digit,
        onBackspace: _backspace,
        action: _step == _Step.choose
            ? FilledButton(
                onPressed: _typed.length >= minLength ? _choose : null,
                child: const Text('Next'),
              )
            : null,
      ),
      _Step.saving => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: Space.s4),
            Text('Securing your PIN…', style: context.text.bodyMedium),
          ],
        ),
      ),
      _Step.showCode => ListView(
        padding: const EdgeInsets.all(Space.gutter),
        children: [
          Icon(Symbols.key_rounded, size: IconSizes.xl, color: c.ink2),
          const SizedBox(height: Space.s4),
          Text('Your recovery code', style: context.text.headlineSmall),
          const SizedBox(height: Space.s2),
          Text(
            'If you forget your PIN, this code is the only way back in without '
            'fingerprint. Write it down and keep it somewhere safe, away from the phone. '
            'It won’t be shown again.',
            style: context.text.bodyMedium,
          ),
          const SizedBox(height: Space.s5),
          Container(
            padding: const EdgeInsets.symmetric(vertical: Space.s5),
            decoration: BoxDecoration(
              color: c.surfaceSunken,
              borderRadius: BorderRadius.circular(Radii.md),
            ),
            child: SelectableText(
              _code,
              textAlign: TextAlign.center,
              semanticsLabel: 'Recovery code: ${_code.split('').join(' ')}',
              style: context.moneyText.moneyM.copyWith(letterSpacing: 2),
            ),
          ),
          const SizedBox(height: Space.s5),
          FilledButton(
            onPressed: () => setState(() => _step = _Step.retypeCode),
            child: const Text('I’ve written it down'),
          ),
        ],
      ),
      _Step.retypeCode => ListView(
        padding: const EdgeInsets.all(Space.gutter),
        children: [
          Text('Type the recovery code', style: context.text.headlineSmall),
          const SizedBox(height: Space.s2),
          Text(
            'From what you wrote down, to be sure it’s correct.',
            style: context.text.bodyMedium,
          ),
          const SizedBox(height: Space.s5),
          TextField(
            controller: _codeField,
            autofocus: true,
            textCapitalization: TextCapitalization.characters,
            // A secret: no autofill offers (Android suggested saved emails)
            // and no keyboard learning.
            autofillHints: null,
            keyboardType: TextInputType.visiblePassword,
            autocorrect: false,
            enableSuggestions: false,
            decoration: InputDecoration(hintText: 'XXXX-XXXX-XXXX', errorText: _error),
            onSubmitted: (_) => _checkCode(),
          ),
          const SizedBox(height: Space.s4),
          FilledButton(onPressed: _checkCode, child: const Text('Confirm')),
          TextButton(
            onPressed: () => setState(() {
              _error = null;
              _step = _Step.showCode;
            }),
            child: const Text('Show the code again'),
          ),
        ],
      ),
    };
  }
}

/// A title, PIN dots, an optional error and the pad.
class _PinStep extends StatelessWidget {
  const _PinStep({
    required this.title,
    required this.hint,
    required this.length,
    required this.filled,
    required this.onDigit,
    required this.onBackspace,
    this.error,
    this.action,
  });

  final String title;
  final String hint;
  final int length;
  final int filled;
  final String? error;
  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return LayoutBuilder(
      builder: (context, box) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: box.maxHeight),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  const SizedBox(height: Space.s5),
                  Text(title, style: context.text.headlineSmall),
                  const SizedBox(height: Space.s1),
                  Text(hint, style: context.text.bodySmall),
                  const SizedBox(height: Space.s5),
                  PinDots(length: length, filled: filled, error: error != null),
                  SizedBox(
                    height: 48,
                    child: error == null
                        ? null
                        : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: Space.gutter),
                            child: Text(
                              error!,
                              textAlign: TextAlign.center,
                              style: context.text.bodySmall?.copyWith(color: c.over),
                            ),
                          ),
                  ),
                ],
              ),
              PinPad(onDigit: onDigit, onBackspace: onBackspace),
              SizedBox(height: 64, child: Center(child: action)),
            ],
          ),
        ),
      ),
    );
  }
}
