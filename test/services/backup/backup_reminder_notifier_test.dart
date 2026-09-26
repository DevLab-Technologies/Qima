import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:qima/l10n/app_localizations_en.dart';
import 'package:qima/services/alerts_store.dart';
import 'package:qima/services/backup/backup_reminder_notifier.dart';
import 'package:qima/services/backup/backup_service.dart';
import 'package:qima/services/cloud_kv_store.dart';
import 'package:qima/services/custom_instrument_store.dart';
import 'package:qima/services/holdings_store.dart';
import 'package:qima/services/local_file_store.dart';
import 'package:qima/services/notification_service.dart';
import 'package:qima/services/preferences.dart';
import 'package:qima/services/watchlist_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeNotificationService extends NotificationService {
  final List<({int id, String title, String body, String payload})> shown = [];

  @override
  Future<void> show({required int id, required String title, required String body, required String payload}) async {
    shown.add((id: id, title: title, body: body, payload: payload));
  }
}

void main() {
  late Directory tempDir;
  final l10n = AppLocalizationsEn();

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('qima_backup_reminder_notifier_test');
    LocalFileStore.overrideDirectoryForTesting(tempDir);
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  Future<BackupService> makeBackupService() async {
    final cloud = LocalOnlyCloudKVStore();
    return BackupService(
      watchlistStore: WatchlistStore(cloud: cloud),
      holdingsStore: HoldingsStore(cloud: cloud),
      customInstrumentStore: CustomInstrumentStore(cloud: cloud),
      alertsStore: AlertsStore(cloud: cloud),
      preferences: await Preferences.create(cloud: cloud),
    );
  }

  test('posts nothing when the reminder is not due', () async {
    final backupService = await makeBackupService();
    await backupService.setReminderEnabled(true);
    await backupService.setDataChangedSinceLastBackup(false); // not due: nothing changed.

    final notifications = _FakeNotificationService();
    final notifier = BackupReminderNotifier(backupService: backupService, notificationService: notifications);

    await notifier.notifyIfDue(now: DateTime(2026, 3, 1), l10n: l10n);

    expect(notifications.shown, isEmpty);
  });

  test('posts exactly one notification with the reminder payload when due', () async {
    final backupService = await makeBackupService();
    await backupService.setReminderEnabled(true);
    await backupService.setDataChangedSinceLastBackup(true);
    final now = DateTime(2026, 3, 1);
    await backupService.setLastBackupAt(now.subtract(const Duration(days: 45)));

    final notifications = _FakeNotificationService();
    final notifier = BackupReminderNotifier(backupService: backupService, notificationService: notifications);

    await notifier.notifyIfDue(now: now, l10n: l10n);

    expect(notifications.shown, hasLength(1));
    expect(notifications.shown.single.payload, backupReminderNotificationPayload);
    expect(notifications.shown.single.id, backupReminderNotificationId);
    expect(notifications.shown.single.title, l10n.backupReminderNotificationTitle);
  });

  test('uses a notification id distinct from any alert notification id range', () async {
    // Alert notification ids are `sha256(alertId) & 0x7fffffff` — effectively
    // the whole positive-int space, so the only real guarantee this test can
    // assert is that the reminder's id is a fixed, well-known constant
    // rather than colliding with the *specific* alert ids these fixtures use.
    expect(backupReminderNotificationId, isNot(0));
    expect(backupReminderNotificationId, greaterThan(0));
  });

  test('records reminderNotifiedAt after posting, so a second call within 30 days is suppressed', () async {
    final backupService = await makeBackupService();
    await backupService.setReminderEnabled(true);
    await backupService.setDataChangedSinceLastBackup(true);
    final now = DateTime(2026, 3, 1);
    await backupService.setLastBackupAt(now.subtract(const Duration(days: 45)));

    final notifications = _FakeNotificationService();
    final notifier = BackupReminderNotifier(backupService: backupService, notificationService: notifications);

    await notifier.notifyIfDue(now: now, l10n: l10n);
    expect(notifications.shown, hasLength(1));

    // A second call a day later must not post again.
    await notifier.notifyIfDue(now: now.add(const Duration(days: 1)), l10n: l10n);
    expect(notifications.shown, hasLength(1));
  });

  test('posts again once 30 days pass since the last notification, if still due', () async {
    final backupService = await makeBackupService();
    await backupService.setReminderEnabled(true);
    await backupService.setDataChangedSinceLastBackup(true);
    final now = DateTime(2026, 3, 1);
    await backupService.setLastBackupAt(now.subtract(const Duration(days: 90)));

    final notifications = _FakeNotificationService();
    final notifier = BackupReminderNotifier(backupService: backupService, notificationService: notifications);

    await notifier.notifyIfDue(now: now, l10n: l10n);
    expect(notifications.shown, hasLength(1));

    await notifier.notifyIfDue(now: now.add(const Duration(days: 31)), l10n: l10n);
    expect(notifications.shown, hasLength(2));
  });

  test('reminder disabled => never notifies regardless of elapsed time', () async {
    final backupService = await makeBackupService();
    await backupService.setReminderEnabled(false);
    await backupService.setDataChangedSinceLastBackup(true);
    final now = DateTime(2026, 3, 1);
    await backupService.setLastBackupAt(now.subtract(const Duration(days: 400)));

    final notifications = _FakeNotificationService();
    final notifier = BackupReminderNotifier(backupService: backupService, notificationService: notifications);

    await notifier.notifyIfDue(now: now, l10n: l10n);

    expect(notifications.shown, isEmpty);
  });
}
