import '../models/money.dart';
import 'local_file_store.dart';

/// Latest-FX cache: `fx-rates.json`, mirrors `FXRateStore.swift`.
class FXRateStore {
  static const String _fileName = 'fx-rates.json';
  static const Duration maxAge = Duration(hours: 6);

  Future<FXRates?> load() async {
    final json = await LocalFileStore.readJson(_fileName);
    if (json == null) return null;
    try {
      return FXRates(
        base: json['base'] as String,
        rates: (json['rates'] as Map<String, dynamic>).map((k, v) => MapEntry(k, (v as num).toDouble())),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
    } catch (_) {
      return null;
    }
  }

  Future<bool> save(FXRates rates) {
    return LocalFileStore.writeJson(_fileName, {
      'base': rates.base,
      'rates': rates.rates,
      'updatedAt': rates.updatedAt.toUtc().toIso8601String(),
    });
  }

  bool isStale(FXRates rates, {DateTime? now}) {
    final current = now ?? DateTime.now();
    return current.difference(rates.updatedAt) > maxAge;
  }
}
