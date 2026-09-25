import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';

import '../blocs/app_state.dart';
import 'widget_snapshot.dart';

/// Bridges [AppState] to the native home-screen widgets via the
/// `home_widget` plugin.
///
/// ## Data contract
///
/// All three platforms read the SAME [WidgetSnapshot] under
/// [WidgetSnapshot.storageKey]:
///
/// - **iOS** in the shared App Group ([appGroupID]) via `home_widget`;
/// - **macOS** in its team-prefixed App Group, written by the Mac runner's
///   own `WidgetBridgePlugin` (`home_widget` has no macOS implementation);
/// - **Android (Glance)** in `home_widget`'s own SharedPreferences file.
///
/// Every placed widget is configured on its own (asset, unit, karat,
/// currency, chart range for Price; currency, chart range for Portfolio),
/// so the snapshot carries raw canonical-USD series and FX data rather than
/// one precomputed answer, and each native side prices its own
/// configuration from it — see [WidgetSnapshot] for the exact rules, and
/// `ios/QimaWidget/Snapshot.swift` / `android/.../widget/Snapshot.kt` for
/// the two consumers (kept in lockstep by hand; there's no shared native
/// layer between the platforms).
class HomeWidgetService {
  HomeWidgetService._();

  /// Must match the App Group on the Runner and widget extension
  /// entitlements.
  static const appGroupID = 'group.com.devlabtechnologies.qima';

  /// Android Glance receiver class names, used by [HomeWidget.updateWidget]
  /// to target the right provider. iOS/macOS widgets are identified by
  /// their WidgetKit kind string instead (see `iOSName`).
  static const _androidPackage = 'com.devlabtechnologies.qima';
  static const _priceReceiverClass = '$_androidPackage.widget.PriceGlanceReceiver';
  static const _portfolioReceiverClass = '$_androidPackage.widget.PortfolioGlanceReceiver';

  /// iOS kinds, matching `kind` in the widget extension.
  static const iOSPriceKind = 'PriceWidget';
  static const iOSPortfolioKind = 'PortfolioWidget';
  static const iOSWatchlistKind = 'WatchlistWidget';

  /// Recomputes the widget snapshot from the latest [AppState], pushes it
  /// to native storage, then asks the OS to redraw any placed instances.
  /// Called from [AppCubit] after every successful refresh.
  ///
  /// Every step is best-effort: a widget write failing (e.g. the platform
  /// channel is unavailable in a unit test, or a platform simply doesn't
  /// support home_widget) must never surface as an app-visible error, since
  /// this is a background side effect of an otherwise-successful refresh.
  static Future<void> publish(AppState state) async {
    if (kIsWeb) return;
    switch (defaultTargetPlatform) {
      case TargetPlatform.macOS:
        // home_widget has no macOS implementation; the Mac runner's own
        // bridge writes the snapshot for the macOS widget extension.
        try {
          await _macBridge.invokeMethod<void>('saveSnapshot', {
            'key': WidgetSnapshot.storageKey,
            'json': jsonEncode(WidgetSnapshot.build(state, now: DateTime.now())),
          });
        } catch (e, st) {
          debugPrint('HomeWidgetService: macOS widget snapshot publish failed: $e\n$st');
        }
        return;
      case TargetPlatform.iOS:
      case TargetPlatform.android:
        break;
      default:
        return; // No widgets on this platform.
    }
    try {
      // Idempotent; set on every publish because background refreshes run
      // in a fresh isolate that never went through app start-up.
      await HomeWidget.setAppGroupId(appGroupID);
      await HomeWidget.saveWidgetData<String>(
        WidgetSnapshot.storageKey,
        jsonEncode(WidgetSnapshot.build(state, now: DateTime.now())),
      );
    } catch (e, st) {
      debugPrint('HomeWidgetService: widget snapshot publish failed: $e\n$st');
    }
    try {
      await _reload();
    } catch (e, st) {
      debugPrint('HomeWidgetService: widget reload failed: $e\n$st');
    }
  }

  /// `WidgetBridgePlugin` in the macOS runner.
  static const _macBridge = MethodChannel('com.devlabtechnologies.qima/widgets');

  /// Asks the OS to redraw every placed widget instance on this platform.
  /// iOS reloads by WidgetKit kind (one call covers every configured
  /// instance of that kind); Android reloads by Glance receiver, which
  /// re-invokes `provideGlance` for every placed `appWidgetId` and lets
  /// each one re-resolve its own configuration against the fresh snapshot.
  static Future<void> _reload() async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await HomeWidget.updateWidget(iOSName: iOSWatchlistKind);
    }
    await HomeWidget.updateWidget(
      name: 'PriceGlanceReceiver',
      androidName: _priceReceiverClass,
      qualifiedAndroidName: _priceReceiverClass,
      iOSName: iOSPriceKind,
    );
    await HomeWidget.updateWidget(
      name: 'PortfolioGlanceReceiver',
      androidName: _portfolioReceiverClass,
      qualifiedAndroidName: _portfolioReceiverClass,
      iOSName: iOSPortfolioKind,
    );
  }
}
