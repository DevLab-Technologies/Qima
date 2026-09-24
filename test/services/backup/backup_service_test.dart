import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:qima/models/asset.dart';
import 'package:qima/models/backup.dart';
import 'package:qima/models/holding.dart';
import 'package:qima/models/watch_card.dart';
import 'package:qima/services/alerts_store.dart';
import 'package:qima/services/backup/backup_codec.dart';
import 'package:qima/services/backup/backup_service.dart';
import 'package:qima/services/cloud_kv_store.dart';
import 'package:qima/services/custom_instrument_store.dart';
import 'package:qima/services/holdings_store.dart';
import 'package:qima/services/local_file_store.dart';
import 'package:qima/services/preferences.dart';
import 'package:qima/services/watchlist_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

WatchCard _card(String id, {String currency = 'USD'}) =>
    WatchCard(id: id, instrumentID: 'metal.XAU', currency: currency, unit: PriceUnit.troyOunce);

HoldingLot _lot(String id, {double quantity = 1}) => HoldingLot(
      id: id,
      instrumentID: 'metal.XAU',
      quantity: quantity,
      unit: PriceUnit.troyOunce,
      unitCost: 1900,
      costCurrency: 'USD',
      date: DateTime(2026, 1, 1),
    );

/// Every store keys its on-disk file by a FIXED filename (e.g.
/// `watchcards.records.json`), not by an instance id — two [BackupService]s
/// pointed at the same [LocalFileStore] directory are therefore the SAME
/// store, not two independent ones. Tests that need to simulate a second
/// "device" (to build an import payload that's genuinely foreign to the
/// store under test) run [body] against a scratch temp dir and restore
/// [originalDir] as the active one before returning, so the rest of the
/// test keeps writing to its own store afterward.
Future<T> withSeparateLocalStore<T>(Directory originalDir, Future<T> Function() body) async {
  final otherDir = await Directory.systemTemp.createTemp('qima_backup_service_other');
  LocalFileStore.overrideDirectoryForTesting(otherDir);
  try {
    return await body();
  } finally {
    LocalFileStore.overrideDirectoryForTesting(originalDir);
    await otherDir.delete(recursive: true);
  }
}

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('qima_backup_service_test');
    LocalFileStore.overrideDirectoryForTesting(tempDir);
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  Future<BackupService> makeService({CloudKVStore? cloud}) async {
    final kv = cloud ?? LocalOnlyCloudKVStore();
    return BackupService(
      watchlistStore: WatchlistStore(cloud: kv),
      holdingsStore: HoldingsStore(cloud: kv),
      customInstrumentStore: CustomInstrumentStore(cloud: kv),
      alertsStore: AlertsStore(cloud: kv),
      preferences: await Preferences.create(cloud: kv),
    );
  }

  group('buildPayload / round trip', () {
    test('export then import(merge) restores everything on a fresh store', () async {
      final source = await makeService();
      await source.watchlistStore.upsert(_card('c1'));
      await source.holdingsStore.upsert(_lot('l1'));

      final payload = await source.buildPayload();
      expect(payload.watchcards, hasLength(1));
      expect(payload.holdings, hasLength(1));

      final destTempDir = await Directory.systemTemp.createTemp('qima_backup_service_dest');
      LocalFileStore.overrideDirectoryForTesting(destTempDir);
      final dest = await makeService();
      await dest.import(payload, mode: BackupImportMode.merge);

      final cards = await dest.watchlistStore.load();
      final lots = await dest.holdingsStore.load();
      expect(cards.map((c) => c.id), contains('c1'));
      expect(lots.map((l) => l.id), contains('l1'));

      await destTempDir.delete(recursive: true);
    });
  });

  group('merge (last-write-wins)', () {
    test('keeps a newer LOCAL edit over an older imported one', () async {
      final service = await makeService();
      await service.watchlistStore.upsert(_card('c1', currency: 'USD'));
      final exported = await service.watchlistStore.exportRecords();

      // Local edit happens AFTER the export snapshot was taken.
      await service.watchlistStore.upsert(_card('c1', currency: 'EUR'));

      await service.import(
        BackupPayloadBuilder.fromRecords(watchcards: exported),
        mode: BackupImportMode.merge,
      );

      final cards = await service.watchlistStore.load();
      expect(cards.single.currency, 'EUR'); // the newer local edit wins.
    });

    test('adds an item present only in the import', () async {
      final service = await makeService();
      await service.watchlistStore.upsert(_card('c1'));

      final imported = await withSeparateLocalStore(tempDir, () async {
        final other = await makeService();
        await other.watchlistStore.upsert(_card('c2'));
        return other.watchlistStore.exportRecords();
      });

      await service.import(BackupPayloadBuilder.fromRecords(watchcards: imported), mode: BackupImportMode.merge);

      final ids = (await service.watchlistStore.load()).map((c) => c.id).toSet();
      expect(ids, {'c1', 'c2'});
    });

    test('does not touch settings', () async {
      final service = await makeService();
      await service.preferences.setBaseCurrency('EGP');
      final payload = await service.buildPayload();
      final importedSettings = payload.settings.copyWithBaseCurrency('USD');

      await service.import(
        BackupPayloadBuilder.fromRecords(settings: importedSettings),
        mode: BackupImportMode.merge,
      );

      expect(await service.preferences.baseCurrency, 'EGP');
    });
  });

  group('replace (tombstoning)', () {
    test('tombstones every local live item not re-added by the import', () async {
      final service = await makeService();
      await service.watchlistStore.upsert(_card('local-only'));

      final imported = await withSeparateLocalStore(tempDir, () async {
        final other = await makeService();
        await other.watchlistStore.upsert(_card('imported'));
        return other.watchlistStore.exportRecords();
      });

      await service.import(BackupPayloadBuilder.fromRecords(watchcards: imported), mode: BackupImportMode.replace);

      final live = (await service.watchlistStore.load()).map((c) => c.id).toSet();
      expect(live, {'imported'});
      expect(live, isNot(contains('local-only')));
    });

    test('applies settings', () async {
      final service = await makeService();
      await service.preferences.setBaseCurrency('USD');
      final payload = await service.buildPayload();
      final importedSettings = payload.settings.copyWithBaseCurrency('EGP');

      await service.import(
        BackupPayloadBuilder.fromRecords(settings: importedSettings),
        mode: BackupImportMode.replace,
      );

      expect(await service.preferences.baseCurrency, 'EGP');
    });
  });

  group('diff counts', () {
    test('merge diff: added/updated/removed reflect what the merge would actually do', () async {
      final service = await makeService();
      await service.watchlistStore.upsert(_card('existing'));
      final imported = await withSeparateLocalStore(tempDir, () async {
        final other = await makeService();
        await other.watchlistStore.upsert(_card('new-item'));
        return other.watchlistStore.exportRecords();
      });

      final preview = await service.preview(
        BackupCodec.parseEnvelope(
          BackupCodec.encodePlain(
            payload: BackupPayloadBuilder.fromRecords(watchcards: imported),
            app: _testAppInfo,
          ),
        ),
      );

      expect(preview.mergeDiff.added, 1); // "new-item" only.
      expect(preview.mergeDiff.removed, 0); // merge never removes.
    });

    test('replace diff: counts the existing item as removed when not re-imported', () async {
      final service = await makeService();
      await service.watchlistStore.upsert(_card('existing'));
      final imported = await withSeparateLocalStore(tempDir, () async {
        final other = await makeService();
        await other.watchlistStore.upsert(_card('new-item'));
        return other.watchlistStore.exportRecords();
      });

      final preview = await service.preview(
        BackupCodec.parseEnvelope(
          BackupCodec.encodePlain(
            payload: BackupPayloadBuilder.fromRecords(watchcards: imported),
            app: _testAppInfo,
          ),
        ),
      );

      expect(preview.replaceDiff.added, 1);
      expect(preview.replaceDiff.removed, 1); // "existing" gets tombstoned.
    });
  });

  group('atomicity on failed import', () {
    test('nothing changes when the file fails to parse before any store is touched', () async {
      final service = await makeService();
      await service.watchlistStore.upsert(_card('c1'));

      expect(
        () => service.parseEnvelope('not a qima backup file'),
        throwsA(isA<BackupError>()),
      );

      final cards = await service.watchlistStore.load();
      expect(cards.map((c) => c.id), ['c1']); // untouched.
    });

    test('nothing changes when the password is wrong', () async {
      final service = await makeService();
      await service.watchlistStore.upsert(_card('c1'));
      final payload = await service.buildPayload();
      // A low test iteration count (see `BackupCrypto.encrypt`'s doc
      // comment) — this test is about the wrong-password error path, not
      // the KDF's real cost, and decoding always reads `kdf.iterations`
      // back from the file regardless.
      final json = await BackupCodec.encodeEncrypted(
        payload: payload,
        app: _testAppInfo,
        password: 'right',
        kdfIterations: 10,
      );
      final envelope = service.parseEnvelope(json);

      await expectLater(
        () => service.preview(envelope, password: 'wrong'),
        throwsA(isA<BackupError>()),
      );

      final cards = await service.watchlistStore.load();
      expect(cards.map((c) => c.id), ['c1']); // untouched — preview never writes anyway.
    });
  });

  group('reminder due logic', () {
    test('never backed up + data changed + reminder on => due', () async {
      final service = await makeService();
      await service.setReminderEnabled(true);
      await service.setDataChangedSinceLastBackup(true);
      expect(service.isReminderDue(), isTrue);
    });

    test('reminder off => never due, even with stale data', () async {
      final service = await makeService();
      await service.setReminderEnabled(false);
      await service.setDataChangedSinceLastBackup(true);
      expect(service.isReminderDue(), isFalse);
    });

    test('no data changed since last backup => not due, regardless of elapsed time', () async {
      final service = await makeService();
      await service.setReminderEnabled(true);
      await service.setDataChangedSinceLastBackup(false);
      await service.setLastBackupAt(DateTime.now().subtract(const Duration(days: 400)));
      expect(service.isReminderDue(), isFalse);
    });

    test('backed up 29 days ago with changed data => not yet due', () async {
      final service = await makeService();
      await service.setReminderEnabled(true);
      await service.setDataChangedSinceLastBackup(true);
      final now = DateTime(2026, 3, 1);
      await service.setLastBackupAt(now.subtract(const Duration(days: 29)));
      expect(service.isReminderDue(now: now), isFalse);
    });

    test('backed up 31 days ago with changed data => due', () async {
      final service = await makeService();
      await service.setReminderEnabled(true);
      await service.setDataChangedSinceLastBackup(true);
      final now = DateTime(2026, 3, 1);
      await service.setLastBackupAt(now.subtract(const Duration(days: 31)));
      expect(service.isReminderDue(now: now), isTrue);
    });

    test('shouldNotifyReminder caps at once per 30 days even if due repeatedly', () async {
      final service = await makeService();
      await service.setReminderEnabled(true);
      await service.setDataChangedSinceLastBackup(true);
      final now = DateTime(2026, 3, 1);
      await service.setLastBackupAt(now.subtract(const Duration(days: 40)));
      await service.setReminderNotifiedAt(now.subtract(const Duration(days: 5)));

      expect(service.isReminderDue(now: now), isTrue); // still due for the in-app card...
      expect(service.shouldNotifyReminder(now: now), isFalse); // ...but already notified recently.
    });

    test('shouldNotifyReminder fires again once 30 days pass since the last notification', () async {
      final service = await makeService();
      await service.setReminderEnabled(true);
      await service.setDataChangedSinceLastBackup(true);
      final now = DateTime(2026, 3, 1);
      await service.setLastBackupAt(now.subtract(const Duration(days: 70)));
      await service.setReminderNotifiedAt(now.subtract(const Duration(days: 31)));

      expect(service.shouldNotifyReminder(now: now), isTrue);
    });
  });
}

const _testAppInfo = BackupAppInfo(version: '1.0.0', build: '1');

/// Test-only helper for constructing a [BackupPayload] from raw exported
/// [Record] lists (what `SyncedStore.exportRecords`/`Store.exportRecords`
/// return), since production code always goes through
/// `BackupService.buildPayload` for a full payload but these tests want to
/// exercise merge/replace/diff behavior against a deliberately partial one.
extension BackupPayloadBuilder on BackupPayload {
  static BackupPayload fromRecords({
    List<dynamic> watchcards = const [],
    List<dynamic> holdings = const [],
    List<dynamic> customInstruments = const [],
    List<dynamic> alerts = const [],
    BackupSettings? settings,
  }) {
    return BackupPayload(
      watchcards: watchcards.map((r) => (r as dynamic).toJson() as Map<String, dynamic>).toList(),
      holdings: holdings.map((r) => (r as dynamic).toJson() as Map<String, dynamic>).toList(),
      customInstruments: customInstruments.map((r) => (r as dynamic).toJson() as Map<String, dynamic>).toList(),
      alerts: alerts.map((r) => (r as dynamic).toJson() as Map<String, dynamic>).toList(),
      settings: settings ??
          const BackupSettings(
            baseCurrency: 'USD',
            appLanguage: 'system',
            appearance: 'system',
            preferredChartRange: 'month1',
            widgetRefreshInterval: 15,
          ),
    );
  }
}

extension _SettingsCopy on BackupSettings {
  BackupSettings copyWithBaseCurrency(String value) => BackupSettings(
        baseCurrency: value,
        appLanguage: appLanguage,
        appearance: appearance,
        preferredChartRange: preferredChartRange,
        widgetRefreshInterval: widgetRefreshInterval,
      );
}
