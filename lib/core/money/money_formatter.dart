import 'package:intl/intl.dart';

import 'currency_format.dart';

/// A formatted amount split into its pieces, so widgets can style the symbol
/// separately from the number.
class MoneyParts {
  const MoneyParts({
    required this.symbol,
    required this.number,
    required this.isNegative,
    required this.position,
    required this.space,
  });

  final String symbol;

  /// Digits with grouping and decimals, without sign or symbol (e.g. `12,500.00`).
  final String number;
  final bool isNegative;
  final SymbolPosition position;
  final bool space;

  static const String minus = '−';

  /// The full display string, e.g. `Rs 12,500.00`, `−Rs 1,500.00` or `12,500.00 LKR`.
  String get text {
    final gap = space ? ' ' : '';
    final sign = isNegative ? minus : '';
    return position == SymbolPosition.before
        ? '$sign$symbol$gap$number'
        : '$sign$number$gap$symbol';
  }

  @override
  String toString() => text;
}

/// Formats integer cents (LKR minor units) for display. Uses integer arithmetic
/// only, so there are no floating-point rounding errors.
class MoneyFormatter {
  MoneyFormatter(this.format);

  final CurrencyFormat format;

  static const int minorPerMajor = 100;
  static final NumberFormat _grouping = NumberFormat('#,##0', 'en_US');

  /// Splits [cents] into display parts.
  ///
  /// When [hideZeroDecimals] is true, `.00` is dropped (used for the hero
  /// number); any other cents value is always shown.
  MoneyParts parts(int cents, {bool hideZeroDecimals = false}) {
    final isNegative = cents < 0;
    final abs = cents.abs();
    final major = abs ~/ minorPerMajor;
    final minor = abs % minorPerMajor;
    final majorText = _grouping.format(major);
    final number = (hideZeroDecimals && minor == 0)
        ? majorText
        : '$majorText.${minor.toString().padLeft(2, '0')}';
    return MoneyParts(
      symbol: format.symbol,
      number: number,
      isNegative: isNegative,
      position: format.position,
      space: format.space,
    );
  }

  /// The complete display string for [cents].
  String formatCents(int cents, {bool hideZeroDecimals = false}) =>
      parts(cents, hideZeroDecimals: hideZeroDecimals).text;

  /// Words for screen readers, e.g. "12,500 rupees 50 cents" or "minus 1,500 rupees".
  String semanticLabel(int cents) {
    final abs = cents.abs();
    final major = _grouping.format(abs ~/ minorPerMajor);
    final minor = abs % minorPerMajor;
    final sign = cents < 0 ? 'minus ' : '';
    final rupees = '$major ${abs ~/ minorPerMajor == 1 ? 'rupee' : 'rupees'}';
    return minor == 0 ? '$sign$rupees' : '$sign$rupees $minor cents';
  }
}
