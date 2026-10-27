/// A parsed CSV file: its rows of cells, and the delimiter it used.
class CsvTable {
  final List<List<String>> rows;
  final String delimiter;

  const CsvTable(this.rows, this.delimiter);

  List<String> get header => rows.isEmpty ? const [] : rows.first;

  List<List<String>> get body => rows.length <= 1 ? const [] : rows.sublist(1);
}

/// Reads CSV the way spreadsheets write it (RFC 4180): quoted cells may hold
/// the delimiter, quotes ("" inside quotes) and line breaks; rows end in LF
/// or CRLF. The delimiter is whichever of comma, semicolon or tab splits the
/// header line into the most cells — European spreadsheets save with
/// semicolons because the comma is their decimal separator.
class CsvReader {
  CsvReader._();

  static const List<String> _candidates = [',', ';', '\t'];

  static CsvTable parse(String text) {
    var source = text;
    // A UTF-8 byte-order mark decoded as text (Excel adds one).
    if (source.startsWith('﻿')) source = source.substring(1);
    final delimiter = _detectDelimiter(source);
    final rows = <List<String>>[];
    var row = <String>[];
    final cell = StringBuffer();
    var inQuotes = false;
    var cellWasQuoted = false;

    void endCell() {
      row.add(_clean(cell.toString(), quoted: cellWasQuoted));
      cell.clear();
      cellWasQuoted = false;
    }

    void endRow() {
      endCell();
      // Skip rows that are entirely empty (trailing newlines, spacer rows).
      if (row.any((c) => c.isNotEmpty)) rows.add(row);
      row = <String>[];
    }

    for (var i = 0; i < source.length; i++) {
      final ch = source[i];
      if (inQuotes) {
        if (ch == '"') {
          if (i + 1 < source.length && source[i + 1] == '"') {
            cell.write('"');
            i++;
          } else {
            inQuotes = false;
          }
        } else {
          cell.write(ch);
        }
        continue;
      }
      if (ch == '"' && cell.toString().trim().isEmpty) {
        inQuotes = true;
        cellWasQuoted = true;
        cell.clear();
      } else if (ch == delimiter) {
        endCell();
      } else if (ch == '\r') {
        if (i + 1 < source.length && source[i + 1] == '\n') i++;
        endRow();
      } else if (ch == '\n') {
        endRow();
      } else {
        cell.write(ch);
      }
    }
    if (cell.isNotEmpty || row.isNotEmpty) endRow();
    return CsvTable(rows, delimiter);
  }

  static String _detectDelimiter(String source) {
    final end = source.indexOf(RegExp(r'[\r\n]'));
    final firstLine = end < 0 ? source : source.substring(0, end);
    var best = ',';
    var bestCount = 0;
    for (final candidate in _candidates) {
      final count = _countOutsideQuotes(firstLine, candidate);
      if (count > bestCount) {
        best = candidate;
        bestCount = count;
      }
    }
    return best;
  }

  static int _countOutsideQuotes(String line, String delimiter) {
    var count = 0;
    var inQuotes = false;
    for (var i = 0; i < line.length; i++) {
      final ch = line[i];
      if (ch == '"') inQuotes = !inQuotes;
      if (!inQuotes && ch == delimiter) count++;
    }
    return count;
  }

  /// Trims surrounding spaces and undoes the formula-injection guard Qima's
  /// own export adds (a leading apostrophe before `=`, `+`, `-` or `@`), so
  /// an exported file imports back to the same values.
  static String _clean(String raw, {required bool quoted}) {
    var value = quoted ? raw : raw.trim();
    if (value.length > 1 && value[0] == "'" && const ['=', '+', '-', '@'].contains(value[1])) {
      value = value.substring(1);
    }
    return value;
  }
}
