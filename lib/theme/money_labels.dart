import 'package:flutter/material.dart';

import '../blocs/money_cubit.dart';
import '../l10n/app_localizations.dart';
import '../models/book_account.dart';
import '../models/book_entry.dart';
import '../models/minor_units.dart';
import '../models/money.dart';
import '../models/money_settings.dart';
import '../models/net_worth.dart';
import 'masking.dart';

/// Names and icons for the money ledger, in the person's language. The
/// ledger stores ids and English names; nothing here is stored.
extension MoneyLabels on AppLocalizations {
  String accountType(AccountType t) => switch (t) {
        AccountType.cash => acctCash,
        AccountType.debit => acctDebit,
        AccountType.holding => sheetHoldings,
        AccountType.asset => acctAsset,
        AccountType.receivable => acctReceivable,
        AccountType.credit => acctCredit,
        AccountType.loan => acctLoan,
        AccountType.payable => acctPayable,
        AccountType.category => acctCategory,
        AccountType.system => acctCategory,
      };

  String sheetGroup(SheetGroup g) => switch (g) {
        SheetGroup.holdings => sheetHoldings,
        SheetGroup.cash => sheetCash,
        SheetGroup.owedToYou => sheetOwedToYou,
        SheetGroup.assets => sheetAssets,
        SheetGroup.cards => sheetCards,
        SheetGroup.loans => sheetLoans,
        SheetGroup.youOwe => sheetYouOwe,
      };

  String assetKind(AssetKind k) => switch (k) {
        AssetKind.property => assetKindProperty,
        AssetKind.vehicle => assetKindVehicle,
        AssetKind.business => assetKindBusiness,
        AssetKind.valuables => assetKindValuables,
        AssetKind.other => assetKindOther,
      };

  String template(EntryTemplate t) => switch (t) {
        EntryTemplate.opening => tplOpening,
        EntryTemplate.spend => tplSpend,
        EntryTemplate.income => tplIncome,
        EntryTemplate.transfer => tplTransfer,
        EntryTemplate.atm => tplAtm,
        EntryTemplate.swap => tplSwap,
        EntryTemplate.cardPayment => tplCardPayment,
        EntryTemplate.loanPayment => tplLoanPayment,
        EntryTemplate.lent => tplLent,
        EntryTemplate.borrowed => tplBorrowed,
        EntryTemplate.repaymentIn => tplRepaymentIn,
        EntryTemplate.repaymentOut => tplRepaymentOut,
        EntryTemplate.refund => tplRefund,
        EntryTemplate.declined => tplDeclined,
        EntryTemplate.cashCount => tplCashCount,
        EntryTemplate.billSplit => tplBillSplit,
        EntryTemplate.valuation => tplValuation,
        EntryTemplate.assetSale => tplAssetSale,
        EntryTemplate.adjustment => tplAdjustment,
      };

  String feature(MoneyFeature f) => switch (f) {
        MoneyFeature.budget => featBudget,
        MoneyFeature.recurring => featRecurring,
        MoneyFeature.people => featPeople,
        MoneyFeature.loans => featLoans,
        MoneyFeature.billSplit => featBillSplit,
        MoneyFeature.zakat => featZakat,
      };

  String featureDetail(MoneyFeature f) => switch (f) {
        MoneyFeature.budget => featBudgetDetail,
        MoneyFeature.recurring => featRecurringDetail,
        MoneyFeature.people => featPeopleDetail,
        MoneyFeature.loans => featLoansDetail,
        MoneyFeature.billSplit => featBillSplitDetail,
        MoneyFeature.zakat => featZakatDetail,
      };

  String homeCard(HomeCard c) => switch (c) {
        HomeCard.needsReview => cardNeedsReview,
        HomeCard.comingUp => cardComingUp,
        HomeCard.leftToSpend => cardLeftToSpend,
        HomeCard.holdings => sheetHoldings,
        HomeCard.accounts => cardAccounts,
        HomeCard.assets => sheetAssets,
        HomeCard.people => featPeople,
        HomeCard.zakat => featZakat,
      };

  /// An account's name as shown: a default category or system account the
  /// person never renamed reads in their language.
  String accountName(BookAccount a) {
    if (!MoneyCubit.isUnrenamedDefault(a) && !a.isSystem) return a.name;
    return switch (a.id) {
      'category.groceries' => catGroceries,
      'category.dining' => catDining,
      'category.transport' => catTransport,
      'category.bills' => catBills,
      'category.shopping' => catShopping,
      'category.health' => catHealth,
      'category.home' => catHome,
      'category.other' => catOther,
      'category.salary' => catSalary,
      'category.other_income' => catOtherIncome,
      'category.interest_and_fees' => catInterestFees,
      'system.opening_balances' => sysOpening,
      'system.change_in_value' => sysChange,
      'system.rounding' => sysRounding,
      _ => a.name,
    };
  }
}

class MoneyIcons {
  static IconData account(BookAccount a) {
    if (a.type == AccountType.asset) return assetKind(a.assetKind ?? AssetKind.other);
    if (a.type == AccountType.category) return category(a.id);
    return type(a.type);
  }

  static IconData type(AccountType t) => switch (t) {
        AccountType.cash => Icons.payments_outlined,
        AccountType.debit => Icons.account_balance_outlined,
        AccountType.holding => Icons.pie_chart_outline,
        AccountType.asset => Icons.home_work_outlined,
        AccountType.receivable => Icons.call_received,
        AccountType.credit => Icons.credit_card,
        AccountType.loan => Icons.request_quote_outlined,
        AccountType.payable => Icons.call_made,
        AccountType.category => Icons.label_outline,
        AccountType.system => Icons.balance,
      };

  static IconData assetKind(AssetKind k) => switch (k) {
        AssetKind.property => Icons.landscape_outlined,
        AssetKind.vehicle => Icons.directions_car_outlined,
        AssetKind.business => Icons.storefront_outlined,
        AssetKind.valuables => Icons.watch_outlined,
        AssetKind.other => Icons.category_outlined,
      };

  static IconData category(String id) => switch (id) {
        'category.groceries' => Icons.local_grocery_store_outlined,
        'category.dining' => Icons.restaurant_outlined,
        'category.transport' => Icons.directions_bus_outlined,
        'category.bills' => Icons.receipt_long_outlined,
        'category.shopping' => Icons.shopping_bag_outlined,
        'category.health' => Icons.favorite_outline,
        'category.home' => Icons.home_outlined,
        'category.salary' => Icons.work_outline,
        'category.interest_and_fees' => Icons.percent,
        _ => Icons.label_outline,
      };

  static IconData template(EntryTemplate t) => switch (t) {
        EntryTemplate.spend || EntryTemplate.declined => Icons.shopping_cart_outlined,
        EntryTemplate.income => Icons.south_west,
        EntryTemplate.transfer || EntryTemplate.atm => Icons.swap_horiz,
        EntryTemplate.swap => Icons.currency_exchange,
        EntryTemplate.cardPayment => Icons.credit_score_outlined,
        EntryTemplate.loanPayment => Icons.request_quote_outlined,
        EntryTemplate.lent || EntryTemplate.repaymentOut => Icons.call_made,
        EntryTemplate.borrowed || EntryTemplate.repaymentIn => Icons.call_received,
        EntryTemplate.refund => Icons.undo,
        EntryTemplate.cashCount => Icons.calculate_outlined,
        EntryTemplate.billSplit => Icons.call_split,
        EntryTemplate.valuation => Icons.trending_up,
        EntryTemplate.assetSale => Icons.sell_outlined,
        EntryTemplate.opening || EntryTemplate.adjustment => Icons.flag_outlined,
      };
}

/// Minor units as money text, masked when balances are hidden.
String minorText(int minor, String currency, {required bool hidden}) => moneyText(MinorUnits.toMajor(minor, currency), currency, hidden: hidden);

/// Money in the book: the currency's own decimals (3.50, not 3.5000).
String moneyText(double amount, String currency, {required bool hidden}) =>
    Masking.amount(Money(amount, currency), hidden: hidden, decimals: MinorUnits.digits(currency));

/// Parses what the person typed ("1,250.5", "1250,50", "١٬٢٥٠٫٥") into minor
/// units of [currency]. Null when it isn't a number.
int? parseMinor(String text, String currency) {
  const eastern = '٠١٢٣٤٥٦٧٨٩';
  var s = text.trim();
  for (var i = 0; i < 10; i++) {
    s = s.replaceAll(eastern[i], '$i');
  }
  s = s.replaceAll('٬', '').replaceAll('٫', '.').replaceAll(' ', '').replaceAll(' ', '');
  // A comma followed by exactly 1 or 2 digits at the end is a decimal comma.
  if (RegExp(r',\d{1,3}$').hasMatch(s) && !s.contains('.') && !RegExp(r',\d{3}$').hasMatch(s)) {
    s = s.replaceAll(',', '.');
  } else {
    s = s.replaceAll(',', '');
  }
  if (s.isEmpty) return null;
  final v = double.tryParse(s);
  if (v == null || v.isNaN || v.isInfinite) return null;
  return MinorUnits.fromMajor(v, currency);
}

/// Minor units as plain text for an editable field ("1250.50").
String minorFieldText(int minor, String currency) {
  final digits = MinorUnits.digits(currency);
  return MinorUnits.toMajor(minor, currency).toStringAsFixed(digits);
}
