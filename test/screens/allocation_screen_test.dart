import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qima/blocs/app_cubit.dart';
import 'package:qima/l10n/app_localizations.dart';
import 'package:qima/l10n/app_localizations_ar.dart';
import 'package:qima/l10n/app_localizations_en.dart';
import 'package:qima/models/asset.dart';
import 'package:qima/models/fx_history.dart';
import 'package:qima/models/holding.dart';
import 'package:qima/models/metal_breakdown.dart';
import 'package:qima/models/money.dart';
import 'package:qima/models/quote.dart';
import 'package:qima/screens/allocation_screen.dart';
import 'package:qima/screens/portfolio_detail_screen.dart';
import 'package:qima/services/preferences.dart';
import 'package:qima/theme/app_theme.dart';
import 'package:qima/theme/masking.dart';
import 'package:qima/theme/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final en = AppLocalizationsEn();
  const goldOz = 3110.34768; // $100/g

  setUp(() => SharedPreferences.setMockInitialValues({}));

  void phone(WidgetTester tester) {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
  }

  HoldingLot lot(String id, double qty, DateTime date, {PriceUnit unit = PriceUnit.each, GoldKarat? karat}) => HoldingLot(
        id: '$id-$qty-${karat?.name}',
        instrumentID: id,
        quantity: qty,
        unit: unit,
        unitCost: 1,
        costCurrency: 'USD',
        date: date,
        karat: karat,
      );

  QuoteSeries series(String id, List<(DateTime, double)> points) => QuoteSeries(
        instrumentID: id,
        quotes: [for (final (t, p) in points) Quote(instrumentID: id, timestamp: t, canonicalUSD: p)],
      );

  Future<AppCubit> cubitWith(List<HoldingLot> lots, Map<String, QuoteSeries> seriesByID, {bool hidden = false}) async {
    final cubit = AppCubit();
    cubit.preferences = await Preferences.create();
    cubit.emit(cubit.state.copyWith(
      initialized: true,
      lots: lots,
      seriesByID: seriesByID,
      rates: FXRates(base: 'USD', rates: const {'USD': 1}, updatedAt: DateTime(2026)),
      fxHistory: FXHistory.empty,
      hideBalances: hidden,
    ));
    return cubit;
  }

  Widget harness(AppCubit cubit, Widget home, {Locale locale = const Locale('en')}) => BlocProvider<AppCubit>.value(
        value: cubit,
        child: MaterialApp(
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: buildTheme(Brightness.dark),
          home: home,
        ),
      );

  String usd(double v) => Masking.amount(Money(v, 'USD'), hidden: false);

  final now = DateTime.now();
  final longAgo = DateTime(now.year - 1, 3, 1);
  final jan1 = DateTime(now.year, 1, 1);

  // Held since last March. On 1 Jan: gold $10k + BTC $10k (50/50).
  // Today: gold $10k + BTC $30k (25/75).
  Map<String, QuoteSeries> history() => {
        'metal.XAU': series('metal.XAU', [(longAgo, goldOz), (jan1.subtract(const Duration(days: 2)), goldOz), (now, goldOz)]),
        'crypto.BTC': series('crypto.BTC', [(longAgo, 8000), (jan1.subtract(const Duration(days: 2)), 10000), (now, 30000)]),
      };

  List<HoldingLot> lots() => [
        lot('metal.XAU', 100, longAgo, unit: PriceUnit.gram),
        lot('crypto.BTC', 1, longAgo),
      ];

  testWidgets('portfolio shows the split by group and opens the detail', (tester) async {
    phone(tester);
    final cubit = await cubitWith(lots(), history());
    await tester.pumpWidget(harness(cubit, const PortfolioDetailScreen()));
    await tester.pumpAndSettle();
    expect(find.text(en.allocationTitle.toUpperCase()), findsOneWidget);
    expect(find.text(en.assetGroupCrypto), findsOneWidget);
    expect(find.text(usd(30000)), findsWidgets);
    await tester.tap(find.text(en.allocationDetails));
    await tester.pumpAndSettle();
    expect(find.byType(AllocationScreen), findsOneWidget);
  });

  testWidgets('a single-group portfolio says so instead of repeating the total', (tester) async {
    phone(tester);
    final cubit = await cubitWith([lot('metal.XAU', 100, longAgo, unit: PriceUnit.gram)], history());
    await tester.pumpWidget(harness(cubit, const PortfolioDetailScreen()));
    await tester.pumpAndSettle();
    expect(find.text(en.allocationSingleGroup(en.assetGroupMetals)), findsOneWidget);
    await tester.tap(find.text(en.allocationDetails));
    await tester.pumpAndSettle();
    expect(find.byType(AllocationScreen), findsOneWidget);
  });

  testWidgets('detail shows metals by karat and drift since 1 January', (tester) async {
    phone(tester);
    final cubit = await cubitWith(
      [...lots(), lot('metal.XAU', 100, longAgo, unit: PriceUnit.gram, karat: GoldKarat.k21)],
      history(),
    );
    await tester.pumpWidget(harness(cubit, const AllocationScreen()));
    await tester.pumpAndSettle();
    expect(find.text(en.allocationMetalForm('Gold', '21K')), findsOneWidget);
    expect(find.text(en.allocationMetalForm('Gold', '24K')), findsOneWidget);
    final context = tester.element(find.byType(AllocationScreen));
    expect(find.text(en.allocationDriftSince(dateWithYear(context, jan1)).toUpperCase()), findsOneWidget);
    // Metals: 18,750 of 28,750 on 1 Jan (65%) → 18,750 of 48,750 now (38%).
    expect(find.text(en.allocationDriftChange(percentLabel(context, 65), percentLabel(context, 38))), findsOneWidget);
  });

  testWidgets('new holdings show the pending note instead of a trend', (tester) async {
    phone(tester);
    final recent = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 3));
    final cubit = await cubitWith([lot('crypto.BTC', 1, recent)], {
      'crypto.BTC': series('crypto.BTC', [(recent, 30000), (now, 30000)]),
    });
    await tester.pumpWidget(harness(cubit, const AllocationScreen()));
    await tester.pumpAndSettle();
    expect(find.text(en.allocationDriftPendingTitle.toUpperCase()), findsOneWidget);
    expect(find.textContaining('→'), findsNothing);
  });

  testWidgets('no price history that far back says so', (tester) async {
    phone(tester);
    final cubit = await cubitWith([lot('crypto.BTC', 1, longAgo)], {
      'crypto.BTC': series('crypto.BTC', [(now, 30000)]),
    });
    await tester.pumpWidget(harness(cubit, const AllocationScreen()));
    await tester.pumpAndSettle();
    expect(find.text(en.allocationDriftNoHistory), findsOneWidget);
  });

  testWidgets('hidden balances mask amounts but keep percentages', (tester) async {
    phone(tester);
    final cubit = await cubitWith(lots(), history(), hidden: true);
    await tester.pumpWidget(harness(cubit, const AllocationScreen()));
    await tester.pumpAndSettle();
    expect(find.text(usd(30000)), findsNothing);
    expect(find.text(Masking.mask), findsWidgets);
    final context = tester.element(find.byType(AllocationScreen));
    expect(find.text(percentLabel(context, 75)), findsOneWidget);
  });

  testWidgets('renders in Arabic without overflow', (tester) async {
    phone(tester);
    final cubit = await cubitWith(lots(), history());
    await tester.pumpWidget(harness(cubit, const AllocationScreen(), locale: const Locale('ar')));
    await tester.pumpAndSettle();
    expect(find.text(AppLocalizationsAr().allocationTitle), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
