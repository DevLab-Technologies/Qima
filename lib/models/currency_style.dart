import 'package:intl/intl.dart';

/// Where a currency's symbol sits relative to the amount.
enum SymbolPosition { prefix, suffix }

/// How a currency is written where it is used: its native symbol and whether
/// that symbol comes before ("$1,234.56") or after ("1,234.56 €") the amount.
///
/// Only the symbol and its position are localized per currency. Digits and
/// grouping stay in the app's single number format so amounts in different
/// currencies line up and compare at a glance.
class CurrencyStyle {
  final String symbol;
  final SymbolPosition position;

  /// Symbol for surfaces that render with the platform's fonts rather than
  /// the app's bundled ones (the native home-screen widgets). Only set when
  /// [symbol] needs a glyph older system fonts lack, such as the Saudi Riyal
  /// sign (U+20C1, added in Unicode 17).
  final String? _fallbackSymbol;

  const CurrencyStyle(this.symbol, this.position, {String? fallbackSymbol}) : _fallbackSymbol = fallbackSymbol;

  String get fallbackSymbol => _fallbackSymbol ?? symbol;

  /// The Saudi Riyal sign introduced by SAMA in 2025.
  static const String saudiRiyalSign = '\u20C1';

  static const Map<String, CurrencyStyle> _known = {
    // Gulf and wider Arab currencies: native Arabic symbols, after the amount.
    'SAR': CurrencyStyle(saudiRiyalSign, SymbolPosition.suffix, fallbackSymbol: 'ر.س'),
    'AED': CurrencyStyle('د.إ', SymbolPosition.suffix),
    'QAR': CurrencyStyle('ر.ق', SymbolPosition.suffix),
    'KWD': CurrencyStyle('د.ك', SymbolPosition.suffix),
    'BHD': CurrencyStyle('د.ب', SymbolPosition.suffix),
    'OMR': CurrencyStyle('ر.ع.', SymbolPosition.suffix),
    'JOD': CurrencyStyle('د.أ', SymbolPosition.suffix),
    'EGP': CurrencyStyle('ج.م', SymbolPosition.suffix),
    'IQD': CurrencyStyle('د.ع', SymbolPosition.suffix),
    'LBP': CurrencyStyle('ل.ل', SymbolPosition.suffix),
    'SYP': CurrencyStyle('ل.س', SymbolPosition.suffix),
    'YER': CurrencyStyle('ر.ي', SymbolPosition.suffix),
    'LYD': CurrencyStyle('د.ل', SymbolPosition.suffix),
    'TND': CurrencyStyle('د.ت', SymbolPosition.suffix),
    'DZD': CurrencyStyle('د.ج', SymbolPosition.suffix),
    'MAD': CurrencyStyle('د.م.', SymbolPosition.suffix),
    'SDG': CurrencyStyle('ج.س', SymbolPosition.suffix),

    // Currencies written before the amount where they are used.
    'USD': CurrencyStyle(r'$', SymbolPosition.prefix),
    'GBP': CurrencyStyle('£', SymbolPosition.prefix),
    'JPY': CurrencyStyle('¥', SymbolPosition.prefix),
    'INR': CurrencyStyle('₹', SymbolPosition.prefix),
    'KRW': CurrencyStyle('₩', SymbolPosition.prefix),
    'TRY': CurrencyStyle('₺', SymbolPosition.prefix),
    'PHP': CurrencyStyle('₱', SymbolPosition.prefix),
    'NGN': CurrencyStyle('₦', SymbolPosition.prefix),
    'THB': CurrencyStyle('฿', SymbolPosition.prefix),
    'PKR': CurrencyStyle('Rs', SymbolPosition.prefix),
    'BRL': CurrencyStyle(r'R$', SymbolPosition.prefix),
    'ZAR': CurrencyStyle('R', SymbolPosition.prefix),
    'CHF': CurrencyStyle('CHF', SymbolPosition.prefix),

    // Currencies written after the amount where they are used.
    'EUR': CurrencyStyle('€', SymbolPosition.suffix),
    'ILS': CurrencyStyle('₪', SymbolPosition.suffix),
    'RUB': CurrencyStyle('₽', SymbolPosition.suffix),
    'UAH': CurrencyStyle('₴', SymbolPosition.suffix),
    'VND': CurrencyStyle('₫', SymbolPosition.suffix),
    'PLN': CurrencyStyle('zł', SymbolPosition.suffix),
    'CZK': CurrencyStyle('Kč', SymbolPosition.suffix),
    'HUF': CurrencyStyle('Ft', SymbolPosition.suffix),
    'RON': CurrencyStyle('lei', SymbolPosition.suffix),
    'BGN': CurrencyStyle('лв.', SymbolPosition.suffix),
    'SEK': CurrencyStyle('kr', SymbolPosition.suffix),
    'NOK': CurrencyStyle('kr', SymbolPosition.suffix),
    'DKK': CurrencyStyle('kr.', SymbolPosition.suffix),
    'ISK': CurrencyStyle('kr', SymbolPosition.suffix),
  };

  /// The style for [currencyCode]. Codes without an explicit entry keep the
  /// intl symbol (e.g. "CA$", "A$") in front of the amount.
  static CurrencyStyle of(String currencyCode) {
    final known = _known[currencyCode];
    if (known != null) return known;
    return CurrencyStyle(
      NumberFormat.simpleCurrency(name: currencyCode).currencySymbol,
      SymbolPosition.prefix,
    );
  }

  static final RegExp _endsWithLetter = RegExp(r'\p{L}$', unicode: true);
  static final RegExp _rtlChar = RegExp(r'[\u0590-\u08FF]');

  /// Places the symbol around an already-formatted, unsigned [number] and
  /// puts the minus sign first, e.g. "-$1,234.56" / "-1,234.56 €".
  ///
  /// The symbol is joined with a non-breaking space so it never wraps away
  /// from the amount. Arabic symbols are wrapped in a first-strong isolate so
  /// their internal dots stay in place whichever direction the surrounding
  /// text runs — in RTL layouts the symbol then reads after the amount too.
  String apply(String number, {required bool isNegative, bool useFallbackSymbol = false}) {
    final sign = isNegative ? '-' : '';
    final raw = useFallbackSymbol ? fallbackSymbol : symbol;
    final sym = _rtlChar.hasMatch(raw) ? '\u2068$raw\u2069' : raw;
    switch (position) {
      case SymbolPosition.prefix:
        final gap = _endsWithLetter.hasMatch(raw) ? '\u00A0' : '';
        return '$sign$sym$gap$number';
      case SymbolPosition.suffix:
        return '$sign$number\u00A0$sym';
    }
  }
}
