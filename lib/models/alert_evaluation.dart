import 'price_alert.dart';

/// The outcome of evaluating one [PriceAlert] against a fresh price, and the
/// runtime-state update that must be persisted regardless of whether it
/// fired (so the next evaluation has an up-to-date `lastSeenPrice`/`armed`).
class AlertEvaluation {
  final PriceAlert alert;

  /// Non-null only when the alert should fire right now.
  final AlertFireReason? fire;

  final double? newLastSeenPrice;
  final bool newArmed;

  /// Whether the alert definition itself should be persisted disabled (a
  /// one-off alert that just fired).
  final bool disableAlert;

  const AlertEvaluation({
    required this.alert,
    this.fire,
    required this.newLastSeenPrice,
    required this.newArmed,
    this.disableAlert = false,
  });

  bool get fired => fire != null;
}

/// Why an alert fired, carrying the values the notification text needs.
class AlertFireReason {
  final AlertKind kind;
  final double currentPrice;

  /// Percent change over the window, only set for [AlertKind.percentMove].
  final double? percentChange;

  const AlertFireReason({required this.kind, required this.currentPrice, this.percentChange});
}
