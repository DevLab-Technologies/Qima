import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qima/l10n/app_localizations.dart';
import 'package:qima/screens/currency_picker.dart';
import 'package:qima/widgets/currency_field.dart';

const _currencies = ['AED', 'EGP', 'EUR', 'GBP', 'JPY', 'SAR', 'USD'];

CurrencyField _field(String selected, {String base = 'EGP', ValueChanged<String>? onChanged}) => CurrencyField(
      label: 'Show prices in',
      selected: selected,
      baseCurrency: base,
      currencies: _currencies,
      onChanged: onChanged ?? (_) {},
    );

void main() {
  group('suggestions', () {
    test('the selection, then the portfolio currency, then common ones, five at most', () {
      expect(_field('USD').suggestions, ['USD', 'EGP', 'EUR', 'SAR', 'AED']);
    });

    test('an uncommon selection is still offered', () {
      expect(_field('JPY').suggestions.first, 'JPY');
      expect(_field('JPY').suggestions, hasLength(5));
    });

    test('codes without a rate are skipped', () {
      expect(_field('USD', base: 'XYZ').suggestions, isNot(contains('XYZ')));
    });
  });

  group('widget', () {
    Future<List<String>> pump(WidgetTester tester, String selected) async {
      final picked = <String>[];
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: _field(selected, onChanged: picked.add)),
        ),
      );
      return picked;
    }

    testWidgets('shows the code, its name and how many currencies there are', (tester) async {
      await pump(tester, 'EGP');
      expect(find.textContaining('Egyptian Pound', findRichText: true), findsOneWidget);
      expect(find.text('7 currencies available'), findsOneWidget);
    });

    testWidgets('a chip picks its currency in one tap', (tester) async {
      final picked = await pump(tester, 'USD');
      await tester.tap(find.widgetWithText(ChoiceChip, 'EGP'));
      expect(picked, ['EGP']);
    });

    testWidgets('More opens the full list', (tester) async {
      final picked = await pump(tester, 'USD');
      await tester.tap(find.text('More'));
      await tester.pumpAndSettle();
      expect(find.byType(CurrencyPicker), findsOneWidget);
      await tester.tap(find.text('JPY'));
      await tester.pumpAndSettle();
      expect(picked, ['JPY']);
    });
  });
}
