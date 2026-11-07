import 'book_account.dart';
import 'book_entry.dart';
import 'minor_units.dart';
import 'money.dart';

/// Makes balanced entries for each template, so no screen ever assembles
/// lines by hand. Every amount is in whole minor units of the account it is
/// posted to; flow accounts (income and spending) take the currency of the
/// money that moved.
///
/// The tests mirror design.md section 3: one builder per row of its table.
class EntryBuilder {
  /// The person's base currency; every line also carries its amount in it.
  final String baseCurrency;

  /// Live rates (units of a currency per one [FXRates.base]).
  final FXRates rates;

  /// Rates the person typed, in units of the currency per one
  /// [baseCurrency]. They win over [rates], as in design.md (Currencies and
  /// rates).
  final Map<String, double> manualRates;

  /// Makes entry ids (a UUID v4 in the app; fixed strings in tests).
  final String Function() newId;

  const EntryBuilder({required this.baseCurrency, required this.rates, required this.newId, this.manualRates = const {}});

  /// Units of [currency] per one [baseCurrency].
  double rateOf(String currency) {
    if (currency == baseCurrency) return 1;
    final manual = manualRates[currency];
    if (manual != null) return manual;
    final c = rates.rate(currency), b = rates.rate(baseCurrency);
    if (c == null || b == null) throw ArgumentError('No rate for $currency against $baseCurrency.');
    return c / b;
  }

  /// [amount] minor units of [currency] in minor units of [baseCurrency].
  int toBase(int amount, String currency) {
    if (currency == baseCurrency) return amount;
    return MinorUnits.fromMajor(MinorUnits.toMajor(amount, currency) / rateOf(currency), baseCurrency);
  }

  EntryLine _line(BookAccount account, int amount, {String? currency, int? baseAmount}) {
    final ccy = account.currency ?? currency;
    if (ccy == null) throw ArgumentError('${account.name} keeps every currency, so the line needs one.');
    if (account.currency != null && currency != null && currency != account.currency) {
      throw ArgumentError('${account.name} holds ${account.currency}, not $currency.');
    }
    return EntryLine(accountId: account.id, amount: amount, currency: ccy, baseAmount: baseAmount ?? toBase(amount, ccy));
  }

  /// Lines in several currencies are converted one by one, so their base
  /// amounts can miss zero by a minor unit or two. That difference goes to
  /// Rounding, in the open. Anything larger is a real imbalance and is left
  /// for `BookEntry.issues` to report.
  List<EntryLine> _close(List<EntryLine> lines) {
    if ({for (final l in lines) l.currency}.length < 2) return lines;
    final off = lines.fold<int>(0, (a, l) => a + l.baseAmount);
    if (off == 0 || off.abs() > lines.length) return lines;
    return [...lines, EntryLine(accountId: SystemAccount.rounding.id, amount: -off, currency: baseCurrency, baseAmount: -off)];
  }

  BookEntry _entry(EntryTemplate template, DateTime date, List<EntryLine> lines,
          {String merchant = '', String note = '', EntryStatus status = EntryStatus.posted, EntrySource source = EntrySource.typed}) =>
      BookEntry(
        id: newId(),
        date: date,
        template: template,
        baseCurrency: baseCurrency,
        lines: _close(lines),
        merchant: merchant,
        note: note,
        status: status,
        source: source,
      );

  BookAccount get _opening => SystemAccount.openingBalances.account;
  BookAccount get _change => SystemAccount.changeInValue.account;
  BookAccount get _interest => SystemAccount.interestAndFees.account;

  /// An account's balance on the day Qima starts tracking it. [shown] is
  /// the figure as people read it: 892.31 in a wallet, 9,100.45 owed on a card.
  BookEntry opening(BookAccount account, int shown, DateTime date) {
    final stored = shown * account.side.shownSign;
    return _entry(EntryTemplate.opening, date, [_line(account, stored), _line(_opening, -stored, currency: account.currency)],
        source: EntrySource.migration);
  }

  /// A purchase, bill or cash spend: the category up, the account it was
  /// paid from down (a bank balance falls, a card's debt rises).
  BookEntry spend(BookAccount from, BookAccount category, int amount, DateTime date, {String merchant = '', EntryStatus status = EntryStatus.posted}) =>
      _entry(status == EntryStatus.declined ? EntryTemplate.declined : EntryTemplate.spend, date,
          [_line(category, amount, currency: from.currency), _line(from, -amount)],
          merchant: merchant, status: status);

  /// Salary or other income arriving in [to].
  BookEntry income(BookAccount to, BookAccount category, int amount, DateTime date, {String merchant = ''}) =>
      _entry(EntryTemplate.income, date, [_line(to, amount), _line(category, -amount, currency: to.currency)], merchant: merchant);

  /// Money back from a shop: negative spending in the original category.
  BookEntry refund(BookAccount to, BookAccount category, int amount, DateTime date, {String merchant = ''}) =>
      _entry(EntryTemplate.refund, date, [_line(to, amount), _line(category, -amount, currency: to.currency)], merchant: merchant);

  /// Between two of the person's own accounts in one currency. An ATM
  /// withdrawal is the same move into a cash wallet.
  BookEntry transfer(BookAccount from, BookAccount to, int amount, DateTime date, {bool atm = false}) =>
      _entry(atm ? EntryTemplate.atm : EntryTemplate.transfer, date, [_line(to, amount), _line(from, -amount)]);

  /// Changing money: [sent] of [from]'s currency became [received] of
  /// [to]'s. The rate is the one the swap happened at, so the base amounts
  /// are made equal and opposite instead of using today's rate twice.
  BookEntry swap(BookAccount from, int sent, BookAccount to, int received, DateTime date) {
    final int baseOut;
    if (to.currency == baseCurrency) {
      baseOut = received;
    } else if (from.currency == baseCurrency) {
      baseOut = sent;
    } else {
      baseOut = toBase(sent, from.currency!);
    }
    return _entry(EntryTemplate.swap, date, [_line(from, -sent, baseAmount: -baseOut), _line(to, received, baseAmount: baseOut)]);
  }

  /// Paying a card from a bank: the bank down, the card's debt down. Not
  /// spending; the spending was each purchase.
  BookEntry cardPayment(BookAccount bank, BookAccount card, int amount, DateTime date) =>
      _entry(EntryTemplate.cardPayment, date, [_line(card, amount), _line(bank, -amount)]);

  /// A loan instalment: the principal lowers the loan, the profit is
  /// spending in Interest & fees, and the bank pays both.
  BookEntry loanPayment(BookAccount bank, BookAccount loan, {required int principal, required int profit, required DateTime date}) =>
      _entry(EntryTemplate.loanPayment, date, [
        _line(loan, principal),
        if (profit != 0) _line(_interest, profit, currency: loan.currency),
        _line(bank, -(principal + profit)),
      ]);

  /// Lending: the money leaves [from] and becomes owed to the person.
  BookEntry lent(BookAccount from, BookAccount owedByThem, int amount, DateTime date) =>
      _entry(EntryTemplate.lent, date, [_line(owedByThem, amount), _line(from, -amount)]);

  /// Borrowing: money arrives in [to] and is owed by the person.
  BookEntry borrowed(BookAccount to, BookAccount owedByMe, int amount, DateTime date) =>
      _entry(EntryTemplate.borrowed, date, [_line(to, amount), _line(owedByMe, -amount)]);

  /// Someone pays the person back.
  BookEntry repaymentIn(BookAccount to, BookAccount owedByThem, int amount, DateTime date) =>
      _entry(EntryTemplate.repaymentIn, date, [_line(to, amount), _line(owedByThem, -amount)]);

  /// The person pays someone back.
  BookEntry repaymentOut(BookAccount from, BookAccount owedByMe, int amount, DateTime date) =>
      _entry(EntryTemplate.repaymentOut, date, [_line(owedByMe, amount), _line(from, -amount)]);

  /// A cash count. Less than tracked is spending in [short]; more is income
  /// in [over]. Null when the count matches.
  BookEntry? cashCount(BookAccount cash, {required int tracked, required int counted, required BookAccount short, required BookAccount over, required DateTime date}) {
    final d = counted - tracked;
    if (d == 0) return null;
    final flow = d < 0 ? short : over;
    return _entry(EntryTemplate.cashCount, date, [_line(cash, d), _line(flow, -d, currency: cash.currency)], source: EntrySource.count);
  }

  /// Brings [account] to the balance a statement shows: [tracked] is what
  /// the book has, [statement] what the bank says, both as people read them.
  /// The difference goes to Opening balances, so it is never counted as
  /// spending or income. Null when they already agree.
  BookEntry? balanceTo(BookAccount account, {required int tracked, required int statement, required DateTime date}) {
    final stored = (statement - tracked) * account.side.shownSign;
    if (stored == 0) return null;
    return _entry(EntryTemplate.adjustment, date, [_line(account, stored), _line(_opening, -stored, currency: account.currency)]);
  }

  /// A bill the person paid in full from [paidFrom] and split: only their
  /// own share is spending; each other share becomes money owed to them, in
  /// that person's currency at the split's rate.
  BookEntry billSplit(BookAccount paidFrom, BookAccount category, {required int total, required int myShare, required Map<BookAccount, int> others, required DateTime date, String merchant = ''}) {
    final lines = [
      _line(category, myShare, currency: paidFrom.currency),
      for (final e in others.entries) _line(e.key, e.value),
      _line(paidFrom, -total),
    ];
    return _entry(EntryTemplate.billSplit, date, lines, merchant: merchant);
  }

  /// A new value for an asset the person values themselves. The difference
  /// goes to Change in value: net worth moves, the budget never does. Null
  /// when the value hasn't changed.
  BookEntry? valuation(BookAccount asset, {required int current, required int value, required DateTime date, String note = ''}) {
    final d = value - current;
    if (d == 0) return null;
    return _entry(EntryTemplate.valuation, date, [_line(asset, d), _line(_change, -d, currency: asset.currency)], note: note, source: EntrySource.valuation);
  }

  /// Selling an asset carried at [carried] for [proceeds] paid into [into].
  /// The gap is the gain or loss, in Change in value.
  BookEntry assetSale(BookAccount asset, {required int carried, required int proceeds, required BookAccount into, required DateTime date}) {
    final intoBase = toBase(proceeds, into.currency!);
    final assetBase = toBase(carried, asset.currency!);
    return _entry(EntryTemplate.assetSale, date, [
      _line(into, proceeds, baseAmount: intoBase),
      _line(asset, -carried, baseAmount: -assetBase),
      if (intoBase != assetBase) _line(_change, assetBase - intoBase, currency: baseCurrency),
    ]);
  }
}
