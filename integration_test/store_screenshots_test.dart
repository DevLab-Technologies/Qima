// Drives the real app through the store-listing screens with the seeded demo
// book and portfolio. Run it through tool/store_screenshots.sh, which captures the
// simulator (status bar included) each time a screen is announced.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:qima/blocs/app_cubit.dart';
import 'package:qima/main.dart';
import 'package:qima/models/zakat.dart';
import 'package:qima/blocs/money_cubit.dart';
import 'package:qima/screens/home_shell.dart';
import 'package:qima/screens/money/accounts_screens.dart';
import 'package:qima/screens/money/asset_screens.dart';
import 'package:qima/screens/money/balance_sheet_screen.dart';
import 'package:qima/screens/money/more_money_screens.dart';
import 'package:qima/screens/zakat_screen.dart';
import 'package:qima/services/preferences.dart';
import 'package:qima/widgets/instrument_row.dart';

import 'store_book_seed.dart';
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

/// Opens [screen] on the root navigator, as its card on the portfolio tab
/// would; a tap could land off-screen on smaller devices.
void _push(WidgetTester tester, Widget screen) =>
    tester.state<NavigatorState>(find.byType(Navigator).first).push(MaterialPageRoute<void>(builder: (_) => screen));

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
    final arabic = _language == 'ar';
    await seedStoreDemo(cubit, language: arabic ? AppLanguage.ar : AppLanguage.en, currency: 'SAR');
    final money = tester.element(find.byType(MaterialApp)).read<MoneyCubit>();
    await seedStoreBook(money, arabic: arabic);
    await _waitFor(find.byType(HomeShell, skipOffstage: false));
    // What's new opens on first launch, before the seed marks it seen.
    await _wait(const Duration(seconds: 2));
    tester.state<NavigatorState>(find.byType(Navigator).first).popUntil((route) => route.isFirst);
    // A fresh simulator can still be fetching when the seed returns; every
    // card needs its price before the first shot.
    final priced = DateTime.now().add(const Duration(seconds: 60));
    while (!cubit.state.cards.every((c) => cubit.state.seriesByID[c.instrumentID]?.quotes.isNotEmpty ?? false)) {
      if (DateTime.now().isAfter(priced)) throw TestFailure('Prices did not load.');
      await _wait(const Duration(milliseconds: 500));
    }
    await _shot(tester, '1_home');

    _push(tester, const BalanceSheetScreen());
    await _shot(tester, '2_balance_sheet');
    _popRoute(tester);
    await _wait(const Duration(seconds: 1));

    await tester.tap(find.byIcon(Icons.account_balance_wallet_outlined));
    await _shot(tester, '3_money');

    _push(tester, const AccountDetailScreen(accountId: 'shot-card'));
    await _shot(tester, '4_card');
    _popRoute(tester);
    await _wait(const Duration(seconds: 1));

    _push(tester, const AssetDetailScreen(assetId: 'shot-land'));
    await _shot(tester, '5_land');
    _popRoute(tester);
    await _wait(const Duration(seconds: 1));

    await tester.tap(find.byIcon(Icons.show_chart_outlined));
    await _shot(tester, '6_prices');

    await tester.tap((await _waitFor(find.byType(InstrumentRow))).first);
    await _shot(tester, '7_gold_detail');
    _popRoute(tester);
    await _wait(const Duration(seconds: 1));

    _push(tester, const ZakatScreen());
    // The nisab needs live gold and silver prices.
    final nisab = DateTime.now().add(const Duration(seconds: 30));
    while (cubit.zakatAssessment.status == NisabStatus.thresholdUnknown) {
      if (DateTime.now().isAfter(nisab)) throw TestFailure('Nisab prices did not load.');
      await _wait(const Duration(milliseconds: 500));
    }
    await _shot(tester, '8_zakat');
    _popRoute(tester);
    await _wait(const Duration(seconds: 1));

    _push(tester, const PeopleScreen());
    await _shot(tester, '9_people');
  });
}
