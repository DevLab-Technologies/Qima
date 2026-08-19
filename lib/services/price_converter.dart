import '../models/asset.dart';
import '../models/display_point.dart';
import '../models/fx_history.dart';
import '../models/metal_breakdown.dart';
import '../models/money.dart';
import '../models/quote.dart';

/// Pure currency/unit/karat conversion math — no I/O. Mirrors
/// `PriceConverter.swift` exactly, including the forward-cursor historical
/// FX walk (spec §2.1 / TC-P3/P6/P10-P12).
class PriceConverter {
  final FXRates rates;
  final String currencyCode;
  final PriceUnit unit;
  final GoldKarat? karat;
  final FXHistory history;

  const PriceConverter({
    required this.rates,
    required this.currencyCode,
    required this.unit,
    this.karat,
    this.history = FXHistory.empty,
  });

  double get purity => karat?.purity ?? 1;

  /// Uses the LATEST rate (not history) — this is the "live" conversion
  /// factor used for single-point conversions and as the flat-path
  /// fallback in [points].
  double get factor => (rates.rate(currencyCode) ?? 1) * unit.multiplier * purity;

  bool get canConvert => rates.rate(currencyCode) != null;

  Money money(double canonicalUSD) => Money(canonicalUSD * factor, currencyCode);

  Money moneyForQuote(Quote quote) => money(quote.canonicalUSD);

  Money absoluteChange(QuoteSeries series) => money(series.absoluteChangeUSD);

  /// Projects a full quote series into display terms. When [currencyCode]
  /// is USD, or there's no FX history for it, every point uses a flat
  /// multiplier (USD case: unit*purity only; other bases: the live [factor]
  /// applied uniformly). Otherwise walks both series (ascending by date) in
  /// a single forward-cursor pass, picking the most recent FX sample at or
  /// before each quote's timestamp (falling back to the earliest sample for
  /// quotes older than any sample, and holding the last sample flat for
  /// quotes newer than all samples). This walk MUST produce output
  /// identical to a naive independent per-point lookup (TC-P6/TC-P10).
  List<DisplayPoint> points(QuoteSeries series) {
    final samples = history.points(currencyCode);
    if (currencyCode == 'USD' || samples.isEmpty) {
      final flat = currencyCode == 'USD' ? (unit.multiplier * purity) : factor;
      return series.quotes
          .map((q) => DisplayPoint(date: q.timestamp, value: q.canonicalUSD * flat))
          .toList();
    }

    final multiplier = unit.multiplier * purity;
    final earliest = samples.first.perUSD;
    int cursor = 0;
    double? rate;
    final result = <DisplayPoint>[];
    for (final quote in series.quotes) {
      while (cursor < samples.length && !samples[cursor].date.isAfter(quote.timestamp)) {
        rate = samples[cursor].perUSD;
        cursor += 1;
      }
      final value = quote.canonicalUSD * (rate ?? earliest) * multiplier;
      result.add(DisplayPoint(date: quote.timestamp, value: value));
    }
    return result;
  }
}
