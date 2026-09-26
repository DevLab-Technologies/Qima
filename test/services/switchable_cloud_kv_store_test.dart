import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qima/services/cloud_kv_store.dart';
import 'package:qima/services/icloud_kv_store.dart';
import 'package:qima/services/switchable_cloud_kv_store.dart';

/// [SwitchableCloudKVStore] routes to [IcloudKVStore] or
/// [LocalOnlyCloudKVStore] without ever changing identity (spec Phase 7:
/// "iOS: MethodChannel ... + SwitchableCloudKVStore forwarding to iCloud or
/// LocalOnly so turning sync on/off doesn't rebuild stores"). These tests
/// mock the underlying `qima/cloud_kv` channels the same way
/// `icloud_kv_store_test.dart` does, standing in for `CloudKVPlugin.swift`.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const methodChannel = MethodChannel('qima/cloud_kv');
  const eventChannel = EventChannel('qima/cloud_kv/changes');
  final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  // Shared in-memory "cloud" the mocked method channel reads/writes, so
  // reads reflect prior writes exactly like the real NSUbiquitousKeyValueStore
  // would.
  late Map<String, String> cloudValues;

  setUp(() {
    cloudValues = {};
    messenger.setMockMethodCallHandler(methodChannel, (call) async {
      switch (call.method) {
        case 'getString':
          final key = (call.arguments as Map)['key'] as String;
          return cloudValues[key];
        case 'setString':
          final args = call.arguments as Map;
          cloudValues[args['key'] as String] = args['value'] as String;
          return null;
        case 'synchronize':
          return true;
        case 'accountStatus':
          return true;
      }
      return null;
    });
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(methodChannel, null);
    messenger.setMockStreamHandler(eventChannel, null);
  });

  test('starts disabled: reads/writes never touch the platform channel', () async {
    final store = SwitchableCloudKVStore();
    expect(store.enabled, isFalse);

    await store.setString('k', 'v');
    expect(cloudValues, isEmpty); // Went to LocalOnlyCloudKVStore, not the channel.
    expect(await store.getString('k'), isNull);

    await store.dispose();
  });

  test('enabling routes reads/writes to the real iCloud channel', () async {
    final store = SwitchableCloudKVStore();
    store.setEnabled(true);
    expect(store.enabled, isTrue);

    await store.setString('watchcards.records', '[]');
    expect(cloudValues['watchcards.records'], '[]');
    expect(await store.getString('watchcards.records'), '[]');

    await store.dispose();
  });

  test('disabling after enabling leaves previously-written cloud data untouched', () async {
    final store = SwitchableCloudKVStore();
    store.setEnabled(true);
    await store.setString('watchcards.records', '["a"]');
    store.setEnabled(false);

    // Reading now goes to LocalOnlyCloudKVStore (always null), but the
    // cloud's own copy is untouched — nothing was deleted by disabling.
    expect(await store.getString('watchcards.records'), isNull);
    expect(cloudValues['watchcards.records'], '["a"]');

    await store.dispose();
  });

  test('external-change events only forward while enabled', () async {
    messenger.setMockStreamHandler(
      eventChannel,
      MockStreamHandler.inline(
        onListen: (arguments, events) {
          events.success({
            'keys': ['watchcards.records'],
            'reason': 'serverChange',
          });
        },
      ),
    );

    final store = SwitchableCloudKVStore();
    final received = <CloudKVChangeEvent>[];
    final subscription = store.didChangeExternally.listen(received.add);

    store.setEnabled(true);
    await pumpEventQueue();
    expect(received, hasLength(1));
    expect(received.single.keys, ['watchcards.records']);

    await subscription.cancel();
    await store.dispose();
  });

  test('accountStatus reflects the real iCloud account regardless of enabled', () async {
    final store = SwitchableCloudKVStore();
    // accountStatus is used to decide WHETHER to enable, so it must answer
    // even while still disabled.
    expect(await store.accountStatus(), isTrue);
    await store.dispose();
  });
}
