import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qima/blocs/app_cubit.dart';
import 'package:qima/l10n/app_localizations.dart';
import 'package:qima/screens/settings_screen.dart';
import 'package:qima/screens/watch_watchlist_screen.dart';
import 'package:qima/screens/watchlist_screen.dart';
import 'package:qima/services/preferences.dart';
import 'package:qima/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Phase 1 smoke coverage: every main screen builds without error in both
/// [ThemeMode]s, and [Appearance] round-trips through [AppState]/[AppCubit]
/// the way `AppLanguage` already did.
Widget _themedApp({required Widget home, required Brightness brightness}) {
  return BlocProvider<AppCubit>(
    create: (_) => AppCubit(),
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

void main() {
  final screens = <String, Widget Function()>{
    'WatchlistScreen': () => const WatchlistScreen(),
    'WatchWatchlistScreen': () => const WatchWatchlistScreen(),
    'SettingsScreen': () => const SettingsScreen(),
  };

  for (final brightness in [Brightness.light, Brightness.dark]) {
    for (final entry in screens.entries) {
      testWidgets('${entry.key} builds in ${brightness.name} mode', (tester) async {
        await tester.pumpWidget(_themedApp(home: entry.value(), brightness: brightness));
        await tester.pump();
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('the Appearance section renders a System/Light/Dark segmented button', (tester) async {
    final cubit = AppCubit();
    await tester.pumpWidget(
      BlocProvider<AppCubit>.value(
        value: cubit,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: buildTheme(Brightness.light),
          darkTheme: buildTheme(Brightness.dark),
          home: const SettingsScreen(),
        ),
      ),
    );
    await tester.pump();

    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.byType(SegmentedButton<Appearance>), findsOneWidget);
    expect(find.text(l10n.settingsAppearanceSystem), findsOneWidget);
    expect(find.text(l10n.settingsAppearanceLight), findsOneWidget);
    expect(find.text(l10n.settingsAppearanceDark), findsOneWidget);

    final segmentedButton = tester.widget<SegmentedButton<Appearance>>(find.byType(SegmentedButton<Appearance>));
    expect(segmentedButton.selected, {Appearance.system});
  });

  group('Appearance persistence', () {
    // SharedPreferences.getInstance() needs the plugin binary-messenger
    // mocking TestWidgetsFlutterBinding sets up, so this runs as a
    // (bindingless-UI) testWidgets rather than a bare test() — a bare
    // test() has no mock method-channel handler and the platform call
    // never returns.
    testWidgets('defaults to system and round-trips through AppCubit.setAppearance', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final cubit = AppCubit();
      expect(cubit.state.appearance, Appearance.system);

      // setAppearance() awaits Preferences persistence, which needs
      // Preferences.create() (init()) to have run first — mirror what
      // AppCubit.init() does for the fields this test touches, without
      // pulling in network-backed price refresh.
      cubit.preferences = await Preferences.create();
      await cubit.setAppearance(Appearance.dark);
      expect(cubit.state.appearance, Appearance.dark);
      expect(await cubit.preferences.appearance, Appearance.dark);

      await cubit.setAppearance(Appearance.light);
      expect(cubit.state.appearance, Appearance.light);
      expect(await cubit.preferences.appearance, Appearance.light);
    });

    test('Appearance.themeMode maps each case to the matching ThemeMode', () {
      expect(Appearance.system.themeMode, ThemeMode.system);
      expect(Appearance.light.themeMode, ThemeMode.light);
      expect(Appearance.dark.themeMode, ThemeMode.dark);
    });
  });
}
