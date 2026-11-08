import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:qima/models/asset.dart';
import 'package:qima/models/fx_history.dart';
import 'package:qima/models/instrument_catalog.dart';
import 'package:qima/models/quote.dart';
import 'package:qima/services/local_file_store.dart';
import 'package:qima/services/price_repository.dart';
import 'package:qima/services/quote_history_store.dart';
import 'package:qima/services/quote_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Serves one daily bar per day from [from] through [to], and [intraday]
/// for 15-minute requests, recording every daily range it was asked for.
class _FakeHistoryProvider extends YahooHistoryProvider {
  final DateTime from;
  final DateTime to;
  final double close;
  final List<Bar> intraday;
  final List<String> requestedRanges = [];
  int intradayRequests = 0;

  _FakeHistoryProvider(this.from, this.to, {this.close = 4000, this.intraday = const []});

  @override
  Future<List<Bar>> bars(String symbol, {String range = '5y', String interval = '1d'}) async {
    if (interval != '1d') {
      intradayRequests++;
      return intraday;
    }
    requestedRanges.add(range);
    return [
      for (var d = from; !d.isAfter(to); d = d.add(const Duration(days: 1)))
        Bar(date: d, close: close, currency: 'USD'),
    ];
  }
}

/// The live spot price, or a failure when [price] is null.
class _FakeSpot extends GoldAPIProvider {
  double? price;
  _FakeSpot(this.price);

  @override
  Future<double> canonicalUSDPrice(Instrument instrument) async {
    final value = price;
    if (value == null) throw const PriceError.invalidResponse();
    return value;
  }
}

void main() {
  final gold = InstrumentCatalog.instrument('metal.XAU')!;
  final now = DateTime.utc(2026, 10, 21, 13);
  final store = QuoteHistoryStore();
  late Directory dir;

  setUp(() {
    // History already stored at the live price's level, as after the first
    // pull with this version.
    SharedPreferences.setMockInitialValues({'quoteHistoryLevel.${gold.id}': 'live-v1'});
    dir = Directory.systemTemp.createTempSync('qima_backfill_test');
    LocalFileStore.overrideDirectoryForTesting(dir);
  });

  tearDown(() => dir.deleteSync(recursive: true));

  /// Five years of daily closes ending [lastClose], then today's live quote —
  /// the shape a series has after weeks of failed live quotes.
  Future<void> seedGappedHistory(DateTime lastClose) async {
    final quotes = <Quote>[
      for (var d = lastClose.subtract(const Duration(days: 365 * 5)); !d.isAfter(lastClose); d = d.add(const Duration(days: 1)))
        Quote(instrumentID: gold.id, timestamp: d, canonicalUSD: 3000),
      Quote(instrumentID: gold.id, timestamp: now, canonicalUSD: 4137),
    ];
    await store.save(QuoteSeries(instrumentID: gold.id, quotes: quotes));
  }

  /// The last intraday bar closes at 4000, the same as the live price, so
  /// nothing is rescaled unless a test says otherwise.
  List<Bar> intradayBars(DateTime from, DateTime to, {double close = 4000}) => [
        for (var t = from; !t.isAfter(to); t = t.add(const Duration(minutes: 15)))
          Bar(date: t, close: close, currency: 'USD'),
      ];

  PriceRepository repositoryWith(_FakeHistoryProvider provider, {double? spot = 4000}) => PriceRepository(
        historyProvider: provider,
        metalCryptoProvider: _FakeSpot(spot),
        quoteHistoryStore: store,
      );

  test('fills a gap in deep history back to the last daily close', () async {
    final lastClose = DateTime.utc(2026, 8, 19);
    await seedGappedHistory(lastClose);
    final provider = _FakeHistoryProvider(
      lastClose,
      now.subtract(const Duration(days: 1)),
      intraday: intradayBars(now.subtract(const Duration(days: 1)), now.subtract(const Duration(minutes: 15))),
    );

    await repositoryWith(provider).backfillInstruments([gold], FXHistory.empty, now: now);

    expect(provider.requestedRanges, ['3mo']);
    final series = await store.load(gold.id);
    final september = series.quotes.where((q) => q.timestamp.year == 2026 && q.timestamp.month == 9);
    expect(september, hasLength(30));
    expect(series.latest!.canonicalUSD, 4137, reason: "today's live quote survives the merge");
  });

  test('refreshes the tail at most once per interval', () async {
    final lastClose = now.subtract(const Duration(days: 5));
    await seedGappedHistory(lastClose);
    final provider = _FakeHistoryProvider(
      lastClose,
      now.subtract(const Duration(days: 1)),
      intraday: intradayBars(now.subtract(const Duration(days: 1)), now.subtract(const Duration(minutes: 15))),
    );
    final repository = repositoryWith(provider);

    await repository.backfillInstruments([gold], FXHistory.empty, now: now);
    await repository.backfillInstruments([gold], FXHistory.empty, now: now.add(const Duration(hours: 1)));
    expect(provider.requestedRanges, ['1mo']);

    await repository.backfillInstruments([gold], FXHistory.empty, now: now.add(const Duration(hours: 13)));
    expect(provider.requestedRanges, ['1mo', '1mo']);
  });

  test('backs off after a failed tail refresh', () async {
    await seedGappedHistory(DateTime.utc(2026, 8, 19));
    final provider = _FakeHistoryProvider(now, now.subtract(const Duration(days: 1))); // serves no bars
    final repository = repositoryWith(provider);

    await repository.backfillInstruments([gold], FXHistory.empty, now: now);
    await repository.backfillInstruments([gold], FXHistory.empty, now: now.add(const Duration(minutes: 5)));
    expect(provider.requestedRanges, hasLength(1));

    await repository.backfillInstruments([gold], FXHistory.empty, now: now.add(const Duration(minutes: 11)));
    expect(provider.requestedRanges, hasLength(2));
  });

  test('a shallow series still gets the full five-year pull', () async {
    final provider = _FakeHistoryProvider(now.subtract(const Duration(days: 10)), now);

    await repositoryWith(provider).backfillInstruments([gold], FXHistory.empty, now: now);

    expect(provider.requestedRanges, ['5y']);
  });

  group('recent days', () {
    test('15-minute bars replace the live samples and the mis-dated daily bar in their span', () async {
      final today = DateTime.utc(2026, 10, 21, 5); // a daily bar's open, carrying today's latest price
      await store.save(QuoteSeries(instrumentID: gold.id, quotes: [
        Quote(instrumentID: gold.id, timestamp: today, canonicalUSD: 4139.10),
        Quote(instrumentID: gold.id, timestamp: DateTime.utc(2026, 10, 21, 9, 7), canonicalUSD: 3990),
        Quote(instrumentID: gold.id, timestamp: now, canonicalUSD: 4000), // newer than the last bar
      ]));
      final bars = intradayBars(DateTime.utc(2026, 10, 20, 13), now.subtract(const Duration(minutes: 15)));
      final provider = _FakeHistoryProvider(DateTime.utc(2021, 10, 21), today, intraday: bars);

      await repositoryWith(provider).backfillInstruments([gold], FXHistory.empty, now: now);

      final recent = (await store.load(gold.id)).quotes.where((q) => !q.timestamp.isBefore(bars.first.date)).toList();
      expect(recent.map((q) => q.timestamp), [...bars.map((b) => b.date), now]);
      expect(recent.any((q) => q.canonicalUSD == 4139.10 || q.canonicalUSD == 3990), isFalse);
    });

    test('are fetched at most every 15 minutes', () async {
      final provider = _FakeHistoryProvider(
        now.subtract(const Duration(days: 365)),
        now.subtract(const Duration(days: 3)),
        intraday: intradayBars(now.subtract(const Duration(hours: 2)), now),
      );
      final repository = repositoryWith(provider);
      await repository.backfillInstruments([gold], FXHistory.empty, now: now);
      expect(provider.intradayRequests, 1);

      await repository.backfillInstruments([gold], FXHistory.empty, now: now.add(const Duration(minutes: 10)));
      expect(provider.intradayRequests, 1);
      expect(provider.requestedRanges, ['5y'], reason: 'deep history waits for its own interval');

      await repository.backfillInstruments([gold], FXHistory.empty, now: now.add(const Duration(minutes: 16)));
      expect(provider.intradayRequests, 2);
    });
  });

  group('metals and crypto', () {
    test("gold's futures bars are scaled to meet the live spot price", () async {
      final provider = _FakeHistoryProvider(
        now.subtract(const Duration(days: 365)),
        now.subtract(const Duration(days: 3)),
        close: 4040,
        intraday: intradayBars(now.subtract(const Duration(hours: 2)), now, close: 4040),
      );

      await repositoryWith(provider, spot: 4000).backfillInstruments([gold], FXHistory.empty, now: now);

      final series = await store.load(gold.id);
      expect(series.latest!.canonicalUSD, closeTo(4000, 1e-9));
      expect(series.quotes.first.canonicalUSD, closeTo(4000, 1e-9), reason: 'the daily history is at the same level');
    });

    test('a stock is stored as Yahoo prices it, with no live price asked for', () async {
      final tesla = InstrumentCatalog.all.firstWhere((i) => i.assetClass == AssetClass.stock);
      final provider = _FakeHistoryProvider(
        now.subtract(const Duration(days: 365)),
        now.subtract(const Duration(days: 3)),
        close: 350,
        intraday: intradayBars(now.subtract(const Duration(hours: 2)), now, close: 350),
      );

      await repositoryWith(provider, spot: null).backfillInstruments([tesla], FXHistory.empty, now: now);

      expect((await store.load(tesla.id)).latest!.canonicalUSD, 350);
    });

    test('without a live price nothing is stored, rather than bars at the wrong level', () async {
      final provider = _FakeHistoryProvider(
        now.subtract(const Duration(days: 365)),
        now.subtract(const Duration(days: 3)),
        intraday: intradayBars(now.subtract(const Duration(hours: 2)), now),
      );

      final result = await repositoryWith(provider, spot: null).backfillInstruments([gold], FXHistory.empty, now: now);

      expect(result, isEmpty);
      expect((await store.load(gold.id)).isEmpty, isTrue);
    });

    test('history stored before scaling is pulled again in full, once', () async {
      SharedPreferences.setMockInitialValues({});
      await seedGappedHistory(now.subtract(const Duration(days: 3)));
      final provider = _FakeHistoryProvider(
        now.subtract(const Duration(days: 365 * 5)),
        now.subtract(const Duration(days: 3)),
        intraday: intradayBars(now.subtract(const Duration(hours: 2)), now),
      );
      final repository = repositoryWith(provider);

      await repository.backfillInstruments([gold], FXHistory.empty, now: now);
      expect(provider.requestedRanges, ['5y']);

      await repository.backfillInstruments([gold], FXHistory.empty, now: now.add(const Duration(minutes: 20)));
      expect(provider.requestedRanges, ['5y'], reason: 'leveled now; the tail waits for its interval');
    });
  });

  test("a currency's closes kept from a feed since found wrong are cleared, and today's live samples stay", () async {
    final sar = InstrumentCatalog.instrument('fx.SAR')!;
    await store.save(QuoteSeries(instrumentID: sar.id, quotes: [
      for (var d = DateTime.utc(2026, 6, 1); d.isBefore(DateTime.utc(2026, 10, 15)); d = d.add(const Duration(days: 1)))
        Quote(instrumentID: sar.id, timestamp: d, canonicalUSD: 1 / 3.64),
      Quote(instrumentID: sar.id, timestamp: now, canonicalUSD: 1 / 3.75),
    ]));
    final provider = _FakeHistoryProvider(now, now);

    // The checked history has no SAR: its feed disagreed with the live rate.
    await repositoryWith(provider).backfillInstruments([sar], FXHistory.empty, force: true, now: now);

    final series = await store.load(sar.id);
    expect(series.quotes.map((q) => q.canonicalUSD), [1 / 3.75]);
  });
}
