import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'blocs/app_cubit.dart';
import 'blocs/app_state.dart';
import 'l10n/app_localizations.dart';
import 'models/watch_card.dart';
import 'screens/instrument_detail_screen.dart';
import 'screens/watch_watchlist_screen.dart';
import 'screens/watchlist_screen.dart';
import 'services/notification_service.dart';
import 'services/preferences.dart';
import 'theme/app_theme.dart';
import 'theme/design_system.dart';
import 'widgets/lock_gate.dart';

/// Wear OS screens are typically 192-227dp square/round; a normal phone's
/// shortest side is comfortably larger than this, so a simple threshold is
/// enough to distinguish a watch form factor without any Wear-specific
/// package or platform channel.
const double _kWatchShortestSideThreshold = 250;

bool isWatchFormFactor(BuildContext context) =>
    MediaQuery.of(context).size.shortestSide < _kWatchShortestSideThreshold;

void main() {
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
    super.dispose();
  }

  Future<void> _consumeColdLaunchPayload() async {
    final payload = await _cubit.notificationService.consumeLaunchPayload();
    if (payload != null) _handleNotificationTap(payload);
  }

  /// [cardID] is a `WatchCard.id` (the notification payload set in
  /// `RefreshPipeline._notify`). Waits for the cubit to finish initializing
  /// (a cold start's tap can arrive before `init()` has loaded the
  /// watchlist) and silently does nothing if the card was since removed.
  void _handleNotificationTap(String cardID) {
    unawaited(() async {
      while (!_cubit.state.initialized) {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      }
      WatchCard? card;
      for (final c in _cubit.state.cards) {
        if (c.id == cardID) {
          card = c;
          break;
        }
      }
      if (card == null) return;
      final navigator = _navigatorKey.currentState;
      if (navigator == null) return;
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
            // Arabic is set entirely in the Arabic family; other locales keep
            // the platform font and reach it only through the fallback chain.
            builder: (context, child) {
              Widget content = child!;
              if (Localizations.localeOf(context).languageCode == 'ar') {
                final theme = Theme.of(context);
                content = Theme(
                  data: theme.copyWith(
                    textTheme: theme.textTheme.apply(fontFamily: DS.arabicFontFamily),
                    primaryTextTheme: theme.primaryTextTheme.apply(fontFamily: DS.arabicFontFamily),
                  ),
                  child: content,
                );
              }
              // LockGate sits above the app's screens but below the root
              // ScaffoldMessenger/Navigator that `MaterialApp` itself
              // supplies around `builder`'s output, so in-app snackbars
              // triggered right after unlocking still surface normally.
              return LockGate(child: content);
            },
            home: Builder(
              builder: (context) => isWatchFormFactor(context) ? const WatchWatchlistScreen() : const WatchlistScreen(),
            ),
          );
        },
      ),
    );
  }
}
