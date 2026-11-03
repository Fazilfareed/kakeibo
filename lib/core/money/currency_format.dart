import 'package:flutter/foundation.dart';

/// Where the currency symbol sits relative to the number.
enum SymbolPosition { before, after }

/// How money is displayed (PRD FR-109). Only the symbol's look changes; the
/// stored currency is always LKR and amounts are never converted.
@immutable
class CurrencyFormat {
  const CurrencyFormat({
    this.symbol = defaultSymbol,
    this.position = SymbolPosition.before,
    this.space = true,
  });

  static const String currencyCode = 'LKR';
  static const String defaultSymbol = 'Rs';

  /// Symbols offered in Settings; a custom symbol of 1–4 characters is also allowed.
  static const List<String> presets = ['Rs', 'Rs.', 'LKR', 'රු', 'ரூ'];
  static const int maxCustomLength = 4;

  // Settings table keys.
  static const String keySymbol = 'currency_symbol';
  static const String keyPosition = 'currency_symbol_position';
  static const String keySpace = 'currency_symbol_space';

  final String symbol;
  final SymbolPosition position;
  final bool space;

  factory CurrencyFormat.fromSettings(Map<String, String> settings) {
    final symbol = settings[keySymbol]?.trim();
    return CurrencyFormat(
      symbol: (symbol == null || symbol.isEmpty) ? defaultSymbol : symbol,
      position: settings[keyPosition] == SymbolPosition.after.name
          ? SymbolPosition.after
          : SymbolPosition.before,
      space: settings[keySpace] != 'false',
    );
  }

  Map<String, String> toSettings() => {
        keySymbol: symbol,
        keyPosition: position.name,
        keySpace: space.toString(),
      };

  CurrencyFormat copyWith({String? symbol, SymbolPosition? position, bool? space}) {
    return CurrencyFormat(
      symbol: symbol ?? this.symbol,
      position: position ?? this.position,
      space: space ?? this.space,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is CurrencyFormat &&
      other.symbol == symbol &&
      other.position == position &&
      other.space == space;

  @override
  int get hashCode => Object.hash(symbol, position, space);
}
