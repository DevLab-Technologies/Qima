import 'book.dart';
import 'chart_range.dart';
import 'display_point.dart';
import 'minor_units.dart';

/// One account's balance at the end of each day, as people read it (cash
/// held, a card's debt), in the account's own currency: the chart on an
/// account's page. Computed, never stored.
class AccountHistory {
  AccountHistory._();

  static List<DisplayPoint> build({required Book book, required String accountId, required ChartRange range, required DateTime now}) {
    final account = book.accounts[accountId];
    final currency = account?.currency;
    if (account == null || currency == null) return const [];
    final sign = account.side.shownSign;
    final entries = [
      for (final e in book.entries)
        if (e.counts && e.lines.any((l) => l.accountId == accountId)) e,
    ]..sort((a, b) => a.date.compareTo(b.date));
    if (entries.isEmpty) return const [];

    final today = _day(now);
    final first = _day(entries.first.date);
    var start = range == ChartRange.all ? first : _day(range.startDate(now) ?? today);
    // Before the first entry the account didn't exist: start there.
    if (start.isBefore(first)) start = first;
    if (start.isAfter(today)) start = today;

    var balance = 0, next = 0;
    final points = <DisplayPoint>[];
    for (var d = start; !d.isAfter(today); d = DateTime(d.year, d.month, d.day + 1)) {
      final endOfDay = DateTime(d.year, d.month, d.day + 1).subtract(const Duration(microseconds: 1));
      while (next < entries.length && !entries[next].date.isAfter(endOfDay)) {
        for (final l in entries[next].lines) {
          if (l.accountId == accountId && l.currency == currency) balance += l.amount * sign;
        }
        next++;
      }
      points.add(DisplayPoint(date: d, value: MinorUnits.toMajor(balance, currency)));
    }
    return points;
  }

  static DateTime _day(DateTime t) {
    final l = t.toLocal();
    return DateTime(l.year, l.month, l.day);
  }
}
