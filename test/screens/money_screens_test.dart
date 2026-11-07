import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qima/blocs/app_cubit.dart';
import 'package:qima/blocs/import_cubit.dart';
import 'package:qima/blocs/money_cubit.dart';
import 'package:qima/l10n/app_localizations.dart';
import 'package:qima/models/asset.dart';
import 'package:qima/models/book_account.dart';
import 'package:qima/models/book_entry.dart';
import 'package:qima/models/fx_history.dart';
import 'package:qima/models/minor_units.dart';
import 'package:qima/models/money.dart';
import 'package:qima/models/money_settings.dart';
import 'package:qima/models/net_worth.dart';
import 'package:qima/models/quote.dart';
import 'package:qima/screens/money/accounts_screens.dart';
import 'package:qima/screens/money/asset_screens.dart';
import 'package:qima/screens/money/balance_sheet_screen.dart';
import 'package:qima/screens/money/categorize_screen.dart';
import 'package:qima/screens/money/entry_detail_screen.dart';
import 'package:qima/screens/money/entry_editor_screen.dart';
import 'package:qima/screens/money/home_screen.dart';
import 'package:qima/screens/money/import_screens.dart';
import 'package:qima/services/import/import_inbox_io.dart';
import 'package:qima/services/import/pasted_image.dart';
import 'package:qima/models/statement_reader.dart';
import 'package:qima/services/text_recognition_service.dart';
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
    await tester.runAsync(() async {
      await tester.tap(find.byKey(const ValueKey('importAdd')));
      for (var i = 0; i < 40 && importer.state.items.isNotEmpty; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      }
    });
    await tester.pump();
    expect(money.state.book.balanceOf('rajhi'), sar(25000));
    expect(tester.takeException(), isNull);
  });

  group('pasting a screenshot', () {
    final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    tearDown(() => messenger.setMockMethodCallHandler(PastedImage.channel, null));

    Widget opener() => Builder(builder: (context) => Scaffold(body: TextButton(onPressed: () => showImportSheet(context), child: const Text('open'))));

    testWidgets('is offered when the clipboard has an image, and imports it', (tester) async {
      await tester.runAsync(seed);
      size(tester, const Size(390, 1200));
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      messenger.setMockMethodCallHandler(PastedImage.channel, (call) async => call.method == 'hasPastedImage');
      final before = importer.state.items.length;
      await tester.pumpWidget(wrap(opener(), const Locale('en')));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text(l10n.importFromClipboard), findsOneWidget);
      expect(find.byKey(const ValueKey('importPaste')), findsOneWidget);
      // The system Paste button sends the image; the sheet closes and the
      // file is added.
      await messenger.handlePlatformMessage(
        PastedImage.pastes.name,
        PastedImage.pastes.codec.encodeMethodCall(MethodCall('pasted', Uint8List.fromList([9, 9, 9]))),
        (_) {},
      );
      for (var i = 0; i < 40 && importer.state.items.length == before; i++) {
        await tester.pump(const Duration(milliseconds: 100));
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
      }
      await tester.pump(const Duration(milliseconds: 300));
      final pasted = importer.state.items.where((i) => i.file.name.startsWith(l10n.importPastedName)).single.file;
      expect(pasted.extension, 'png');
      expect(find.byType(ImportReviewScreen), findsOneWidget);
    });

    testWidgets('is not offered when the clipboard has no image', (tester) async {
      await tester.runAsync(seed);
      size(tester, const Size(390, 1200));
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      messenger.setMockMethodCallHandler(PastedImage.channel, (call) async => call.method == 'hasPastedImage' ? false : null);
      await tester.pumpWidget(wrap(opener(), const Locale('en')));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text(l10n.importFromPhotos), findsOneWidget);
      expect(find.text(l10n.importFromClipboard), findsNothing);
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
}
