import 'package:flutter_test/flutter_test.dart';

import 'package:qima/main.dart';

void main() {
  testWidgets('App boots to the watchlist screen', (WidgetTester tester) async {
    await tester.pumpWidget(const QimaApp());
    await tester.pump();
    expect(find.text('Qima'), findsOneWidget);
  });
}
