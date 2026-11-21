import 'package:flutter_test/flutter_test.dart';
import 'package:qima/models/account_history.dart';
import 'package:qima/models/book.dart';
import 'package:qima/models/chart_range.dart';
import 'package:qima/models/minor_units.dart';

import 'book_test.dart' show allAccounts, builder, dining, groceries, rajhi, sar, visa;

void main() {
  final now = DateTime(2026, 11, 17, 15);
  DateTime ago(int days) => DateTime(2026, 11, 17 - days, 10);

  test('a bank account day by day, ending at its balance, from its first day', () {
    final x = builder();
    final book = Book(allAccounts, [
      x.opening(rajhi, sar(10000), ago(10)),
      x.spend(rajhi, groceries, sar(500), ago(5)),
      x.spend(rajhi, dining, sar(200), ago(0)),
    ]);
    final points = AccountHistory.build(book: book, accountId: 'rajhi', range: ChartRange.month1, now: now);
    expect(points.first.date, DateTime(2026, 11, 7), reason: 'nothing before the account began');
    expect(points.first.value, 10000);
    expect(points.firstWhere((p) => p.date.day == 12).value, 9500);
    expect(points.last.value, MinorUnits.toMajor(book.balanceOf('rajhi'), 'SAR'));
    expect(points.last.value, 9300);
  });

  test('a card shows what is owed, rising as it is used', () {
    final x = builder();
    final book = Book(allAccounts, [
      x.opening(visa, sar(1000), ago(3)),
      x.spend(visa, dining, sar(300), ago(1)),
    ]);
    final points = AccountHistory.build(book: book, accountId: 'visa', range: ChartRange.week1, now: now);
    expect(points.first.value, 1000);
    expect(points.last.value, 1300);
  });

  test('an account with nothing in it draws nothing', () {
    expect(AccountHistory.build(book: Book(allAccounts, const []), accountId: 'rajhi', range: ChartRange.all, now: now), isEmpty);
  });
}
