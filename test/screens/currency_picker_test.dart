import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qima/l10n/app_localizations.dart';
import 'package:qima/screens/currency_picker.dart';

Widget _app(Locale locale) => MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const CurrencyPicker(selected: 'USD', currencies: ['BHD', 'KWD', 'USD']),
    );

void main() {
  testWidgets('shows localized currency names, not the ISO code twice', (tester) async {
    await tester.pumpWidget(_app(const Locale('en')));
    expect(find.text('Kuwaiti Dinar'), findsOneWidget);
    expect(find.text('US Dollar'), findsOneWidget);
  });

  testWidgets('search matches the currency name', (tester) async {
    await tester.pumpWidget(_app(const Locale('en')));
    await tester.enterText(find.byType(TextField), 'dinar');
    await tester.pump();
    expect(find.text('KWD'), findsOneWidget);
    expect(find.text('BHD'), findsOneWidget);
    expect(find.text('USD'), findsNothing);
  });

  testWidgets('names follow the app language', (tester) async {
    await tester.pumpWidget(_app(const Locale('ar')));
    expect(find.text('دينار كويتي'), findsOneWidget);
  });
}
