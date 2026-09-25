import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'blocs/app_cubit.dart';
import 'blocs/app_state.dart';
import 'l10n/app_localizations.dart';
import 'models/watch_card.dart';
import 'screens/backup_screen.dart';
import 'screens/home_shell.dart';
import 'screens/instrument_detail_screen.dart';
import 'screens/watch_watchlist_screen.dart';
import 'services/backup/backup_reminder_notifier.dart';
import 'services/notification_service.dart';
import 'services/preferences.dart';
import 'theme/app_theme.dart';
import 'widgets/lock_gate.dart';

/// Wear OS screens are typically 192-227dp square/round; a normal phone's
/// shortest side is comfortably larger than this, so a simple threshold is
/// enough to distinguish a watch form factor without any Wear-specific
/// package or platform channel.
const double _kWatchShortestSideThreshold = 250;

bool isWatchFormFactor(BuildContext context) =>
    MediaQuery.of(context).size.shortestSide < _kWatchShortestSideThreshold;

void main() {
  // `cryptography_flutter`'s plugin auto-registers with `package:cryptography`
  // (used by the Phase 6 backup encryption) as soon as it's a dependency —
  // no explicit enable call needed — routing AES-GCM/PBKDF2 through native OS
  // APIs on Android/iOS/macOS, which are dramatically faster than the
  // pure-Dart fallback. See `BackupCrypto`/`backup_crypto.dart`.
  LicenseRegistry.addLicense(_bundledFontLicenses);
  runApp(const QimaApp());
}

/// Surfaces the bundled fonts' licenses on the system licenses page, as the
/// SIL OFL requires the license to travel with the font.
Stream<LicenseEntry> _bundledFontLicenses() async* {
  yield LicenseEntryWithLineBreaks(
    const ['Almarai'],
    await rootBundle.loadString('assets/fonts/almarai/OFL.txt'),
  );
  yield LicenseEntryWithLineBreaks(
    const ['Riyal'],
    await rootBundle.loadString('assets/fonts/riyal/LICENSE'),
  );
}

class QimaApp extends StatefulWidget {
  const QimaApp({super.key});

  @override
  State<QimaApp> createState() => _QimaAppState();
}

class _QimaAppState extends State<QimaApp> {
  /// Lets notification-tap navigation reach the `Navigator` without a
  /// `BuildContext` from inside the tap-payload stream listener (spec Phase
  /// 5 "notification-tap navigation"). Pushing through this key still lands
  /// inside `MaterialApp`'s navigator, so `LockGate` — which wraps
  /// `builder`'s output ABOVE this navigator — still visually gates the
  /// pushed screen behind the lock screen/privacy cover until unlocked; nothing
  /// here bypasses it.
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  late final AppCubit _cubit;
  StreamSubscription<String>? _tapSubscription;

  @override
  void initState() {
    super.initState();
    _cubit = AppCubit();
    _tapSubscription = notificationTapPayloads.stream.listen(_handleNotificationTap);
    _cubit.init().then((_) => _consumeColdLaunchPayload());
  }

  @override
  void dispose() {
    _tapSubscription?.cancel();
    unawaited(_cubit.disposeCloudSync());
    super.dispose();
  }

  Future<void> _consumeColdLaunchPayload() async {
    final payload = await _cubit.notificationService.consumeLaunchPayload();
    if (payload != null) _handleNotificationTap(payload);
  }

  /// [payload] is either a `WatchCard.id` (a price alert notification, set
  /// in `RefreshPipeline._notify`) or [backupReminderNotificationPayload]
  /// (the Phase 6 backup-reminder notification, set in
  /// `BackupReminderNotifier`). Waits for the cubit to finish initializing
  /// (a cold start's tap can arrive before `init()` has loaded the
  /// watchlist) and silently does nothing if a referenced card was since
  /// removed.
  void _handleNotificationTap(String payload) {
    unawaited(() async {
      while (!_cubit.state.initialized) {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      }
      final navigator = _navigatorKey.currentState;
      if (navigator == null) return;

      if (payload == backupReminderNotificationPayload) {
        navigator.push(MaterialPageRoute(builder: (_) => const BackupScreen()));
        return;
      }

      WatchCard? card;
      for (final c in _cubit.state.cards) {
        if (c.id == payload) {
          card = c;
          break;
        }
      }
      if (card == null) return;
      navigator.push(MaterialPageRoute(builder: (_) => InstrumentDetailScreen(card: card!)));
    }());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AppCubit>.value(
      value: _cubit,
      child: BlocBuilder<AppCubit, AppState>(
        buildWhen: (previous, current) =>
            previous.appLanguage != current.appLanguage || previous.appearance != current.appearance,
        builder: (context, state) {
          return MaterialApp(
            navigatorKey: _navigatorKey,
            onGenerateTitle: (context) => AppLocalizations.of(context)?.appTitle ?? 'Qima',
            debugShowCheckedModeBanner: false,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: state.appLanguage == AppLanguage.system
                ? null
                : Locale(state.appLanguage.localeIdentifier!),
            theme: buildTheme(Brightness.light),
            darkTheme: buildTheme(Brightness.dark),
            themeMode: state.appearance.themeMode,
            // The theme depends on the resolved locale for its font (see
            // `buildTheme`), which is only known here.
            builder: (context, child) {
              final content = Theme(
                data: buildTheme(Theme.of(context).brightness, locale: Localizations.localeOf(context)),
                child: child!,
              );
              // LockGate sits above the app's screens but below the root
              // ScaffoldMessenger/Navigator that `MaterialApp` itself
              // supplies around `builder`'s output, so in-app snackbars
              // triggered right after unlocking still surface normally.
              return LockGate(child: content);
            },
            home: Builder(
              builder: (context) => isWatchFormFactor(context) ? const WatchWatchlistScreen() : const HomeShell(),
            ),
          );
        },
      ),
    );
  }
}
