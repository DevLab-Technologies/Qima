import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qima/l10n/app_localizations.dart';
import 'package:qima/theme/app_theme.dart';
import 'package:qima/theme/design_system.dart';

/// The app's font is decided once, in `buildTheme`. Chips and navigation
/// labels replace the ambient text style instead of merging with it, so
/// these check they still end up in the locale's family.
void main() {
  Widget app(Locale locale) {
    return MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => Theme(
        data: buildTheme(Brightness.dark, locale: Localizations.localeOf(context)),
        child: child!,
      ),
      home: Scaffold(
        body: DSChoiceChip(label: 'chip', selected: false, onSelected: (_) {}),
        bottomNavigationBar: NavigationBar(
          destinations: const [
            NavigationDestination(icon: Icon(Icons.list), label: 'first'),
            NavigationDestination(icon: Icon(Icons.settings), label: 'second'),
          ],
        ),
      ),
    );
  }

  String? familyOf(WidgetTester tester, String text) {
    final element = tester.element(find.text(text));
    final widget = tester.widget<Text>(find.text(text));
    return DefaultTextStyle.of(element).style.merge(widget.style).fontFamily;
  }

  testWidgets('Arabic sets chips and navigation labels in Almarai', (tester) async {
    await tester.pumpWidget(app(const Locale('ar')));
    await tester.pumpAndSettle();

    expect(familyOf(tester, 'chip'), DS.arabicFontFamily);
    expect(familyOf(tester, 'first'), DS.arabicFontFamily);
    expect(familyOf(tester, 'second'), DS.arabicFontFamily);
  });

  testWidgets('other languages keep the platform font', (tester) async {
    await tester.pumpWidget(app(const Locale('en')));
    await tester.pumpAndSettle();

    expect(familyOf(tester, 'chip'), isNot(DS.arabicFontFamily));
    expect(familyOf(tester, 'first'), isNot(DS.arabicFontFamily));
  });
}
