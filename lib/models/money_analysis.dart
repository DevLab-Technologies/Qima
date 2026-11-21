import 'book.dart';
import 'book_account.dart';
import 'minor_units.dart';
import 'money.dart';

/// One month of Money: spending by category, income, the budget and where
/// the month is heading. Arithmetic on the person's own ledger only; it
/// describes what happened and never advises.
class MonthAnalysis {
  /// First day of the month.
  final DateTime month;
  final String currency;

  /// Spending per category id, in [currency], largest first.
  final List<(String, double)> byCategory;
  final double spent;
  final double income;

  /// Monthly budget per category id, in [currency].
  final Map<String, double> budgets;

  /// Planned payments in budgeted categories still to come this month, in
  /// [currency]: money the budget has already promised. Zero for any other
  /// month.
  final double planned;

  /// Currencies with no exchange rate to [currency]: their amounts are
  /// left out of every figure here, so the figures are incomplete.
  final Set<String> missingRates;

  const MonthAnalysis({
    required this.month,
    required this.currency,
    required this.byCategory,
    required this.spent,
    required this.income,
    required this.budgets,
    this.planned = 0,
    this.missingRates = const {},
  });

  DateTime get end => DateTime(month.year, month.month + 1);
  // Calendar arithmetic, not a Duration: a month with a DST change isn't a
  // whole number of 24-hour days.
  int get daysInMonth => DateTime(month.year, month.month + 1, 0).day;

  double get budget => budgets.values.fold(0.0, (a, b) => a + b);
  bool get hasBudget => budgets.isNotEmpty;
  /// The budget minus what is spent and what planned payments will still
  /// spend: the one definition every screen shows.
  double get leftToSpend => budget - spent - planned;

  /// Every figure counts every amount.
  bool get complete => missingRates.isEmpty;
  double get net => income - spent;

  double spentIn(String categoryId) => byCategory.where((c) => c.$1 == categoryId).fold(0.0, (a, c) => a + c.$2);

  /// Days of the month gone by on [today] (all of them for a past month).
  int elapsedDays(DateTime today) {
    if (!today.isBefore(end)) return daysInMonth;
    if (today.isBefore(month)) return 0;
    return today.day;
  }

  /// Spending by the month's end at the pace so far, or null before the
  /// month has started.
  double? projected(DateTime today) {
    final d = elapsedDays(today);
    if (d == 0) return null;
    return spent / d * daysInMonth;
  }

  /// Categories whose spending so far is ahead of their budget's pace,
  /// most over first: (category, spent, budget).
  List<(String, double, double)> aheadOfPace(DateTime today) {
    final share = elapsedDays(today) / daysInMonth;
    final out = <(String, double, double)>[];
    budgets.forEach((id, b) {
      final s = spentIn(id);
      if (b > 0 && s > b * share && s > 0) out.add((id, s, b));
    });
    out.sort((a, b) => (b.$2 / b.$3).compareTo(a.$2 / a.$3));
    return out;
  }

  /// Budget lines with money to spare at the month's pace, most spare
  /// first: (category, spare).
  List<(String, double)> spare(DateTime today) {
    final share = elapsedDays(today) / daysInMonth;
    final out = <(String, double)>[];
    budgets.forEach((id, b) {
      final s = spentIn(id);
      final atPace = b * share;
      if (b > 0 && s < atPace) out.add((id, b - (share == 0 ? 0 : s / share)));
    });
    out.removeWhere((e) => e.$2 <= 0);
    out.sort((a, b) => b.$2.compareTo(a.$2));
    return out;
  }

  static double _convert(Amounts amounts, String currency, FXRates rates, [Set<String>? missing]) {
    var total = 0.0;
    amounts.forEach((c, v) {
      final major = MinorUnits.toMajor(v, c);
      if (c == currency) {
        total += major;
        return;
      }
      final from = rates.rate(c), to = rates.rate(currency);
      // A currency with no rate is left out rather than counted at 1:1.
      if (from != null && to != null) {
        total += major / from * to;
      } else if (major != 0) {
        missing?.add(c);
      }
    });
    return total;
  }

  /// [planned] is each planned payment still to come this month as
  /// (category id, amount, currency); only those in a budgeted category
  /// count.
  static MonthAnalysis of(
    Book book,
    DateTime anyDay, {
    required String currency,
    required FXRates rates,
    Map<String, int> budgets = const {},
    String? budgetCurrency,
    List<(String categoryId, int amount, String currency)> planned = const [],
  }) {
    final month = DateTime(anyDay.year, anyDay.month);
    final missing = <String>{};
    final to = DateTime(month.year, month.month + 1).subtract(const Duration(microseconds: 1));
    final byCategory = <(String, double)>[];
    for (final a in book.accounts.values) {
      if (a.side != AccountSide.spending) continue;
      final amounts = book.spending(from: month, to: to, categories: {a.id});
      if (amounts.isEmpty) continue;
      final v = _convert(amounts, currency, rates, missing);
      if (v != 0) byCategory.add((a.id, v));
    }
    byCategory.sort((a, b) => b.$2.compareTo(a.$2));
    final bc = budgetCurrency ?? currency;
    final promised = <String, int>{};
    for (final (id, amount, ccy) in planned) {
      if (budgets.containsKey(id)) promised[ccy] = (promised[ccy] ?? 0) + amount;
    }
    return MonthAnalysis(
      month: month,
      currency: currency,
      byCategory: byCategory,
      spent: byCategory.fold(0.0, (a, c) => a + c.$2),
      income: _convert(book.income(from: month, to: to), currency, rates, missing),
      budgets: {for (final e in budgets.entries) e.key: _convert({bc: e.value}, currency, rates, missing)},
      planned: _convert(promised, currency, rates, missing),
      missingRates: missing,
    );
  }

  /// Spending for each of the [count] months ending with [anyDay]'s,
  /// oldest first.
  static List<(DateTime, double)> trend(Book book, DateTime anyDay, {required String currency, required FXRates rates, int count = 6}) => [
        for (var i = count - 1; i >= 0; i--)
          () {
            final m = DateTime(anyDay.year, anyDay.month - i);
            final to = DateTime(m.year, m.month + 1).subtract(const Duration(microseconds: 1));
            return (m, _convert(book.spending(from: m, to: to), currency, rates));
          }(),
      ];
}
