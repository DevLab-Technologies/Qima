import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qima/l10n/app_localizations.dart';
import 'package:qima/models/instrument_catalog.dart';
import 'package:qima/widgets/market_status.dart';

Widget _app(Widget child) => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );

void main() {
  final apple = InstrumentCatalog.instrument('stock.AAPL')!;
  final bitcoin = InstrumentCatalog.instrument('crypto.BTC')!;

  testWidgets('a closed market says when it opens', (tester) async {
    // Saturday: the US market opens Monday.
    final now = DateTime.utc(2026, 11, 7, 12).toLocal();
    await tester.pumpWidget(_app(MarketStatusLine(instrument: apple, now: now)));
    expect(find.byKey(const ValueKey('market:closed')), findsOneWidget);
    expect(find.textContaining('Market closed · opens'), findsOneWidget);
    expect(MarketClosedMark.closed(apple, now), isTrue);
  });

  testWidgets('an open market says when it closes', (tester) async {
    final now = DateTime.utc(2026, 11, 6, 20).toLocal();
    await tester.pumpWidget(_app(MarketStatusLine(instrument: apple, now: now)));
    expect(find.textContaining('Market open · closes'), findsOneWidget);
    expect(MarketClosedMark.closed(apple, now), isFalse);
  });

  testWidgets('a market that never closes shows nothing', (tester) async {
    final now = DateTime.utc(2026, 11, 7, 12).toLocal();
    await tester.pumpWidget(_app(Column(children: [MarketStatusLine(instrument: bitcoin, now: now)])));
    expect(find.byType(Text), findsNothing);
    expect(MarketClosedMark.closed(bitcoin, now), isFalse);
  });

  testWidgets('the closed mark reads in Arabic', (tester) async {
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('ar'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: Builder(builder: (context) => Text.rich(TextSpan(children: MarketClosedMark.spans(context))))),
    ));
    expect(find.textContaining('مغلق', findRichText: true), findsOneWidget);
    expect(find.byKey(const ValueKey('marketClosed')), findsOneWidget);
  });
}
