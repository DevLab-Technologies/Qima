import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/statement_facts.dart';
import '../models/statement_reader.dart';
import '../models/transaction_capture.dart';

/// The one seam between Qima's domain layer and an on-device language model
/// (v4), mirroring [QuoteProvider]: a null implementation by default, one
/// native implementation per platform, and a deterministic fallback for
/// every call. Nothing here may need a network.
///
/// A model may label or phrase language; it never produces a number. Every
/// figure the app shows comes from the ledger and `PriceConverter`.
/// How ready the on-device model is, for Settings.
enum ModelStatus {
  ready,

  /// The OS has no on-device model API, or this device can't run it.
  unsupported,

  /// Apple Intelligence is off in the system settings.
  turnedOff,

  /// The model is still downloading.
  notReady,

  /// The model can't work in the app's language.
  unsupportedLanguage,
}

abstract class AiAssistProvider {
  /// Whether a model is ready on this device right now. Models are
  /// hardware-gated and may still be downloading, so this can change between
  /// launches; callers check it per use rather than caching it.
  Future<bool> isAvailable();

  /// Why the model is or isn't ready for [localeTag], for Settings.
  Future<ModelStatus> status(String localeTag);

  /// Labels the parts of a free-text transaction ([text], written in
  /// [localeTag]) that the deterministic parser couldn't place. Returns null
  /// when the model can't help. See [CaptureSpans] for why it returns words
  /// rather than values.
  Future<CaptureSpans?> labelTransaction(String text, String localeTag);

  /// Rewords [sentence] (written in [localeTag]) to read more naturally.
  /// Returns null when the model can't help. Callers pass the result
  /// through [acceptPhrasing] before showing it.
  Future<String?> phrase(String sentence, String localeTag);

  /// Says what each of a document's [lines] is: a transaction (with the
  /// words naming who was paid), an opening or closing balance, the account
  /// number, or the bank's own text. Returns null when the model can't
  /// help. The reader checks every label against the line itself; see
  /// `StatementReader.withLabels`.
  Future<List<LineLabel>?> labelStatementLines(List<String> lines, String localeTag);

  /// Says, for each page of the document at [path], which of its words
  /// ([pages], numbered from 0 per page) are each transaction's date,
  /// amount, balance and direction, and which are the opening and closing
  /// balances, with each payee's name read off the picture. Returns null
  /// when the model can't help. It points at words and never writes a
  /// figure; see `StatementReader.withStructure`.
  Future<List<PageStructure>?> structurePages(String path, List<DocPage> pages, String localeTag);
}

/// Whether a model's [candidate] rewording of [original] can be shown: it
/// keeps exactly the numbers [original] has, adds none (rule 1), and gives
/// no advice or forecast (rule 2). Anything else falls back to [original].
bool acceptPhrasing(String original, String candidate) {
  final text = candidate.trim();
  if (text.isEmpty || text.length > original.length * 2 + 40) return false;
  List<String> numbers(String s) {
    final folded = String.fromCharCodes(s.runes.map((r) {
      if (r >= 0x0660 && r <= 0x0669) return 0x30 + r - 0x0660;
      if (r >= 0x06F0 && r <= 0x06F9) return 0x30 + r - 0x06F0;
      return r;
    }));
    return RegExp(r'\d+(?:[.,]\d+)*').allMatches(folded).map((m) => m[0]!.replaceAll(',', '')).toList()..sort();
  }

  if (!listEquals(numbers(original), numbers(text))) return false;
  // Masked amounts stay masked.
  if ('•'.allMatches(original).length != '•'.allMatches(text).length) return false;
  final lower = text.toLowerCase();
  const advice = [
    'should', 'recommend', 'advice', 'advise', 'forecast', 'predict', 'expect', 'likely', 'consider',
    'ينبغي', 'يجب', 'أنصح', 'انصح', 'ننصح', 'توصي', 'نتوقع', 'يتوقع', 'توقع',
    'deberías', 'recomiend', 'consej', 'previs', 'prevé', 'espera',
    'devriez', 'recommand', 'conseil', 'prévi', 'prévoi', 'attend',
  ];
  return !advice.any((word) => lower.contains(word) && !original.toLowerCase().contains(word));
}

/// [candidate] with each left-to-right isolated figure of [original] (an
/// amount, a signed amount, a percent) isolated again. Models drop these
/// invisible marks, and without them Arabic shows "$792.07+" for
/// "+$792.07". A figure the model reworded is left as it is.
String restoreIsolates(String original, String candidate) {
  var text = candidate.replaceAll(RegExp('[\u2066\u2069]'), '');
  var from = 0;
  for (final match in RegExp('\u2066(.*?)\u2069').allMatches(original)) {
    final figure = match[1]!;
    final at = figure.isEmpty ? -1 : text.indexOf(figure, from);
    if (at < 0) continue;
    text = '${text.substring(0, at)}\u2066$figure\u2069${text.substring(at + figure.length)}';
    from = at + figure.length + 2;
  }
  return text;
}

/// The default: no model. Every feature takes its deterministic path.
class NullAiAssistProvider implements AiAssistProvider {
  const NullAiAssistProvider();

  @override
  Future<bool> isAvailable() async => false;

  @override
  Future<ModelStatus> status(String localeTag) async => ModelStatus.unsupported;

  @override
  Future<CaptureSpans?> labelTransaction(String text, String localeTag) async => null;

  @override
  Future<String?> phrase(String sentence, String localeTag) async => null;

  @override
  Future<List<LineLabel>?> labelStatementLines(List<String> lines, String localeTag) async => null;

  @override
  Future<List<PageStructure>?> structurePages(String path, List<DocPage> pages, String localeTag) async => null;
}

/// The OS's own on-device model (v4 phase 6): Apple's Foundation Models on
/// iOS and macOS 26 and later, through `OnDeviceModelPlugin`. Never a
/// server model. Other platforms report [ModelStatus.unsupported].
class PlatformAiAssistProvider implements AiAssistProvider {
  const PlatformAiAssistProvider();

  static const _channel = MethodChannel('com.devlabtechnologies.qima/ai');

  @override
  Future<ModelStatus> status(String localeTag) async {
    if (kIsWeb) return ModelStatus.unsupported;
    try {
      final value = await _channel.invokeMethod<String>('availability', {'locale': localeTag});
      return ModelStatus.values.asNameMap()[value] ?? ModelStatus.unsupported;
    } on MissingPluginException {
      return ModelStatus.unsupported;
    } on PlatformException catch (e) {
      debugPrint('AiAssist: availability failed: $e');
      return ModelStatus.unsupported;
    }
  }

  @override
  Future<bool> isAvailable() async =>
      await status(PlatformDispatcher.instance.locale.toLanguageTag()) == ModelStatus.ready;

  @override
  Future<CaptureSpans?> labelTransaction(String text, String localeTag) async {
    try {
      final raw = await _channel.invokeMapMethod<String, String>('labelTransaction', {'text': text, 'locale': localeTag});
      if (raw == null) return null;
      String? span(String key) => (raw[key]?.trim().isEmpty ?? true) ? null : raw[key]!.trim();
      return CaptureSpans(
        kind: span('kind'),
        instrument: span('instrument'),
        quantity: span('quantity'),
        unit: span('unit'),
        karat: span('karat'),
        unitPrice: span('unitPrice'),
        total: span('total'),
        currency: span('currency'),
        date: span('date'),
      );
    } on MissingPluginException {
      return null;
    } on PlatformException catch (e) {
      debugPrint('AiAssist: labelTransaction failed: $e');
      return null;
    }
  }

  @override
  Future<String?> phrase(String sentence, String localeTag) async {
    try {
      return await _channel.invokeMethod<String>('phrase', {'sentence': sentence, 'locale': localeTag});
    } on MissingPluginException {
      return null;
    } on PlatformException catch (e) {
      debugPrint('AiAssist: phrase failed: $e');
      return null;
    }
  }

  @override
  Future<List<LineLabel>?> labelStatementLines(List<String> lines, String localeTag) async {
    if (lines.isEmpty) return null;
    try {
      final raw = await _channel.invokeListMethod<Object?>('labelStatementLines', {'lines': lines, 'locale': localeTag});
      if (raw == null) return null;
      return raw.whereType<Map<Object?, Object?>>().map(LineLabel.fromMap).nonNulls.toList();
    } on MissingPluginException {
      return null;
    } on PlatformException catch (e) {
      debugPrint('AiAssist: labelStatementLines failed: $e');
      return null;
    }
  }

  @override
  Future<List<PageStructure>?> structurePages(String path, List<DocPage> pages, String localeTag) async {
    if (pages.isEmpty) return null;
    try {
      final raw = await _channel.invokeListMethod<Object?>('structurePages', {
        'path': path,
        'locale': localeTag,
        'pages': [
          for (final p in pages) [for (final t in p.tokens) {'t': t.text, 'x': t.x, 'y': t.y, 'w': t.w, 'h': t.h}],
        ],
      });
      if (raw == null || raw.length != pages.length) return null;
      return [for (final p in raw) p is Map<Object?, Object?> ? PageStructure.fromMap(p) : const PageStructure()];
    } on MissingPluginException {
      return null;
    } on PlatformException catch (e) {
      debugPrint('AiAssist: structurePages failed: $e');
      return null;
    }
  }
}

/// Parses [text] deterministically, and only when that leaves the draft
/// without an instrument, a quantity or a price, asks [provider] to label
/// what's missing. Whatever the provider returns passes the same literal-span
/// checks and field parsers as typed input.
Future<TransactionDraft?> captureTransaction(
  String text,
  CaptureContext context, {
  required AiAssistProvider provider,
  required String localeTag,
}) async {
  final draft = TransactionCapture.parse(text, context);
  if (draft != null && draft.isComplete) return draft;
  if (!await provider.isAvailable()) return draft;
  final spans = await provider.labelTransaction(text, localeTag);
  if (spans == null) return draft;
  return TransactionCapture.parseWithSpans(text, spans, context) ?? draft;
}
