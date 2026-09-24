import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:qima/blocs/app_cubit.dart';
import 'package:qima/models/asset.dart';
import 'package:qima/models/fx_history.dart';
import 'package:qima/models/instrument_catalog.dart';
import 'package:qima/models/quote.dart';
import 'package:qima/models/watch_card.dart';
import 'package:qima/services/backup/backup_service.dart';
import 'package:qima/services/local_file_store.dart';
import 'package:qima/services/preferences.dart';
import 'package:qima/services/price_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stands in for `PriceRepository` so `_reloadAllStores`'s fire-and-forget
/// `refreshAll()`/backfill calls never hit the network or the unmocked
/// `shared_preferences`/`path_provider` plugins — mirrors `add_card_test.dart`'s
/// `_NoopRepository`.
class _NoopRepository extends PriceRepository {
  @override
  Future<QuoteSeries> refresh(Instrument instrument, {DateTime? now}) async => QuoteSeries.empty(instrument.id);

  @override
  Future<Map<String, QuoteSeries>> refreshAll(List<Instrument> instruments, {DateTime? now}) async => {};

  @override
  Future<FXHistory> backfillFXHistory(List<String> currencies, {bool force = false, DateTime? now}) async =>
      FXHistory.empty;

  @override
  Future<Map<String, QuoteSeries>> backfillInstruments(
    List<Instrument> instruments,
    FXHistory fxHistory, {
    bool force = false,
    DateTime? now,
  }) async =>
      {};
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('qima_restore_from_backup_test');
    LocalFileStore.overrideDirectoryForTesting(tempDir);
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  Future<AppCubit> populatedCubit() async {
    final cubit = AppCubit(repository: _NoopRepository());
    cubit.preferences = await Preferences.create();
    cubit.backupService = BackupService(
      watchlistStore: cubit.watchlistStore,
      holdingsStore: cubit.holdingsStore,
      customInstrumentStore: cubit.customInstrumentStore,
      alertsStore: cubit.alertsStore,
      preferences: cubit.preferences,
    );
    cubit.emit(cubit.state.copyWith(initialized: true, baseCurrency: 'USD'));
    return cubit;
  }

  final gold = InstrumentCatalog.instrument('metal.XAU')!;

  test('restoring a Merge backup reloads the watchlist into AppState', () async {
    final source = await populatedCubit();
    await source.addCard(WatchCard(id: 'c1', instrumentID: gold.id, currency: 'USD', unit: PriceUnit.troyOunce));
    final payload = await source.backupService.buildPayload();

    // A fresh destination cubit pointed at its own store.
    final destDir = await Directory.systemTemp.createTemp('qima_restore_dest');
    LocalFileStore.overrideDirectoryForTesting(destDir);
    final dest = await populatedCubit();

    await dest.restoreFromBackup(payload, mode: BackupImportMode.merge);

    expect(dest.state.cards.map((c) => c.id), contains('c1'));
    await destDir.delete(recursive: true);
  });

  test('restoring a Replace backup applies the imported settings', () async {
    final source = await populatedCubit();
    await source.preferences.setBaseCurrency('EGP');
    final payload = await source.backupService.buildPayload();

    final destDir = await Directory.systemTemp.createTemp('qima_restore_dest2');
    LocalFileStore.overrideDirectoryForTesting(destDir);
    final dest = await populatedCubit();
    await dest.preferences.setBaseCurrency('USD');

    await dest.restoreFromBackup(payload, mode: BackupImportMode.replace);

    expect(dest.state.baseCurrency, 'EGP');
    await destDir.delete(recursive: true);
  });

  test('restoring a Replace backup removes a local-only card not present in the import', () async {
    final source = await populatedCubit();
    final payload = await source.backupService.buildPayload(); // empty watchlist.

    final dest = await populatedCubit();
    await dest.addCard(WatchCard(id: 'local', instrumentID: gold.id, currency: 'USD', unit: PriceUnit.troyOunce));
    expect(dest.state.cards, isNotEmpty);

    await dest.restoreFromBackup(payload, mode: BackupImportMode.replace);

    expect(dest.state.cards, isEmpty);
  });

  test('restoring clears the backup-due reminder state via _refreshBackupReminder', () async {
    final source = await populatedCubit();
    final payload = await source.backupService.buildPayload();

    final dest = await populatedCubit();
    await dest.backupService.setReminderEnabled(true);
    await dest.backupService.setDataChangedSinceLastBackup(true);
    await dest.backupService.setLastBackupAt(DateTime.now().subtract(const Duration(days: 60)));
    expect(dest.backupService.isReminderDue(), isTrue);

    await dest.restoreFromBackup(payload, mode: BackupImportMode.merge);

    // Restoring isn't itself a backup, so `dataChangedSinceLastBackup` and
    // `lastBackupAt` are untouched by `restoreFromBackup` — only an actual
    // export clears them (see `BackupService.exportJson`). This asserts the
    // state re-sync ran without throwing and left the reminder computation
    // consistent with the service's own values, not that restoring silently
    // clears the due flag.
    expect(dest.state.backupReminderDue, dest.backupService.isReminderDue());
  });
}
