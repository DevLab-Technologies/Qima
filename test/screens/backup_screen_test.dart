import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qima/blocs/app_cubit.dart';
import 'package:qima/l10n/app_localizations.dart';
import 'package:qima/screens/backup_screen.dart';
import 'package:qima/services/backup/backup_service.dart';
import 'package:qima/services/local_file_store.dart';
import 'package:qima/services/preferences.dart';
import 'package:qima/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('qima_backup_screen_test');
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
        home: const BackupScreen(),
      ),
    );
  }

  testWidgets('shows "Never backed up" when no backup has been made yet', (tester) async {
    final cubit = await populatedCubit();
    await tester.pumpWidget(harness(cubit));
    await tester.pump();

    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.text(l10n.backupLastBackupNever), findsOneWidget);
  });

  testWidgets('shows the last backup date once one has been recorded', (tester) async {
    final cubit = await populatedCubit();
    await cubit.backupService.setLastBackupAt(DateTime(2026, 1, 15));
    await tester.pumpWidget(harness(cubit));
    await tester.pump();

    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.text(l10n.backupLastBackupNever), findsNothing);
  });

  testWidgets('does not show the reminder card when nothing is due', (tester) async {
    final cubit = await populatedCubit();
    await tester.pumpWidget(harness(cubit));
    await tester.pump();

    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.text(l10n.backupReminderCardTitle), findsNothing);
  });

  testWidgets('shows the reminder card when a backup is due', (tester) async {
    final cubit = await populatedCubit();
    await cubit.backupService.setReminderEnabled(true);
    await cubit.backupService.setDataChangedSinceLastBackup(true);
    await cubit.backupService.setLastBackupAt(DateTime.now().subtract(const Duration(days: 45)));
    cubit.emit(cubit.state.copyWith(backupReminderDue: true));

    await tester.pumpWidget(harness(cubit));
    await tester.pump();

    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.text(l10n.backupReminderCardTitle), findsOneWidget);
  });

  testWidgets('Export/Restore section rows are present', (tester) async {
    final cubit = await populatedCubit();
    await tester.pumpWidget(harness(cubit));
    await tester.pump();

    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.text(l10n.backupExportFullTitle), findsOneWidget);
    expect(find.text(l10n.backupExportCsvTitle), findsOneWidget);
    expect(find.text(l10n.backupRestoreTitle), findsOneWidget);
  });

  testWidgets('the reminder toggle reflects and updates BackupService.reminderEnabled', (tester) async {
    final cubit = await populatedCubit();
    await cubit.backupService.setReminderEnabled(true);
    await tester.pumpWidget(harness(cubit));
    await tester.pump();

    final switchFinder = find.byType(SwitchListTile).last;
    expect(tester.widget<SwitchListTile>(switchFinder).value, isTrue);

    await tester.runAsync(() async {
      await tester.tap(switchFinder, warnIfMissed: false);
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pump();

    expect(cubit.backupService.reminderEnabled, isFalse);
  });
}
