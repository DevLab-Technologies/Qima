import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:xml/xml.dart';

/// Reads the first worksheet of an Excel workbook (.xlsx) as rows of cell
/// text, the way a bank's "Export to Excel" writes it. Dates stored as
/// serial numbers come back as yyyy-MM-dd when the cell's style is a date.
class XlsxReader {
  XlsxReader._();

  static List<List<String>>? read(List<int> bytes) {
    final Archive zip;
    try {
      zip = ZipDecoder().decodeBytes(bytes);
    } catch (_) {
      return null;
    }
    String? text(String name) {
      final f = zip.findFile(name);
      if (f == null) return null;
      return String.fromCharCodes(f.content);
    }

    final shared = <String>[];
    final sharedXml = _utf8(zip, 'xl/sharedStrings.xml');
    if (sharedXml != null) {
      for (final si in XmlDocument.parse(sharedXml).findAllElements('si')) {
        shared.add(si.findAllElements('t').map((t) => t.innerText).join());
      }
    }

    final dateStyles = _dateStyles(_utf8(zip, 'xl/styles.xml'));
    final sheetName = _firstSheet(zip) ?? 'xl/worksheets/sheet1.xml';
    final sheet = _utf8(zip, sheetName) ?? text(sheetName);
    if (sheet == null) return null;

    final rows = <List<String>>[];
    for (final row in XmlDocument.parse(sheet).findAllElements('row')) {
      final cells = <String>[];
      for (final c in row.findElements('c')) {
        final ref = c.getAttribute('r');
        final col = ref == null ? cells.length : _column(ref);
        while (cells.length < col) {
          cells.add('');
        }
        final type = c.getAttribute('t');
        final v = c.getElement('v')?.innerText ?? '';
        String value;
        if (type == 's') {
          final i = int.tryParse(v);
          value = i != null && i < shared.length ? shared[i] : '';
        } else if (type == 'inlineStr') {
          value = c.findAllElements('t').map((t) => t.innerText).join();
        } else {
          final style = int.tryParse(c.getAttribute('s') ?? '');
          final serial = double.tryParse(v);
          value = style != null && dateStyles.contains(style) && serial != null ? _serialDate(serial) : v;
        }
        cells.add(value);
      }
      if (cells.any((c) => c.trim().isNotEmpty)) rows.add(cells);
    }
    return rows;
  }

  static String? _utf8(Archive zip, String name) {
    final f = zip.findFile(name);
    if (f == null) return null;
    try {
      return const Utf8Decoder().convert(f.content);
    } catch (_) {
      return null;
    }
  }

  /// The first sheet in the workbook's order.
  static String? _firstSheet(Archive zip) {
    final workbook = _utf8(zip, 'xl/workbook.xml');
    final rels = _utf8(zip, 'xl/_rels/workbook.xml.rels');
    if (workbook == null || rels == null) return null;
    final first = XmlDocument.parse(workbook).findAllElements('sheet').firstOrNull;
    final id = first?.getAttribute('r:id') ?? first?.attributes.where((a) => a.name.local == 'id').firstOrNull?.value;
    if (id == null) return null;
    for (final r in XmlDocument.parse(rels).findAllElements('Relationship')) {
      if (r.getAttribute('Id') == id) {
        final target = r.getAttribute('Target') ?? '';
        return target.startsWith('/') ? target.substring(1) : 'xl/$target';
      }
    }
    return null;
  }

  /// Style indexes whose number format is a date.
  static Set<int> _dateStyles(String? styles) {
    if (styles == null) return const {};
    final doc = XmlDocument.parse(styles);
    final custom = <int>{};
    for (final f in doc.findAllElements('numFmt')) {
      final id = int.tryParse(f.getAttribute('numFmtId') ?? '');
      final code = (f.getAttribute('formatCode') ?? '').toLowerCase().replaceAll(RegExp(r'"[^"]*"|\[[^\]]*\]'), '');
      if (id != null && RegExp('[dy]').hasMatch(code)) custom.add(id);
    }
    bool isDate(int id) => (id >= 14 && id <= 22) || (id >= 45 && id <= 47) || custom.contains(id);
    final out = <int>{};
    final xfs = doc.findAllElements('cellXfs').firstOrNull?.findElements('xf').toList() ?? const [];
    for (var i = 0; i < xfs.length; i++) {
      final id = int.tryParse(xfs[i].getAttribute('numFmtId') ?? '');
      if (id != null && isDate(id)) out.add(i);
    }
    return out;
  }

  static int _column(String ref) {
    var n = 0;
    for (final ch in ref.codeUnits) {
      if (ch < 65 || ch > 90) break;
      n = n * 26 + (ch - 64);
    }
    return n - 1;
  }

  static String _serialDate(double serial) {
    final d = DateTime.utc(1899, 12, 30).add(Duration(days: serial.floor()));
    String two(int v) => v.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)}';
  }
}
