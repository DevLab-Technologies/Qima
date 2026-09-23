import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

import 'currency_style.dart';

/// A currency-tagged amount with magnitude-aware formatting rules that
/// mirror the original Swift `Money` type exactly (see spec §1.3 / §8.1).
class Money extends Equatable {
  final double amount;
  final String currencyCode;

  const Money(this.amount, this.currencyCode);

  double get magnitude => amount.abs();

  /// Number of fraction digits to show, based on magnitude.
  ///
  /// Bands (deliberately not collapsed, to mirror the source 1:1):
  /// magnitude == 0 -> 2; < 1 -> 6; < 10 -> 4; < 10,000 -> 2; else -> 2.
  int get fractionDigits {
    final m = magnitude;
    if (m == 0) return 2;
    if (m < 1) return 6;
    if (m < 10) return 4;
    if (m < 10000) return 2;
    return 2;
  }

  /// Full-precision currency-formatted string with the currency's native
  /// symbol and placement, e.g. "$1,234.56" or "1,234.56 €".
  ///
  /// [useFallbackSymbol] swaps in a symbol system fonts can render, for
  /// surfaces outside Flutter (see [CurrencyStyle.fallbackSymbol]).
  String formatted({String? locale, bool useFallbackSymbol = false}) {
    final number = NumberFormat.decimalPatternDigits(
      locale: locale,
      decimalDigits: fractionDigits,
    ).format(magnitude);
    return CurrencyStyle.of(currencyCode).apply(
      number,
      isNegative: amount < 0,
      useFallbackSymbol: useFallbackSymbol,
    );
  }

  /// Compact currency-formatted string with k/M suffixes for large amounts,
  /// e.g. "$4.5k", "2.1M €". Values below 1,000 are shown unscaled.
  String compact({String? locale, bool useFallbackSymbol = false}) {
    final m = magnitude;
    double scaled = m;
    String suffix = '';
    if (m >= 1000000) {
      scaled = m / 1000000;
      suffix = 'M';
    } else if (m >= 1000) {
      scaled = m / 1000;
      suffix = 'k';
    }

    // 0 to 1 fraction digits: drop the decimal entirely when it rounds to a
    // whole number, otherwise show exactly one decimal place.
    final rounded1 = (scaled * 10).round() / 10;
    final isWhole = rounded1 == rounded1.truncateToDouble();
    final decimalDigits = isWhole ? 0 : 1;

    final number = NumberFormat.decimalPatternDigits(
      locale: locale,
      decimalDigits: decimalDigits,
    ).format(scaled);
    return CurrencyStyle.of(currencyCode).apply(
      '$number$suffix',
      isNegative: amount < 0,
      useFallbackSymbol: useFallbackSymbol,
    );
  }

  @override
  List<Object?> get props => [amount, currencyCode];
}

/// Live foreign-exchange rate table, always expressed relative to [base].
class FXRates extends Equatable {
  final String base;
  final Map<String, double> rates;
  final DateTime updatedAt;

  const FXRates({required this.base, required this.rates, required this.updatedAt});

  static final FXRates usdIdentity = FXRates(
    base: 'USD',
    rates: const {'USD': 1},
    updatedAt: DateTime.fromMillisecondsSinceEpoch(-8640000000000000, isUtc: true),
  );

  double? rate(String code) {
    if (code == base) return 1;
    return rates[code];
  }

  List<String> get availableCurrencies {
    final set = <String>{...rates.keys, base};
    final list = set.toList()..sort();
    return list;
  }

  @override
  List<Object?> get props => [base, rates, updatedAt];
}
