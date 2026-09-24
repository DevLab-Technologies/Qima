import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qima/services/cloud_kv_store.dart';
import 'package:qima/services/icloud_kv_store.dart';

/// Exercises [IcloudKVStore] against a mocked `qima/cloud_kv`
/// `MethodChannel` + `qima/cloud_kv/changes` `EventChannel`, standing in for
/// `CloudKVPlugin.swift` — verifies the Dart side speaks the exact wire
/// contract the native plugin implements (method names/args, event payload
/// shape, reason-string mapping) without needing a real iOS/macOS host.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const methodChannel = MethodChannel('qima/cloud_kv');
  const eventChannel = EventChannel('qima/cloud_kv/changes');
  final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() {
    messenger.setMockMethodCallHandler(methodChannel, null);
    messenger.setMockStreamHandler(eventChannel, null);
  });

  test('getString/setString/synchronize/accountStatus call through with the right args', () async {
    final calls = <MethodCall>[];
    messenger.setMockMethodCallHandler(methodChannel, (call) async {
      calls.add(call);
      switch (call.method) {
        case 'getString':
          return 'stored-value';
        case 'setString':
          return null;
        case 'synchronize':
          return true;
        case 'accountStatus':
          return true;
      }
      return null;
    });

    final store = IcloudKVStore();
    expect(await store.getString('watchcards.records'), 'stored-value');
    expect(await store.accountStatus(), isTrue);
    await store.setString('watchcards.records', '[]');
    await store.synchronize();

    expect(calls[0].method, 'getString');
    expect(calls[0].arguments, {'key': 'watchcards.records'});
    expect(calls[1].method, 'accountStatus');
    expect(calls[2].method, 'setString');
    expect(calls[2].arguments, {'key': 'watchcards.records', 'value': '[]'});
    expect(calls[3].method, 'synchronize');
  });

  test('getString returns null when the native side has nothing stored', () async {
    messenger.setMockMethodCallHandler(methodChannel, (call) async => null);
    final store = IcloudKVStore();
    expect(await store.getString('missing'), isNull);
  });

  test('accountStatus defaults to false if the platform returns null', () async {
    messenger.setMockMethodCallHandler(methodChannel, (call) async => null);
    final store = IcloudKVStore();
    expect(await store.accountStatus(), isFalse);
  });

  test('external-change events decode keys and a known reason', () async {
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

    final store = IcloudKVStore();
    final event = await store.didChangeExternally.first;
    expect(event.keys, ['watchcards.records']);
    expect(event.reason, CloudKVChangeReason.serverChange);
  });

  test('an unrecognized reason string decodes to unknown rather than throwing', () async {
    messenger.setMockStreamHandler(
      eventChannel,
      MockStreamHandler.inline(
        onListen: (arguments, events) {
          events.success({'keys': <String>[], 'reason': 'somethingNewFromAFutureOS'});
        },
      ),
    );

    final store = IcloudKVStore();
    final event = await store.didChangeExternally.first;
    expect(event.keys, isEmpty);
    expect(event.reason, CloudKVChangeReason.unknown);
  });

  test('quotaViolationChange and accountChange decode correctly', () async {
    messenger.setMockStreamHandler(
      eventChannel,
      MockStreamHandler.inline(
        onListen: (arguments, events) {
          events.success({'keys': <String>[], 'reason': 'quotaViolationChange'});
          events.success({'keys': <String>[], 'reason': 'accountChange'});
        },
      ),
    );

    final store = IcloudKVStore();
    final events = await store.didChangeExternally.take(2).toList();
    expect(events.map((e) => e.reason), [CloudKVChangeReason.quotaViolationChange, CloudKVChangeReason.accountChange]);
  });
}
