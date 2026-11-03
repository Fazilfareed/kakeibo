import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/core/money/amount_input.dart';

AmountInput type(String keys) {
  var a = const AmountInput.empty();
  for (final k in keys.split('')) {
    a = k == '<' ? a.backspace() : a.append(k);
  }
  return a;
}

void main() {
  test('typing digits builds whole rupees', () {
    expect(type('240').cents, 24000);
    expect(type('12500').cents, 1250000);
  });

  test('decimal point allows at most two decimals', () {
    expect(type('12.5').cents, 1250);
    expect(type('12.50').cents, 1250);
    expect(type('12.505').raw, '12.50');
    expect(type('12..5').raw, '12.5');
    expect(type('.5').raw, '0.5');
  });

  test('leading zero is replaced and length is capped', () {
    expect(type('05').raw, '5');
    expect(type('1234567890').raw, '123456789');
  });

  test('backspace removes the last key', () {
    expect(type('240<').cents, 2400);
    expect(type('<').isEmpty, isTrue);
  });

  test('round-trips from cents', () {
    expect(AmountInput.fromCents(24000).raw, '240');
    expect(AmountInput.fromCents(1250).raw, '12.50');
    expect(AmountInput.fromCents(0).isEmpty, isTrue);
  });

  test('parses text field input with grouping', () {
    expect(AmountInput.parseCents('12,500.50'), 1250050);
    expect(AmountInput.parseCents(' 240 '), 24000);
    expect(AmountInput.parseCents('1.999'), isNull);
    expect(AmountInput.parseCents('abc'), isNull);
    expect(AmountInput.parseCents(''), isNull);
  });
}
