import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qima/blocs/app_cubit.dart';
import 'package:qima/l10n/app_localizations.dart';
import 'package:qima/models/asset.dart';
import 'package:qima/models/watch_card.dart';
import 'package:qima/screens/import_preview_screen.dart';
import 'package:qima/services/backup/backup_service.dart';
import 'package:qima/services/local_file_store.dart';
import 'package:qima/services/preferences.dart';
import 'package:qima/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// `ImportPreviewScreen` kicks off its parsing/decoding in a post-frame
/// callback fired by the very FIRST frame `pumpWidget` schedules, and
/// encrypted backups additionally run PBKDF2 via `compute()` on a real
/// background isolate. Neither progresses under a widget test's synchronous
/// `pump()`; only `runAsync` lets real Futures/isolate messages actually
/// resolve — which means `pumpWidget` (or whatever action first triggers the
/// async work, e.g. a button tap that pushes the route) has to run inside
/// `runAsync` too, not just the settling pumps after it. `pumpAndSettle`
/// can't be used here either way: the loading stage shows a
/// `CircularProgressIndicator`, whose indeterminate animation never
/// settles.
Future<void> _runAsyncAndSettle(WidgetTester tester, Future<void> Function() action, {int times = 20}) async {
  await tester.runAsync(() async {
    await action();
    for (var i = 0; i < times; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await tester.pump();
    }
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('qima_import_preview_test');
    LocalFileStore.overrideDirectoryForTesting(tempDir);
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  /// The ready-state body (file card, counts grid, mode picker, diff line,
  /// Restore button) is taller than the default 800x600 test surface, so
  /// the Restore button sits below the fold — a larger surface avoids
  /// depending on `scrollUntilVisible` picking exactly one `Scrollable`
  /// ancestor out of the several this screen legitimately has (the outer
  /// `ListView` plus internal ones from Material widgets).
  void useTallSurface(WidgetTester tester) {
    tester.view.physicalSize = const Size(390, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

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

  Widget harness(AppCubit cubit, PickedBackupFile picked) {
    return BlocProvider<AppCubit>.value(
      value: cubit,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: buildTheme(Brightness.dark),
        home: ImportPreviewScreen(picked: picked),
      ),
    );
  }

  Future<AppLocalizations> l10n() => AppLocalizations.delegate.load(const Locale('en'));

  /// Builds a plain (unencrypted) backup JSON from a fresh cubit with one
  /// watchlist card, writing straight through the store (not
  /// `AppCubit.addCard`, which also fires off a live `refresh`/
  /// `backfillHistoryIfNeeded` this helper has no need to deal with). Must
  /// run inside `tester.runAsync` — real `dart:io` file writes don't
  /// progress under a widget test's synchronous fake-async zone otherwise.
  Future<String> plainBackupJson(WidgetTester tester) async {
    late String json;
    await tester.runAsync(() async {
      final source = await populatedCubit();
      await source.watchlistStore
          .upsert(WatchCard(id: 'c1', instrumentID: 'metal.XAU', currency: 'USD', unit: PriceUnit.troyOunce));
      json = await source.backupService.buildJson();
    });
    return json;
  }

  /// Same as [plainBackupJson] but password-protected — see its doc comment
  /// for why `runAsync` is required; encryption additionally needs it for
  /// the PBKDF2 pass's `compute()` isolate round-trip. Uses a low KDF
  /// iteration count (`BackupService.buildJson`'s `kdfIterations`, test-only
  /// — see `BackupCrypto.encrypt`'s doc comment) rather than the real
  /// 600,000: at production cost, this fixture build plus the SCREEN's own
  /// two decrypt attempts (once with the wrong password, once — in the
  /// "shows the password prompt" test — never at all) can each take
  /// hundreds of milliseconds to seconds under CPU load, which is exactly
  /// what made "wrong password" time out at the widget-test default 30s
  /// budget. The on-disk format/decoding path is unchanged either way —
  /// decoding always reads `kdf.iterations` back out of the file rather than
  /// assuming any particular cost.
  Future<String> encryptedBackupJson(WidgetTester tester, String password) async {
    late String json;
    await tester.runAsync(() async {
      final source = await populatedCubit();
      await source.watchlistStore
          .upsert(WatchCard(id: 'c1', instrumentID: 'metal.XAU', currency: 'USD', unit: PriceUnit.troyOunce));
      json = await source.backupService.buildJson(password: password, kdfIterations: 10);
    });
    return json;
  }

  testWidgets('a picked .csv file shows the CSV-chosen error state', (tester) async {
    final cubit = await populatedCubit();
    final picked = const PickedBackupFile(name: 'qima-holdings-2026-01-01.csv', raw: 'a,b,c\n1,2,3');

    await _runAsyncAndSettle(tester, () => tester.pumpWidget(harness(cubit, picked)));

    final strings = await l10n();
    expect(find.text(strings.backupImportCsvErrorTitle), findsOneWidget);
    expect(find.text(strings.backupImportCsvErrorMessage), findsOneWidget);
  });

  testWidgets('a non-JSON file shows the generic error state with the right message', (tester) async {
    final cubit = await populatedCubit();
    const picked = PickedBackupFile(name: 'notes.txt', raw: 'this is not json');

    await _runAsyncAndSettle(tester, () => tester.pumpWidget(harness(cubit, picked)));

    final strings = await l10n();
    expect(find.text(strings.backupImportFailedTitle), findsOneWidget);
    expect(find.text(strings.backupErrorNotQimaFile), findsOneWidget);
  });

  testWidgets('a plain (unencrypted) backup goes straight to the ready state with Merge selected by default',
      (tester) async {
    useTallSurface(tester);
    final json = await plainBackupJson(tester);
    final cubit = await populatedCubit();
    final picked = PickedBackupFile(name: 'qima-backup-2026-01-01.json', raw: json);

    await _runAsyncAndSettle(tester, () => tester.pumpWidget(harness(cubit, picked)));

    final strings = await l10n();
    expect(find.text(strings.backupImportModeMergeFooter), findsOneWidget);
    expect(find.text(strings.backupImportRestoreButton), findsOneWidget);
  }, timeout: const Timeout(Duration(seconds: 30)));

  testWidgets('an encrypted backup shows the password prompt first', (tester) async {
    final json = await encryptedBackupJson(tester, 'correcthorse');
    final cubit = await populatedCubit();
    final picked = PickedBackupFile(name: 'qima-backup-2026-01-01.json', raw: json);

    await _runAsyncAndSettle(tester, () => tester.pumpWidget(harness(cubit, picked)));

    final strings = await l10n();
    expect(find.text(strings.backupImportPasswordPrompt), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  }, timeout: const Timeout(Duration(seconds: 30)));

  testWidgets('an encrypted backup with the wrong password shows an inline error and stays on the prompt',
      (tester) async {
    final json = await encryptedBackupJson(tester, 'correcthorse');
    final cubit = await populatedCubit();
    final picked = PickedBackupFile(name: 'qima-backup-2026-01-01.json', raw: json);

    await _runAsyncAndSettle(tester, () => tester.pumpWidget(harness(cubit, picked)));

    await tester.enterText(find.byType(TextField), 'wrongpassword');
    final strings = await l10n();
    // This triggers a SECOND real PBKDF2 pass (deriving the key to attempt
    // decryption with the wrong password) via `compute()`, but the fixture
    // above was built at a low test iteration count, so the default settle
    // budget is plenty — no need to inflate it to absorb a ~600k-iteration
    // round trip that isn't happening here.
    await _runAsyncAndSettle(
      tester,
      () async => tester.tap(find.text(strings.backupImportUnlock)),
    );

    expect(find.text(strings.backupImportPasswordIncorrect), findsOneWidget);
  }, timeout: const Timeout(Duration(seconds: 30)));

  testWidgets('switching to Replace mode updates the footer text and diff line', (tester) async {
    final json = await plainBackupJson(tester);
    final cubit = await populatedCubit();
    final picked = PickedBackupFile(name: 'qima-backup-2026-01-01.json', raw: json);

    await _runAsyncAndSettle(tester, () => tester.pumpWidget(harness(cubit, picked)));

    final strings = await l10n();
    expect(find.text(strings.backupImportModeMergeFooter), findsOneWidget);

    await tester.tap(find.text(strings.backupImportModeReplace));
    await tester.pump();

    expect(find.text(strings.backupImportModeReplaceFooter), findsOneWidget);
    expect(find.text(strings.backupImportModeMergeFooter), findsNothing);
  }, timeout: const Timeout(Duration(seconds: 30)));

  testWidgets('choosing Replace and confirming shows the "replace everything" confirmation dialog', (tester) async {
    useTallSurface(tester);
    final json = await plainBackupJson(tester);
    final cubit = await populatedCubit();
    final picked = PickedBackupFile(name: 'qima-backup-2026-01-01.json', raw: json);

    await _runAsyncAndSettle(tester, () => tester.pumpWidget(harness(cubit, picked)));

    final strings = await l10n();
    await tester.tap(find.text(strings.backupImportModeReplace));
    await tester.pump();

    await tester.tap(find.text(strings.backupImportRestoreButton));
    await tester.pump();

    expect(find.text(strings.backupImportReplaceConfirmTitle), findsOneWidget);
  }, timeout: const Timeout(Duration(seconds: 30)));

  testWidgets('confirming Merge restore applies the payload and pops with a success snackbar', (tester) async {
    useTallSurface(tester);
    final json = await plainBackupJson(tester);
    final cubit = await populatedCubit();
    final picked = PickedBackupFile(name: 'qima-backup-2026-01-01.json', raw: json);

    // A two-route Navigator (a placeholder root route, then
    // `ImportPreviewScreen`) under one `BlocProvider`, so
    // `Navigator.popUntil((route) => route.isFirst)` (what
    // `ImportPreviewScreen._restore` calls on success) has a real first
    // route to land back on — mirroring the actual Settings -> Backup ->
    // ImportPreviewScreen push chain.
    final innerNavigatorKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: buildTheme(Brightness.dark),
      home: BlocProvider<AppCubit>.value(
        value: cubit,
        child: Navigator(
          key: innerNavigatorKey,
          onGenerateRoute: (_) => MaterialPageRoute(builder: (_) => const Scaffold(body: Text('root'))),
        ),
      ),
    ));

    final navigatorState = innerNavigatorKey.currentState!;
    // Pushing (and the pushed screen's own `initState` post-frame callback,
    // which kicks off the async parse/decode) has to run inside the same
    // `runAsync` block as the settle loop that follows it.
    await _runAsyncAndSettle(tester, () async {
      navigatorState.push(MaterialPageRoute(builder: (_) => ImportPreviewScreen(picked: picked)));
    });

    final strings = await l10n();
    await _runAsyncAndSettle(tester, () async {
      await tester.tap(find.text(strings.backupImportRestoreButton), warnIfMissed: false);
    });

    expect(cubit.state.cards.map((c) => c.id), contains('c1'));
    expect(find.text(strings.backupImportSuccessSnackbar), findsOneWidget);
  }, timeout: const Timeout(Duration(seconds: 30)));
}
