import 'package:equatable/equatable.dart';

import 'asset.dart';
import 'deterministic_uuid.dart';
import 'instrument_catalog.dart';
import 'metal_breakdown.dart';
import 'money_settings.dart';
import 'watch_card.dart';

/// "How do you want to use Qima?" Each choice decides which later questions
/// are asked and what the app shows first.
enum SetupUse { money, portfolio, prices, netWorth, zakat }

/// "What do you invest in or follow?" Drives the suggested watchlist.
enum SetupProduct { metals, stocks, currencies, crypto, indices, property }

/// "What do you want from your money?"
enum SetupGoal { whereItGoes, saveMore, budget, bills, people }

/// "How will you add your spending?"
enum SetupCapture { typeOrSay, bankMessages, statement }

/// The setup screens, in the order they can appear.
enum SetupStep { welcome, currency, uses, products, prices, goals, capture, summary }

/// The guided tour's stops, in order.
enum TourStop { tabs, add, money, prices }

/// The first steps listed on Home's Get started card.
enum StartTask { account, transaction, holding, asset, alert, bankMessages }

/// A price offered on the "Start with these prices" screen.
class SetupSuggestion extends Equatable {
  final WatchCard card;

  /// Ticked when the screen opens.
  final bool preselected;

  const SetupSuggestion(this.card, {this.preselected = true});

  /// Names this suggestion among the ones offered together, whatever the
  /// main currency: the instrument and, for gold, its karat. (The card's id
  /// and unit follow the currency, so they change when it does.)
  String get key => '${card.instrumentID}.${card.karat?.rawValue ?? 0}';

  @override
  List<Object?> get props => [card, preselected];
}

/// What the person answered in setup, kept on this device so the tour, the
/// Get started card and "Run setup again" can follow it. Everything the app
/// does with the answers is worked out here, with no widgets involved.
class SetupAnswers extends Equatable {
  final Set<SetupUse> uses;
  final Set<SetupProduct> products;
  final Set<SetupGoal> goals;
  final Set<SetupCapture> captures;

  const SetupAnswers({
    this.uses = const {},
    this.products = const {},
    this.goals = const {},
    this.captures = const {},
  });

  /// The portfolio questions follow "Manage my portfolio" or "Watch prices".
  bool get asksProducts => uses.contains(SetupUse.portfolio) || uses.contains(SetupUse.prices);

  /// The money questions follow "Manage my money".
  bool get asksMoney => uses.contains(SetupUse.money);

  /// Whether any chosen product has prices to suggest (property has none).
  bool get hasPricedProducts => asksProducts && products.any((p) => p != SetupProduct.property);

  /// The screens this set of answers leads through. With both branches, the
  /// portfolio questions come first.
  List<SetupStep> get steps => [
        SetupStep.welcome,
        SetupStep.currency,
        SetupStep.uses,
        if (asksProducts) SetupStep.products,
        if (hasPricedProducts) SetupStep.prices,
        if (asksMoney) ...[SetupStep.goals, SetupStep.capture],
        SetupStep.summary,
      ];

  /// Answers to questions that are no longer asked are dropped, so going
  /// back and unticking "Manage my money" leaves no goals behind.
  SetupAnswers get pruned => SetupAnswers(
        uses: uses,
        products: asksProducts ? products : const {},
        goals: asksMoney ? goals : const {},
        captures: asksMoney ? captures : const {},
      );

  /// The features these answers switch on. Setup only ever adds features.
  Set<MoneyFeature> get features => {
        if (asksMoney && goals.contains(SetupGoal.budget)) MoneyFeature.budget,
        if (asksMoney && goals.contains(SetupGoal.bills)) MoneyFeature.recurring,
        if (asksMoney && goals.contains(SetupGoal.people)) MoneyFeature.people,
        if (uses.contains(SetupUse.zakat)) MoneyFeature.zakat,
      };

  /// The tab the app opens on: Money or Prices when that is the only thing
  /// the person came for, otherwise Home.
  int get startTab {
    if (uses.length != 1) return 0;
    return switch (uses.single) {
      SetupUse.money => 1,
      SetupUse.prices => 2,
      _ => 0,
    };
  }

  /// The tour's stops. Stops for areas the person did not choose are left
  /// out; with no answers at all (a replay by someone who skipped setup)
  /// every stop shows.
  List<TourStop> get tourStops => [
        TourStop.tabs,
        TourStop.add,
        if (uses.isEmpty || asksMoney) TourStop.money,
        if (uses.isEmpty || asksProducts) TourStop.prices,
      ];

  /// The first steps for Home's Get started card.
  List<StartTask> get tasks => [
        if (asksMoney || uses.contains(SetupUse.netWorth)) StartTask.account,
        if (asksMoney) StartTask.transaction,
        if (uses.contains(SetupUse.portfolio)) StartTask.holding,
        if (uses.contains(SetupUse.netWorth) || (asksProducts && products.contains(SetupProduct.property))) StartTask.asset,
        if (asksProducts) StartTask.alert,
        if (asksMoney && captures.contains(SetupCapture.bankMessages)) StartTask.bankMessages,
      ];

  /// Currencies whose gold is bought by the gram, and the karat most sold
  /// there next to 24K.
  static const Map<String, GoldKarat> _gramMarkets = {
    'EGP': GoldKarat.k21,
    'SAR': GoldKarat.k21,
    'JOD': GoldKarat.k21,
    'AED': GoldKarat.k22,
    'KWD': GoldKarat.k22,
    'QAR': GoldKarat.k22,
    'BHD': GoldKarat.k22,
    'OMR': GoldKarat.k22,
  };

  /// The prices to offer for these products, shown in [currency]. Built
  /// only from the catalog, so every one has a price feed. The same
  /// instrument is never offered twice in one shape.
  List<SetupSuggestion> suggestions(String currency) {
    if (!asksProducts) return const [];
    final out = <SetupSuggestion>[];
    void offer(String instrumentID, {PriceUnit? unit, GoldKarat? karat, bool preselected = true}) {
      final instrument = InstrumentCatalog.instrument(instrumentID);
      if (instrument == null) return;
      final u = unit ?? instrument.quotation.defaultUnit;
      final card = WatchCard(
        id: deterministicUuid('setup.$instrumentID.$currency.${u.name}.${karat?.rawValue ?? 0}'),
        instrumentID: instrumentID,
        currency: currency,
        unit: u,
        karat: karat,
      );
      if (out.any((s) => s.card.isSameCombo(card))) return;
      out.add(SetupSuggestion(card, preselected: preselected));
    }

    if (products.contains(SetupProduct.metals)) {
      final local = _gramMarkets[currency];
      if (local != null) {
        // 24K is stored with no karat, as the add flow does.
        offer('metal.XAU', unit: PriceUnit.gram);
        offer('metal.XAU', unit: PriceUnit.gram, karat: local);
        offer('metal.XAG', unit: PriceUnit.gram, preselected: false);
      } else {
        offer('metal.XAU');
        offer('metal.XAG', preselected: false);
      }
    }
    if (products.contains(SetupProduct.currencies)) {
      final order = _gramMarkets.containsKey(currency) ? const ['USD', 'SAR', 'AED', 'EUR', 'GBP'] : const ['USD', 'EUR', 'GBP', 'SAR', 'AED'];
      final others = [for (final c in order) if (c != currency) c].take(3).toList();
      for (final (i, c) in others.indexed) {
        offer('fx.$c', preselected: i < 2);
      }
    }
    if (products.contains(SetupProduct.stocks)) {
      offer('index.GSPC');
      offer('stock.AAPL', preselected: false);
      offer('stock.NVDA', preselected: false);
    }
    if (products.contains(SetupProduct.indices)) {
      offer('index.GSPC');
      offer('index.IXIC', preselected: false);
    }
    if (products.contains(SetupProduct.crypto)) {
      offer('crypto.BTC');
      offer('crypto.ETH', preselected: false);
    }
    return out;
  }

  SetupAnswers copyWith({
    Set<SetupUse>? uses,
    Set<SetupProduct>? products,
    Set<SetupGoal>? goals,
    Set<SetupCapture>? captures,
  }) =>
      SetupAnswers(
        uses: uses ?? this.uses,
        products: products ?? this.products,
        goals: goals ?? this.goals,
        captures: captures ?? this.captures,
      );

  Map<String, dynamic> toJson() => {
        'uses': [for (final v in uses) v.name],
        'products': [for (final v in products) v.name],
        'goals': [for (final v in goals) v.name],
        'captures': [for (final v in captures) v.name],
      };

  /// Unknown names (an answer a later version added) are ignored.
  factory SetupAnswers.fromJson(Map<String, dynamic> json) {
    Set<T> read<T extends Enum>(String key, List<T> values) => {
          for (final n in (json[key] as List? ?? const []))
            for (final v in values)
              if (v.name == n) v,
        };
    return SetupAnswers(
      uses: read('uses', SetupUse.values),
      products: read('products', SetupProduct.values),
      goals: read('goals', SetupGoal.values),
      captures: read('captures', SetupCapture.values),
    );
  }

  @override
  List<Object?> get props => [uses, products, goals, captures];
}
