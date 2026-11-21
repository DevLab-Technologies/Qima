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
import 'package:qima/services/ai_apps.dart';
import 'package:qima/services/ai_assist_provider.dart';
import 'package:qima/services/local_file_store.dart';
import 'package:qima/services/preferences.dart';
import 'package:qima/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const channel = MethodChannel('com.devlabtechnologies.qima/ai');

  Future<(AppCubit, List<String>)> show(WidgetTester tester, TargetPlatform platform, {AiAssistProvider? aiAssist}) async {
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

    final app = AppCubit(aiAssist: aiAssist);
    app.preferences = await Preferences.create();
    app.emit(app.state.copyWith(initialized: true));
    final money = MoneyCubit(store: app.bookStore, baseCurrency: () => app.state.baseCurrency, rates: () => app.state.rates);
    await tester.runAsync(money.load);
    final ai = (await tester.runAsync(() async => AiApps(app: app, money: money)))!;
    await tester.pumpWidget(MultiBlocProvider(
      providers: [
        RepositoryProvider<AiApps>.value(value: ai),
        BlocProvider<AppCubit>.value(value: app),
        BlocProvider<MoneyCubit>.value(value: money),
      ],
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

  testWidgets('Linux: the model is not asked about (which starts its download) until it is turned on', (tester) async {
    try {
      final model = _CountingModel();
      final (app, _) = await show(tester, TargetPlatform.linux, aiAssist: model);
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      final toggle = find.widgetWithText(SwitchListTile, l10n.settingsUseModel);
      await tester.scrollUntilVisible(toggle, 300, scrollable: find.byType(Scrollable).first);
      expect(model.asked, 0);
      expect(find.textContaining(l10n.settingsUseModelDownload), findsOneWidget);
      expect(find.textContaining(l10n.settingsUseModelAndroid), findsNothing);

      await tester.tap(toggle);
      await tester.pumpAndSettle();
      expect(app.state.onDeviceModel, isTrue);
      expect(model.asked, 1);
      expect(find.text(l10n.modelNotReady), findsOneWidget);

      // Asked again while it gets ready, so the screen shows when it's done.
      model.answer = ModelStatus.ready;
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      expect(model.asked, 2);
      expect(find.text(l10n.modelReady), findsOneWidget);

      // Turning it off stops the download.
      await tester.tap(toggle);
      await tester.pumpAndSettle();
      expect(model.stopped, 1);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}

class _CountingModel extends NullAiAssistProvider implements StoppableModel {
  int asked = 0;
  int stopped = 0;
  ModelStatus answer = ModelStatus.notReady;

  @override
  Future<ModelStatus> status(String localeTag) async {
    asked++;
    return answer;
  }

  @override
  void stop() => stopped++;
}
