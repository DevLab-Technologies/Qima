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

  /// SHA-256 of files already imported, newest last, so the same statement
  /// shared twice (here or on another device) is skipped.
  final List<String> importedHashes;

  static const int keptHashes = 400;

  /// Categories the person picked for merchants, by rule key ("out:panda"
  /// to a category id). Imports use them first; Categories lists them.
  final Map<String, String> categoryRules;

  const MoneySettings({
    this.features = const {},
    this.homeOrder = const [],
    this.hiddenCards = const {},
    this.budgets = const {},
    this.budgetCurrency,
    this.seenWhatsNew = false,
    this.valueReviewMonths = 6,
    this.importedHashes = const [],
    this.categoryRules = const {},
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
    List<String>? importedHashes,
    Map<String, String>? categoryRules,
  }) =>
      MoneySettings(
        features: features ?? this.features,
        homeOrder: homeOrder ?? this.homeOrder,
        hiddenCards: hiddenCards ?? this.hiddenCards,
        budgets: budgets ?? this.budgets,
        budgetCurrency: budgetCurrency ?? this.budgetCurrency,
        seenWhatsNew: seenWhatsNew ?? this.seenWhatsNew,
        valueReviewMonths: valueReviewMonths ?? this.valueReviewMonths,
        importedHashes: importedHashes ?? this.importedHashes,
        categoryRules: categoryRules ?? this.categoryRules,
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
        if (importedHashes.isNotEmpty) 'imported': importedHashes,
        if (categoryRules.isNotEmpty) 'categoryRules': categoryRules,
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
      importedHashes: names('imported'),
      categoryRules: {for (final e in ((json['categoryRules'] as Map?) ?? const {}).entries) e.key as String: e.value as String},
    );
  }

  @override
  List<Object?> get props => [features, homeOrder, hiddenCards, budgets, budgetCurrency, seenWhatsNew, valueReviewMonths, importedHashes, categoryRules];
}

/// How often a planned payment comes back.
enum PlanRepeat {
  once,
  weekly,
  monthly,
  quarterly,
  yearly;

  static PlanRepeat fromName(String? name) => PlanRepeat.values.firstWhere((r) => r.name == name, orElse: () => PlanRepeat.monthly);
}

/// A planned payment: money going out (rent, a bill, an installment) or
/// coming in (salary), once or on a repeat, shown in Coming up until it is
/// recorded. Nothing is posted until the person marks it paid.
class RecurringPayment extends Equatable implements Syncable {
  @override
  final String id;
  final String name;

  /// Minor units of [fromAccountId]'s currency.
  final int amount;

  /// The account it is paid from, or paid into when [incoming].
  final String fromAccountId;

  /// A spending category, or an income one when [incoming].
  final String categoryId;

  final PlanRepeat repeat;

  /// The first due date; every later one is counted from it, so a monthly
  /// payment on the 31st falls on the last day of shorter months and comes
  /// back to the 31st.
  final DateTime start;

  /// How many payments in all ("4" for an installment plan); null for no
  /// end. A one-off is always 1.
  final int? times;

  /// How many have been recorded or skipped.
  final int paid;

  /// Money coming in rather than going out.
  final bool incoming;

  /// Whether to post a reminder the day before it is due.
  final bool remind;

  RecurringPayment({
    required this.id,
    required this.name,
    required this.amount,
    required this.fromAccountId,
    required this.categoryId,
    this.repeat = PlanRepeat.monthly,
    DateTime? start,
    int? times,
    int? paid,
    this.incoming = false,
    this.remind = true,
    // The first version's fields: a day of the month and the last month
    // paid, read into [start] and [paid].
    int? dayOfMonth,
    DateTime? lastPaid,
  })  : start = start ?? _legacyStart(dayOfMonth ?? 1, lastPaid),
        times = repeat == PlanRepeat.once ? 1 : times,
        paid = paid ?? (start == null && lastPaid != null ? 1 : 0);

  static DateTime _legacyStart(int day, DateTime? lastPaid) {
    final month = lastPaid ?? DateTime.now();
    return DateTime(month.year, month.month, _clampDay(month.year, month.month, day));
  }

  static int _clampDay(int year, int month, int day) => day.clamp(1, DateTime(year, month + 1, 0).day);

  /// The day of the month it falls on (for monthly and longer repeats).
  int get dayOfMonth => start.day;

  /// The [k]th due date, from 0.
  DateTime dueAt(int k) {
    final months = switch (repeat) {
      PlanRepeat.monthly => 1,
      PlanRepeat.quarterly => 3,
      PlanRepeat.yearly => 12,
      _ => 0,
    };
    if (repeat == PlanRepeat.weekly) return DateTime(start.year, start.month, start.day + 7 * k);
    if (months == 0) return start;
    final y = start.year, m = start.month + months * k;
    return DateTime(y, m, _clampDay(DateTime(y, m).year, DateTime(y, m).month, start.day));
  }

  /// Every payment has been recorded or skipped.
  bool get finished => times != null && paid >= times!;

  /// The next one still to record (possibly overdue); null when [finished].
  DateTime? get next => finished ? null : dueAt(paid);

  /// [next], for callers that only handle open plans. [today] is unused and
  /// kept for the first version's callers.
  DateTime nextDue([DateTime? today]) => dueAt(paid);

  /// The open due dates up to and including [until], from the next one.
  List<DateTime> dueThrough(DateTime until) => [
        for (var k = paid; (times == null || k < times!) && !dueAt(k).isAfter(until); k++) dueAt(k),
      ];

  /// Payments left after this one is recorded, for "2 of 4 left".
  int? get left => times == null ? null : times! - paid;

  RecurringPayment copyWith({
    String? name,
    int? amount,
    String? fromAccountId,
    String? categoryId,
    PlanRepeat? repeat,
    DateTime? start,
    int? times,
    bool clearTimes = false,
    int? paid,
    bool? incoming,
    bool? remind,
  }) =>
      RecurringPayment(
        id: id,
        name: name ?? this.name,
        amount: amount ?? this.amount,
        fromAccountId: fromAccountId ?? this.fromAccountId,
        categoryId: categoryId ?? this.categoryId,
        repeat: repeat ?? this.repeat,
        start: start ?? this.start,
        times: clearTimes ? null : (times ?? this.times),
        paid: paid ?? this.paid,
        incoming: incoming ?? this.incoming,
        remind: remind ?? this.remind,
      );

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'amount': amount,
        'from': fromAccountId,
        'category': categoryId,
        'repeat': repeat.name,
        'start': dayToJson(start),
        if (times != null) 'times': times,
        'paid': paid,
        if (incoming) 'incoming': true,
        if (!remind) 'remind': false,
      };

  factory RecurringPayment.fromJson(Map<String, dynamic> json) => RecurringPayment(
        id: json['id'] as String,
        name: json['name'] as String,
        amount: json['amount'] as int,
        fromAccountId: json['from'] as String,
        categoryId: json['category'] as String,
        repeat: PlanRepeat.fromName(json['repeat'] as String?),
        start: json['start'] == null ? null : dayFromJson(json['start'] as String),
        times: json['times'] as int?,
        paid: json['paid'] as int?,
        incoming: json['incoming'] as bool? ?? false,
        remind: json['remind'] as bool? ?? true,
        dayOfMonth: json['day'] as int?,
        lastPaid: json['lastPaid'] == null ? null : dayFromJson(json['lastPaid'] as String),
      );

  @override
  List<Object?> get props => [id, name, amount, fromAccountId, categoryId, repeat, start, times, paid, incoming, remind];
}
