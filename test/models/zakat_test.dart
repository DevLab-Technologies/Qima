import 'package:flutter_test/flutter_test.dart';
import 'package:qima/models/asset.dart';
import 'package:qima/models/hijri_date.dart';
import 'package:qima/models/holding.dart';
import 'package:qima/models/instrument_catalog.dart';
import 'package:qima/models/metal_breakdown.dart';
import 'package:qima/models/money.dart';
import 'package:qima/models/zakat.dart';

void main() {
  final rates = FXRates(base: 'USD', rates: const {'USD': 1, 'SAR': 3.75}, updatedAt: DateTime(2026));

  // Round numbers: gold $3,110.34768/oz → exactly $100 per gram; silver
  // $31.1034768/oz → exactly $1 per gram.
  const goldOz = 3110.34768;
  const silverOz = 31.1034768;
  final prices = <String, double>{
    'metal.XAU': goldOz,
    'metal.XAG': silverOz,
    'crypto.BTC': 50000,
    'stock.AAPL': 200,
    'fx.SAR': 1 / 3.75,
  };
  double? latest(String id) => prices[id];

  HoldingLot lot(String instrumentID, double quantity, {PriceUnit unit = PriceUnit.each, GoldKarat? karat, String? id}) {
    return HoldingLot(
      id: id ?? '$instrumentID-$quantity-${unit.name}-${karat?.name}',
      instrumentID: instrumentID,
      quantity: quantity,
      unit: unit,
      unitCost: 1,
      costCurrency: 'USD',
      date: DateTime(2025),
      karat: karat,
    );
  }

  ZakatAssessment assess(List<HoldingLot> lots,
      {ZakatSettings settings = const ZakatSettings(), String base = 'USD', double? Function(String)? prices}) {
    return ZakatAssessment.compute(
      lots: lots,
      settings: settings,
      rates: rates,
      baseCurrency: base,
      latestUSD: prices ?? latest,
      resolve: InstrumentCatalog.instrument,
    );
  }

  group('nisab threshold', () {
    test('gold is 85 g of fine gold, silver 595 g of silver', () {
      final a = assess([lot('crypto.BTC', 1)]);
      expect(a.threshold!.amount, closeTo(8500, 1e-6));
      expect(a.otherThreshold!.amount, closeTo(595, 1e-6));
      final s = assess([lot('crypto.BTC', 1)], settings: const ZakatSettings(basis: NisabBasis.silver));
      expect(s.threshold!.amount, closeTo(595, 1e-6));
      expect(s.otherThreshold!.amount, closeTo(8500, 1e-6));
    });

    test('is expressed in the base currency', () {
      final a = assess([lot('crypto.BTC', 1)], base: 'SAR');
      expect(a.threshold!.currencyCode, 'SAR');
      expect(a.threshold!.amount, closeTo(8500 * 3.75, 1e-6));
    });

    test('is unknown when the nisab metal has no price', () {
      final a = assess([lot('crypto.BTC', 1)], prices: (id) => id == 'metal.XAU' ? null : latest(id));
      expect(a.threshold, isNull);
      expect(a.status, NisabStatus.thresholdUnknown);
      expect(a.due.amount, 0);
      // The other basis can still be shown.
      expect(a.otherThreshold!.amount, closeTo(595, 1e-6));
    });

    test('a zero price counts as no price, never a zero threshold', () {
      final a = assess([lot('crypto.BTC', 1)], prices: (id) => id == 'metal.XAU' ? 0 : latest(id));
      expect(a.status, NisabStatus.thresholdUnknown);
    });
  });

  group('status and amount due', () {
    test('no holdings', () {
      final a = assess(const []);
      expect(a.status, NisabStatus.noHoldings);
      expect(a.due.amount, 0);
      expect(a.lines, isEmpty);
    });

    test('above nisab owes 2.5% of the whole base', () {
      final a = assess([lot('crypto.BTC', 1)]); // $50,000
      expect(a.status, NisabStatus.above);
      expect(a.base.amount, closeTo(50000, 1e-6));
      expect(a.due.amount, closeTo(1250, 1e-6));
    });

    test('exactly at nisab is above', () {
      final a = assess([lot('metal.XAU', 85, unit: PriceUnit.gram)]);
      expect(a.base.amount, closeTo(8500, 1e-6));
      expect(a.status, NisabStatus.above);
      expect(a.due.amount, closeTo(212.5, 1e-6));
    });

    test('below nisab owes nothing', () {
      final a = assess([lot('metal.XAU', 84, unit: PriceUnit.gram)]);
      expect(a.status, NisabStatus.below);
      expect(a.due.amount, 0);
    });

    test('the silver basis brings more people above nisab', () {
      final lots = [lot('metal.XAG', 1000, unit: PriceUnit.gram)]; // $1,000
      expect(assess(lots).status, NisabStatus.below);
      expect(assess(lots, settings: const ZakatSettings(basis: NisabBasis.silver)).status, NisabStatus.above);
    });

    test('everything excluded with a known threshold reads as below, not above', () {
      final a = assess([lot('stock.AAPL', 1000)]);
      expect(a.base.amount, 0);
      expect(a.status, NisabStatus.below);
    });
  });

  group('what counts', () {
    test('karat gold counts by its fine-gold content', () {
      // 100 g of 21K = 87.5 g fine = $8,750 → just above the 85 g nisab.
      final a = assess([lot('metal.XAU', 100, unit: PriceUnit.gram, karat: GoldKarat.k21)]);
      expect(a.base.amount, closeTo(8750, 1e-6));
      expect(a.status, NisabStatus.above);
      // 96 g of 21K = 84 g fine → below, even though 96 g > 85 g.
      final b = assess([lot('metal.XAU', 96, unit: PriceUnit.gram, karat: GoldKarat.k21)]);
      expect(b.status, NisabStatus.below);
    });

    test('equities are off by default, metals crypto and cash are on', () {
      final a = assess([
        lot('stock.AAPL', 10),
        lot('crypto.BTC', 0.1),
        lot('fx.SAR', 3750),
        lot('metal.XAG', 100, unit: PriceUnit.gram),
      ]);
      expect(a.base.amount, closeTo(5000 + 1000 + 100, 1e-6));
      final apple = a.lines.firstWhere((l) => l.instrument.id == 'stock.AAPL');
      expect(apple.exclusion, ZakatExclusion.classOff);
      expect(apple.value!.amount, closeTo(2000, 1e-6), reason: 'an excluded asset still shows its value');
    });

    test('indices count as equities', () {
      expect(ZakatClass.of(AssetClass.indices), ZakatClass.equities);
      expect(ZakatClass.of(AssetClass.fiat), ZakatClass.cash);
    });

    test('switching a class on includes it', () {
      final settings = const ZakatSettings().toggleClass(ZakatClass.equities);
      final a = assess([lot('stock.AAPL', 10)], settings: settings);
      expect(a.base.amount, closeTo(2000, 1e-6));
    });

    test('a per-asset override beats its class, both ways', () {
      final gold = InstrumentCatalog.instrument('metal.XAU')!;
      final apple = InstrumentCatalog.instrument('stock.AAPL')!;
      final settings = const ZakatSettings().toggleHolding(gold).toggleHolding(apple);
      final a = assess([lot('metal.XAU', 100, unit: PriceUnit.gram), lot('stock.AAPL', 10)], settings: settings);
      expect(a.base.amount, closeTo(2000, 1e-6));
      expect(a.lines.firstWhere((l) => l.instrument.id == 'metal.XAU').exclusion, ZakatExclusion.holdingOff);
    });

    test('toggling an asset back to its class default drops the override', () {
      final gold = InstrumentCatalog.instrument('metal.XAU')!;
      final settings = const ZakatSettings().toggleHolding(gold).toggleHolding(gold);
      expect(settings.holdingOverrides, isEmpty);
      expect(settings.includes(gold), isTrue);
    });

    test('an override survives its class being toggled off and on', () {
      final apple = InstrumentCatalog.instrument('stock.AAPL')!;
      var settings = const ZakatSettings().toggleHolding(apple); // forced in
      settings = settings.toggleClass(ZakatClass.equities); // class on
      expect(settings.includes(apple), isTrue);
    });

    test('an unpriced asset is listed, flagged and left out of the base', () {
      final a = assess([lot('crypto.BTC', 1), lot('crypto.ETH', 10)]);
      final eth = a.lines.firstWhere((l) => l.instrument.id == 'crypto.ETH');
      expect(eth.exclusion, ZakatExclusion.noPrice);
      expect(eth.value, isNull);
      expect(a.hasUnpricedHoldings, isTrue);
      expect(a.base.amount, closeTo(50000, 1e-6));
    });

    test('lots of an instrument no longer in the catalog are skipped', () {
      final a = assess([lot('custom.GONE', 5), lot('crypto.BTC', 1)]);
      expect(a.lines.map((l) => l.instrument.id), ['crypto.BTC']);
    });

    test('several lots of one asset are one line', () {
      final a = assess([lot('crypto.BTC', 0.5, id: 'a'), lot('crypto.BTC', 0.5, id: 'b')]);
      expect(a.lines, hasLength(1));
      expect(a.lines.single.lots, hasLength(2));
      expect(a.base.amount, closeTo(50000, 1e-6));
    });

    test('lines list counted assets first, largest first', () {
      final a = assess([
        lot('stock.AAPL', 1000), // $200k but excluded
        lot('metal.XAG', 100, unit: PriceUnit.gram), // $100
        lot('crypto.BTC', 1), // $50k
      ]);
      expect(a.lines.map((l) => l.instrument.id), ['crypto.BTC', 'metal.XAG', 'stock.AAPL']);
    });
  });

  group('settings JSON', () {
    test('round-trips', () {
      final settings = ZakatSettings(
        basis: NisabBasis.silver,
        includedClasses: const {ZakatClass.metals, ZakatClass.equities},
        holdingOverrides: const {'metal.XAU': false},
        calendar: HawlCalendar.gregorian,
        hawlStart: DateTime(2025, 3, 12),
        remind: true,
      );
      expect(ZakatSettings.fromJson(settings.toJson()), settings);
    });

    test('stores the hawl start as a calendar day, not an instant', () {
      final json = ZakatSettings(hawlStart: DateTime(2025, 3, 12, 23, 30)).toJson();
      expect(json['hawlStart'], '2025-03-12');
    });

    test('defaults are what an empty object reads as', () {
      expect(ZakatSettings.fromJson(const {}), const ZakatSettings());
    });

    test('garbage values fall back field by field', () {
      final s = ZakatSettings.fromJson(const {
        'basis': 'copper',
        'classes': ['metals', 'nonsense', 3],
        'overrides': {'metal.XAU': 'yes', 'crypto.BTC': false},
        'calendar': 42,
        'hawlStart': 'not a date',
        'remind': 'true',
      });
      expect(s.basis, NisabBasis.gold);
      expect(s.includedClasses, {ZakatClass.metals});
      expect(s.holdingOverrides, {'crypto.BTC': false});
      expect(s.calendar, HawlCalendar.hijri);
      expect(s.hawlStart, isNull);
      expect(s.remind, isFalse);
    });

    test('an empty class list is kept as "nothing counts", not reset to defaults', () {
      expect(ZakatSettings.fromJson(const {'classes': []}).includedClasses, isEmpty);
    });
  });

  group('HawlSchedule', () {
    test('null without a start date', () {
      expect(HawlSchedule.of(const ZakatSettings(), DateTime(2026)), isNull);
    });

    test('Hijri: the first hawl completes on the same Hijri day a year later', () {
      final start = const HijriDate(1446, 9, 12).toGregorian()!;
      final firstEnd = const HijriDate(1447, 9, 12).toGregorian()!;
      final settings = ZakatSettings(hawlStart: start);
      final mid = HawlSchedule.of(settings, start.add(const Duration(days: 100)))!;
      expect(mid.next, firstEnd);
      expect(mid.lastCompleted, isNull);
      expect(mid.completesToday, isFalse);
    });

    test('completes today on the anniversary itself', () {
      final start = const HijriDate(1446, 9, 12).toGregorian()!;
      final end = const HijriDate(1447, 9, 12).toGregorian()!;
      final s = HawlSchedule.of(ZakatSettings(hawlStart: start), end.add(const Duration(hours: 15)))!;
      expect(s.completesToday, isTrue);
      expect(s.daysUntilNext, 0);
      expect(s.lastCompleted, end);
    });

    test('the day after an anniversary rolls on to the next year', () {
      final start = const HijriDate(1446, 9, 12).toGregorian()!;
      final end = const HijriDate(1447, 9, 12).toGregorian()!;
      final s = HawlSchedule.of(ZakatSettings(hawlStart: start), end.add(const Duration(days: 1)))!;
      expect(s.lastCompleted, end);
      expect(s.next, const HijriDate(1448, 9, 12).toGregorian());
    });

    test('counts days by calendar day', () {
      final s = HawlSchedule.of(
        ZakatSettings(hawlStart: DateTime(2025, 1, 10), calendar: HawlCalendar.gregorian),
        DateTime(2026, 1, 7, 23, 59),
      )!;
      expect(s.daysUntilNext, 3);
    });

    test('Gregorian 29 February clamps to 28 February in common years', () {
      expect(HawlSchedule.anniversaryOf(DateTime(2024, 2, 29), 1, HawlCalendar.gregorian), DateTime(2025, 2, 28));
      expect(HawlSchedule.anniversaryOf(DateTime(2024, 2, 29), 4, HawlCalendar.gregorian), DateTime(2028, 2, 29));
    });

    test('a start several years back lands on the right year', () {
      final s = HawlSchedule.of(
        ZakatSettings(hawlStart: DateTime(2019, 6, 1), calendar: HawlCalendar.gregorian),
        DateTime(2026, 3, 1),
      )!;
      expect(s.next, DateTime(2026, 6, 1));
      expect(s.lastCompleted, DateTime(2025, 6, 1));
    });

    test('a future start has its first completion a year after it', () {
      final s = HawlSchedule.of(
        ZakatSettings(hawlStart: DateTime(2026, 6, 1), calendar: HawlCalendar.gregorian),
        DateTime(2026, 3, 1),
      )!;
      expect(s.next, DateTime(2027, 6, 1));
      expect(s.lastCompleted, isNull);
    });

    test('a Hijri start outside the Umm al-Qura table falls back to Gregorian', () {
      expect(HawlSchedule.anniversaryOf(DateTime(1930, 5, 5), 1, HawlCalendar.hijri), DateTime(1931, 5, 5));
    });

    test('a Hijri anniversary past the end of the table is null', () {
      expect(HawlSchedule.anniversaryOf(DateTime(2077, 1, 1), 2, HawlCalendar.hijri), isNull);
    });
  });
}
