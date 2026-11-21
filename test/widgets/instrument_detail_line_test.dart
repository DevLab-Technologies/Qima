import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qima/l10n/app_localizations.dart';
import 'package:qima/theme/app_theme.dart';
import 'package:qima/widgets/instrument_row.dart';

void main() {
  Future<void> pump(WidgetTester tester, double width) => tester.pumpWidget(MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: buildTheme(Brightness.dark),
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: width,
              child: const InstrumentDetailLine(text: 'XAU · EGP g', closed: true, style: TextStyle(fontSize: 12)),
            ),
          ),
        ),
      ));

  String shown(WidgetTester tester) => tester.widget<RichText>(find.byType(RichText).first).text.toPlainText();

  testWidgets('a closed market shows the moon and the word when there is room', (tester) async {
    await pump(tester, 300);
    expect(find.byKey(const ValueKey('marketClosed')), findsOneWidget);
    expect(shown(tester), contains('Closed'));
  });

  testWidgets('with no room for the word, the moon stays and the symbol is not cut', (tester) async {
    await pump(tester, 200);
    expect(find.byKey(const ValueKey('marketClosed')), findsOneWidget);
    expect(shown(tester), isNot(contains('Closed')));
    expect(tester.renderObject<RenderParagraph>(find.byType(RichText).first).didExceedMaxLines, isFalse);
  });
}
