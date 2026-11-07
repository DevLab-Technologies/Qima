import 'dart:math' as math;

/// How many decimal places a currency's smallest unit has (ISO 4217), and
/// conversion between major amounts and whole minor units.
///
/// The money ledger stores every amount as an integer count of minor units
/// (halalas, piastres, fils) so sums are exact: a balance never drifts by a
/// fraction of a halala however many lines it adds up.
abstract final class MinorUnits {
  /// Currencies whose minor unit is a thousandth.
  static const Set<String> _three = {'BHD', 'IQD', 'JOD', 'KWD', 'LYD', 'OMR', 'TND'};

  /// Currencies with no minor unit in use.
  static const Set<String> _zero = {
    'BIF', 'CLP', 'DJF', 'GNF', 'ISK', 'JPY', 'KMF', 'KRW', 'PYG', 'RWF', 'UGX', 'VND', 'VUV', 'XAF', 'XOF', 'XPF',
  };

  /// Decimal places of [currency]'s minor unit. Two unless listed above.
  static int digits(String currency) {
    if (_three.contains(currency)) return 3;
    if (_zero.contains(currency)) return 0;
    return 2;
  }

  static int _scale(String currency) => math.pow(10, digits(currency)).toInt();

  /// [major] in whole minor units of [currency], rounded half away from zero.
  static int fromMajor(num major, String currency) => (major * _scale(currency)).round();

  /// [minor] units of [currency] as a major amount, for display and FX maths.
  static double toMajor(int minor, String currency) => minor / _scale(currency);
}
