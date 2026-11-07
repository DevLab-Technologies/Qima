import 'package:equatable/equatable.dart';

import 'syncable.dart';

/// Which side of the person's books an account sits on.
///
/// Lines are stored debit-positive: a positive line raises an [own] or
/// [spending] account and lowers an [owe], [worth] or [income] account.
/// People never see that convention; [shownSign] turns a stored balance
/// into the figure the screens show, where every side reads as a positive
/// amount when it has something in it.
enum AccountSide {
  /// Something the person owns: cash, bank, holdings, money owed to them,
  /// assets they value themselves.
  own,

  /// Something the person owes: cards, loans, money they owe people.
  owe,

  /// The part of net worth no single account explains: opening balances,
  /// changes in value, rounding. Never income or spending.
  worth,

  /// Money coming in, by category.
  income,

  /// Money going out, by category. Only lines here count as spending.
  spending;

  /// +1 when a positive (debit) line raises the figure shown for an account
  /// on this side, -1 when it lowers it.
  int get shownSign => (this == own || this == spending) ? 1 : -1;

  /// On the balance sheet: what you own and what you owe.
  bool get onBalanceSheet => this == own || this == owe;

  /// Balance-sheet accounts hold one currency; flow and worth accounts
  /// collect lines in any currency and keep a balance per currency.
  bool get hasFixedCurrency => onBalanceSheet;

  static AccountSide fromName(String name) => AccountSide.values.byName(name);
}

/// What kind of thing an account is. The type decides its icon, its screen
/// and which side it may sit on.
enum AccountType {
  cash(AccountSide.own),
  debit(AccountSide.own),
  holding(AccountSide.own),
  asset(AccountSide.own),
  receivable(AccountSide.own),
  credit(AccountSide.owe),
  loan(AccountSide.owe),
  payable(AccountSide.owe),

  /// An income or spending category; its side says which.
  category(null),

  /// Opening balances, Change in value and Rounding.
  system(AccountSide.worth);

  /// The only side this type may sit on, or null for [category], which may
  /// be [AccountSide.income] or [AccountSide.spending].
  final AccountSide? side;

  const AccountType(this.side);

  bool allows(AccountSide s) => side == null ? (s == AccountSide.income || s == AccountSide.spending) : side == s;

  static AccountType fromName(String name) => AccountType.values.byName(name);
}

/// The accounts every book has, with ids that are the same on every device
/// so two devices never create two Rounding accounts.
enum SystemAccount {
  openingBalances('system.opening_balances', 'Opening balances', AccountSide.worth, AccountType.system),
  changeInValue('system.change_in_value', 'Change in value', AccountSide.worth, AccountType.system),
  rounding('system.rounding', 'Rounding', AccountSide.worth, AccountType.system),

  /// Loan profit always goes here, so the budget shows it as spending and
  /// the principal never does.
  interestAndFees('category.interest_and_fees', 'Interest & fees', AccountSide.spending, AccountType.category);

  final String id;
  final String defaultName;
  final AccountSide side;
  final AccountType type;

  const SystemAccount(this.id, this.defaultName, this.side, this.type);

  BookAccount get account => BookAccount(id: id, name: defaultName, side: side, type: type);
}

/// The five kinds of asset a person values themselves. The kind sets the
/// icon and the questions asked; the form is otherwise the same.
enum AssetKind {
  property,
  vehicle,
  business,
  valuables,
  other;

  static AssetKind? fromName(String? name) {
    for (final k in AssetKind.values) {
      if (k.name == name) return k;
    }
    return null;
  }
}

/// One account in the money ledger. Its balance is never stored: it is the
/// sum of the lines posted to it.
class BookAccount extends Equatable implements Syncable {
  @override
  final String id;
  final String name;
  final AccountSide side;
  final AccountType type;

  /// The one currency a balance-sheet account holds. Null for income,
  /// spending and worth accounts, which keep a balance per currency.
  final String? currency;

  /// Off leaves the account out of net worth (for example, a car the person
  /// doesn't want counted). Its lines still balance.
  final bool countsInNetWorth;
  final bool archived;

  /// For an asset: what kind it is.
  final AssetKind? assetKind;

  /// For an asset: the day it was bought, if the person said.
  final DateTime? boughtOn;

  /// For an asset: the price paid, in minor units of [currency], if known.
  final int? cost;

  /// For an asset: the loan secured on it, so its page can show what part
  /// is the person's own.
  final String? securedLoanId;

  /// For an asset: "Held for sale" counts it for zakat at its value.
  final bool heldForSale;

  /// For a card: its limit, in minor units of [currency].
  final int? creditLimit;
  final String note;

  const BookAccount({
    required this.id,
    required this.name,
    required this.side,
    required this.type,
    this.currency,
    this.countsInNetWorth = true,
    this.archived = false,
    this.assetKind,
    this.boughtOn,
    this.cost,
    this.securedLoanId,
    this.heldForSale = false,
    this.creditLimit,
    this.note = '',
  });

  /// Why this account can't be used, or null when it is sound.
  String? get problem {
    if (!type.allows(side)) return 'A ${type.name} account can’t sit on the ${side.name} side.';
    if (side.hasFixedCurrency && (currency == null || currency!.isEmpty)) return 'A ${side.name} account needs a currency.';
    if (!side.hasFixedCurrency && currency != null) return 'A ${side.name} account keeps every currency, so it takes none.';
    if (assetKind != null && type != AccountType.asset) return 'Only an asset has a kind.';
    return null;
  }

  bool get isSystem => type == AccountType.system || SystemAccount.values.any((s) => s.id == id);

  /// [clearX] flags set an optional field back to null, which a plain null
  /// argument can't.
  BookAccount copyWith({
    String? name,
    bool? countsInNetWorth,
    bool? archived,
    AssetKind? assetKind,
    DateTime? boughtOn,
    bool clearBoughtOn = false,
    int? cost,
    bool clearCost = false,
    String? securedLoanId,
    bool clearSecuredLoan = false,
    bool? heldForSale,
    int? creditLimit,
    bool clearCreditLimit = false,
    String? note,
  }) =>
      BookAccount(
        id: id,
        name: name ?? this.name,
        side: side,
        type: type,
        currency: currency,
        countsInNetWorth: countsInNetWorth ?? this.countsInNetWorth,
        archived: archived ?? this.archived,
        assetKind: assetKind ?? this.assetKind,
        boughtOn: clearBoughtOn ? null : (boughtOn ?? this.boughtOn),
        cost: clearCost ? null : (cost ?? this.cost),
        securedLoanId: clearSecuredLoan ? null : (securedLoanId ?? this.securedLoanId),
        heldForSale: heldForSale ?? this.heldForSale,
        creditLimit: clearCreditLimit ? null : (creditLimit ?? this.creditLimit),
        note: note ?? this.note,
      );

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'side': side.name,
        'type': type.name,
        if (currency != null) 'currency': currency,
        if (!countsInNetWorth) 'countsInNetWorth': false,
        if (archived) 'archived': true,
        if (assetKind != null) 'assetKind': assetKind!.name,
        if (boughtOn != null) 'boughtOn': dayToJson(boughtOn!),
        if (cost != null) 'cost': cost,
        if (securedLoanId != null) 'securedLoan': securedLoanId,
        if (heldForSale) 'heldForSale': true,
        if (creditLimit != null) 'creditLimit': creditLimit,
        if (note.isNotEmpty) 'note': note,
      };

  factory BookAccount.fromJson(Map<String, dynamic> json) => BookAccount(
        id: json['id'] as String,
        name: json['name'] as String,
        side: AccountSide.fromName(json['side'] as String),
        type: AccountType.fromName(json['type'] as String),
        currency: json['currency'] as String?,
        countsInNetWorth: json['countsInNetWorth'] as bool? ?? true,
        archived: json['archived'] as bool? ?? false,
        assetKind: AssetKind.fromName(json['assetKind'] as String?),
        boughtOn: json['boughtOn'] == null ? null : dayFromJson(json['boughtOn'] as String),
        cost: json['cost'] as int?,
        securedLoanId: json['securedLoan'] as String?,
        heldForSale: json['heldForSale'] as bool? ?? false,
        creditLimit: json['creditLimit'] as int?,
        note: json['note'] as String? ?? '',
      );

  @override
  List<Object?> get props =>
      [id, name, side, type, currency, countsInNetWorth, archived, assetKind, boughtOn, cost, securedLoanId, heldForSale, creditLimit, note];
}

/// A calendar day as `yyyy-MM-dd`, so it is the same day on a device in
/// another time zone (an instant would move it across midnight).
String dayToJson(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// Reads [dayToJson]'s form, or an instant written by an earlier build.
DateTime dayFromJson(String s) {
  final d = DateTime.parse(s);
  final local = s.length == 10 ? d : d.toLocal();
  return DateTime(local.year, local.month, local.day);
}
