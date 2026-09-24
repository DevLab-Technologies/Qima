import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'blocs/app_cubit.dart';
import 'blocs/app_state.dart';
import 'l10n/app_localizations.dart';
import 'screens/watch_watchlist_screen.dart';
import 'screens/watchlist_screen.dart';
import 'services/preferences.dart';
import 'theme/app_theme.dart';
import 'theme/design_system.dart';

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

class QimaApp extends StatelessWidget {
  const QimaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AppCubit>(
      create: (_) => AppCubit()..init(),
      child: BlocBuilder<AppCubit, AppState>(
        buildWhen: (previous, current) =>
            previous.appLanguage != current.appLanguage || previous.appearance != current.appearance,
        builder: (context, state) {
          return MaterialApp(
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
              if (Localizations.localeOf(context).languageCode != 'ar') return child!;
              final theme = Theme.of(context);
              return Theme(
                data: theme.copyWith(
                  textTheme: theme.textTheme.apply(fontFamily: DS.arabicFontFamily),
                  primaryTextTheme: theme.primaryTextTheme.apply(fontFamily: DS.arabicFontFamily),
                ),
                child: child!,
              );
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
