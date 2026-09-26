// Drives the real app through the store-listing screens with the seeded demo
// portfolio. Run it through tool/store_screenshots.sh, which captures the
// simulator (status bar included) each time a screen is announced.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:qima/blocs/app_cubit.dart';
import 'package:qima/main.dart';
import 'package:qima/screens/home_shell.dart';
import 'package:qima/screens/instrument_detail_screen.dart';
import 'package:qima/services/preferences.dart';
import 'package:qima/widgets/instrument_row.dart';

import 'store_demo_seed.dart';

/// `en` or `ar`; selects the in-app language for the run.
const _language = String.fromEnvironment('SCREENSHOT_LANG', defaultValue: 'en');

/// The host script captures the device while the app holds still after this.
const _holdForCapture = Duration(seconds: 5);

Future<void> _wait(Duration duration) => Future<void>.delayed(duration);

/// Polls until [finder] matches, since live network data arrives on its own
/// schedule and fixed delays are either flaky or slow.
Future<Finder> _waitFor(Finder finder, {Duration timeout = const Duration(seconds: 30)}) async {
  final deadline = DateTime.now().add(timeout);
  while (finder.evaluate().isEmpty) {
    if (DateTime.now().isAfter(deadline)) {
      throw TestFailure('Timed out waiting for $finder');
    }
    await _wait(const Duration(milliseconds: 250));
  }
  return finder;
}

Future<void> _shot(WidgetTester tester, String name) async {
  await _wait(const Duration(seconds: 3));
  // ignore: avoid_print
  print('QIMA_SCREENSHOT $name');
  await _wait(_holdForCapture);
}

/// Closes whatever the root navigator last pushed (detail page or add flow).
void _popRoute(WidgetTester tester) => tester.state<NavigatorState>(find.byType(Navigator).first).pop();

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('store screenshots ($_language)', (tester) async {
    await tester.pumpWidget(const QimaApp());
    final cubit = tester.element(find.byType(MaterialApp)).read<AppCubit>();
    // Wait for the stores to load before seeding.
    final ready = DateTime.now().add(const Duration(seconds: 30));
    while (!cubit.state.initialized && DateTime.now().isBefore(ready)) {
      await _wait(const Duration(milliseconds: 250));
    }
    await seedStoreDemo(cubit, language: _language == 'ar' ? AppLanguage.ar : AppLanguage.en);
    await _waitFor(find.byType(HomeShell, skipOffstage: false));
    // A fresh simulator can still be fetching when the seed returns; every
    // card needs its price before the first shot.
    final priced = DateTime.now().add(const Duration(seconds: 60));
    while (!cubit.state.cards.every((c) => cubit.state.seriesByID[c.instrumentID]?.quotes.isNotEmpty ?? false)) {
      if (DateTime.now().isAfter(priced)) throw TestFailure('Prices did not load.');
      await _wait(const Duration(milliseconds: 500));
    }
    await _shot(tester, '1_watchlist');

    await tester.tap((await _waitFor(find.byType(InstrumentRow))).first);
    await _shot(tester, '2_gold_detail');

    // Scroll the page itself to its end (the holdings card) rather than drag:
    // a synthetic swipe can land on the back gesture, notably in RTL.
    final page = find
        .descendant(
          of: find.byType(InstrumentDetailScreen),
          matching: find.byWidgetPredicate((w) => w is Scrollable && w.axisDirection == AxisDirection.down),
        )
        .first;
    final position = tester.state<ScrollableState>(page).position;
    await position.animateTo(
      position.maxScrollExtent,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
    );
    await _shot(tester, '3_gold_holdings');

    _popRoute(tester);
    await _wait(const Duration(seconds: 2));
    await tester.tap(find.byIcon(Icons.pie_chart_outline));
    await _shot(tester, '4_portfolio');

    await tester.tap(find.byIcon(Icons.list_alt_outlined));
    await _wait(const Duration(seconds: 1));
    await tester.tap(find.byIcon(Icons.add).first);
    await _wait(const Duration(seconds: 1));
    // The search field focuses itself; keep the keyboard out of the shot.
    FocusManager.instance.primaryFocus?.unfocus();
    await _shot(tester, '5_add_asset');
  });
}
