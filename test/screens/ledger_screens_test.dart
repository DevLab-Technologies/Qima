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
import 'package:qima/models/instrument_catalog.dart';
import 'package:qima/models/metal_breakdown.dart';
import 'package:qima/models/money.dart';
import 'package:qima/models/quote.dart';
import 'package:qima/screens/holdings_screen.dart';
import 'package:qima/screens/transaction_editor_screen.dart';
import 'package:qima/services/local_file_store.dart';
import 'package:qima/services/holdings_store.dart';
import 'package:qima/services/preferences.dart';
import 'package:qima/services/transactions_store.dart';
import 'package:qima/services/price_repository.dart';
import 'package:qima/theme/app_theme.dart';
import 'package:qima/theme/masking.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Never touches the network: a save that starts tracking a new instrument
/// would otherwise try to fetch its price.
class _OfflineRepository extends PriceRepository {
  @override
  Future<QuoteSeries> refresh(Instrument instrument, {DateTime? now}) async => QuoteSeries.empty(instrument.id);

  @override
  Future<QuoteSeries> cachedSeries(Instrument instrument) async => QuoteSeries.empty(instrument.id);
}

/// In memory, so saves complete inside the widget test's fake clock.
class _MemoryTransactionsStore extends TransactionsStore {
  final Map<String, HoldingTransaction> _rows = {};

  _MemoryTransactionsStore() : super(legacyLots: HoldingsStore());

  List<HoldingTransaction> get _all => _rows.values.toList();

  @override
  Future<List<HoldingTransaction>> load() async => _all;

  @override
  Future<List<HoldingTransaction>> upsert(HoldingTransaction transaction) async {
    _rows[transaction.id] = transaction;
    return _all;
  }

  @override
  Future<List<HoldingTransaction>> delete(String id) async {
    _rows.remove(id);
    return _all;
  }
}

void main() {
  final en = AppLocalizationsEn();
  final gold = InstrumentCatalog.instrument('metal.XAU')!;
  const goldOz = 3110.34768; // $100/g

  late Directory dir;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    dir = await Directory.systemTemp.createTemp('qima_ledger_screens_test');
    LocalFileStore.overrideDirectoryForTesting(dir);
  });

  tearDown(() async {
    if (await dir.exists()) await dir.delete(recursive: true);
  });

  void phone(WidgetTester tester, {double height = 2532}) {
    tester.view.physicalSize = Size(1170, height);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
  }

  HoldingTransaction tx(String id, TransactionKind kind, double qty, double price, DateTime date,
          {double fee = 0, GoldKarat? karat}) =>
      HoldingTransaction(
        id: id,
        instrumentID: gold.id,
        kind: kind,
        quantity: qty,
        unit: PriceUnit.gram,
        karat: karat,
        unitPrice: price,
        fee: fee,
        currency: 'USD',
        date: date,
      );

  Future<AppCubit> cubitWith(List<HoldingTransaction> transactions, {bool hidden = false}) async {
    final store = _MemoryTransactionsStore();
    for (final t in transactions) {
      await store.upsert(t);
    }
    final cubit = AppCubit(repository: _OfflineRepository(), transactionsStore: store);
    cubit.preferences = await Preferences.create();
    cubit.emit(cubit.state.copyWith(
      initialized: true,
      transactions: transactions,
      seriesByID: {
        gold.id: QuoteSeries(
            instrumentID: gold.id, quotes: [Quote(instrumentID: gold.id, timestamp: DateTime(2026, 10, 1), canonicalUSD: goldOz)]),
      },
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

  final ledger = [
    tx('b1', TransactionKind.buy, 100, 80, DateTime(2026, 1, 10)),
    tx('s1', TransactionKind.sell, 30, 110, DateTime(2026, 3, 1), fee: 10),
    tx('f1', TransactionKind.fee, 0, 0, DateTime(2026, 4, 1), fee: 5),
  ];

  group('HoldingsScreen ledger', () {
    testWidgets('summarises holding, average cost, unrealised and realised', (tester) async {
      phone(tester);
      final cubit = await cubitWith(ledger);
      await tester.pumpWidget(harness(cubit, HoldingsScreen(instrument: gold, displayCurrency: 'USD', refUnit: PriceUnit.gram)));
      await tester.pumpAndSettle();
      expect(find.text('70 g'), findsOneWidget);
      expect(find.text(en.ledgerPerUnit(usd(80), en.unitAbbrGram)), findsOneWidget);
      // 30 g sold for 3,300 − 10 fee − 2,400 basis = 890; then a 5 fee.
      expect(find.textContaining(usd(885)), findsWidgets);
      expect(find.text(en.transactionKindSell), findsOneWidget);
      expect(find.text(en.transactionKindFee), findsWidgets);
    });

    testWidgets('lists newest first', (tester) async {
      phone(tester);
      final cubit = await cubitWith(ledger);
      await tester.pumpWidget(harness(cubit, HoldingsScreen(instrument: gold, displayCurrency: 'USD')));
      await tester.pumpAndSettle();
      final feeY = tester.getTopLeft(find.text(en.transactionKindFee).first).dy;
      final buyY = tester.getTopLeft(find.text(en.transactionKindBuy)).dy;
      expect(feeY, lessThan(buyY));
    });

    testWidgets('hidden balances mask the holding and money, not the average cost', (tester) async {
      phone(tester);
      final cubit = await cubitWith(ledger, hidden: true);
      await tester.pumpWidget(harness(cubit, HoldingsScreen(instrument: gold, displayCurrency: 'USD', refUnit: PriceUnit.gram)));
      await tester.pumpAndSettle();
      expect(find.text('70 g'), findsNothing);
      expect(find.textContaining('885'), findsNothing);
      expect(find.text(en.ledgerPerUnit(usd(80), en.unitAbbrGram)), findsOneWidget);
    });

    testWidgets('a sold-out holding says nothing is held and keeps its realised result', (tester) async {
      phone(tester);
      final cubit = await cubitWith([
        tx('b1', TransactionKind.buy, 10, 80, DateTime(2026, 1, 10)),
        tx('s1', TransactionKind.sell, 10, 100, DateTime(2026, 2, 1)),
      ]);
      await tester.pumpWidget(harness(cubit, HoldingsScreen(instrument: gold, displayCurrency: 'USD')));
      await tester.pumpAndSettle();
      expect(find.text(en.ledgerNothingHeld), findsOneWidget);
      expect(find.textContaining(usd(200)), findsWidgets);
    });

    testWidgets('an overdrawn row from a sync conflict is flagged', (tester) async {
      phone(tester);
      final cubit = await cubitWith([
        tx('b1', TransactionKind.buy, 10, 80, DateTime(2026, 1, 10)),
        tx('s1', TransactionKind.sell, 15, 100, DateTime(2026, 2, 1)),
      ]);
      await tester.pumpWidget(harness(cubit, HoldingsScreen(instrument: gold, displayCurrency: 'USD')));
      await tester.pumpAndSettle();
      expect(find.text(en.ledgerOverdrawnBanner), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsWidgets);
    });

    testWidgets('deleting a buy a later sale depends on is refused with the reason', (tester) async {
      phone(tester);
      final cubit = await cubitWith(ledger);
      await tester.pumpWidget(harness(cubit, HoldingsScreen(instrument: gold, displayCurrency: 'USD')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(en.transactionKindBuy));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip(en.commonDelete));
      await tester.pumpAndSettle();
      expect(find.text(en.ledgerConflictDeleteTitle), findsOneWidget);
      expect(cubit.state.transactions, hasLength(3));
    });

    testWidgets('empty ledger offers to add the first transaction', (tester) async {
      phone(tester);
      final cubit = await cubitWith(const []);
      await tester.pumpWidget(harness(cubit, HoldingsScreen(instrument: gold, displayCurrency: 'USD')));
      await tester.pumpAndSettle();
      expect(find.text(en.ledgerAddFirst), findsOneWidget);
    });

    testWidgets('renders in Arabic without overflow', (tester) async {
      phone(tester);
      final cubit = await cubitWith(ledger);
      await tester.pumpWidget(
          harness(cubit, HoldingsScreen(instrument: gold, displayCurrency: 'USD'), locale: const Locale('ar')));
      await tester.pumpAndSettle();
      expect(find.text(AppLocalizationsAr().transactionKindSell), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('TransactionEditorScreen', () {
    Future<void> save(WidgetTester tester) async {
      await tester.tap(find.widgetWithText(TextButton, en.holdingsSave));
      await tester.pumpAndSettle();
    }

    Future<void> type(WidgetTester tester, String label, String text) async {
      await tester.enterText(find.widgetWithText(TextField, label), text);
      await tester.pumpAndSettle();
    }

    testWidgets('a sell previews its realised gain and saves', (tester) async {
      phone(tester, height: 4200);
      final cubit = await cubitWith([tx('b1', TransactionKind.buy, 100, 80, DateTime(2026, 1, 10))]);
      await tester.pumpWidget(harness(cubit, TransactionEditorScreen(instrument: gold, defaultCurrency: 'USD')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(en.transactionKindSell));
      await tester.pumpAndSettle();
      await type(tester, en.holdingsQuantity, '25');
      await type(tester, en.transactionSalePrice(en.transactionPerUnitKarat(en.unitGram, en.karatShort24)), '120');
      await type(tester, en.transactionFee, '5');
      // 25 × 120 = 3,000; basis 2,000; fee 5 → +995.
      expect(find.text(en.transactionPreviewTitle.toUpperCase()), findsOneWidget);
      expect(find.textContaining(usd(995)), findsOneWidget);
      await save(tester);
      final sell = cubit.state.transactions.firstWhere((t) => t.kind == TransactionKind.sell);
      expect(sell.quantity, 25);
      expect(sell.fee, 5);
    });

    testWidgets('selling more than is held is refused inline', (tester) async {
      phone(tester, height: 4200);
      final cubit = await cubitWith([tx('b1', TransactionKind.buy, 10, 80, DateTime(2026, 1, 10))]);
      await tester.pumpWidget(harness(cubit, TransactionEditorScreen(instrument: gold, defaultCurrency: 'USD')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(en.transactionKindSell));
      await tester.pumpAndSettle();
      await type(tester, en.holdingsQuantity, '11');
      await type(tester, en.transactionSalePrice(en.transactionPerUnitKarat(en.unitGram, en.karatShort24)), '100');
      expect(find.text(en.transactionMoreThanHeld('10 g')), findsOneWidget);
      expect(tester.widget<TextButton>(find.widgetWithText(TextButton, en.holdingsSave)).onPressed, isNull);
    });

    testWidgets('shrinking a buy below a later sale names that sale', (tester) async {
      phone(tester, height: 4200);
      final cubit = await cubitWith(ledger);
      await tester.pumpWidget(
          harness(cubit, TransactionEditorScreen(instrument: gold, defaultCurrency: 'USD', existing: ledger.first)));
      await tester.pumpAndSettle();
      await type(tester, en.holdingsQuantity, '20');
      expect(find.textContaining(en.transactionKindSell), findsWidgets);
      expect(tester.widget<TextButton>(find.widgetWithText(TextButton, en.holdingsSave)).onPressed, isNull);
    });

    testWidgets('a new row starts at the karat already held', (tester) async {
      phone(tester, height: 4200);
      final cubit = await cubitWith([tx('b1', TransactionKind.buy, 100, 80, DateTime(2026, 1, 10), karat: GoldKarat.k21)]);
      await tester.pumpWidget(harness(cubit, TransactionEditorScreen(instrument: gold, defaultCurrency: 'USD')));
      await tester.pumpAndSettle();
      final segmented = tester.widget<SegmentedButton<GoldKarat>>(find.byType(SegmentedButton<GoldKarat>));
      expect(segmented.selected, {GoldKarat.k21});
    });

    testWidgets('a fee needs only an amount', (tester) async {
      phone(tester, height: 4200);
      final cubit = await cubitWith([tx('b1', TransactionKind.buy, 10, 80, DateTime(2026, 1, 10))]);
      await tester.pumpWidget(harness(cubit, TransactionEditorScreen(instrument: gold, defaultCurrency: 'USD')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(en.transactionKindFee));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(TextField, en.holdingsQuantity), findsNothing);
      expect(find.text(en.transactionNeedsFee), findsOneWidget);
      await type(tester, en.transactionFeeAmount, '12,5');
      await save(tester);
      expect(cubit.state.transactions.firstWhere((t) => t.kind == TransactionKind.fee).fee, 12.5,
          reason: 'a comma decimal is accepted');
    });

    testWidgets('a transfer in may carry no cost', (tester) async {
      phone(tester, height: 4200);
      final cubit = await cubitWith(const []);
      await tester.pumpWidget(harness(cubit, TransactionEditorScreen(instrument: gold, defaultCurrency: 'USD')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(en.transactionKindTransfer));
      await tester.pumpAndSettle();
      await type(tester, en.holdingsQuantity, '5');
      await save(tester);
      final t = cubit.state.transactions.single;
      expect(t.kind, TransactionKind.transferIn);
      expect(t.unitPrice, 0);
    });
  });
}
