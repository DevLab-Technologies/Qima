import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qima/blocs/app_cubit.dart';
import 'package:qima/l10n/app_localizations.dart';
import 'package:qima/l10n/app_localizations_ar.dart';
import 'package:qima/l10n/app_localizations_en.dart';
import 'package:qima/models/asset.dart';
import 'package:qima/models/fx_history.dart';
import 'package:qima/models/holding_transaction.dart';
import 'package:qima/models/metal_breakdown.dart';
import 'package:qima/models/money.dart';
import 'package:qima/models/quote.dart';
import 'package:qima/screens/add_instrument_screen.dart';
import 'package:qima/screens/capture_review_screen.dart';
import 'package:qima/screens/holdings_screen.dart';
import 'package:qima/screens/transaction_editor_screen.dart';
import 'package:qima/services/holdings_store.dart';
import 'package:qima/services/local_file_store.dart';
import 'package:qima/services/preferences.dart';
import 'package:qima/services/price_repository.dart';
import 'package:qima/services/transactions_store.dart';
import 'package:qima/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _OfflineRepository extends PriceRepository {
  @override
  Future<QuoteSeries> refresh(Instrument instrument, {DateTime? now}) async => QuoteSeries.empty(instrument.id);

  @override
  Future<QuoteSeries> cachedSeries(Instrument instrument) async => QuoteSeries.empty(instrument.id);
}

class _MemoryTransactionsStore extends TransactionsStore {
  final Map<String, HoldingTransaction> rows = {};

  _MemoryTransactionsStore() : super(legacyLots: HoldingsStore());

  List<HoldingTransaction> get _all => rows.values.toList();

  @override
  Future<List<HoldingTransaction>> load() async => _all;

  @override
  Future<List<HoldingTransaction>> upsert(HoldingTransaction transaction) async {
    rows[transaction.id] = transaction;
    return _all;
  }

  @override
  Future<List<HoldingTransaction>> delete(String id) async {
    rows.remove(id);
    return _all;
  }
}

void main() {
  final en = AppLocalizationsEn();
  final ar = AppLocalizationsAr();
  late Directory dir;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    dir = await Directory.systemTemp.createTemp('qima_capture_flow_test');
    LocalFileStore.overrideDirectoryForTesting(dir);
  });

  tearDown(() async {
    if (await dir.exists()) await dir.delete(recursive: true);
  });

  void phone(WidgetTester tester) {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
  }

  Future<(AppCubit, _MemoryTransactionsStore)> cubit() async {
    final store = _MemoryTransactionsStore();
    final cubit = AppCubit(repository: _OfflineRepository(), transactionsStore: store);
    cubit.preferences = await Preferences.create();
    cubit.emit(cubit.state.copyWith(
      initialized: true,
      baseCurrency: 'EGP',
      rates: FXRates(base: 'USD', rates: const {'USD': 1, 'EGP': 50}, updatedAt: DateTime(2026)),
      fxHistory: FXHistory.empty,
    ));
    return (cubit, store);
  }

  Widget harness(AppCubit cubit, Widget home, {Locale locale = const Locale('en')}) => BlocProvider<AppCubit>.value(
        value: cubit,
        child: MaterialApp(
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: buildTheme(Brightness.dark),
          // A root route under Add, as the watchlist is in the app.
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => home)),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      );

  Future<void> openAdd(WidgetTester tester, AppCubit cubit, {Locale locale = const Locale('en')}) async {
    await tester.pumpWidget(harness(cubit, const AddInstrumentScreen(), locale: locale));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('a described purchase is offered, checked and recorded', (tester) async {
    phone(tester);
    final (c, store) = await cubit();
    await openAdd(tester, c);

    await tester.enterText(find.byType(TextField), '20 g of 21K gold at 4,100 EGP, bought on the 12th');
    await tester.pumpAndSettle();
    expect(find.text(en.captureRecordThis), findsOneWidget);
    expect(find.textContaining('20 g · 21K'), findsOneWidget);

    await tester.tap(find.text(en.captureRecordThis));
    await tester.pumpAndSettle();
    expect(find.byType(CaptureReviewScreen), findsOneWidget);
    expect(find.text(en.captureCheckTitle), findsOneWidget);
    expect(find.text('20 g'), findsOneWidget);
    expect(find.text('${en.captureFrom('gold')} · ${en.captureFrom('21K')}'), findsOneWidget);
    expect(find.text(en.captureFrom('bought')), findsOneWidget);
    // Only the bare "the 12th" is a guess.
    expect(find.text(en.captureCheck), findsOneWidget);
    expect(store.rows, isEmpty, reason: 'nothing is saved before Confirm');

    await tester.tap(find.widgetWithText(FilledButton, en.captureConfirm));
    await tester.pumpAndSettle();

    final saved = store.rows.values.single;
    expect(saved.instrumentID, 'metal.XAU');
    expect(saved.kind, TransactionKind.buy);
    expect(saved.quantity, 20);
    expect(saved.unit, PriceUnit.gram);
    expect(saved.karat, GoldKarat.k21);
    expect(saved.unitPrice, 4100);
    expect(saved.currency, 'EGP');
    expect(saved.date.day, 12);
    expect(find.byType(HoldingsScreen), findsOneWidget);
    // Straight back to the root underneath — not through Add again.
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('open'), findsOneWidget);
  });

  testWidgets('an ordinary search shows no capture card', (tester) async {
    phone(tester);
    final (c, _) = await cubit();
    await openAdd(tester, c);
    await tester.enterText(find.byType(TextField), 'gold');
    await tester.pumpAndSettle();
    expect(find.text(en.captureRecordThis), findsNothing);
    expect(find.text(en.addSearchCustomTickerTitle('gold')), findsOneWidget);
  });

  testWidgets('a name from another language finds the asset and says which word matched', (tester) async {
    phone(tester);
    final (c, _) = await cubit();
    await openAdd(tester, c);
    await tester.enterText(find.byType(TextField), 'ذهب');
    await tester.pumpAndSettle();
    expect(find.text('Gold'), findsOneWidget);
    expect(find.text('XAU · ${en.addSearchMatchedAlias('ذهب')}'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Oro');
    await tester.pumpAndSettle();
    expect(find.text('XAU · ${en.addSearchMatchedAlias('Oro')}'), findsOneWidget);
  });

  testWidgets('without a price, Confirm is off and Edit fields opens the editor prefilled', (tester) async {
    phone(tester);
    final (c, store) = await cubit();
    await openAdd(tester, c);
    await tester.enterText(find.byType(TextField), '20 g gold');
    await tester.pumpAndSettle();
    await tester.tap(find.text(en.captureRecordThis));
    await tester.pumpAndSettle();

    expect(find.text(en.captureNeedsPrice), findsOneWidget);
    final confirm = tester.widget<FilledButton>(find.widgetWithText(FilledButton, en.captureConfirm));
    expect(confirm.onPressed, isNull);

    await tester.tap(find.text(en.captureEditFields));
    await tester.pumpAndSettle();
    expect(find.byType(TransactionEditorScreen), findsOneWidget);
    expect(find.widgetWithText(TextField, '20'), findsOneWidget);
    expect(find.text(en.transactionNewTitle), findsOneWidget, reason: 'a draft is a new row, not an edit');
    expect(store.rows, isEmpty);
  });

  testWidgets('a sale of more than is held is refused, and nothing is saved', (tester) async {
    phone(tester);
    final (c, store) = await cubit();
    await openAdd(tester, c);
    await tester.enterText(find.byType(TextField), 'sold 5 g gold at 4500 EGP');
    await tester.pumpAndSettle();
    await tester.tap(find.text(en.captureRecordThis));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, en.captureConfirm));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(store.rows, isEmpty);
    expect(find.byType(CaptureReviewScreen), findsOneWidget);
  });

  testWidgets('Arabic, with Arabic-Indic digits', (tester) async {
    phone(tester);
    final (c, store) = await cubit();
    await openAdd(tester, c, locale: const Locale('ar'));
    await tester.enterText(find.byType(TextField), 'اشتريت ٢٠ جرام ذهب عيار ٢١ بسعر ٤١٠٠ جنيه');
    await tester.pumpAndSettle();
    await tester.tap(find.text(ar.captureRecordThis));
    await tester.pumpAndSettle();
    expect(find.text(ar.captureCheckTitle), findsOneWidget);
    expect(find.text(ar.captureFrom('اشتريت')), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, ar.captureConfirm));
    await tester.pumpAndSettle();
    final saved = store.rows.values.single;
    expect(saved.quantity, 20);
    expect(saved.unitPrice, 4100);
    expect(saved.currency, 'EGP');
    expect(tester.takeException(), isNull);
  });
}
