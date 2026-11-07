import 'book.dart';
import 'book_account.dart';
import 'chart_range.dart';
import 'display_point.dart';
import 'fx_history.dart';
import 'minor_units.dart';
import 'money.dart';
import 'portfolio_history.dart';

/// Net worth day by day, for the chart on Home: what the book's accounts
/// held at the end of each day (cash, cards, loans, people, and assets at
/// their latest dated value, never a value in between), converted at that
/// day's rate, plus the holdings at that day's prices.
///
/// Computed, never stored: one ascending walk over the book's entries.
class NetWorthHistory {
  NetWorthHistory._();

  /// [holdings] is [PortfolioHistory.build]'s series for the same [range],
  /// already in [currency]. Accounts left out of net worth stay out of
  /// every day. A currency with no rate on a day counts as nothing that
  /// day, as on the balance sheet.
  static List<DisplayPoint> build({
    required Book book,
    required List<PortfolioHistoryPoint> holdings,
    required String currency,
    required FXRates rates,
    required FXHistory fxHistory,
    required ChartRange range,
    required DateTime now,
  }) {
    final counted = <String, int>{}; // account id → +1 own, −1 owe (shown sign folded in)
    for (final a in book.accounts.values) {
      if (!a.side.onBalanceSheet || !a.countsInNetWorth) continue;
      counted[a.id] = (a.side == AccountSide.own ? 1 : -1) * a.side.shownSign;
    }
    final entries = [
      for (final e in book.entries)
        if (e.counts && e.lines.any((l) => counted.containsKey(l.accountId))) e,
    ]..sort((a, b) => a.date.compareTo(b.date));

    final today = _day(now);
    DateTime? first;
    if (entries.isNotEmpty) first = _day(entries.first.date);
    if (holdings.isNotEmpty && (first == null || holdings.first.date.isBefore(first))) first = _day(holdings.first.date);
    if (first == null) return const [];
    var start = range == ChartRange.all ? first : _day(range.startDate(now) ?? today);
    if (start.isBefore(first) && range == ChartRange.all) start = first;
    if (start.isAfter(today)) return const [];

    // Net minor units per currency, signed so own adds and owe subtracts.
    final net = <String, int>{};
    var next = 0;
    void postThrough(DateTime endOfDay) {
      while (next < entries.length && !entries[next].date.isAfter(endOfDay)) {
        for (final l in entries[next].lines) {
          final sign = counted[l.accountId];
          if (sign != null) net[l.currency] = (net[l.currency] ?? 0) + l.amount * sign;
        }
        next++;
      }
    }

    final held = {for (final p in holdings) _day(p.date): p.value};
    // Historic rates are per US dollar; live rates may be against another
    // base. A pair uses history only when both sides have it.
    final cursors = <String, _Rate>{};
    bool hasHistory(String ccy) => ccy == 'USD' || fxHistory.points(ccy).isNotEmpty;
    double? historic(String ccy, DateTime endOfDay) => ccy == 'USD' ? 1 : (cursors[ccy] ??= _Rate(fxHistory.points(ccy))).on(endOfDay);
    double? convert(double major, String ccy, DateTime endOfDay) {
      if (ccy == currency) return major;
      final (from, to) = hasHistory(ccy) && hasHistory(currency)
          ? (historic(ccy, endOfDay), historic(currency, endOfDay))
          : (rates.rate(ccy), rates.rate(currency));
      if (from == null || to == null || from <= 0) return null;
      return major / from * to;
    }

    final points = <DisplayPoint>[];
    for (var d = start; !d.isAfter(today); d = DateTime(d.year, d.month, d.day + 1)) {
      final endOfDay = DateTime(d.year, d.month, d.day + 1).subtract(const Duration(microseconds: 1));
      postThrough(endOfDay);
      var value = held[d] ?? 0.0;
      net.forEach((ccy, minor) {
        if (minor != 0) value += convert(MinorUnits.toMajor(minor, ccy), ccy, endOfDay) ?? 0;
      });
      points.add(DisplayPoint(date: d, value: value));
    }
    return points;
  }

  static DateTime _day(DateTime t) {
    final l = t.toLocal();
    return DateTime(l.year, l.month, l.day);
  }
}

/// A currency's per-USD rate on or before each day, walked forward.
class _Rate {
  final List<FXHistoryPoint> points;
  int _i = 0;
  double? _last;

  _Rate(this.points);

  double? on(DateTime t) {
    while (_i < points.length && !points[_i].date.isAfter(t)) {
      _last = points[_i].perUSD;
      _i++;
    }
    return _last ?? (points.isEmpty ? null : points.first.perUSD);
  }
}
