import 'package:flutter_test/flutter_test.dart';
import 'package:qima/blocs/app_state.dart';
import 'package:qima/models/asset.dart';
import 'package:qima/models/fx_history.dart';
import 'package:qima/models/holding.dart';
import 'package:qima/models/metal_breakdown.dart';
import 'package:qima/models/money.dart';
import 'package:qima/models/quote.dart';
import 'package:qima/models/watch_card.dart';
import 'package:qima/services/widget_snapshot.dart';

void main() {
  final now = DateTime(2026, 9, 25, 12);
  const gold = 'metal.XAU';

  QuoteSeries hourly(String id, int hours, {double start = 2000}) => QuoteSeries(
        instrumentID: id,
        quotes: [
          for (var i = hours; i >= 0; i--)
            Quote(instrumentID: id, timestamp: now.subtract(Duration(hours: i)), canonicalUSD: start + (hours - i)),
        ],
      );

  AppState state({List<HoldingLot> lots = const [], bool hide = false}) => AppState(
        initialized: true,
        cards: const [
          WatchCard(id: 'c1', instrumentID: gold, currency: 'EGP', unit: PriceUnit.gram, karat: GoldKarat.k21),
          WatchCard(id: 'c2', instrumentID: 'unknown.ZZZ', currency: 'USD', unit: PriceUnit.each),
        ],
        lots: lots,
        seriesByID: {gold: hourly(gold, 24 * 40)},
        rates: FXRates(base: 'USD', rates: const {'USD': 1, 'EGP': 48.5, 'SAR': 3.75}, updatedAt: now),
        fxHistory: FXHistory(series: {
          'EGP': [FXHistoryPoint(date: now.subtract(const Duration(days: 2)), perUSD: 48)],
        }),
        hideBalances: hide,
      );

  test('carries cards, rates with widget-safe symbols, and FX history', () {
    final snapshot = WidgetSnapshot.build(state(), now: now);

    expect(snapshot['version'], WidgetSnapshot.schemaVersion);
    final cards = snapshot['cards'] as List;
    expect(cards, hasLength(1), reason: 'a card for an instrument that no longer resolves is dropped');
    expect(cards.single, {'id': 'c1', 'instrumentID': gold, 'currency': 'EGP', 'unit': 'gram', 'karat': 21});

    final currencies = snapshot['currencies'] as Map<String, dynamic>;
    expect(currencies['EGP'], {'rate': 48.5, 'symbol': 'ج.م', 'suffix': true});
    expect(currencies['SAR']['symbol'], 'ر.س', reason: 'system fonts lack the new Riyal sign');
    expect(currencies['USD'], {'rate': 1.0, 'symbol': r'$', 'suffix': false});
    expect((snapshot['fxHistory'] as Map)['EGP'], [
      [now.subtract(const Duration(days: 2)).millisecondsSinceEpoch, 48.0],
    ]);
  });

  test('each range window keeps the same first and last quote the app chart uses', () {
    final snapshot = WidgetSnapshot.build(state(), now: now);
    final instrument = (snapshot['instruments'] as List).single as Map<String, dynamic>;
    expect(instrument['karats'], [24, 22, 21, 18]);
    expect(instrument['units'], ['troyOunce', 'gram', 'kilogram']);

    final series = instrument['series'] as Map<String, dynamic>;
    final quotes = hourly(gold, 24 * 40).quotes;
    for (final entry in WidgetSnapshot.ranges.entries) {
      final points = series[entry.key] as List;
      final start = entry.value.startDate(now);
      final expected = start == null ? quotes : quotes.where((q) => !q.timestamp.isBefore(start)).toList();
      expect(points.length, lessThanOrEqualTo(WidgetSnapshot.maxPoints));
      expect(points.first, [expected.first.timestamp.millisecondsSinceEpoch, expected.first.canonicalUSD]);
      expect(points.last, [expected.last.timestamp.millisecondsSinceEpoch, expected.last.canonicalUSD]);
    }
    expect((series['1D'] as List).length, 25, reason: 'short windows are not thinned');
  });

  test('thin keeps both ends and caps the length', () {
    final items = List.generate(1000, (i) => i);
    final thinned = WidgetSnapshot.thin(items);
    expect(thinned, hasLength(WidgetSnapshot.maxPoints));
    expect(thinned.first, 0);
    expect(thinned.last, 999);
    expect(WidgetSnapshot.thin([1, 2, 3]), [1, 2, 3]);
  });

  test('portfolio values fine metal at the latest price and cost at live rates', () {
    final lots = [
      HoldingLot(
        id: 'l1',
        instrumentID: gold,
        quantity: 2,
        unit: PriceUnit.troyOunce,
        unitCost: 97000,
        costCurrency: 'EGP',
        date: now.subtract(const Duration(days: 10)),
      ),
      HoldingLot(
        id: 'l2',
        instrumentID: gold,
        quantity: PriceUnit.gramsPerTroyOunce,
        unit: PriceUnit.gram,
        unitCost: 60,
        costCurrency: 'USD',
        date: now.subtract(const Duration(days: 1)),
        karat: GoldKarat.k18,
      ),
    ];
    final snapshot = WidgetSnapshot.build(state(lots: lots, hide: true), now: now);
    expect(snapshot['hideBalances'], isTrue);

    final portfolio = snapshot['portfolio'] as Map<String, dynamic>;
    final latest = hourly(gold, 24 * 40).latest!.canonicalUSD;
    expect(portfolio['available'], isTrue);
    expect(portfolio['valueUSD'], closeTo((2 + 0.75) * latest, 1e-6));
    expect(portfolio['costUSD'], closeTo(2 * 97000 / 48.5 + PriceUnit.gramsPerTroyOunce * 60, 1e-6));

    final allTime = (portfolio['series'] as Map)['ALL'] as List;
    expect(allTime, hasLength(WidgetSnapshot.maxPoints));
    final first = allTime.first as List;
    final last = allTime.last as List;
    expect(DateTime.fromMillisecondsSinceEpoch(first[0] as int), now.subtract(const Duration(days: 10)),
        reason: '"All" starts at the first lot');
    expect(first[2], closeTo(2 * 97000 / 48.5, 1e-6), reason: 'the later lot is not counted yet');
    expect(last[1], closeTo(portfolio['valueUSD'] as double, 1e-6));
    expect(last[2], closeTo(portfolio['costUSD'] as double, 1e-6));
  });

  test('portfolio is unavailable without lots or without any price', () {
    expect(WidgetSnapshot.build(state(), now: now)['portfolio'], {'available': false});
    final unpriced = HoldingLot(
      id: 'l1',
      instrumentID: 'crypto.BTC',
      quantity: 1,
      unit: PriceUnit.each,
      unitCost: 1,
      costCurrency: 'USD',
      date: now,
    );
    expect(WidgetSnapshot.build(state(lots: [unpriced]), now: now)['portfolio'], {'available': false});
  });
}
