/// How a bill is divided between the person who paid it and the others.
enum SplitBy {
  /// Each other person's share is typed as an amount.
  amount,

  /// Everyone, the payer included, pays the same.
  equally,

  /// Each other person's share is a percentage of the total.
  percent,

  /// Each person, the payer included, has a number of shares.
  shares,
}

/// Each person's part of a bill, in minor units. A cent left over from
/// rounding goes to the payer, so the parts always add up to the total.
class BillSplit {
  BillSplit._();

  /// The payer's part and each other person's, or null when the values
  /// don't fit the total (more than all of it, or a share below zero).
  /// [values] are per other person: amounts in minor units for
  /// [SplitBy.amount], percentages, or share counts; ignored for
  /// [SplitBy.equally]. [myShares] is the payer's share count.
  static ({int mine, List<int> others})? divide(int total, SplitBy by, List<num> values, {num myShares = 1}) {
    if (total <= 0 || values.any((v) => v < 0)) return null;
    final List<int> others;
    switch (by) {
      case SplitBy.amount:
        others = [for (final v in values) v.round()];
      case SplitBy.equally:
        final each = total ~/ (values.length + 1);
        others = [for (final _ in values) each];
      case SplitBy.percent:
        if (values.fold<num>(0, (a, v) => a + v) > 100) return null;
        others = [for (final v in values) (total * v / 100).floor()];
      case SplitBy.shares:
        if (myShares < 0) return null;
        final all = values.fold<num>(myShares, (a, v) => a + v);
        if (all <= 0) return null;
        others = [for (final v in values) (total * v / all).floor()];
    }
    final mine = total - others.fold<int>(0, (a, v) => a + v);
    if (mine < 0) return null;
    return (mine: mine, others: others);
  }
}
