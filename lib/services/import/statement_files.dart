import 'dart:convert';

import '../../models/statement_reader.dart';
import '../csv/csv_reader.dart';
import '../csv/xlsx_reader.dart';
import '../text_recognition_service.dart';
import 'import_inbox.dart';

/// What reading one file gave.
enum ReadOutcome { read, unsupported, unreadable }

/// Turns one inbox file into statement rows, whatever it is: a PDF (text or
/// scanned, tables included), a screenshot or photo, a CSV or Excel export,
/// or shared text such as a bank message.
class StatementFiles {
  static const images = {'png', 'jpg', 'jpeg', 'heic', 'heif', 'webp', 'tif', 'tiff', 'gif', 'bmp'};
  static const tables = {'csv', 'tsv', 'xlsx'};
  static const supported = {'pdf', 'txt', ...images, ...tables};

  final TextRecognitionService recognition;
  final ImportInbox inbox;

  const StatementFiles({required this.recognition, required this.inbox});

  Future<(ReadOutcome, List<StatementRow>)> read(ImportFile file, {required List<String> languages}) async {
    final reader = StatementReader(received: file.receivedAt);
    final ext = file.extension;
    if (!supported.contains(ext)) return (ReadOutcome.unsupported, const <StatementRow>[]);
    try {
      if (ext == 'pdf' || images.contains(ext)) {
        final pages = await recognition.readDocument(file.path, languages);
        if (pages == null) return (ReadOutcome.unreadable, const <StatementRow>[]);
        return (ReadOutcome.read, reader.readPages(pages));
      }
      final bytes = await inbox.bytes(file);
      if (ext == 'xlsx') {
        final rows = XlsxReader.read(bytes);
        if (rows == null) return (ReadOutcome.unreadable, const <StatementRow>[]);
        return (ReadOutcome.read, reader.readPages([DocPage.fromTable(rows)]));
      }
      final text = utf8.decode(bytes, allowMalformed: true);
      if (ext == 'txt') {
        // A shared message, unless it is really a table.
        final asTable = _tableRows(reader, text);
        return (ReadOutcome.read, asTable.isNotEmpty ? asTable : reader.readMessages(text));
      }
      return (ReadOutcome.read, _tableRows(reader, text));
    } catch (_) {
      return (ReadOutcome.unreadable, const <StatementRow>[]);
    }
  }

  List<StatementRow> _tableRows(StatementReader reader, String text) {
    final table = CsvReader.parse(text);
    if (table.rows.length < 2 || table.header.length < 2) return const [];
    return reader.readPages([DocPage.fromTable(table.rows)]);
  }

  /// The languages to read images in: the app's first.
  static List<String> languagesFor(String languageCode) => switch (languageCode) {
        'ar' => ['ar-SA', 'en-US'],
        'fr' => ['fr-FR', 'en-US', 'ar-SA'],
        'es' => ['es-ES', 'en-US', 'ar-SA'],
        _ => ['en-US', 'ar-SA'],
      };
}
