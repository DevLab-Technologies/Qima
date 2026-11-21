import 'package:flutter_test/flutter_test.dart';
import 'package:qima/models/bill_split.dart';

/// The payer's part, then each other person's.
List<int>? parts(({int mine, List<int> others})? r) => r == null ? null : [r.mine, ...r.others];

void main() {
  test('equally: everyone the same, the cent left over is the payer\'s', () {
    expect(parts(BillSplit.divide(10000, SplitBy.equally, [0, 0])), [3334, 3333, 3333]);
  });

  test('by amount: what is left is the payer\'s, never below zero', () {
    expect(parts(BillSplit.divide(30000, SplitBy.amount, [12000, 5000])), [13000, 12000, 5000]);
    expect(BillSplit.divide(30000, SplitBy.amount, [20000, 15000]), isNull);
  });

  test('by percent: of the total, at most 100 together', () {
    expect(parts(BillSplit.divide(20000, SplitBy.percent, [25, 12.5])), [12500, 5000, 2500]);
    expect(BillSplit.divide(20000, SplitBy.percent, [60, 50]), isNull);
    expect(parts(BillSplit.divide(20000, SplitBy.percent, [100])), [0, 20000]);
  });

  test('by shares: the payer\'s shares count too', () {
    // Two shares for the payer (a couple), one each for two friends.
    expect(parts(BillSplit.divide(40000, SplitBy.shares, [1, 1], myShares: 2)), [20000, 10000, 10000]);
    expect(parts(BillSplit.divide(10000, SplitBy.shares, [1, 1], myShares: 1)), [3334, 3333, 3333]);
    expect(parts(BillSplit.divide(10000, SplitBy.shares, [1], myShares: 0)), [0, 10000]);
    expect(BillSplit.divide(10000, SplitBy.shares, [0], myShares: 0), isNull);
  });

  test('a share below zero, or no total, is refused', () {
    expect(BillSplit.divide(10000, SplitBy.amount, [-1]), isNull);
    expect(BillSplit.divide(0, SplitBy.equally, [0]), isNull);
  });
}
