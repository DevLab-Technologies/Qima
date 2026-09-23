import 'package:flutter_test/flutter_test.dart';
import 'package:qima/models/currency_style.dart';
import 'package:qima/models/money.dart';

const _nbsp = '\u00A0';
const _fsi = '\u2068';
const _pdi = '\u2069';

void main() {
  group('Money.formatted uses each currency\'s native symbol and placement', () {
    test('USD symbol comes before the amount', () {
      expect(const Money(1234.56, 'USD').formatted(locale: 'en_US'), r'$1,234.56');
    });

    test('SAR uses the Saudi Riyal sign after the amount', () {
      expect(
        const Money(1234.56, 'SAR').formatted(locale: 'en_US'),
        '1,234.56$_nbsp${CurrencyStyle.saudiRiyalSign}',
      );
    });

    test('EUR symbol comes after the amount', () {
      expect(const Money(1234.56, 'EUR').formatted(locale: 'en_US'), '1,234.56$_nbsp€');
    });

    test('Arabic symbols follow the amount inside a direction isolate', () {
      expect(const Money(1234.56, 'AED').formatted(locale: 'en_US'), '1,234.56$_nbsp$_fsiد.إ$_pdi');
    });

    test('negative amounts put the minus sign first in both placements', () {
      expect(const Money(-12.5, 'USD').formatted(locale: 'en_US'), r'-$12.50');
      expect(
        const Money(-12.5, 'SAR').formatted(locale: 'en_US'),
        '-12.50$_nbsp${CurrencyStyle.saudiRiyalSign}',
      );
    });

    test('letter symbols in front are separated from the amount', () {
      expect(const Money(20, 'CHF').formatted(locale: 'en_US'), 'CHF${_nbsp}20.00');
    });

    test('unknown currencies keep the intl symbol in front', () {
      final formatted = const Money(20, 'CAD').formatted(locale: 'en_US');
      expect(formatted.endsWith('20.00'), isTrue);
      expect(formatted.startsWith('20'), isFalse);
    });

    test('magnitude-based fraction digits still apply', () {
      expect(const Money(0.5, 'SAR').formatted(locale: 'en_US'), '0.500000$_nbsp${CurrencyStyle.saudiRiyalSign}');
    });
  });

  group('fallback symbol for native surfaces', () {
    test('SAR falls back to the Arabic abbreviation', () {
      expect(
        const Money(10, 'SAR').formatted(locale: 'en_US', useFallbackSymbol: true),
        '10.00$_nbsp$_fsiر.س$_pdi',
      );
    });

    test('currencies without a fallback keep their symbol', () {
      expect(const Money(10, 'USD').formatted(locale: 'en_US', useFallbackSymbol: true), r'$10.00');
    });
  });

  group('Money.compact keeps the symbol placement', () {
    test('suffix currencies place the symbol after the scale suffix', () {
      expect(const Money(4500, 'SAR').compact(locale: 'en_US'), '4.5k$_nbsp${CurrencyStyle.saudiRiyalSign}');
    });

    test('prefix currencies place the symbol before the number', () {
      expect(const Money(2100000, 'USD').compact(locale: 'en_US'), r'$2.1M');
      expect(const Money(-4500, 'USD').compact(locale: 'en_US'), r'-$4.5k');
    });
  });
}
