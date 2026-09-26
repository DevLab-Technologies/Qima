import 'package:equatable/equatable.dart';

import 'syncable.dart';

/// The condition kind an alert watches for.
enum AlertKind {
  above,
  below,
  percentMove;

  String get labelKey => 'alertKind.$name';
}

/// Direction filter for a [AlertKind.percentMove] alert.
enum AlertDirection {
  up,
  down,
  either;

  String get labelKey => 'alertDirection.$name';
}

/// Lookback window for a [AlertKind.percentMove] alert.
enum AlertWindow {
  h24,
  d7;

  Duration get duration => this == AlertWindow.h24 ? const Duration(hours: 24) : const Duration(days: 7);

  String get labelKey => 'alertWindow.$name';
}

/// A user-defined price alert on a single watchlist card's instrument, target
/// expressed in the card's own currency/unit/karat (spec Phase 5).
///
/// Syncable like other user collections (watchlist, holdings): the alert
/// DEFINITION syncs across devices via [AlertsStore]. Whether it has fired,
/// and when, is per-device runtime state — see `AlertRuntimeState` — which is
/// deliberately NOT part of this model or synced, so firing on one device
/// doesn't silently mute it on another.
class PriceAlert extends Equatable implements Syncable {
  @override
  final String id;
  final String cardID;
  final AlertKind kind;

  /// Threshold for [AlertKind.above]/[AlertKind.below], in the card's own
  /// display currency/unit/karat. Unused for [AlertKind.percentMove].
  final double target;

  /// Percent move threshold (e.g. 0.05 for 5%) for [AlertKind.percentMove].
  /// Unused for above/below.
  final double percent;
  final AlertDirection direction;
  final AlertWindow window;

  /// Whether this alert re-arms after firing (keeps watching) or turns
  /// itself off once it fires.
  final bool repeats;
  final bool enabled;
  final DateTime createdAt;

  const PriceAlert({
    required this.id,
    required this.cardID,
    required this.kind,
    this.target = 0,
    this.percent = 0,
    this.direction = AlertDirection.either,
    this.window = AlertWindow.h24,
    this.repeats = false,
    this.enabled = true,
    required this.createdAt,
  });

  PriceAlert copyWith({
    String? id,
    String? cardID,
    AlertKind? kind,
    double? target,
    double? percent,
    AlertDirection? direction,
    AlertWindow? window,
    bool? repeats,
    bool? enabled,
    DateTime? createdAt,
  }) {
    return PriceAlert(
      id: id ?? this.id,
      cardID: cardID ?? this.cardID,
      kind: kind ?? this.kind,
      target: target ?? this.target,
      percent: percent ?? this.percent,
      direction: direction ?? this.direction,
      window: window ?? this.window,
      repeats: repeats ?? this.repeats,
      enabled: enabled ?? this.enabled,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'cardID': cardID,
        'kind': kind.name,
        'target': target,
        'percent': percent,
        'direction': direction.name,
        'window': window.name,
        'repeats': repeats,
        'enabled': enabled,
        'createdAt': createdAt.toUtc().toIso8601String(),
      };

  factory PriceAlert.fromJson(Map<String, dynamic> json) => PriceAlert(
        id: json['id'] as String,
        cardID: json['cardID'] as String,
        kind: AlertKind.values.byName(json['kind'] as String),
        target: (json['target'] as num?)?.toDouble() ?? 0,
        percent: (json['percent'] as num?)?.toDouble() ?? 0,
        direction: AlertDirection.values.byName(json['direction'] as String? ?? AlertDirection.either.name),
        window: AlertWindow.values.byName(json['window'] as String? ?? AlertWindow.h24.name),
        repeats: json['repeats'] as bool? ?? false,
        enabled: json['enabled'] as bool? ?? true,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  @override
  List<Object?> get props => [id, cardID, kind, target, percent, direction, window, repeats, enabled, createdAt];
}
