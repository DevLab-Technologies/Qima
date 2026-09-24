import 'package:flutter_test/flutter_test.dart';
import 'package:qima/blocs/app_cubit.dart';
import 'package:qima/blocs/app_state.dart';
import 'package:qima/models/asset.dart';
import 'package:qima/models/fx_history.dart';
import 'package:qima/models/holding.dart';
import 'package:qima/models/instrument_catalog.dart';
import 'package:qima/models/quote.dart';
import 'package:qima/models/watch_card.dart';
import 'package:qima/services/price_repository.dart';

/// Records exactly which instruments were asked for on each call, instead of
/// hitting the network — so the test can assert on the union the cubit
/// computed without any provider/store plumbing.
class _RecordingRepository extends PriceRepository {
  List<Instrument>? refreshAllInstruments;
  List<Instrument>? backfillInstruments_;

  @override
  Future<Map<String, QuoteSeries>> refreshAll(List<Instrument> instruments, {DateTime? now}) async {
    refreshAllInstruments = instruments;
    return {
      for (final i in instruments)
        i.id: QuoteSeries(
          instrumentID: i.id,
          quotes: [Quote(instrumentID: i.id, timestamp: now ?? DateTime.now(), canonicalUSD: 100)],
        ),
    };
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
  }) async {
    backfillInstruments_ = instruments;
    return {};
  }
}

void main() {
  group('AppCubit.trackedInstruments (held-but-not-watched instruments)', () {
    test('is the union of watchlist instruments and instruments with holding lots', () {
      final cubit = AppCubit(repository: _RecordingRepository());
      final watched = InstrumentCatalog.instrument('metal.XAU')!;
      final heldOnly = InstrumentCatalog.instrument('metal.XAG')!;

      final card = WatchCard(id: 'c1', instrumentID: watched.id, currency: 'USD', unit: PriceUnit.troyOunce);
      final lot = HoldingLot(
        id: 'l1',
        instrumentID: heldOnly.id,
        quantity: 1,
        unit: PriceUnit.troyOunce,
        unitCost: 10,
        costCurrency: 'USD',
        date: DateTime(2024, 1, 1),
      );

      cubit.emit(cubit.state.copyWith(cards: [card], lots: [lot]));

      final ids = cubit.trackedInstruments.map((i) => i.id).toSet();
      expect(ids, {watched.id, heldOnly.id});
    });

    test('a held-but-not-watched instrument is included in refreshAll and backfillHistoryIfNeeded', () async {
      final repository = _RecordingRepository();
      final cubit = AppCubit(repository: repository);
      final heldOnly = InstrumentCatalog.instrument('metal.XPT')!;
      final lot = HoldingLot(
        id: 'l1',
        instrumentID: heldOnly.id,
        quantity: 2,
        unit: PriceUnit.troyOunce,
        unitCost: 20,
        costCurrency: 'USD',
        date: DateTime(2024, 1, 1),
      );

      cubit.emit(cubit.state.copyWith(cards: const [], lots: [lot]));

      await cubit.refreshAll();
      expect(repository.refreshAllInstruments?.map((i) => i.id), contains(heldOnly.id));
      expect(cubit.state.seriesByID[heldOnly.id]?.isEmpty, isFalse);

      await cubit.backfillHistoryIfNeeded();
      expect(repository.backfillInstruments_?.map((i) => i.id), contains(heldOnly.id));
    });

    test('a held-but-not-watched instrument is valued once its price is known', () async {
      final repository = _RecordingRepository();
      final cubit = AppCubit(repository: repository);
      final heldOnly = InstrumentCatalog.instrument('metal.XPD')!;
      final lot = HoldingLot(
        id: 'l1',
        instrumentID: heldOnly.id,
        quantity: 3,
        unit: PriceUnit.troyOunce,
        unitCost: 50,
        costCurrency: 'USD',
        date: DateTime(2024, 1, 1),
      );

      cubit.emit(cubit.state.copyWith(cards: const [], lots: [lot], phase: RefreshPhase.idle));
      await cubit.refreshAll();

      final valuation = cubit.valuationFor(heldOnly, 'USD');
      expect(valuation, isNotNull);
      expect(valuation!.value.amount, closeTo(300, 0.001)); // 3 * 100 (fake price).
    });
  });
}
