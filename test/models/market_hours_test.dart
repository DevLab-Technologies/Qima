import 'package:flutter_test/flutter_test.dart';
import 'package:qima/models/asset.dart';
import 'package:qima/models/instrument_catalog.dart';
import 'package:qima/models/market_hours.dart';

Instrument stock(String source) => Instrument(id: 'stock.$source', symbol: source, assetClass: AssetClass.stock, nameKey: source);

void main() {
  group('which market an instrument trades on', () {
    test('by class, index and ticker suffix', () {
      expect(MarketHours.marketOf(InstrumentCatalog.instrument('crypto.BTC')!), Market.always);
      expect(MarketHours.marketOf(InstrumentCatalog.instrument('metal.XAU')!), Market.metals);
      expect(MarketHours.marketOf(InstrumentCatalog.instrument('fx.EUR')!), Market.fx);
      expect(MarketHours.marketOf(InstrumentCatalog.instrument('stock.AAPL')!), Market.us);
      expect(MarketHours.marketOf(InstrumentCatalog.instrument('index.FTSE')!), Market.london);
      expect(MarketHours.marketOf(InstrumentCatalog.instrument('index.N225')!), Market.tokyo);
      expect(MarketHours.marketOf(stock('2222.SR')), Market.tadawul);
      expect(MarketHours.marketOf(stock('COMI.CA')), Market.egx);
      expect(MarketHours.marketOf(stock('EMAAR.AE')), Market.uae);
      expect(MarketHours.marketOf(stock('VOD.L')), Market.london);
      expect(MarketHours.marketOf(stock('ABC.XYZ')), isNull, reason: 'an unknown exchange shows no hours');
    });
  });

  group('open or closed', () {
    test('US stocks: open in the session, closed after it with the next open', () {
      // Fri 2026-11-06 15:00 New York (EST, UTC-5) = 20:00 UTC.
      final open = MarketHours.status(Market.us, DateTime.utc(2026, 11, 6, 20));
      expect(open.open, isTrue);
      expect(open.next, DateTime.utc(2026, 11, 6, 21));
      // Saturday: opens Monday 09:30 New York = 14:30 UTC.
      final shut = MarketHours.status(Market.us, DateTime.utc(2026, 11, 7, 12));
      expect(shut.open, isFalse);
      expect(shut.next, DateTime.utc(2026, 11, 9, 14, 30));
    });

    test('US summer time moves the session an hour earlier in UTC', () {
      // Wed 2026-07-01 13:45 UTC = 09:45 EDT: open.
      expect(MarketHours.status(Market.us, DateTime.utc(2026, 7, 1, 13, 45)).open, isTrue);
      // Wed 2026-01-07 13:45 UTC = 08:45 EST: not yet.
      final early = MarketHours.status(Market.us, DateTime.utc(2026, 1, 7, 13, 45));
      expect(early.open, isFalse);
      expect(early.next, DateTime.utc(2026, 1, 7, 14, 30));
    });

    test('US holidays: Thanksgiving, Good Friday and an observed July 4th', () {
      expect(MarketHours.status(Market.us, DateTime.utc(2026, 11, 26, 16)).open, isFalse);
      expect(MarketHours.status(Market.us, DateTime.utc(2026, 4, 3, 16)).open, isFalse, reason: 'Good Friday 2026');
      expect(MarketHours.status(Market.us, DateTime.utc(2026, 7, 3, 16)).open, isFalse, reason: 'July 4th falls on a Saturday');
      expect(MarketHours.status(Market.us, DateTime.utc(2026, 11, 27, 16)).open, isTrue);
    });

    test('Tadawul trades Sunday to Thursday, 10:00 to 15:00 Riyadh', () {
      // Sun 2026-11-08 08:00 UTC = 11:00 Riyadh.
      expect(MarketHours.status(Market.tadawul, DateTime.utc(2026, 11, 8, 8)).open, isTrue);
      // Fri 2026-11-06: opens Sunday 10:00 Riyadh = 07:00 UTC.
      final friday = MarketHours.status(Market.tadawul, DateTime.utc(2026, 11, 6, 9));
      expect(friday.open, isFalse);
      expect(friday.next, DateTime.utc(2026, 11, 8, 7));
    });

    test('Tokyo closes for lunch', () {
      // Mon 2026-11-09 03:00 UTC = 12:00 Tokyo.
      final lunch = MarketHours.status(Market.tokyo, DateTime.utc(2026, 11, 9, 3));
      expect(lunch.open, isFalse);
      expect(lunch.next, DateTime.utc(2026, 11, 9, 3, 30));
    });

    test('gold runs across midnight, stops an hour a day and for the weekend', () {
      // Tue 2026-11-10 05:00 UTC = 00:00 New York: open, through to 17:00.
      final night = MarketHours.status(Market.metals, DateTime.utc(2026, 11, 10, 5));
      expect(night.open, isTrue);
      expect(night.next, DateTime.utc(2026, 11, 10, 22));
      // The daily break, 17:00 to 18:00 New York.
      expect(MarketHours.status(Market.metals, DateTime.utc(2026, 11, 10, 22, 30)).open, isFalse);
      // Saturday: opens Sunday 18:00 New York = 23:00 UTC.
      final weekend = MarketHours.status(Market.metals, DateTime.utc(2026, 11, 7, 12));
      expect(weekend.open, isFalse);
      expect(weekend.next, DateTime.utc(2026, 11, 8, 23));
    });

    test('currencies trade all week, crypto never closes', () {
      final fx = MarketHours.status(Market.fx, DateTime.utc(2026, 11, 10, 12));
      expect(fx.open, isTrue);
      expect(fx.next, DateTime.utc(2026, 11, 13, 22), reason: 'Friday 17:00 New York');
      expect(MarketHours.status(Market.always, DateTime.utc(2026, 11, 7, 12)), const MarketStatus(open: true));
    });

    test('Egypt keeps summer time', () {
      // Sun 2026-07-05 07:30 UTC = 10:30 Cairo summer time: open.
      expect(MarketHours.status(Market.egx, DateTime.utc(2026, 7, 5, 7, 30)).open, isTrue);
      // Sun 2026-11-08 07:30 UTC = 09:30 Cairo winter time: not yet.
      expect(MarketHours.status(Market.egx, DateTime.utc(2026, 11, 8, 7, 30)).open, isFalse);
    });
  });
}
