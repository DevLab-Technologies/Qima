import '../l10n/app_localizations.dart';
import '../models/money_settings.dart';
import 'notification_service.dart';
import 'preferences.dart';

/// Notification payload for a planned payment reminder, routed to Planned
/// payments by `main.dart`'s tap handler.
const String plannedReminderPayload = 'qima.planned';

/// Schedules one reminder per open planned payment, at 9:00 the day before
/// its next due date, on the device itself so it arrives even when Qima
/// isn't running. Run again whenever the plans change: what was scheduled
/// before is withdrawn first.
///
/// The text names no amount: a lock-screen notification must not reveal
/// money, whatever the hide-balances setting says.
class PlannedReminders {
  static const int _idBase = 0x50000000;

  final NotificationService notifications;
  final Preferences preferences;

  const PlannedReminders({required this.notifications, required this.preferences});

  /// A stable notification id for [planId], apart from the alert,
  /// backup and zakat ids.
  static int idFor(String planId) => _idBase | (planId.hashCode & 0x0FFFFFFF);

  /// When [plan]'s reminder is due, or null when it gets none.
  static DateTime? remindAt(RecurringPayment plan, DateTime now) {
    final next = plan.next;
    if (!plan.remind || next == null) return null;
    final at = DateTime(next.year, next.month, next.day - 1, 9);
    return at.isAfter(now) ? at : null;
  }

  Future<void> sync(List<RecurringPayment> plans, AppLocalizations l10n, {DateTime? now}) async {
    final when = now ?? DateTime.now();
    for (final id in preferences.plannedReminderIds) {
      await notifications.cancel(id);
    }
    final scheduled = <int>[];
    for (final p in plans) {
      final at = remindAt(p, when);
      if (at == null) continue;
      final id = idFor(p.id);
      await notifications.scheduleAt(
        id: id,
        at: at,
        title: p.incoming ? l10n.planExpectedTomorrow(p.name) : l10n.planDueTomorrow(p.name),
        body: l10n.planReminderBody,
        payload: plannedReminderPayload,
      );
      scheduled.add(id);
    }
    await preferences.setPlannedReminderIds(scheduled);
  }
}
