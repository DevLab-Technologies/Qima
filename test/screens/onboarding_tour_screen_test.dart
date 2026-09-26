import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qima/blocs/app_cubit.dart';
import 'package:qima/l10n/app_localizations.dart';
import 'package:qima/models/fx_history.dart';
import 'package:qima/models/money.dart';
import 'package:qima/screens/home_shell.dart';
import 'package:qima/screens/onboarding_tour_screen.dart';
import 'package:qima/services/local_file_store.dart';
import 'package:qima/services/preferences.dart';
import 'package:qima/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Onboarding tour widget behavior (spec "Onboarding tour" + Engineering
/// rules): page dots, Skip under Next and absent on the last step, Get
/// started completing the tour and landing on the home shell, the base
/// currency row saving via the real [AppCubit], RTL, and no overflow at a
/// small size with large text.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late AppCubit cubit;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('qima_onboarding_tour_screen_test');
    LocalFileStore.overrideDirectoryForTesting(tempDir);
    SharedPreferences.setMockInitialValues({});
    cubit = AppCubit();
    cubit.preferences = await Preferences.create();
    final now = DateTime(2024, 6, 10);
    cubit.emit(cubit.state.copyWith(
      initialized: true,
      baseCurrency: 'USD',
      rates: FXRates(base: 'USD', rates: const {'USD': 1, 'GBP': 0.78}, updatedAt: now),
      fxHistory: FXHistory.empty,
    ));
  });

  tearDown(() async {
    cubit.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  Widget harness({Locale locale = const Locale('en'), Size? surfaceSize, double textScale = 1}) {
    return BlocProvider<AppCubit>.value(
      value: cubit,
      child: MediaQuery(
        data: MediaQueryData(
          size: surfaceSize ?? const Size(400, 800),
          textScaler: TextScaler.linear(textScale),
        ),
        child: MaterialApp(
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: buildTheme(Brightness.dark),
          home: const OnboardingTourScreen(),
        ),
      ),
    );
  }

  void setSurfaceSize(WidgetTester tester, Size size) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('steps 1-4 show Next and Skip under it; Skip is absent on step 5', (tester) async {
    setSurfaceSize(tester, const Size(400, 800));
    await tester.pumpWidget(harness());
    await tester.pump();

    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.widgetWithText(FilledButton, l10n.onboardingNext), findsOneWidget);
    final nextCenter = tester.getCenter(find.widgetWithText(FilledButton, l10n.onboardingNext));
    final skipCenter = tester.getCenter(find.widgetWithText(TextButton, l10n.onboardingSkip));
    expect(skipCenter.dy, greaterThan(nextCenter.dy));

    // Swipe through to the last step.
    for (var i = 0; i < 4; i++) {
      await tester.tap(find.widgetWithText(FilledButton, l10n.onboardingNext).last);
      await tester.pumpAndSettle();
    }

    expect(find.text(l10n.onboardingGetStarted), findsOneWidget);
    // The Skip button's space is kept reserved so the primary button never
    // jumps (spec "keep the vertical space where Skip would be"), so it's
    // still in the tree — but it must be invisible and untappable. Its
    // nearest `IgnorePointer`/`Opacity` ancestors are the ones the screen
    // itself wraps it in (`.first`, closest to the widget), not any
    // framework-internal one further up the tree (e.g. inside `PageView`).
    final ignorePointer = tester.widgetList<IgnorePointer>(find.ancestor(
      of: find.text(l10n.onboardingSkip),
      matching: find.byType(IgnorePointer),
    )).first;
    expect(ignorePointer.ignoring, isTrue);
    final opacity = tester.widgetList<Opacity>(find.ancestor(
      of: find.text(l10n.onboardingSkip),
      matching: find.byType(Opacity),
    )).first;
    expect(opacity.opacity, 0);
  });

  testWidgets('page dots show 5 steps with the first highlighted initially', (tester) async {
    setSurfaceSize(tester, const Size(400, 800));
    await tester.pumpWidget(harness());
    await tester.pump();

    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.bySemanticsLabel(l10n.onboardingSemanticStepOf(1, 5)), findsOneWidget);
    expect(find.bySemanticsLabel(l10n.onboardingSemanticStepOf(5, 5)), findsOneWidget);
  });

  testWidgets('Get started completes onboarding and pops', (tester) async {
    setSurfaceSize(tester, const Size(400, 800));
    var finished = false;
    await tester.pumpWidget(BlocProvider<AppCubit>.value(
      value: cubit,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: buildTheme(Brightness.dark),
        home: OnboardingTourScreen(onFinished: () => finished = true),
      ),
    ));
    await tester.pump();

    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    for (var i = 0; i < 4; i++) {
      await tester.tap(find.widgetWithText(FilledButton, l10n.onboardingNext).last);
      await tester.pumpAndSettle();
    }
    await tester.tap(find.widgetWithText(FilledButton, l10n.onboardingGetStarted));
    await tester.pumpAndSettle();

    expect(finished, isTrue);
    expect(cubit.preferences.onboardingCompleted, isTrue);
  });

  testWidgets('Skip completes onboarding just like Get started', (tester) async {
    setSurfaceSize(tester, const Size(400, 800));
    await tester.pumpWidget(harness());
    await tester.pump();

    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    await tester.tap(find.text(l10n.onboardingSkip));
    await tester.pumpAndSettle();

    expect(cubit.preferences.onboardingCompleted, isTrue);
  });

  testWidgets('base currency row opens the picker and saves the choice via AppCubit', (tester) async {
    setSurfaceSize(tester, const Size(400, 800));
    await tester.pumpWidget(harness());
    await tester.pump();

    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    // Swipe to the last step.
    for (var i = 0; i < 4; i++) {
      await tester.tap(find.widgetWithText(FilledButton, l10n.onboardingNext).last);
      await tester.pumpAndSettle();
    }

    await tester.tap(find.text(l10n.onboardingBaseCurrencyTitle));
    await tester.pumpAndSettle();

    await tester.tap(find.text('GBP').last);
    await tester.pumpAndSettle();

    expect(cubit.state.baseCurrency, 'GBP');
  });

  testWidgets('replaying from Settings shows the tour again and popping returns to the shell', (tester) async {
    setSurfaceSize(tester, const Size(400, 800));
    await tester.pumpWidget(BlocProvider<AppCubit>.value(
      value: cubit,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: buildTheme(Brightness.dark),
        home: const HomeShell(),
      ),
    ));
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    await tester.tap(find.byIcon(Icons.settings_outlined).first);
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    // `HomeShell` (underneath both the settings tab and, after replaying,
    // the pushed tour route) runs its own periodic price-refresh `Timer`,
    // which never completes on its own and would make `pumpAndSettle()`
    // time out from here on (same pattern as `home_shell_test.dart`).
    Future<void> settle() async {
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    await tester.scrollUntilVisible(find.text(l10n.settingsHelpReplayTour), 200);
    await tester.tap(find.text(l10n.settingsHelpReplayTour));
    await settle();

    expect(find.byType(OnboardingTourScreen), findsOneWidget);

    await tester.tap(find.text(l10n.onboardingSkip));
    await settle();

    expect(find.byType(OnboardingTourScreen), findsNothing);
    expect(find.byType(HomeShell), findsOneWidget);
  });

  testWidgets('builds under RTL (Arabic locale) without exceptions', (tester) async {
    setSurfaceSize(tester, const Size(400, 800));
    await tester.pumpWidget(harness(locale: const Locale('ar')));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(Directionality.of(tester.element(find.byType(OnboardingTourScreen))), TextDirection.rtl);
  });

  testWidgets('no overflow at 320x640 with textScaler 1.3', (tester) async {
    setSurfaceSize(tester, const Size(320, 640));
    await tester.pumpWidget(harness(surfaceSize: const Size(320, 640), textScale: 1.3));
    await tester.pump();
    expect(tester.takeException(), isNull);

    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    for (var i = 0; i < 4; i++) {
      await tester.tap(find.widgetWithText(FilledButton, l10n.onboardingNext).last);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });
}
