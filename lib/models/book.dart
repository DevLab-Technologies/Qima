import 'book_account.dart';
import 'book_entry.dart';
import 'minor_units.dart';
import 'money.dart';

/// Amounts in minor units, one per currency, kept apart until they are
/// shown: converting early would freeze one day's rate into a total.
typedef Amounts = Map<String, int>;

/// The books: accounts and the entries posted to them. Every figure the
/// money screens show is derived here; nothing is stored twice.
///
/// - Net worth is what you own minus what you owe.
/// - Spending is the total of lines on spending accounts.
/// - Because every entry balances, net worth always equals opening balances
///   plus changes in value plus income minus spending.
class Book {
  final Map<String, BookAccount> accounts;
  final List<BookEntry> entries;

  Book(Iterable<BookAccount> accounts, Iterable<BookEntry> entries)
      : accounts = {
          for (final s in SystemAccount.values) s.id: s.account,
          for (final a in accounts) a.id: a,
        },
        entries = List.unmodifiable(entries);

  /// Everything that keeps the books from adding up: bad accounts, and
  /// entries that don't balance, post to an unknown account or put a
  /// currency into an account that holds another.
  List<EntryIssue> get issues {
    final out = <EntryIssue>[];
    for (final a in accounts.values) {
      final p = a.problem;
      if (p != null) out.add(EntryIssue(EntryProblem.badAccount, a.id, p));
    }
    for (final e in entries) {
      out.addAll(e.issues);
      for (final l in e.lines) {
        final a = accounts[l.accountId];
        if (a == null) {
          out.add(EntryIssue(EntryProblem.unknownAccount, e.id, 'No account ${l.accountId}.'));
        } else if (a.currency != null && a.currency != l.currency) {
          out.add(EntryIssue(EntryProblem.wrongCurrency, e.id, '${a.name} holds ${a.currency}; the line is in ${l.currency}.'));
        }
      }
    }
    return out;
  }

  bool _within(BookEntry e, DateTime? from, DateTime? to) =>
      e.counts && (from == null || !e.date.isBefore(from)) && (to == null || !e.date.isAfter(to));

  /// Stored (debit-positive) totals per account and currency, for entries
  /// dated from [from] to [to] inclusive. Declined entries never count.
  Map<String, Amounts> _totals({DateTime? from, DateTime? to}) {
    final out = <String, Amounts>{};
    for (final e in entries) {
      if (!_within(e, from, to)) continue;
      for (final l in e.lines) {
        final m = out[l.accountId] ??= {};
        m[l.currency] = (m[l.currency] ?? 0) + l.amount;
      }
    }
    return out;
  }

  /// What each account shows on [asOf] (today when null): a wallet's cash,
  /// a card's debt, a category's spending, each as a positive figure when
  /// there is something in it.
  Map<String, Amounts> balances({DateTime? asOf}) {
    final totals = _totals(to: asOf);
    return {
      for (final e in totals.entries)
        e.key: {for (final c in e.value.entries) c.key: c.value * (accounts[e.key]?.side.shownSign ?? 1)},
    };
  }

  /// One account's shown balance in its own currency (zero if untouched).
  int balanceOf(String accountId, {DateTime? asOf}) {
    final a = accounts[accountId];
    final b = balances(asOf: asOf)[accountId] ?? const {};
    if (a?.currency != null) return b[a!.currency] ?? 0;
    if (b.length > 1) throw StateError('${a?.name ?? accountId} holds several currencies; read balances() instead.');
    return b.values.isEmpty ? 0 : b.values.first;
  }

  /// What you own and what you owe on [asOf], with each account's line.
  BalanceSheet balanceSheet({DateTime? asOf}) {
    final b = balances(asOf: asOf);
    final own = <BalanceSheetLine>[], owe = <BalanceSheetLine>[];
    for (final a in accounts.values) {
      if (!a.side.onBalanceSheet) continue;
      final amount = b[a.id]?[a.currency] ?? 0;
      if (amount == 0 && a.archived) continue;
      (a.side == AccountSide.own ? own : owe).add(BalanceSheetLine(a, amount));
    }
    return BalanceSheet(own: own, owe: owe);
  }

  /// Net worth in [currency] at [rates], for accounts that count in it.
  Money netWorth(String currency, FXRates rates, {DateTime? asOf}) => balanceSheet(asOf: asOf).netWorth(currency, rates);

  /// Totals on one side between [from] and [to] inclusive, by currency, as
  /// shown: spending and income both read as positive amounts. [accountIds]
  /// narrows it to some categories.
  Amounts flow(AccountSide side, {DateTime? from, DateTime? to, Set<String>? accountIds}) {
    final out = <String, int>{};
    _totals(from: from, to: to).forEach((id, byCcy) {
      final a = accounts[id];
      if (a == null || a.side != side) return;
      if (accountIds != null && !accountIds.contains(id)) return;
      byCcy.forEach((c, v) => out[c] = (out[c] ?? 0) + v * side.shownSign);
    });
    out.removeWhere((_, v) => v == 0);
    return out;
  }

  Amounts spending({DateTime? from, DateTime? to, Set<String>? categories}) =>
      flow(AccountSide.spending, from: from, to: to, accountIds: categories);

  Amounts income({DateTime? from, DateTime? to, Set<String>? categories}) =>
      flow(AccountSide.income, from: from, to: to, accountIds: categories);
}

class BalanceSheetLine {
  final BookAccount account;

  /// As shown, in the account's currency: positive is something in it.
  final int amount;

  const BalanceSheetLine(this.account, this.amount);

  String get currency => account.currency!;
}

/// The two sides of the books on one date.
class BalanceSheet {
  final List<BalanceSheetLine> own;
  final List<BalanceSheetLine> owe;

  const BalanceSheet({required this.own, required this.owe});

  static Amounts _sum(Iterable<BalanceSheetLine> lines) {
    final out = <String, int>{};
    for (final l in lines) {
      if (!l.account.countsInNetWorth || l.amount == 0) continue;
      out[l.currency] = (out[l.currency] ?? 0) + l.amount;
    }
    return out;
  }

  /// What you own, by currency, for accounts that count in net worth.
  Amounts get owned => _sum(own);

  /// What you owe, by currency, for accounts that count in net worth.
  Amounts get owed => _sum(owe);

  static Money convert(Amounts amounts, String currency, FXRates rates) {
    final target = rates.rate(currency);
    if (target == null) throw ArgumentError('No rate for $currency.');
    var total = 0.0;
    amounts.forEach((c, v) {
      final r = rates.rate(c);
      if (r == null) throw ArgumentError('No rate for $c.');
      total += MinorUnits.toMajor(v, c) / r * target;
    });
    return Money(total, currency);
  }

  Money ownedIn(String currency, FXRates rates) => convert(owned, currency, rates);
  Money owedIn(String currency, FXRates rates) => convert(owed, currency, rates);

  Money netWorth(String currency, FXRates rates) =>
      Money(ownedIn(currency, rates).amount - owedIn(currency, rates).amount, currency);
}
