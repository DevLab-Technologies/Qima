import 'package:flutter_test/flutter_test.dart';
import 'package:qima/models/display_point.dart';
import 'package:qima/models/price_alert.dart';
import 'package:qima/services/alert_evaluator.dart';

void main() {
  const evaluator = AlertEvaluator();
  final now = DateTime(2024, 6, 15, 12);

  PriceAlert above({
    double target = 2000,
    bool repeats = false,
    bool enabled = true,
  }) =>
      PriceAlert(
        id: 'a1',
        cardID: 'card1',
        kind: AlertKind.above,
        target: target,
        repeats: repeats,
        enabled: enabled,
        createdAt: now,
      );

  PriceAlert below({double target = 2000, bool repeats = false}) => PriceAlert(
        id: 'a2',
        cardID: 'card1',
        kind: AlertKind.below,
        target: target,
        repeats: repeats,
        createdAt: now,
      );

  PriceAlert percentMove({
    double percent = 0.05,
    AlertDirection direction = AlertDirection.either,
    AlertWindow window = AlertWindow.h24,
    bool repeats = false,
  }) =>
      PriceAlert(
        id: 'a3',
        cardID: 'card1',
        kind: AlertKind.percentMove,
        percent: percent,
        direction: direction,
        window: window,
        repeats: repeats,
        createdAt: now,
      );

  group('above/below crossing (TC: first observation never fires)', () {
    test('first evaluation with no lastSeenPrice never fires, only records baseline', () {
      final result = evaluator.evaluate(
        alert: above(target: 2000),
        currentPrice: 2500, // already past target
        lastSeenPrice: null,
        armed: true,
        now: now,
      );
      expect(result.fired, isFalse);
      expect(result.newLastSeenPrice, 2500);
    });

    test('above fires on crossing from below to at/above target', () {
      final result = evaluator.evaluate(
        alert: above(target: 2000),
        currentPrice: 2001,
        lastSeenPrice: 1999,
        armed: true,
        now: now,
      );
      expect(result.fired, isTrue);
      expect(result.fire!.kind, AlertKind.above);
    });

    test('above does not fire when price stays above target across refreshes', () {
      final result = evaluator.evaluate(
        alert: above(target: 2000),
        currentPrice: 2100,
        lastSeenPrice: 2050,
        armed: true,
        now: now,
      );
      expect(result.fired, isFalse);
    });

    test('below fires on crossing from above to at/below target', () {
      final result = evaluator.evaluate(
        alert: below(target: 2000),
        currentPrice: 1999,
        lastSeenPrice: 2001,
        armed: true,
        now: now,
      );
      expect(result.fired, isTrue);
      expect(result.fire!.kind, AlertKind.below);
    });

    test('a gap between refreshes that jumps clean over the target still fires', () {
      // lastSeen well below target, current price well above it — no
      // intermediate refresh ever observed the exact crossing point, but the
      // before/after states are still on opposite sides.
      final result = evaluator.evaluate(
        alert: above(target: 2000),
        currentPrice: 2500,
        lastSeenPrice: 1000,
        armed: true,
        now: now,
      );
      expect(result.fired, isTrue);
    });

    test('one-off alert disables itself after firing', () {
      final result = evaluator.evaluate(
        alert: above(target: 2000, repeats: false),
        currentPrice: 2001,
        lastSeenPrice: 1999,
        armed: true,
        now: now,
      );
      expect(result.fired, isTrue);
      expect(result.disableAlert, isTrue);
      expect(result.newArmed, isFalse);
    });

    test('repeat alert re-arms once the condition becomes false again, then fires on the next crossing', () {
      final alert = above(target: 2000, repeats: true);

      // First crossing: fires, un-arms.
      final first = evaluator.evaluate(
        alert: alert,
        currentPrice: 2001,
        lastSeenPrice: 1999,
        armed: true,
        now: now,
      );
      expect(first.fired, isTrue);
      expect(first.disableAlert, isFalse);
      expect(first.newArmed, isFalse);

      // Still above target on the next refresh: must not re-fire while un-armed.
      final second = evaluator.evaluate(
        alert: alert,
        currentPrice: 2010,
        lastSeenPrice: first.newLastSeenPrice,
        armed: first.newArmed,
        now: now,
      );
      expect(second.fired, isFalse);
      expect(second.newArmed, isFalse);

      // Price falls back under target: re-arms (still doesn't fire, since
      // "below" isn't this alert's condition).
      final third = evaluator.evaluate(
        alert: alert,
        currentPrice: 1500,
        lastSeenPrice: second.newLastSeenPrice,
        armed: second.newArmed,
        now: now,
      );
      expect(third.fired, isFalse);
      expect(third.newArmed, isTrue);

      // Crosses above again: fires again now that it's re-armed.
      final fourth = evaluator.evaluate(
        alert: alert,
        currentPrice: 2001,
        lastSeenPrice: third.newLastSeenPrice,
        armed: third.newArmed,
        now: now,
      );
      expect(fourth.fired, isTrue);
    });

    test('disabled alert never fires regardless of price movement', () {
      final result = evaluator.evaluate(
        alert: above(target: 2000, enabled: false),
        currentPrice: 2500,
        lastSeenPrice: 1000,
        armed: true,
        now: now,
      );
      expect(result.fired, isFalse);
    });
  });

  group('percentMove (TC: window-based, both directions)', () {
    List<DisplayPoint> points(List<(DateTime, double)> samples) =>
        [for (final s in samples) DisplayPoint(date: s.$1, value: s.$2)];

    test('fires on an upward move meeting the threshold within the window, direction up', () {
      final windowStart = now.subtract(const Duration(hours: 24));
      final series = points([(windowStart, 1000), (now, 1060)]); // +6%
      final result = evaluator.evaluate(
        alert: percentMove(percent: 0.05, direction: AlertDirection.up),
        currentPrice: 1060,
        lastSeenPrice: null,
        armed: true,
        now: now,
        pointsForWindow: () => series,
      );
      expect(result.fired, isTrue);
      expect(result.fire!.percentChange, closeTo(0.06, 1e-9));
    });

    test('does not fire on an upward move when direction filter is down', () {
      final windowStart = now.subtract(const Duration(hours: 24));
      final series = points([(windowStart, 1000), (now, 1060)]);
      final result = evaluator.evaluate(
        alert: percentMove(percent: 0.05, direction: AlertDirection.down),
        currentPrice: 1060,
        lastSeenPrice: null,
        armed: true,
        now: now,
        pointsForWindow: () => series,
      );
      expect(result.fired, isFalse);
    });

    test('fires on a downward move meeting the threshold, direction down', () {
      final windowStart = now.subtract(const Duration(hours: 24));
      final series = points([(windowStart, 1000), (now, 940)]); // -6%
      final result = evaluator.evaluate(
        alert: percentMove(percent: 0.05, direction: AlertDirection.down),
        currentPrice: 940,
        lastSeenPrice: null,
        armed: true,
        now: now,
        pointsForWindow: () => series,
      );
      expect(result.fired, isTrue);
      expect(result.fire!.percentChange, closeTo(-0.06, 1e-9));
    });

    test('direction either fires on either an up or down move', () {
      final windowStart = now.subtract(const Duration(days: 7));
      final downSeries = points([(windowStart, 1000), (now, 940)]);
      final downResult = evaluator.evaluate(
        alert: percentMove(percent: 0.05, direction: AlertDirection.either, window: AlertWindow.d7),
        currentPrice: 940,
        lastSeenPrice: null,
        armed: true,
        now: now,
        pointsForWindow: () => downSeries,
      );
      expect(downResult.fired, isTrue);

      final upSeries = points([(windowStart, 1000), (now, 1060)]);
      final upResult = evaluator.evaluate(
        alert: percentMove(percent: 0.05, direction: AlertDirection.either, window: AlertWindow.d7),
        currentPrice: 1060,
        lastSeenPrice: null,
        armed: true,
        now: now,
        pointsForWindow: () => upSeries,
      );
      expect(upResult.fired, isTrue);
    });

    test('does not fire when the move is under the threshold', () {
      final windowStart = now.subtract(const Duration(hours: 24));
      final series = points([(windowStart, 1000), (now, 1020)]); // +2%
      final result = evaluator.evaluate(
        alert: percentMove(percent: 0.05),
        currentPrice: 1020,
        lastSeenPrice: null,
        armed: true,
        now: now,
        pointsForWindow: () => series,
      );
      expect(result.fired, isFalse);
    });

    test('one-off percentMove alert disables itself after firing', () {
      final windowStart = now.subtract(const Duration(hours: 24));
      final series = points([(windowStart, 1000), (now, 1060)]);
      final result = evaluator.evaluate(
        alert: percentMove(percent: 0.05, repeats: false),
        currentPrice: 1060,
        lastSeenPrice: null,
        armed: true,
        now: now,
        pointsForWindow: () => series,
      );
      expect(result.disableAlert, isTrue);
    });

    test('repeat percentMove alert re-arms once the move rolls back under the threshold', () {
      final alert = percentMove(percent: 0.05, repeats: true);
      final windowStart = now.subtract(const Duration(hours: 24));

      final firedSeries = points([(windowStart, 1000), (now, 1060)]);
      final first = evaluator.evaluate(
        alert: alert,
        currentPrice: 1060,
        lastSeenPrice: null,
        armed: true,
        now: now,
        pointsForWindow: () => firedSeries,
      );
      expect(first.fired, isTrue);
      expect(first.newArmed, isFalse);

      // Same magnitude of move still in the window: must not re-fire while un-armed.
      final second = evaluator.evaluate(
        alert: alert,
        currentPrice: 1060,
        lastSeenPrice: first.newLastSeenPrice,
        armed: first.newArmed,
        now: now,
        pointsForWindow: () => firedSeries,
      );
      expect(second.fired, isFalse);

      // Move has rolled out of the window (back near baseline): re-arms.
      final settledSeries = points([(windowStart, 1000), (now, 1005)]);
      final third = evaluator.evaluate(
        alert: alert,
        currentPrice: 1005,
        lastSeenPrice: second.newLastSeenPrice,
        armed: second.newArmed,
        now: now,
        pointsForWindow: () => settledSeries,
      );
      expect(third.fired, isFalse);
      expect(third.newArmed, isTrue);
    });

    test('no history in the window neither fires nor crashes', () {
      final result = evaluator.evaluate(
        alert: percentMove(percent: 0.05),
        currentPrice: 1060,
        lastSeenPrice: null,
        armed: true,
        now: now,
        pointsForWindow: () => const [],
      );
      expect(result.fired, isFalse);
    });
  });

  group('conversion (TC: gram + 21K karat + non-USD currency)', () {
    // AlertEvaluator itself is unit/currency-agnostic — it only ever sees
    // ALREADY-CONVERTED prices (the caller does gram/karat/currency
    // conversion via PriceConverter before calling evaluate). This proves
    // the evaluator's crossing logic is correct against a realistic
    // converted magnitude (21K gold, grams, EGP), not just round USD/oz
    // numbers, so a conversion bug elsewhere can't hide behind an evaluator
    // that only exercises "nice" numbers.
    test('crossing fires correctly against small-magnitude converted values', () {
      // A plausible 21K gold gram price in EGP: ~4,200.
      final result = evaluator.evaluate(
        alert: above(target: 4200.0),
        currentPrice: 4200.5,
        lastSeenPrice: 4199.9,
        armed: true,
        now: now,
      );
      expect(result.fired, isTrue);
    });
  });
}
