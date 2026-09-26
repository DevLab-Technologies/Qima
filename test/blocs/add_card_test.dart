import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:qima/blocs/app_cubit.dart';
import 'package:qima/models/asset.dart';
import 'package:qima/models/fx_history.dart';
import 'package:qima/models/instrument_catalog.dart';
import 'package:qima/models/metal_breakdown.dart';
import 'package:qima/models/quote.dart';
import 'package:qima/models/watch_card.dart';
import 'package:qima/services/local_file_store.dart';
import 'package:qima/services/price_repository.dart';

/// `addCard` fires-and-forgets a live `refresh`/`backfillHistoryIfNeeded`
/// for a newly-tracked instrument (spec: watchlist prices should start
/// populating immediately, without the add flow waiting on the network).
/// These tests care about the watchlist mutation, not live pricing, so this
/// no-ops the network/shared_preferences-touching calls instead of letting
/// them hit the real network or throw on the unmocked shared_preferences
/// plugin channel — either of which would otherwise fail the test via an
/// unhandled async error even though the assertions themselves pass.
class _NoopRepository extends PriceRepository {
  @override
  Future<QuoteSeries> refresh(Instrument instrument, {DateTime? now}) async => QuoteSeries.empty(instrument.id);

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

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('qima_add_card_test');
    LocalFileStore.overrideDirectoryForTesting(tempDir);
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('addCard returns the new card with created: true', () async {
    final cubit = AppCubit(repository: _NoopRepository());
    final gold = InstrumentCatalog.instrument('metal.XAU')!;
    final card = WatchCard(id: 'c1', instrumentID: gold.id, currency: 'USD', unit: PriceUnit.troyOunce);

    final result = await cubit.addCard(card);

    expect(result.created, isTrue);
    expect(result.card, card);
    expect(cubit.state.cards, contains(card));
  });

  test('addCard on a duplicate combo returns the EXISTING card with created: false, without adding a second card', () async {
    final cubit = AppCubit(repository: _NoopRepository());
    final gold = InstrumentCatalog.instrument('metal.XAU')!;
    final first = WatchCard(id: 'c1', instrumentID: gold.id, currency: 'USD', unit: PriceUnit.troyOunce);
    final duplicate = WatchCard(id: 'c2', instrumentID: gold.id, currency: 'USD', unit: PriceUnit.troyOunce);

    await cubit.addCard(first);
    final result = await cubit.addCard(duplicate);

    expect(result.created, isFalse);
    expect(result.card, first); // the pre-existing card, not the duplicate.
    expect(cubit.state.cards.length, 1);
    expect(cubit.state.cards, isNot(contains(duplicate)));
  });

  test('different karats of the same instrument/currency/unit are not duplicates (TC-W4)', () async {
    final cubit = AppCubit(repository: _NoopRepository());
    final gold = InstrumentCatalog.instrument('metal.XAU')!;
    final k24 = WatchCard(id: 'c1', instrumentID: gold.id, currency: 'USD', unit: PriceUnit.gram, karat: GoldKarat.k24);
    final k18 = WatchCard(id: 'c2', instrumentID: gold.id, currency: 'USD', unit: PriceUnit.gram, karat: GoldKarat.k18);

    final r1 = await cubit.addCard(k24);
    final r2 = await cubit.addCard(k18);

    expect(r1.created, isTrue);
    expect(r2.created, isTrue);
    expect(cubit.state.cards.length, 2);
  });

  test('undoAdd removes the card', () async {
    final cubit = AppCubit(repository: _NoopRepository());
    final gold = InstrumentCatalog.instrument('metal.XAU')!;
    final card = WatchCard(id: 'c1', instrumentID: gold.id, currency: 'USD', unit: PriceUnit.troyOunce);
    await cubit.addCard(card);
    expect(cubit.state.cards, contains(card));

    await cubit.undoAdd(card);

    expect(cubit.state.cards, isNot(contains(card)));
  });

  test('undoAdd with a customInstrumentID removes a newly-created custom ticker entirely', () async {
    final cubit = AppCubit(repository: _NoopRepository());
    final instrument = await cubit.addCustomTicker('ZZZZ', 'Test Co', assetClass: AssetClass.stock);
    expect(cubit.isCustom(instrument.id), isTrue);

    final card = WatchCard(id: 'c1', instrumentID: instrument.id, currency: 'USD', unit: PriceUnit.each);
    await cubit.addCard(card);

    await cubit.undoAdd(card, customInstrumentID: instrument.id);

    expect(cubit.state.cards, isNot(contains(card)));
    expect(cubit.isCustom(instrument.id), isFalse);
  });

  test('undoAdd keeps a custom ticker that existed before this add flow, only removing the card', () async {
    final cubit = AppCubit(repository: _NoopRepository());
    final instrument = await cubit.addCustomTicker('YYYY', 'Existing Co', assetClass: AssetClass.stock);
    // Simulate the ticker already having a watchlist card from an earlier flow.
    final oldCard = WatchCard(id: 'old', instrumentID: instrument.id, currency: 'EUR', unit: PriceUnit.each);
    await cubit.addCard(oldCard);

    // A second add flow adds it again at a different currency, then undoes —
    // customInstrumentID is NOT passed, since custom_ticker_screen only
    // passes it when the ticker didn't already exist (checked via isCustom
    // BEFORE calling addCustomTicker).
    final newCard = WatchCard(id: 'new', instrumentID: instrument.id, currency: 'USD', unit: PriceUnit.each);
    await cubit.addCard(newCard);
    await cubit.undoAdd(newCard);

    expect(cubit.state.cards, isNot(contains(newCard)));
    expect(cubit.state.cards, contains(oldCard));
    expect(cubit.isCustom(instrument.id), isTrue);
  });

  test('undoAdd with customInstrumentID keeps the ticker if another card still references it', () async {
    final cubit = AppCubit(repository: _NoopRepository());
    final instrument = await cubit.addCustomTicker('XXXX', 'Multi Co', assetClass: AssetClass.stock);

    final usdCard = WatchCard(id: 'usd', instrumentID: instrument.id, currency: 'USD', unit: PriceUnit.each);
    final eurCard = WatchCard(id: 'eur', instrumentID: instrument.id, currency: 'EUR', unit: PriceUnit.each);
    await cubit.addCard(usdCard);
    await cubit.addCard(eurCard);

    // Undo only the EUR add; the ticker is still referenced by the USD card.
    await cubit.undoAdd(eurCard, customInstrumentID: instrument.id);

    expect(cubit.state.cards, isNot(contains(eurCard)));
    expect(cubit.state.cards, contains(usdCard));
    expect(cubit.isCustom(instrument.id), isTrue);
  });
}
