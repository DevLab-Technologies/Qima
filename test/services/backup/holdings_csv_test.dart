import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:qima/l10n/app_localizations_en.dart';
import 'package:qima/models/asset.dart';
import 'package:qima/models/custom_instrument.dart';
import 'package:qima/models/holding.dart';
import 'package:qima/models/instrument_catalog.dart';
import 'package:qima/models/metal_breakdown.dart';
import 'package:qima/services/backup/holdings_csv.dart';

HoldingLot _lot({
  String instrumentID = 'metal.XAU',
  double quantity = 1,
  PriceUnit unit = PriceUnit.troyOunce,
  double unitCost = 1900,
  String costCurrency = 'USD',
  DateTime? date,
  GoldKarat? karat,
}) {
  return HoldingLot(
    id: 'lot-1',
    instrumentID: instrumentID,
    quantity: quantity,
    unit: unit,
    unitCost: unitCost,
    costCurrency: costCurrency,
    date: date ?? DateTime(2026, 1, 15),
    karat: karat,
  );
}

void main() {
  final l10n = AppLocalizationsEn();

  tearDown(() {
    // Any test that registers a custom instrument mutates the shared
    // catalog; reset it so later tests (and other files) see a clean slate.
    InstrumentCatalog.reloadCustom([]);
  });

  test('BOM is prepended to the byte output', () {
    final bytes = HoldingsCsv.bytes([_lot()], l10n);
    expect(bytes.take(3).toList(), [0xEF, 0xBB, 0xBF]);
  });

  test('header row and a plain row round-trip via comma-split', () {
    final text = HoldingsCsv.build([_lot()], l10n);
    final lines = text.split('\r\n')..removeWhere((l) => l.isEmpty);
    expect(lines, hasLength(2));
    expect(lines[0].split(','), hasLength(9));
    expect(lines[1], contains('XAU'));
    expect(lines[1], contains('1900'));
    expect(lines[1], contains('2026-01-15'));
  });

  group('Karat column', () {
    test('header includes a Karat column right after Unit', () {
      final text = HoldingsCsv.build([_lot()], l10n);
      final header = text.split('\r\n').first.split(',');
      final unitIndex = header.indexOf(l10n.backupCsvHeaderUnit);
      expect(header[unitIndex + 1], l10n.backupCsvHeaderKarat);
    });

    test('a non-gold lot has an empty Karat cell', () {
      final lot = _lot(instrumentID: 'metal.XAG', unit: PriceUnit.troyOunce);
      final text = HoldingsCsv.build([lot], l10n);
      final row = text.split('\r\n')[1].split(',');
      final header = text.split('\r\n').first.split(',');
      final karatIndex = header.indexOf(l10n.backupCsvHeaderKarat);
      expect(row[karatIndex], '');
    });

    test('a 24K/fine gold lot (null karat) has an empty Karat cell', () {
      final lot = _lot(unit: PriceUnit.gram);
      final text = HoldingsCsv.build([lot], l10n);
      final row = text.split('\r\n')[1].split(',');
      final header = text.split('\r\n').first.split(',');
      final karatIndex = header.indexOf(l10n.backupCsvHeaderKarat);
      expect(row[karatIndex], '');
    });

    test('a 21K gold lot shows its karat in the Karat cell', () {
      final lot = _lot(unit: PriceUnit.gram, karat: GoldKarat.k21);
      final text = HoldingsCsv.build([lot], l10n);
      final row = text.split('\r\n')[1].split(',');
      final header = text.split('\r\n').first.split(',');
      final karatIndex = header.indexOf(l10n.backupCsvHeaderKarat);
      expect(row[karatIndex], l10n.karatShort21);
    });
  });

  test('a value containing a comma is quoted', () {
    InstrumentCatalog.reloadCustom([CustomInstrument(symbol: 'ACME', name: 'Acme, Inc.').instrument]);
    final lot = _lot(instrumentID: 'stock.ACME');
    final text = HoldingsCsv.build([lot], l10n);
    expect(text, contains('"Acme, Inc."'));
  });

  test('a value containing a double quote is escaped by doubling', () {
    InstrumentCatalog.reloadCustom([CustomInstrument(symbol: 'ACME', name: 'The "Acme" Co').instrument]);
    final lot = _lot(instrumentID: 'stock.ACME');
    final text = HoldingsCsv.build([lot], l10n);
    expect(text, contains('"The ""Acme"" Co"'));
  });

  test('a value containing a newline is quoted', () {
    InstrumentCatalog.reloadCustom([CustomInstrument(symbol: 'ACME', name: 'Acme\nCo').instrument]);
    final lot = _lot(instrumentID: 'stock.ACME');
    final text = HoldingsCsv.build([lot], l10n);
    expect(text, contains('"Acme\nCo"'));
  });

  test('Arabic instrument names are preserved as UTF-8 text', () {
    InstrumentCatalog.reloadCustom([CustomInstrument(symbol: 'ARB', name: 'أسهم عربية').instrument]);
    final lot = _lot(instrumentID: 'stock.ARB');
    final bytes = HoldingsCsv.bytes([lot], l10n);
    final withoutBom = bytes.skip(3).toList();
    final decoded = utf8.decode(withoutBom);
    expect(decoded, contains('أسهم عربية'));
  });

  group('CSV/formula-injection guard', () {
    for (final prefix in ['=', '+', '-', '@']) {
      test('a name starting with "$prefix" is prefixed with a quote', () {
        InstrumentCatalog.reloadCustom([CustomInstrument(symbol: 'INJ', name: '${prefix}SUM(A1:A9)').instrument]);
        final lot = _lot(instrumentID: 'stock.INJ');
        final text = HoldingsCsv.build([lot], l10n);
        final dataLine = text.split('\r\n')[1];
        final firstCell = dataLine.split(',').first;
        expect(firstCell, startsWith("'$prefix"));
      });
    }

    test('a name NOT starting with a formula trigger character is left unprefixed', () {
      InstrumentCatalog.reloadCustom([CustomInstrument(symbol: 'SAFE', name: 'Safe Co').instrument]);
      final lot = _lot(instrumentID: 'stock.SAFE');
      final text = HoldingsCsv.build([lot], l10n);
      final dataLine = text.split('\r\n')[1];
      expect(dataLine, startsWith('Safe Co'));
    });
  });

  test('multiple lots each get their own row, in the order given', () {
    final lots = [
      _lot(quantity: 1),
      _lot(instrumentID: 'metal.XAG', quantity: 2),
    ];
    final text = HoldingsCsv.build(lots, l10n);
    final lines = text.split('\r\n')..removeWhere((l) => l.isEmpty);
    expect(lines, hasLength(3)); // header + 2 rows
  });

  test('whole numbers are formatted without a trailing decimal point', () {
    final text = HoldingsCsv.build([_lot(quantity: 5, unitCost: 100)], l10n);
    final dataLine = text.split('\r\n')[1];
    expect(dataLine, contains(',5,'));
    expect(dataLine, contains(',100,'));
  });
}
