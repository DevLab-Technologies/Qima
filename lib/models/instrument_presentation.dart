import '../services/price_converter.dart';
import 'asset.dart';
import 'chart_range.dart';
import 'display_point.dart';
import 'metal_breakdown.dart';
import 'quote.dart';

/// A window-scoped change figure: the absolute and percent delta over
/// exactly the window it is displayed beside (spec §8.12 — never mix an
/// all-time percent with a bounded curve).
class RangeChange {
  final double absoluteValue;
  final double percentValue;
  final bool isUp;

  const RangeChange({required this.absoluteValue, required this.percentValue, required this.isUp});
}

/// View-projection layer over an [Instrument] + [QuoteSeries] +
/// [PriceConverter]. Mirrors `InstrumentPresentation.swift`.
class InstrumentPresentation {
  final Instrument instrument;
  final QuoteSeries series;
  final PriceConverter converter;

  List<DisplayPoint>? _pointsCache;

  InstrumentPresentation({required this.instrument, required this.series, required this.converter});

  /// Lazily-memoized projected points (avoids recomputing the FX walk
  /// multiple times per render).
  List<DisplayPoint> get points => _pointsCache ??= converter.points(series);

  String get symbol => instrument.symbol;

  String get displayCurrency => converter.currencyCode;

  bool get hasData => !series.isEmpty;

  /// Trailing 3-month window used for the watchlist row sparkline.
  List<DisplayPoint> sparklinePoints(DateTime now) => ChartRange.fallbackDefault.filter(points, now);

  /// Change over [range]. Returns null when the window has fewer than 2
  /// points or a zero-valued first point (never fabricates a flat 0%).
  RangeChange? change(ChartRange range, DateTime now) {
    final window = range.filter(points, now);
    if (window.length < 2) return null;
    final first = window.first.value;
    final last = window.last.value;
    if (first == 0) return null;
    final delta = last - first;
    final fraction = delta / first;
    return RangeChange(absoluteValue: delta, percentValue: fraction, isUp: fraction >= 0);
  }

  RangeChange? sparklineChange(DateTime now) => change(ChartRange.fallbackDefault, now);

  /// Whole-series (unbounded) trend, used by widgets/watch complications.
  bool get isTrendingUp {
    if (points.isEmpty) return true;
    return points.last.value >= points.first.value;
  }

  bool get isAvailable => hasData && converter.canConvert;

  /// Whole-series (unbounded) percent change; 0 if the series is degenerate.
  double get percentChange {
    if (points.length < 2) return 0;
    final first = points.first.value;
    if (first == 0) return 0;
    return (points.last.value - first) / first;
  }

  String? get unitSuffix => converter.unit.abbreviationKey;

  String? get karatLabel => converter.karat?.shortLabelKey;

  /// Latest price formatted in full or compact precision; "—" if no data.
  String get latestPrice {
    final latest = series.latest;
    if (latest == null) return '—';
    return converter.moneyForQuote(latest).formatted();
  }

  String get compactPrice {
    final latest = series.latest;
    if (latest == null) return '—';
    return converter.moneyForQuote(latest).compact();
  }

  /// Rows for the metal breakdown card: troy-ounce and kilogram prices,
  /// then either per-karat gram prices (gold) or a single plain gram price
  /// (other metals). Empty for non-metals or when there's no data.
  List<MetalBreakdownRow> get metalBreakdown {
    if (instrument.assetClass != AssetClass.metal || series.isEmpty) return const [];
    final latest = series.latest!;
    final rows = <MetalBreakdownRow>[];

    PriceConverter converterFor(PriceUnit unit, GoldKarat? karat) => PriceConverter(
          rates: converter.rates,
          currencyCode: converter.currencyCode,
          unit: unit,
          karat: karat,
          history: converter.history,
        );

    rows.add(MetalBreakdownRow(
      id: 'troyOunce',
      label: PriceUnit.troyOunce.labelKey,
      value: converterFor(PriceUnit.troyOunce, null).moneyForQuote(latest).formatted(),
    ));
    rows.add(MetalBreakdownRow(
      id: 'kilogram',
      label: PriceUnit.kilogram.labelKey,
      value: converterFor(PriceUnit.kilogram, null).moneyForQuote(latest).formatted(),
    ));

    if (instrument.supportedKarats.isNotEmpty) {
      for (final karat in instrument.supportedKarats) {
        rows.add(MetalBreakdownRow(
          id: 'gram-${karat.rawValue}',
          label: '${karat.shortLabelKey} ${PriceUnit.gram.abbreviationKey}',
          value: converterFor(PriceUnit.gram, karat).moneyForQuote(latest).formatted(),
        ));
      }
    } else {
      rows.add(MetalBreakdownRow(
        id: 'gram',
        label: PriceUnit.gram.labelKey,
        value: converterFor(PriceUnit.gram, null).moneyForQuote(latest).formatted(),
      ));
    }

    return rows;
  }
}
