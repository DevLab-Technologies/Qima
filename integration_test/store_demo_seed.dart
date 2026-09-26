// The demo portfolio every store capture starts from (App Store and Play
// screenshots, Mac screenshots and the Mac app preview), so all store media
// shows the same data.
import 'package:qima/blocs/app_cubit.dart';
import 'package:qima/models/asset.dart';
import 'package:qima/models/chart_range.dart';
import 'package:qima/models/holding.dart';
import 'package:qima/models/metal_breakdown.dart';
import 'package:qima/models/watch_card.dart';
import 'package:qima/services/preferences.dart';

/// Replaces the watchlist and holdings with the demo set, in [language] and
/// dark mode, past onboarding, with prices and history loaded. Idempotent
/// across runs: re-adding a card id removed earlier would fight the store's
/// tombstones, so existing demo cards are kept and only others removed.
Future<void> seedStoreDemo(AppCubit cubit, {AppLanguage language = AppLanguage.en}) async {
  await cubit.completeOnboarding();
  await cubit.setAppLanguage(language);
  await cubit.setAppearance(Appearance.dark);
  await cubit.setBaseCurrency('USD');
  // Every run starts from the same ranges: walkthroughs tap other ones, and
  // tapping an already-selected chip does nothing.
  await cubit.setPreferredPortfolioRange(ChartRange.all);
  await cubit.setPreferredChartRange(ChartRange.month3);
  const cards = [
    WatchCard(id: 'shot-xau', instrumentID: 'metal.XAU', currency: 'USD', unit: PriceUnit.troyOunce),
    WatchCard(id: 'shot-xau21', instrumentID: 'metal.XAU', currency: 'SAR', unit: PriceUnit.gram, karat: GoldKarat.k21),
    WatchCard(id: 'shot-xag', instrumentID: 'metal.XAG', currency: 'USD', unit: PriceUnit.troyOunce),
    WatchCard(id: 'shot-btc', instrumentID: 'crypto.BTC', currency: 'USD', unit: PriceUnit.each),
    WatchCard(id: 'shot-aapl', instrumentID: 'stock.AAPL', currency: 'USD', unit: PriceUnit.each),
    WatchCard(id: 'shot-spx', instrumentID: 'index.GSPC', currency: 'USD', unit: PriceUnit.each),
    WatchCard(id: 'shot-eur', instrumentID: 'fx.EUR', currency: 'USD', unit: PriceUnit.each),
  ];
  final wanted = {for (final card in cards) card.id};
  for (final card in List.of(cubit.state.cards)) {
    if (!wanted.contains(card.id)) await cubit.removeCard(card.id);
  }
  final existing = {for (final card in cubit.state.cards) card.id};
  for (final card in cards) {
    if (!existing.contains(card.id)) await cubit.addCard(card);
  }

  final lots = [
    HoldingLot(
      id: 'shot-lot-1',
      instrumentID: 'metal.XAU',
      quantity: 5,
      unit: PriceUnit.troyOunce,
      unitCost: 2380,
      costCurrency: 'USD',
      date: DateTime(2024, 3, 14),
    ),
    HoldingLot(
      id: 'shot-lot-2',
      instrumentID: 'metal.XAU',
      quantity: 100,
      unit: PriceUnit.gram,
      unitCost: 88.5,
      costCurrency: 'USD',
      date: DateTime(2025, 1, 8),
    ),
    HoldingLot(
      id: 'shot-lot-3',
      instrumentID: 'metal.XAG',
      quantity: 50,
      unit: PriceUnit.troyOunce,
      unitCost: 29.4,
      costCurrency: 'USD',
      date: DateTime(2024, 9, 2),
    ),
    HoldingLot(
      id: 'shot-lot-4',
      instrumentID: 'crypto.BTC',
      quantity: 0.12,
      unit: PriceUnit.each,
      unitCost: 61200,
      costCurrency: 'USD',
      date: DateTime(2024, 6, 20),
    ),
    HoldingLot(
      id: 'shot-lot-5',
      instrumentID: 'stock.AAPL',
      quantity: 15,
      unit: PriceUnit.each,
      unitCost: 182.3,
      costCurrency: 'USD',
      date: DateTime(2024, 11, 5),
    ),
  ];
  for (final lot in lots) {
    await cubit.saveLot(lot);
  }
  await cubit.refreshAll();
  await cubit.backfillHistoryIfNeeded();
}
