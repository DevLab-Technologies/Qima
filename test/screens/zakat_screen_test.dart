import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qima/blocs/app_cubit.dart';
import 'package:qima/l10n/app_localizations.dart';
import 'package:qima/l10n/app_localizations_ar.dart';
import 'package:qima/l10n/app_localizations_en.dart';
import 'package:qima/models/asset.dart';
import 'package:qima/models/asset_group.dart';
import 'package:qima/models/fx_history.dart';
import 'package:qima/models/hijri_date.dart';
import 'package:qima/models/holding.dart';
import 'package:qima/models/instrument_catalog.dart';
import 'package:qima/models/money.dart';
import 'package:qima/models/quote.dart';
import 'package:qima/models/zakat.dart';
import 'package:qima/screens/portfolio_detail_screen.dart';
import 'package:qima/screens/zakat_screen.dart';
import 'package:qima/screens/zakat_settings_screen.dart';
import 'package:qima/services/notification_service.dart';
import 'package:qima/services/preferences.dart';
import 'package:qima/services/price_repository.dart';
import 'package:qima/theme/app_theme.dart';
import 'package:qima/theme/masking.dart';
import 'package:qima/theme/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Serves fixed prices and never touches the network or disk.
class _FakeRepository extends PriceRepository {
  final Map<String, double> prices;
  int refreshCalls = 0;

  _FakeRepository(this.prices);

  QuoteSeries _series(String id) => QuoteSeries(
        instrumentID: id,
        quotes: [if (prices[id] != null) Quote(instrumentID: id, timestamp: DateTime(2026, 10, 1), canonicalUSD: prices[id]!)],
      );

  @override
  Future<QuoteSeries> refresh(Instrument instrument, {DateTime? now}) async {
    refreshCalls++;
    if (prices[instrument.id] == null) throw Exception('offline');
    return _series(instrument.id);
  }

  @override
  Future<QuoteSeries> cachedSeries(Instrument instrument) async => _series(instrument.id);
}

class _FakeNotificationService extends NotificationService {
  bool enabled = true;

  @override
  Future<bool> isEnabled() async => enabled;

  @override
  Future<bool> requestPermission() async => enabled;
}

void main() {
  final en = AppLocalizationsEn();
  // $100/g gold and $1/g silver keep the arithmetic readable: gold nisab is
  // $8,500, silver nisab $595.
  const goldOz = 3110.34768;
  const silverOz = 31.1034768;

  setUp(() => SharedPreferences.setMockInitialValues({}));

  // A phone-sized window, so rows below the fold are on screen.
  void phone(WidgetTester tester) {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
  }

  HoldingLot lot(String id, double quantity, {PriceUnit unit = PriceUnit.each}) => HoldingLot(
        id: '$id-$quantity',
        instrumentID: id,
        quantity: quantity,
        unit: unit,
        unitCost: 1,
        costCurrency: 'USD',
        date: DateTime(2025),
      );

  Future<AppCubit> cubitWith(
    List<HoldingLot> lots, {
    Map<String, double>? prices,
    ZakatSettings settings = const ZakatSettings(),
    bool hidden = false,
  }) async {
    final effective = prices ?? {'metal.XAU': goldOz, 'metal.XAG': silverOz, 'crypto.BTC': 50000, 'stock.AAPL': 200};
    final repo = _FakeRepository(effective);
    final cubit = AppCubit(repository: repo, notificationService: _FakeNotificationService());
    cubit.preferences = await Preferences.create();
    cubit.emit(cubit.state.copyWith(
      initialized: true,
      lots: lots,
      seriesByID: {for (final id in effective.keys) id: await repo.cachedSeries(InstrumentCatalog.instrument(id)!)},
      rates: FXRates(base: 'USD', rates: const {'USD': 1}, updatedAt: DateTime(2026)),
      fxHistory: FXHistory.empty,
      baseCurrency: 'USD',
      zakatSettings: settings,
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

  String usd(double amount) => Masking.amount(Money(amount, 'USD'), hidden: false);

  group('ZakatScreen', () {
    testWidgets('no holdings shows the empty state', (tester) async {
      phone(tester);
      final cubit = await cubitWith(const []);
      await tester.pumpWidget(harness(cubit, const ZakatScreen()));
      await tester.pumpAndSettle();
      expect(find.text(en.zakatEmptyTitle), findsOneWidget);
      expect(find.text(en.zakatDueLabel('2.5%').toUpperCase()), findsNothing);
    });

    testWidgets('above nisab shows 2.5% of the base and asks for a hawl date', (tester) async {
      phone(tester);
      final cubit = await cubitWith([lot('crypto.BTC', 1)]);
      await tester.pumpWidget(harness(cubit, const ZakatScreen()));
      await tester.pumpAndSettle();
      expect(find.text(en.zakatStatusAbove), findsOneWidget);
      expect(find.text(usd(1250)), findsOneWidget);
      expect(find.text(en.zakatExplainAboveNoHawl(usd(50000))), findsOneWidget);
      expect(find.text(usd(8500)), findsOneWidget, reason: 'gold threshold today');
      expect(find.text(en.zakatHawlSet), findsOneWidget);
    });

    testWidgets('below nisab owes nothing and says why', (tester) async {
      phone(tester);
      final cubit = await cubitWith([lot('metal.XAU', 10, unit: PriceUnit.gram)]);
      await tester.pumpWidget(harness(cubit, const ZakatScreen()));
      await tester.pumpAndSettle();
      expect(find.text(en.zakatStatusBelow), findsOneWidget);
      expect(find.text(usd(0)), findsOneWidget);
      expect(find.text(en.zakatExplainBelow(usd(1000), usd(8500))), findsOneWidget);
    });

    testWidgets('a hawl in progress names its completion date', (tester) async {
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 30));
      final cubit = await cubitWith([lot('crypto.BTC', 1)],
          settings: ZakatSettings(hawlStart: start, calendar: HawlCalendar.gregorian));
      await tester.pumpWidget(harness(cubit, const ZakatScreen()));
      await tester.pumpAndSettle();
      final schedule = HawlSchedule.of(cubit.state.zakatSettings, now)!;
      final context = tester.element(find.byType(ZakatScreen));
      final date = dateWithYear(context, schedule.next);
      expect(find.text(en.zakatExplainAboveUpcoming(usd(50000), date, schedule.daysUntilNext)), findsOneWidget);
    });

    testWidgets('hidden balances mask the due amount and base but not the market threshold', (tester) async {
      phone(tester);
      final cubit = await cubitWith([lot('crypto.BTC', 1)], hidden: true);
      await tester.pumpWidget(harness(cubit, const ZakatScreen()));
      await tester.pumpAndSettle();
      expect(find.text(usd(1250)), findsNothing);
      expect(find.text(usd(50000)), findsNothing);
      expect(find.textContaining('50,000'), findsNothing);
      expect(find.text(usd(8500)), findsOneWidget);
    });

    testWidgets('switching an asset off removes it from the base', (tester) async {
      phone(tester);
      final cubit = await cubitWith([lot('crypto.BTC', 1), lot('metal.XAU', 100, unit: PriceUnit.gram)]);
      await tester.pumpWidget(harness(cubit, const ZakatScreen()));
      await tester.pumpAndSettle();
      expect(find.text(usd(60000 * 0.025)), findsOneWidget);

      final bitcoinRow = find.ancestor(of: find.textContaining('Bitcoin'), matching: find.byType(SwitchListTile));
      await tester.dragUntilVisible(bitcoinRow, find.byType(ListView), const Offset(0, -150));
      await tester.pumpAndSettle();
      await tester.tap(bitcoinRow);
      await tester.pumpAndSettle();

      expect(cubit.state.zakatSettings.holdingOverrides, {'crypto.BTC': false});
      await tester.drag(find.byType(ListView), const Offset(0, 2000));
      await tester.pumpAndSettle();
      expect(find.text(usd(250)), findsOneWidget);
      expect(find.textContaining(en.zakatExcludedHolding), findsOneWidget);
    });

    testWidgets('equities are listed as excluded by class by default', (tester) async {
      phone(tester);
      final cubit = await cubitWith([lot('crypto.BTC', 1), lot('stock.AAPL', 10)]);
      await tester.pumpWidget(harness(cubit, const ZakatScreen()));
      await tester.pumpAndSettle();
      await tester.dragUntilVisible(find.textContaining(en.zakatExcludedClass(en.assetGroupEquities)), find.byType(ListView), const Offset(0, -150));
      await tester.pumpAndSettle();
      expect(find.textContaining(en.zakatExcludedClass(en.assetGroupEquities)), findsOneWidget);
    });

    testWidgets('without a gold price the status is unknown and offers a retry', (tester) async {
      phone(tester);
      final cubit = await cubitWith([lot('crypto.BTC', 1)], prices: {'metal.XAG': silverOz, 'crypto.BTC': 50000});
      await tester.pumpWidget(harness(cubit, const ZakatScreen()));
      await tester.pumpAndSettle();
      expect(find.text(en.zakatStatusUnknown), findsOneWidget);
      expect(find.text(en.zakatRetry), findsOneWidget);
      expect(find.text(usd(0)), findsOneWidget);
    });

    testWidgets('an unpriced asset is flagged, not silently dropped', (tester) async {
      phone(tester);
      final cubit = await cubitWith([lot('crypto.BTC', 1), lot('crypto.ETH', 2)]);
      await tester.pumpWidget(harness(cubit, const ZakatScreen()));
      await tester.pumpAndSettle();
      expect(find.text(en.zakatUnpricedNote), findsOneWidget);
      await tester.dragUntilVisible(find.textContaining('· ${en.zakatExcludedNoPrice}'), find.byType(ListView), const Offset(0, -150));
      await tester.pumpAndSettle();
      expect(find.textContaining('· ${en.zakatExcludedNoPrice}'), findsOneWidget);
    });

    testWidgets('fetches nisab metals the user does not track', (tester) async {
      phone(tester);
      final repo = _FakeRepository({'metal.XAU': goldOz, 'metal.XAG': silverOz, 'crypto.BTC': 50000});
      final cubit = AppCubit(repository: repo, notificationService: _FakeNotificationService());
      cubit.preferences = await Preferences.create();
      cubit.emit(cubit.state.copyWith(
        initialized: true,
        lots: [lot('crypto.BTC', 1)],
        seriesByID: {'crypto.BTC': await repo.cachedSeries(InstrumentCatalog.instrument('crypto.BTC')!)},
        rates: FXRates(base: 'USD', rates: const {'USD': 1}, updatedAt: DateTime(2026)),
      ));
      await tester.pumpWidget(harness(cubit, const ZakatScreen()));
      await tester.pumpAndSettle();
      expect(repo.refreshCalls, 2);
      expect(find.text(en.zakatStatusAbove), findsOneWidget);
    });

    testWidgets('renders in Arabic without overflow', (tester) async {
      phone(tester);
      final ar = AppLocalizationsAr();
      final cubit = await cubitWith([lot('crypto.BTC', 1), lot('stock.AAPL', 10)],
          settings: ZakatSettings(hawlStart: DateTime(2025, 3, 12)));
      await tester.pumpWidget(harness(cubit, const ZakatScreen(), locale: const Locale('ar')));
      await tester.pumpAndSettle();
      expect(find.text(ar.zakatStatusAbove), findsOneWidget);
      expect(find.text(ar.zakatTitle), findsOneWidget);
      // Western digits, isolated so the % stays on the right of the number.
      expect(find.text(ar.zakatDueLabel('\u20662.5%\u2069')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('formats the rate for the locale', (tester) async {
      phone(tester);
      final cubit = await cubitWith([lot('crypto.BTC', 1)]);
      await tester.pumpWidget(harness(cubit, const ZakatScreen(), locale: const Locale('fr')));
      await tester.pumpAndSettle();
      expect(find.textContaining('2,5%'), findsOneWidget);
    });
  });

  group('ZakatSettingsScreen', () {
    testWidgets('marks gold as the higher threshold and silver as the lower', (tester) async {
      phone(tester);
      final cubit = await cubitWith([lot('crypto.BTC', 1)]);
      await tester.pumpWidget(harness(cubit, const ZakatSettingsScreen()));
      await tester.pumpAndSettle();
      expect(find.text(en.zakatBasisHigher(usd(8500))), findsOneWidget);
      expect(find.text(en.zakatBasisLower(usd(595))), findsOneWidget);
    });

    testWidgets('choosing silver saves and persists', (tester) async {
      phone(tester);
      final cubit = await cubitWith([lot('crypto.BTC', 1)]);
      await tester.pumpWidget(harness(cubit, const ZakatSettingsScreen()));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(RadioListTile<NisabBasis>).last);
      await tester.pumpAndSettle();
      expect(cubit.state.zakatSettings.basis, NisabBasis.silver);
      expect((await cubit.preferences.zakatSettings).basis, NisabBasis.silver);
    });

    testWidgets('toggling equities on includes them', (tester) async {
      phone(tester);
      final cubit = await cubitWith([lot('stock.AAPL', 10)]);
      await tester.pumpWidget(harness(cubit, const ZakatSettingsScreen()));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(SwitchListTile, en.assetGroupEquities));
      await tester.pumpAndSettle();
      expect(cubit.state.zakatSettings.includedClasses, contains(AssetGroup.equities));
      expect(cubit.zakatAssessment.base.amount, closeTo(2000, 1e-6));
    });

    testWidgets('the reminder needs a hawl date first', (tester) async {
      phone(tester);
      final cubit = await cubitWith([lot('crypto.BTC', 1)]);
      await tester.pumpWidget(harness(cubit, const ZakatSettingsScreen()));
      await tester.pumpAndSettle();
      final reminder = find.widgetWithText(SwitchListTile, en.zakatRemind);
      await tester.dragUntilVisible(reminder, find.byType(ListView), const Offset(0, -150));
      await tester.pumpAndSettle();
      expect(tester.widget<SwitchListTile>(reminder).onChanged, isNull);
      expect(find.text(en.zakatRemindNeedsStart), findsOneWidget);
    });

    testWidgets('a Hijri start is picked by day, month and year, and a future day is refused', (tester) async {
      phone(tester);
      final cubit = await cubitWith([lot('crypto.BTC', 1)]);
      await tester.pumpWidget(harness(cubit, const ZakatSettingsScreen()));
      await tester.pumpAndSettle();
      await tester.dragUntilVisible(find.text(en.zakatHawlSet), find.byType(ListView), const Offset(0, -150));
      await tester.pumpAndSettle();
      await tester.tap(find.text(en.zakatHawlSet));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);

      final today = HijriDate.fromGregorian(DateTime.now())!;
      // Move to the following month of this year: in the future.
      final futureMonth = today.month == 12 ? null : today.month + 1;
      if (futureMonth != null) {
        await tester.tap(find.text(_monthName(en, today.month)).last);
        await tester.pumpAndSettle();
        await tester.tap(find.text(_monthName(en, futureMonth)).last);
        await tester.pumpAndSettle();
        expect(find.text(en.zakatHawlPickerFuture), findsOneWidget);
        expect(tester.widget<FilledButton>(find.widgetWithText(FilledButton, en.commonDone)).onPressed, isNull);

        // Back to last year: valid again.
        await tester.tap(find.text('${today.year}').last);
        await tester.pumpAndSettle();
        await tester.tap(find.text('${today.year - 1}').last);
        await tester.pumpAndSettle();
      }
      expect(find.text(en.zakatHawlPickerFuture), findsNothing);
      await tester.tap(find.widgetWithText(FilledButton, en.commonDone));
      await tester.pumpAndSettle();

      final start = cubit.state.zakatSettings.hawlStart!;
      expect(start.isAfter(DateTime.now()), isFalse);
      final picked = HijriDate.fromGregorian(start)!;
      if (futureMonth != null) {
        expect(picked.year, today.year - 1);
        expect(picked.month, futureMonth);
      }
    });

    testWidgets('clearing the hawl date also turns the reminder off', (tester) async {
      phone(tester);
      final cubit = await cubitWith([lot('crypto.BTC', 1)],
          settings: ZakatSettings(hawlStart: DateTime(2025, 3, 12), remind: true));
      await tester.pumpWidget(harness(cubit, const ZakatSettingsScreen()));
      await tester.pumpAndSettle();
      await tester.dragUntilVisible(find.text(en.zakatHawlClear), find.byType(ListView), const Offset(0, -150));
      await tester.pumpAndSettle();
      await tester.tap(find.text(en.zakatHawlClear));
      await tester.pumpAndSettle();
      expect(cubit.state.zakatSettings.hawlStart, isNull);
      expect(cubit.state.zakatSettings.remind, isFalse);
    });

    testWidgets('per-asset choices can be reset in one tap', (tester) async {
      phone(tester);
      final cubit = await cubitWith([lot('crypto.BTC', 1)],
          settings: const ZakatSettings(holdingOverrides: {'crypto.BTC': false, 'stock.AAPL': true}));
      await tester.pumpWidget(harness(cubit, const ZakatSettingsScreen()));
      await tester.pumpAndSettle();
      expect(find.text(en.zakatOverridesCount(2)), findsOneWidget);
      await tester.tap(find.text(en.zakatOverridesReset));
      await tester.pumpAndSettle();
      expect(cubit.state.zakatSettings.holdingOverrides, isEmpty);
    });
  });

  group('Portfolio entry', () {
    testWidgets('shows what is due and opens the zakat screen', (tester) async {
      phone(tester);
      final cubit = await cubitWith([lot('crypto.BTC', 1)]);
      await tester.pumpWidget(harness(cubit, const PortfolioDetailScreen()));
      await tester.pumpAndSettle();
      expect(find.text(en.zakatEntryDue(usd(1250))), findsOneWidget);
      await tester.tap(find.text(en.zakatTitle));
      await tester.pumpAndSettle();
      expect(find.byType(ZakatScreen), findsOneWidget);
    });

    testWidgets('masks the amount when balances are hidden', (tester) async {
      phone(tester);
      final cubit = await cubitWith([lot('crypto.BTC', 1)], hidden: true);
      await tester.pumpWidget(harness(cubit, const PortfolioDetailScreen()));
      await tester.pumpAndSettle();
      expect(find.text(en.zakatEntryDue(usd(1250))), findsNothing);
      expect(find.text(en.zakatEntryDue(Masking.mask)), findsOneWidget);
    });

    testWidgets('is absent with no holdings', (tester) async {
      phone(tester);
      final cubit = await cubitWith(const []);
      await tester.pumpWidget(harness(cubit, const PortfolioDetailScreen()));
      await tester.pumpAndSettle();
      expect(find.text(en.zakatTitle), findsNothing);
    });
  });
}

String _monthName(AppLocalizations l10n, int month) => [
      l10n.hijriMonth1,
      l10n.hijriMonth2,
      l10n.hijriMonth3,
      l10n.hijriMonth4,
      l10n.hijriMonth5,
      l10n.hijriMonth6,
      l10n.hijriMonth7,
      l10n.hijriMonth8,
      l10n.hijriMonth9,
      l10n.hijriMonth10,
      l10n.hijriMonth11,
      l10n.hijriMonth12,
    ][month - 1];
