import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qima/l10n/app_localizations.dart';
import 'package:qima/models/asset.dart';
import 'package:qima/models/chart_range.dart';
import 'package:qima/models/display_point.dart';
import 'package:qima/models/fx_history.dart';
import 'package:qima/models/holding.dart';
import 'package:qima/models/holding_transaction.dart';
import 'package:qima/models/instrument_catalog.dart';
import 'package:qima/models/ledger.dart';
import 'package:qima/models/money.dart';
import 'package:qima/models/period_summary.dart';
import 'package:qima/models/quote.dart';
import 'package:qima/theme/summaries.dart';

void main() {
  final gold = InstrumentCatalog.instrument('metal.XAU')!;
  final silver = InstrumentCatalog.instrument('metal.XAG')!;
  final rates = FXRates(base: 'USD', rates: const {'USD': 1}, updatedAt: DateTime(2024));
  final now = DateTime(2024, 6, 30);

  QuoteSeries seriesOf(Instrument instrument, List<MapEntry<DateTime, double>> samples) => QuoteSeries(
        instrumentID: instrument.id,
        quotes: [for (final s in samples) Quote(instrumentID: instrument.id, timestamp: s.key, canonicalUSD: s.value)],
      );

  HoldingTransaction buy(Instrument i, double oz, double cost, DateTime date) => HoldingTransaction.fromLot(HoldingLot(
        id: '${i.id}-$date',
        instrumentID: i.id,
        quantity: oz,
        unit: PriceUnit.troyOunce,
        unitCost: cost,
        costCurrency: 'USD',
        date: date,
      ));

  PeriodSummary? summarize(List<HoldingTransaction> transactions, Map<String, QuoteSeries> series) => PeriodSummary.build(
        ledger: Ledger.derive(transactions),
        transactions: transactions,
        seriesByID: series,
        rates: rates,
        fxHistory: FXHistory.empty,
        baseCurrency: 'USD',
        now: now,
      );

  group('PeriodSummary', () {
    test('nothing held is no summary', () {
      expect(summarize(const [], const {}), isNull);
    });

    test('the gain change, the holding that moved it most, and the month\'s transactions', () {
      final transactions = [
        buy(gold, 1, 2000, DateTime(2024, 1, 1)),
        buy(silver, 10, 20, DateTime(2024, 1, 1)),
        buy(silver, 10, 25, DateTime(2024, 6, 10)),
      ];
      final summary = summarize(transactions, {
        gold.id: seriesOf(gold, [MapEntry(DateTime(2024, 5, 1), 2000), MapEntry(DateTime(2024, 6, 29), 2300)]),
        silver.id: seriesOf(silver, [MapEntry(DateTime(2024, 5, 1), 25), MapEntry(DateTime(2024, 6, 29), 24)]),
      })!;
      // Gold +300; silver: the first 10 oz lost 10, and the 10 oz bought at
      // 25 lost 10 more — buying is never a gain.
      expect(summary.gainDelta, closeTo(280, 1e-6));
      expect(summary.isUp, isTrue);
      expect(summary.topMoverID, gold.id);
      expect(summary.topMoverDelta, closeTo(300, 1e-6));
      expect(summary.transactionCount, 1);
    });

    test('a fall is a fall, and the mover can be the loser', () {
      final transactions = [buy(gold, 1, 2000, DateTime(2024, 1, 1))];
      final summary = summarize(transactions, {
        gold.id: seriesOf(gold, [MapEntry(DateTime(2024, 5, 1), 2300), MapEntry(DateTime(2024, 6, 29), 2100)]),
      })!;
      expect(summary.isUp, isFalse);
      expect(summary.topMoverDelta, closeTo(-200, 1e-6));
      expect(summary.transactionCount, 0);
    });
  });

  group('ChartFacts', () {
    test('first, last, high and low', () {
      final points = [
        DisplayPoint(date: DateTime(2024, 6, 1), value: 10),
        DisplayPoint(date: DateTime(2024, 6, 2), value: 14),
        DisplayPoint(date: DateTime(2024, 6, 3), value: 8),
        DisplayPoint(date: DateTime(2024, 6, 4), value: 12),
      ];
      final facts = ChartFacts.of(points)!;
      expect(facts.high.value, 14);
      expect(facts.low.date, DateTime(2024, 6, 3));
      expect(facts.percent, closeTo(0.2, 1e-9));
      expect(ChartFacts.of(points.take(1).toList()), isNull);
    });
  });

  group('sentences', () {
    Future<BuildContext> contextIn(WidgetTester tester, Locale locale) async {
      late BuildContext captured;
      await tester.pumpWidget(Localizations(
        locale: locale,
        delegates: AppLocalizations.localizationsDelegates,
        child: Builder(builder: (context) {
          captured = context;
          return const SizedBox();
        }),
      ));
      return captured;
    }

    const summary = PeriodSummary(
      range: ChartRange.month1,
      gainDelta: 280,
      percent: 0.0928,
      topMoverID: 'metal.XAU',
      topMoverDelta: 300,
      transactionCount: 1,
    );

    testWidgets('every figure in the sentence is one of the summary\'s', (tester) async {
      final context = await contextIn(tester, const Locale('en'));
      final text = periodSummarySentence(context, summary, currency: 'USD', hidden: false);
      expect(text, contains('gained'));
      expect(text, contains('280'));
      expect(text, contains('9.3%'));
      expect(text, contains('Gold moved them most'));
      expect(text, contains('+\$300'));
      expect(text, contains('1 transaction.'));
    });

    testWidgets('hidden balances hide the amounts but keep the direction', (tester) async {
      final context = await contextIn(tester, const Locale('ar'));
      final text = periodSummarySentence(context, summary, currency: 'USD', hidden: true);
      expect(text, isNot(contains('280')));
      expect(text, contains('ربحت'));
    });

    testWidgets('a flat month says so without figures', (tester) async {
      final context = await contextIn(tester, const Locale('en'));
      const flat = PeriodSummary(range: ChartRange.month1, gainDelta: 0.2, percent: 0.00001);
      expect(periodSummarySentence(context, flat, currency: 'USD', hidden: false), 'Your holdings barely moved over the past month.');
    });

    testWidgets('a chart description names its extremes, or only the change when hidden', (tester) async {
      final context = await contextIn(tester, const Locale('en'));
      final facts = ChartFacts.of([
        DisplayPoint(date: DateTime(2024, 6, 1), value: 10),
        DisplayPoint(date: DateTime(2024, 6, 2), value: 14),
        DisplayPoint(date: DateTime(2024, 6, 3), value: 8),
        DisplayPoint(date: DateTime(2024, 6, 4), value: 12),
      ])!;
      final full = chartDescription(context, facts, currencyCode: 'USD', hidden: false);
      expect(full, contains('High \$14.00'));
      expect(full, contains('Jun 2, 2024'));
      expect(full, contains('20%'));
      final hidden = chartDescription(context, facts, currencyCode: 'USD', hidden: true);
      expect(hidden, isNot(contains('14')));
    });
  });
}
