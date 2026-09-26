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
import 'package:qima/screens/instrument_detail_screen.dart';
import 'package:qima/screens/portfolio_detail_screen.dart';
import 'package:qima/screens/watchlist_screen.dart';
import 'package:qima/theme/app_theme.dart';

/// v2-A "Chart-first" smoke coverage: the three redesigned screens build
/// without error in both themes with a realistic populated state (a
/// multi-asset-class watchlist plus holdings, so the portfolio hero,
/// allocation donut and asset-class filter all actually render content
/// rather than their empty states), and the instrument detail screen no
/// longer exposes a "Load history" button (spec §v2-A: ranges lazily load
/// in the background instead of being gated behind an explicit action).
void main() {
  final gold = InstrumentCatalog.instrument('metal.XAU')!;
  final silver = InstrumentCatalog.instrument('metal.XAG')!;
  final btc = InstrumentCatalog.instrument('crypto.BTC')!;

  AppCubit populatedCubit() {
    final cubit = AppCubit();
    final now = DateTime(2024, 6, 10);
    final cards = [
      WatchCard(id: 'c1', instrumentID: gold.id, currency: 'USD', unit: PriceUnit.troyOunce),
      WatchCard(id: 'c2', instrumentID: silver.id, currency: 'USD', unit: PriceUnit.troyOunce),
      WatchCard(id: 'c3', instrumentID: btc.id, currency: 'USD', unit: PriceUnit.each),
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
      btc.id: QuoteSeries(instrumentID: btc.id, quotes: [
        Quote(instrumentID: btc.id, timestamp: now, canonicalUSD: 65000),
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

  Widget harness({required Widget home, required Brightness brightness, AppCubit? cubit}) {
    return BlocProvider<AppCubit>(
      create: (_) => cubit ?? populatedCubit(),
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: buildTheme(Brightness.light),
        darkTheme: buildTheme(Brightness.dark),
        themeMode: brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light,
        home: home,
      ),
    );
  }

  for (final brightness in [Brightness.light, Brightness.dark]) {
    testWidgets('WatchlistScreen builds in ${brightness.name} mode with hero + filter + rows', (tester) async {
      await tester.pumpWidget(harness(home: const WatchlistScreen(), brightness: brightness));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('InstrumentDetailScreen builds in ${brightness.name} mode', (tester) async {
      final card = WatchCard(id: 'c1', instrumentID: gold.id, currency: 'USD', unit: PriceUnit.troyOunce);
      await tester.pumpWidget(harness(
        home: InstrumentDetailScreen(card: card),
        brightness: brightness,
        cubit: populatedCubit(),
      ));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('PortfolioDetailScreen builds in ${brightness.name} mode', (tester) async {
      await tester.pumpWidget(harness(home: const PortfolioDetailScreen(), brightness: brightness));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('WatchlistScreen still builds cleanly with an empty watchlist', (tester) async {
    final cubit = AppCubit();
    cubit.emit(cubit.state.copyWith(initialized: true));
    await tester.pumpWidget(harness(home: const WatchlistScreen(), brightness: Brightness.dark, cubit: cubit));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('WatchlistScreen shows the loading state before initialization', (tester) async {
    final cubit = AppCubit();
    await tester.pumpWidget(harness(home: const WatchlistScreen(), brightness: Brightness.dark, cubit: cubit));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('PortfolioDetailScreen shows the empty state with no holdings', (tester) async {
    final cubit = AppCubit();
    cubit.emit(cubit.state.copyWith(initialized: true));
    await tester.pumpWidget(harness(home: const PortfolioDetailScreen(), brightness: Brightness.dark, cubit: cubit));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('InstrumentDetailScreen never shows a "Load history" button', (tester) async {
    final card = WatchCard(id: 'c1', instrumentID: gold.id, currency: 'USD', unit: PriceUnit.troyOunce);
    await tester.pumpWidget(harness(
      home: InstrumentDetailScreen(card: card),
      brightness: Brightness.dark,
      cubit: populatedCubit(),
    ));
    await tester.pump();

    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.text(l10n.detailLoadHistory), findsNothing);

    // Selecting the "All" range chip must not surface a "Load history"
    // button either — it lazily kicks off a background load instead.
    await tester.tap(find.text(l10n.rangeAll));
    await tester.pump();
    expect(find.text(l10n.detailLoadHistory), findsNothing);
  });

  testWidgets('InstrumentDetailScreen offers every default-selectable range plus All, and no 5Y chip', (tester) async {
    final card = WatchCard(id: 'c1', instrumentID: gold.id, currency: 'USD', unit: PriceUnit.troyOunce);
    await tester.pumpWidget(harness(
      home: InstrumentDetailScreen(card: card),
      brightness: Brightness.dark,
      cubit: populatedCubit(),
    ));
    await tester.pump();

    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    for (final label in [l10n.range1D, l10n.range3D, l10n.range7D, l10n.range1M, l10n.range3M, l10n.range6M, l10n.rangeYtd, l10n.range1Y, l10n.rangeAll]) {
      expect(find.text(label), findsOneWidget, reason: 'expected a $label chip');
    }
    expect(find.text(l10n.range5Y), findsNothing);
  });

  group('narrow-screen overflow (spec: no overflow across screen sizes)', () {
    testWidgets('WatchlistScreen on a small phone width', (tester) async {
      tester.view.physicalSize = const Size(360, 690);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(harness(home: const WatchlistScreen(), brightness: Brightness.dark));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('InstrumentDetailScreen on a small phone width', (tester) async {
      tester.view.physicalSize = const Size(360, 690);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final card = WatchCard(id: 'c1', instrumentID: gold.id, currency: 'USD', unit: PriceUnit.troyOunce);
      await tester.pumpWidget(harness(
        home: InstrumentDetailScreen(card: card),
        brightness: Brightness.dark,
        cubit: populatedCubit(),
      ));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('PortfolioDetailScreen on a small phone width', (tester) async {
      tester.view.physicalSize = const Size(360, 690);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(harness(home: const PortfolioDetailScreen(), brightness: Brightness.dark));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });

  group('RTL (Arabic locale) layout', () {
    Widget arabicHarness({required Widget home, AppCubit? cubit}) {
      return BlocProvider<AppCubit>(
        create: (_) => cubit ?? populatedCubit(),
        child: MaterialApp(
          locale: const Locale('ar'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: buildTheme(Brightness.dark),
          home: home,
        ),
      );
    }

    testWidgets('WatchlistScreen builds under RTL', (tester) async {
      await tester.pumpWidget(arabicHarness(home: const WatchlistScreen()));
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(Directionality.of(tester.element(find.byType(WatchlistScreen))), TextDirection.rtl);
    });

    testWidgets('PortfolioDetailScreen builds under RTL', (tester) async {
      await tester.pumpWidget(arabicHarness(home: const PortfolioDetailScreen()));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });
}
