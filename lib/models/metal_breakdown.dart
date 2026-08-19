/// Gold karat purity levels supported by the catalog.
enum GoldKarat {
  k24(24),
  k22(22),
  k21(21),
  k18(18);

  final int rawValue;
  const GoldKarat(this.rawValue);

  double get purity => rawValue / 24.0;

  String get shortLabelKey => 'karat.short.$rawValue';

  static GoldKarat? fromRawValue(int value) {
    for (final k in GoldKarat.values) {
      if (k.rawValue == value) return k;
    }
    return null;
  }
}

/// A single row in the metal price breakdown card.
class MetalBreakdownRow {
  final String id;
  final String label;
  final String value;

  const MetalBreakdownRow({required this.id, required this.label, required this.value});
}
