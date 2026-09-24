import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:qima/models/price_alert.dart';
import 'package:qima/services/alert_runtime_store.dart';
import 'package:qima/services/alerts_store.dart';
import 'package:qima/services/cloud_kv_store.dart';
import 'package:qima/services/local_file_store.dart';

/// In-memory [CloudKVStore], mirroring the one `synced_store_test.dart` uses
/// — lets two [AlertsStore]s stand in for the alert list syncing across two
/// devices without any real platform channel.
class _FakeCloudKVStore implements CloudKVStore {
  final Map<String, String> _values = {};
  final _controller = StreamController<CloudKVChangeEvent>.broadcast();

  @override
  Future<String?> getString(String key) async => _values[key];

  @override
  Future<void> setString(String key, String value) async {
    _values[key] = value;
    _controller.add(CloudKVChangeEvent(keys: [key], reason: CloudKVChangeReason.serverChange));
  }

  @override
  Future<void> synchronize() async {}

  @override
  Future<bool> accountStatus() async => true;

  @override
  Stream<CloudKVChangeEvent> get didChangeExternally => _controller.stream;
}

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('qima_alerts_store_test');
    LocalFileStore.overrideDirectoryForTesting(tempDir);
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  PriceAlert makeAlert({String id = 'a1', double target = 2000}) => PriceAlert(
        id: id,
        cardID: 'card1',
        kind: AlertKind.above,
        target: target,
        createdAt: DateTime(2024, 1, 1),
      );

  group('AlertsStore CRUD', () {
    test('upsert then load round-trips the alert definition', () async {
      final store = AlertsStore();
      await store.upsert(makeAlert());
      final loaded = await store.load();
      expect(loaded, hasLength(1));
      expect(loaded.single.target, 2000);
      expect(loaded.single.kind, AlertKind.above);
    });

    test('delete removes the alert from subsequent loads', () async {
      final store = AlertsStore();
      await store.upsert(makeAlert());
      await store.delete('a1');
      final loaded = await store.load();
      expect(loaded, isEmpty);
    });

    test('percentMove fields round-trip through JSON', () async {
      final store = AlertsStore();
      final alert = PriceAlert(
        id: 'a2',
        cardID: 'card1',
        kind: AlertKind.percentMove,
        percent: 0.07,
        direction: AlertDirection.down,
        window: AlertWindow.d7,
        repeats: true,
        createdAt: DateTime(2024, 1, 1),
      );
      await store.upsert(alert);
      final loaded = (await store.load()).single;
      expect(loaded.percent, 0.07);
      expect(loaded.direction, AlertDirection.down);
      expect(loaded.window, AlertWindow.d7);
      expect(loaded.repeats, isTrue);
    });
  });

  group('AlertsStore sync round-trip (definitions sync; runtime state never does)', () {
    test('an alert created on one device appears on another after load', () async {
      final cloud = _FakeCloudKVStore();
      final deviceA = AlertsStore(cloud: cloud);
      final deviceB = AlertsStore(cloud: cloud);

      await deviceA.upsert(makeAlert());
      final onB = await deviceB.load();

      expect(onB, hasLength(1));
      expect(onB.single.id, 'a1');
    });

    test('a delete on one device propagates to another', () async {
      final cloud = _FakeCloudKVStore();
      final deviceA = AlertsStore(cloud: cloud);
      final deviceB = AlertsStore(cloud: cloud);

      await deviceA.upsert(makeAlert());
      await deviceB.load();
      await deviceA.delete('a1');

      final onB = await deviceB.load();
      expect(onB, isEmpty);
    });
  });

  group('AlertRuntimeStore (local-only, spec: never synced)', () {
    test('updateOne persists lastSeenPrice/armed/lastFiredAt for later reads', () async {
      final store = AlertRuntimeStore();
      await store.updateOne('a1', (s) => s.copyWith(lastSeenPrice: 1999, armed: false, lastFiredAt: DateTime(2024, 6, 1)));

      final all = await store.loadAll();
      expect(all['a1']!.lastSeenPrice, 1999);
      expect(all['a1']!.armed, isFalse);
      expect(all['a1']!.lastFiredAt!.isAtSameMomentAs(DateTime(2024, 6, 1)), isTrue);
    });

    test('stateFor returns a fresh default (armed, no history) for an unknown alert id', () async {
      final store = AlertRuntimeStore();
      final all = await store.loadAll();
      final state = store.stateFor(all, 'never-seen');
      expect(state.armed, isTrue);
      expect(state.lastSeenPrice, isNull);
      expect(state.lastFiredAt, isNull);
    });

    test('pruneMissing removes runtime state for alerts that no longer exist', () async {
      final store = AlertRuntimeStore();
      await store.updateOne('a1', (s) => s.copyWith(lastSeenPrice: 100));
      await store.updateOne('a2', (s) => s.copyWith(lastSeenPrice: 200));

      await store.pruneMissing({'a1'});

      final all = await store.loadAll();
      expect(all.containsKey('a1'), isTrue);
      expect(all.containsKey('a2'), isFalse);
    });

    test('concurrent updateOne calls for different alerts do not clobber each other', () async {
      final store = AlertRuntimeStore();
      await Future.wait([
        store.updateOne('a1', (s) => s.copyWith(lastSeenPrice: 1)),
        store.updateOne('a2', (s) => s.copyWith(lastSeenPrice: 2)),
        store.updateOne('a3', (s) => s.copyWith(lastSeenPrice: 3)),
      ]);

      final all = await store.loadAll();
      expect(all['a1']!.lastSeenPrice, 1);
      expect(all['a2']!.lastSeenPrice, 2);
      expect(all['a3']!.lastSeenPrice, 3);
    });

    test('AlertRuntimeState is not part of PriceAlert JSON', () {
      // Documents the "never synced" invariant at the type level: PriceAlert
      // (the synced model) has no runtime-state fields at all, so there is
      // no field to accidentally serialize into the synced store.
      final alert = makeAlert();
      expect(alert.toJson().containsKey('lastSeenPrice'), isFalse);
      expect(alert.toJson().containsKey('lastFiredAt'), isFalse);
      expect(alert.toJson().containsKey('armed'), isFalse);
    });
  });
}
