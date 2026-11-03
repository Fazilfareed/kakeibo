import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/core/money/currency_format.dart';
import 'package:kakeibo/core/money/money_formatter.dart';

void main() {
  group('MoneyFormatter (default Rs)', () {
    final f = MoneyFormatter(const CurrencyFormat());

    test('formats cents with grouping and two decimals', () {
      expect(f.formatCents(1250000), 'Rs 12,500.00');
      expect(f.formatCents(125000050), 'Rs 1,250,000.50');
      expect(f.formatCents(5), 'Rs 0.05');
      expect(f.formatCents(0), 'Rs 0.00');
    });

    test('uses a true minus sign before the symbol for negatives', () {
      expect(f.formatCents(-150000), '−Rs 1,500.00');
    });

    test('hides .00 only when asked and only when cents are zero', () {
      expect(f.formatCents(845000, hideZeroDecimals: true), 'Rs 8,450');
      expect(f.formatCents(845050, hideZeroDecimals: true), 'Rs 8,450.50');
    });

    test('splits parts so the symbol can be styled separately', () {
      final parts = f.parts(-99);
      expect(parts.symbol, 'Rs');
      expect(parts.number, '0.99');
      expect(parts.isNegative, isTrue);
    });

    test('semantic label reads naturally', () {
      expect(f.semanticLabel(1250050), '12,500 rupees 50 cents');
      expect(f.semanticLabel(100), '1 rupee');
      expect(f.semanticLabel(-150000), 'minus 1,500 rupees');
    });
  });

  group('CurrencyFormat (FR-109)', () {
    test('symbol after the number, without space', () {
      final f = MoneyFormatter(const CurrencyFormat(
          symbol: 'LKR', position: SymbolPosition.after, space: false));
      expect(f.formatCents(1250000), '12,500.00LKR');
    });

    test('changing the format never changes the number', () {
      const cents = 987654321;
      final numbers = [
        for (final s in CurrencyFormat.presets)
          MoneyFormatter(CurrencyFormat(symbol: s)).parts(cents).number,
      ];
      expect(numbers.toSet(), {'9,876,543.21'});
    });

    test('round-trips through settings and falls back to defaults', () {
      const format = CurrencyFormat(symbol: 'රු', position: SymbolPosition.after, space: false);
      expect(CurrencyFormat.fromSettings(format.toSettings()), format);
      expect(CurrencyFormat.fromSettings(const {}), const CurrencyFormat());
      expect(CurrencyFormat.fromSettings(const {'currency_symbol': '  '}).symbol, 'Rs');
    });
  });
}
