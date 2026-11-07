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
import 'package:qima/screens/money/balance_sheet_screen.dart';
import 'package:qima/screens/money/home_screen.dart';
import 'package:qima/screens/money/money_screen.dart';
import 'package:qima/screens/instrument_detail_screen.dart';
import 'package:qima/screens/settings_screen.dart';
import 'package:qima/screens/watchlist_screen.dart';
import 'package:qima/services/local_file_store.dart';
import 'package:qima/services/price_repository.dart';
import 'package:qima/theme/app_theme.dart';
import 'package:qima/widgets/portfolio_hero.dart';

import '../helpers/money_provider.dart';

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
    return MultiBlocProvider(providers: [BlocProvider<AppCubit>.value(value: cubit), testMoneyProvider(cubit)],
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

  /// The tab bar's button for [label] (the bar marks each tab as a
  /// labelled, selectable button).
  Finder tabButton(String label) =>
      find.byWidgetPredicate((w) => w is Semantics && w.properties.button == true && w.properties.label == label);

  Future<void> tapTab(WidgetTester tester, String label) async {
    await tester.tap(tabButton(label));
    await settle(tester);
  }

  void expectTabSelected(WidgetTester tester, String label) {
    expect(tester.widget<Semantics>(tabButton(label)).properties.selected, isTrue);
  }

  testWidgets('the phone bar has Home, Money and Prices, and Settings opens from Home', (tester) async {
    setSurfaceSize(tester, const Size(400, 800));
    await tester.pumpWidget(app(cubit));
    await settle(tester);

    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    expect(tabButton(l10n.navHome), findsOneWidget);
    expect(tabButton(l10n.navMoney), findsOneWidget);
    expect(tabButton(l10n.navPrices), findsOneWidget);
    expect(tabButton(l10n.settingsTitle), findsNothing);
    expect(find.byTooltip(l10n.addButton), findsOneWidget);
    expectTabSelected(tester, l10n.navHome);
    expect(find.byType(HomeScreen), findsOneWidget);

    await tester.tap(find.byTooltip(l10n.settingsTitle));
    await settle(tester);
    expect(find.byType(SettingsScreen), findsOneWidget);
    expect(find.byType(BackButton), findsOneWidget);
  });

  testWidgets('switching tabs preserves the Prices asset-class filter', (tester) async {
    // Add a non-metal card directly to state (not via `addCard`, which
    // round-trips through the on-disk store) so the filter renders.
    cubit.emit(cubit.state.copyWith(
      cards: [
        ...cubit.state.cards,
        WatchCard(id: 'c3', instrumentID: 'crypto.BTC', currency: 'USD', unit: PriceUnit.each),
      ],
    ));
    setSurfaceSize(tester, const Size(400, 800));
    await tester.pumpWidget(app(cubit));
    await settle(tester);
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));

    await tapTab(tester, l10n.navPrices);
    final cryptoChip = find.widgetWithText(ChoiceChip, 'Crypto');
    expect(cryptoChip, findsOneWidget);
    await tester.tap(cryptoChip);
    await settle(tester);

    await tapTab(tester, l10n.navMoney);
    expect(find.byType(MoneyScreen), findsOneWidget);
    // `IndexedStack` keeps inactive tabs mounted but offstage.
    expect(find.byType(WatchlistScreen, skipOffstage: false), findsOneWidget);

    await tapTab(tester, l10n.navPrices);
    expect(tester.widget<ChoiceChip>(cryptoChip).selected, isTrue);
  });

  testWidgets('the Prices tab has no portfolio total and no back button', (tester) async {
    setSurfaceSize(tester, const Size(400, 800));
    await tester.pumpWidget(app(cubit));
    await settle(tester);
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));

    await tapTab(tester, l10n.navPrices);
    expect(find.byType(BackButton), findsNothing);
    expect(find.descendant(of: find.byType(WatchlistScreen), matching: find.byType(PortfolioHero)), findsNothing);
  });

  testWidgets('Android back from Money returns to Home instead of exiting', (tester) async {
    setSurfaceSize(tester, const Size(400, 800));
    await tester.pumpWidget(app(cubit));
    await settle(tester);
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));

    await tapTab(tester, l10n.navMoney);
    expectTabSelected(tester, l10n.navMoney);

    await tester.binding.handlePopRoute();
    await settle(tester);
    expectTabSelected(tester, l10n.navHome);
  });

  testWidgets('before any account, Home shows the Portfolio total, and tapping it opens the balance sheet', (tester) async {
    setSurfaceSize(tester, const Size(400, 800));
    await tester.pumpWidget(app(cubit));
    await settle(tester);

    expect(find.byType(PortfolioHero), findsOneWidget);
    await tester.tap(find.byType(PortfolioHero));
    await settle(tester);
    expect(find.byType(BalanceSheetScreen), findsOneWidget);
  });

  testWidgets('add flow ends at [Shell, Detail] and Back shows the shell again', (tester) async {
    setSurfaceSize(tester, const Size(400, 800));
    await tester.pumpWidget(app(cubit));
    await settle(tester);

    await tester.tap(find.byIcon(Icons.add));
    final watch = find.byKey(const ValueKey('addSheetWatch')).hitTestable();
    for (var i = 0; i < 40 && watch.evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.tap(watch);
    await settle(tester);
    expect(find.byType(AddInstrumentScreen), findsOneWidget);

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
    expect(find.byType(HomeShell, skipOffstage: false), findsOneWidget);

    final navigator = tester.state<NavigatorState>(find.byType(Navigator).first);
    expect(navigator.canPop(), isTrue);
    navigator.pop();
    await settle(tester);

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(InstrumentDetailScreen), findsNothing);
  });

  testWidgets('a NavigationRail with three tabs, the + and Settings at the foot is used at width >= 600', (tester) async {
    setSurfaceSize(tester, const Size(900, 800));
    await tester.pumpWidget(app(cubit));
    await settle(tester);

    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(tester.widget<NavigationRail>(find.byType(NavigationRail)).destinations, hasLength(3));
    expect(find.byTooltip(l10n.addButton), findsOneWidget);
    // Settings sits at the rail's foot, not in Home's header.
    expect(find.descendant(of: find.byType(NavigationRail), matching: find.byTooltip(l10n.settingsTitle)), findsOneWidget);
    expect(find.byTooltip(l10n.settingsTitle), findsOneWidget);
  });

  testWidgets('refresh keeps running while another tab is showing', (tester) async {
    setSurfaceSize(tester, const Size(400, 800));
    await tester.pumpWidget(app(cubit));
    await settle(tester);
    final callsAfterMount = repository.refreshAllCallCount;
    expect(callsAfterMount, greaterThan(0));
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));

    await tapTab(tester, l10n.navMoney);

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
      MultiBlocProvider(providers: [BlocProvider<AppCubit>.value(value: cubit), testMoneyProvider(cubit)],
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
