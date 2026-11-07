import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qima/blocs/app_cubit.dart';
import 'package:qima/blocs/import_cubit.dart';
import 'package:qima/blocs/money_cubit.dart';
import 'package:qima/l10n/app_localizations.dart';
import 'package:qima/models/asset.dart';
import 'package:qima/models/chart_range.dart';
import 'package:qima/models/entry_builder.dart';
import 'package:qima/models/holding.dart';
import 'package:qima/models/instrument_catalog.dart';
import 'package:qima/models/book_account.dart';
import 'package:qima/models/book_entry.dart';
import 'package:qima/models/fx_history.dart';
import 'package:qima/models/minor_units.dart';
import 'package:qima/models/money.dart';
import 'package:qima/models/money_settings.dart';
import 'package:qima/models/net_worth.dart';
import 'package:qima/models/quote.dart';
import 'package:qima/screens/help_sheet.dart';
import 'package:qima/screens/money/accounts_screens.dart';
import 'package:qima/screens/money/asset_screens.dart';
import 'package:qima/screens/money/balance_sheet_screen.dart';
import 'package:qima/theme/price_chart.dart';
import 'package:qima/theme/strings.dart';
import 'package:qima/screens/money/bank_messages_screen.dart';
import 'package:qima/screens/money/categorize_screen.dart';
import 'package:qima/screens/money/entry_detail_screen.dart';
import 'package:qima/screens/money/entry_editor_screen.dart';
import 'package:qima/screens/money/home_screen.dart';
import 'package:qima/screens/money/import_screens.dart';
import 'package:qima/services/dictation_service.dart';
import 'package:qima/services/import/bank_messages.dart';
import 'package:qima/services/import/import_inbox_io.dart';
import 'package:qima/services/import/pasted_files.dart';
import 'package:qima/models/statement_reader.dart';
import 'package:qima/services/text_recognition_service.dart';
import 'package:qima/screens/money/money_screen.dart';
import 'package:qima/screens/money/more_money_screens.dart';
import 'package:qima/theme/money_labels.dart';
import 'package:qima/services/local_file_store.dart';
import 'package:qima/services/price_repository.dart';
import 'package:qima/theme/app_theme.dart';
import 'package:qima/theme/help_topics.dart';
import 'package:qima/widgets/help_button.dart';
import 'package:qima/services/preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A recognizer the test speaks through.
class _SpokenWords implements DictationService {
  StreamController<DictationEvent>? session;

  @override
  Future<DictationAvailability> availability(String localeTag) async => DictationAvailability.available;

  @override
  Stream<DictationEvent> listen(String localeTag) => (session = StreamController<DictationEvent>()).stream;

  @override
  Future<void> stop() async {}
}

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

class _PdfRecognition implements TextRecognitionService {
  @override
  Future<bool> isAvailable() async => true;
  @override
  Future<List<String>?> recognize(String imagePath, List<String> languageTags) async => null;
  @override
  Future<List<DocPage>?> readDocument(String path, List<String> languageTags) async => [
        DocPage([
          const DocToken('Today', 0.05, 0.10, 0.2, 0.02),
          const DocToken('Starbucks Olaya Riyadh with a long branch name', 0.05, 0.14, 0.5, 0.025),
          const DocToken('-23.00 SAR', 0.7, 0.14, 0.25, 0.025),
          const DocToken('Amazon', 0.05, 0.18, 0.3, 0.025),
          const DocToken('USD 1,234,567.89', 0.6, 0.18, 0.35, 0.025),
        ]),
      ];
}

/// A banking app's account screen: the account and its balance, no
/// transactions.
class _AccountScreen implements TextRecognitionService {
  @override
  Future<bool> isAvailable() async => true;
  @override
  Future<List<String>?> recognize(String imagePath, List<String> languageTags) async => null;
  @override
  Future<List<DocPage>?> readDocument(String path, List<String> languageTags) async => [
        DocPage([
          const DocToken('Current account', 0.069, 0.109, 0.324, 0.016),
          const DocToken('Available balance', 0.066, 0.189, 0.274, 0.015),
          const DocToken('25,000.00 SAR', 0.069, 0.223, 0.695, 0.049),
        ]),
      ];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory dir;
  late AppCubit app;
  late MoneyCubit money;
  late ImportCubit importer;
  final rates = FXRates(base: 'SAR', rates: const {'SAR': 1, 'EGP': 13}, updatedAt: DateTime(2026, 11, 7));

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('qima_money_screens');
    LocalFileStore.overrideDirectoryForTesting(dir);
    app = AppCubit(repository: _OfflineRepository());
    app.emit(app.state.copyWith(initialized: true, rates: rates, fxHistory: FXHistory.empty, baseCurrency: 'SAR'));
    money = MoneyCubit(store: app.bookStore, baseCurrency: () => 'SAR', rates: () => app.state.rates);
    final inboxDir = Directory('${dir.path}/inbox')..createSync();
    importer = ImportCubit(
      inbox: FolderInbox(folders: [inboxDir]),
      recognition: _PdfRecognition(),
      wasImported: money.wasImported,
      languages: () => const ['en-US'],
    );
  });

  tearDown(() async {
    await importer.close();
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
    await importer.addFiles([
      ('Al Rajhi statement November 2026 with a long name.csv', utf8.encode('Date,Description,Debit,Credit,Balance\n03/11/2026,PANDA RIYADH,512.40,,21508.25\n01/11/2026,SALARY NOVEMBER,,17500.00,22020.65\n')),
      ('IMG_2041.png', [1, 2, 3]),
      ('notes.docx', [1]),
    ]);
  }

  Widget wrap(Widget screen, Locale locale) => MultiBlocProvider(
        providers: [
          BlocProvider<AppCubit>.value(value: app),
          BlocProvider<MoneyCubit>.value(value: money),
          BlocProvider<ImportCubit>.value(value: importer),
        ],
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
      'import review': () => const ImportReviewScreen(),
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
          expect(find.byType(HelpButton), findsWidgets, reason: '$name has no help');
          await tester.pumpWidget(const SizedBox());
        }
        // And every page's help reads without overflow.
        for (final id in HelpTopicId.values) {
          await tester.pumpWidget(wrap(Scaffold(body: Builder(builder: (context) => HelpSheet(topic: helpTopicFor(context, id)))), locale));
          final error = tester.takeException();
          if (error != null) fail('help ${id.name}: $error');
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

  testWidgets('spend, income and transfer are tabs of one page that keep the amount', (tester) async {
    await tester.runAsync(seed);
    size(tester, const Size(390, 1200));
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    final before = money.state.book.balanceOf('rajhi');
    await tester.pumpWidget(wrap(const EntryEditorScreen(kind: EntryKind.spend, fromAccountId: 'rajhi'), const Locale('en')));
    await tester.pump();
    expect(find.text(l10n.entryNewTitle), findsOneWidget);
    expect(find.text(l10n.entryPaidFrom), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, '40');

    await tester.tap(find.text(l10n.tplTransfer));
    await tester.pump();
    expect(find.text(l10n.entryTo), findsOneWidget);
    expect(find.text(l10n.entryCategory), findsNothing);

    await tester.tap(find.text(l10n.tplIncome));
    await tester.pump();
    expect(find.text(l10n.entryPaidFrom), findsNothing);
    expect(find.text('40'), findsOneWidget);
    await tester.runAsync(() async {
      await tester.tap(find.text('Save'));
      for (var i = 0; i < 20 && money.state.book.balanceOf('rajhi') == before; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      }
    });
    await tester.pump();
    // The account chosen on the Spend tab is where the income went.
    expect(money.state.book.balanceOf('rajhi'), before + sar(40));
  });

  testWidgets('editing shows no tabs', (tester) async {
    await tester.runAsync(seed);
    size(tester, const Size(390, 1200));
    final spend = money.state.book.entries.firstWhere((e) => e.template == EntryTemplate.spend);
    await tester.pumpWidget(wrap(EntryEditorScreen(kind: EntryKind.spend, existing: spend), const Locale('en')));
    await tester.pump();
    expect(find.byKey(const ValueKey('entryKindTabs')), findsNothing);
  });

  testWidgets('the import review: rows ticked where sure, flags, and adding them', (tester) async {
    await tester.runAsync(seed);
    size(tester, const Size(390, 2400));
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    final before = money.state.book.balanceOf('rajhi');
    await tester.pumpWidget(wrap(const ImportReviewScreen(), const Locale('en')));
    await tester.pump(const Duration(milliseconds: 300));
    // The CSV, the screenshot (read as positioned text) and the unknown file.
    expect(find.text('PANDA RIYADH'), findsOneWidget);
    expect(find.text('SALARY NOVEMBER'), findsOneWidget);
    expect(find.text('Starbucks Olaya Riyadh with a long branch name'), findsOneWidget);
    expect(find.text(l10n.importFlagCurrency('USD')), findsOneWidget);
    expect(find.text(l10n.importStatusUnsupported), findsOneWidget);
    // Three ticked: Panda, salary, Starbucks; Amazon in USD is not.
    expect(find.text(l10n.importAddCount(3)), findsOneWidget);
    // The four rows, and above them the offer to bring the account to the
    // statement's running balance: unticked, as the account has history.
    expect(find.byType(Checkbox), findsNWidgets(5));
    final offer = tester.widget<CheckboxListTile>(find.byKey(const ValueKey('importBalance')));
    expect(offer.value, isFalse);

    // With no row ticked, the balance alone can still be applied.
    for (final i in [0, 1, 2, 3]) {
      await tester.tap(find.byType(Checkbox).at(i));
      await tester.pump();
    }
    expect(find.text(l10n.importApplyBalance), findsOneWidget);

    // Panda and the salary back, the coffee and the balance left out, then add.
    for (final i in [0, 1, 2]) {
      await tester.tap(find.byType(Checkbox).at(i));
      await tester.pump();
    }
    expect(find.text(l10n.importAddCount(2)), findsOneWidget);
    await tester.runAsync(() async {
      await tester.tap(find.byKey(const ValueKey('importAdd')));
      for (var i = 0; i < 40 && importer.state.items.isNotEmpty; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      }
    });
    await tester.pump();
    expect(money.state.book.balanceOf('rajhi'), before - sar(512.40) + sar(17500));
    expect(importer.state.isEmpty, isTrue);
    expect(money.state.settings.importedHashes, hasLength(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('the import review in Arabic on a narrow phone: the balance offer fits', (tester) async {
    await tester.runAsync(seed);
    size(tester, const Size(320, 2400));
    await tester.pumpWidget(wrap(const ImportReviewScreen(), const Locale('ar')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byKey(const ValueKey('importBalance')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a screenshot of only a balance offers the correction ticked, and applies it', (tester) async {
    await tester.runAsync(seed);
    size(tester, const Size(390, 1200));
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    await tester.runAsync(() async {
      await importer.close();
      importer = ImportCubit(
        inbox: FolderInbox(folders: [Directory('${dir.path}/screen')..createSync()]),
        recognition: _AccountScreen(),
        wasImported: money.wasImported,
        languages: () => const ['en-US'],
      );
      await importer.addFiles([('IMG_3001.png', [4, 5, 6])]);
      for (var i = 0; i < 40 && importer.state.reading; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      }
    });
    expect(importer.state.items.single.rows, isEmpty);
    // Home says there is a balance to check, not that nothing was found.
    await tester.pumpWidget(wrap(const Scaffold(body: ImportBanner()), const Locale('en')));
    await tester.pump();
    expect(find.text(l10n.importReadyBalance), findsOneWidget);
    await tester.pumpWidget(wrap(const ImportReviewScreen(), const Locale('en')));
    await tester.pump(const Duration(milliseconds: 300));
    // No account number on the screen: the account with the most
    // statements is offered.
    expect(find.byKey(const ValueKey('importAccount-rajhi')), findsOneWidget);
    final offer = tester.widget<CheckboxListTile>(find.byKey(const ValueKey('importBalance')));
    expect(offer.value, isTrue);
    expect(find.text(l10n.importApplyBalance), findsOneWidget);
    // The account has history, so the difference can go either way; the
    // opening balance is offered first.
    expect(tester.widget<RadioGroup<BalanceWay>>(find.byType(RadioGroup<BalanceWay>)).groupValue, BalanceWay.opening);
    final entriesBefore = money.state.book.entries.length;
    await tester.runAsync(() async {
      await tester.tap(find.byKey(const ValueKey('importAdd')));
      for (var i = 0; i < 40 && importer.state.items.isNotEmpty; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      }
    });
    await tester.pump();
    expect(money.state.book.balanceOf('rajhi'), sar(25000));
    expect(money.state.book.entries, hasLength(entriesBefore), reason: 'the opening balance changed; nothing was added');
    expect(tester.takeException(), isNull);
  });

  for (final way in BalanceWay.values) {
    testWidgets('checking a balance by ${way.name}', (tester) async {
      await tester.runAsync(seed);
      size(tester, const Size(390, 1600));
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      await tester.pumpWidget(wrap(const AccountDetailScreen(accountId: 'wallet'), const Locale('en')));
      await tester.pump(const Duration(milliseconds: 300));
      final entriesBefore = money.state.book.entries.length;
      final spentBefore = money.state.book.balanceOf('category.other');
      await tester.tap(find.text(l10n.accountCountCash));
      await tester.pumpAndSettle();
      expect(tester.widget<RadioGroup<BalanceWay>>(find.byType(RadioGroup<BalanceWay>)).groupValue, BalanceWay.transaction);
      await tester.enterText(find.byType(TextField).last, '800');
      if (way == BalanceWay.opening) await tester.tap(find.byKey(const ValueKey('balanceWay-opening')));
      await tester.pump();
      await tester.tap(find.text(l10n.commonDone));
      await tester.pump();
      for (var i = 0; i < 40 && money.state.book.balanceOf('wallet') != sar(800); i++) {
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
        await tester.pump();
      }
      expect(money.state.book.balanceOf('wallet'), sar(800));
      if (way == BalanceWay.opening) {
        expect(money.state.book.entries, hasLength(entriesBefore));
        expect(money.state.book.balanceOf('category.other'), spentBefore);
      } else {
        expect(money.state.book.entries, hasLength(entriesBefore + 1));
        expect(money.state.book.balanceOf('category.other'), spentBefore + sar(92.31));
      }
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  group('pasting a screenshot', () {
    final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    tearDown(() => messenger.setMockMethodCallHandler(PastedFiles.channel, null));

    Widget opener() => Builder(builder: (context) => Scaffold(body: TextButton(onPressed: () => showImportSheet(context), child: const Text('open'))));

    testWidgets('is offered when the clipboard has a file or screenshot, and imports them', (tester) async {
      await tester.runAsync(seed);
      size(tester, const Size(390, 1200));
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      messenger.setMockMethodCallHandler(PastedFiles.channel, (call) async => call.method == 'hasPastedFile');
      final before = importer.state.items.length;
      await tester.pumpWidget(wrap(opener(), const Locale('en')));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text(l10n.importFromClipboard), findsOneWidget);
      expect(find.byKey(const ValueKey('importPaste')), findsOneWidget);
      // The system Paste button sends the image; the sheet closes and the
      // file is added.
      await messenger.handlePlatformMessage(
        PastedFiles.pastes.name,
        PastedFiles.pastes.codec.encodeMethodCall(MethodCall('pasted', [
          {'ext': 'png', 'bytes': Uint8List.fromList([9, 9, 9])},
          {'name': 'November statement', 'ext': 'pdf', 'bytes': Uint8List.fromList([7, 7])},
        ])),
        (_) {},
      );
      for (var i = 0; i < 100 && importer.state.items.length < before + 2; i++) {
        await tester.pump(const Duration(milliseconds: 100));
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
      }
      await tester.pump(const Duration(milliseconds: 300));
      // A screenshot without a name is named for when it was pasted; a
      // copied file keeps its own name.
      final pasted = importer.state.items.where((i) => i.file.name.startsWith(l10n.importPastedName)).single.file;
      expect(pasted.extension, 'png');
      expect(importer.state.items.where((i) => i.file.name == 'November statement.pdf'), hasLength(1));
      expect(find.byType(ImportReviewScreen), findsOneWidget);
    });

    testWidgets('is not offered when the clipboard has nothing to import', (tester) async {
      await tester.runAsync(seed);
      size(tester, const Size(390, 1200));
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      messenger.setMockMethodCallHandler(PastedFiles.channel, (call) async => call.method == 'hasPastedFile' ? false : null);
      await tester.pumpWidget(wrap(opener(), const Locale('en')));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text(l10n.importFromPhotos), findsOneWidget);
      expect(find.text(l10n.importFromClipboard), findsNothing);
    });
  });

  group('bank messages', () {
    final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    tearDown(() {
      debugDefaultTargetPlatformOverride = null;
      messenger.setMockMethodCallHandler(BankMessages.sms, null);
      messenger.setMockMethodCallHandler(PastedFiles.channel, null);
    });

    testWidgets('Android: turning it on asks for the permission, then recent messages can be brought in', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      await tester.runAsync(seed);
      size(tester, const Size(320, 900));
      final l10n = await AppLocalizations.delegate.load(const Locale('ar'));
      final calls = <String>[];
      var on = false;
      messenger.setMockMethodCallHandler(BankMessages.sms, (call) async {
        calls.add(call.method);
        if (call.method == 'enable') on = true;
        if (call.method == 'disable') on = false;
        if (call.method == 'importRecent') return 0;
        return {'granted': on, 'enabled': on};
      });
      await tester.pumpWidget(wrap(const BankMessagesScreen(), const Locale('ar')));
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
      expect(tester.widget<ListTile>(find.byKey(const ValueKey('bankMessagesRecent'))).enabled, isFalse);

      await tester.tap(find.byKey(const ValueKey('bankMessagesSwitch')));
      await tester.pump(const Duration(milliseconds: 300));
      expect(calls, ['status', 'enable']);
      expect(tester.widget<SwitchListTile>(find.byKey(const ValueKey('bankMessagesSwitch'))).value, isTrue);

      await tester.tap(find.byKey(const ValueKey('bankMessagesRecent')));
      for (var i = 0; i < 50 && find.text(l10n.bankMessagesFound(0)).evaluate().isEmpty; i++) {
        await tester.pump(const Duration(milliseconds: 100));
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
      }
      expect(calls.last, 'importRecent');
      expect(find.text(l10n.bankMessagesFound(0)), findsOneWidget);
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('iOS: the Shortcuts steps, and the sheet leads there', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      await tester.runAsync(seed);
      size(tester, const Size(390, 1200));
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      final opened = <String>[];
      messenger.setMockMethodCallHandler(PastedFiles.channel, (call) async {
        opened.add(call.method);
        return call.method == 'hasPastedFile' ? false : null;
      });
      await tester.pumpWidget(wrap(Builder(builder: (context) => Scaffold(body: TextButton(onPressed: () => showImportSheet(context), child: const Text('open')))), const Locale('en')));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('importBankMessages')));
      await tester.pumpAndSettle();
      expect(find.byType(BankMessagesScreen), findsOneWidget);
      expect(find.text(l10n.bankMessagesStep4), findsOneWidget);
      expect(find.byKey(const ValueKey('bankMessagesSwitch')), findsNothing);
      await tester.tap(find.byKey(const ValueKey('bankMessagesShortcuts')));
      await tester.pump();
      expect(opened, contains('openShortcuts'));
      debugDefaultTargetPlatformOverride = null;
    });
  });

  group('speaking a transaction', () {
    late _SpokenWords voice;

    /// The app cubit with a mic that hears what the test says.
    Future<void> withVoice() async {
      voice = _SpokenWords();
      final old = app;
      app = AppCubit(repository: _OfflineRepository(), bookStore: old.bookStore, dictation: voice);
      app.emit(old.state);
      await old.close();
    }

    Future<void> say(WidgetTester tester, String words, AppLocalizations l10n) async {
      await tester.tap(find.byTooltip(l10n.dictationStart));
      await tester.pump();
      voice.session!.add(DictationPartial(words.split(' ').first));
      await tester.pump();
      expect(find.byKey(const ValueKey('entryHeard')), findsOneWidget);
      voice.session!
        ..add(DictationFinal(words))
        ..close();
      await tester.pump();
      await tester.pump();
    }

    testWidgets('a spend fills in as said, with the category it usually has, and saves only on Save', (tester) async {
      await tester.runAsync(seed);
      await withVoice();
      size(tester, const Size(390, 1400));
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      final before = money.state.book.entries.length;
      await tester.pumpWidget(wrap(const EntryEditorScreen(kind: EntryKind.spend), const Locale('en')));
      await tester.pump(const Duration(milliseconds: 300));
      await say(tester, 'Spent 45.50 at Panda with Visa yesterday', l10n);
      expect(find.text('\u201cSpent 45.50 at Panda with Visa yesterday\u201d'), findsOneWidget);
      expect(find.widgetWithText(TextField, '45.50'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Panda'), findsOneWidget);
      expect(money.state.book.entries, hasLength(before));

      await tester.tap(find.text(l10n.holdingsSave));
      for (var i = 0; i < 50 && money.state.book.entries.length == before; i++) {
        await tester.pump(const Duration(milliseconds: 100));
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
      }
      final saved = money.state.entriesNewestFirst.firstWhere((e) => e.merchant == 'Panda' && e.lines.any((l) => l.accountId == 'visa'));
      final now = DateTime.now();
      expect(saved.date, DateTime(now.year, now.month, now.day - 1));
      expect(saved.lines.firstWhere((l) => l.accountId == 'visa').amount, -sar(45.50));
      expect(saved.lines.any((l) => l.accountId == 'category.groceries'), isTrue);
    });

    testWidgets('a transfer moves to its tab with both accounts; nothing understood says so', (tester) async {
      await tester.runAsync(seed);
      await withVoice();
      size(tester, const Size(390, 1400));
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      await tester.pumpWidget(wrap(const EntryEditorScreen(kind: EntryKind.spend), const Locale('en')));
      await tester.pump(const Duration(milliseconds: 300));
      await say(tester, 'transferred 500 from Al Rajhi to my wallet', l10n);
      expect(tester.widget<SegmentedButton<EntryKind>>(find.byKey(const ValueKey('entryKindTabs'))).selected, {EntryKind.transfer});
      expect(find.widgetWithText(TextField, '500'), findsOneWidget);
      expect(find.textContaining('Al Rajhi current account'), findsOneWidget);
      expect(find.textContaining('Wallet'), findsOneWidget);

      await say(tester, 'hello there', l10n);
      expect(find.text(l10n.entryVoiceNothing), findsOneWidget);
      expect(find.widgetWithText(TextField, '500'), findsOneWidget);
    });
  });

  testWidgets('to categorize: one pick sorts a merchant\'s entries, is remembered, and can be forgotten', (tester) async {
    await tester.runAsync(seed);
    size(tester, const Size(390, 2400));
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    final rajhi = money.state.book.accounts['rajhi']!;
    final un = money.state.book.accounts[SystemAccount.uncategorized.id]!;
    await tester.runAsync(() async {
      await money.saveEntry(money.builder.spend(rajhi, un, sar(40), DateTime(2026, 11, 1), merchant: 'FT26AA01 - PayeeName Gym Club'));
      await money.saveEntry(money.builder.spend(rajhi, un, sar(40), DateTime(2026, 11, 8), merchant: 'FT26AA02 - PayeeName Gym Club'));
    });

    await tester.pumpWidget(wrap(const MoneyScreen(), const Locale('en')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text(l10n.toCategorizeCount(2)), findsOneWidget);

    await tester.pumpWidget(wrap(const ToCategorizeScreen(), const Locale('en')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text(l10n.importCategory));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.catHealth));
    await tester.pumpAndSettle();
    // The save started from the tap: let its storage finish between frames.
    for (var i = 0; i < 40 && money.state.uncategorized.isNotEmpty; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pump();
    }
    await tester.pumpAndSettle();
    expect(money.state.uncategorized, isEmpty);
    expect(money.state.settings.categoryRules, {'out:gym club': 'category.health'});
    expect(find.text(l10n.toCategorizeEmpty), findsOneWidget);

    await tester.pumpWidget(wrap(const CategoriesScreen(), const Locale('en')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text(l10n.categoriesLearned), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('rule:out:gym club')));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.categoriesForget));
    await tester.pumpAndSettle();
    // The save started from the tap: let its storage finish between frames.
    for (var i = 0; i < 40 && money.state.settings.categoryRules.isNotEmpty; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pump();
    }
    await tester.pumpAndSettle();
    expect(money.state.settings.categoryRules, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Home shows the import banner while files wait', (tester) async {
    await tester.runAsync(seed);
    size(tester, const Size(390, 3000));
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    await tester.pumpWidget(wrap(const HomeScreen(), const Locale('en')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text(l10n.importBannerTitle), findsOneWidget);
    expect(find.text(l10n.importReadyRows(4)), findsOneWidget);
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

  testWidgets('Home draws net worth over time with the ranges, and holdings with their split', (tester) async {
    await tester.runAsync(seed);
    SharedPreferences.setMockInitialValues({});
    app.preferences = (await tester.runAsync(Preferences.create))!;
    final gold = InstrumentCatalog.instrument('metal.XAU')!;
    final silver = InstrumentCatalog.instrument('metal.XAG')!;
    final now = DateTime.now();
    app.emit(app.state.copyWith(
      rates: FXRates(base: 'SAR', rates: const {'SAR': 1, 'EGP': 13, 'USD': 0.2667}, updatedAt: now),
      lots: [
        HoldingLot(id: 'l1', instrumentID: gold.id, quantity: 2, unit: PriceUnit.troyOunce, unitCost: 1900, costCurrency: 'USD', date: DateTime(now.year, now.month - 1)),
        HoldingLot(id: 'l2', instrumentID: silver.id, quantity: 10, unit: PriceUnit.troyOunce, unitCost: 22, costCurrency: 'USD', date: DateTime(now.year, now.month - 1)),
      ],
      seriesByID: {
        gold.id: QuoteSeries(instrumentID: gold.id, quotes: [Quote(instrumentID: gold.id, timestamp: now, canonicalUSD: 2000)]),
        silver.id: QuoteSeries(instrumentID: silver.id, quotes: [Quote(instrumentID: silver.id, timestamp: now, canonicalUSD: 25)]),
      },
      lastRefresh: DateTime(now.year, now.month, now.day, 9, 38),
    ));
    size(tester, const Size(390, 3000));
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    await tester.pumpWidget(wrap(const HomeScreen(), const Locale('en')));
    await tester.pump(const Duration(milliseconds: 600));

    // The net worth chart, and the ranges switch it without leaving Home.
    expect(find.descendant(of: find.byKey(const ValueKey('netWorthChart')), matching: find.byType(PriceChartView)), findsOneWidget);
    await tester.tap(find.text(displayLabelFor(l10n, ChartRange.year1.labelKey)).first);
    await tester.pump(const Duration(milliseconds: 300));
    expect(app.state.preferredPortfolioRange, ChartRange.year1);
    expect(find.byType(BalanceSheetScreen), findsNothing);

    // Holdings: count and price time, then each holding's share.
    final card = find.byKey(const ValueKey('holdingsCard'));
    expect(card, findsOneWidget);
    expect(find.descendant(of: card, matching: find.textContaining('${l10n.holdingsCount(2)} · ${l10n.pricesAt('09:38')}')), findsOneWidget);
    expect(find.byKey(const ValueKey('holdingsSplit')), findsOneWidget);
    expect(find.descendant(of: card, matching: find.text('94%')), findsOneWidget);
    expect(find.descendant(of: card, matching: find.text('6%')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
