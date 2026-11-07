import 'dart:convert';

import '../../models/statement_facts.dart';
import '../../models/statement_reader.dart';
import '../ai_assist_provider.dart';
import '../csv/csv_reader.dart';
import '../csv/xlsx_reader.dart';
import '../text_recognition_service.dart';
import 'import_inbox.dart';

/// What reading one file gave.
enum ReadOutcome { read, unsupported, unreadable }

/// One file, read: its rows and what it says about itself.
class StatementRead {
  final ReadOutcome outcome;
  final List<StatementRow> rows;
  final StatementFacts facts;

  const StatementRead(this.outcome, [this.rows = const [], this.facts = StatementFacts.none]);
}

/// Turns one inbox file into statement rows, whatever it is: a PDF (text or
/// scanned, tables included), a screenshot or photo, a CSV or Excel export,
/// or shared text such as a bank message.
class StatementFiles {
  static const images = {'png', 'jpg', 'jpeg', 'heic', 'heif', 'webp', 'tif', 'tiff', 'gif', 'bmp'};
  static const tables = {'csv', 'tsv', 'xlsx'};
  static const supported = {'pdf', 'txt', ...images, ...tables};

  final TextRecognitionService recognition;
  final ImportInbox inbox;

  /// The on-device model, when the person turned it on; it only labels
  /// lines the reader then checks.
  final AiAssistProvider Function() assist;

  const StatementFiles({required this.recognition, required this.inbox, this.assist = _noModel});

  static AiAssistProvider _noModel() => const NullAiAssistProvider();

  Future<StatementRead> read(ImportFile file, {required List<String> languages}) async {
    final reader = StatementReader(received: file.receivedAt);
    final ext = file.extension;
    if (!supported.contains(ext)) return const StatementRead(ReadOutcome.unsupported);
    try {
      if (ext == 'pdf' || images.contains(ext)) {
        final pages = await recognition.readDocument(file.path, languages);
        if (pages == null) return const StatementRead(ReadOutcome.unreadable);
        return _labelled(reader, file.path, pages, languages.first);
      }
      final bytes = await inbox.bytes(file);
      if (ext == 'xlsx') {
        final rows = XlsxReader.read(bytes);
        if (rows == null) return const StatementRead(ReadOutcome.unreadable);
        return _table(reader, [DocPage.fromTable(rows)]);
      }
      final text = utf8.decode(bytes, allowMalformed: true);
      final table = _tablePages(text);
      final asTable = table == null ? null : _table(reader, table);
      if (ext == 'txt' && (asTable == null || asTable.rows.isEmpty)) {
        // A shared message, unless it is really a table.
        final rows = reader.readMessages(text);
        return StatementRead(ReadOutcome.read, rows, reader.messageFacts(text, rows));
      }
      return asTable ?? const StatementRead(ReadOutcome.read);
    } catch (_) {
      return const StatementRead(ReadOutcome.unreadable);
    }
  }

  /// A CSV or Excel export: its columns are named, so no model is needed.
  StatementRead _table(StatementReader reader, List<DocPage> pages) {
    final (rows, facts) = reader.read(pages);
    return StatementRead(ReadOutcome.read, rows, facts);
  }

  /// A PDF or a picture, read by the rules and then, when the model is on,
  /// checked against what the model says: which words on each page make
  /// up each row (kept only when the numbers back it), then what each line
  /// is.
  Future<StatementRead> _labelled(StatementReader reader, String path, List<DocPage> pages, String localeTag) async {
    var (rows, facts) = reader.read(pages);
    final model = assist();
    if (await model.isAvailable()) {
      final structures = await model.structurePages(path, pages, localeTag);
      if (structures != null) (rows, facts) = reader.withStructure(pages, rows, facts, structures);
      final lines = reader.lineTexts(pages);
      final labels = await model.labelStatementLines(lines, localeTag);
      if (labels != null && labels.isNotEmpty) (rows, facts) = reader.withLabels(rows, facts, lines, labels);
    }
    return StatementRead(ReadOutcome.read, rows, facts);
  }

  List<DocPage>? _tablePages(String text) {
    final table = CsvReader.parse(text);
    if (table.rows.length < 2 || table.header.length < 2) return null;
    return [DocPage.fromTable(table.rows)];
  }
  /// The languages to read images in: the app's first.
  static List<String> languagesFor(String languageCode) => switch (languageCode) {
        'ar' => ['ar-SA', 'en-US'],
        'fr' => ['fr-FR', 'en-US', 'ar-SA'],
        'es' => ['es-ES', 'en-US', 'ar-SA'],
        _ => ['en-US', 'ar-SA'],
      };
}
