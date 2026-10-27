import 'dart:ui' show Locale;

import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../l10n/app_localizations.dart';
import '../../models/asset.dart';
import '../../models/holding_transaction.dart';
import '../../models/instrument_catalog.dart';
import '../../models/ledger.dart';
import '../../models/metal_breakdown.dart';
import '../../theme/strings.dart';
import 'csv_reader.dart';

/// What a CSV column can hold.
enum CsvField { type, asset, symbol, quantity, unit, karat, unitPrice, total, fee, currency, date, note }

/// How to read dates written with numbers only ("03/04/2026").
enum DateOrder { dayFirst, monthFirst }

/// Which column holds each field, plus the choices a file can't answer for
/// itself.
class CsvMapping extends Equatable {
  /// Column index per field; a field that's absent isn't in the file.
  final Map<CsvField, int> columns;

  /// Used for every row when there's no currency column, or its cell is
  /// empty.
  final String fallbackCurrency;
  final DateOrder dateOrder;

  /// "1.234,56" rather than "1,234.56".
  final bool decimalComma;

  const CsvMapping({
    required this.columns,
    required this.fallbackCurrency,
    this.dateOrder = DateOrder.dayFirst,
    this.decimalComma = false,
  });

  int? operator [](CsvField field) => columns[field];

  /// Enough to build a transaction from: what, how much, when.
  bool get isUsable =>
      (columns.containsKey(CsvField.asset) || columns.containsKey(CsvField.symbol)) &&
      columns.containsKey(CsvField.date) &&
      (columns.containsKey(CsvField.quantity) || columns.containsKey(CsvField.fee));

  CsvMapping withColumn(CsvField field, int? column) {
    final next = Map<CsvField, int>.of(columns)..remove(field);
    if (column != null) {
      // One column feeds one field.
      next.removeWhere((_, c) => c == column);
      next[field] = column;
    }
    return copyWith(columns: next);
  }

  CsvMapping copyWith({Map<CsvField, int>? columns, String? fallbackCurrency, DateOrder? dateOrder, bool? decimalComma}) =>
      CsvMapping(
        columns: columns ?? this.columns,
        fallbackCurrency: fallbackCurrency ?? this.fallbackCurrency,
        dateOrder: dateOrder ?? this.dateOrder,
        decimalComma: decimalComma ?? this.decimalComma,
      );

  @override
  List<Object?> get props => [columns, fallbackCurrency, dateOrder, decimalComma];
}

/// Why a row can't be imported as it stands.
enum CsvProblem {
  unknownAsset,
  missingQuantity,
  badNumber,
  missingPrice,
  missingDate,
  badDate,
  futureDate,
  unknownType,
  unknownCurrency,
  unsupportedUnit,
  unsupportedKarat,

  /// Sells more than would be held on its date.
  oversell,

  /// Already in the ledger (same asset, type, day, quantity and price).
  duplicate,
}

/// One data row, as the preview shows it.
class CsvRowOutcome extends Equatable {
  /// 1-based line number in the file, header included — what a spreadsheet
  /// shows in its margin.
  final int line;
  final List<String> cells;
  final HoldingTransaction? transaction;
  final List<CsvProblem> problems;

  const CsvRowOutcome({required this.line, required this.cells, this.transaction, this.problems = const []});

  bool get ready => problems.isEmpty && transaction != null;

  CsvRowOutcome withProblem(CsvProblem problem) =>
      CsvRowOutcome(line: line, cells: cells, transaction: transaction, problems: [...problems, problem]);

  @override
  List<Object?> get props => [line, cells, transaction, problems];
}

/// The outcome of reading every row against a mapping.
class CsvImportPlan extends Equatable {
  final List<CsvRowOutcome> rows;

  const CsvImportPlan(this.rows);

  List<HoldingTransaction> get ready => [for (final r in rows) if (r.ready) r.transaction!];

  int get readyCount => rows.where((r) => r.ready).length;

  int get duplicateCount => rows.where((r) => r.problems.contains(CsvProblem.duplicate)).length;

  int get problemCount => rows.length - readyCount - duplicateCount;

  @override
  List<Object?> get props => [rows];
}

/// Turns spreadsheet rows into ledger transactions.
///
/// Reads the file the way people actually write them: headers in any of the
/// app's four languages (and Qima's own export, so a file round-trips),
/// assets by symbol or by name, numbers with either decimal mark or
/// Arabic-Indic digits, and dates as ISO, day/month or month/day, written
/// out, or as spreadsheet serial numbers. A row that can't be read is shown
/// with its reasons and skipped — never guessed at.
class CsvImporter {
  CsvImporter._();

  static List<AppLocalizations> get _allLocales =>
      [for (final code in const ['en', 'ar', 'es', 'fr']) lookupAppLocalizations(Locale(code))];

  /// A best guess at which column is which, from the header row.
  static CsvMapping autoMap(CsvTable table, {required String fallbackCurrency}) {
    final synonyms = _headerSynonyms();
    final columns = <CsvField, int>{};
    for (var i = 0; i < table.header.length; i++) {
      final name = _normalize(table.header[i]);
      for (final field in CsvField.values) {
        if (columns.containsKey(field)) continue;
        if (synonyms[field]!.contains(name)) {
          columns[field] = i;
          break;
        }
      }
    }
    final decimalComma = table.delimiter == ';';
    final dateColumn = columns[CsvField.date];
    return CsvMapping(
      columns: columns,
      fallbackCurrency: fallbackCurrency,
      decimalComma: decimalComma,
      dateOrder: dateColumn == null ? DateOrder.dayFirst : (detectDateOrder(table, dateColumn) ?? DateOrder.dayFirst),
    );
  }

  /// Day-first or month-first, if the dates in [column] settle it: a first
  /// number over 12 can only be a day, and so can a second one. Null when
  /// every date reads both ways.
  static DateOrder? detectDateOrder(CsvTable table, int column) {
    final pattern = RegExp(r'^(\d{1,2})[/.\-](\d{1,2})[/.\-](\d{2,4})');
    for (final row in table.body) {
      if (column >= row.length) continue;
      final m = pattern.firstMatch(_westernDigits(row[column].trim()));
      if (m == null) continue;
      final first = int.parse(m.group(1)!);
      final second = int.parse(m.group(2)!);
      if (first > 12 && second <= 12) return DateOrder.dayFirst;
      if (second > 12 && first <= 12) return DateOrder.monthFirst;
    }
    return null;
  }

  /// Whether any numeric date in [column] could be read either way.
  static bool hasAmbiguousDates(CsvTable table, int column) {
    final pattern = RegExp(r'^(\d{1,2})[/.\-](\d{1,2})[/.\-](\d{2,4})');
    for (final row in table.body) {
      if (column >= row.length) continue;
      final m = pattern.firstMatch(_westernDigits(row[column].trim()));
      if (m == null) continue;
      final first = int.parse(m.group(1)!);
      final second = int.parse(m.group(2)!);
      if (first <= 12 && second <= 12 && first != second) return true;
    }
    return false;
  }

  static CsvImportPlan plan(
    CsvTable table,
    CsvMapping mapping, {
    required List<HoldingTransaction> existing,
    required List<String> availableCurrencies,
    required DateTime now,
    String Function()? newId,
  }) {
    final ids = newId ?? () => const Uuid().v4();
    final assets = _assetIndex();
    final today = DateTime(now.year, now.month, now.day);
    final currencies = availableCurrencies.toSet();

    final rows = <CsvRowOutcome>[];
    for (var r = 0; r < table.body.length; r++) {
      rows.add(_readRow(table.body[r], r + 2, mapping, assets, currencies, today, ids));
    }

    // Already in the ledger.
    for (var i = 0; i < rows.length; i++) {
      final t = rows[i].transaction;
      if (rows[i].problems.isEmpty && t != null && existing.any((e) => _sameTransaction(e, t))) {
        rows[i] = rows[i].withProblem(CsvProblem.duplicate);
      }
    }

    // Sells that would sell more than is held, taking the existing ledger
    // and every other importable row into account. Removing the first one
    // can make a later one valid again, so they're found one at a time.
    final baseline = Ledger.derive(existing).overdrawn;
    while (true) {
      final candidate = [...existing, for (final r in rows) if (r.ready) r.transaction!];
      final newlyOverdrawn = Ledger.derive(candidate).overdrawn.difference(baseline);
      if (newlyOverdrawn.isEmpty) break;
      final first = Ledger.ordered(candidate).firstWhere((t) => newlyOverdrawn.contains(t.id));
      final index = rows.indexWhere((r) => r.transaction?.id == first.id);
      rows[index] = rows[index].withProblem(CsvProblem.oversell);
    }

    return CsvImportPlan(rows);
  }

  static bool _sameTransaction(HoldingTransaction a, HoldingTransaction b) =>
      a.instrumentID == b.instrumentID &&
      a.kind == b.kind &&
      a.date.year == b.date.year &&
      a.date.month == b.date.month &&
      a.date.day == b.date.day &&
      (a.quantity - b.quantity).abs() < 1e-9 &&
      (a.unitPrice - b.unitPrice).abs() < 1e-6 &&
      (a.fee - b.fee).abs() < 1e-6 &&
      a.currency == b.currency;

  static CsvRowOutcome _readRow(
    List<String> cells,
    int line,
    CsvMapping mapping,
    Map<String, Instrument> assets,
    Set<String> currencies,
    DateTime today,
    String Function() newId,
  ) {
    String? cell(CsvField field) {
      final column = mapping[field];
      if (column == null || column >= cells.length) return null;
      final value = cells[column].trim();
      return value.isEmpty ? null : value;
    }

    final problems = <CsvProblem>[];
    double? number(CsvField field) {
      final raw = cell(field);
      if (raw == null) return null;
      final value = parseNumber(raw, decimalComma: mapping.decimalComma);
      if (value == null) problems.add(CsvProblem.badNumber);
      return value;
    }

    // What.
    Instrument? instrument;
    for (final raw in [cell(CsvField.symbol), cell(CsvField.asset)]) {
      if (raw == null) continue;
      instrument = assets[_normalize(raw)];
      if (instrument != null) break;
    }
    if (instrument == null) problems.add(CsvProblem.unknownAsset);

    // Kind, and how much.
    var quantity = number(CsvField.quantity);
    final typeCell = cell(CsvField.type);
    TransactionKind? kind = typeCell == null ? TransactionKind.buy : parseKind(typeCell);
    if (kind == null) problems.add(CsvProblem.unknownType);
    if (quantity != null && quantity < 0) {
      // A signed quantity with no type column: negative means it left.
      if (typeCell == null) kind = TransactionKind.sell;
      quantity = -quantity;
    }
    if (kind != TransactionKind.fee && (quantity == null || quantity == 0) && !problems.contains(CsvProblem.badNumber)) {
      problems.add(CsvProblem.missingQuantity);
    }

    // Unit and karat.
    PriceUnit? unit = instrument?.quotation.defaultUnit;
    final unitCell = cell(CsvField.unit);
    if (unitCell != null && instrument != null) {
      final parsed = parseUnit(unitCell);
      if (parsed == null || !instrument.supportedUnits.contains(parsed)) {
        problems.add(CsvProblem.unsupportedUnit);
      } else {
        unit = parsed;
      }
    }
    GoldKarat? karat;
    final karatCell = cell(CsvField.karat);
    if (karatCell != null) {
      final parsed = parseKarat(karatCell);
      final karatAllowed = instrument != null && instrument.supportedKarats.isNotEmpty && unit != PriceUnit.troyOunce;
      if (parsed == null || (parsed != GoldKarat.k24 && !karatAllowed)) {
        problems.add(CsvProblem.unsupportedKarat);
      } else if (parsed != GoldKarat.k24) {
        karat = parsed;
      }
    }

    // Money.
    final unitPriceCell = number(CsvField.unitPrice);
    final total = number(CsvField.total);
    final fee = number(CsvField.fee)?.abs() ?? 0;
    var unitPrice = unitPriceCell?.abs();
    if (unitPrice == null && total != null && quantity != null && quantity > 0) unitPrice = total.abs() / quantity;
    var feeAmount = fee;
    if (kind == TransactionKind.fee) {
      feeAmount = fee > 0 ? fee : (total?.abs() ?? unitPrice ?? 0);
      unitPrice = 0;
      quantity = 0;
      if (feeAmount <= 0) problems.add(CsvProblem.missingPrice);
    } else if (kind == TransactionKind.buy || kind == TransactionKind.sell) {
      if (unitPrice == null || unitPrice <= 0) problems.add(CsvProblem.missingPrice);
    } else if (kind == TransactionKind.transferOut) {
      unitPrice = 0;
    }

    final currency = (cell(CsvField.currency) == null ? mapping.fallbackCurrency : parseCurrency(cell(CsvField.currency)!));
    if (currency == null || !currencies.contains(currency)) problems.add(CsvProblem.unknownCurrency);

    // When.
    final dateCell = cell(CsvField.date);
    DateTime? date;
    if (dateCell == null) {
      problems.add(CsvProblem.missingDate);
    } else {
      date = parseDate(dateCell, mapping.dateOrder);
      if (date == null) {
        problems.add(CsvProblem.badDate);
      } else if (date.isAfter(today)) {
        problems.add(CsvProblem.futureDate);
      }
    }

    if (problems.isNotEmpty || instrument == null || kind == null || date == null || currency == null || unit == null) {
      return CsvRowOutcome(line: line, cells: cells, problems: problems.toSet().toList());
    }
    return CsvRowOutcome(
      line: line,
      cells: cells,
      transaction: HoldingTransaction(
        id: newId(),
        instrumentID: instrument.id,
        kind: kind,
        quantity: quantity ?? 0,
        unit: unit,
        karat: karat,
        unitPrice: unitPrice ?? 0,
        fee: feeAmount,
        currency: currency,
        date: date,
        note: cell(CsvField.note) ?? '',
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Value parsing
  // ---------------------------------------------------------------------

  /// "1,234.56", "1.234,56" (with [decimalComma]), "1 234,5", "$1,200",
  /// "(15)" for −15, and Arabic-Indic digits. Null when it isn't a number.
  static double? parseNumber(String raw, {required bool decimalComma}) {
    var text = _westernDigits(raw.trim()).replaceAll('٫', decimalComma ? ',' : '.').replaceAll('٬', decimalComma ? '.' : ',');
    var negative = false;
    if (text.startsWith('(') && text.endsWith(')')) {
      negative = true;
      text = text.substring(1, text.length - 1);
    }
    // Drop currency signs, letters and grouping spaces; keep digits, signs
    // and separators.
    text = text.replaceAll(RegExp(r"[^0-9,.\-+eE]"), '');
    if (text.isEmpty) return null;
    if (decimalComma) {
      text = text.replaceAll('.', '').replaceAll(',', '.');
    } else {
      text = text.replaceAll(',', '');
    }
    final value = double.tryParse(text);
    if (value == null || value.isNaN || value.isInfinite) return null;
    return negative ? -value : value;
  }

  static TransactionKind? parseKind(String raw) {
    final name = _normalize(raw);
    for (final entry in _kindSynonyms().entries) {
      if (entry.value.contains(name)) return entry.key;
    }
    return null;
  }

  static PriceUnit? parseUnit(String raw) {
    final name = _normalize(raw);
    for (final entry in _unitSynonyms().entries) {
      if (entry.value.contains(name)) return entry.key;
    }
    return null;
  }

  static GoldKarat? parseKarat(String raw) {
    final digits = RegExp(r'\d+').firstMatch(_westernDigits(raw));
    if (digits == null) return null;
    return GoldKarat.fromRawValue(int.parse(digits.group(0)!));
  }

  static String? parseCurrency(String raw) {
    final text = raw.trim();
    const symbols = {r'$': 'USD', '€': 'EUR', '£': 'GBP', '¥': 'JPY', '﷼': 'SAR', 'ر.س': 'SAR', 'د.إ': 'AED'};
    if (symbols.containsKey(text)) return symbols[text];
    final code = text.toUpperCase();
    return RegExp(r'^[A-Z]{3}$').hasMatch(code) ? code : null;
  }

  /// ISO ("2026-03-04", with or without a time), numeric with / . or -
  /// in [order], written out ("4 Mar 2026", "March 4, 2026"), or a
  /// spreadsheet serial number. Returns a local calendar day.
  static DateTime? parseDate(String raw, DateOrder order) {
    final text = _westernDigits(raw.trim());

    final iso = RegExp(r'^(\d{4})[-/.](\d{1,2})[-/.](\d{1,2})').firstMatch(text);
    if (iso != null) {
      // A full timestamp names an instant; keep the day it falls on locally.
      final instant = text.length > 10 ? DateTime.tryParse(text) : null;
      if (instant != null) {
        final local = instant.toLocal();
        return DateTime(local.year, local.month, local.day);
      }
      return _day(int.parse(iso.group(1)!), int.parse(iso.group(2)!), int.parse(iso.group(3)!));
    }

    final numeric = RegExp(r'^(\d{1,2})[/.\-](\d{1,2})[/.\-](\d{2,4})$').firstMatch(text.split(RegExp(r'\s')).first);
    if (numeric != null) {
      final a = int.parse(numeric.group(1)!);
      final b = int.parse(numeric.group(2)!);
      var y = int.parse(numeric.group(3)!);
      if (y < 100) y += 2000;
      return order == DateOrder.dayFirst ? _day(y, b, a) : _day(y, a, b);
    }

    final serial = double.tryParse(text);
    if (serial != null && serial > 20000 && serial < 80000) {
      // Spreadsheet day numbers count from 30 Dec 1899.
      return DateTime(1899, 12, 30 + serial.floor());
    }

    // English month names, the form spreadsheets and brokers export. en_US
    // is built into intl, so this needs no locale data to be loaded first.
    for (final pattern in const ['d MMM y', 'd MMMM y', 'MMM d, y', 'MMMM d, y', 'd-MMM-y', 'd-MMM-yy']) {
      try {
        final parsed = DateFormat(pattern, 'en_US').parseStrict(text);
        return DateTime(parsed.year, parsed.month, parsed.day);
      } on FormatException {
        continue;
      }
    }
    return null;
  }

  static DateTime? _day(int y, int m, int d) {
    if (m < 1 || m > 12 || d < 1 || d > 31) return null;
    final date = DateTime(y, m, d);
    // Reject 31 April and friends instead of rolling into the next month.
    return date.month == m && date.day == d ? date : null;
  }

  // ---------------------------------------------------------------------
  // Vocabularies
  // ---------------------------------------------------------------------

  static Map<CsvField, Set<String>> _headerSynonyms() {
    final words = <CsvField, Set<String>>{
      CsvField.type: {'type', 'transaction type', 'side', 'action', 'operation', 'kind'},
      CsvField.asset: {'asset', 'instrument', 'name', 'security', 'holding', 'metal', 'coin'},
      CsvField.symbol: {'symbol', 'ticker', 'code'},
      CsvField.quantity: {'quantity', 'qty', 'amount', 'shares', 'units', 'weight', 'volume'},
      CsvField.unit: {'unit', 'uom', 'unit of measure'},
      CsvField.karat: {'karat', 'carat', 'purity', 'kt'},
      // Including the 2.x export's headers in every language, so files
      // exported before the ledger still map themselves.
      CsvField.unitPrice: {
        'price', 'unit price', 'price per unit', 'unit cost', 'cost per unit', 'rate',
        'تكلفة الوحدة', 'coste unitario', 'coût unitaire',
      },
      CsvField.total: {
        'total', 'total cost', 'value', 'cost', 'total value', 'proceeds',
        'التكلفة الاجمالية', 'coste total', 'coût total',
      },
      CsvField.fee: {'fee', 'fees', 'commission', 'charges'},
      CsvField.currency: {'currency', 'ccy', 'cost currency', 'عملة التكلفة', 'moneda del coste', 'devise du coût'},
      CsvField.date: {'date', 'trade date', 'transaction date', 'time', 'timestamp'},
      CsvField.note: {'note', 'notes', 'memo', 'comment', 'description'},
    };
    for (final l in _allLocales) {
      words[CsvField.type]!.add(_normalize(l.backupCsvHeaderType));
      words[CsvField.asset]!.add(_normalize(l.backupCsvHeaderInstrument));
      words[CsvField.symbol]!.add(_normalize(l.backupCsvHeaderSymbol));
      words[CsvField.quantity]!.add(_normalize(l.backupCsvHeaderQuantity));
      words[CsvField.unit]!.add(_normalize(l.backupCsvHeaderUnit));
      words[CsvField.karat]!.add(_normalize(l.backupCsvHeaderKarat));
      words[CsvField.unitPrice]!.add(_normalize(l.backupCsvHeaderUnitCost));
      words[CsvField.total]!.add(_normalize(l.backupCsvHeaderTotalCost));
      words[CsvField.fee]!.add(_normalize(l.backupCsvHeaderFee));
      words[CsvField.currency]!.add(_normalize(l.backupCsvHeaderCostCurrency));
      words[CsvField.date]!.add(_normalize(l.backupCsvHeaderDate));
      words[CsvField.note]!.add(_normalize(l.backupCsvHeaderNote));
    }
    return words;
  }

  static Map<TransactionKind, Set<String>> _kindSynonyms() {
    final words = <TransactionKind, Set<String>>{
      TransactionKind.buy: {'buy', 'bought', 'purchase', 'b', 'long', 'acquire'},
      TransactionKind.sell: {'sell', 'sold', 'sale', 's', 'dispose'},
      TransactionKind.transferIn: {'transfer in', 'deposit', 'in', 'received', 'receive', 'gift in'},
      TransactionKind.transferOut: {'transfer out', 'withdraw', 'withdrawal', 'out', 'sent', 'send', 'gift out'},
      TransactionKind.fee: {'fee', 'fees', 'charge', 'commission', 'storage'},
    };
    for (final l in _allLocales) {
      words[TransactionKind.buy]!.add(_normalize(l.transactionKindBuy));
      words[TransactionKind.sell]!.add(_normalize(l.transactionKindSell));
      words[TransactionKind.transferIn]!.add(_normalize(l.transactionKindTransferIn));
      words[TransactionKind.transferOut]!.add(_normalize(l.transactionKindTransferOut));
      words[TransactionKind.fee]!.add(_normalize(l.transactionKindFee));
    }
    return words;
  }

  static Map<PriceUnit, Set<String>> _unitSynonyms() {
    final words = <PriceUnit, Set<String>>{
      PriceUnit.troyOunce: {'oz', 'ozt', 'oz t', 'troy oz', 'troy ounce', 'troy ounces', 'ounce', 'ounces', 'toz'},
      PriceUnit.gram: {'g', 'gr', 'gm', 'gram', 'grams', 'gramme', 'grammes', 'غ', 'غرام', 'جرام', 'جم'},
      PriceUnit.kilogram: {'kg', 'kgs', 'kilo', 'kilos', 'kilogram', 'kilograms', 'كجم', 'كغ', 'كيلو'},
      PriceUnit.each: {'each', 'unit', 'units', 'share', 'shares', 'pcs', 'piece', 'pieces', 'coin', 'coins'},
    };
    for (final l in _allLocales) {
      words[PriceUnit.troyOunce]!..add(_normalize(l.unitTroyOunce))..add(_normalize(l.unitAbbrTroyOunce));
      words[PriceUnit.gram]!..add(_normalize(l.unitGram))..add(_normalize(l.unitAbbrGram));
      words[PriceUnit.kilogram]!..add(_normalize(l.unitKilogram))..add(_normalize(l.unitAbbrKilogram));
      words[PriceUnit.each]!.add(_normalize(l.unitEach));
    }
    return words;
  }

  /// Every way a file might name an asset: its id, symbol, source symbol
  /// and its name in each language. Custom tickers are included.
  static Map<String, Instrument> _assetIndex() {
    final index = <String, Instrument>{};
    void add(String key, Instrument instrument) => index.putIfAbsent(_normalize(key), () => instrument);
    for (final instrument in InstrumentCatalog.all) {
      add(instrument.id, instrument);
      add(instrument.symbol, instrument);
      add(instrument.sourceSymbol, instrument);
    }
    for (final l in _allLocales) {
      for (final instrument in InstrumentCatalog.all) {
        add(displayLabelFor(l, instrument.nameKey), instrument);
      }
    }
    return index;
  }

  /// Case-, space- and diacritic-insensitive key for matching words.
  static String _normalize(String raw) => raw
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[ً-ْـ]'), '') // Arabic marks and tatweel
      .replaceAll(RegExp('[أإآ]'), 'ا')
      .replaceAll(RegExp(r'[_\s]+'), ' ')
      .replaceAll(RegExp(r'[^\p{L}\p{N} .\-]', unicode: true), '')
      .trim();

  static String _westernDigits(String text) {
    const eastern = '٠١٢٣٤٥٦٧٨٩';
    const persian = '۰۱۲۳۴۵۶۷۸۹';
    final buffer = StringBuffer();
    for (final rune in text.runes) {
      final ch = String.fromCharCode(rune);
      final e = eastern.indexOf(ch);
      final p = persian.indexOf(ch);
      buffer.write(e >= 0 ? '$e' : (p >= 0 ? '$p' : ch));
    }
    return buffer.toString();
  }
}
