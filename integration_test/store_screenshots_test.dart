// Drives the real app through the store-listing screens with a seeded demo
// portfolio. Run it through tool/store_screenshots.sh, which captures the
// simulator (status bar included) each time a screen is announced.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:qima/blocs/app_cubit.dart';
import 'package:qima/main.dart';
import 'package:qima/models/asset.dart';
import 'package:qima/models/holding.dart';
import 'package:qima/models/metal_breakdown.dart';
import 'package:qima/models/watch_card.dart';
import 'package:qima/screens/watchlist_screen.dart';
import 'package:qima/services/preferences.dart';
import 'package:qima/widgets/instrument_row.dart';

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

Future<void> _seed(AppCubit cubit) async {
  await cubit.setAppLanguage(_language == 'ar' ? AppLanguage.ar : AppLanguage.en);
  await cubit.setBaseCurrency('USD');
  const cards = [
    WatchCard(id: 'shot-xau', instrumentID: 'metal.XAU', currency: 'USD', unit: PriceUnit.troyOunce),
    WatchCard(id: 'shot-xau21', instrumentID: 'metal.XAU', currency: 'SAR', unit: PriceUnit.gram, karat: GoldKarat.k21),
    WatchCard(id: 'shot-xag', instrumentID: 'metal.XAG', currency: 'USD', unit: PriceUnit.troyOunce),
    WatchCard(id: 'shot-btc', instrumentID: 'crypto.BTC', currency: 'USD', unit: PriceUnit.each),
    WatchCard(id: 'shot-aapl', instrumentID: 'stock.AAPL', currency: 'USD', unit: PriceUnit.each),
    WatchCard(id: 'shot-spx', instrumentID: 'index.GSPC', currency: 'USD', unit: PriceUnit.each),
    WatchCard(id: 'shot-eur', instrumentID: 'fx.EUR', currency: 'USD', unit: PriceUnit.each),
  ];
  // Idempotent across runs: re-adding a card id that was removed earlier
  // would fight the store's tombstones, so keep existing demo cards and only
  // remove everything else.
  final wanted = {for (final card in cards) card.id};
  for (final card in List.of(cubit.state.cards)) {
    if (!wanted.contains(card.id)) await cubit.removeCard(card.id);
  }
  final existing = {for (final card in cubit.state.cards) card.id};
  for (final card in cards) {
    if (!existing.contains(card.id)) await cubit.addCard(card);
  }

  final lots = [
    HoldingLot(id: 'shot-lot-1', instrumentID: 'metal.XAU', quantity: 5, unit: PriceUnit.troyOunce, unitCost: 2380, costCurrency: 'USD', date: DateTime(2024, 3, 14)),
    HoldingLot(id: 'shot-lot-2', instrumentID: 'metal.XAU', quantity: 100, unit: PriceUnit.gram, unitCost: 88.5, costCurrency: 'USD', date: DateTime(2025, 1, 8)),
    HoldingLot(id: 'shot-lot-3', instrumentID: 'metal.XAG', quantity: 50, unit: PriceUnit.troyOunce, unitCost: 29.4, costCurrency: 'USD', date: DateTime(2024, 9, 2)),
    HoldingLot(id: 'shot-lot-4', instrumentID: 'crypto.BTC', quantity: 0.12, unit: PriceUnit.each, unitCost: 61200, costCurrency: 'USD', date: DateTime(2024, 6, 20)),
    HoldingLot(id: 'shot-lot-5', instrumentID: 'stock.AAPL', quantity: 15, unit: PriceUnit.each, unitCost: 182.3, costCurrency: 'USD', date: DateTime(2024, 11, 5)),
  ];
  for (final lot in lots) {
    await cubit.saveLot(lot);
  }
  await cubit.refreshAll();
  await cubit.backfillHistoryIfNeeded();
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('store screenshots ($_language)', (tester) async {
    await tester.pumpWidget(const QimaApp());
    await _waitFor(find.byType(WatchlistScreen));
    final cubit = tester.element(find.byType(WatchlistScreen)).read<AppCubit>();
    // Wait for the stores to load; the watchlist itself may start empty.
    final ready = DateTime.now().add(const Duration(seconds: 30));
    while (!cubit.state.initialized && DateTime.now().isBefore(ready)) {
      await _wait(const Duration(milliseconds: 250));
    }
    await _seed(cubit);
    await _wait(const Duration(seconds: 3));
    await _shot(tester, '1_watchlist');

    await tester.tap((await _waitFor(find.byType(InstrumentRow))).first);
    await _wait(const Duration(seconds: 3));
    await _shot(tester, '2_gold_detail');

    await tester.drag(find.byType(Scrollable).first, const Offset(0, -900));
    await _shot(tester, '3_gold_holdings');

    await tester.tap(find.byType(BackButton));
    await _wait(const Duration(seconds: 2));
    await tester.tap(await _waitFor(find.byKey(const ValueKey('portfolio-summary'))));
    await _wait(const Duration(seconds: 2));
    await _shot(tester, '4_portfolio');

    await tester.tap(find.byType(BackButton));
    await _wait(const Duration(seconds: 2));
    await tester.tap(find.byIcon(Icons.add));
    await _wait(const Duration(seconds: 2));
    await _shot(tester, '5_add_instrument');
  });
}
