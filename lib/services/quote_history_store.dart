import '../models/quote.dart';
import 'local_file_store.dart';

/// One JSON file per instrument at `history/<instrumentID>.json`. Mirrors
/// `QuoteHistoryStore.swift`.
class QuoteHistoryStore {
  String _path(String instrumentID) => 'history/$instrumentID.json';

  Future<QuoteSeries> load(String instrumentID) async {
    final json = await LocalFileStore.readJson(_path(instrumentID));
    if (json == null) return QuoteSeries.empty(instrumentID);
    try {
      return QuoteSeries.fromJson(json);
    } catch (_) {
      return QuoteSeries.empty(instrumentID);
    }
  }

  Future<bool> save(QuoteSeries series) {
    return LocalFileStore.writeJson(_path(series.instrumentID), series.toJson());
  }

  /// Loads the existing series, appends [quote], saves, and returns the
  /// updated series.
  Future<QuoteSeries> record(Quote quote) async {
    final existing = await load(quote.instrumentID);
    final updated = existing.appending(quote);
    await save(updated);
    return updated;
  }
}
