import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:qima/main.dart';

void main() {
  // `QimaApp` always constructs a real `AppCubit()` (there's no test seam
  // to inject a fake `NotificationService`/`PriceRepository` here — see
  // every other widget test, which builds its own harness around
  // `BlocProvider<AppCubit>.value` instead of `QimaApp` for exactly this
  // reason). `AppCubit.init()` therefore never resolves in the test
  // environment's unmocked plugin channels, so this smoke test only checks
  // what's actually true offline: the app boots without throwing and shows
  // its loading placeholder while `init()` is in flight — it does not
  // (and cannot, without a `QimaApp` test seam) exercise the onboarding
  // tour or the home shell end to end; those are covered by
  // `test/screens/onboarding_tour_screen_test.dart` and
  // `test/screens/home_shell_test.dart` instead, against a harness with a
  // fake repository/notification service.
  testWidgets('App boots without throwing and shows a loading state', (WidgetTester tester) async {
    await tester.pumpWidget(const QimaApp());
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
