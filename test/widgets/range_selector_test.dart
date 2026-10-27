import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qima/l10n/app_localizations.dart';
import 'package:qima/models/chart_range.dart';
import 'package:qima/theme/app_theme.dart';
import 'package:qima/theme/design_system.dart';
import 'package:qima/widgets/range_selector.dart';

Widget _app(Widget child, {Locale locale = const Locale('en'), double width = 358}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: buildTheme(Brightness.light),
    home: Scaffold(body: Center(child: SizedBox(width: width, child: child))),
  );
}

void main() {
  testWidgets('fill mode keeps every range inside the row, even in Arabic', (tester) async {
    await tester.pumpWidget(_app(
      RangeSelector(
        ranges: ChartRange.portfolioSelectable,
        selected: ChartRange.all,
        onSelected: (_) {},
        accent: Colors.amber,
        fill: true,
      ),
      locale: const Locale('ar'),
    ));
    await tester.pumpAndSettle();

    final row = tester.getRect(find.byType(RangeSelector));
    final labels = find.descendant(of: find.byType(RangeSelector), matching: find.byType(Text));
    expect(labels, findsNWidgets(ChartRange.portfolioSelectable.length));
    for (final label in labels.evaluate()) {
      final rect = tester.getRect(find.byWidget(label.widget));
      expect(rect.left, greaterThanOrEqualTo(row.left));
      expect(rect.right, lessThanOrEqualTo(row.right));
    }
  });

  testWidgets('tapping a range reports it', (tester) async {
    ChartRange? picked;
    final en = await AppLocalizations.delegate.load(const Locale('en'));
    await tester.pumpWidget(_app(RangeSelector(
      ranges: ChartRange.portfolioSelectable,
      selected: ChartRange.all,
      onSelected: (r) => picked = r,
      accent: Colors.amber,
      fill: true,
    )));
    await tester.tap(find.text(en.range1M));
    expect(picked, ChartRange.month1);
  });

  testWidgets('a scrolling row brings the selected range into view', (tester) async {
    await tester.pumpWidget(_app(
      RangeSelector(
        ranges: ChartRange.defaultSelectable,
        selected: ChartRange.year1,
        onSelected: (_) {},
        accent: Colors.amber,
      ),
      width: 200,
    ));
    await tester.pumpAndSettle();

    final row = tester.getRect(find.byType(RangeSelector));
    final selected = tester.getRect(find.byKey(const ValueKey('selected-range')));
    expect(selected.left, greaterThanOrEqualTo(row.left));
    expect(selected.right, lessThanOrEqualTo(row.right));
  });

  testWidgets('overlines drop letter spacing and grow in Arabic', (tester) async {
    late TextStyle latin;
    late TextStyle arabic;
    Widget probe(void Function(TextStyle) capture) => Builder(builder: (context) {
          capture(DS.overline(context, color: Colors.black, fontSize: 12));
          return const SizedBox();
        });
    await tester.pumpWidget(_app(probe((s) => latin = s)));
    await tester.pumpWidget(_app(probe((s) => arabic = s), locale: const Locale('ar')));

    expect(latin.letterSpacing, greaterThan(0));
    expect(arabic.letterSpacing, 0);
    expect(arabic.fontSize, greaterThan(latin.fontSize!));
  });

  test('status-bar icons contrast with each palette', () {
    expect(overlayStyleFor(Brightness.light).statusBarBrightness, Brightness.light);
    expect(overlayStyleFor(Brightness.light).statusBarIconBrightness, Brightness.dark);
    expect(overlayStyleFor(Brightness.dark).statusBarIconBrightness, Brightness.light);
    expect(buildTheme(Brightness.light).appBarTheme.systemOverlayStyle, SystemUiOverlayStyle.dark);
  });
}
