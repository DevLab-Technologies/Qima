import 'package:equatable/equatable.dart';

/// A single (date, value) sample already converted into display
/// currency/unit/karat terms — the output of [PriceConverter.points].
class DisplayPoint extends Equatable {
  /// Device-local, whatever [date] was given in: history bars and stored
  /// quotes come back in UTC, and every axis label, scrub callout and
  /// spoken description formats this field as it is.
  final DateTime date;
  final double value;

  DisplayPoint({required DateTime date, required this.value}) : date = date.toLocal();

  @override
  List<Object?> get props => [date, value];
}
