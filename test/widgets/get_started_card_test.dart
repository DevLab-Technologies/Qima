import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qima/blocs/app_cubit.dart';
import 'package:qima/blocs/app_state.dart';
import 'package:qima/blocs/money_cubit.dart';
import 'package:qima/l10n/app_localizations.dart';
import 'package:qima/models/asset.dart';
import 'package:qima/models/book_account.dart';
import 'package:qima/models/book_entry.dart';
import 'package:qima/models/fx_history.dart';
import 'package:qima/models/holding.dart';
import 'package:qima/models/money.dart';
import 'package:qima/models/money_settings.dart';
import 'package:qima/models/setup_answers.dart';
import 'package:qima/screens/money/accounts_screens.dart';
import 'package:qima/screens/money/home_screen.dart';
import 'package:qima/services/local_file_store.dart';
import 'package:qima/services/preferences.dart';
import 'package:qima/theme/app_theme.dart';
import 'package:qima/widgets/get_started_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Home's Get started card: when it shows, which steps it lists, that a
/// step ticks itself from what is in the app, and that closing it sticks.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const moneyAndPortfolio = SetupAnswers(uses: {SetupUse.money, SetupUse.portfolio});
  BookAccount account(AccountType type, {bool archived = false}) =>
      BookAccount(id: type.name, name: type.name, side: type == AccountType.credit ? AccountSide.owe : AccountSide.own, type: type, currency: 'USD', archived: archived);

  group('whether a step is done', () {
    final empty = MoneyState(loaded: true);

    test('an account is cash, a bank account or a card, not an asset or an archived one', () {
      expect(startTaskDone(StartTask.account, AppState(), empty), isFalse);
      expect(startTaskDone(StartTask.account, AppState(), MoneyState(loaded: true, accounts: [account(AccountType.asset)])), isFalse);
      expect(startTaskDone(StartTask.account, AppState(), MoneyState(loaded: true, accounts: [account(AccountType.cash, archived: true)])), isFalse);
      for (final type in [AccountType.cash, AccountType.debit, AccountType.credit]) {
        expect(startTaskDone(StartTask.account, AppState(), MoneyState(loaded: true, accounts: [account(type)])), isTrue, reason: type.name);
      }
    });

    test('an asset is one the person values themselves', () {
      expect(startTaskDone(StartTask.asset, AppState(), MoneyState(loaded: true, accounts: [account(AccountType.cash)])), isFalse);
      expect(startTaskDone(StartTask.asset, AppState(), MoneyState(loaded: true, accounts: [account(AccountType.asset)])), isTrue);
    });

    test('an opening balance is not a recorded transaction', () {
      BookEntry entry(EntryTemplate template) => BookEntry(id: template.name, date: DateTime(2024, 6, 1), template: template, baseCurrency: 'USD', lines: const []);
      expect(startTaskDone(StartTask.transaction, AppState(), MoneyState(loaded: true, entries: [entry(EntryTemplate.opening)])), isFalse);
      expect(startTaskDone(StartTask.transaction, AppState(), MoneyState(loaded: true, entries: [entry(EntryTemplate.valuation)])), isFalse);
      expect(startTaskDone(StartTask.transaction, AppState(), MoneyState(loaded: true, entries: [entry(EntryTemplate.spend)])), isTrue);
    });

    test('a holding is anything bought', () {
      final lot = HoldingLot(id: 'l', instrumentID: 'metal.XAU', quantity: 1, unit: PriceUnit.troyOunce, unitCost: 1900, costCurrency: 'USD', date: DateTime(2024, 5, 1));
      expect(startTaskDone(StartTask.holding, AppState(), empty), isFalse);
      expect(startTaskDone(StartTask.holding, AppState(lots: [lot]), empty), isTrue);
    });

    test('bank messages are done once the person has answered about them', () {
      expect(startTaskDone(StartTask.bankMessages, AppState(), empty), isFalse);
      expect(
        startTaskDone(StartTask.bankMessages, AppState(), MoneyState(loaded: true, settings: const MoneySettings(askedBankMessages: true))),
        isTrue,
      );
    });
  });

  group('whether the card shows', () {
    final loaded = MoneyState(loaded: true);

    test('not without setup answers, once closed, or before the book has loaded', () {
      expect(showsGetStarted(AppState(), loaded), isFalse);
      expect(showsGetStarted(AppState(setup: moneyAndPortfolio, getStartedDismissed: true), loaded), isFalse);
      expect(showsGetStarted(AppState(setup: moneyAndPortfolio), MoneyState()), isFalse);
      expect(showsGetStarted(AppState(setup: moneyAndPortfolio), loaded), isTrue);
    });

    test('not when the answers call for no steps, or every step is done', () {
      expect(showsGetStarted(AppState(setup: const SetupAnswers(uses: {SetupUse.zakat})), loaded), isFalse);
      final done = MoneyState(loaded: true, accounts: [account(AccountType.cash), account(AccountType.asset)]);
      expect(showsGetStarted(AppState(setup: const SetupAnswers(uses: {SetupUse.netWorth})), done), isFalse);
    });
  });

  group('on Home', () {
    late Directory tempDir;
    late AppCubit cubit;
    late MoneyCubit money;
    late AppLocalizations l10n;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('qima_get_started_test');
      LocalFileStore.overrideDirectoryForTesting(tempDir);
      SharedPreferences.setMockInitialValues({});
      l10n = await AppLocalizations.delegate.load(const Locale('en'));
      cubit = AppCubit();
      cubit.preferences = await Preferences.create();
      cubit.emit(cubit.state.copyWith(
        initialized: true,
        baseCurrency: 'USD',
        setup: moneyAndPortfolio,
        rates: FXRates(base: 'USD', rates: const {'USD': 1}, updatedAt: DateTime(2024, 6, 10)),
        fxHistory: FXHistory.empty,
      ));
      // Loaded here, on the real clock: the book reads files.
      money = MoneyCubit(store: cubit.bookStore, baseCurrency: () => cubit.state.baseCurrency, rates: () => cubit.state.rates);
      await cubit.bookStore.settings.upsert(const MoneySettings(seenWhatsNew: true));
      await money.load();
    });

    tearDown(() async {
      await money.close();
      await cubit.close();
      if (await tempDir.exists()) await tempDir.delete(recursive: true);
    });

    Widget harness({Locale locale = const Locale('en')}) => MultiBlocProvider(
          providers: [BlocProvider<AppCubit>.value(value: cubit), BlocProvider<MoneyCubit>.value(value: money)],
          child: MaterialApp(
            locale: locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: buildTheme(Brightness.light),
            home: const HomeScreen(),
          ),
        );

    testWidgets('takes the Start card\'s place and lists the steps for the answers', (tester) async {
      await tester.pumpWidget(harness());
      await tester.pump();

      expect(find.byType(GetStartedCard), findsOneWidget);
      expect(find.text(l10n.startTitle), findsNothing);
      expect(find.text(l10n.startCardProgress(1, 5)), findsOneWidget);
      for (final step in [l10n.startCardSetUp, l10n.startTaskAccount, l10n.startTaskTransaction, l10n.startTaskHolding, l10n.startTaskAlert]) {
        expect(find.text(step), findsOneWidget, reason: step);
      }
      // Nothing asked for an asset or bank messages.
      expect(find.text(l10n.startTaskAsset), findsNothing);
      expect(find.text(l10n.startTaskBankMessages), findsNothing);
    });

    testWidgets('a step opens the screen that does it', (tester) async {
      await tester.pumpWidget(harness());
      await tester.pump();

      await tester.tap(find.text(l10n.startTaskAccount));
      await tester.pumpAndSettle();

      expect(find.byType(AccountEditorScreen), findsOneWidget);
    });

    testWidgets('closing it hides it for good and brings the Start card back', (tester) async {
      await tester.pumpWidget(harness());
      await tester.pump();

      await tester.tap(find.byTooltip(l10n.startCardDismiss));
      await tester.pumpAndSettle();

      expect(find.byType(GetStartedCard), findsNothing);
      expect(find.text(l10n.startTitle), findsOneWidget);
      expect(cubit.preferences.getStartedDismissed, isTrue);
    });

    testWidgets('without setup answers Home is as it was', (tester) async {
      cubit.emit(AppState(initialized: true, baseCurrency: 'USD', rates: cubit.state.rates, fxHistory: FXHistory.empty));
      await tester.pumpWidget(harness());
      await tester.pump();

      expect(find.byType(GetStartedCard), findsNothing);
      expect(find.text(l10n.startTitle), findsOneWidget);
    });

    testWidgets('lays out in Arabic', (tester) async {
      final ar = await AppLocalizations.delegate.load(const Locale('ar'));
      await tester.pumpWidget(harness(locale: const Locale('ar')));
      await tester.pump();

      expect(find.text(ar.startCardTitle), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
