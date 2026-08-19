import 'package:equatable/equatable.dart';

/// A single (date, value) sample already converted into display
/// currency/unit/karat terms — the output of [PriceConverter.points].
class DisplayPoint extends Equatable {
  final DateTime date;
  final double value;

  const DisplayPoint({required this.date, required this.value});

  @override
  List<Object?> get props => [date, value];
}
