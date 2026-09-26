import 'dart:convert';

import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../models/holding.dart';
import '../../models/instrument_catalog.dart';
import '../../theme/strings.dart';

/// Builds the "Holdings spreadsheet" CSV export (spec Phase 6): one row per
/// lot — instrument name, symbol, quantity, unit, unit cost, cost currency,
/// total cost, date. Export-only; there is no CSV import path (a CSV can't
/// carry the sync metadata a restore needs — see `ImportPreviewScreen`'s
/// CSV-chosen error state).
class HoldingsCsv {
  HoldingsCsv._();

  /// UTF-8 BOM (`EF BB BF`) so Excel — which otherwise guesses the system
  /// codepage rather than UTF-8 — renders Arabic instrument names correctly
  /// instead of mojibake.
  static const List<int> _utf8Bom = [0xEF, 0xBB, 0xBF];

  /// Builds the CSV text (without the BOM — see [bytes] for the full file
  /// contents to write/share).
  static String build(List<HoldingLot> lots, AppLocalizations l10n) {
    final buffer = StringBuffer();
    buffer.write(_headerRow(l10n));
    buffer.write('\r\n');
    final dateFormat = DateFormat('yyyy-MM-dd');
    for (final lot in lots) {
      final instrument = InstrumentCatalog.instrument(lot.instrumentID);
      final name = instrument == null ? lot.instrumentID : displayLabelFor(l10n, instrument.nameKey);
      final symbol = instrument?.symbol ?? lot.instrumentID;
      final row = [
        name,
        symbol,
        _formatNumber(lot.quantity),
        displayLabelFor(l10n, lot.unit.labelKey),
        // Empty for non-gold lots and for 24K/fine gold — a karat column is
        // only meaningful for physical gold bought at less than fine purity.
        lot.karat == null ? '' : displayLabelFor(l10n, lot.karat!.shortLabelKey),
        _formatNumber(lot.unitCost),
        lot.costCurrency,
        _formatNumber(lot.totalCost),
        dateFormat.format(lot.date),
      ];
      buffer.write(row.map(_escapeCell).join(','));
      buffer.write('\r\n');
    }
    return buffer.toString();
  }

  static String _headerRow(AppLocalizations l10n) {
    final headers = [
      l10n.backupCsvHeaderInstrument,
      l10n.backupCsvHeaderSymbol,
      l10n.backupCsvHeaderQuantity,
      l10n.backupCsvHeaderUnit,
      l10n.backupCsvHeaderKarat,
      l10n.backupCsvHeaderUnitCost,
      l10n.backupCsvHeaderCostCurrency,
      l10n.backupCsvHeaderTotalCost,
      l10n.backupCsvHeaderDate,
    ];
    return headers.map(_escapeCell).join(',');
  }

  static String _formatNumber(double value) {
    // Fixed, locale-independent decimal formatting (not `toString()`, which
    // can emit scientific notation for very small/large doubles, and not
    // `NumberFormat`, which would localize the decimal separator and break
    // round-tripping in a spreadsheet). Trailing zeros are trimmed so whole
    // numbers read as `5` rather than `5.00000000`.
    var text = value.toStringAsFixed(8);
    if (text.contains('.')) {
      text = text.replaceFirst(RegExp(r'0+$'), '');
      text = text.replaceFirst(RegExp(r'\.$'), '');
    }
    return text;
  }

  /// RFC 4180 escaping plus a CSV/formula-injection guard: a cell whose
  /// first character is `=`, `+`, `-` or `@` is prefixed with a leading
  /// single quote before quoting, since Excel/Sheets would otherwise
  /// evaluate it as a formula when the file is opened (a malicious/odd
  /// custom-ticker name or symbol is the realistic attack surface here,
  /// since those are the only user-editable free-text fields that flow into
  /// this CSV).
  static String _escapeCell(String value) {
    var cell = value;
    if (cell.isNotEmpty && const ['=', '+', '-', '@'].contains(cell[0])) {
      cell = "'$cell";
    }
    final needsQuoting = cell.contains(',') || cell.contains('"') || cell.contains('\n') || cell.contains('\r');
    if (needsQuoting) {
      cell = '"${cell.replaceAll('"', '""')}"';
    }
    return cell;
  }

  /// Full file bytes — UTF-8 BOM followed by the UTF-8-encoded CSV text —
  /// ready to write to disk or share.
  static List<int> bytes(List<HoldingLot> lots, AppLocalizations l10n) {
    return [..._utf8Bom, ...utf8.encode(build(lots, l10n))];
  }
}
