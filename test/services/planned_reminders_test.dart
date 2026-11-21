import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qima/l10n/app_localizations.dart';
import 'package:qima/models/money_settings.dart';
import 'package:qima/services/notification_service.dart';
import 'package:qima/services/planned_reminders.dart';
import 'package:qima/services/preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Tray extends NotificationService {
  final scheduled = <int, (DateTime, String)>{};
  final cancelled = <int>[];

  @override
  Future<void> scheduleAt({required int id, required DateTime at, required String title, required String body, required String payload}) async {
    scheduled[id] = (at, title);
  }

  @override
  Future<void> cancel(int id) async {
    cancelled.add(id);
    scheduled.remove(id);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  RecurringPayment plan(String id, DateTime start, {bool remind = true, bool incoming = false, PlanRepeat repeat = PlanRepeat.monthly, int paid = 0}) =>
      RecurringPayment(id: id, name: id, amount: 100, fromAccountId: 'a', categoryId: 'c', start: start, remind: remind, incoming: incoming, repeat: repeat, paid: paid);

  test('one reminder per open plan at 9:00 the day before, none when off, past or finished', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await Preferences.create();
    final tray = _Tray();
    final en = await AppLocalizations.delegate.load(const Locale('en'));
    final now = DateTime(2026, 11, 10, 12);
    await PlannedReminders(notifications: tray, preferences: prefs).sync([
      plan('Rent', DateTime(2026, 11, 27)),
      plan('Salary', DateTime(2026, 11, 26), incoming: true),
      plan('Gym', DateTime(2026, 11, 20), remind: false),
      plan('Today', DateTime(2026, 11, 10)),
      plan('Fees', DateTime(2026, 9, 1), repeat: PlanRepeat.once, paid: 1),
    ], en, now: now);
    expect(tray.scheduled.values.toSet(), {
      (DateTime(2026, 11, 26, 9), 'Rent is due tomorrow'),
      (DateTime(2026, 11, 25, 9), 'Salary is expected tomorrow'),
    });
    expect(prefs.plannedReminderIds.toSet(), tray.scheduled.keys.toSet());

    // Changing the plans withdraws what was scheduled before.
    final before = prefs.plannedReminderIds;
    await PlannedReminders(notifications: tray, preferences: prefs).sync([plan('Rent', DateTime(2026, 11, 27), paid: 1)], en, now: now);
    expect(tray.cancelled, containsAll(before));
    expect(tray.scheduled.values.single, (DateTime(2026, 12, 26, 9), 'Rent is due tomorrow'));
  });
}
