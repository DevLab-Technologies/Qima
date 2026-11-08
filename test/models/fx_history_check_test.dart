import 'package:flutter_test/flutter_test.dart';
import 'package:qima/models/fx_history.dart';
import 'package:qima/models/money.dart';

List<FXHistoryPoint> days(List<double> values) => [
      for (var i = 0; i < values.length; i++) FXHistoryPoint(date: DateTime.utc(2026, 6, 1 + i), perUSD: values[i]),
    ];

List<double> perUSD(FXHistory h, String code) => [for (final p in h.points(code)) p.perUSD];

void main() {
  final live = FXRates(base: 'USD', rates: const {'USD': 1, 'SAR': 3.75, 'EGP': 53.9, 'BHD': 0.376}, updatedAt: DateTime.utc(2026, 11, 8));

  test('a one-day jump away from neighbours that agree is dropped', () {
    final h = FXHistory(series: {'SAR': days([3.75, 3.75, 3.64, 3.75, 3.75])}).checkedAgainst(live);
    expect(perUSD(h, 'SAR'), [3.75, 3.75, 3.75, 3.75]);
  });

  test('a devaluation step and a steady slide are kept', () {
    final step = [30.9, 30.9, 30.9, 49.0, 49.5, 50.1, 53.9];
    final slide = [55.98, 55.32, 55.28, 54.70, 53.87];
    final live2 = FXRates(base: 'USD', rates: const {'USD': 1, 'EGP': 53.9}, updatedAt: DateTime.utc(2026, 11, 8));
    expect(perUSD(FXHistory(series: {'EGP': days(step)}).checkedAgainst(live2), 'EGP'), step);
    expect(perUSD(FXHistory(series: {'EGP': days(slide)}).checkedAgainst(live2), 'EGP'), slide);
  });

  test('a feed that has drifted from the live rate is not used at all', () {
    // Yahoo's SAR=X since June 2026: about 3.64 while the riyal is pegged at 3.75.
    final h = FXHistory(series: {'SAR': days([3.75, 3.75, 3.64, 3.64, 3.64, 3.75, 3.64, 3.64])}).checkedAgainst(live);
    expect(h.points('SAR'), isEmpty);
    expect(h.rate('SAR', DateTime.utc(2026, 6, 3)), isNull);
  });

  test('one bad last close is trimmed, and the rest of a good feed stays', () {
    final h = FXHistory(series: {'BHD': days([0.376, 0.3761, 0.376, 0.3759, 0.376, 0.3658])}).checkedAgainst(live);
    expect(perUSD(h, 'BHD'), [0.376, 0.3761, 0.376, 0.3759, 0.376]);
  });

  test('a currency with no live rate keeps its history, spikes aside', () {
    final h = FXHistory(series: {'XYZ': days([2.0, 2.0, 2.0])}).checkedAgainst(live);
    expect(perUSD(h, 'XYZ'), [2.0, 2.0, 2.0]);
  });
}
