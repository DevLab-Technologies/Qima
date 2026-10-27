import 'package:flutter_test/flutter_test.dart';
import 'package:qima/l10n/app_localizations_en.dart';
import 'package:qima/models/zakat.dart';
import 'package:qima/services/notification_service.dart';
import 'package:qima/services/preferences.dart';
import 'package:qima/services/zakat_reminder_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _RecordingNotifications extends NotificationService {
  final shown = <({int id, String title, String body, String payload})>[];

  @override
  Future<void> show({required int id, required String title, required String body, required String payload}) async {
    shown.add((id: id, title: title, body: body, payload: payload));
  }
}

void main() {
  late Preferences preferences;
  late _RecordingNotifications notifications;
  final l10n = AppLocalizationsEn();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await Preferences.create();
    notifications = _RecordingNotifications();
  });

  ZakatReminderNotifier notifier() =>
      ZakatReminderNotifier(preferences: preferences, notificationService: notifications);

  Future<void> settings({bool remind = true, DateTime? start}) => preferences.setZakatSettings(ZakatSettings(
        remind: remind,
        calendar: HawlCalendar.gregorian,
        hawlStart: start ?? DateTime(2025, 6, 1),
      ));

  test('posts on the day a hawl completes, with no amount in the text', () async {
    await settings();
    expect(await notifier().notifyIfDue(now: DateTime(2026, 6, 1, 9), l10n: l10n), isTrue);
    expect(notifications.shown, hasLength(1));
    final shown = notifications.shown.single;
    expect(shown.payload, zakatReminderNotificationPayload);
    expect(shown.title, l10n.zakatReminderNotificationTitle);
    expect(shown.body, isNot(contains(RegExp(r'\d'))));
  });

  test('posts once per completion, however many refreshes run', () async {
    await settings();
    await notifier().notifyIfDue(now: DateTime(2026, 6, 1, 9), l10n: l10n);
    await notifier().notifyIfDue(now: DateTime(2026, 6, 1, 18), l10n: l10n);
    await notifier().notifyIfDue(now: DateTime(2026, 6, 3), l10n: l10n);
    expect(notifications.shown, hasLength(1));
  });

  test('still posts a few days late (device was off), but not weeks late', () async {
    await settings();
    expect(await notifier().notifyIfDue(now: DateTime(2026, 6, 5), l10n: l10n), isTrue);

    SharedPreferences.setMockInitialValues({});
    preferences = await Preferences.create();
    notifications = _RecordingNotifications();
    await settings();
    expect(await notifier().notifyIfDue(now: DateTime(2026, 6, 20), l10n: l10n), isFalse);
    expect(notifications.shown, isEmpty);
  });

  test('posts again the following year', () async {
    await settings();
    await notifier().notifyIfDue(now: DateTime(2026, 6, 1), l10n: l10n);
    await notifier().notifyIfDue(now: DateTime(2027, 6, 1), l10n: l10n);
    expect(notifications.shown, hasLength(2));
  });

  test('nothing during the first year', () async {
    await settings();
    expect(await notifier().notifyIfDue(now: DateTime(2025, 12, 1), l10n: l10n), isFalse);
  });

  test('nothing when the reminder is off or no hawl is set', () async {
    await settings(remind: false);
    expect(await notifier().notifyIfDue(now: DateTime(2026, 6, 1), l10n: l10n), isFalse);
    await preferences.setZakatSettings(const ZakatSettings(remind: true));
    expect(await notifier().notifyIfDue(now: DateTime(2026, 6, 1), l10n: l10n), isFalse);
    expect(notifications.shown, isEmpty);
  });
}
