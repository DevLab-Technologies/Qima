import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qima/blocs/app_cubit.dart';
import 'package:qima/l10n/app_localizations.dart';
import 'package:qima/l10n/app_localizations_en.dart';
import 'package:qima/models/asset.dart';
import 'package:qima/models/fx_history.dart';
import 'package:qima/models/holding.dart';
import 'package:qima/models/instrument_catalog.dart';
import 'package:qima/models/metal_breakdown.dart';
import 'package:qima/models/money.dart';
import 'package:qima/models/quote.dart';
import 'package:qima/screens/holdings_screen.dart';
import 'package:qima/screens/lot_editor_screen.dart';
import 'package:qima/services/preferences.dart';
import 'package:qima/theme/app_theme.dart';
import 'package:qima/theme/masking.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holdings karat feature (spec: "Holdings: karat per lot + totals & average
/// cost"): the lot editor's karat selector, and HoldingsScreen's "Total
/// held"/"Average cost" summary tiles.
void main() {
  final gold = InstrumentCatalog.instrument('metal.XAU')!;
  final silver = InstrumentCatalog.instrument('metal.XAG')!;

  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<AppCubit> emptyCubit() async {
    final cubit = AppCubit();
    cubit.preferences = await Preferences.create();
    cubit.emit(cubit.state.copyWith(
      initialized: true,
      cards: const [],
      lots: const [],
      seriesByID: {
        gold.id: QuoteSeries(instrumentID: gold.id, quotes: [
          Quote(instrumentID: gold.id, timestamp: DateTime(2024, 6, 10), canonicalUSD: 2000),
        ]),
      },
      rates: FXRates(base: 'USD', rates: const {'USD': 1}, updatedAt: DateTime(2024, 6, 10)),
      fxHistory: FXHistory.empty,
      baseCurrency: 'USD',
    ));
    return cubit;
  }

  Future<AppCubit> populatedCubit(List<HoldingLot> lots) async {
    final cubit = await emptyCubit();
    cubit.emit(cubit.state.copyWith(lots: lots));
    return cubit;
  }

  Widget harness({required Widget home, required AppCubit cubit}) {
    return BlocProvider<AppCubit>.value(
      value: cubit,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: buildTheme(Brightness.dark),
        home: home,
      ),
    );
  }

  group('LotEditorScreen karat selector', () {
    testWidgets('is shown for gold priced by gram, defaulting to the originating card\'s karat', (tester) async {
      final cubit = await emptyCubit();
      await tester.pumpWidget(harness(
        home: LotEditorScreen(
          instrument: gold,
          defaultCurrency: 'USD',
          defaultUnit: PriceUnit.gram,
          defaultKarat: GoldKarat.k21,
        ),
        cubit: cubit,
      ));
      await tester.pump();

      final l10n = AppLocalizationsEn();
      expect(find.text(l10n.settingsKarat), findsOneWidget);
      // The 21K segment is selected by default (from the originating card).
      final segmented = tester.widget<SegmentedButton<GoldKarat>>(find.byType(SegmentedButton<GoldKarat>));
      expect(segmented.selected, {GoldKarat.k21});
    });

    testWidgets('is hidden for troy ounce (fine weight) and clears karat when switching to it', (tester) async {
      final cubit = await emptyCubit();
      await tester.pumpWidget(harness(
        home: LotEditorScreen(
          instrument: gold,
          defaultCurrency: 'USD',
          defaultUnit: PriceUnit.gram,
          defaultKarat: GoldKarat.k21,
        ),
        cubit: cubit,
      ));
      await tester.pump();

      final l10n = AppLocalizationsEn();
      expect(find.text(l10n.settingsKarat), findsOneWidget);

      // Switch unit to troy ounce.
      await tester.tap(find.text(l10n.unitTroyOunce));
      await tester.pump();

      expect(find.text(l10n.settingsKarat), findsNothing);
    });

    testWidgets('is never shown for a non-gold instrument', (tester) async {
      final cubit = await emptyCubit();
      await tester.pumpWidget(harness(
        home: LotEditorScreen(instrument: silver, defaultCurrency: 'USD'),
        cubit: cubit,
      ));
      await tester.pump();

      final l10n = AppLocalizationsEn();
      expect(find.text(l10n.settingsKarat), findsNothing);
    });

    testWidgets('editing an existing lot keeps its own stored karat, not the card default', (tester) async {
      final cubit = await emptyCubit();
      final existing = HoldingLot(
        id: 'l1',
        instrumentID: gold.id,
        quantity: 50,
        unit: PriceUnit.gram,
        unitCost: 50,
        costCurrency: 'USD',
        date: DateTime(2024, 6, 1),
        karat: GoldKarat.k18,
      );
      await tester.pumpWidget(harness(
        home: LotEditorScreen(
          instrument: gold,
          defaultCurrency: 'USD',
          defaultUnit: PriceUnit.troyOunce, // different card default unit/karat than the lot
          defaultKarat: GoldKarat.k21,
          existing: existing,
        ),
        cubit: cubit,
      ));
      await tester.pump();

      final segmented = tester.widget<SegmentedButton<GoldKarat>>(find.byType(SegmentedButton<GoldKarat>));
      expect(segmented.selected, {GoldKarat.k18});
    });
  });

  group('HoldingsScreen totals', () {
    testWidgets('shows Total held and Average cost tiles', (tester) async {
      final lot = HoldingLot(
        id: 'l1',
        instrumentID: gold.id,
        quantity: 100,
        unit: PriceUnit.gram,
        unitCost: 50,
        costCurrency: 'USD',
        date: DateTime(2024, 6, 1),
      );
      final cubit = await populatedCubit([lot]);
      final l10n = AppLocalizationsEn();

      await tester.pumpWidget(harness(
        home: HoldingsScreen(instrument: gold, displayCurrency: 'USD', refUnit: PriceUnit.gram),
        cubit: cubit,
      ));
      await tester.pump();

      expect(find.text(l10n.holdingsTotalHeld.toUpperCase()), findsOneWidget);
      expect(find.text(l10n.holdingsAverageCost.toUpperCase()), findsOneWidget);
      expect(find.textContaining('100'), findsWidgets);
    });

    testWidgets('masks Total held (a quantity) when balances are hidden, but not Average cost', (tester) async {
      final lot = HoldingLot(
        id: 'l1',
        instrumentID: gold.id,
        quantity: 100,
        unit: PriceUnit.gram,
        unitCost: 50,
        costCurrency: 'USD',
        date: DateTime(2024, 6, 1),
      );
      final cubit = await populatedCubit([lot]);
      await cubit.toggleHideBalances();
      final l10n = AppLocalizationsEn();

      await tester.pumpWidget(harness(
        home: HoldingsScreen(instrument: gold, displayCurrency: 'USD', refUnit: PriceUnit.gram),
        cubit: cubit,
      ));
      await tester.pump();

      // Total held is a bare quantity that reveals wealth, so it's masked
      // exactly like a money amount would be.
      final totalHeldLabel = find.text(l10n.holdingsTotalHeld.toUpperCase());
      final totalHeldTile = find.ancestor(of: totalHeldLabel, matching: find.byType(Column)).first;
      expect(find.descendant(of: totalHeldTile, matching: find.text(Masking.mask)), findsOneWidget);
      expect(find.descendant(of: totalHeldTile, matching: find.textContaining('100')), findsNothing);

      // Average cost is a PRICE, not an amount held — it stays visible even
      // while balances are hidden.
      final averageLabel = find.text(l10n.holdingsAverageCost.toUpperCase());
      final averageTile = find.ancestor(of: averageLabel, matching: find.byType(Column)).first;
      expect(find.descendant(of: averageTile, matching: find.text(Masking.mask)), findsNothing);
    });

    testWidgets('shows a mixed-karat note when lots have different karats', (tester) async {
      final k24 = HoldingLot(
        id: '1',
        instrumentID: gold.id,
        quantity: 50,
        unit: PriceUnit.gram,
        unitCost: 50,
        costCurrency: 'USD',
        date: DateTime(2024, 6, 1),
      );
      final k21 = k24.copyWith(id: '2', karat: GoldKarat.k21);
      final cubit = await populatedCubit([k24, k21]);
      final l10n = AppLocalizationsEn();

      await tester.pumpWidget(harness(
        home: HoldingsScreen(instrument: gold, displayCurrency: 'USD', refUnit: PriceUnit.gram),
        cubit: cubit,
      ));
      await tester.pump();

      // Reference karat defaults to null (24K) since the card has no karat;
      // the note names the karat the mixed total is shown at.
      expect(find.text(l10n.holdingsMixedNote(l10n.karatShort24)), findsOneWidget);
    });
  });

  group('Lot tiles', () {
    testWidgets('a karat lot shows its karat in the quantity label', (tester) async {
      final lot = HoldingLot(
        id: 'l1',
        instrumentID: gold.id,
        quantity: 100,
        unit: PriceUnit.gram,
        unitCost: 50,
        costCurrency: 'USD',
        date: DateTime(2024, 6, 1),
        karat: GoldKarat.k21,
      );
      final cubit = await populatedCubit([lot]);

      await tester.pumpWidget(harness(
        home: HoldingsScreen(instrument: gold, displayCurrency: 'USD'),
        cubit: cubit,
      ));
      await tester.pump();

      final l10n = AppLocalizationsEn();
      expect(find.textContaining('100 g · ${l10n.karatShort21}'), findsOneWidget);
    });
  });
}
