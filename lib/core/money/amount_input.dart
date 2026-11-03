/// Immutable state of an amount being typed on the keypad or in a text field.
/// Holds the raw digits so no floating-point value is ever involved.
class AmountInput {
  const AmountInput._(this.raw);

  const AmountInput.empty() : raw = '';

  /// Typed text such as `1250`, `1250.` or `1250.5` (no grouping).
  final String raw;

  static const int maxMajorDigits = 9;
  static const int decimals = 2;

  factory AmountInput.fromCents(int cents) {
    if (cents <= 0) return const AmountInput.empty();
    final major = cents ~/ 100;
    final minor = cents % 100;
    return AmountInput._(minor == 0 ? '$major' : '$major.${minor.toString().padLeft(2, '0')}');
  }

  bool get isEmpty => raw.isEmpty;
  bool get hasDecimalPoint => raw.contains('.');

  /// Amount in cents; 0 when empty.
  int get cents => parseCents(raw) ?? 0;

  AmountInput append(String key) {
    if (key == '.') {
      if (hasDecimalPoint) return this;
      return AmountInput._(raw.isEmpty ? '0.' : '$raw.');
    }
    if (!RegExp(r'^\d$').hasMatch(key)) return this;
    final parts = raw.split('.');
    if (hasDecimalPoint) {
      if (parts[1].length >= decimals) return this;
    } else {
      if (raw == '0') return AmountInput._(key);
      if (raw.length >= maxMajorDigits) return this;
    }
    return AmountInput._('$raw$key');
  }

  AmountInput backspace() =>
      raw.isEmpty ? this : AmountInput._(raw.substring(0, raw.length - 1));

  AmountInput clear() => const AmountInput.empty();

  /// Parses user text like `12,500.50` or `240` into cents. Returns null for
  /// invalid input. Uses integer arithmetic only.
  static int? parseCents(String text) {
    final t = text.replaceAll(',', '').replaceAll(' ', '').trim();
    if (t.isEmpty) return null;
    final m = RegExp(r'^(\d{0,9})(?:\.(\d{0,2}))?$').firstMatch(t);
    if (m == null) return null;
    final major = m.group(1)!.isEmpty ? 0 : int.parse(m.group(1)!);
    final minorText = (m.group(2) ?? '').padRight(2, '0');
    return major * 100 + int.parse(minorText);
  }
}
