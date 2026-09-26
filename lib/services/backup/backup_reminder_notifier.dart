import 'dart:ui';

import '../../l10n/app_localizations.dart';
import '../notification_service.dart';
import 'backup_service.dart';

/// Notification payload used for the Phase 6 backup-reminder notification —
/// distinct from every `WatchCard.id` payload a price-alert notification
/// uses, so `main.dart`'s tap handler can tell them apart and route to
/// [BackupScreen] instead of an instrument detail screen. `WatchCard.id`s
/// are deterministic UUIDs (see `deterministic_uuid.dart`), which never
/// collide with this plain string.
const String backupReminderNotificationPayload = 'qima.backupReminder';

/// A stable notification id for the backup reminder — distinct from
/// `notificationIdFor(alertId)`'s hashed range (spec Phase 5) so the two
/// notification kinds never collide in the tray.
const int backupReminderNotificationId = 0x51424B50; // 'QBKP' in ASCII hex, masked positive by construction.

/// Posts the "time for a backup" notification at most once per 30 days,
/// from BOTH the foreground refresh path and the background task (spec
/// Phase 6: "have the background task post one notification at most once
/// per 30 days"). Called from the same place `RefreshPipeline` already
/// runs — see `AppCubit._evaluateAlertsAfterRefresh` and
/// `RefreshPipeline.run` — so it piggybacks on the existing refresh cadence
/// rather than needing its own scheduler.
class BackupReminderNotifier {
  final BackupService backupService;
  final NotificationService notificationService;

  const BackupReminderNotifier({required this.backupService, required this.notificationService});

  Future<void> notifyIfDue({DateTime? now, AppLocalizations? l10n}) async {
    final effectiveNow = now ?? DateTime.now();
    if (!backupService.shouldNotifyReminder(now: effectiveNow)) return;

    final strings = l10n ?? await AppLocalizations.delegate.load(PlatformDispatcher.instance.locale);
    await notificationService.show(
      id: backupReminderNotificationId,
      title: strings.backupReminderNotificationTitle,
      body: strings.backupReminderNotificationBody,
      payload: backupReminderNotificationPayload,
    );
    await backupService.setReminderNotifiedAt(effectiveNow);
  }
}
