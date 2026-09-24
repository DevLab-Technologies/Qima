import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qima/blocs/app_cubit.dart';
import 'package:qima/l10n/app_localizations.dart';
import 'package:qima/screens/export_backup_sheet.dart';
import 'package:qima/services/backup/backup_service.dart';
import 'package:qima/services/local_file_store.dart';
import 'package:qima/services/preferences.dart';
import 'package:qima/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('qima_export_backup_sheet_test');
    LocalFileStore.overrideDirectoryForTesting(tempDir);
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  Future<AppCubit> populatedCubit() async {
    final cubit = AppCubit();
    cubit.preferences = await Preferences.create();
    cubit.backupService = BackupService(
      watchlistStore: cubit.watchlistStore,
      holdingsStore: cubit.holdingsStore,
      customInstrumentStore: cubit.customInstrumentStore,
      alertsStore: cubit.alertsStore,
      preferences: cubit.preferences,
    );
    cubit.emit(cubit.state.copyWith(initialized: true));
    return cubit;
  }

  Widget harness(AppCubit cubit) {
    return BlocProvider<AppCubit>.value(
      value: cubit,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: buildTheme(Brightness.dark),
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => ExportBackupSheet.show(context),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
  }

  Future<AppLocalizations> l10n() => AppLocalizations.delegate.load(const Locale('en'));

  testWidgets('the "Save or share…" button is enabled with no password protection', (tester) async {
    final cubit = await populatedCubit();
    await tester.pumpWidget(harness(cubit));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final strings = await l10n();
    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNotNull);
    expect(find.text(strings.backupExportSheetAction), findsOneWidget);
  });

  testWidgets('unprotected warning note is shown when password protection is off', (tester) async {
    final cubit = await populatedCubit();
    await tester.pumpWidget(harness(cubit));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final strings = await l10n();
    expect(find.text(strings.backupExportSheetUnprotectedWarning), findsOneWidget);
  });

  testWidgets('turning on password protection reveals password fields and disables the button', (tester) async {
    final cubit = await populatedCubit();
    await tester.pumpWidget(harness(cubit));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    final strings = await l10n();
    expect(find.text(strings.backupExportSheetPasswordLabel), findsOneWidget);
    expect(find.text(strings.backupExportSheetPasswordConfirmLabel), findsOneWidget);
    expect(find.text(strings.backupExportSheetUnprotectedWarning), findsNothing);

    // Empty password: button must be disabled until a valid password is entered.
    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('a password shorter than 8 characters shows an error and keeps the button disabled', (tester) async {
    final cubit = await populatedCubit();
    await tester.pumpWidget(harness(cubit));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'short');
    await tester.pump();

    final strings = await l10n();
    expect(find.text(strings.backupExportSheetPasswordTooShort), findsOneWidget);
    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('mismatched password/confirm shows an error and keeps the button disabled', (tester) async {
    final cubit = await populatedCubit();
    await tester.pumpWidget(harness(cubit));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'longenough1');
    await tester.enterText(fields.at(1), 'longenough2');
    await tester.pump();

    final strings = await l10n();
    expect(find.text(strings.backupExportSheetPasswordMismatch), findsOneWidget);
    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('a valid matching password of at least 8 characters enables the button', (tester) async {
    final cubit = await populatedCubit();
    await tester.pumpWidget(harness(cubit));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'longenough1');
    await tester.enterText(fields.at(1), 'longenough1');
    await tester.pump();

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNotNull);
  });
}
