// The demo book every v5 store capture starts from: a made-up household with
// accounts, a card, a loan, a car, land and two people, three months of
// everyday spending, and budgets. Nothing here is anyone's real money.
import 'package:qima/blocs/money_cubit.dart';
import 'package:qima/models/book_account.dart';
import 'package:qima/models/minor_units.dart';
import 'package:qima/models/money_settings.dart';

/// Adds the demo book in [currency], with names in Arabic when [arabic].
/// Runs once per install: a second run finds the demo accounts and stops.
Future<void> seedStoreBook(MoneyCubit money, {required bool arabic, String currency = 'SAR', DateTime? now}) async {
  await money.load();
  if (money.state.book.accounts.containsKey('shot-current')) return;
  await money.markWhatsNewSeen();
  final today = now ?? DateTime.now();
  DateTime monthsAgo(int m, [int day = 1]) => DateTime(today.year, today.month - m, day);
  int c(num major) => MinorUnits.fromMajor(major, currency);
  String t(String en, String ar) => arabic ? ar : en;
  BookAccount account(String id, String en, String ar, AccountType type, {AccountSide side = AccountSide.own}) =>
      BookAccount(id: id, name: t(en, ar), side: side, type: type, currency: currency);

  final current = account('shot-current', 'Current account', 'الحساب الجاري', AccountType.debit);
  final savings = account('shot-savings', 'Savings', 'التوفير', AccountType.debit);
  final cash = account('shot-cash', 'Cash', 'الكاش', AccountType.cash);
  final card = account('shot-card', 'Credit card', 'بطاقة الائتمان', AccountType.credit, side: AccountSide.owe).copyWith(creditLimit: c(20000));
  final loan = account('shot-loan', 'Car loan', 'قرض العربية', AccountType.loan, side: AccountSide.owe);
  final car = account('shot-car', 'Family car', 'عربية العيلة', AccountType.asset)
      .copyWith(assetKind: AssetKind.vehicle, securedLoanId: 'shot-loan', cost: c(118000), boughtOn: DateTime(2024, 2, 1));
  final land = account('shot-land', 'Land plot', 'قطعة الأرض', AccountType.asset).copyWith(assetKind: AssetKind.property, heldForSale: true);

  await money.addAccount(current, opening: c(21400), openedOn: monthsAgo(4));
  await money.addAccount(savings, opening: c(58000), openedOn: monthsAgo(4));
  await money.addAccount(cash, opening: c(900), openedOn: monthsAgo(4));
  await money.addAccount(card, opening: c(2100), openedOn: monthsAgo(4));
  await money.addAccount(loan, opening: c(52000), openedOn: DateTime(2024, 2, 1));
  await money.addAccount(car, opening: c(118000), openedOn: DateTime(2024, 2, 1));
  await money.addAccount(land, opening: c(310000), openedOn: DateTime(2021, 5, 1));
  await money.revalue(land, c(326000), DateTime(2023, 4, 1));
  await money.revalue(land, c(345000), monthsAgo(3, 15));
  await money.revalue(car, c(92000), monthsAgo(2));
  final omar = await money.personAccount(t('Omar', 'عمر'), currency, owesMe: true);
  final sara = await money.personAccount(t('Sara', 'سارة'), currency, owesMe: false);

  final b = money.builder;
  final cats = money.state.book.accounts;
  final groceries = cats['category.groceries']!;
  final dining = cats['category.dining']!;
  final transport = cats['category.transport']!;
  final bills = cats['category.bills']!;
  final shopping = cats['category.shopping']!;
  final health = cats['category.health']!;
  final salary = cats['category.salary']!;
  final market = t('Supermarket', 'السوبر ماركت');
  final cafe = t('Coffee shop', 'الكافيه');
  final fuel = t('Fuel station', 'البنزينة');

  // Three months and this one, the same rhythm with different amounts.
  for (var m = 3; m >= 0; m--) {
    DateTime on(int day) => monthsAgo(m, day);
    bool past(DateTime d) => !d.isAfter(today);
    final wiggle = (m * 37) % 90;
    final entries = [
      b.income(current, salary, c(19500), on(1), merchant: t('Salary', 'المرتب')),
      b.transfer(current, savings, c(3000), on(2)),
      b.spend(current, bills, c(640 + wiggle), on(4), merchant: t('Electricity', 'الكهربا')),
      b.spend(card, groceries, c(512.40 + wiggle), on(5), merchant: market),
      b.spend(card, dining, c(186 + wiggle), on(7), merchant: cafe),
      b.spend(cash, transport, c(140), on(9), merchant: fuel),
      b.spend(card, groceries, c(388.75), on(12), merchant: market),
      b.spend(card, shopping, c(420 + wiggle * 2), on(14), merchant: t('Clothing store', 'محل الهدوم')),
      b.spend(card, dining, c(264.50), on(17), merchant: t('Restaurant', 'المطعم')),
      b.spend(current, health, c(95), on(19), merchant: t('Pharmacy', 'الصيدلية')),
      b.spend(card, groceries, c(455.20 + wiggle), on(21), merchant: market),
      b.loanPayment(current, loan, principal: c(1750), profit: c(230), date: on(24)),
      b.cardPayment(current, card, c(2100 + wiggle), on(25)),
      b.spend(cash, transport, c(150), on(26), merchant: fuel),
    ];
    for (final e in entries) {
      if (past(e.date)) await money.saveEntry(e);
    }
  }
  await money.saveEntry(b.lent(current, omar, c(1500), monthsAgo(1, 10)));
  await money.saveEntry(b.borrowed(cash, sara, c(600), monthsAgo(0, 3)));

  await money.saveRecurring(RecurringPayment(
    id: 'shot-rent', name: t('Rent', 'الإيجار'), amount: c(3500), fromAccountId: current.id, categoryId: 'category.home', dayOfMonth: 27,
  ));
  await money.setBudget('category.groceries', c(2500));
  await money.setBudget('category.dining', c(1200));
  await money.setBudget('category.shopping', c(900));
  await money.setFeatures(MoneyFeature.values.toSet());
}
