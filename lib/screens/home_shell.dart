import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/app_cubit.dart';
import '../l10n/app_localizations.dart';
import 'portfolio_detail_screen.dart';
import 'settings_screen.dart';
import 'watchlist_screen.dart';

/// The app's home: a Material 3 [NavigationBar] (or, on wide layouts, a
/// leading-edge [NavigationRail]) hosting the three chart-first v2-A tabs —
/// Watchlist, Portfolio, Settings — inside a single [IndexedStack] so scroll
/// position, the watchlist's asset-class filter, and the portfolio hero's
/// selected chart range all survive switching tabs (spec §v2-C "kept
/// alive").
///
/// Everything else in the app (instrument detail, holdings, the add flow,
/// alerts, backup, the lock screen) is pushed on the ROOT navigator
/// (`MaterialApp.navigatorKey` in `main.dart`) and covers this shell,
/// including its nav bar — `HomeShell` itself never owns those routes.
///
/// Owns the single price-refresh loop for the whole home experience (moved
/// here from `WatchlistScreen`, which only runs its own loop when used
/// standalone via [WatchlistScreen.manageRefreshLifecycle]) so refreshing
/// keeps happening while the Portfolio or Settings tab is showing, and so
/// there is never more than one periodic timer running at once.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

/// Width at/above which the shell switches from a bottom [NavigationBar] to
/// a leading-edge [NavigationRail] (Material 3 medium-window breakpoint —
/// tablet/desktop/web).
const double _kRailBreakpoint = 600;

class _HomeShellState extends State<HomeShell> with WidgetsBindingObserver {
  int _index = 0;
  Timer? _timer;

  final _watchlistScroll = ScrollController();
  final _portfolioScroll = ScrollController();
  final _settingsScroll = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _onForeground());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _watchlistScroll.dispose();
    _portfolioScroll.dispose();
    _settingsScroll.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _onForeground();
    } else {
      _timer?.cancel();
      _timer = null;
    }
  }

  void _onForeground() {
    final cubit = context.read<AppCubit>();
    cubit.refreshIfStale();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 60), (_) => cubit.refreshAll(silent: true));
  }

  ScrollController _controllerFor(int index) {
    switch (index) {
      case 0:
        return _watchlistScroll;
      case 1:
        return _portfolioScroll;
      default:
        return _settingsScroll;
    }
  }

  void _selectTab(int index) {
    if (index == _index) {
      // Tapping the already-selected tab scrolls it to top (spec §v2-C).
      final controller = _controllerFor(index);
      if (controller.hasClients) {
        controller.animateTo(0, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
      return;
    }
    setState(() => _index = index);
  }

  /// Android/predictive back: from Portfolio or Settings, go to Watchlist
  /// first; only exit the app from Watchlist itself (spec §v2-C).
  void _handleBack() {
    if (_index != 0) {
      setState(() => _index = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final destinations = [
      NavigationDestination(icon: const Icon(Icons.list_alt_outlined), selectedIcon: const Icon(Icons.list_alt), label: l10n.navWatchlist),
      NavigationDestination(icon: const Icon(Icons.pie_chart_outline), selectedIcon: const Icon(Icons.pie_chart), label: l10n.portfolioTitle),
      NavigationDestination(icon: const Icon(Icons.settings_outlined), selectedIcon: const Icon(Icons.settings), label: l10n.settingsTitle),
    ];

    final tabs = IndexedStack(
      index: _index,
      children: [
        WatchlistScreen(
          manageRefreshLifecycle: false,
          onOpenPortfolio: () => _selectTab(1),
          scrollController: _watchlistScroll,
        ),
        PortfolioDetailScreen(asTab: true, scrollController: _portfolioScroll),
        SettingsScreen(asTab: true, scrollController: _settingsScroll),
      ],
    );

    return PopScope(
      canPop: _index == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleBack();
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final useRail = constraints.maxWidth >= _kRailBreakpoint;
          if (!useRail) {
            return Scaffold(
              body: tabs,
              bottomNavigationBar: NavigationBar(
                selectedIndex: _index,
                onDestinationSelected: _selectTab,
                destinations: destinations,
              ),
            );
          }

          // NavigationRail as the first child of a Row always lands on the
          // reading-direction-leading edge: `Row` (via `Flex`) paints its
          // children according to the ambient `Directionality`, so this
          // flips to the right automatically under RTL without any extra
          // handling (spec §v2-C "RTL-aware").
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _index,
                  onDestinationSelected: _selectTab,
                  labelType: NavigationRailLabelType.all,
                  destinations: [
                    for (final d in destinations)
                      NavigationRailDestination(icon: d.icon, selectedIcon: d.selectedIcon, label: Text(d.label)),
                  ],
                ),
                const VerticalDivider(width: 1, thickness: 1),
                Expanded(child: tabs),
              ],
            ),
          );
        },
      ),
    );
  }
}
