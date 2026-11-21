import 'book.dart';
import 'book_account.dart';
import 'minor_units.dart';
import 'money.dart';

/// The groups the balance sheet shows, in order: what you own, then what
/// you owe. Holdings come from the holdings ledger at live prices; every
/// other group is a set of book accounts.
enum SheetGroup {
  holdings(AccountSide.own, {}),
  cash(AccountSide.own, {AccountType.cash, AccountType.debit}),
  owedToYou(AccountSide.own, {AccountType.receivable}),
  assets(AccountSide.own, {AccountType.asset}),
  cards(AccountSide.owe, {AccountType.credit}),
  loans(AccountSide.owe, {AccountType.loan}),
  youOwe(AccountSide.owe, {AccountType.payable});

  final AccountSide side;
  final Set<AccountType> types;

  const SheetGroup(this.side, this.types);

  static SheetGroup? of(AccountType type) {
    for (final g in SheetGroup.values) {
      if (g.types.contains(type)) return g;
    }
    return null;
  }
}

/// One group's total in the display currency.
class SheetGroupTotal {
  final SheetGroup group;
  final double amount;
  final List<BalanceSheetLine> lines;

  const SheetGroupTotal(this.group, this.amount, this.lines);
}

/// Net worth = what you own − what you owe, where what you own includes
/// holdings at live prices. Amounts in a currency with no rate are left
/// out and named in [missingRates], instead of being counted at 1:1.
class NetWorthSummary {
  final String currency;
  final double holdings;
  final List<SheetGroupTotal> groups;
  final Set<String> missingRates;

  const NetWorthSummary({required this.currency, required this.holdings, required this.groups, required this.missingRates});

  double _side(AccountSide side) => groups.where((g) => g.group.side == side).fold(0.0, (a, g) => a + g.amount);

  double get owned => _side(AccountSide.own);
  double get owed => _side(AccountSide.owe);
  double get netWorth => owned - owed;

  Money get ownedMoney => Money(owned, currency);
  Money get owedMoney => Money(owed, currency);
  Money get netWorthMoney => Money(netWorth, currency);

  SheetGroupTotal group(SheetGroup g) => groups.firstWhere((t) => t.group == g);

  /// [holdingsValue] is the holdings' live value, already in [currency].
  static NetWorthSummary of({
    required Book book,
    required double holdingsValue,
    required String currency,
    required FXRates rates,
    DateTime? asOf,
  }) {
    final sheet = book.balanceSheet(asOf: asOf);
    final missing = <String>{};
    double convert(BalanceSheetLine l) {
      if (!l.account.countsInNetWorth || l.amount == 0) return 0;
      final major = MinorUnits.toMajor(l.amount, l.currency);
      if (l.currency == currency) return major;
      final from = rates.rate(l.currency), to = rates.rate(currency);
      if (from == null || to == null) {
        missing.add(l.currency);
        return 0;
      }
      return major / from * to;
    }

    final groups = <SheetGroupTotal>[];
    for (final g in SheetGroup.values) {
      if (g == SheetGroup.holdings) {
        groups.add(SheetGroupTotal(g, holdingsValue, const []));
        continue;
      }
      final lines = [
        for (final l in [...sheet.own, ...sheet.owe])
          // The balance sheet already leaves out archived accounts with
          // nothing in them; one still holding money still counts.
          if (g.types.contains(l.account.type)) l,
      ];
      groups.add(SheetGroupTotal(g, lines.fold(0.0, (a, l) => a + convert(l)), lines));
    }
    return NetWorthSummary(currency: currency, holdings: holdingsValue, groups: groups, missingRates: missing);
  }

  /// One account's balance in [currency], or null without a rate.
  static double? inCurrency(int minor, String from, String currency, FXRates rates) {
    final major = MinorUnits.toMajor(minor, from);
    if (from == currency) return major;
    final f = rates.rate(from), t = rates.rate(currency);
    if (f == null || t == null) return null;
    return major / f * t;
  }
}
