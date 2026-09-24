import '../models/alert_evaluation.dart';
import '../models/display_point.dart';
import '../models/price_alert.dart';

/// Pure evaluation of [PriceAlert]s against display-currency prices — no I/O,
/// no notification side effects (spec Phase 5 "Evaluation"). Mirrors the
/// evaluation half of `refresh_pipeline.dart`'s job, kept separate and pure
/// so the crossing/percent-window logic is unit-testable without a fake
/// repository or notifier.
class AlertEvaluator {
  const AlertEvaluator();

  /// Evaluates one alert.
  ///
  /// [currentPrice] and [lastSeenPrice] are both already converted into the
  /// alert's card's own display currency/unit/karat (the caller is
  /// responsible for that conversion via `PriceConverter`, since this class
  /// has no I/O and no knowledge of FX).
  ///
  /// [pointsForWindow] supplies the already-converted display series for
  /// [AlertKind.percentMove] alerts (also in the card's own display terms) —
  /// only read when the alert kind needs it.
  AlertEvaluation evaluate({
    required PriceAlert alert,
    required double currentPrice,
    required double? lastSeenPrice,
    required bool armed,
    required DateTime now,
    List<DisplayPoint> Function()? pointsForWindow,
  }) {
    if (!alert.enabled) {
      return AlertEvaluation(alert: alert, newLastSeenPrice: currentPrice, newArmed: armed);
    }

    switch (alert.kind) {
      case AlertKind.above:
      case AlertKind.below:
        return _evaluateCrossing(alert, currentPrice, lastSeenPrice, armed);
      case AlertKind.percentMove:
        final points = pointsForWindow?.call() ?? const <DisplayPoint>[];
        return _evaluatePercentMove(alert, currentPrice, points, armed, now);
    }
  }

  /// Above/below fire on a CROSSING: the last-seen price and the current
  /// price must be on opposite sides of the target. The very first
  /// evaluation (no `lastSeenPrice` yet) never fires — it only records the
  /// baseline, since there's nothing to have "crossed" from (spec: "record
  /// lastSeen, don't fire").
  AlertEvaluation _evaluateCrossing(
    PriceAlert alert,
    double currentPrice,
    double? lastSeenPrice,
    bool armed,
  ) {
    if (lastSeenPrice == null) {
      return AlertEvaluation(alert: alert, newLastSeenPrice: currentPrice, newArmed: armed);
    }

    final isAbove = alert.kind == AlertKind.above;
    // "Past" the target in the direction this alert cares about.
    bool pastTarget(double price) => isAbove ? price >= alert.target : price <= alert.target;

    final wasPast = pastTarget(lastSeenPrice);
    final isPast = pastTarget(currentPrice);
    final crossed = !wasPast && isPast;

    if (crossed && armed) {
      final fire = AlertFireReason(kind: alert.kind, currentPrice: currentPrice);
      if (!alert.repeats) {
        return AlertEvaluation(
          alert: alert,
          fire: fire,
          newLastSeenPrice: currentPrice,
          newArmed: false,
          disableAlert: true,
        );
      }
      // Repeat alerts go un-armed immediately after firing, and only re-arm
      // once the price falls back off the target side (see the `armed`
      // recovery branch below) — otherwise every subsequent refresh that's
      // still past the target would re-fire.
      return AlertEvaluation(alert: alert, fire: fire, newLastSeenPrice: currentPrice, newArmed: false);
    }

    // Re-arm once the condition is false again (price back on the near side
    // of the target), so a repeat alert can fire on the NEXT crossing.
    final newArmed = armed || !isPast;
    return AlertEvaluation(alert: alert, newLastSeenPrice: currentPrice, newArmed: newArmed);
  }

  /// percentMove compares the current price with the price at `now - window`
  /// (read from the converted display series via [pointsForWindow]), filtered
  /// by [AlertDirection].
  AlertEvaluation _evaluatePercentMove(
    PriceAlert alert,
    double currentPrice,
    List<DisplayPoint> points,
    bool armed,
    DateTime now,
  ) {
    final windowStart = now.subtract(alert.window.duration);
    final basePrice = _priceAtOrBefore(points, windowStart);
    if (basePrice == null || basePrice == 0) {
      // Not enough history yet to evaluate a window move — nothing to
      // record either, since there's no comparable "last seen" concept here
      // (the window itself IS the baseline, recomputed every evaluation).
      return AlertEvaluation(alert: alert, newLastSeenPrice: currentPrice, newArmed: armed);
    }

    final change = (currentPrice - basePrice) / basePrice;
    final movedEnough = change.abs() >= alert.percent;
    final directionMatches = switch (alert.direction) {
      AlertDirection.up => change > 0,
      AlertDirection.down => change < 0,
      AlertDirection.either => true,
    };
    final conditionMet = movedEnough && directionMatches;

    if (conditionMet && armed) {
      final fire = AlertFireReason(kind: alert.kind, currentPrice: currentPrice, percentChange: change);
      if (!alert.repeats) {
        return AlertEvaluation(
          alert: alert,
          fire: fire,
          newLastSeenPrice: currentPrice,
          newArmed: false,
          disableAlert: true,
        );
      }
      return AlertEvaluation(alert: alert, fire: fire, newLastSeenPrice: currentPrice, newArmed: false);
    }

    // Re-arms once the move over the window drops back under the threshold
    // — i.e. after the fired move has rolled out of the lookback window (or
    // reversed), per spec: "percentMove: after one window".
    final newArmed = armed || !conditionMet;
    return AlertEvaluation(alert: alert, newLastSeenPrice: currentPrice, newArmed: newArmed);
  }

  /// Most recent sample at or before [target]; falls back to the earliest
  /// sample if every point is newer than [target] (short history), and null
  /// if there are no points at all.
  double? _priceAtOrBefore(List<DisplayPoint> points, DateTime target) {
    if (points.isEmpty) return null;
    double? candidate;
    for (final point in points) {
      if (point.date.isAfter(target)) break;
      candidate = point.value;
    }
    return candidate ?? points.first.value;
  }
}
