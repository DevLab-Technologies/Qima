import 'package:equatable/equatable.dart';

/// Per-device evaluation state for a single [PriceAlert], persisted locally
/// in `alerts.state.json` (spec Phase 5) — deliberately NOT part of
/// [PriceAlert] and NOT synced: whether an alert has recently fired, and
/// what price it last saw, is meaningful only to the device that observed
/// it. Syncing this would let firing on one device silently suppress the
/// notification on another.
class AlertRuntimeState extends Equatable {
  final String alertID;

  /// The price (in the alert's card's own currency/unit/karat) observed the
  /// last time this alert was evaluated. Null before the first evaluation —
  /// [AlertEvaluator] deliberately never fires on that first observation,
  /// since there's no crossing to detect yet.
  final double? lastSeenPrice;

  /// When this alert last fired a notification, if ever.
  final DateTime? lastFiredAt;

  /// Whether the alert is currently eligible to fire. A repeat alert that
  /// just fired goes un-armed until the condition becomes false again (so it
  /// doesn't re-fire on every subsequent refresh while still past the
  /// target), then re-arms.
  final bool armed;

  const AlertRuntimeState({
    required this.alertID,
    this.lastSeenPrice,
    this.lastFiredAt,
    this.armed = true,
  });

  AlertRuntimeState copyWith({
    double? lastSeenPrice,
    bool clearLastSeenPrice = false,
    DateTime? lastFiredAt,
    bool? armed,
  }) {
    return AlertRuntimeState(
      alertID: alertID,
      lastSeenPrice: clearLastSeenPrice ? null : (lastSeenPrice ?? this.lastSeenPrice),
      lastFiredAt: lastFiredAt ?? this.lastFiredAt,
      armed: armed ?? this.armed,
    );
  }

  Map<String, dynamic> toJson() => {
        'alertID': alertID,
        'lastSeenPrice': lastSeenPrice,
        'lastFiredAt': lastFiredAt?.toUtc().toIso8601String(),
        'armed': armed,
      };

  factory AlertRuntimeState.fromJson(Map<String, dynamic> json) => AlertRuntimeState(
        alertID: json['alertID'] as String,
        lastSeenPrice: (json['lastSeenPrice'] as num?)?.toDouble(),
        lastFiredAt: json['lastFiredAt'] == null ? null : DateTime.parse(json['lastFiredAt'] as String),
        armed: json['armed'] as bool? ?? true,
      );

  @override
  List<Object?> get props => [alertID, lastSeenPrice, lastFiredAt, armed];
}
