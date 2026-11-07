import 'package:equatable/equatable.dart';

import 'book_account.dart' show dayFromJson, dayToJson;
import 'syncable.dart';

/// The parts of Money a person can switch on and off in Settings › Features.
/// Off hides screens, never money: a switched-off feature's amounts still
/// count and still show on the balance sheet.
enum MoneyFeature {
  budget,
  recurring,
  people,
  loans,
  billSplit,
  zakat;

  static MoneyFeature? fromName(String name) {
    for (final f in MoneyFeature.values) {
      if (f.name == name) return f;
    }
    return null;
  }
}

/// The cards Home can show, in their default order. The total is always
/// first and is not in this list, because it can't be moved or hidden.
enum HomeCard {
  needsReview(canHide: false),
  comingUp(canHide: false),
  leftToSpend(feature: MoneyFeature.budget),
  holdings,
  accounts,
  assets,
  people(feature: MoneyFeature.people),
  zakat(feature: MoneyFeature.zakat);

  /// Needs review and Coming up can move but can't be hidden: they show
  /// only when something needs the person.
  final bool canHide;

  /// The feature whose switch adds and removes this card, if any.
  final MoneyFeature? feature;

  const HomeCard({this.canHide = true, this.feature});

  static HomeCard? fromName(String name) {
    for (final c in HomeCard.values) {
      if (c.name == name) return c;
    }
    return null;
  }
}

/// Money's own settings, synced as one record with the other settings:
/// which features are on, how Home is arranged, and the monthly budget.
class MoneySettings extends Equatable implements Syncable {
  static const String recordId = 'money.settings';

  final Set<MoneyFeature> features;

  /// Home's cards in the person's order. A card not listed is shown in its
  /// default place (see [orderedCards]).
  final List<HomeCard> homeOrder;

  /// Cards the person hid. Qima never adds one of these back.
  final Set<HomeCard> hiddenCards;

  /// Monthly budget per spending category id, in minor units of the base
  /// currency the budget was set in ([budgetCurrency]).
  final Map<String, int> budgets;
  final String? budgetCurrency;

  /// The What's new sheet (O.3) has been shown.
  final bool seenWhatsNew;

  /// How often to remind the person to review the values of assets they
  /// value themselves, in months; 0 is off.
  final int valueReviewMonths;

  const MoneySettings({
    this.features = const {},
    this.homeOrder = const [],
    this.hiddenCards = const {},
    this.budgets = const {},
    this.budgetCurrency,
    this.seenWhatsNew = false,
    this.valueReviewMonths = 6,
  });

  @override
  String get id => recordId;

  bool has(MoneyFeature f) => features.contains(f);

  /// Home's cards to show, in order: the person's order first, then any card
  /// they never placed in its default position. Hidden cards and cards whose
  /// feature is off are left out.
  List<HomeCard> get orderedCards {
    final out = <HomeCard>[...homeOrder];
    for (final c in HomeCard.values) {
      if (out.contains(c)) continue;
      // A card the person never placed goes in its default place: after the
      // nearest card before it in the default order that is already placed.
      var at = 0;
      for (var i = c.index - 1; i >= 0; i--) {
        final j = out.indexOf(HomeCard.values[i]);
        if (j >= 0) {
          at = j + 1;
          break;
        }
      }
      out.insert(at, c);
    }
    return out;
  }

  List<HomeCard> get visibleCards => [
        for (final c in orderedCards)
          if (!hiddenCards.contains(c) && (c.feature == null || features.contains(c.feature))) c,
      ];

  MoneySettings copyWith({
    Set<MoneyFeature>? features,
    List<HomeCard>? homeOrder,
    Set<HomeCard>? hiddenCards,
    Map<String, int>? budgets,
    String? budgetCurrency,
    bool? seenWhatsNew,
    int? valueReviewMonths,
  }) =>
      MoneySettings(
        features: features ?? this.features,
        homeOrder: homeOrder ?? this.homeOrder,
        hiddenCards: hiddenCards ?? this.hiddenCards,
        budgets: budgets ?? this.budgets,
        budgetCurrency: budgetCurrency ?? this.budgetCurrency,
        seenWhatsNew: seenWhatsNew ?? this.seenWhatsNew,
        valueReviewMonths: valueReviewMonths ?? this.valueReviewMonths,
      );

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'features': [for (final f in features) f.name],
        'homeOrder': [for (final c in homeOrder) c.name],
        'hidden': [for (final c in hiddenCards) c.name],
        'budgets': budgets,
        if (budgetCurrency != null) 'budgetCurrency': budgetCurrency,
        if (seenWhatsNew) 'seenWhatsNew': true,
        'valueReviewMonths': valueReviewMonths,
      };

  factory MoneySettings.fromJson(Map<String, dynamic> json) {
    List<String> names(String key) => [for (final v in (json[key] as List? ?? const [])) v as String];
    return MoneySettings(
      features: {for (final n in names('features')) ?MoneyFeature.fromName(n)},
      homeOrder: [for (final n in names('homeOrder')) ?HomeCard.fromName(n)],
      hiddenCards: {for (final n in names('hidden')) ?HomeCard.fromName(n)},
      budgets: {for (final e in ((json['budgets'] as Map?) ?? const {}).entries) e.key as String: (e.value as num).toInt()},
      budgetCurrency: json['budgetCurrency'] as String?,
      seenWhatsNew: json['seenWhatsNew'] as bool? ?? false,
      valueReviewMonths: (json['valueReviewMonths'] as num?)?.toInt() ?? 6,
    );
  }

  @override
  List<Object?> get props => [features, homeOrder, hiddenCards, budgets, budgetCurrency, seenWhatsNew, valueReviewMonths];
}

/// A payment that comes back every month, shown in Coming up until it is
/// recorded for that month.
class RecurringPayment extends Equatable implements Syncable {
  @override
  final String id;
  final String name;

  /// Minor units of [fromAccountId]'s currency.
  final int amount;
  final String fromAccountId;
  final String categoryId;

  /// Day of the month it is due, 1 to 28 (later days fall on the 28th so
  /// every month has one).
  final int dayOfMonth;

  /// The last month (first day) it was recorded for.
  final DateTime? lastPaid;

  const RecurringPayment({
    required this.id,
    required this.name,
    required this.amount,
    required this.fromAccountId,
    required this.categoryId,
    required this.dayOfMonth,
    this.lastPaid,
  });

  /// The next due date on or after the month after [lastPaid], or this
  /// month's when it was never paid.
  DateTime nextDue(DateTime today) {
    final base = lastPaid == null ? DateTime(today.year, today.month) : DateTime(lastPaid!.year, lastPaid!.month + 1);
    return DateTime(base.year, base.month, dayOfMonth.clamp(1, 28));
  }

  RecurringPayment copyWith({String? name, int? amount, String? fromAccountId, String? categoryId, int? dayOfMonth, DateTime? lastPaid}) =>
      RecurringPayment(
        id: id,
        name: name ?? this.name,
        amount: amount ?? this.amount,
        fromAccountId: fromAccountId ?? this.fromAccountId,
        categoryId: categoryId ?? this.categoryId,
        dayOfMonth: dayOfMonth ?? this.dayOfMonth,
        lastPaid: lastPaid ?? this.lastPaid,
      );

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'amount': amount,
        'from': fromAccountId,
        'category': categoryId,
        'day': dayOfMonth,
        if (lastPaid != null) 'lastPaid': dayToJson(lastPaid!),
      };

  factory RecurringPayment.fromJson(Map<String, dynamic> json) => RecurringPayment(
        id: json['id'] as String,
        name: json['name'] as String,
        amount: json['amount'] as int,
        fromAccountId: json['from'] as String,
        categoryId: json['category'] as String,
        dayOfMonth: json['day'] as int,
        lastPaid: json['lastPaid'] == null ? null : dayFromJson(json['lastPaid'] as String),
      );

  @override
  List<Object?> get props => [id, name, amount, fromAccountId, categoryId, dayOfMonth, lastPaid];
}
