import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qima/blocs/app_cubit.dart';
import 'package:qima/l10n/app_localizations.dart';
import 'package:qima/models/asset.dart';
import 'package:qima/models/fx_history.dart';
import 'package:qima/models/instrument_catalog.dart';
import 'package:qima/models/money.dart';
import 'package:qima/models/quote.dart';
import 'package:qima/models/watch_card.dart';
import 'package:qima/screens/help_index_sheet.dart';
import 'package:qima/screens/help_sheet.dart';
import 'package:qima/screens/home_shell.dart';
import 'package:qima/screens/onboarding_tour_screen.dart';
import 'package:qima/screens/settings_screen.dart';
import 'package:qima/screens/watchlist_screen.dart';
import 'package:qima/services/local_file_store.dart';
import 'package:qima/services/preferences.dart';
import 'package:qima/theme/help_topics.dart';
import 'package:qima/widgets/help_button.dart';
import 'package:qima/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Help button + help sheet behavior (spec "Help on every page" +
/// Engineering rules): the button is present on every listed page, opens
/// the right topic, the index sheet lists every topic, "Replay the tour"
/// from a sheet opens the tour, and RTL builds cleanly.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late AppCubit cubit;
  final gold = InstrumentCatalog.instrument('metal.XAU')!;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('qima_help_sheet_test');
    LocalFileStore.overrideDirectoryForTesting(tempDir);
    SharedPreferences.setMockInitialValues({});
    cubit = AppCubit();
    cubit.preferences = await Preferences.create();
    final now = DateTime(2024, 6, 10);
    final card = WatchCard(id: 'c1', instrumentID: gold.id, currency: 'USD', unit: PriceUnit.troyOunce);
    cubit.emit(cubit.state.copyWith(
      initialized: true,
      cards: [card],
      baseCurrency: 'USD',
      rates: FXRates(base: 'USD', rates: const {'USD': 1}, updatedAt: now),
      fxHistory: FXHistory.empty,
      seriesByID: {
        gold.id: QuoteSeries(instrumentID: gold.id, quotes: [
          Quote(instrumentID: gold.id, timestamp: now, canonicalUSD: 2000),
        ]),
      },
    ));
  });

  tearDown(() async {
    cubit.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  Widget harness(Widget child, {Locale locale = const Locale('en')}) {
    return BlocProvider<AppCubit>.value(
      value: cubit,
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: buildTheme(Brightness.dark),
        home: child,
      ),
    );
  }

  void setSurfaceSize(WidgetTester tester, Size size) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets('the help button is the first trailing action on the Watchlist app bar', (tester) async {
    setSurfaceSize(tester, const Size(400, 800));
    await tester.pumpWidget(harness(const WatchlistScreen(manageRefreshLifecycle: false)));
    await settle(tester);

    final appBar = tester.widget<AppBar>(find.byType(AppBar));
    final actions = appBar.actions!;
    expect(actions.first, isA<HelpButton>());
  });

  testWidgets('tapping the help button opens the right topic', (tester) async {
    setSurfaceSize(tester, const Size(400, 800));
    await tester.pumpWidget(harness(const WatchlistScreen(manageRefreshLifecycle: false)));
    await settle(tester);

    await tester.tap(find.byIcon(Icons.help_outline));
    await settle(tester);

    expect(find.byType(HelpSheet), findsOneWidget);
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.text(l10n.helpWatchlistTitle), findsOneWidget);
    expect(find.text(l10n.helpWatchlistStep1Title), findsOneWidget);
  });

  testWidgets('"Replay the tour" from a help sheet opens the tour', (tester) async {
    setSurfaceSize(tester, const Size(400, 800));
    await tester.pumpWidget(harness(const WatchlistScreen(manageRefreshLifecycle: false)));
    await settle(tester);

    await tester.tap(find.byIcon(Icons.help_outline));
    await settle(tester);

    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    await tester.tap(find.text(l10n.onboardingReplayTour));
    await settle(tester);

    expect(find.byType(OnboardingTourScreen), findsOneWidget);
  });

  testWidgets('the "How Qima works" index sheet lists every topic', (tester) async {
    setSurfaceSize(tester, const Size(400, 900));
    await tester.pumpWidget(harness(const SettingsScreen()));
    await settle(tester);

    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    // `scrollUntilVisible` only guarantees the target is painted somewhere
    // within the scrollable's bounds, not necessarily above `tap()`'s own
    // hit-test area at the very bottom edge — scroll a further fixed
    // amount past it so the row sits comfortably inside the viewport.
    await tester.scrollUntilVisible(find.text(l10n.settingsHelpHowQimaWorks), 300);
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -150));
    await settle(tester);
    await tester.tap(find.text(l10n.settingsHelpHowQimaWorks));
    await settle(tester);

    expect(find.byType(HelpIndexSheet), findsOneWidget);
    for (final id in HelpTopicId.values) {
      if (id == HelpTopicId.widgets && !widgetsSupportedOnThisPlatform) continue;
      final title = helpTopicFor(tester.element(find.byType(HelpIndexSheet)), id).title;
      // Scoped to the sheet: some topic titles ("Settings") also match text
      // still mounted behind the sheet (the underlying screen's app bar).
      expect(
        find.descendant(of: find.byType(HelpIndexSheet), matching: find.text(title)),
        findsOneWidget,
        reason: 'missing topic row: $title',
      );
    }
  });

  testWidgets('tapping a topic in the index sheet opens that topic', (tester) async {
    setSurfaceSize(tester, const Size(400, 900));
    await tester.pumpWidget(harness(const SettingsScreen()));
    await settle(tester);

    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    await tester.scrollUntilVisible(find.text(l10n.settingsHelpHowQimaWorks), 300);
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -150));
    await settle(tester);
    await tester.tap(find.text(l10n.settingsHelpHowQimaWorks));
    await settle(tester);

    await tester.tap(find.text(l10n.helpPortfolioTitle));
    await settle(tester);

    expect(find.byType(HelpSheet), findsOneWidget);
    expect(find.text(l10n.helpPortfolioStep1Title), findsOneWidget);
  });

  testWidgets('Settings Help group has Replay the tour and How Qima works', (tester) async {
    setSurfaceSize(tester, const Size(400, 1000));
    await tester.pumpWidget(harness(const SettingsScreen()));
    await settle(tester);

    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    await tester.scrollUntilVisible(find.text(l10n.settingsHelpReplayTour), 300);
    expect(find.text(l10n.settingsHelpReplayTour), findsOneWidget);
    expect(find.text(l10n.settingsHelpHowQimaWorks), findsOneWidget);
  });

  testWidgets('help button is present on every full-screen page listed in the spec', (tester) async {
    setSurfaceSize(tester, const Size(400, 900));
    await tester.pumpWidget(harness(const HomeShell()));
    await settle(tester);

    // Watchlist tab (default).
    expect(find.byType(HelpButton), findsWidgets);
  });

  testWidgets('builds under RTL (Arabic locale) without exceptions', (tester) async {
    setSurfaceSize(tester, const Size(400, 800));
    await tester.pumpWidget(harness(
      const WatchlistScreen(manageRefreshLifecycle: false),
      locale: const Locale('ar'),
    ));
    await settle(tester);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byIcon(Icons.help_outline));
    await settle(tester);
    expect(tester.takeException(), isNull);
    expect(find.byType(HelpSheet), findsOneWidget);
  });
}
