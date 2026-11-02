import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qima/blocs/app_cubit.dart';
import 'package:qima/l10n/app_localizations.dart';
import 'package:qima/models/instrument_catalog.dart';
import 'package:qima/models/metal_breakdown.dart';
import 'package:qima/models/transaction_capture.dart';
import 'package:qima/screens/add_instrument_screen.dart';
import 'package:qima/services/dictation_service.dart';
import 'package:qima/services/text_recognition_service.dart';
import 'package:qima/widgets/add_sheet.dart';

class _Dictation extends NoDictation {
  final DictationAvailability value;
  const _Dictation(this.value);

  @override
  Future<DictationAvailability> availability(String localeTag) async => value;
}

class _Recognition extends NoTextRecognition {
  final bool available;
  const _Recognition(this.available);

  @override
  Future<bool> isAvailable() async => available;
}

final en = lookupAppLocalizations(const Locale('en'));

void main() {
  Future<void> openSheet(WidgetTester tester, {required DictationAvailability dictation, required bool scan}) async {
    await tester.pumpWidget(
      BlocProvider<AppCubit>.value(
        value: AppCubit(dictation: _Dictation(dictation), textRecognition: _Recognition(scan)),
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(onPressed: () => showAddSheet(context), child: const Text('open')),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('offers the watchlist and a holding, naming what the device can do', (tester) async {
    await openSheet(tester, dictation: DictationAvailability.available, scan: true);
    expect(find.text(en.addSheetWatch), findsOneWidget);
    expect(find.text(en.addHoldingTitle), findsOneWidget);
    expect(find.text(en.addSheetHoldingSpeakScan), findsOneWidget);
  });

  testWidgets('leaves out of the holding row what the device cannot do', (tester) async {
    await openSheet(tester, dictation: DictationAvailability.unsupported, scan: false);
    expect(find.text(en.addSheetHoldingType), findsOneWidget);
  });

  testWidgets('counts a mic that is only turned off, which explains itself in Add', (tester) async {
    await openSheet(tester, dictation: DictationAvailability.denied, scan: false);
    expect(find.text(en.addSheetHoldingSpeak), findsOneWidget);
  });

  testWidgets('names scanning alone where there is no mic', (tester) async {
    await openSheet(tester, dictation: DictationAvailability.unsupported, scan: true);
    expect(find.text(en.addSheetHoldingScan), findsOneWidget);
  });

  testWidgets('Add holding opens Add for recording, with an example and the scanner', (tester) async {
    await openSheet(tester, dictation: DictationAvailability.unsupported, scan: true);
    await tester.tap(find.text(en.addHoldingTitle));
    await tester.pumpAndSettle();
    final screen = tester.widget<AddInstrumentScreen>(find.byType(AddInstrumentScreen));
    expect(screen.start, AddStart.holding);
    expect(find.text(en.addHoldingTitle), findsOneWidget);
    expect(find.text(en.addTypeExample), findsOneWidget);
    expect(find.text(en.addSearchHint), findsOneWidget);
    expect(find.byIcon(Icons.document_scanner_outlined), findsOneWidget);
  });

  testWidgets('Add to watchlist opens a search, without the purchase tools', (tester) async {
    await openSheet(tester, dictation: DictationAvailability.unsupported, scan: true);
    await tester.tap(find.text(en.addSheetWatch));
    await tester.pumpAndSettle();
    final screen = tester.widget<AddInstrumentScreen>(find.byType(AddInstrumentScreen));
    expect(screen.start, AddStart.watchlist);
    expect(find.text(en.addTitle), findsOneWidget);
    expect(find.text(en.addWatchSearchHint), findsOneWidget);
    expect(find.text(en.addTypeExample), findsNothing);
    expect(find.byIcon(Icons.document_scanner_outlined), findsNothing);
  });

  test('every language example reads as a complete purchase', () {
    final context = CaptureContext(
      catalog: InstrumentCatalog.builtIn,
      displayName: (i) => i.symbol,
      baseCurrency: 'EGP',
      currencies: const {'USD', 'EGP'},
      today: DateTime(2026, 11, 1),
    );
    for (final locale in AppLocalizations.supportedLocales) {
      final example = lookupAppLocalizations(locale).addTypeExample;
      final sentence = example.substring(example.indexOf(':') + 1);
      final draft = TransactionCapture.parse(sentence, context);
      expect(draft, isNotNull, reason: example);
      expect(draft!.instrument.value.id, 'metal.XAU', reason: example);
      expect(draft.quantity.value, 20, reason: example);
      expect(draft.karat?.value, GoldKarat.k21, reason: example);
      expect(draft.unitPrice?.value, 4100, reason: example);
      expect(draft.currency.value, 'EGP', reason: example);
    }
  });
}
