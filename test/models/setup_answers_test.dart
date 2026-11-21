import 'package:flutter_test/flutter_test.dart';
import 'package:qima/models/asset.dart';
import 'package:qima/models/metal_breakdown.dart';
import 'package:qima/models/money_settings.dart';
import 'package:qima/models/setup_answers.dart';

/// What the setup answers lead to: which screens are asked, which features
/// turn on, which prices are suggested, and what the tour and the Get
/// started card show.
void main() {
  group('steps', () {
    test('with no use chosen yet, only the questions everyone gets', () {
      expect(const SetupAnswers().steps, [SetupStep.welcome, SetupStep.currency, SetupStep.uses, SetupStep.summary]);
    });

    test('net worth or zakat alone adds no questions', () {
      const answers = SetupAnswers(uses: {SetupUse.netWorth, SetupUse.zakat});
      expect(answers.steps, [SetupStep.welcome, SetupStep.currency, SetupStep.uses, SetupStep.summary]);
    });

    test('portfolio or prices asks what is followed, then offers prices', () {
      for (final use in [SetupUse.portfolio, SetupUse.prices]) {
        final answers = SetupAnswers(uses: {use}, products: const {SetupProduct.metals});
        expect(answers.steps, [SetupStep.welcome, SetupStep.currency, SetupStep.uses, SetupStep.products, SetupStep.prices, SetupStep.summary]);
      }
    });

    test('the prices screen is left out until a product with prices is chosen', () {
      expect(const SetupAnswers(uses: {SetupUse.prices}).steps, isNot(contains(SetupStep.prices)));
      expect(const SetupAnswers(uses: {SetupUse.prices}, products: {SetupProduct.property}).steps, isNot(contains(SetupStep.prices)));
    });

    test('money asks for goals and how spending is added', () {
      const answers = SetupAnswers(uses: {SetupUse.money});
      expect(answers.steps, [SetupStep.welcome, SetupStep.currency, SetupStep.uses, SetupStep.goals, SetupStep.capture, SetupStep.summary]);
    });

    test('with both branches, the portfolio questions come first and all eight screens show', () {
      const answers = SetupAnswers(uses: {SetupUse.money, SetupUse.portfolio}, products: {SetupProduct.stocks});
      expect(answers.steps, SetupStep.values);
    });
  });

  group('features', () {
    test('each goal turns on its feature, and zakat its own', () {
      const answers = SetupAnswers(
        uses: {SetupUse.money, SetupUse.zakat},
        goals: {SetupGoal.budget, SetupGoal.bills, SetupGoal.people, SetupGoal.saveMore, SetupGoal.whereItGoes},
      );
      expect(answers.features, {MoneyFeature.budget, MoneyFeature.recurring, MoneyFeature.people, MoneyFeature.zakat});
    });

    test('goals left over from an unticked "Manage my money" turn nothing on', () {
      const answers = SetupAnswers(uses: {SetupUse.prices}, goals: {SetupGoal.budget}, captures: {SetupCapture.bankMessages});
      expect(answers.features, isEmpty);
      expect(answers.pruned.goals, isEmpty);
      expect(answers.pruned.captures, isEmpty);
      expect(answers.tasks, isNot(contains(StartTask.bankMessages)));
    });

    test('products left over from an unticked portfolio are dropped', () {
      const answers = SetupAnswers(uses: {SetupUse.money}, products: {SetupProduct.metals});
      expect(answers.pruned.products, isEmpty);
      expect(answers.suggestions('USD'), isEmpty);
    });
  });

  group('start tab', () {
    test('Money or Prices only when that is the single reason for Qima', () {
      expect(const SetupAnswers(uses: {SetupUse.money}).startTab, 1);
      expect(const SetupAnswers(uses: {SetupUse.prices}).startTab, 2);
      expect(const SetupAnswers(uses: {SetupUse.portfolio}).startTab, 0);
      expect(const SetupAnswers(uses: {SetupUse.money, SetupUse.prices}).startTab, 0);
      expect(const SetupAnswers().startTab, 0);
    });
  });

  group('tour stops', () {
    test('every stop when nothing was answered', () {
      expect(const SetupAnswers().tourStops, TourStop.values);
    });

    test('stops for areas not chosen are left out', () {
      expect(const SetupAnswers(uses: {SetupUse.money}).tourStops, [TourStop.tabs, TourStop.add, TourStop.money]);
      expect(const SetupAnswers(uses: {SetupUse.prices}).tourStops, [TourStop.tabs, TourStop.add, TourStop.prices]);
      expect(const SetupAnswers(uses: {SetupUse.netWorth}).tourStops, [TourStop.tabs, TourStop.add]);
    });
  });

  group('tasks', () {
    test('follow the uses', () {
      expect(const SetupAnswers(uses: {SetupUse.money}).tasks, [StartTask.account, StartTask.transaction]);
      expect(const SetupAnswers(uses: {SetupUse.portfolio}).tasks, [StartTask.holding, StartTask.alert]);
      expect(const SetupAnswers(uses: {SetupUse.prices}).tasks, [StartTask.alert]);
      expect(const SetupAnswers(uses: {SetupUse.netWorth}).tasks, [StartTask.account, StartTask.asset]);
      expect(const SetupAnswers(uses: {SetupUse.zakat}).tasks, isEmpty);
    });

    test('property adds an asset, and bank messages their own step', () {
      const answers = SetupAnswers(
        uses: {SetupUse.money, SetupUse.portfolio},
        products: {SetupProduct.property},
        captures: {SetupCapture.bankMessages},
      );
      expect(answers.tasks, [StartTask.account, StartTask.transaction, StartTask.holding, StartTask.asset, StartTask.alert, StartTask.bankMessages]);
    });
  });

  group('suggestions', () {
    SetupAnswers following(Set<SetupProduct> products) => SetupAnswers(uses: const {SetupUse.prices}, products: products);

    test('gold by the gram with the local karat where gold is bought that way', () {
      final egp = following({SetupProduct.metals}).suggestions('EGP');
      expect([for (final s in egp) (s.card.instrumentID, s.card.unit, s.card.karat, s.preselected)], [
        ('metal.XAU', PriceUnit.gram, null, true),
        ('metal.XAU', PriceUnit.gram, GoldKarat.k21, true),
        ('metal.XAG', PriceUnit.gram, null, false),
      ]);
      expect(following({SetupProduct.metals}).suggestions('AED')[1].card.karat, GoldKarat.k22);
      expect(egp.every((s) => s.card.currency == 'EGP'), isTrue);
    });

    test('gold by the ounce elsewhere', () {
      final usd = following({SetupProduct.metals}).suggestions('USD');
      expect([for (final s in usd) (s.card.instrumentID, s.card.unit, s.card.karat)], [
        ('metal.XAU', PriceUnit.troyOunce, null),
        ('metal.XAG', PriceUnit.troyOunce, null),
      ]);
    });

    test('currencies never offer the main currency against itself', () {
      final sar = following({SetupProduct.currencies}).suggestions('SAR');
      expect([for (final s in sar) s.card.instrumentID], ['fx.USD', 'fx.AED', 'fx.EUR']);
      expect([for (final s in sar) s.preselected], [true, true, false]);
      final usd = following({SetupProduct.currencies}).suggestions('USD');
      expect([for (final s in usd) s.card.instrumentID], ['fx.EUR', 'fx.GBP', 'fx.SAR']);
    });

    test('an instrument two products share is offered once', () {
      final both = following({SetupProduct.stocks, SetupProduct.indices}).suggestions('USD');
      expect([for (final s in both) s.card.instrumentID].where((id) => id == 'index.GSPC'), hasLength(1));
    });

    test('ids are stable, so running setup twice offers the same cards', () {
      final a = following({SetupProduct.metals, SetupProduct.crypto}).suggestions('EGP');
      final b = following({SetupProduct.metals, SetupProduct.crypto}).suggestions('EGP');
      expect([for (final s in a) s.card.id], [for (final s in b) s.card.id]);
      expect({for (final s in a) s.card.id}, hasLength(a.length));
    });

    test('a suggestion keeps its key when the main currency changes', () {
      final egp = following({SetupProduct.metals, SetupProduct.crypto}).suggestions('EGP');
      final usd = following({SetupProduct.metals, SetupProduct.crypto}).suggestions('USD');
      expect({for (final s in egp) s.key}, hasLength(egp.length));
      expect({for (final s in egp) s.key}, containsAll({for (final s in usd) s.key}));
      expect([for (final s in egp) s.card.id], isNot(contains(usd.first.card.id)));
    });

    test('property has no prices', () {
      expect(following({SetupProduct.property}).suggestions('USD'), isEmpty);
    });
  });

  group('json', () {
    test('round trips', () {
      const answers = SetupAnswers(
        uses: {SetupUse.money, SetupUse.zakat},
        products: {SetupProduct.metals},
        goals: {SetupGoal.budget},
        captures: {SetupCapture.statement},
      );
      expect(SetupAnswers.fromJson(answers.toJson()), answers);
    });

    test('ignores names it does not know', () {
      final answers = SetupAnswers.fromJson(const {
        'uses': ['money', 'somethingNewer'],
        'goals': ['budget'],
      });
      expect(answers.uses, {SetupUse.money});
      expect(answers.goals, {SetupGoal.budget});
      expect(answers.products, isEmpty);
    });
  });
}
