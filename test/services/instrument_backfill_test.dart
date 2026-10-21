import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:qima/models/fx_history.dart';
import 'package:qima/models/instrument_catalog.dart';
import 'package:qima/models/quote.dart';
import 'package:qima/services/local_file_store.dart';
import 'package:qima/services/price_repository.dart';
import 'package:qima/services/quote_history_store.dart';
import 'package:qima/services/quote_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Serves one daily bar per day from [from] through [to] and records every
/// range it was asked for.
class _FakeHistoryProvider extends YahooHistoryProvider {
  final DateTime from;
  final DateTime to;
  final List<String> requestedRanges = [];

  _FakeHistoryProvider(this.from, this.to);

  @override
  Future<List<Bar>> bars(String symbol, {String range = '5y', String interval = '1d'}) async {
    requestedRanges.add(range);
    return [
      for (var d = from; !d.isAfter(to); d = d.add(const Duration(days: 1)))
        Bar(date: d, close: 4000, currency: 'USD'),
    ];
  }
}

void main() {
  final gold = InstrumentCatalog.instrument('metal.XAU')!;
  final now = DateTime.utc(2026, 10, 21, 13);
  final store = QuoteHistoryStore();
  late Directory dir;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
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

  PriceRepository repositoryWith(_FakeHistoryProvider provider) =>
      PriceRepository(historyProvider: provider, quoteHistoryStore: store);

  test('fills a gap in deep history back to the last daily close', () async {
    final lastClose = DateTime.utc(2026, 8, 19);
    await seedGappedHistory(lastClose);
    final provider = _FakeHistoryProvider(lastClose, now.subtract(const Duration(days: 1)));

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
    final provider = _FakeHistoryProvider(lastClose, now.subtract(const Duration(days: 1)));
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
}
