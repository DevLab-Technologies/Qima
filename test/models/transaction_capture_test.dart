import 'package:flutter_test/flutter_test.dart';
import 'package:qima/models/asset.dart';
import 'package:qima/models/holding_transaction.dart';
import 'package:qima/models/instrument_catalog.dart';
import 'package:qima/models/metal_breakdown.dart';
import 'package:qima/models/transaction_capture.dart';
import 'package:qima/services/ai_assist_provider.dart';

const _names = {
  'asset.gold': 'Gold',
  'asset.silver': 'Silver',
  'asset.bitcoin': 'Bitcoin',
  'asset.apple': 'Apple',
  'asset.usDollar': 'US Dollar',
  'asset.egyptianPound': 'Egyptian Pound',
};

CaptureContext _context({String base = 'EGP', DateTime? today}) => CaptureContext(
      catalog: InstrumentCatalog.builtIn,
      displayName: (i) => _names[i.nameKey] ?? i.symbol,
      baseCurrency: base,
      currencies: const {'USD', 'EUR', 'GBP', 'EGP', 'SAR', 'QAR', 'OMR', 'AED', 'KWD', 'BHD', 'JOD', 'ALL', 'TRY'},
      today: today ?? DateTime(2026, 3, 20),
    );

TransactionDraft _parse(String text, {String base = 'EGP', DateTime? today}) {
  final draft = TransactionCapture.parse(text, _context(base: base, today: today));
  expect(draft, isNotNull, reason: text);
  return draft!;
}

class _FakeProvider implements AiAssistProvider {
  final CaptureSpans spans;
  int calls = 0;
  _FakeProvider(this.spans);

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<ModelStatus> status(String localeTag) async => ModelStatus.ready;

  @override
  Future<CaptureSpans?> labelTransaction(String text, String localeTag) async {
    calls++;
    return spans;
  }

  @override
  Future<String?> phrase(String sentence, String localeTag) async => null;
}

void main() {
  group('English', () {
    test('the Figma sentence: every field read, the bare day flagged', () {
      final d = _parse('20 g of 21K gold at 4,100 EGP, bought on the 12th');
      expect(d.instrument.value.id, 'metal.XAU');
      expect(d.instrument.source, 'gold');
      expect(d.quantity.value, 20);
      expect(d.unit.value, PriceUnit.gram);
      expect(d.unit.guessed, isFalse);
      expect(d.karat?.value, GoldKarat.k21);
      expect(d.unitPrice?.value, 4100);
      expect(d.unitPrice?.guessed, isFalse);
      expect(d.currency.value, 'EGP');
      expect(d.currency.guessed, isFalse);
      expect(d.kind.value, TransactionKind.buy);
      expect(d.kind.source, 'bought');
      expect(d.date.value, DateTime(2026, 3, 12));
      expect(d.date.guessed, isTrue);
    });

    test('a total is divided by the quantity and remembered', () {
      final d = _parse('bought 10 grams gold for 41,000 EGP');
      expect(d.unitPrice?.value, 4100);
      expect(d.total?.value, 41000);
    });

    test('"per gram" after a total-looking keyword still means per unit', () {
      final d = _parse('paid 4100 EGP per gram for 10g gold');
      expect(d.unitPrice?.value, 4100);
      expect(d.total, isNull);
    });

    test('a quantity right before the name, for something counted', () {
      final d = _parse('sold 0.25 BTC at \$68,000 yesterday');
      expect(d.instrument.value.id, 'crypto.BTC');
      expect(d.quantity.value, 0.25);
      expect(d.unit.value, PriceUnit.each);
      expect(d.kind.value, TransactionKind.sell);
      expect(d.currency.value, 'USD');
      expect(d.unitPrice?.value, 68000);
      expect(d.date.value, DateTime(2026, 3, 19));
    });

    test('shares of a stock by its everyday name', () {
      final d = _parse('3 shares of apple at 190 USD');
      expect(d.instrument.value.id, 'stock.AAPL');
      expect(d.quantity.value, 3);
    });

    test('"pounds" resolves to the base currency and is flagged', () {
      final egp = _parse('20g gold at 4100 pounds');
      expect(egp.currency.value, 'EGP');
      expect(egp.currency.guessed, isTrue);
      final gbp = _parse('20g gold at 4100 pounds', base: 'GBP');
      expect(gbp.currency.value, 'GBP');
      final usdBase = _parse('20g gold at 4100 pounds', base: 'USD');
      expect(usdBase.currency.value, 'EGP');
    });

    test('a qualified currency name is not a guess', () {
      final d = _parse('1 oz gold at 2400 british pounds', base: 'EGP');
      expect(d.currency.value, 'GBP');
      expect(d.currency.guessed, isFalse);
    });

    test('no currency: the base currency, flagged, with no source', () {
      final d = _parse('20g gold at 4100');
      expect(d.currency.value, 'EGP');
      expect(d.currency.guessed, isTrue);
      expect(d.currency.source, isNull);
    });

    test('a karat alone names gold, and gold with a karat defaults to grams', () {
      final d = _parse('20 21K at 4100 EGP');
      expect(d.instrument.value.id, 'metal.XAU');
      expect(d.instrument.guessed, isTrue);
      expect(d.quantity.value, 20);
      expect(d.unit.value, PriceUnit.gram);
      expect(d.unit.guessed, isTrue);
    });

    test('a karat is dropped for troy ounces and for anything but gold', () {
      expect(_parse('1 oz 22K gold at 2400 USD').karat, isNull);
      expect(_parse('100 g 21K silver at 50 EGP').karat, isNull);
    });

    test('a lower-case word that happens to be a currency code is not one', () {
      final d = _parse('all 20g gold at 4100');
      expect(d.currency.value, 'EGP');
      expect(d.currency.guessed, isTrue);
    });

    test('lower-case code next to the amount still counts', () {
      expect(_parse('20g gold at 4100 usd').currency.value, 'USD');
    });

    test('a commission is read as the fee', () {
      final d = _parse('20g gold at 4100 EGP fee 150');
      expect(d.fee?.value, 150);
      expect(d.unitPrice?.value, 4100);
    });

    test('a bare number left over is the price, flagged', () {
      final d = _parse('20g gold 4100');
      expect(d.unitPrice?.value, 4100);
      expect(d.unitPrice?.guessed, isTrue);
    });

    test('comma decimals and thousands', () {
      expect(_parse('2,5 g gold at 4100').quantity.value, 2.5);
      expect(_parse('1 kg silver at 1,234,567.5 EGP').unitPrice?.value, 1234567.5);
    });

    test('a currency held as an asset: "1000 USD at 48.5 EGP"', () {
      final d = _parse('bought 1000 USD at 48.5 EGP');
      expect(d.instrument.value.id, 'fx.USD');
      expect(d.quantity.value, 1000);
      expect(d.currency.value, 'EGP');
      expect(d.unitPrice?.value, 48.5);
    });
  });

  group('Arabic', () {
    test('Arabic-Indic digits, عيار and جنيه', () {
      final d = _parse('اشتريت ٢٠ جرام ذهب عيار ٢١ بسعر ٤٬١٠٠ جنيه');
      expect(d.instrument.value.id, 'metal.XAU');
      expect(d.instrument.source, 'ذهب');
      expect(d.quantity.value, 20);
      expect(d.unit.value, PriceUnit.gram);
      expect(d.karat?.value, GoldKarat.k21);
      expect(d.unitPrice?.value, 4100);
      expect(d.currency.value, 'EGP');
      expect(d.kind.value, TransactionKind.buy);
      expect(d.kind.source, 'اشتريت');
    });

    test('the definite article and a sale', () {
      final d = _parse('بعت ١٠ غرام من الذهب ٢١ قيراط ب ٤٥٠٠ ريال', base: 'SAR');
      expect(d.kind.value, TransactionKind.sell);
      expect(d.instrument.source, 'الذهب');
      expect(d.unitPrice?.value, 4500);
      expect(d.currency.value, 'SAR');
    });

    test('a total in Arabic', () {
      final d = _parse('اشتريت ١٠ جرام ذهب بمبلغ ٤١٠٠٠ جنيه مصري');
      expect(d.unitPrice?.value, 4100);
      expect(d.currency.value, 'EGP');
      expect(d.currency.guessed, isFalse);
    });

    test('أمس and يوم', () {
      expect(_parse('٢٠ جرام ذهب أمس').date.value, DateTime(2026, 3, 19));
      expect(_parse('٢٠ جرام ذهب يوم ٥').date.value, DateTime(2026, 3, 5));
    });

    test('Arabic month name', () {
      final d = _parse('٢٠ جرام ذهب ١٢ فبراير');
      expect(d.date.value, DateTime(2026, 2, 12));
    });

    test('sources come back in the original digits', () {
      final d = _parse('٢٠ جرام ذهب بسعر ٤١٠٠ جنيه');
      expect(d.quantity.source, '٢٠ جرام');
    });
  });

  group('dates', () {
    test('a day later than today means last month', () {
      expect(_parse('20g gold on the 25th').date.value, DateTime(2026, 2, 25));
    });

    test('the 31st skips months without one', () {
      final d = _parse('20g gold on the 31st', today: DateTime(2026, 3, 20));
      expect(d.date.value, DateTime(2026, 1, 31));
    });

    test('a month and day later than today means last year', () {
      expect(_parse('20g gold 5 December').date.value, DateTime(2025, 12, 5));
    });

    test('ISO and day-first slash dates', () {
      expect(_parse('20g gold 2026-01-15').date.value, DateTime(2026, 1, 15));
      final slash = _parse('20g gold 15/1/2026');
      expect(slash.date.value, DateTime(2026, 1, 15));
      expect(slash.date.guessed, isFalse);
      expect(_parse('20g gold 3/1/2026').date.guessed, isTrue);
    });

    test('no date means today, not flagged', () {
      final d = _parse('20g gold at 4100');
      expect(d.date.value, DateTime(2026, 3, 20));
      expect(d.date.guessed, isFalse);
    });

    test('a future date is not used', () {
      expect(_parse('20g gold 2027-01-01').date.value, DateTime(2026, 3, 20));
    });
  });

  group('rejection', () {
    test('no instrument or no quantity is not a transaction', () {
      final c = _context();
      expect(TransactionCapture.parse('gold', c), isNull);
      expect(TransactionCapture.parse('20 grams at 4100', c), isNull);
      expect(TransactionCapture.parse('', c), isNull);
      expect(TransactionCapture.parse('0 g gold', c), isNull);
    });

    test('an ordinary search is not a transaction', () {
      final c = _context();
      expect(TransactionCapture.parse('apple', c), isNull);
      expect(TransactionCapture.parse('S&P 500', c), isNull);
    });

    test('a draft without a price is incomplete', () {
      final d = _parse('20g gold');
      expect(d.isComplete, isFalse);
    });
  });

  test('toTransaction carries every field', () {
    final t = _parse('sold 20 g of 21K gold at 4,100 EGP fee 50 on the 12th').toTransaction('id-1');
    expect(t.id, 'id-1');
    expect(t.instrumentID, 'metal.XAU');
    expect(t.kind, TransactionKind.sell);
    expect(t.quantity, 20);
    expect(t.unit, PriceUnit.gram);
    expect(t.karat, GoldKarat.k21);
    expect(t.unitPrice, 4100);
    expect(t.fee, 50);
    expect(t.currency, 'EGP');
    expect(t.date, DateTime(2026, 3, 12));
  });

  group('model spans', () {
    test('a span naming nothing in the catalog adds nothing', () async {
      final provider = _FakeProvider(const CaptureSpans(instrument: 'the yellow stuff', unitPrice: '4100'));
      expect(
        await captureTransaction('20 g of the yellow stuff at 4100', _context(), provider: provider, localeTag: 'en'),
        isNull,
      );
      expect(provider.calls, 1);
    });

    test('a span that is not in the text is discarded', () async {
      final provider = _FakeProvider(const CaptureSpans(unitPrice: '4100 EGP'));
      final d = await captureTransaction('20 g gold', _context(), provider: provider, localeTag: 'en');
      // Missing a price, so the model is asked — but "4100 EGP" was never said.
      expect(provider.calls, 1);
      expect(d?.unitPrice, isNull);
    });

    test('a model span is parsed like typed text and flagged', () {
      final d = TransactionCapture.parseWithSpans(
        '٢٠ جرام ذهب',
        const CaptureSpans(date: 'جرام', kind: 'ذهب'),
        _context(),
      )!;
      // Neither span holds a date or a kind word, so neither field changes.
      expect(d.date.value, DateTime(2026, 3, 20));
      expect(d.kind.guessed, isTrue);
      expect(d.kind.source, isNull);
    });

    test('a complete deterministic parse never asks the model', () async {
      final provider = _FakeProvider(const CaptureSpans());
      await captureTransaction('20g gold at 4100 EGP', _context(), provider: provider, localeTag: 'en');
      expect(provider.calls, 0);
    });

    test('model labels never override what was read', () {
      final d = TransactionCapture.parseWithSpans(
        'sold 20g gold at 4100 EGP',
        const CaptureSpans(kind: 'gold', quantity: '4100'),
        _context(),
      )!;
      expect(d.kind.value, TransactionKind.sell);
      expect(d.quantity.value, 20);
      expect(d.quantity.guessed, isFalse);
    });

    test('the model can fill a price the parser could not place', () {
      final d = TransactionCapture.parseWithSpans(
        'twenty grams gold 20 g, the dealer wanted 4100 for each',
        const CaptureSpans(unitPrice: '4100'),
        _context(),
      );
      expect(d?.unitPrice?.value, 4100);
    });
  });
}
