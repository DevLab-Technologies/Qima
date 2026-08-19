import 'package:flutter_test/flutter_test.dart';
import 'package:qima/models/money.dart';

void main() {
  group('Money.fractionDigits (spec §8.1 / TC-M1/M2)', () {
    test('magnitude 0 -> 2 digits', () {
      expect(const Money(0, 'USD').fractionDigits, 2);
    });
    test('magnitude < 1 -> 6 digits', () {
      expect(const Money(0.5, 'USD').fractionDigits, 6);
      expect(const Money(-0.5, 'USD').fractionDigits, 6);
    });
    test('magnitude < 10 -> 4 digits', () {
      expect(const Money(9.999, 'USD').fractionDigits, 4);
    });
    test('10 <= magnitude < 10,000 -> 2 digits', () {
      expect(const Money(10, 'USD').fractionDigits, 2);
      expect(const Money(9999.99, 'USD').fractionDigits, 2);
    });
    test('magnitude >= 10,000 -> 2 digits', () {
      expect(const Money(1000000, 'USD').fractionDigits, 2);
    });
  });

  group('Money.compact (TC-M2)', () {
    test('below 1,000 has no suffix', () {
      final formatted = const Money(450, 'USD').compact(locale: 'en_US');
      expect(formatted.contains('k'), isFalse);
      expect(formatted.contains('M'), isFalse);
    });
    test('>= 1,000 uses k suffix', () {
      final formatted = const Money(4500, 'USD').compact(locale: 'en_US');
      expect(formatted.endsWith('k'), isTrue);
    });
    test('>= 1,000,000 uses M suffix', () {
      final formatted = const Money(2100000, 'USD').compact(locale: 'en_US');
      expect(formatted.endsWith('M'), isTrue);
    });
  });
}
