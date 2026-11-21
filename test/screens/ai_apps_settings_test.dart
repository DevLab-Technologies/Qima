import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qima/blocs/app_cubit.dart';
import 'package:qima/blocs/money_cubit.dart';
import 'package:qima/l10n/app_localizations.dart';
import 'package:qima/mcp/snapshot_location.dart';
import 'package:qima/models/book_account.dart';
import 'package:qima/models/money_settings.dart';
import 'package:qima/screens/settings_screen.dart';
import 'package:qima/services/ai_apps.dart';
import 'package:qima/services/local_file_store.dart';
import 'package:qima/services/preferences.dart';
import 'package:qima/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Let AI apps read Qima shares a private-field-free copy and removes it when turned off', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    try {
      final dir = await tester.runAsync(() => Directory.systemTemp.createTemp('qima_ai_apps'));
      addTearDown(() => dir!.deleteSync(recursive: true));
      LocalFileStore.overrideDirectoryForTesting(dir!);
      // The Mac app writes into its App Group container.
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('com.devlabtechnologies.qima/widgets'),
        (call) async => call.method == 'groupContainerPath' ? dir.path : null,
      );
      SharedPreferences.setMockInitialValues({});

      final app = AppCubit();
      app.preferences = await Preferences.create();
      app.emit(app.state.copyWith(initialized: true));
      final money = MoneyCubit(store: app.bookStore, baseCurrency: () => app.state.baseCurrency, rates: () => app.state.rates);
      await tester.runAsync(() async {
        await app.bookStore.settings.upsert(const MoneySettings(seenWhatsNew: true, categoryRules: {'panda': 'groceries'}));
        await app.bookStore.accounts.upsert(const BookAccount(
          id: 'rajhi',
          name: 'Al Rajhi',
          side: AccountSide.own,
          type: AccountType.debit,
          currency: 'SAR',
          note: 'IBAN SA03 8000',
          statementRefs: ['4421'],
        ));
        await money.load();
      });
      // Made on the real clock: its write queue chains real file work.
      final ai = (await tester.runAsync(() async => AiApps(app: app, money: money)))!;
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));

      await tester.pumpWidget(MultiBlocProvider(
        providers: [
          RepositoryProvider<AiApps>.value(value: ai),
          BlocProvider<AppCubit>.value(value: app),
          BlocProvider<MoneyCubit>.value(value: money),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: buildTheme(Brightness.dark),
          home: const SettingsScreen(),
        ),
      ));
      await tester.pumpAndSettle();

      final toggle = find.byKey(const Key('aiAppsToggle'));
      await tester.scrollUntilVisible(toggle, 300, scrollable: find.byType(Scrollable).first);
      expect(tester.widget<SwitchListTile>(toggle).value, isFalse);
      expect(find.text(l10n.aiAppsSetupTitle), findsNothing);

      await tester.runAsync(() => ai.setEnabled(true));
      await tester.pumpAndSettle();
      expect(tester.widget<SwitchListTile>(toggle).value, isTrue);
      expect(app.preferences.local.getBool('aiAppsEnabled'), isTrue);
      // A test run has no helper beside it, so the section says so instead
      // of showing a config that points nowhere.
      expect(find.text(l10n.aiAppsNoHelper), findsOneWidget);

      final file = File('${dir.path}/${SnapshotLocation.fileName}');
      final shared = await tester.runAsync(() => file.readAsString());
      final json = jsonDecode(shared!) as Map<String, dynamic>;
      expect([for (final a in json['accounts'] as List) a['name']], contains('Al Rajhi'));
      expect(shared, isNot(contains('4421')));
      expect(shared, isNot(contains('IBAN')));
      expect(shared, isNot(contains('panda')));
      expect(SnapshotLocation.read(file.path).holdingsValue, 0);

      await tester.runAsync(() => ai.setEnabled(false));
      await tester.pumpAndSettle();
      expect(await tester.runAsync(() => file.exists()), isFalse);
      expect(app.preferences.local.getBool('aiAppsEnabled'), isFalse);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}
