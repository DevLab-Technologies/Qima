import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qima/blocs/app_cubit.dart';
import 'package:qima/blocs/money_cubit.dart';
import 'package:qima/l10n/app_localizations.dart';
import 'package:qima/models/asset.dart';
import 'package:qima/models/fx_history.dart';
import 'package:qima/models/money.dart';
import 'package:qima/models/money_settings.dart';
import 'package:qima/models/quote.dart';
import 'package:qima/models/setup_answers.dart';
import 'package:qima/screens/setup_flow_screen.dart';
import 'package:qima/services/local_file_store.dart';
import 'package:qima/services/preferences.dart';
import 'package:qima/services/price_repository.dart';
import 'package:qima/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Keeps `AppCubit.addCard`'s background refresh and backfill off the
/// network (same fake as `home_shell_test.dart`).
class _FakeRepository extends PriceRepository {
  @override
  Future<QuoteSeries> refresh(Instrument instrument, {DateTime? now}) async => QuoteSeries.empty(instrument.id);

  @override
  Future<Map<String, QuoteSeries>> refreshAll(List<Instrument> instruments, {DateTime? now}) async => {};

  @override
  Future<FXHistory> backfillFXHistory(List<String> currencies, {bool force = false, DateTime? now}) async => FXHistory.empty;

  @override
  Future<Map<String, QuoteSeries>> backfillInstruments(
    List<Instrument> instruments,
    FXHistory fxHistory, {
    bool force = false,
    DateTime? now,
  }) async =>
      {};
}

/// Setup's screens: which questions follow which answers, that nothing
/// changes before the end, what the answers switch on, and that it lays out
/// in Arabic and on a small screen with large text.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late AppCubit cubit;
  late MoneyCubit money;
  late AppLocalizations l10n;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('qima_setup_flow_test');
    LocalFileStore.overrideDirectoryForTesting(tempDir);
    SharedPreferences.setMockInitialValues({});
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
    cubit = AppCubit(repository: _FakeRepository());
    cubit.preferences = await Preferences.create();
    // A fresh install: the seeded watchlist and nothing else.
    final seed = await cubit.preferences.seedWatchcards();
    for (final card in seed) {
      await cubit.watchlistStore.upsert(card);
    }
    cubit.emit(cubit.state.copyWith(
      initialized: true,
      baseCurrency: 'USD',
      cards: seed,
      shouldShowOnboarding: true,
      rates: FXRates(base: 'USD', rates: const {'USD': 1, 'EUR': 0.92, 'EGP': 48, 'SAR': 3.75}, updatedAt: DateTime(2024, 6, 10)),
      fxHistory: FXHistory.empty,
    ));
    // Loaded here, on the real clock: the book reads files.
    money = MoneyCubit(store: cubit.bookStore, baseCurrency: () => cubit.state.baseCurrency, rates: () => cubit.state.rates);
    await money.load();
  });

  tearDown(() async {
    await money.close();
    await cubit.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  void setSurfaceSize(WidgetTester tester, Size size) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Widget harness({Locale locale = const Locale('en'), bool rerun = false, double textScale = 1}) {
    return MultiBlocProvider(
      providers: [BlocProvider<AppCubit>.value(value: cubit), BlocProvider<MoneyCubit>.value(value: money)],
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: buildTheme(Brightness.light),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: rerun
            ? Builder(
                builder: (context) => Scaffold(
                  body: TextButton(
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const SetupFlowScreen(rerun: true))),
                    child: const Text('open'),
                  ),
                ),
              )
            : const SetupFlowScreen(),
      ),
    );
  }

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.ensureVisible(find.text(text));
    await tester.pump();
    await tester.tap(find.text(text));
    await settle(tester);
  }

  /// A tap that ends setup. Applying the answers writes files, which only
  /// the real clock moves along, so the tap and the wait for [done] (by
  /// default, onboarding marked finished, which is what makes `main.dart`
  /// show the home shell) run on it.
  Future<void> tapToFinish(WidgetTester tester, String text, {bool Function()? done}) async {
    final isDone = done ?? () => !cubit.state.shouldShowOnboarding;
    await tester.ensureVisible(find.text(text));
    await tester.pump();
    await tester.runAsync(() async {
      await tester.tap(find.text(text));
      for (var i = 0; i < 60 && !isDone(); i++) {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      }
    });
    await settle(tester);
  }

  FilledButton primary(WidgetTester tester) => tester.widget<FilledButton>(find.byType(FilledButton));

  testWidgets('money and portfolio lead through every question and switch on what was chosen', (tester) async {
    setSurfaceSize(tester, const Size(400, 900));
    await tester.pumpWidget(harness());
    await settle(tester);

    expect(find.text(l10n.setupWelcomeTitle), findsOneWidget);
    await tapText(tester, l10n.onboardingGetStarted);

    expect(find.text(l10n.setupCurrencyTitle), findsOneWidget);
    await tapText(tester, l10n.commonContinue);

    // Continue waits for a choice on the question everything else hangs on.
    expect(find.text(l10n.setupUsesTitle), findsOneWidget);
    expect(primary(tester).onPressed, isNull);
    await tapText(tester, l10n.setupUseMoney);
    await tapText(tester, l10n.setupUsePortfolio);
    expect(find.text(l10n.setupChosen(2)), findsOneWidget);
    await tapText(tester, l10n.commonContinue);

    expect(find.text(l10n.setupProductsTitle), findsOneWidget);
    await tapText(tester, l10n.setupProductMetals);
    await tapText(tester, l10n.commonContinue);

    // Gold is ticked, silver is offered unticked.
    expect(find.text(l10n.setupPricesTitle), findsOneWidget);
    await tapText(tester, l10n.setupPricesAdd(1));

    expect(find.text(l10n.setupGoalsTitle), findsOneWidget);
    await tapText(tester, l10n.setupGoalBudget);
    await tapText(tester, l10n.commonContinue);

    expect(find.text(l10n.setupCaptureTitle), findsOneWidget);
    await tapText(tester, l10n.commonContinue);

    // Nothing has been changed yet.
    expect(find.text(l10n.setupSummaryTitle), findsOneWidget);
    expect(money.state.settings.features, isEmpty);
    expect(cubit.state.setup, isNull);
    expect(cubit.state.cards, hasLength(3));

    await tapToFinish(tester, l10n.setupSummaryGoHome);

    expect(cubit.state.shouldShowOnboarding, isFalse);
    expect(cubit.state.tourRequested, isFalse);
    expect(money.state.settings.features, {MoneyFeature.budget});
    expect(cubit.state.setup, const SetupAnswers(uses: {SetupUse.money, SetupUse.portfolio}, products: {SetupProduct.metals}, goals: {SetupGoal.budget}));
    expect(cubit.preferences.onboardingCompleted, isTrue);
    expect(cubit.preferences.setupAnswers, cubit.state.setup);
    // The seeded silver and bitcoin make way for the pick; gold was both.
    expect([for (final c in cubit.state.cards) c.instrumentID], ['metal.XAU']);
  });

  testWidgets('"Show me around" asks for the tour', (tester) async {
    setSurfaceSize(tester, const Size(400, 900));
    await tester.pumpWidget(harness());
    await settle(tester);

    await tapText(tester, l10n.onboardingGetStarted);
    await tapText(tester, l10n.commonContinue);
    await tapText(tester, l10n.setupUseNetWorth);
    await tapText(tester, l10n.commonContinue);
    // Net worth alone adds no questions.
    expect(find.text(l10n.setupSummaryTitle), findsOneWidget);
    await tapToFinish(tester, l10n.setupSummaryTour);

    expect(cubit.state.shouldShowOnboarding, isFalse);
    expect(cubit.state.tourRequested, isTrue);
    expect(cubit.state.setup, const SetupAnswers(uses: {SetupUse.netWorth}));
  });

  testWidgets('skipping from the welcome screen answers nothing and leaves the app as it was', (tester) async {
    setSurfaceSize(tester, const Size(400, 900));
    await tester.pumpWidget(harness());
    await settle(tester);

    await tapToFinish(tester, l10n.setupWelcomeSkip);

    expect(cubit.state.shouldShowOnboarding, isFalse);
    expect(cubit.state.tourRequested, isFalse);
    expect(cubit.state.setup, isNull);
    expect(cubit.preferences.onboardingCompleted, isTrue);
    expect(money.state.settings.features, isEmpty);
    expect(cubit.state.cards, hasLength(3));
  });

  testWidgets('Skip on a question keeps the answers so far', (tester) async {
    setSurfaceSize(tester, const Size(400, 900));
    await tester.pumpWidget(harness());
    await settle(tester);

    await tapText(tester, l10n.onboardingGetStarted);
    await tapText(tester, l10n.commonContinue);
    await tapText(tester, l10n.setupUseZakat);
    await tapText(tester, l10n.setupUseMoney);
    await tapText(tester, l10n.commonContinue);
    expect(find.text(l10n.setupGoalsTitle), findsOneWidget);
    await tapToFinish(tester, l10n.onboardingSkip);

    expect(cubit.state.shouldShowOnboarding, isFalse);
    expect(cubit.state.tourRequested, isFalse);
    expect(cubit.state.setup?.uses, {SetupUse.zakat, SetupUse.money});
    expect(money.state.settings.features, {MoneyFeature.zakat});
  });

  testWidgets('"Not now" on the prices leaves the watchlist alone', (tester) async {
    setSurfaceSize(tester, const Size(400, 900));
    await tester.pumpWidget(harness());
    await settle(tester);

    await tapText(tester, l10n.onboardingGetStarted);
    await tapText(tester, l10n.commonContinue);
    await tapText(tester, l10n.setupUsePrices);
    await tapText(tester, l10n.commonContinue);
    await tapText(tester, l10n.setupProductCrypto);
    await tapText(tester, l10n.commonContinue);
    await tapText(tester, l10n.setupPricesNotNow);
    expect(find.text(l10n.setupSummaryWatchlistKept), findsOneWidget);
    await tapToFinish(tester, l10n.setupSummaryGoHome);

    expect([for (final c in cubit.state.cards) c.instrumentID], ['metal.XAU', 'metal.XAG', 'crypto.BTC']);
  });

  testWidgets('picking a currency applies at once, so the prices are offered in it', (tester) async {
    setSurfaceSize(tester, const Size(400, 900));
    await tester.pumpWidget(harness());
    await settle(tester);

    await tapText(tester, l10n.onboardingGetStarted);
    await tapText(tester, 'Egyptian Pound');
    expect(cubit.state.baseCurrency, 'EGP');
    await tapText(tester, l10n.commonContinue);
    await tapText(tester, l10n.setupUsePrices);
    await tapText(tester, l10n.commonContinue);
    await tapText(tester, l10n.setupProductMetals);
    await tapText(tester, l10n.commonContinue);

    expect(find.text(l10n.setupPricesBody('EGP')), findsOneWidget);
    // 24K and 21K by the gram are ticked.
    await tapText(tester, l10n.setupPricesAdd(2));
    await tapToFinish(tester, l10n.setupSummaryGoHome);

    expect([for (final c in cubit.state.cards) (c.instrumentID, c.currency, c.unit)], [
      ('metal.XAU', 'EGP', PriceUnit.gram),
      ('metal.XAU', 'EGP', PriceUnit.gram),
    ]);
  });

  testWidgets('Back returns to the previous question with its answers kept', (tester) async {
    setSurfaceSize(tester, const Size(400, 900));
    await tester.pumpWidget(harness());
    await settle(tester);

    await tapText(tester, l10n.onboardingGetStarted);
    await tapText(tester, l10n.commonContinue);
    await tapText(tester, l10n.setupUseMoney);
    await tapText(tester, l10n.commonContinue);
    expect(find.text(l10n.setupGoalsTitle), findsOneWidget);

    await tester.tap(find.byType(BackButtonIcon));
    await settle(tester);

    expect(find.text(l10n.setupUsesTitle), findsOneWidget);
    expect(find.text(l10n.setupChosen(1)), findsOneWidget);
  });

  testWidgets('running setup again starts from the last answers and never turns a feature off', (tester) async {
    setSurfaceSize(tester, const Size(400, 900));
    await tester.runAsync(() async {
      await cubit.saveSetup(const SetupAnswers(uses: {SetupUse.money}, goals: {SetupGoal.budget}));
      await money.setFeatures({MoneyFeature.budget, MoneyFeature.loans});
    });
    await tester.pumpWidget(harness(rerun: true));
    await settle(tester);
    await tester.tap(find.text('open'));
    await settle(tester);

    // No welcome screen and no Skip: Back leaves without changing anything.
    expect(find.text(l10n.setupCurrencyTitle), findsOneWidget);
    expect(find.text(l10n.onboardingSkip), findsNothing);
    await tapText(tester, l10n.commonContinue);
    expect(find.text(l10n.setupChosen(1)), findsOneWidget);
    await tapText(tester, l10n.commonContinue);
    // Unticking the goal does not switch Budget off.
    await tapText(tester, l10n.setupGoalBudget);
    await tapText(tester, l10n.setupGoalPeople);
    await tapText(tester, l10n.commonContinue);
    await tapText(tester, l10n.commonContinue);
    await tapToFinish(tester, l10n.commonDone, done: () => cubit.state.setup?.goals.contains(SetupGoal.people) ?? false);

    expect(find.byType(SetupFlowScreen), findsNothing);
    expect(money.state.settings.features, {MoneyFeature.budget, MoneyFeature.loans, MoneyFeature.people});
    expect(cubit.state.setup?.goals, {SetupGoal.people});
    expect(cubit.state.tourRequested, isFalse);
  });

  testWidgets('lays out in Arabic on a small screen with large text', (tester) async {
    setSurfaceSize(tester, const Size(320, 568));
    final ar = await AppLocalizations.delegate.load(const Locale('ar'));
    await tester.pumpWidget(harness(locale: const Locale('ar'), textScale: 1.6));
    await settle(tester);

    expect(Directionality.of(tester.element(find.text(ar.setupWelcomeTitle))), TextDirection.rtl);
    await tapText(tester, ar.onboardingGetStarted);
    await tapText(tester, ar.commonContinue);
    await tapText(tester, ar.setupUseMoney);
    await tapText(tester, ar.setupUsePortfolio);
    await tapText(tester, ar.commonContinue);
    await tapText(tester, ar.setupProductMetals);
    await tapText(tester, ar.commonContinue);
    await tapText(tester, ar.setupPricesNotNow);
    await tapText(tester, ar.commonContinue);
    await tapText(tester, ar.commonContinue);

    expect(find.text(ar.setupSummaryTitle), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
