import 'package:flutter_test/flutter_test.dart';
import 'package:qima/models/book.dart';
import 'package:qima/models/chart_range.dart';
import 'package:qima/models/fx_history.dart';
import 'package:qima/models/net_worth.dart';
import 'package:qima/models/net_worth_history.dart';
import 'package:qima/models/portfolio_history.dart';

import 'book_test.dart' show allAccounts, builder, cib, egp, groceries, land, rajhi, rates, sar, visa, dining;

void main() {
  final now = DateTime(2026, 11, 17, 15);
  DateTime ago(int days) => DateTime(2026, 11, 17 - days, 10);

  test('each day is what the accounts held that evening, owing subtracted, and the last day is today\'s net worth', () {
    final x = builder();
    final book = Book(allAccounts, [
      x.opening(rajhi, sar(10000), ago(10)),
      x.opening(visa, sar(2000), ago(10)),
      x.spend(rajhi, groceries, sar(500), ago(5)),
      x.spend(visa, dining, sar(300), ago(2)),
    ]);
    final points = NetWorthHistory.build(book: book, holdings: const [], currency: 'SAR', rates: rates, fxHistory: FXHistory.empty, range: ChartRange.all, now: now);
    expect(points.first.date, DateTime(2026, 11, 7));
    expect(points.first.value, 8000);
    expect(points[5].value, 7500);
    expect(points.last.date, DateTime(2026, 11, 17));
    expect(points.last.value, 7200);
    final today = NetWorthSummary.of(book: book, holdingsValue: 0, currency: 'SAR', rates: rates);
    expect(points.last.value, closeTo(today.netWorth, 0.001));
  });

  test('an asset keeps its last value until the next one; never a value in between', () {
    final x = builder();
    final book = Book(allAccounts, [
      x.opening(land, sar(200000), ago(20)),
      x.valuation(land, current: sar(200000), value: sar(240000), date: ago(10))!,
    ]);
    final points = NetWorthHistory.build(book: book, holdings: const [], currency: 'SAR', rates: rates, fxHistory: FXHistory.empty, range: ChartRange.month1, now: now);
    final byDay = {for (final p in points) p.date.day: p.value};
    expect(byDay[27], 0); // October 27: before the land was added (October 28)
    expect(byDay[1], 200000);
    expect(byDay[6], 200000);
    expect(byDay[7], 240000);
    expect(byDay[17], 240000);
  });

  test('holdings add their value for the day, other currencies convert, and a left-out account stays out', () {
    final x = builder();
    final book = Book([for (final a in allAccounts) a.id == 'rajhi' ? a.copyWith(countsInNetWorth: false) : a], [
      x.opening(rajhi, sar(99999), ago(3)),
      x.opening(cib, egp(1300), ago(3)),
    ]);
    final holdings = [for (var i = 3; i >= 0; i--) PortfolioHistoryPoint(date: DateTime(2026, 11, 17 - i), value: 1000.0 + i, cost: 900)];
    final points = NetWorthHistory.build(book: book, holdings: holdings, currency: 'SAR', rates: rates, fxHistory: FXHistory.empty, range: ChartRange.week1, now: now);
    expect(points.last.value, closeTo(1000 + 100, 0.001));
    expect(points.firstWhere((p) => p.date.day == 14).value, closeTo(1003 + 100, 0.001));
  });

  test('nothing recorded draws nothing', () {
    expect(NetWorthHistory.build(book: Book(allAccounts, const []), holdings: const [], currency: 'SAR', rates: rates, fxHistory: FXHistory.empty, range: ChartRange.all, now: now), isEmpty);
  });
}
