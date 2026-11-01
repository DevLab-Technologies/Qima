import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qima/blocs/app_cubit.dart';
import 'package:qima/l10n/app_localizations.dart';
import 'package:qima/l10n/app_localizations_en.dart';
import 'package:qima/models/asset.dart';
import 'package:qima/models/holding_transaction.dart';
import 'package:qima/models/instrument_catalog.dart';
import 'package:qima/models/metal_breakdown.dart';
import 'package:qima/models/transaction_capture.dart';
import 'package:qima/services/text_recognition_service.dart';
import 'package:qima/widgets/receipt_scan_button.dart';

class _FakeRecognition implements TextRecognitionService {
  final bool available;
  final List<String>? lines;
  List<String>? languages;
  _FakeRecognition({this.available = true, this.lines});

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<List<String>?> recognize(String imagePath, List<String> languageTags) async {
    languages = languageTags;
    return lines;
  }
}

void main() {
  final en = AppLocalizationsEn();
  final context = CaptureContext(
    catalog: InstrumentCatalog.all,
    displayName: (i) => i.nameKey,
    baseCurrency: 'EGP',
    currencies: const {'USD', 'EGP'},
    today: DateTime(2026, 11, 1),
  );

  group('receipts through the typed-capture parser', () {
    test('an English dealer receipt', () {
      final text = receiptText(const [
        'El Sagha Jewelry',
        'Invoice 10293',
        '12/10/2026',
        '',
        'Gold 21K',
        'Weight 20.5 g',
        'Price/g 4,100 EGP',
        'Total 84,050 EGP',
      ]);
      final d = TransactionCapture.parse(text, context)!;
      expect(d.kind.value, TransactionKind.buy);
      expect(d.instrument.value.id, 'metal.XAU');
      expect(d.quantity.value, 20.5);
      expect(d.unit.value, PriceUnit.gram);
      expect(d.karat?.value, GoldKarat.k21);
      expect(d.unitPrice?.value, 4100);
      expect(d.currency.value, 'EGP');
      expect(d.date.value, DateTime(2026, 10, 12));
    });

    test('an Arabic dealer receipt, year-first date', () {
      final text = receiptText(const [
        'مجوهرات الصاغة',
        'فاتورة رقم 10293',
        '2026/10/12',
        'ذهب عيار 21',
        'الوزن 20.5 جرام',
        'سعر الجرام 4100 جنيه',
        'الإجمالي 84050 جنيه',
      ]);
      final d = TransactionCapture.parse(text, context)!;
      expect(d.instrument.value.id, 'metal.XAU');
      expect(d.quantity.value, 20.5);
      expect(d.karat?.value, GoldKarat.k21);
      expect(d.unitPrice?.value, 4100);
      expect(d.date.value, DateTime(2026, 10, 12));
    });

    test('lines join into one field line, blanks dropped', () {
      expect(receiptText(const [' Gold 21K ', '', 'Weight 20 g']), 'Gold 21K · Weight 20 g');
    });
  });

  group('ReceiptScanButton', () {
    Future<List<String>> pump(WidgetTester tester, _FakeRecognition recognition, {String? path = '/tmp/r.jpg'}) async {
      final texts = <String>[];
      await tester.pumpWidget(
        BlocProvider<AppCubit>.value(
          value: AppCubit(textRecognition: recognition),
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: ReceiptScanButton(onText: texts.add, pickImage: (_) async => path),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      return texts;
    }

    testWidgets('hidden where text recognition is unavailable', (tester) async {
      await pump(tester, _FakeRecognition(available: false));
      expect(find.byTooltip(en.receiptScan), findsNothing);
    });

    testWidgets('the read text goes to the field', (tester) async {
      final recognition = _FakeRecognition(lines: const ['Gold 21K', 'Weight 20 g']);
      final texts = await pump(tester, recognition);
      await tester.tap(find.byTooltip(en.receiptScan));
      await tester.pumpAndSettle();
      expect(texts, ['Gold 21K · Weight 20 g']);
      expect(recognition.languages, contains('en-US'));
    });

    testWidgets('a photo with no text says so and leaves the field alone', (tester) async {
      final texts = await pump(tester, _FakeRecognition(lines: const []));
      await tester.tap(find.byTooltip(en.receiptScan));
      await tester.pumpAndSettle();
      expect(texts, isEmpty);
      expect(find.text(en.receiptNoText), findsOneWidget);
    });

    testWidgets('cancelling the photo does nothing', (tester) async {
      final recognition = _FakeRecognition(lines: const ['Gold']);
      final texts = await pump(tester, recognition, path: null);
      await tester.tap(find.byTooltip(en.receiptScan));
      await tester.pumpAndSettle();
      expect(texts, isEmpty);
      expect(recognition.languages, isNull);
    });
  });
}
