import 'package:flutter_test/flutter_test.dart';
import 'package:qima/models/book.dart';
import 'package:qima/models/book_account.dart';
import 'package:qima/models/entry_builder.dart';
import 'package:qima/models/minor_units.dart';
import 'package:qima/models/money.dart';
import 'package:qima/models/money_analysis.dart';
import 'package:qima/models/money_settings.dart';
import 'package:qima/models/net_worth.dart';
import 'package:qima/models/zakat.dart';
import 'package:qima/models/zakat_book.dart';
import 'package:qima/theme/money_labels.dart';

BookAccount own(String id, AccountType type, [String ccy = 'SAR']) =>
    BookAccount(id: id, name: id, side: AccountSide.own, type: type, currency: ccy);
BookAccount owe(String id, AccountType type, [String ccy = 'SAR']) =>
    BookAccount(id: id, name: id, side: AccountSide.owe, type: type, currency: ccy);
BookAccount spendCat(String id) => BookAccount(id: id, name: id, side: AccountSide.spending, type: AccountType.category);
BookAccount incomeCat(String id) => BookAccount(id: id, name: id, side: AccountSide.income, type: AccountType.category);

final rajhi = own('rajhi', AccountType.debit);
final wallet = own('wallet', AccountType.cash);
final cib = own('cib', AccountType.debit, 'EGP');
final faisal = own('faisal', AccountType.receivable);
final land = own('land', AccountType.asset).copyWith(assetKind: AssetKind.property, heldForSale: true);
final camry = own('camry', AccountType.asset).copyWith(assetKind: AssetKind.vehicle);
final visa = owe('visa', AccountType.credit);
final carLoan = owe('car', AccountType.loan);
final khalid = owe('khalid', AccountType.payable);
final dining = spendCat('dining');
final groceries = spendCat('groceries');
final salary = incomeCat('salary');
final accounts = [rajhi, wallet, cib, faisal, land, camry, visa, carLoan, khalid, dining, groceries, salary];

final rates = FXRates(base: 'SAR', rates: const {'SAR': 1, 'EGP': 13}, updatedAt: DateTime.utc(2026, 11, 7));

int sar(num major) => MinorUnits.fromMajor(major, 'SAR');

EntryBuilder builder() {
  var n = 0;
  return EntryBuilder(baseCurrency: 'SAR', rates: rates, newId: () => 'e${++n}');
}

/// design.md's example without holdings in the book: holdings join from the
/// holdings ledger at live prices instead.
Book example() {
  final x = builder();
  final d = DateTime(2026, 11, 1);
  return Book(accounts, [
    x.opening(wallet, sar(892.31), d),
    x.opening(rajhi, sar(22020.35), d),
    x.opening(faisal, sar(2299.13), d),
    x.opening(land, sar(240000), d),
    x.opening(camry, sar(85000), d),
    x.opening(visa, sar(9100.45), d),
    x.opening(carLoan, sar(81150.07), d),
    x.opening(khalid, sar(800), d),
  ]);
}

void main() {
  group('NetWorthSummary', () {
    test('holdings from the holdings ledger plus the book reproduce SAR 369,169.07', () {
      final s = NetWorthSummary.of(book: example(), holdingsValue: 110007.80, currency: 'SAR', rates: rates);
      expect(s.owned, closeTo(460219.59, 1e-6));
      expect(s.owed, closeTo(91050.52, 1e-6));
      expect(s.netWorth, closeTo(369169.07, 1e-6));
      expect(s.group(SheetGroup.assets).amount, closeTo(325000, 1e-6));
      expect(s.group(SheetGroup.cash).amount, closeTo(892.31 + 22020.35, 1e-6));
      expect(s.group(SheetGroup.loans).lines.single.account.id, 'car');
      expect(s.missingRates, isEmpty);
    });

    test('an account in a currency with no rate is left out and named, never counted at 1:1', () {
      final usd = own('usd', AccountType.debit, 'USD');
      final withUsd = FXRates(base: 'SAR', rates: const {'SAR': 1, 'EGP': 13, 'USD': 0.2667}, updatedAt: DateTime.utc(2026, 11, 7));
      final x = EntryBuilder(baseCurrency: 'SAR', rates: withUsd, newId: () => 'u1');
      final b = Book([...accounts, usd], [x.opening(usd, 100000, DateTime(2026, 11, 1))]);
      final s = NetWorthSummary.of(book: b, holdingsValue: 0, currency: 'SAR', rates: rates);
      expect(s.netWorth, 0);
      expect(s.missingRates, {'USD'});
    });

    test('an account switched out of net worth isn’t counted; an archived one still holding money is', () {
      final x = builder();
      final d = DateTime(2026, 11, 1);
      final b = Book(
        [rajhi, camry.copyWith(countsInNetWorth: false), wallet.copyWith(archived: true)],
        [x.opening(rajhi, sar(100), d), x.opening(camry, sar(85000), d), x.opening(wallet, sar(50), d)],
      );
      final s = NetWorthSummary.of(book: b, holdingsValue: 0, currency: 'SAR', rates: rates);
      expect(s.netWorth, closeTo(150, 1e-9));
      // The same total the book itself gives.
      expect(s.netWorth, closeTo(b.netWorth('SAR', rates).amount, 1e-9));
    });

    test('EGP converts at the live rate', () {
      final b = Book(accounts, [builder().opening(cib, MinorUnits.fromMajor(1300, 'EGP'), DateTime(2026, 11, 1))]);
      expect(NetWorthSummary.of(book: b, holdingsValue: 0, currency: 'SAR', rates: rates).netWorth, closeTo(100, 1e-9));
    });
  });

  group('MonthAnalysis', () {
    final x = builder();
    final b = Book(accounts, [
      x.opening(rajhi, sar(10000), DateTime(2026, 9, 1)),
      x.spend(rajhi, groceries, sar(300), DateTime(2026, 10, 5)),
      x.income(rajhi, salary, sar(12000), DateTime(2026, 11, 1)),
      x.spend(visa, dining, sar(450), DateTime(2026, 11, 3)),
      x.spend(rajhi, groceries, sar(600), DateTime(2026, 11, 4)),
      // Not spending: a card payment and a loan's principal.
      x.cardPayment(rajhi, visa, sar(450), DateTime(2026, 11, 5)),
      x.loanPayment(rajhi, carLoan, principal: sar(1200), profit: sar(240), date: DateTime(2026, 11, 6)),
      // Next month: not in November.
      x.spend(rajhi, dining, sar(99), DateTime(2026, 12, 1)),
    ]);

    test('spending by category counts only spending lines: profit yes, principal and card payments no', () {
      final a = MonthAnalysis.of(b, DateTime(2026, 11, 20), currency: 'SAR', rates: rates);
      expect(a.month, DateTime(2026, 11));
      expect(a.spent, closeTo(450 + 600 + 240, 1e-9));
      expect(a.income, closeTo(12000, 1e-9));
      expect(a.byCategory.first, ('groceries', 600.0));
      expect(a.spentIn(SystemAccount.interestAndFees.id), closeTo(240, 1e-9));
      expect(a.net, closeTo(12000 - 1290, 1e-9));
    });

    test('the pace projects spending to the month’s end; a past month projects its own total', () {
      final a = MonthAnalysis.of(b, DateTime(2026, 11, 1), currency: 'SAR', rates: rates);
      // 1,290 over 10 of November's 30 days.
      expect(a.projected(DateTime(2026, 11, 10)), closeTo(1290 / 10 * 30, 1e-9));
      final october = MonthAnalysis.of(b, DateTime(2026, 10, 1), currency: 'SAR', rates: rates);
      expect(october.projected(DateTime(2026, 11, 10)), closeTo(300, 1e-9));
      expect(MonthAnalysis.of(b, DateTime(2027, 1, 1), currency: 'SAR', rates: rates).projected(DateTime(2026, 11, 10)), isNull);
    });

    test('budget: left to spend, lines ahead of pace, and spare money on others', () {
      final a = MonthAnalysis.of(b, DateTime(2026, 11, 1),
          currency: 'SAR', rates: rates, budgets: {'dining': sar(600), 'groceries': sar(3000)}, budgetCurrency: 'SAR');
      expect(a.budget, closeTo(3600, 1e-9));
      expect(a.leftToSpend, closeTo(3600 - 1290, 1e-9));
      // Day 10 of 30: dining's 450 is past a third of 600; groceries' 600 isn't past a third of 3,000.
      final ahead = a.aheadOfPace(DateTime(2026, 11, 10));
      expect(ahead.map((e) => e.$1), ['dining']);
      final spare = a.spare(DateTime(2026, 11, 10));
      expect(spare.single.$1, 'groceries');
      expect(spare.single.$2, closeTo(3000 - 600 * 3, 1e-9));
    });

    test('a budget set in another currency converts at today’s rate', () {
      final a = MonthAnalysis.of(b, DateTime(2026, 11, 1), currency: 'SAR', rates: rates, budgets: {'dining': MinorUnits.fromMajor(1300, 'EGP')}, budgetCurrency: 'EGP');
      expect(a.budgets['dining'], closeTo(100, 1e-9));
    });

    test('trend gives each month’s spending, oldest first', () {
      final t = MonthAnalysis.trend(b, DateTime(2026, 11, 15), currency: 'SAR', rates: rates, count: 3);
      expect(t.map((e) => e.$1), [DateTime(2026, 9), DateTime(2026, 10), DateTime(2026, 11)]);
      expect(t.map((e) => e.$2), [0, 300, 1290]);
    });
  });

  group('ZakatOnBook', () {
    ZakatAssessment holdings(double base, double? nisab) => ZakatAssessment(
          lines: const [],
          base: Money(base, 'SAR'),
          threshold: nisab == null ? null : Money(nisab, 'SAR'),
          otherThreshold: null,
          due: const Money(0, 'SAR'),
          status: NisabStatus.noHoldings,
          basis: NisabBasis.gold,
        );

    test('adds cash, money owed to you and assets held for sale; deducts cards and money owed to people, not loans', () {
      final z = ZakatOnBook.of(book: example(), holdings: holdings(10000, 25000), currency: 'SAR', rates: rates);
      expect(z.parts[ZakatPart.cash], closeTo(892.31 + 22020.35, 1e-6));
      expect(z.parts[ZakatPart.owedToYou], closeTo(2299.13, 1e-6));
      // The land is held for sale; the car is for personal use.
      expect(z.parts[ZakatPart.heldForSale], closeTo(240000, 1e-6));
      expect(z.parts[ZakatPart.debtsDue], closeTo(9100.45 + 800, 1e-6));
      final base = 10000 + 892.31 + 22020.35 + 2299.13 + 240000 - 9900.45;
      expect(z.base, closeTo(base, 1e-6));
      expect(z.above, isTrue);
      expect(z.due, closeTo(base * 0.025, 1e-6));
    });

    test('nothing is due below the nisab, or before the nisab is known', () {
      final b = Book(accounts, [builder().opening(wallet, sar(1000), DateTime(2026, 11, 1))]);
      expect(ZakatOnBook.of(book: b, holdings: holdings(0, 25000), currency: 'SAR', rates: rates).due, 0);
      final unknown = ZakatOnBook.of(book: b, holdings: holdings(0, null), currency: 'SAR', rates: rates);
      expect(unknown.thresholdKnown, isFalse);
      expect(unknown.due, 0);
    });
  });

  group('calendar days', () {
    test('a month’s days come from the calendar, leap February included', () {
      MonthAnalysis m(int y, int mo) => MonthAnalysis.of(Book(accounts, const []), DateTime(y, mo), currency: 'SAR', rates: rates);
      expect(m(2026, 3).daysInMonth, 31);
      expect(m(2026, 4).daysInMonth, 30);
      expect(m(2028, 2).daysInMonth, 29);
      expect(m(2026, 3).elapsedDays(DateTime(2026, 3, 31, 0, 30)), 31);
    });

    test('a calendar date is stored as a day and reads back as the same day', () {
      expect(dayToJson(DateTime(2026, 3, 1)), '2026-03-01');
      expect(dayFromJson('2026-03-01'), DateTime(2026, 3, 1));
      // An instant from an earlier build still reads as its local day.
      final old = DateTime(2026, 3, 1).toUtc().toIso8601String();
      expect(dayFromJson(old), DateTime(2026, 3, 1));
      final r = RecurringPayment(id: 'r', name: 'Rent', amount: 1, fromAccountId: 'a', categoryId: 'c', dayOfMonth: 1, lastPaid: DateTime(2026, 3));
      expect(r.toJson()['lastPaid'], '2026-03-01');
    });
  });

  group('MoneySettings', () {
    test('Home shows cards in the default order until the person moves one', () {
      const s = MoneySettings(features: {MoneyFeature.budget});
      expect(s.visibleCards, [HomeCard.needsReview, HomeCard.comingUp, HomeCard.leftToSpend, HomeCard.holdings, HomeCard.accounts, HomeCard.assets]);
    });

    test('a card never placed goes in its default place after the person’s order', () {
      const s = MoneySettings(homeOrder: [HomeCard.assets, HomeCard.needsReview]);
      final o = s.orderedCards;
      expect(o.first, HomeCard.assets);
      expect(o.indexOf(HomeCard.comingUp), o.indexOf(HomeCard.needsReview) + 1);
      expect(o.toSet(), HomeCard.values.toSet());
    });

    test('a hidden card stays hidden when its feature turns on; turning a feature off hides its card', () {
      const s = MoneySettings(hiddenCards: {HomeCard.people});
      expect(s.copyWith(features: {MoneyFeature.people}).visibleCards, isNot(contains(HomeCard.people)));
      expect(const MoneySettings(features: {MoneyFeature.zakat}).visibleCards, contains(HomeCard.zakat));
      expect(const MoneySettings().visibleCards, isNot(contains(HomeCard.zakat)));
    });

    test('Needs review and Coming up can’t be hidden', () {
      expect(HomeCard.needsReview.canHide, isFalse);
      expect(HomeCard.comingUp.canHide, isFalse);
      expect(HomeCard.comingUp.feature, isNull, reason: 'Coming up is never a feature');
    });

    test('survives a JSON round trip and ignores names it doesn’t know', () {
      const s = MoneySettings(
        features: {MoneyFeature.budget, MoneyFeature.zakat},
        homeOrder: [HomeCard.assets],
        hiddenCards: {HomeCard.holdings},
        budgets: {'dining': 60000},
        budgetCurrency: 'SAR',
        seenWhatsNew: true,
        valueReviewMonths: 12,
      );
      expect(MoneySettings.fromJson(s.toJson()), s);
      final json = s.toJson()..['features'] = ['budget', 'somethingNew'];
      expect(MoneySettings.fromJson(json).features, {MoneyFeature.budget});
    });

    test('a recurring payment is due this month until paid, then next month, on day 28 at the latest', () {
      final r = RecurringPayment(id: 'r', name: 'Rent', amount: 100, fromAccountId: 'rajhi', categoryId: 'home', dayOfMonth: 31);
      expect(r.nextDue(DateTime(2026, 2, 10)), DateTime(2026, 2, 28));
      expect(r.copyWith(lastPaid: DateTime(2026, 2)).nextDue(DateTime(2026, 2, 10)), DateTime(2026, 3, 28));
      expect(RecurringPayment.fromJson(r.toJson()), r);
    });
  });

  group('parseMinor', () {
    test('reads the ways people type amounts', () {
      expect(parseMinor('1250.5', 'SAR'), 125050);
      expect(parseMinor('1,250.50', 'SAR'), 125050);
      expect(parseMinor('1250,50', 'EUR'), 125050);
      expect(parseMinor('1,250', 'SAR'), 125000);
      expect(parseMinor('١٬٢٥٠٫٥', 'SAR'), 125050);
      expect(parseMinor('1.234', 'KWD'), 1234);
      expect(parseMinor('', 'SAR'), isNull);
      expect(parseMinor('abc', 'SAR'), isNull);
    });

    test('minorFieldText writes the currency’s places, grouped', () {
      expect(minorFieldText(125050, 'SAR'), '1,250.50');
      expect(minorFieldText(1234, 'KWD'), '1.234');
      expect(minorFieldText(500, 'JPY'), '500');
    });
  });

  group('BookAccount details', () {
    test('asset details survive a JSON round trip; clear flags remove them', () {
      final a = own('land', AccountType.asset).copyWith(
        assetKind: AssetKind.property,
        boughtOn: DateTime(2020, 3, 1),
        cost: sar(180000),
        securedLoanId: 'car',
        heldForSale: true,
        note: 'Al Qassim',
      );
      expect(BookAccount.fromJson(a.toJson()), a);
      final cleared = a.copyWith(clearCost: true, clearBoughtOn: true, clearSecuredLoan: true);
      expect(cleared.cost, isNull);
      expect(cleared.boughtOn, isNull);
      expect(cleared.securedLoanId, isNull);
    });

    test('only an asset may have a kind', () {
      expect(own('x', AccountType.debit).copyWith(assetKind: AssetKind.vehicle).problem, isNotNull);
    });
  });
}
