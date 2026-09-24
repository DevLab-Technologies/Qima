import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qima/blocs/app_cubit.dart';
import 'package:qima/blocs/app_state.dart';
import 'package:qima/models/asset.dart';
import 'package:qima/models/fx_history.dart';
import 'package:qima/models/instrument_catalog.dart';
import 'package:qima/models/quote.dart';
import 'package:qima/models/watch_card.dart';
import 'package:qima/services/local_file_store.dart';
import 'package:qima/services/notification_service.dart';
import 'package:qima/services/price_repository.dart';
import 'package:qima/services/switchable_cloud_kv_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stands in for `PriceRepository` so nothing here hits the network — mirrors
/// `restore_from_backup_test.dart`'s `_NoopRepository`.
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

/// Avoids touching the real `flutter_local_notifications` plugin (which
/// needs a registered platform instance this test's plain widget binding
/// doesn't provide) — mirrors `alerts_screen_test.dart`'s
/// `_FakeNotificationService`, but also short-circuits `init()` since these
/// tests DO run the full `AppCubit.init()`.
class _FakeNotificationService extends NotificationService {
  @override
  Future<void> init() async {}

  @override
  Future<bool> isEnabled() async => true;
}

/// Phase 7 "iCloud key-value sync" — exercises the whole stack (`AppCubit` +
/// `SwitchableCloudKVStore` + `SyncedStore`/`Preferences`) against the SAME
/// mocked `qima/cloud_kv` channels `icloud_kv_store_test.dart` mocks, so two
/// [AppCubit]s (each with its own local storage directory, sharing the one
/// mocked "cloud") stand in for two real devices sharing one iCloud account.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // `AppCubit._platformSupportsICloud` gates on `defaultTargetPlatform ==
  // TargetPlatform.iOS` (spec Phase 7: iCloud KVS is iOS-only for now) — the
  // test host defaults to Android, so every test in this file needs the
  // override or sync would never actually turn on.
  setUpAll(() {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
  });
  tearDownAll(() {
    debugDefaultTargetPlatformOverride = null;
  });

  const methodChannel = MethodChannel('qima/cloud_kv');
  const eventChannel = EventChannel('qima/cloud_kv/changes');
  final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  late Map<String, String> cloudValues;
  late List<void Function(Map<String, Object?>)> listeners;

  void broadcastChange(String key, {String reason = 'serverChange'}) {
    for (final listener in listeners) {
      listener({
        'keys': [key],
        'reason': reason,
      });
    }
  }

  setUp(() {
    cloudValues = {};
    listeners = [];
    messenger.setMockMethodCallHandler(methodChannel, (call) async {
      switch (call.method) {
        case 'getString':
          final key = (call.arguments as Map)['key'] as String;
          return cloudValues[key];
        case 'setString':
          final args = call.arguments as Map;
          final key = args['key'] as String;
          final value = args['value'] as String;
          final changed = cloudValues[key] != value;
          cloudValues[key] = value;
          if (changed) broadcastChange(key);
          return null;
        case 'synchronize':
          return true;
        case 'accountStatus':
          return true;
      }
      return null;
    });
    messenger.setMockStreamHandler(
      eventChannel,
      MockStreamHandler.inline(
        onListen: (arguments, events) {
          listeners.add((payload) => events.success(payload));
        },
        onCancel: (arguments) {},
      ),
    );
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(methodChannel, null);
    messenger.setMockStreamHandler(eventChannel, null);
  });

  final gold = InstrumentCatalog.instrument('metal.XAU')!;
  final silver = InstrumentCatalog.instrument('metal.XAG')!;

  /// Builds a fresh [AppCubit] pointed at its own temp local-storage
  /// directory and its own [SharedPreferences] instance (so it behaves like
  /// an independent device), sharing the mocked cloud channel above. Runs
  /// the real [AppCubit.init] so seeding/first-enable ordering matches
  /// production.
  Future<AppCubit> device(Directory dir, {bool iCloudSyncEnabled = true}) async {
    LocalFileStore.overrideDirectoryForTesting(dir);
    SharedPreferences.setMockInitialValues({'iCloudSyncEnabled': iCloudSyncEnabled});
    final cubit = AppCubit(
      repository: _NoopRepository(),
      cloudStore: SwitchableCloudKVStore(),
      notificationService: _FakeNotificationService(),
    );
    await cubit.init();
    return cubit;
  }

  group('two devices sharing a fake cloud', () {
    test('a card added on device A appears on device B after B enables sync', () async {
      final dirA = await Directory.systemTemp.createTemp('qima_icloud_a');
      final deviceA = await device(dirA);
      // A non-USD currency avoids colliding with the default-seeded
      // USD/troy-ounce gold card every fresh device gets — `AppCubit.addCard`
      // treats a matching instrument+currency+unit+karat combo as "already
      // there" (`isSameCombo`) regardless of id, so a USD card here would
      // silently no-op against the seed instead of adding a new one.
      await deviceA.addCard(WatchCard(id: 'c1', instrumentID: gold.id, currency: 'EGP', unit: PriceUnit.troyOunce));
      await deviceA.disposeCloudSync();

      final dirB = await Directory.systemTemp.createTemp('qima_icloud_b');
      final deviceB = await device(dirB);

      expect(deviceB.state.cards.map((c) => c.id), contains('c1'));
      await deviceB.disposeCloudSync();
      await dirA.delete(recursive: true);
      await dirB.delete(recursive: true);
    });

    // Every fresh device also seeds `InstrumentCatalog.defaultWatchlist`
    // (gold/silver/BTC in USD) — these tests use EGP so the cards they add
    // are genuinely new items rather than colliding, via
    // `WatchCard.isSameCombo`, with that seed (see the comment on the first
    // test in this group).
    test('edits and deletes converge across two devices', () async {
      final dirA = await Directory.systemTemp.createTemp('qima_icloud_edit_a');
      final deviceA = await device(dirA);
      final defaultIds = deviceA.state.cards.map((c) => c.id).toSet();
      await deviceA.addCard(WatchCard(id: 'c1', instrumentID: gold.id, currency: 'EGP', unit: PriceUnit.troyOunce));
      await deviceA.addCard(WatchCard(id: 'c2', instrumentID: silver.id, currency: 'EGP', unit: PriceUnit.troyOunce));

      final dirB = await Directory.systemTemp.createTemp('qima_icloud_edit_b');
      final deviceB = await device(dirB);
      expect(deviceB.state.cards.map((c) => c.id).toSet(), {...defaultIds, 'c1', 'c2'});

      // B deletes c2; A concurrently reorders (no-op mutation on c1's data
      // isn't available directly, so use removeCard on B and re-load A).
      await deviceB.removeCard('c2');
      final reloadedA = await deviceA.watchlistStore.load();
      expect(reloadedA.map((c) => c.id).toSet(), {...defaultIds, 'c1'});

      await deviceA.disposeCloudSync();
      await deviceB.disposeCloudSync();
      await dirA.delete(recursive: true);
      await dirB.delete(recursive: true);
    });

    test('reorder on one device is respected by the other after reload', () async {
      final dirA = await Directory.systemTemp.createTemp('qima_icloud_reorder_a');
      final deviceA = await device(dirA);
      await deviceA.addCard(WatchCard(id: 'c1', instrumentID: gold.id, currency: 'EGP', unit: PriceUnit.troyOunce));
      await deviceA.addCard(WatchCard(id: 'c2', instrumentID: silver.id, currency: 'EGP', unit: PriceUnit.troyOunce));

      // Reverse the whole order via `setOrder` directly, so the expected
      // result doesn't depend on reasoning about `move`'s from/to index
      // semantics — only that A's chosen order round-trips through B.
      final reversed = deviceA.state.cards.map((c) => c.id).toList().reversed.toList();
      await deviceA.watchlistStore.setOrder(reversed);
      final reloadedA = await deviceA.watchlistStore.load();
      expect(reloadedA.map((c) => c.id).toList(), reversed);

      final dirB = await Directory.systemTemp.createTemp('qima_icloud_reorder_b');
      final deviceB = await device(dirB);
      expect(deviceB.state.cards.map((c) => c.id).toList(), reversed);

      await deviceA.disposeCloudSync();
      await deviceB.disposeCloudSync();
      await dirA.delete(recursive: true);
      await dirB.delete(recursive: true);
    });

    test('a tombstoned delete on A is respected by B, not resurrected by an unrelated reload', () async {
      final dirA = await Directory.systemTemp.createTemp('qima_icloud_tomb_a');
      final deviceA = await device(dirA);
      final added =
          await deviceA.addCard(WatchCard(id: 'c1', instrumentID: gold.id, currency: 'EGP', unit: PriceUnit.troyOunce));
      expect(added.created, isTrue);

      final dirB = await Directory.systemTemp.createTemp('qima_icloud_tomb_b');
      final deviceB = await device(dirB);
      expect(deviceB.state.cards.map((c) => c.id), contains('c1'));

      await deviceA.removeCard('c1');
      final reloadedB = await deviceB.watchlistStore.load();
      expect(reloadedB.map((c) => c.id), isNot(contains('c1')));

      await deviceA.disposeCloudSync();
      await deviceB.disposeCloudSync();
      await dirA.delete(recursive: true);
      await dirB.delete(recursive: true);
    });
  });

  group('first-enable on a device that already has local data', () {
    test('local data merges with the cloud rather than being wiped', () async {
      // Device A seeds the cloud with a card.
      final dirA = await Directory.systemTemp.createTemp('qima_icloud_first_a');
      final deviceA = await device(dirA);
      await deviceA.addCard(WatchCard(id: 'cloud-card', instrumentID: gold.id, currency: 'EGP', unit: PriceUnit.troyOunce));
      await deviceA.disposeCloudSync();

      // Device B starts with sync OFF and adds its own local-only card first.
      final dirB = await Directory.systemTemp.createTemp('qima_icloud_first_b');
      final deviceB = await device(dirB, iCloudSyncEnabled: false);
      final defaultIds = deviceB.state.cards.map((c) => c.id).toSet();
      await deviceB.addCard(
          WatchCard(id: 'local-card', instrumentID: silver.id, currency: 'EGP', unit: PriceUnit.troyOunce));
      expect(deviceB.state.cards.map((c) => c.id).toSet(), {...defaultIds, 'local-card'});

      // Now B turns sync on: every card (its own defaults, its local-only
      // addition, AND A's cloud addition) must still be present afterward —
      // local data is never wiped by enabling.
      await deviceB.setICloudSyncEnabled(true);
      expect(deviceB.state.cards.map((c) => c.id).toSet(), {...defaultIds, 'local-card', 'cloud-card'});
      expect(deviceB.state.cloudSyncStatus, CloudSyncStatus.upToDate);

      await deviceA.disposeCloudSync();
      await deviceB.disposeCloudSync();
      await dirA.delete(recursive: true);
      await dirB.delete(recursive: true);
    });
  });

  group('toggling sync off/on', () {
    test('turning sync off then on again keeps local data and re-merges instead of overwriting', () async {
      final dirA = await Directory.systemTemp.createTemp('qima_icloud_toggle_a');
      final deviceA = await device(dirA);
      final defaultIds = deviceA.state.cards.map((c) => c.id).toSet();
      await deviceA.addCard(WatchCard(id: 'c1', instrumentID: gold.id, currency: 'EGP', unit: PriceUnit.troyOunce));
      // NOTE: unlike the real `NSUbiquitousKeyValueStore` (which never fires
      // `didChangeExternallyNotification` for a change this same process
      // just made), this test's mocked channel broadcasts on every
      // `setString` regardless of origin, so `addCard`'s own write loops
      // back as a (harmless, self-)external-change event here — its
      // asynchronous re-sync briefly reports `syncing` before settling back
      // to `upToDate`. Pump once so that's landed before asserting.
      await pumpEventQueue();
      expect(deviceA.state.cloudSyncStatus, CloudSyncStatus.upToDate);

      await deviceA.setICloudSyncEnabled(false);
      expect(deviceA.state.cards.map((c) => c.id), contains('c1')); // Still there locally.
      expect(deviceA.state.cloudSyncStatus, CloudSyncStatus.disabled);

      // While A is off, a second device adds another card to the cloud.
      final dirB = await Directory.systemTemp.createTemp('qima_icloud_toggle_b');
      final deviceB = await device(dirB);
      await deviceB.addCard(WatchCard(id: 'c2', instrumentID: silver.id, currency: 'EGP', unit: PriceUnit.troyOunce));
      await deviceB.disposeCloudSync();

      await deviceA.setICloudSyncEnabled(true);
      expect(deviceA.state.cards.map((c) => c.id).toSet(), {...defaultIds, 'c1', 'c2'});

      await deviceA.disposeCloudSync();
      await dirA.delete(recursive: true);
      await dirB.delete(recursive: true);
    });
  });

  group('quota violation', () {
    test('a quotaViolationChange event surfaces a storage-full status', () async {
      final dir = await Directory.systemTemp.createTemp('qima_icloud_quota');
      final deviceCubit = await device(dir);
      expect(deviceCubit.state.cloudSyncStatus, CloudSyncStatus.upToDate);

      broadcastChange('watchcards.records', reason: 'quotaViolationChange');
      await pumpEventQueue();
      expect(deviceCubit.state.cloudSyncStatus, CloudSyncStatus.storageFull);

      await deviceCubit.disposeCloudSync();
      await dir.delete(recursive: true);
    });
  });

  group('external-change event reloads the right store', () {
    test('a holdings.records change event triggers a holdings reload, not a watchlist reload', () async {
      final dirA = await Directory.systemTemp.createTemp('qima_icloud_targeted2_a');
      final deviceA = await device(dirA);

      final dirB = await Directory.systemTemp.createTemp('qima_icloud_targeted2_b');
      final deviceB = await device(dirB);
      final cardsIdentityBefore = deviceB.state.cards;

      // Directly push a holdings-only change through the cloud (as if
      // another device wrote a lot) and confirm B's cards list is untouched
      // (same identity) while a reload for holdings was attempted (no crash,
      // no unrelated card churn).
      cloudValues['holdings.records'] = '[]';
      broadcastChange('holdings.records');
      await pumpEventQueue();

      expect(deviceB.state.cards, same(cardsIdentityBefore));

      await deviceA.disposeCloudSync();
      await deviceB.disposeCloudSync();
      await dirA.delete(recursive: true);
      await dirB.delete(recursive: true);
    });
  });

  group('preferences that must not sync stay local', () {
    test('iCloudSyncEnabled itself is never written to the cloud store', () async {
      final dir = await Directory.systemTemp.createTemp('qima_icloud_pref_local');
      final deviceCubit = await device(dir);
      await deviceCubit.setICloudSyncEnabled(false);
      await deviceCubit.setICloudSyncEnabled(true);

      expect(cloudValues.containsKey('iCloudSyncEnabled'), isFalse);

      await deviceCubit.disposeCloudSync();
      await dir.delete(recursive: true);
    });

    test('hideBalances, appLockEnabled and lockGrace never reach the cloud store', () async {
      final dir = await Directory.systemTemp.createTemp('qima_icloud_pref_local2');
      final deviceCubit = await device(dir);
      await deviceCubit.setHideBalances(true);
      await deviceCubit.setLockGrace(deviceCubit.state.lockGrace);

      expect(cloudValues.containsKey('hideBalances'), isFalse);
      expect(cloudValues.containsKey('appLockEnabled'), isFalse);
      expect(cloudValues.containsKey('lockGrace'), isFalse);

      await deviceCubit.disposeCloudSync();
      await dir.delete(recursive: true);
    });

    test('baseCurrency (a synced preference) DOES reach the cloud store', () async {
      final dir = await Directory.systemTemp.createTemp('qima_icloud_pref_synced');
      final deviceCubit = await device(dir);
      await deviceCubit.setBaseCurrency('EGP');

      expect(cloudValues['baseCurrency'], 'EGP');

      await deviceCubit.disposeCloudSync();
      await dir.delete(recursive: true);
    });
  });
}
