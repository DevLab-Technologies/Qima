import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qima/blocs/app_state.dart';
import 'package:qima/models/asset.dart';
import 'package:qima/models/fx_history.dart';
import 'package:qima/models/holding.dart';
import 'package:qima/models/instrument_catalog.dart';
import 'package:qima/models/money.dart';
import 'package:qima/models/quote.dart';
import 'package:qima/services/home_widget_service.dart';
import 'package:qima/theme/masking.dart';

/// Phase 4 "Hide balances": [HomeWidgetService] publishes masked portfolio
/// strings (plus a `hidden` flag) whenever [AppState.hideBalances] is on, so
/// the Android Glance portfolio widget never renders a real amount while
/// hidden — spec explicitly calls this out since it's a surface outside
/// Flutter's own widget tree that's easy to forget.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('home_widget');
  final gold = InstrumentCatalog.instrument('metal.XAU')!;

  Map<String, dynamic>? lastPortfolioPayload;

  setUp(() {
    lastPortfolioPayload = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'saveWidgetData') {
        final args = Map<String, dynamic>.from(call.arguments as Map);
        if (args['id'] == HomeWidgetService.portfolioWidgetDataKey) {
          lastPortfolioPayload = jsonDecode(args['data'] as String) as Map<String, dynamic>;
        }
      }
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  AppState stateWithLot({required bool hideBalances}) {
    final now = DateTime(2024, 6, 10);
    final lots = [
      HoldingLot(
        id: 'l1',
        instrumentID: gold.id,
        quantity: 2,
        unit: PriceUnit.troyOunce,
        unitCost: 1900,
        costCurrency: 'USD',
        date: DateTime(2024, 5, 1),
      ),
    ];
    final seriesByID = {
      gold.id: QuoteSeries(instrumentID: gold.id, quotes: [
        Quote(instrumentID: gold.id, timestamp: now, canonicalUSD: 2000),
      ]),
    };
    return AppState(
      initialized: true,
      lots: lots,
      seriesByID: seriesByID,
      rates: FXRates(base: 'USD', rates: const {'USD': 1}, updatedAt: now),
      fxHistory: FXHistory.empty,
      baseCurrency: 'USD',
      hideBalances: hideBalances,
    );
  }

  test('publishes the real formatted amounts when hideBalances is off', () async {
    final state = stateWithLot(hideBalances: false);
    await HomeWidgetService.publish(state);

    final valuation = HoldingValuation.aggregate(
      lots: state.lots,
      rates: state.rates,
      displayCurrency: state.baseCurrency,
      latestUSD: (id) => state.seriesByID[id]?.latest?.canonicalUSD,
    )!;

    expect(lastPortfolioPayload, isNotNull);
    expect(lastPortfolioPayload!['hidden'], isFalse);
    expect(lastPortfolioPayload!['value'], valuation.value.formatted(useFallbackSymbol: true));
    expect(lastPortfolioPayload!['gain'], valuation.gain.formatted(useFallbackSymbol: true));
    expect(lastPortfolioPayload!['cost'], valuation.cost.formatted(useFallbackSymbol: true));
  });

  test('publishes masked amounts (but a real percent) when hideBalances is on', () async {
    final state = stateWithLot(hideBalances: true);
    await HomeWidgetService.publish(state);

    final valuation = HoldingValuation.aggregate(
      lots: state.lots,
      rates: state.rates,
      displayCurrency: state.baseCurrency,
      latestUSD: (id) => state.seriesByID[id]?.latest?.canonicalUSD,
    )!;

    expect(lastPortfolioPayload, isNotNull);
    expect(lastPortfolioPayload!['hidden'], isTrue);
    expect(lastPortfolioPayload!['value'], Masking.mask);
    expect(lastPortfolioPayload!['gain'], Masking.mask);
    expect(lastPortfolioPayload!['cost'], Masking.mask);
    // Percent stays real even while amounts are masked.
    expect(lastPortfolioPayload!['percent'], closeTo(valuation.gainFraction * 100, 0.0001));
  });
}
