import 'package:flutter_test/flutter_test.dart';
import 'package:qima/models/money.dart';
import 'package:qima/theme/masking.dart';

void main() {
  const lri = '\u2066', pdi = '\u2069';

  group('Masking.amount', () {
    test('formats normally when not hidden', () {
      final money = Money(1234.5, 'USD');
      expect(Masking.amount(money, hidden: false), money.formatted());
    });

    test('returns the mask string when hidden', () {
      final money = Money(1234.5, 'USD');
      expect(Masking.amount(money, hidden: true), Masking.mask);
    });
  });

  group('Masking.compactAmount', () {
    test('formats normally when not hidden', () {
      final money = Money(4500, 'USD');
      expect(Masking.compactAmount(money, hidden: false), money.compact());
    });

    test('returns the mask string when hidden', () {
      final money = Money(4500, 'USD');
      expect(Masking.compactAmount(money, hidden: true), Masking.mask);
    });
  });

  group('Masking.signedAmount', () {
    test('shows the real formatted amount, signed and isolated, when not hidden', () {
      final money = Money(214.80, 'USD');
      expect(Masking.signedAmount(money, hidden: false, isUp: true), '$lri+${money.formatted()}$pdi');
    });

    test('an already-negative amount when not hidden is not double-signed', () {
      final money = Money(-214.80, 'USD');
      expect(Masking.signedAmount(money, hidden: false, isUp: false), '$lri${money.formatted()}$pdi');
    });

    test('masks the amount but keeps a "+" sign when hidden and up', () {
      final money = Money(214.80, 'USD');
      expect(Masking.signedAmount(money, hidden: true, isUp: true), '$lri+${Masking.mask}$pdi');
    });

    test('masks the amount but keeps a "-" sign when hidden and down', () {
      final money = Money(214.80, 'USD');
      expect(Masking.signedAmount(money, hidden: true, isUp: false), '$lri-${Masking.mask}$pdi');
    });
  });
}
