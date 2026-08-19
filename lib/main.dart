import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'blocs/app_cubit.dart';
import 'blocs/app_state.dart';
import 'l10n/app_localizations.dart';
import 'screens/watch_watchlist_screen.dart';
import 'screens/watchlist_screen.dart';
import 'services/preferences.dart';
import 'theme/design_system.dart';

/// Wear OS screens are typically 192-227dp square/round; a normal phone's
/// shortest side is comfortably larger than this, so a simple threshold is
/// enough to distinguish a watch form factor without any Wear-specific
/// package or platform channel.
const double _kWatchShortestSideThreshold = 250;

bool isWatchFormFactor(BuildContext context) =>
    MediaQuery.of(context).size.shortestSide < _kWatchShortestSideThreshold;

void main() {
  runApp(const QimaApp());
}

class QimaApp extends StatelessWidget {
  const QimaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AppCubit>(
      create: (_) => AppCubit()..init(),
      child: BlocBuilder<AppCubit, AppState>(
        buildWhen: (previous, current) => previous.appLanguage != current.appLanguage,
        builder: (context, state) {
          return MaterialApp(
            onGenerateTitle: (context) => AppLocalizations.of(context)?.appTitle ?? 'Qima',
            debugShowCheckedModeBanner: false,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: state.appLanguage == AppLanguage.system
                ? null
                : Locale(state.appLanguage.localeIdentifier!),
            theme: ThemeData(
              brightness: Brightness.dark,
              scaffoldBackgroundColor: DS.bg0,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFFE6BA4D),
                brightness: Brightness.dark,
              ),
              appBarTheme: const AppBarTheme(
                elevation: 0,
                centerTitle: false,
                foregroundColor: DS.textPrimary,
              ),
              textTheme: ThemeData.dark().textTheme.apply(
                    bodyColor: DS.textPrimary,
                    displayColor: DS.textPrimary,
                  ),
              filledButtonTheme: FilledButtonThemeData(
                style: FilledButton.styleFrom(
                  backgroundColor: DS.textPrimary,
                  foregroundColor: DS.bg0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DS.radiusPill)),
                ),
              ),
            ),
            home: Builder(
              builder: (context) => isWatchFormFactor(context) ? const WatchWatchlistScreen() : const WatchlistScreen(),
            ),
          );
        },
      ),
    );
  }
}
