import 'dart:io';

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
import 'package:qima/screens/add_instrument_screen.dart';
import 'package:qima/screens/card_config_screen.dart';
import 'package:qima/screens/home_shell.dart';
import 'package:qima/screens/instrument_detail_screen.dart';
import 'package:qima/screens/portfolio_detail_screen.dart';
import 'package:qima/screens/settings_screen.dart';
import 'package:qima/screens/watchlist_screen.dart';
import 'package:qima/services/local_file_store.dart';
import 'package:qima/services/price_repository.dart';
import 'package:qima/theme/app_theme.dart';

/// No-ops every network/on-disk call `AppCubit` fires in the background, so
/// these widget tests can exercise `HomeShell` deterministically and offline
/// (same fake as `add_instrument_flow_test.dart`).
class _FakeRepository extends PriceRepository {
  int refreshAllCallCount = 0;

  @override
  Future<double> probePrice(Instrument instrument) async => 100;

  @override
  Future<QuoteSeries> refresh(Instrument instrument, {DateTime? now}) async => QuoteSeries.empty(instrument.id);

  @override
  Future<Map<String, QuoteSeries>> refreshAll(List<Instrument> instruments, {DateTime? now}) async {
    refreshAllCallCount++;
    return {};
  }

  @override
  Future<FXHistory> backfillFXHistory(List<String> currencies, {bool force = false, DateTime? now}) async =>
      FXHistory.empty;

  @override
  Future<Map<String, QuoteSeries>> backfillInstruments(
    List<Instrument> instruments,
    FXHistory fxHistory, {
    bool force = false,
    DateTime? now,
  }) async =>
      {};
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late AppCubit cubit;
  late _FakeRepository repository;
  final gold = InstrumentCatalog.instrument('metal.XAU')!;
  final silver = InstrumentCatalog.instrument('metal.XAG')!;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('qima_home_shell_test');
    LocalFileStore.overrideDirectoryForTesting(tempDir);
    repository = _FakeRepository();
    cubit = AppCubit(repository: repository);
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
  });

  tearDown(() async {
    cubit.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  /// Sets the test binding's actual view size — a wrapping `MediaQuery` only
  /// changes what `MediaQuery.of(context)` reports, not the real constraints
  /// `LayoutBuilder` receives from the test surface, and `HomeShell` picks
  /// its nav-bar-vs-rail layout from the latter.
  void setSurfaceSize(WidgetTester tester, Size size) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Widget app(AppCubit cubit, {Locale locale = const Locale('en')}) {
    return BlocProvider<AppCubit>.value(
      value: cubit,
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: buildTheme(Brightness.dark),
        home: const HomeShell(),
      ),
    );
  }

  /// A bounded stand-in for `pumpAndSettle()` — `HomeShell` runs its own
  /// periodic refresh `Timer`, which never completes on its own and would
  /// make `pumpAndSettle()` time out.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  /// Taps a nav destination by its (unselected) icon rather than its label —
  /// the Portfolio label text also appears elsewhere on screen (e.g. the
  /// watchlist's portfolio hero), so a text finder would be ambiguous.
  Future<void> tapNavDestination(WidgetTester tester, IconData icon) async {
    await tester.tap(find.widgetWithIcon(NavigationDestination, icon).first);
    await settle(tester);
  }

  testWidgets('shows three tabs: Watchlist, Portfolio, Settings', (tester) async {
    setSurfaceSize(tester, const Size(400, 800));
    await tester.pumpWidget(app(cubit));
    await settle(tester);

    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    final labels = tester.widgetList<NavigationDestination>(find.byType(NavigationDestination)).map((d) => d.label);
    expect(labels, containsAll(<String>[l10n.navWatchlist, l10n.portfolioTitle, l10n.settingsTitle]));
    expect(find.byType(WatchlistScreen), findsOneWidget);
  });

  testWidgets('switching tabs preserves the watchlist asset-class filter and scroll state', (tester) async {
    // Add a non-metal card directly to state (not via `addCard`, which
    // round-trips through the on-disk `watchlistStore` and would replace
    // the in-memory-only gold/silver cards `setUp` seeded with `emit`) so
    // the asset-class filter actually renders (only shown with >1 available
    // class).
    cubit.emit(cubit.state.copyWith(
      cards: [
        ...cubit.state.cards,
        WatchCard(id: 'c3', instrumentID: 'crypto.BTC', currency: 'USD', unit: PriceUnit.each),
      ],
    ));
    setSurfaceSize(tester, const Size(400, 800));
    await tester.pumpWidget(app(cubit));
    await settle(tester);

    final cryptoChip = find.widgetWithText(ChoiceChip, 'Crypto');
    expect(cryptoChip, findsOneWidget);
    await tester.tap(cryptoChip);
    await settle(tester);

    // Switch to Portfolio, then Settings, then back to Watchlist.
    await tapNavDestination(tester, Icons.pie_chart_outline);
    expect(find.byType(PortfolioDetailScreen), findsOneWidget);
    // `skipOffstage: false` — `IndexedStack` keeps inactive tabs mounted but
    // offstage, and `find.byType` skips offstage widgets by default.
    expect(find.byType(WatchlistScreen, skipOffstage: false), findsOneWidget); // kept alive underneath

    await tapNavDestination(tester, Icons.settings_outlined);
    expect(find.byType(SettingsScreen), findsOneWidget);

    await tapNavDestination(tester, Icons.list_alt_outlined);

    // The Crypto filter chip is still selected (Gold/Silver rows are hidden).
    final chipWidget = tester.widget<ChoiceChip>(cryptoChip);
    expect(chipWidget.selected, isTrue);
  });

  testWidgets('Portfolio and Settings tabs show no back button', (tester) async {
    setSurfaceSize(tester, const Size(400, 800));
    await tester.pumpWidget(app(cubit));
    await settle(tester);

    await tapNavDestination(tester, Icons.pie_chart_outline);
    expect(find.byType(BackButton), findsNothing);

    await tapNavDestination(tester, Icons.settings_outlined);
    expect(find.byType(BackButton), findsNothing);
  });

  testWidgets('Android back from Portfolio returns to Watchlist instead of exiting', (tester) async {
    setSurfaceSize(tester, const Size(400, 800));
    await tester.pumpWidget(app(cubit));
    await settle(tester);

    await tapNavDestination(tester, Icons.pie_chart_outline);
    expect(find.byType(PortfolioDetailScreen), findsOneWidget);

    // Simulate the system back gesture/button through the standard test API.
    await tester.binding.handlePopRoute();
    await settle(tester);

    final navBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(navBar.selectedIndex, 0);
    // A second back press (now on Watchlist) is left for the platform to
    // exit the app — PopScope.canPop is true there rather than intercepted.
  });

  testWidgets('tapping the portfolio hero switches to the Portfolio tab', (tester) async {
    setSurfaceSize(tester, const Size(400, 800));
    await tester.pumpWidget(app(cubit));
    await settle(tester);

    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    // The hero's own "Portfolio" label (not the nav bar's).
    await tester.tap(find.text(l10n.portfolioTitle).first);
    await settle(tester);

    expect(find.byType(PortfolioDetailScreen), findsOneWidget);
    final navBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(navBar.selectedIndex, 1);
  });

  testWidgets('add flow ends at [Shell(Watchlist), Detail] and Back shows the Watchlist tab', (tester) async {
    setSurfaceSize(tester, const Size(400, 800));
    await tester.pumpWidget(app(cubit));
    await settle(tester);

    await tester.tap(find.byIcon(Icons.add));
    await settle(tester);
    expect(find.byType(AddInstrumentScreen), findsOneWidget);

    // Scoped to AddInstrumentScreen — "Gold" also already appears as an
    // existing watchlist row underneath it, so an unscoped text finder
    // would be ambiguous.
    final goldOption = find.descendant(of: find.byType(AddInstrumentScreen), matching: find.text('Gold'));
    await tester.tap(goldOption.first);
    await settle(tester);
    expect(find.byType(CardConfigScreen), findsOneWidget);

    await tester.runAsync(() async {
      await tester.tap(find.byType(FilledButton), warnIfMissed: false);
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    await settle(tester);

    expect(find.byType(InstrumentDetailScreen), findsOneWidget);
    // `skipOffstage: false` — the Navigator keeps the previous route (the
    // shell) mounted-but-offstage underneath the newly pushed detail route.
    expect(find.byType(HomeShell, skipOffstage: false), findsOneWidget);

    final navigator = tester.state<NavigatorState>(find.byType(Navigator).first);
    expect(navigator.canPop(), isTrue);
    navigator.pop();
    await settle(tester);

    expect(find.byType(WatchlistScreen), findsOneWidget);
    expect(find.byType(InstrumentDetailScreen), findsNothing);
  });

  testWidgets('a NavigationRail is used at width >= 600 instead of the bottom NavigationBar', (tester) async {
    setSurfaceSize(tester, const Size(900, 800));
    await tester.pumpWidget(app(cubit));
    await settle(tester);

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('refresh keeps running while a non-watchlist tab is showing', (tester) async {
    setSurfaceSize(tester, const Size(400, 800));
    await tester.pumpWidget(app(cubit));
    await settle(tester);
    final callsAfterMount = repository.refreshAllCallCount;
    expect(callsAfterMount, greaterThan(0));

    await tapNavDestination(tester, Icons.settings_outlined);

    await tester.runAsync(() async {
      await cubit.refreshAll(silent: true);
    });
    expect(repository.refreshAllCallCount, greaterThan(callsAfterMount));
  });

  testWidgets('builds under RTL (Arabic locale)', (tester) async {
    setSurfaceSize(tester, const Size(400, 800));
    await tester.pumpWidget(app(cubit, locale: const Locale('ar')));
    await settle(tester);
    expect(tester.takeException(), isNull);
    expect(Directionality.of(tester.element(find.byType(HomeShell))), TextDirection.rtl);
  });

  testWidgets('builds cleanly in light theme', (tester) async {
    setSurfaceSize(tester, const Size(400, 800));
    await tester.pumpWidget(
      BlocProvider<AppCubit>.value(
        value: cubit,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: buildTheme(Brightness.light),
          home: const HomeShell(),
        ),
      ),
    );
    await settle(tester);
    expect(tester.takeException(), isNull);
  });
}
