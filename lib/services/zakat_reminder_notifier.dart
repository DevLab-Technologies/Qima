import 'dart:ui';

import '../l10n/app_localizations.dart';
import '../models/zakat.dart';
import 'notification_service.dart';
import 'preferences.dart';

/// Notification payload for the hawl-completed reminder, routed to the
/// zakat screen by `main.dart`'s tap handler. A plain string can never
/// collide with the deterministic-UUID `WatchCard.id`s alert notifications
/// carry.
const String zakatReminderNotificationPayload = 'qima.zakatReminder';

/// Stable tray id, distinct from the hashed per-alert ids and the backup
/// reminder's.
const int zakatReminderNotificationId = 0x515A4B54; // 'QZKT'

/// Posts "your hawl completed" once per completion per device, from both
/// the foreground refresh and the background task — the same cadence the
/// backup reminder piggybacks on, so no scheduler of its own is needed.
///
/// The text names no amount: a lock-screen notification must not reveal
/// wealth, whatever the hide-balances setting says.
class ZakatReminderNotifier {
  /// A completion older than this is not announced: turning the reminder
  /// on, or opening the app after a long gap, shouldn't fire a notification
  /// for a hawl that ended weeks ago.
  static const Duration staleAfter = Duration(days: 7);

  final Preferences preferences;
  final NotificationService notificationService;

  const ZakatReminderNotifier({required this.preferences, required this.notificationService});

  Future<bool> notifyIfDue({DateTime? now, AppLocalizations? l10n}) async {
    final effectiveNow = now ?? DateTime.now();
    final settings = await preferences.zakatSettings;
    if (!settings.remind) return false;
    final completed = HawlSchedule.of(settings, effectiveNow)?.lastCompleted;
    if (completed == null) return false;
    final today = DateTime(effectiveNow.year, effectiveNow.month, effectiveNow.day);
    if (today.difference(completed) > staleAfter) return false;
    final already = preferences.zakatReminderNotifiedFor;
    if (already != null && !already.isBefore(completed)) return false;

    final strings = l10n ?? await AppLocalizations.delegate.load(PlatformDispatcher.instance.locale);
    await notificationService.show(
      id: zakatReminderNotificationId,
      title: strings.zakatReminderNotificationTitle,
      body: strings.zakatReminderNotificationBody,
      payload: zakatReminderNotificationPayload,
    );
    await preferences.setZakatReminderNotifiedFor(completed);
    return true;
  }
}
