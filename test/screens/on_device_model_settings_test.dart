import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qima/blocs/app_cubit.dart';
import 'package:qima/blocs/money_cubit.dart';
import 'package:qima/l10n/app_localizations.dart';
import 'package:qima/screens/settings_screen.dart';
import 'package:qima/services/local_file_store.dart';
import 'package:qima/services/preferences.dart';
import 'package:qima/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const channel = MethodChannel('com.devlabtechnologies.qima/ai');

  Future<(AppCubit, List<String>)> show(WidgetTester tester, TargetPlatform platform) async {
    debugDefaultTargetPlatformOverride = platform;
    final dir = await tester.runAsync(() => Directory.systemTemp.createTemp('qima_model'));
    addTearDown(() => dir!.deleteSync(recursive: true));
    LocalFileStore.overrideDirectoryForTesting(dir!);
    SharedPreferences.setMockInitialValues({});
    final calls = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call.method);
      return call.method == 'availability' ? 'ready' : null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, null));

    final app = AppCubit();
    app.preferences = await Preferences.create();
    app.emit(app.state.copyWith(initialized: true));
    final money = MoneyCubit(store: app.bookStore, baseCurrency: () => app.state.baseCurrency, rates: () => app.state.rates);
    await tester.runAsync(money.load);
    await tester.pumpWidget(MultiBlocProvider(
      providers: [BlocProvider<AppCubit>.value(value: app), BlocProvider<MoneyCubit>.value(value: money)],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: buildTheme(Brightness.light),
        home: const SettingsScreen(),
      ),
    ));
    await tester.pumpAndSettle();
    return (app, calls);
  }

  testWidgets('Android: ML Kit is not asked anything until the model is turned on', (tester) async {
    try {
      final (app, calls) = await show(tester, TargetPlatform.android);
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      final toggle = find.widgetWithText(SwitchListTile, l10n.settingsUseModel);
      await tester.scrollUntilVisible(toggle, 300, scrollable: find.byType(Scrollable).first);
      expect(calls, isEmpty);
      expect(find.textContaining(l10n.settingsUseModelAndroid), findsOneWidget);
      expect(find.text(l10n.modelReady), findsNothing);

      await tester.tap(toggle);
      await tester.pumpAndSettle();
      expect(app.state.onDeviceModel, isTrue);
      expect(calls, ['availability']);
      expect(find.text(l10n.modelReady), findsOneWidget);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('iPhone: the model\'s state shows with the switch off, without the Android note', (tester) async {
    try {
      final (_, calls) = await show(tester, TargetPlatform.iOS);
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      final toggle = find.widgetWithText(SwitchListTile, l10n.settingsUseModel);
      await tester.scrollUntilVisible(toggle, 300, scrollable: find.byType(Scrollable).first);
      expect(calls, ['availability']);
      expect(find.text(l10n.modelReady), findsOneWidget);
      expect(find.textContaining(l10n.settingsUseModelAndroid), findsNothing);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}
