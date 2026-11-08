import 'package:flutter_test/flutter_test.dart';
import 'package:qima/models/book.dart';
import 'package:qima/models/book_account.dart';
import 'package:qima/models/book_entry.dart';
import 'package:qima/models/entry_builder.dart';
import 'package:qima/models/minor_units.dart';
import 'package:qima/models/money.dart';

/// The example from docs/v5: a person in Riyadh paid in SAR, with family and
/// an account in Egypt in EGP, typed at 13.00 EGP to the riyal.
BookAccount own(String id, AccountType type, [String ccy = 'SAR']) =>
    BookAccount(id: id, name: id, side: AccountSide.own, type: type, currency: ccy);
BookAccount owe(String id, AccountType type, [String ccy = 'SAR']) =>
    BookAccount(id: id, name: id, side: AccountSide.owe, type: type, currency: ccy);
BookAccount spendCat(String id) => BookAccount(id: id, name: id, side: AccountSide.spending, type: AccountType.category);
BookAccount incomeCat(String id) => BookAccount(id: id, name: id, side: AccountSide.income, type: AccountType.category);

final rajhi = own('rajhi', AccountType.debit);
final wallet = own('wallet', AccountType.cash);
final cib = own('cib', AccountType.debit, 'EGP');
final holdings = own('holdings', AccountType.holding);
final faisal = own('faisal', AccountType.receivable);
final faisalEgp = own('faisal.egp', AccountType.receivable, 'EGP');
final omar = own('omar', AccountType.receivable);
final saad = own('saad', AccountType.receivable);
final land = own('land', AccountType.asset);
final camry = own('camry', AccountType.asset);
final visa = owe('visa', AccountType.credit);
final carLoan = owe('car', AccountType.loan);
final khalid = owe('khalid', AccountType.payable);
final dining = spendCat('dining');
final groceries = spendCat('groceries');
final otherOut = spendCat('other.out');
final otherIn = incomeCat('other.in');
final salary = incomeCat('salary');

final allAccounts = [rajhi, wallet, cib, holdings, faisal, faisalEgp, omar, saad, land, camry, visa, carLoan, khalid, dining, groceries, otherOut, otherIn, salary];

final rates = FXRates(base: 'SAR', rates: const {'SAR': 1, 'EGP': 13, 'USD': 0.2667}, updatedAt: DateTime.utc(2026, 11, 17));
final day = DateTime(2026, 11, 17);

int sar(num major) => MinorUnits.fromMajor(major, 'SAR');
int egp(num major) => MinorUnits.fromMajor(major, 'EGP');

EntryBuilder builder() {
  var n = 0;
  return EntryBuilder(baseCurrency: 'SAR', rates: rates, manualRates: const {'EGP': 13}, newId: () => 'e${++n}');
}

Book book(List<BookEntry> entries) => Book(allAccounts, entries);
double worth(Book b) => b.netWorth('SAR', rates).amount;

void main() {
  group('MinorUnits', () {
    test('riyals have two places, dinars three, yen none', () {
      expect(MinorUnits.fromMajor(9100.45, 'SAR'), 910045);
      expect(MinorUnits.fromMajor(1.234, 'KWD'), 1234);
      expect(MinorUnits.fromMajor(500, 'JPY'), 500);
      expect(MinorUnits.toMajor(55534, 'SAR'), 555.34);
    });
  });

  group('design.md section 3: one entry per row of the table', () {
    test('coffee on the Visa: Dining up, Visa owed up, and it counts as spending', () {
      final e = builder().spend(visa, dining, sar(18), day, merchant: 'Barn’s');
      final b = book([e]);
      expect(e.isBalanced, isTrue);
      expect(b.issues, isEmpty);
      expect(b.balanceOf('visa'), sar(18));
      expect(b.spending(), {'SAR': sar(18)});
      expect(worth(b), closeTo(-18, 1e-9));
    });

    test('paying the Visa from Al Rajhi is not spending and leaves net worth alone', () {
      final x = builder();
      final b = book([x.spend(visa, groceries, sar(6812.40), day), x.cardPayment(rajhi, visa, sar(6812.40), day)]);
      expect(b.issues, isEmpty);
      expect(b.balanceOf('visa'), 0);
      expect(b.balanceOf('rajhi'), -sar(6812.40));
      expect(b.spending(), {'SAR': sar(6812.40)}, reason: 'only the purchases count, not the payment');
    });

    test('a car payment of 1,440 lowers the loan by 1,200 and only the 240 profit is spending', () {
      final x = builder();
      final b = book([
        x.opening(carLoan, sar(70800), day.subtract(const Duration(days: 30))),
        x.loanPayment(rajhi, carLoan, principal: sar(1200), profit: sar(240), date: day),
      ]);
      expect(b.issues, isEmpty);
      expect(b.balanceOf('car'), sar(69600));
      expect(b.balanceOf('rajhi'), -sar(1440));
      expect(b.spending(), {'SAR': sar(240)});
      expect(b.balanceOf(SystemAccount.interestAndFees.id), sar(240));
      expect(worth(b), closeTo(-70800 - 240, 1e-6), reason: 'net worth falls by the profit only');
    });

    test('lending Faisal 1,500 moves money into “owed to you” and is not spending', () {
      final b = book([builder().lent(rajhi, faisal, sar(1500), day)]);
      expect(b.issues, isEmpty);
      expect(b.balanceOf('faisal'), sar(1500));
      expect(b.spending(), isEmpty);
      expect(worth(b), closeTo(0, 1e-9));
    });

    test('a 240 bill I paid and split: only my 55.34 is spending; friends owe the rest, Faisal in EGP', () {
      final e = builder().billSplit(visa, dining,
          total: sar(240), myShare: sar(55.34), others: {omar: sar(62.19), faisalEgp: egp(778.70), saad: sar(62.57)}, date: day, merchant: 'Mama Noura');
      final b = book([e]);
      expect(e.isBalanced, isTrue, reason: e.issues.join('; '));
      expect(e.lines.where((l) => l.accountId == SystemAccount.rounding.id), isEmpty, reason: '778.70 / 13 is exactly 59.90');
      expect(b.issues, isEmpty);
      expect(b.balanceOf('visa'), sar(240));
      expect(b.spending(), {'SAR': sar(55.34)});
      expect(b.balanceOf('faisal.egp'), egp(778.70));
      expect(worth(b), closeTo(-55.34, 1e-6));
    });

    test('SAR to EGP: each side at the swap’s own rate, not spending, net worth unchanged at that rate', () {
      final e = builder().swap(rajhi, sar(2000), cib, egp(26000), day);
      final b = book([e]);
      expect(e.isBalanced, isTrue);
      expect(e.lines.map((l) => l.baseAmount), [-sar(2000), sar(2000)]);
      expect(b.balanceOf('cib'), egp(26000));
      expect(b.spending(), isEmpty);
      expect(worth(b), closeTo(0, 1e-6));
    });

    test('a new value for the land, 240,000 → 255,000, raises net worth by 15,000 and never touches spending', () {
      final x = builder();
      final opening = x.opening(land, sar(240000), DateTime(2026, 10, 18));
      final v = x.valuation(land, current: sar(240000), value: sar(255000), date: day)!;
      final b = book([opening, v]);
      expect(b.issues, isEmpty);
      expect(b.balanceOf('land'), sar(255000));
      expect(b.balanceOf(SystemAccount.changeInValue.id), sar(15000), reason: 'a gain shows as a positive change in value');
      expect(b.flow(AccountSide.worth), {'SAR': sar(240000 + 15000)});
      expect(b.spending(), isEmpty);
      expect(b.income(), isEmpty);
      expect(worth(b), closeTo(255000, 1e-6));
      expect(x.valuation(land, current: sar(255000), value: sar(255000), date: day), isNull);
    });

    test('selling the car for 82,000 when it was last valued at 85,000 lowers net worth by 3,000', () {
      final x = builder();
      final b = book([
        x.opening(camry, sar(85000), DateTime(2026, 11, 1)),
        x.assetSale(camry, carried: sar(85000), proceeds: sar(82000), into: rajhi, date: day),
      ]);
      expect(b.issues, isEmpty);
      expect(b.balanceOf('camry'), 0);
      expect(b.balanceOf('rajhi'), sar(82000));
      expect(worth(b), closeTo(82000, 1e-6));
      expect(b.spending(), isEmpty);
    });
  });

  group('the other templates', () {
    test('salary is income; a refund is negative spending in its category', () {
      final x = builder();
      final b = book([
        x.income(rajhi, salary, sar(24000), day),
        x.spend(visa, groceries, sar(400), day),
        x.refund(visa, groceries, sar(129), day),
      ]);
      expect(b.issues, isEmpty);
      expect(b.income(), {'SAR': sar(24000)});
      expect(b.spending(), {'SAR': sar(271)});
      expect(b.balanceOf('visa'), sar(271));
    });

    test('an ATM withdrawal moves bank to cash and is neither income nor spending', () {
      final e = builder().transfer(rajhi, wallet, sar(500), day, atm: true);
      final b = book([e]);
      expect(e.template, EntryTemplate.atm);
      expect(b.balanceOf('wallet'), sar(500));
      expect(b.spending(), isEmpty);
      expect(b.income(), isEmpty);
    });

    test('borrowing from Khalid and repaying him leaves nothing owed and nothing spent', () {
      final x = builder();
      final b = book([x.borrowed(rajhi, khalid, sar(800), day), x.repaymentOut(rajhi, khalid, sar(800), day)]);
      expect(b.issues, isEmpty);
      expect(b.balanceOf('khalid'), 0);
      expect(b.balanceOf('rajhi'), 0);
      expect(b.spending(), isEmpty);
    });

    test('a repayment lowers what Faisal owes and raises the bank', () {
      final x = builder();
      final b = book([x.lent(rajhi, faisal, sar(1500), day), x.repaymentIn(rajhi, faisal, sar(30), day)]);
      expect(b.balanceOf('faisal'), sar(1470));
    });

    test('Faisal owes 4,000 EGP and pays back 300 SAR: the debt is cleared at the rate the two figures set', () {
      final x = builder();
      final b = book([x.lent(cib, faisalEgp, egp(4000), day), x.repaymentIn(rajhi, faisalEgp, sar(300), day, clears: egp(4000))]);
      expect(b.issues, isEmpty);
      expect(b.balanceOf('faisal.egp'), 0);
      expect(b.balanceOf('rajhi'), sar(300));
      expect(b.balanceOf('cib'), -egp(4000));
      expect(b.spending(), isEmpty);
      expect(b.income(), isEmpty);
    });

    test('a repayment in another currency with no cleared figure clears at today\'s rate', () {
      final x = builder();
      final b = book([x.lent(cib, faisalEgp, egp(4000), day), x.repaymentIn(rajhi, faisalEgp, sar(260), day)]);
      expect(b.issues, isEmpty);
      expect(b.balanceOf('faisal.egp'), egp(4000 - 260 * 13));
    });

    test('paying back an EGP debt from a SAR account lowers the debt by what it clears', () {
      final khalidEgp = owe('khalid.egp', AccountType.payable, 'EGP');
      final x = builder();
      final b = Book([...allAccounts, khalidEgp], [x.borrowed(cib, khalidEgp, egp(1300), day), x.repaymentOut(rajhi, khalidEgp, sar(100), day, clears: egp(1300))]);
      expect(b.issues, isEmpty);
      expect(b.balanceOf('khalid.egp'), 0);
      expect(b.balanceOf('rajhi'), -sar(100));
      expect(b.spending(), isEmpty);
    });

    test('a cash count of 700.00 against 735.57 tracked spends the 35.57 difference in Other', () {
      final x = builder();
      final b = book([
        x.opening(wallet, sar(735.57), DateTime(2026, 11, 1)),
        x.cashCount(wallet, tracked: sar(735.57), counted: sar(700), short: otherOut, over: otherIn, date: day)!,
      ]);
      expect(b.balanceOf('wallet'), sar(700));
      expect(b.spending(), {'SAR': sar(35.57)});
      expect(x.cashCount(wallet, tracked: sar(700), counted: sar(700), short: otherOut, over: otherIn, date: day), isNull);
    });

    test('found cash is income in Other', () {
      final e = builder().cashCount(wallet, tracked: sar(100), counted: sar(120), short: otherOut, over: otherIn, date: day)!;
      expect(book([e]).income(), {'SAR': sar(20)});
    });

    test('a declined charge balances but moves nothing', () {
      final e = builder().spend(visa, dining, sar(99), day, status: EntryStatus.declined);
      final b = book([e]);
      expect(e.template, EntryTemplate.declined);
      expect(b.issues, isEmpty);
      expect(b.balanceOf('visa'), 0);
      expect(b.spending(), isEmpty);
    });
  });

  group('the balance check', () {
    BookEntry raw(List<EntryLine> lines, {EntryStatus status = EntryStatus.posted}) =>
        BookEntry(id: 'x', date: day, template: EntryTemplate.adjustment, baseCurrency: 'SAR', lines: lines, status: status);
    EntryLine l(String acct, int amount, [String ccy = 'SAR', int? base]) =>
        EntryLine(accountId: acct, amount: amount, currency: ccy, baseAmount: base ?? amount);

    test('lines that don’t sum to zero are reported with the gap', () {
      final e = raw([l('dining', 1800), l('visa', -1700)]);
      expect(e.issues.single.problem, EntryProblem.unbalanced);
      expect(e.issues.single.detail, contains('100'));
    });

    test('one line, or a zero line, is not an entry', () {
      expect(raw([l('dining', 1800)]).issues.map((i) => i.problem), contains(EntryProblem.tooFewLines));
      expect(raw([l('dining', 0), l('visa', 0)]).issues.map((i) => i.problem), contains(EntryProblem.zeroLine));
    });

    test('a declined entry may have no lines; any other may not', () {
      expect(raw([], status: EntryStatus.declined).issues, isEmpty);
      expect(raw([]).issues.map((i) => i.problem), contains(EntryProblem.tooFewLines));
    });

    test('a base-currency line must carry its own amount as its base amount', () {
      expect(raw([l('dining', 1800, 'SAR', 1700), l('visa', -1800, 'SAR', -1800)]).issues.map((i) => i.problem), contains(EntryProblem.baseMismatch));
    });

    test('lines in two currencies must balance in the base currency', () {
      final ok = raw([l('rajhi', -200000), l('cib', 2600000, 'EGP', 200000)]);
      final off = raw([l('rajhi', -200000), l('cib', 2600000, 'EGP', 199000)]);
      expect(ok.issues, isEmpty);
      expect(off.issues.single.problem, EntryProblem.unbalanced);
    });

    test('a small FX remainder goes to Rounding, in the open; a large one is never hidden', () {
      final x = EntryBuilder(baseCurrency: 'SAR', rates: rates, manualRates: const {'EGP': 13.07}, newId: () => 'r');
      final e = x.billSplit(visa, dining, total: sar(100), myShare: sar(50), others: {faisalEgp: egp(653.57)}, date: day);
      final rounding = e.lines.where((ln) => ln.accountId == SystemAccount.rounding.id).toList();
      expect(e.isBalanced, isTrue, reason: e.issues.join('; '));
      expect(rounding.single.amount.abs(), lessThanOrEqualTo(e.lines.length));

      final wrong = x.billSplit(visa, dining, total: sar(100), myShare: sar(50), others: {faisalEgp: egp(100)}, date: day);
      expect(wrong.lines.where((ln) => ln.accountId == SystemAccount.rounding.id), isEmpty);
      expect(wrong.issues.single.problem, EntryProblem.unbalanced);
    });

    test('the book reports unknown accounts, wrong currencies and accounts on the wrong side', () {
      final stray = raw([l('nobody', 100), l('visa', -100)]);
      final egpOnRajhi = BookEntry(id: 'y', date: day, template: EntryTemplate.adjustment, baseCurrency: 'SAR', lines: [
        l('rajhi', 1300, 'EGP', 100),
        l('other.in', -1300, 'EGP', -100),
      ]);
      final bad = BookAccount(id: 'bad', name: 'Visa as owned', side: AccountSide.own, type: AccountType.credit, currency: 'SAR');
      final problems = Book([...allAccounts, bad], [stray, egpOnRajhi]).issues.map((i) => i.problem).toSet();
      expect(problems, containsAll({EntryProblem.unknownAccount, EntryProblem.wrongCurrency, EntryProblem.badAccount}));
    });

    test('the builder refuses a currency an account doesn’t hold, and a currency it has no rate for', () {
      expect(() => builder().income(cib, wallet, egp(10), day), throwsArgumentError, reason: 'the wallet holds SAR');
      expect(() => EntryBuilder(baseCurrency: 'SAR', rates: rates, newId: () => 'z').toBase(100, 'XYZ'), throwsArgumentError);
    });
  });

  group('the balance sheet', () {
    // design.md section 3, "Net worth": the example's figures as opening balances.
    List<BookEntry> example(EntryBuilder x) {
      final d = DateTime(2026, 11, 1);
      return [
        x.opening(holdings, sar(110007.80), d),
        x.opening(wallet, sar(892.31), d),
        x.opening(rajhi, sar(22020.35), d),
        x.opening(faisal, sar(2299.13), d),
        x.opening(land, sar(240000), d),
        x.opening(camry, sar(85000), d),
        x.opening(visa, sar(9100.45), d),
        x.opening(carLoan, sar(81150.07), d),
        x.opening(khalid, sar(800), d),
      ];
    }

    test('reproduces the design’s example: SAR 369,169.07', () {
      final b = book(example(builder()));
      final sheet = b.balanceSheet();
      expect(b.issues, isEmpty);
      expect(sheet.owned, {'SAR': sar(460219.59)});
      expect(sheet.owed, {'SAR': sar(91050.52)});
      expect(worth(b), closeTo(369169.07, 1e-6));
    });

    test('an asset switched out of net worth stays on the sheet but out of the total', () {
      final accounts = [for (final a in allAccounts) a.id == 'camry' ? a.copyWith(countsInNetWorth: false) : a];
      final b = Book(accounts, example(builder()));
      expect(b.balanceSheet().own.map((l) => l.account.id), contains('camry'));
      expect(b.netWorth('SAR', rates).amount, closeTo(369169.07 - 85000, 1e-6));
    });

    test('net worth always equals opening balances and changes in value plus income minus spending', () {
      final x = builder();
      final b = book([
        ...example(x),
        x.income(rajhi, salary, sar(24000), day),
        x.spend(visa, dining, sar(240), day),
        x.loanPayment(rajhi, carLoan, principal: sar(1200), profit: sar(240), date: day),
        x.valuation(land, current: sar(240000), value: sar(255000), date: day)!,
        x.swap(rajhi, sar(2000), cib, egp(26000), day),
      ]);
      int one(Amounts a) => a['SAR'] ?? 0;
      final sheet = b.balanceSheet();
      final lhs = one(sheet.owned) - one(sheet.owed) + MinorUnits.fromMajor(MinorUnits.toMajor(sheet.owned['EGP'] ?? 0, 'EGP') / 13, 'SAR');
      final rhs = one(b.flow(AccountSide.worth)) + one(b.income()) - one(b.spending());
      expect(lhs, rhs);
    });

    test('balances can be read as of an earlier date', () {
      final x = builder();
      final b = book([x.opening(rajhi, sar(1000), DateTime(2026, 11, 1)), x.spend(rajhi, dining, sar(100), day)]);
      expect(b.balanceOf('rajhi', asOf: DateTime(2026, 11, 10)), sar(1000));
      expect(b.balanceOf('rajhi'), sar(900));
      expect(b.spending(from: DateTime(2026, 11, 1), to: DateTime(2026, 11, 10)), isEmpty);
    });
  });

  group('sync records', () {
    test('an account survives a JSON round trip', () {
      final a = camry.copyWith(countsInNetWorth: false, archived: true);
      expect(BookAccount.fromJson(a.toJson()), a);
    });

    test('an entry and its lines survive a JSON round trip as one record', () {
      final e = builder().billSplit(visa, dining,
          total: sar(240), myShare: sar(55.34), others: {omar: sar(62.19), faisalEgp: egp(778.70), saad: sar(62.57)}, date: day, merchant: 'Mama Noura');
      final back = BookEntry.fromJson(e.toJson());
      expect(back, e);
      expect(back.template, EntryTemplate.billSplit);
      expect(e.toJson()['template'], 'bill_split');
    });

    test('system accounts have the same ids on every device', () {
      expect(Book(const [], const []).accounts.keys, containsAll(SystemAccount.values.map((s) => s.id)));
      expect(SystemAccount.rounding.id, 'system.rounding');
    });
  });
}
