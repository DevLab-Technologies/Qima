import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qima/blocs/app_cubit.dart';
import 'package:qima/l10n/app_localizations.dart';
import 'package:qima/l10n/app_localizations_en.dart';
import 'package:qima/models/asset.dart';
import 'package:qima/models/holding_transaction.dart';
import 'package:qima/models/money.dart';
import 'package:qima/models/quote.dart';
import 'package:qima/screens/csv_import_screen.dart';
import 'package:qima/services/csv/csv_import.dart';
import 'package:qima/services/holdings_store.dart';
import 'package:qima/services/preferences.dart';
import 'package:qima/services/price_repository.dart';
import 'package:qima/services/transactions_store.dart';
import 'package:qima/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _OfflineRepository extends PriceRepository {
  @override
  Future<QuoteSeries> refresh(Instrument instrument, {DateTime? now}) async => QuoteSeries.empty(instrument.id);

  @override
  Future<Map<String, QuoteSeries>> refreshAll(List<Instrument> instruments, {DateTime? now}) async => const {};

  @override
  Future<QuoteSeries> cachedSeries(Instrument instrument) async => QuoteSeries.empty(instrument.id);
}

class _MemoryTransactionsStore extends TransactionsStore {
  final Map<String, HoldingTransaction> rows = {};

  _MemoryTransactionsStore() : super(legacyLots: HoldingsStore());

  @override
  Future<List<HoldingTransaction>> load() async => rows.values.toList();

  @override
  Future<List<HoldingTransaction>> addAll(List<HoldingTransaction> transactions) async {
    for (final t in transactions) {
      rows[t.id] = t;
    }
    return rows.values.toList();
  }

  @override
  Future<List<HoldingTransaction>> deleteAll(Iterable<String> ids) async {
    ids.forEach(rows.remove);
    return rows.values.toList();
  }
}

void main() {
  final en = AppLocalizationsEn();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  void phone(WidgetTester tester) {
    tester.view.physicalSize = const Size(1170, 4200);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
  }

  Future<AppCubit> cubit() async {
    final c = AppCubit(repository: _OfflineRepository(), transactionsStore: _MemoryTransactionsStore());
    c.preferences = await Preferences.create();
    c.emit(c.state.copyWith(
      initialized: true,
      baseCurrency: 'SAR',
      rates: FXRates(base: 'USD', rates: const {'USD': 1, 'SAR': 3.75}, updatedAt: DateTime(2026)),
    ));
    return c;
  }

  Widget harness(AppCubit c, Widget home) => BlocProvider<AppCubit>.value(
        value: c,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: buildTheme(Brightness.dark),
          home: home,
        ),
      );

  const csv = 'Date,Ticker,Side,Qty,Price,Currency\n'
      '2026-01-05,BTC,Buy,1,50000,USD\n'
      '2026-02-05,BTC,Sell,3,60000,USD\n'
      '2026-03-05,Nope,Buy,1,1,USD\n'
      '2026-04-05,XAU,Buy,2,3000,\n';

  testWidgets('maps, previews, imports and undoes', (tester) async {
    phone(tester);
    final c = await cubit();
    await tester.pumpWidget(harness(c, const CsvImportScreen(fileName: 'broker.csv', text: csv)));
    await tester.pumpAndSettle();

    expect(find.text('broker.csv'), findsOneWidget);
    expect(find.text(en.csvImportRowCount(4)), findsOneWidget);
    // Auto-mapped: the Ticker column feeds Symbol.
    final symbolRow = find.ancestor(of: find.text(en.csvFieldSymbol), matching: find.byType(Row)).first;
    expect(find.descendant(of: symbolRow, matching: find.textContaining('Ticker')), findsOneWidget);
    // The fallback currency starts at the base currency.
    expect(find.text('SAR'), findsOneWidget);

    await tester.tap(find.text(en.csvImportReview));
    await tester.pumpAndSettle();

    // BTC buy and XAU buy are ready; the oversized sale and the unknown
    // asset are skipped with their reasons.
    expect(find.text(en.csvImportConfirm(2)), findsOneWidget);
    expect(find.textContaining(en.csvProblemOversell), findsOneWidget);
    expect(find.textContaining(en.csvProblemUnknownAsset), findsOneWidget);

    await tester.tap(find.text(en.csvImportShowProblems));
    await tester.pumpAndSettle();
    expect(find.text(en.csvImportSkipped), findsNWidgets(2));

    await tester.tap(find.text(en.csvImportConfirm(2)));
    await tester.pumpAndSettle();
    expect(find.text(en.csvImportDoneTitle(2)), findsOneWidget);
    expect(c.state.transactions, hasLength(2));
    expect(c.state.transactions.firstWhere((t) => t.instrumentID == 'metal.XAU').currency, 'SAR',
        reason: 'an empty currency cell takes the fallback');

    await tester.tap(find.text(en.csvImportUndo));
    await tester.pumpAndSettle();
    expect(c.state.transactions, isEmpty);
  });

  testWidgets('re-importing the same file finds only duplicates', (tester) async {
    phone(tester);
    final c = await cubit();
    const file = 'Date,Symbol,Quantity,Price\n2026-01-05,BTC,1,50000\n';
    await tester.pumpWidget(harness(c, const CsvImportScreen(fileName: 'a.csv', text: file)));
    await tester.pumpAndSettle();
    await tester.tap(find.text(en.csvImportReview));
    await tester.pumpAndSettle();
    await tester.tap(find.text(en.csvImportConfirm(1)));
    await tester.pumpAndSettle();

    await tester.pumpWidget(harness(c, const CsvImportScreen(fileName: 'a.csv', text: file, key: ValueKey('again'))));
    await tester.pumpAndSettle();
    await tester.tap(find.text(en.csvImportReview));
    await tester.pumpAndSettle();
    expect(find.text(en.csvImportConfirm(0)), findsOneWidget);
    expect(find.text(en.csvImportDuplicate), findsOneWidget);
    expect(tester.widget<FilledButton>(find.widgetWithText(FilledButton, en.csvImportConfirm(0))).onPressed, isNull);
  });

  testWidgets('without enough columns, review is disabled and says why', (tester) async {
    phone(tester);
    final c = await cubit();
    await tester.pumpWidget(harness(c, const CsvImportScreen(fileName: 'x.csv', text: 'Foo,Bar\n1,2\n')));
    await tester.pumpAndSettle();
    expect(find.text(en.csvImportNeedsColumns), findsOneWidget);
    expect(tester.widget<FilledButton>(find.widgetWithText(FilledButton, en.csvImportReview)).onPressed, isNull);
  });

  testWidgets('ambiguous dates ask which order they are in', (tester) async {
    phone(tester);
    final c = await cubit();
    await tester.pumpWidget(harness(
        c, const CsvImportScreen(fileName: 'd.csv', text: 'Date,Symbol,Quantity,Price\n03/04/2026,BTC,1,1\n')));
    await tester.pumpAndSettle();
    expect(find.text(en.csvImportDateOrder), findsOneWidget);
    expect(find.byType(SegmentedButton<DateOrder>), findsOneWidget);
  });

  testWidgets('a header with no rows says so', (tester) async {
    phone(tester);
    final c = await cubit();
    await tester.pumpWidget(harness(c, const CsvImportScreen(fileName: 'e.csv', text: 'Date,Symbol\n')));
    await tester.pumpAndSettle();
    expect(find.text(en.csvImportEmptyFile), findsOneWidget);
  });
}
