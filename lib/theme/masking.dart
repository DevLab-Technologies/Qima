import '../models/money.dart';

/// Hide-balances masking (spec Phase 4 "Hide balances + App lock").
///
/// Only money AMOUNTS are masked when hidden — portfolio value, cost, gain
/// amounts, lot costs/values, holdings values. Percentages (gain %,
/// allocation %) and market PRICES stay visible even when hidden, so this
/// helper is deliberately narrow: it only ever touches [Money] formatting,
/// never percent strings or [InstrumentPresentation.latestPrice]/metal
/// breakdown values.
class Masking {
  Masking._();

  /// The mask string shown in place of a formatted amount.
  static const String mask = '••••••';

  /// Formats [money] normally, or returns [mask] when [hidden].
  static String amount(Money money, {required bool hidden, bool useFallbackSymbol = false}) {
    if (hidden) return mask;
    return money.formatted(useFallbackSymbol: useFallbackSymbol);
  }

  /// Compact-formats [money] normally, or returns [mask] when [hidden].
  static String compactAmount(Money money, {required bool hidden, bool useFallbackSymbol = false}) {
    if (hidden) return mask;
    return money.compact(useFallbackSymbol: useFallbackSymbol);
  }

  /// Signed amount, mirroring `signedFigure`'s "+"/isolate convention: shows
  /// the real formatted amount when visible, or a sign-only mask
  /// ("+••••••"/"-••••••") when [hidden] — the sign still communicates
  /// direction without revealing the amount, and stays attached to the mask
  /// in RTL via the same bidi isolate `signedFigure` uses.
  static String signedAmount(Money money, {required bool hidden, required bool isUp, bool useFallbackSymbol = false}) {
    final value = hidden ? mask : money.formatted(useFallbackSymbol: useFallbackSymbol);
    return '\u2066${isUp ? '+' : hidden ? '-' : ''}$value\u2069';
  }
}
