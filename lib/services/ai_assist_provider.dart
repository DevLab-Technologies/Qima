import '../models/transaction_capture.dart';

/// The one seam between Qima's domain layer and an on-device language model
/// (v4), mirroring [QuoteProvider]: a null implementation by default, one
/// native implementation per platform, and a deterministic fallback for
/// every call. Nothing here may need a network.
///
/// A model may label or phrase language; it never produces a number. Every
/// figure the app shows comes from the ledger and `PriceConverter`.
abstract class AiAssistProvider {
  /// Whether a model is ready on this device right now. Models are
  /// hardware-gated and may still be downloading, so this can change between
  /// launches; callers check it per use rather than caching it.
  Future<bool> isAvailable();

  /// Labels the parts of a free-text transaction ([text], written in
  /// [localeTag]) that the deterministic parser couldn't place. Returns null
  /// when the model can't help. See [CaptureSpans] for why it returns words
  /// rather than values.
  Future<CaptureSpans?> labelTransaction(String text, String localeTag);
}

/// The default: no model. Every feature takes its deterministic path.
class NullAiAssistProvider implements AiAssistProvider {
  const NullAiAssistProvider();

  @override
  Future<bool> isAvailable() async => false;

  @override
  Future<CaptureSpans?> labelTransaction(String text, String localeTag) async => null;
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
