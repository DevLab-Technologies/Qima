import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:qima/l10n/app_localizations_ar.dart';
import 'package:qima/l10n/app_localizations_en.dart';
import 'package:qima/models/asset.dart';
import 'package:qima/models/holding_transaction.dart';
import 'package:qima/models/metal_breakdown.dart';
import 'package:qima/services/backup/holdings_csv.dart';
import 'package:qima/services/csv/csv_import.dart';
import 'package:qima/services/csv/csv_reader.dart';

void main() {
  final now = DateTime(2026, 10, 21);
  const currencies = ['USD', 'SAR', 'EUR', 'AED'];
  var counter = 0;
  String nextId() => 'row-${counter++}';

  setUp(() => counter = 0);

  CsvImportPlan planFor(String csv, {List<HoldingTransaction> existing = const [], CsvMapping Function(CsvMapping)? adjust}) {
    final table = CsvReader.parse(csv);
    var mapping = CsvImporter.autoMap(table, fallbackCurrency: 'USD');
    if (adjust != null) mapping = adjust(mapping);
    return CsvImporter.plan(table, mapping, existing: existing, availableCurrencies: currencies, now: now, newId: nextId);
  }

  group('CsvReader', () {
    test('quotes, escaped quotes, embedded delimiters and line breaks', () {
      final t = CsvReader.parse('a,b,c\r\n"1,5","say ""hi""","two\nlines"\r\n');
      expect(t.rows, [
        ['a', 'b', 'c'],
        ['1,5', 'say "hi"', 'two\nlines'],
      ]);
    });

    test('detects semicolons and tabs, strips a BOM and skips blank rows', () {
      expect(CsvReader.parse('﻿a;b\n1;2\n\n').rows, [
        ['a', 'b'],
        ['1', '2'],
      ]);
      expect(CsvReader.parse('a\tb\n1\t2').delimiter, '\t');
    });

    test('undoes the export\'s formula guard', () {
      expect(CsvReader.parse("x\n'=SUM(A1)\n").body.single.single, '=SUM(A1)');
    });

    test('a missing final newline still yields the last row', () {
      expect(CsvReader.parse('a,b\n1,2').body.single, ['1', '2']);
    });
  });

  group('value parsing', () {
    test('numbers in both conventions, with symbols and Arabic-Indic digits', () {
      expect(CsvImporter.parseNumber(r'$1,234.50', decimalComma: false), 1234.5);
      expect(CsvImporter.parseNumber('1.234,50 €', decimalComma: true), 1234.5);
      expect(CsvImporter.parseNumber('1 234,5', decimalComma: true), 1234.5);
      expect(CsvImporter.parseNumber('(15)', decimalComma: false), -15);
      expect(CsvImporter.parseNumber('١٢٣٫٥', decimalComma: false), 123.5);
      expect(CsvImporter.parseNumber('abc', decimalComma: false), isNull);
    });

    test('dates: ISO, either numeric order, written out, serial numbers', () {
      expect(CsvImporter.parseDate('2026-03-04', DateOrder.monthFirst), DateTime(2026, 3, 4));
      expect(CsvImporter.parseDate('04/03/2026', DateOrder.dayFirst), DateTime(2026, 3, 4));
      expect(CsvImporter.parseDate('03/04/2026', DateOrder.monthFirst), DateTime(2026, 3, 4));
      expect(CsvImporter.parseDate('4.3.26', DateOrder.dayFirst), DateTime(2026, 3, 4));
      expect(CsvImporter.parseDate('4 Mar 2026', DateOrder.dayFirst), DateTime(2026, 3, 4));
      expect(CsvImporter.parseDate('March 4, 2026', DateOrder.dayFirst), DateTime(2026, 3, 4));
      expect(CsvImporter.parseDate('46085', DateOrder.dayFirst), DateTime(2026, 3, 4));
      expect(CsvImporter.parseDate('31/04/2026', DateOrder.dayFirst), isNull, reason: 'no 31 April');
      expect(CsvImporter.parseDate('soon', DateOrder.dayFirst), isNull);
    });

    test('types, units and karats in several languages', () {
      expect(CsvImporter.parseKind('Sold'), TransactionKind.sell);
      expect(CsvImporter.parseKind('بيع'), TransactionKind.sell);
      expect(CsvImporter.parseKind('Achat'), TransactionKind.buy);
      expect(CsvImporter.parseKind('Transfer in'), TransactionKind.transferIn);
      expect(CsvImporter.parseKind('maybe'), isNull);
      expect(CsvImporter.parseUnit('g'), PriceUnit.gram);
      expect(CsvImporter.parseUnit('جرام'), PriceUnit.gram);
      expect(CsvImporter.parseUnit('oz t'), PriceUnit.troyOunce);
      expect(CsvImporter.parseKarat('21K'), GoldKarat.k21);
      expect(CsvImporter.parseKarat('عيار ٢١'), GoldKarat.k21);
      expect(CsvImporter.parseKarat('14K'), isNull);
    });

    test('works out the date order when the data settles it', () {
      expect(CsvImporter.detectDateOrder(CsvReader.parse('d\n03/04/2026\n25/04/2026'), 0), DateOrder.dayFirst);
      expect(CsvImporter.detectDateOrder(CsvReader.parse('d\n04/25/2026'), 0), DateOrder.monthFirst);
      expect(CsvImporter.detectDateOrder(CsvReader.parse('d\n03/04/2026'), 0), isNull);
      expect(CsvImporter.hasAmbiguousDates(CsvReader.parse('d\n03/04/2026'), 0), isTrue);
      expect(CsvImporter.hasAmbiguousDates(CsvReader.parse('d\n2026-03-04'), 0), isFalse);
    });
  });

  group('mapping', () {
    test('maps common English headers', () {
      final table = CsvReader.parse('Date,Ticker,Side,Qty,Price,Commission,Currency,Notes\n');
      final m = CsvImporter.autoMap(table, fallbackCurrency: 'USD');
      expect(m[CsvField.date], 0);
      expect(m[CsvField.symbol], 1);
      expect(m[CsvField.type], 2);
      expect(m[CsvField.quantity], 3);
      expect(m[CsvField.unitPrice], 4);
      expect(m[CsvField.fee], 5);
      expect(m[CsvField.currency], 6);
      expect(m[CsvField.note], 7);
      expect(m.isUsable, isTrue);
    });

    test('maps Arabic headers and picks a decimal comma for semicolon files', () {
      final ar = AppLocalizationsAr();
      final table = CsvReader.parse('${ar.backupCsvHeaderDate};${ar.backupCsvHeaderInstrument};${ar.backupCsvHeaderQuantity}\n');
      final m = CsvImporter.autoMap(table, fallbackCurrency: 'SAR');
      expect(m[CsvField.date], 0);
      expect(m[CsvField.asset], 1);
      expect(m[CsvField.quantity], 2);
      expect(m.decimalComma, isTrue);
    });

    test('a column feeds one field only', () {
      const m = CsvMapping(columns: {CsvField.total: 3}, fallbackCurrency: 'USD');
      final next = m.withColumn(CsvField.unitPrice, 3);
      expect(next.columns, {CsvField.unitPrice: 3});
      expect(next.withColumn(CsvField.unitPrice, null).columns, isEmpty);
    });

    test('is not usable without an asset, a date and a quantity', () {
      expect(const CsvMapping(columns: {CsvField.asset: 0, CsvField.date: 1}, fallbackCurrency: 'USD').isUsable, isFalse);
    });
  });

  group('plan', () {
    test('reads buys by symbol or name, in any language', () {
      final plan = planFor('Date,Asset,Quantity,Unit,Karat,Price\n'
          '2026-01-05,Gold,100,g,21K,75\n'
          '2026-02-01,BTC,0.5,,,60000\n'
          '2026-02-02,الفضة,1,kg,,900\n');
      expect(plan.readyCount, 3);
      final gold = plan.ready[0];
      expect(gold.instrumentID, 'metal.XAU');
      expect(gold.unit, PriceUnit.gram);
      expect(gold.karat, GoldKarat.k21);
      expect(gold.kind, TransactionKind.buy);
      expect(plan.ready[1].unit, PriceUnit.each);
      expect(plan.ready[2].instrumentID, 'metal.XAG');
    });

    test('a total stands in for the price, and fee rows need only an amount', () {
      final plan = planFor('Date,Type,Asset,Quantity,Total,Fee\n'
          '2026-01-05,Buy,BTC,2,100000,\n'
          '2026-01-06,Fee,BTC,,,12\n');
      expect(plan.ready[0].unitPrice, 50000);
      expect(plan.ready[1].kind, TransactionKind.fee);
      expect(plan.ready[1].fee, 12);
    });

    test('a negative quantity with no type column is a sale', () {
      final plan = planFor('Date,Asset,Quantity,Price\n2026-01-05,BTC,1,100\n2026-02-05,BTC,-0.4,150\n');
      expect(plan.ready[1].kind, TransactionKind.sell);
      expect(plan.ready[1].quantity, 0.4);
    });

    test('every reason a row fails is listed, and the row is skipped', () {
      final plan = planFor('Date,Type,Asset,Quantity,Unit,Karat,Price,Currency\n'
          '2026-01-05,Buy,Unobtainium,1,,,10,USD\n'
          'someday,Buy,BTC,1,,,10,USD\n'
          '2030-01-01,Buy,BTC,1,,,10,USD\n'
          '2026-01-05,Buy,BTC,,,,10,USD\n'
          '2026-01-05,Buy,BTC,1,,,,USD\n'
          '2026-01-05,Swap,BTC,1,,,10,USD\n'
          '2026-01-05,Buy,BTC,1,,,10,XYZ\n'
          '2026-01-05,Buy,BTC,1,g,,10,USD\n'
          '2026-01-05,Buy,Silver,1,g,21K,10,USD\n'
          '2026-01-05,Buy,BTC,lots,,,10,USD\n');
      List<CsvProblem> at(int i) => plan.rows[i].problems;
      expect(at(0), contains(CsvProblem.unknownAsset));
      expect(at(1), contains(CsvProblem.badDate));
      expect(at(2), contains(CsvProblem.futureDate));
      expect(at(3), contains(CsvProblem.missingQuantity));
      expect(at(4), contains(CsvProblem.missingPrice));
      expect(at(5), contains(CsvProblem.unknownType));
      expect(at(6), contains(CsvProblem.unknownCurrency));
      expect(at(7), contains(CsvProblem.unsupportedUnit));
      expect(at(8), contains(CsvProblem.unsupportedKarat));
      expect(at(9), contains(CsvProblem.badNumber));
      expect(plan.readyCount, 0);
      expect(plan.rows.map((r) => r.line), [2, 3, 4, 5, 6, 7, 8, 9, 10, 11]);
    });

    test('a sale of more than would be held is refused, and only that one', () {
      final plan = planFor('Date,Type,Asset,Quantity,Price\n'
          '2026-01-05,Buy,BTC,1,100\n'
          '2026-02-01,Sell,BTC,2,150\n'
          '2026-03-01,Sell,BTC,0.5,150\n');
      expect(plan.rows[1].problems, [CsvProblem.oversell]);
      expect(plan.rows[2].ready, isTrue, reason: 'valid once the bad sale is left out');
    });

    test('a sale can draw on what is already in the ledger', () {
      final existing = [
        HoldingTransaction(
          id: 'mine',
          instrumentID: 'crypto.BTC',
          kind: TransactionKind.buy,
          quantity: 1,
          unit: PriceUnit.each,
          unitPrice: 100,
          currency: 'USD',
          date: DateTime(2025, 1, 1),
        ),
      ];
      final plan = planFor('Date,Type,Asset,Quantity,Price\n2026-02-01,Sell,BTC,1,150\n', existing: existing);
      expect(plan.readyCount, 1);
    });

    test('rows already in the ledger are recognised as duplicates', () {
      final existing = [
        HoldingTransaction(
          id: 'mine',
          instrumentID: 'crypto.BTC',
          kind: TransactionKind.buy,
          quantity: 1,
          unit: PriceUnit.each,
          unitPrice: 100,
          currency: 'USD',
          date: DateTime(2026, 1, 5, 14),
        ),
      ];
      final plan = planFor('Date,Asset,Quantity,Price\n2026-01-05,BTC,1,100\n2026-01-06,BTC,1,100\n', existing: existing);
      expect(plan.duplicateCount, 1);
      expect(plan.readyCount, 1);
      expect(plan.problemCount, 0);
    });

    test('the fallback currency applies to rows with no currency', () {
      final plan = planFor('Date,Asset,Quantity,Price\n2026-01-05,BTC,1,100\n',
          adjust: (m) => m.copyWith(fallbackCurrency: 'SAR'));
      expect(plan.ready.single.currency, 'SAR');
    });
  });

  test('an export imports back as the same ledger', () {
    final ledger = [
      HoldingTransaction(
        id: 'a',
        instrumentID: 'metal.XAU',
        kind: TransactionKind.buy,
        quantity: 100,
        unit: PriceUnit.gram,
        karat: GoldKarat.k21,
        unitPrice: 75.5,
        fee: 10,
        currency: 'SAR',
        date: DateTime(2026, 1, 5),
        note: 'From the souk, "best" price',
      ),
      HoldingTransaction(
        id: 'b',
        instrumentID: 'metal.XAU',
        kind: TransactionKind.sell,
        quantity: 20,
        unit: PriceUnit.gram,
        karat: GoldKarat.k21,
        unitPrice: 90,
        currency: 'SAR',
        date: DateTime(2026, 3, 1),
      ),
      HoldingTransaction(
        id: 'c',
        instrumentID: 'metal.XAU',
        kind: TransactionKind.fee,
        quantity: 0,
        unit: PriceUnit.gram,
        unitPrice: 0,
        fee: 25,
        currency: 'SAR',
        date: DateTime(2026, 4, 1),
      ),
    ];
    for (final l10n in [AppLocalizationsEn(), AppLocalizationsAr()]) {
      final bytes = HoldingsCsv.bytes(ledger, l10n);
      final plan = planFor(utf8.decode(bytes));
      expect(plan.readyCount, 3, reason: 'in ${l10n.localeName}: ${plan.rows.map((r) => r.problems)}');
      for (var i = 0; i < 3; i++) {
        final got = plan.ready[i];
        final want = ledger[i];
        expect(got.kind, want.kind);
        expect(got.instrumentID, want.instrumentID);
        expect(got.quantity, want.quantity);
        expect(got.unit, want.kind == TransactionKind.fee ? got.unit : want.unit);
        expect(got.karat, want.karat);
        expect(got.unitPrice, want.unitPrice);
        expect(got.fee, want.fee);
        expect(got.currency, want.currency);
        expect(got.date, want.date);
        expect(got.note, want.note);
      }
    }
  });
}
