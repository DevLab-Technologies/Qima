import 'book_account.dart';

/// The categories every book starts with. Their ids are the same on every
/// device, so two devices seeding at once never make two Groceries. The
/// stored name is English; screens show the person's language for a
/// category whose name was never changed (see `categoryName`).
class DefaultCategories {
  static const spending = <String, String>{
    'category.groceries': 'Groceries',
    'category.dining': 'Dining',
    'category.transport': 'Transport',
    'category.bills': 'Bills',
    'category.shopping': 'Shopping',
    'category.health': 'Health',
    'category.home': 'Home',
    'category.other': 'Other',
  };

  static const income = <String, String>{
    'category.salary': 'Salary',
    'category.other_income': 'Other income',
  };

  static const String other = 'category.other';
  static const String otherIncome = 'category.other_income';

  static List<BookAccount> get all => [
        for (final e in spending.entries) BookAccount(id: e.key, name: e.value, side: AccountSide.spending, type: AccountType.category),
        for (final e in income.entries) BookAccount(id: e.key, name: e.value, side: AccountSide.income, type: AccountType.category),
      ];

  /// The English name a default category was seeded with, or null.
  static String? seededName(String id) => spending[id] ?? income[id] ?? (id == SystemAccount.interestAndFees.id ? SystemAccount.interestAndFees.defaultName : null);
}
