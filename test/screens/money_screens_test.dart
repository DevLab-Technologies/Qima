import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qima/blocs/app_cubit.dart';
import 'package:qima/blocs/money_cubit.dart';
import 'package:qima/l10n/app_localizations.dart';
import 'package:qima/models/asset.dart';
import 'package:qima/models/book_account.dart';
import 'package:qima/models/fx_history.dart';
import 'package:qima/models/minor_units.dart';
import 'package:qima/models/money.dart';
import 'package:qima/models/money_settings.dart';
import 'package:qima/models/net_worth.dart';
import 'package:qima/models/quote.dart';
import 'package:qima/screens/money/accounts_screens.dart';
import 'package:qima/screens/money/asset_screens.dart';
import 'package:qima/screens/money/balance_sheet_screen.dart';
import 'package:qima/screens/money/entry_detail_screen.dart';
import 'package:qima/screens/money/entry_editor_screen.dart';
import 'package:qima/screens/money/home_screen.dart';
import 'package:qima/screens/money/money_screen.dart';
import 'package:qima/screens/money/more_money_screens.dart';
import 'package:qima/theme/money_labels.dart';
import 'package:qima/services/local_file_store.dart';
import 'package:qima/services/price_repository.dart';
import 'package:qima/theme/app_theme.dart';

class _OfflineRepository extends PriceRepository {
  @override
  Future<double> probePrice(Instrument instrument) async => 100;
  @override
  Future<QuoteSeries> refresh(Instrument instrument, {DateTime? now}) async => QuoteSeries.empty(instrument.id);
  @override
  Future<Map<String, QuoteSeries>> refreshAll(List<Instrument> instruments, {DateTime? now}) async => {};
  @override
  Future<FXHistory> backfillFXHistory(List<String> currencies, {bool force = false, DateTime? now}) async => FXHistory.empty;
  @override
  Future<Map<String, QuoteSeries>> backfillInstruments(List<Instrument> instruments, FXHistory fxHistory, {bool force = false, DateTime? now}) async => {};
}

int sar(num major) => MinorUnits.fromMajor(major, 'SAR');

BookAccount acct(String id, String name, AccountType type, {AccountSide side = AccountSide.own, String ccy = 'SAR'}) =>
    BookAccount(id: id, name: name, side: side, type: type, currency: ccy);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory dir;
  late AppCubit app;
  late MoneyCubit money;
  final rates = FXRates(base: 'SAR', rates: const {'SAR': 1, 'EGP': 13}, updatedAt: DateTime(2026, 11, 7));

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('qima_money_screens');
    LocalFileStore.overrideDirectoryForTesting(dir);
    app = AppCubit(repository: _OfflineRepository());
    app.emit(app.state.copyWith(initialized: true, rates: rates, fxHistory: FXHistory.empty, baseCurrency: 'SAR'));
    money = MoneyCubit(store: app.bookStore, baseCurrency: () => 'SAR', rates: () => app.state.rates);
  });

  tearDown(() async {
    await money.close();
    await app.close();
    if (await dir.exists()) await dir.delete(recursive: true);
  });

  /// A book with something in every part: money, a card, a loan secured on
  /// a car, land with a value history, people, a bill split, a recurring
  /// payment and a budget, and every feature on.
  Future<void> seed() async {
    await money.load();
    await money.markWhatsNewSeen();
    final today = DateTime.now();
    final rajhi = acct('rajhi', 'Al Rajhi current account', AccountType.debit);
    final wallet = acct('wallet', 'Wallet', AccountType.cash);
    final cib = acct('cib', 'CIB', AccountType.debit, ccy: 'EGP');
    final visa = acct('visa', 'Visa Signature', AccountType.credit, side: AccountSide.owe).copyWith(creditLimit: sar(20000));
    final loan = acct('loan', 'Car loan', AccountType.loan, side: AccountSide.owe);
    final car = acct('car', 'Toyota Camry 2023', AccountType.asset).copyWith(assetKind: AssetKind.vehicle, securedLoanId: 'loan', cost: sar(120000), boughtOn: DateTime(2023, 3, 1));
    final land = acct('land', 'Land in Al Qassim', AccountType.asset).copyWith(assetKind: AssetKind.property, heldForSale: true);
    await money.addAccount(rajhi, opening: sar(22020.35), openedOn: DateTime(today.year, today.month - 2));
    await money.addAccount(wallet, opening: sar(892.31), openedOn: DateTime(today.year, today.month - 2));
    await money.addAccount(cib, opening: MinorUnits.fromMajor(12000, 'EGP'), openedOn: DateTime(today.year, today.month - 2));
    await money.addAccount(visa, opening: sar(9100.45), openedOn: DateTime(today.year, today.month - 1));
    await money.addAccount(loan, opening: sar(81150.07), openedOn: DateTime(2023, 3, 1));
    await money.addAccount(car, opening: sar(120000), openedOn: DateTime(2023, 3, 1));
    await money.addAccount(land, opening: sar(200000), openedOn: DateTime(2020, 1, 1));
    await money.revalue(land, sar(240000), DateTime(2025, 1, 1));
    await money.revalue(car, sar(85000), DateTime(2025, 6, 1));
    final faisal = await money.personAccount('Faisal', 'SAR', owesMe: true);
    await money.personAccount('Khalid', 'SAR', owesMe: false);
    final b = money.builder;
    final cats = money.state.book.accounts;
    await money.saveEntry(b.spend(rajhi, cats['category.groceries']!, sar(642.10), today, merchant: 'Panda'));
    await money.saveEntry(b.spend(visa, cats['category.dining']!, sar(1450), today, merchant: 'Al Baik'));
    await money.saveEntry(b.income(rajhi, cats['category.salary']!, sar(18000), DateTime(today.year, today.month)));
    await money.saveEntry(b.lent(rajhi, faisal, sar(500), today));
    await money.saveEntry(b.loanPayment(rajhi, loan, principal: sar(1800), profit: sar(240), date: today));
    await money.saveRecurring(RecurringPayment(id: 'rent', name: 'Rent', amount: sar(3500), fromAccountId: 'rajhi', categoryId: 'category.home', dayOfMonth: 27));
    await money.setBudget('category.dining', sar(1200));
    await money.setBudget('category.groceries', sar(2500));
    await money.setFeatures(MoneyFeature.values.toSet());
  }

  Widget wrap(Widget screen, Locale locale) => MultiBlocProvider(
        providers: [BlocProvider<AppCubit>.value(value: app), BlocProvider<MoneyCubit>.value(value: money)],
        child: MaterialApp(
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: buildTheme(Brightness.light),
          home: screen,
        ),
      );

  void size(WidgetTester tester, Size s) {
    tester.view.physicalSize = s;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Map<String, Widget Function()> screens() {
    final s = money.state;
    final spend = s.entriesNewestFirst.firstWhere((e) => e.merchant == 'Panda');
    return {
      'home': () => const HomeScreen(),
      'edit home': () => const EditHomeScreen(),
      'money': () => const MoneyScreen(),
      'balance sheet': () => const BalanceSheetScreen(),
      'how total': () => const HowTotalScreen(),
      'accounts': () => const AccountsScreen(),
      'add account': () => const AccountEditorScreen(),
      'bank account': () => const AccountDetailScreen(accountId: 'rajhi'),
      'card': () => const AccountDetailScreen(accountId: 'visa'),
      'loan': () => const AccountDetailScreen(accountId: 'loan'),
      'features': () => const FeaturesScreen(),
      'assets': () => const AssetsScreen(),
      'add asset': () => const AssetEditorScreen(),
      'edit asset': () => AssetEditorScreen(existing: s.book.accounts['car']),
      'asset': () => const AssetDetailScreen(assetId: 'land'),
      'asset with loan': () => const AssetDetailScreen(assetId: 'car'),
      'sell asset': () => SellAssetScreen(asset: s.book.accounts['car']!),
      'entry': () => EntryDetailScreen(entryId: spend.id),
      'all transactions': () => const AllTransactionsScreen(),
      'budget': () => const BudgetScreen(),
      'recurring': () => const RecurringScreen(),
      'add recurring': () => const RecurringEditorScreen(),
      'people': () => const PeopleScreen(),
      'bill split': () => const BillSplitScreen(),
      'categories': () => const CategoriesScreen(),
      'zakat': () => const ZakatBookScreen(),
      for (final k in EntryKind.values) 'editor ${k.name}': () => EntryEditorScreen(kind: k),
      'edit spend': () => EntryEditorScreen(kind: EntryKind.spend, existing: spend),
    };
  }

  for (final locale in const [Locale('en'), Locale('ar')]) {
    for (final width in const [320.0, 390.0]) {
      testWidgets('every money screen builds without overflow (${locale.languageCode}, ${width.toInt()} wide)', (tester) async {
        await tester.runAsync(seed);
        // Tall, so lazily built lists build all their rows.
        size(tester, Size(width, 3000));
        for (final MapEntry(key: name, value: build) in screens().entries) {
          await tester.pumpWidget(wrap(build(), locale), duration: Duration.zero);
          await tester.pump(const Duration(milliseconds: 600));
          final error = tester.takeException();
          if (error != null) fail('$name: ${error is FlutterError ? error.diagnostics.map((d) => d.toStringDeep()).join('\n') : error}');
          await tester.pumpWidget(const SizedBox());
        }
      });
    }
  }

  testWidgets('the balance sheet lists every group with the person’s accounts', (tester) async {
    await tester.runAsync(seed);
    size(tester, const Size(390, 3000));
    await tester.pumpWidget(wrap(const BalanceSheetScreen(), const Locale('en')));
    await tester.pump(const Duration(milliseconds: 600));
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    for (final g in SheetGroup.values) {
      expect(find.text(l10n.sheetGroup(g)), findsOneWidget, reason: g.name);
    }
    await tester.tap(find.text(l10n.sheetGroup(SheetGroup.assets)));
    await tester.pumpAndSettle();
    expect(find.text('Land in Al Qassim'), findsOneWidget);
    expect(find.text('Toyota Camry 2023'), findsOneWidget);
  });

  testWidgets('a spend saved in the editor lowers the account', (tester) async {
    await tester.runAsync(seed);
    size(tester, const Size(390, 1200));
    final before = money.state.book.balanceOf('rajhi');
    await tester.pumpWidget(wrap(const EntryEditorScreen(kind: EntryKind.spend, fromAccountId: 'rajhi'), const Locale('en')));
    await tester.pump();
    await tester.enterText(find.byType(TextField).first, '25.50');
    await tester.runAsync(() async {
      await tester.tap(find.text('Save'));
      // Lets the store write finish.
      for (var i = 0; i < 20 && money.state.book.balanceOf('rajhi') == before; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      }
    });
    await tester.pump();
    expect(money.state.book.balanceOf('rajhi'), before - sar(25.50));
  });

  testWidgets('Home shows net worth once there is an account, and hides a card from Edit Home', (tester) async {
    await tester.runAsync(seed);
    size(tester, const Size(390, 3000));
    await tester.pumpWidget(wrap(const HomeScreen(), const Locale('en')));
    await tester.pump(const Duration(milliseconds: 600));
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.text(l10n.sheetAssets), findsWidgets);
    await tester.runAsync(() => money.setCardHidden(HomeCard.assets, true));
    await tester.pump(const Duration(milliseconds: 300));
    expect(money.state.settings.visibleCards, isNot(contains(HomeCard.assets)));
    expect(tester.takeException(), isNull);
  });
}
