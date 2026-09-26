import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qima/blocs/app_cubit.dart';
import 'package:qima/l10n/app_localizations.dart';
import 'package:qima/models/asset.dart';
import 'package:qima/models/fx_history.dart';
import 'package:qima/models/holding.dart';
import 'package:qima/models/instrument_catalog.dart';
import 'package:qima/models/money.dart';
import 'package:qima/models/quote.dart';
import 'package:qima/models/watch_card.dart';
import 'package:qima/screens/holdings_screen.dart';
import 'package:qima/screens/portfolio_detail_screen.dart';
import 'package:qima/screens/watchlist_screen.dart';
import 'package:qima/services/preferences.dart';
import 'package:qima/theme/app_theme.dart';
import 'package:qima/theme/masking.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Phase 4 "Hide balances": every money AMOUNT surface is masked while
/// hidden, but percentages and market prices always stay visible (spec
/// decision). Covers the watchlist portfolio hero, the portfolio screen
/// (hero + rows), and the holdings lot list.
void main() {
  final gold = InstrumentCatalog.instrument('metal.XAU')!;
  final silver = InstrumentCatalog.instrument('metal.XAG')!;

  // `toggleHideBalances`/`setHideBalances` persist through `AppCubit.preferences`,
  // which needs `Preferences.create()` to have run (mirrors `AppCubit.init()`)
  // — see theme_smoke_test.dart's "Appearance persistence" group for the same
  // pattern. SharedPreferences needs the plugin binary-messenger mocking
  // TestWidgetsFlutterBinding sets up, so this is set once per test file.
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<AppCubit> populatedCubit() async {
    final cubit = AppCubit();
    cubit.preferences = await Preferences.create();
    final now = DateTime(2024, 6, 10);
    final cards = [
      WatchCard(id: 'c1', instrumentID: gold.id, currency: 'USD', unit: PriceUnit.troyOunce),
      WatchCard(id: 'c2', instrumentID: silver.id, currency: 'USD', unit: PriceUnit.troyOunce),
    ];
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
      HoldingLot(
        id: 'l2',
        instrumentID: silver.id,
        quantity: 10,
        unit: PriceUnit.troyOunce,
        unitCost: 22,
        costCurrency: 'USD',
        date: DateTime(2024, 5, 15),
      ),
    ];
    final seriesByID = {
      gold.id: QuoteSeries(instrumentID: gold.id, quotes: [
        Quote(instrumentID: gold.id, timestamp: DateTime(2024, 5, 1), canonicalUSD: 1900),
        Quote(instrumentID: gold.id, timestamp: now, canonicalUSD: 2000),
      ]),
      silver.id: QuoteSeries(instrumentID: silver.id, quotes: [
        Quote(instrumentID: silver.id, timestamp: DateTime(2024, 5, 15), canonicalUSD: 22),
        Quote(instrumentID: silver.id, timestamp: now, canonicalUSD: 25),
      ]),
    };

    cubit.emit(cubit.state.copyWith(
      initialized: true,
      cards: cards,
      lots: lots,
      seriesByID: seriesByID,
      rates: FXRates(base: 'USD', rates: const {'USD': 1}, updatedAt: now),
      fxHistory: FXHistory.empty,
      baseCurrency: 'USD',
    ));
    return cubit;
  }

  Widget harness({required Widget home, required AppCubit cubit}) {
    return BlocProvider<AppCubit>.value(
      value: cubit,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: buildTheme(Brightness.dark),
        home: home,
      ),
    );
  }

  testWidgets('watchlist hero masks the portfolio value when hidden, and unmasks on toggle', (tester) async {
    final cubit = await populatedCubit();
    final valuation = cubit.portfolioValuation!;
    await tester.pumpWidget(harness(home: const WatchlistScreen(), cubit: cubit));
    await tester.pump();

    expect(find.text(valuation.value.formatted()), findsOneWidget);
    expect(find.text(Masking.mask), findsNothing);

    await cubit.toggleHideBalances();
    await tester.pump();

    expect(find.text(valuation.value.formatted()), findsNothing);
    expect(find.text(Masking.mask), findsOneWidget);

    // Tapping the eye icon toggles it back off.
    await tester.tap(find.byIcon(Icons.visibility_off_outlined));
    await tester.pump();
    expect(find.text(valuation.value.formatted()), findsOneWidget);
    expect(find.text(Masking.mask), findsNothing);
  });

  testWidgets(
      'PortfolioDetailScreen masks value/cost/gain amounts but keeps the allocation weight percent and the app bar toggle works',
      (tester) async {
    final cubit = await populatedCubit();
    final valuation = cubit.portfolioValuation!;
    final held = cubit.heldInstruments.first;
    final weightPercent = (held.valuation.value.amount / valuation.value.amount * 100).toStringAsFixed(1);
    await tester.pumpWidget(harness(home: const PortfolioDetailScreen(), cubit: cubit));
    await tester.pump();

    expect(find.text(valuation.value.formatted()), findsOneWidget);

    await tester.tap(find.byIcon(Icons.visibility_outlined));
    await tester.pump();

    expect(find.text(valuation.value.formatted()), findsNothing);
    expect(find.textContaining(Masking.mask), findsWidgets);
    // The allocation weight percent (a %, not an amount) is never masked.
    expect(find.textContaining('$weightPercent%'), findsWidgets);
  });

  testWidgets('HoldingsScreen masks lot unit cost and total cost but not the raw quantity', (tester) async {
    final cubit = await populatedCubit();
    await cubit.toggleHideBalances();
    final lot = cubit.lotsFor(gold)[0];

    await tester.pumpWidget(harness(
      home: HoldingsScreen(instrument: gold, displayCurrency: 'USD'),
      cubit: cubit,
    ));
    await tester.pump();

    // Quantity ("2 oz t") is not a money amount and must stay visible.
    expect(find.textContaining('2'), findsWidgets);
    // Unit cost / total cost are money amounts and must be masked.
    expect(find.text(Money(lot.unitCost, lot.costCurrency).formatted()), findsNothing);
    expect(find.text(Money(lot.totalCost, lot.costCurrency).formatted()), findsNothing);
    expect(find.textContaining(Masking.mask), findsWidgets);
  });
}
