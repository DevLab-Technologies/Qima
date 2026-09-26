import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';

import 'alert_runtime_store.dart';
import 'alerts_store.dart';
import 'custom_instrument_store.dart';
import 'holdings_store.dart';
import 'notification_service.dart';
import 'preferences.dart';
import 'price_repository.dart';
import 'refresh_pipeline.dart';
import 'watchlist_store.dart';

/// Periodic background price refresh + alert evaluation (spec Phase 5),
/// built on `workmanager`:
///
/// - **Android**: a real periodic `WorkManager` job, minimum 15 minutes
///   (the OS floor — `WidgetRefreshInterval.fifteenMinutes` maps to it
///   exactly; longer settings register at their real interval). Runs even
///   if the app is fully closed. This is where `WidgetRefreshInterval`
///   finally does something — until this phase it was stored and shown in
///   Settings but nothing read it.
/// - **iOS**: `BGTaskScheduler` (`BGAppRefreshTask`), registered with the
///   identifier declared in Info.plist. iOS decides the actual cadence
///   based on usage patterns and never guarantees the requested interval —
///   this is opportunistic best-effort background refresh, not a reliable
///   timer. See `_iosSetup` below and the top-level report for why the
///   launch-handler registration needed an explicit `AppDelegate` call
///   rather than relying on the plugin's default auto-registration.
/// - **macOS/desktop/web**: no background task is registered at all
///   (`workmanager`'s macOS backend only runs while the app process is
///   alive via `NSBackgroundActivityScheduler`, and there's no equivalent
///   on Windows/Linux/Web) — those platforms evaluate alerts only while
///   the app is actually open and refreshing, via `AppCubit.refreshAll`.
class BackgroundRefresh {
  BackgroundRefresh._();

  static const String uniqueName = 'com.devlabtechnologies.qima.refresh';
  static const String taskName = 'priceRefresh';
  static bool _initialized = false;

  static bool get _supportsBackgroundTask {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS;
  }

  /// Initializes the `workmanager` plugin (idempotent) and (re-)registers
  /// the periodic task at [interval]. Safe to call repeatedly — e.g. every
  /// time the user changes the widget refresh interval in Settings, since
  /// `registerPeriodicTask` replaces any existing registration under the
  /// same [uniqueName] rather than stacking duplicates.
  static Future<void> register({required Duration interval}) async {
    if (!_supportsBackgroundTask) return;
    try {
      if (!_initialized) {
        await Workmanager().initialize(callbackDispatcher);
        _initialized = true;
      }
      // WorkManager enforces a 15-minute floor itself, but registering with
      // the app's own already-floored value keeps the two settings sources
      // (this call and the AppDelegate-registered BGTaskScheduler
      // identifier's implicit cadence hint) consistent.
      final floored = interval < const Duration(minutes: 15) ? const Duration(minutes: 15) : interval;
      await Workmanager().registerPeriodicTask(
        uniqueName,
        taskName,
        frequency: floored,
        existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
        constraints: Constraints(networkType: NetworkType.connected),
      );
    } catch (e, st) {
      // Registration failing (permissions revoked, an unsupported OS
      // version, a simulator quirk) must never block app startup or a
      // settings change — background refresh is a bonus on top of the
      // foreground timer, not a requirement.
      debugPrint('BackgroundRefresh: register failed: $e\n$st');
    }
  }

  static Future<void> cancel() async {
    if (!_supportsBackgroundTask) return;
    try {
      await Workmanager().cancelByUniqueName(uniqueName);
    } catch (e, st) {
      debugPrint('BackgroundRefresh: cancel failed: $e\n$st');
    }
  }
}

/// Top-level background isolate entry point. Must stay top-level (not a
/// class member/closure) and keep the `@pragma('vm:entry-point')` so the
/// AOT compiler doesn't tree-shake it — this is the function the OS's
/// background dispatcher looks up by name.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // A background isolate starts with NO bindings, NO plugin registrations
    // and none of the app's usual `main()` setup — everything the refresh
    // needs (Flutter binding, the repository, every store, notifications)
    // is constructed fresh, right here, rather than reusing anything from
    // the foreground app (which isn't running in this process/isolate at
    // all).
    WidgetsFlutterBinding.ensureInitialized();
    try {
      final preferences = await Preferences.create();
      final notificationService = NotificationService();
      await notificationService.init();

      final pipeline = RefreshPipeline(
        repository: PriceRepository(),
        watchlistStore: WatchlistStore(),
        holdingsStore: HoldingsStore(),
        customInstrumentStore: CustomInstrumentStore(),
        alertsStore: AlertsStore(),
        alertRuntimeStore: AlertRuntimeStore(),
        notificationService: notificationService,
        preferences: preferences,
      );

      await pipeline.run(isForeground: false);
      return true;
    } catch (e, st) {
      debugPrint('BackgroundRefresh: task failed: $e\n$st');
      // Returning false tells WorkManager to retry per its backoff policy;
      // iOS ignores the return value (see `BackgroundTaskHandler` docs).
      return false;
    }
  });
}
