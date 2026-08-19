import 'package:flutter_test/flutter_test.dart';
import 'package:qima/models/fx_history.dart';

void main() {
  group('FXHistory.rate fallbacks (spec §8.2 / TC-H3)', () {
    test('USD is always 1', () {
      expect(FXHistory.empty.rate('USD', DateTime(2024, 1, 1)), 1);
    });

    test('no history at all for a code returns null', () {
      expect(FXHistory.empty.rate('EUR', DateTime(2024, 1, 1)), isNull);
    });

    test('date before earliest sample falls back to earliest sample', () {
      final history = FXHistory(series: {
        'EUR': [
          FXHistoryPoint(date: DateTime(2024, 6, 1), perUSD: 0.9),
          FXHistoryPoint(date: DateTime(2024, 7, 1), perUSD: 0.95),
        ],
      });
      expect(history.rate('EUR', DateTime(2024, 1, 1)), 0.9);
    });

    test('date exactly on a sample uses that sample', () {
      final history = FXHistory(series: {
        'EUR': [
          FXHistoryPoint(date: DateTime(2024, 6, 1), perUSD: 0.9),
          FXHistoryPoint(date: DateTime(2024, 7, 1), perUSD: 0.95),
        ],
      });
      expect(history.rate('EUR', DateTime(2024, 7, 1)), 0.95);
    });

    test('date after last sample holds flat at the last sample', () {
      final history = FXHistory(series: {
        'EUR': [
          FXHistoryPoint(date: DateTime(2024, 6, 1), perUSD: 0.9),
          FXHistoryPoint(date: DateTime(2024, 7, 1), perUSD: 0.95),
        ],
      });
      expect(history.rate('EUR', DateTime(2024, 12, 1)), 0.95);
    });
  });

  group('FXHistory.merge UTC-day bucketing', () {
    test('new points win ties for the same UTC day', () {
      var history = FXHistory.empty;
      history = history.merge('EUR', [FXHistoryPoint(date: DateTime.utc(2024, 1, 1, 3), perUSD: 0.9)]);
      history = history.merge('EUR', [FXHistoryPoint(date: DateTime.utc(2024, 1, 1, 20), perUSD: 0.91)]);
      expect(history.points('EUR').length, 1);
      expect(history.points('EUR').first.perUSD, 0.91);
    });

    test('existing points from days absent in new data are kept', () {
      var history = FXHistory.empty;
      history = history.merge('EUR', [FXHistoryPoint(date: DateTime.utc(2024, 1, 1), perUSD: 0.9)]);
      history = history.merge('EUR', [FXHistoryPoint(date: DateTime.utc(2024, 1, 2), perUSD: 0.91)]);
      expect(history.points('EUR').length, 2);
    });
  });
}
