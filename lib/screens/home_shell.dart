import 'dart:async';
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/app_cubit.dart';
import '../blocs/import_cubit.dart';
import '../blocs/money_cubit.dart';
import '../l10n/app_localizations.dart';
import '../theme/design_system.dart';
import '../theme/qima_colors.dart';
import '../widgets/add_sheet.dart';
import 'money/home_screen.dart';
import 'money/money_screen.dart';
import 'settings_screen.dart';
import 'watchlist_screen.dart';

/// The app's home (v5): three tabs, Home, Money and Prices, kept alive in
/// one [IndexedStack] so scroll positions and filters survive switching.
/// Settings is the gear in Home's header on a phone, and the foot of the
/// rail from 600 points wide. The + opens the Add sheet.
///
/// Everything else is pushed on the ROOT navigator and covers this shell,
/// including its bar.
///
/// Owns the single price-refresh loop for the whole home experience, so
/// prices keep refreshing while Home or Money is showing and there is never
/// more than one periodic timer.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

/// Width at/above which the shell switches from the floating tab bar to a
/// leading-edge [NavigationRail].
const double _kRailBreakpoint = 600;

class _HomeShellState extends State<HomeShell> with WidgetsBindingObserver {
  int _index = 0;
  Timer? _timer;
  bool _whatsNewShown = false;

  final _homeScroll = ScrollController();
  final _moneyScroll = ScrollController();
  final _pricesScroll = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onForeground();
      _maybeShowWhatsNew(context.read<MoneyCubit>().state);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _homeScroll.dispose();
    _moneyScroll.dispose();
    _pricesScroll.dispose();
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
    // Anything shared to Qima while it was in the background.
    unawaited(maybeImportCubit(context)?.checkInbox());
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 60), (_) => cubit.refreshAll(silent: true));
  }

  /// O.3, once: after the update (or the first run), what changed and which
  /// parts of Money to use.
  void _maybeShowWhatsNew(MoneyState money) {
    if (_whatsNewShown || !money.loaded || money.settings.seenWhatsNew || !mounted) return;
    _whatsNewShown = true;
    showWhatsNew(context);
  }

  ScrollController _controllerFor(int index) => switch (index) {
        0 => _homeScroll,
        1 => _moneyScroll,
        _ => _pricesScroll,
      };

  void _selectTab(int index) {
    if (index == _index) {
      // Tapping the selected tab scrolls it to the top.
      final controller = _controllerFor(index);
      if (controller.hasClients) {
        controller.animateTo(0, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
      return;
    }
    setState(() => _index = index);
  }

  void _openSettings() {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const SettingsScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final destinations = [
      NavigationDestination(icon: const Icon(Icons.home_outlined), selectedIcon: const Icon(Icons.home), label: l10n.navHome),
      NavigationDestination(icon: const Icon(Icons.account_balance_wallet_outlined), selectedIcon: const Icon(Icons.account_balance_wallet), label: l10n.navMoney),
      NavigationDestination(icon: const Icon(Icons.show_chart_outlined), selectedIcon: const Icon(Icons.show_chart), label: l10n.navPrices),
    ];

    // [phone]: Settings opens from Home's header instead of the rail.
    Widget tabs({required bool phone}) => IndexedStack(
          index: _index,
          children: [
            HomeScreen(scrollController: _homeScroll, onOpenSettings: phone ? _openSettings : null),
            MoneyScreen(scrollController: _moneyScroll),
            WatchlistScreen(manageRefreshLifecycle: false, asPrices: true, scrollController: _pricesScroll),
          ],
        );

    return BlocListener<MoneyCubit, MoneyState>(
      listenWhen: (a, b) => a.loaded != b.loaded,
      listener: (context, money) => _maybeShowWhatsNew(money),
      child: PopScope(
        canPop: _index == 0,
        onPopInvokedWithResult: (didPop, _) {
          // Android back from Money or Prices goes to Home first.
          if (!didPop) setState(() => _index = 0);
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            final useRail = constraints.maxWidth >= _kRailBreakpoint;
            if (!useRail) {
              return Scaffold(
                extendBody: true,
                body: tabs(phone: true),
                floatingActionButton: const AddButton(),
                floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
                bottomNavigationBar: _FloatingTabBar(destinations: destinations, selectedIndex: _index, onSelected: _selectTab),
              );
            }

            // The rail lands on the reading-direction-leading edge, so it
            // flips to the right under RTL with no extra handling.
            return Scaffold(
              body: Row(
                children: [
                  NavigationRail(
                    selectedIndex: _index,
                    onDestinationSelected: _selectTab,
                    labelType: NavigationRailLabelType.all,
                    leading: const Padding(padding: EdgeInsets.only(bottom: 8), child: AddButton()),
                    trailing: Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: IconButton(icon: const Icon(Icons.settings_outlined), tooltip: l10n.settingsTitle, onPressed: _openSettings),
                        ),
                      ),
                    ),
                    destinations: [
                      for (final d in destinations) NavigationRailDestination(icon: d.icon, selectedIcon: d.selectedIcon, label: Text(d.label)),
                    ],
                  ),
                  const VerticalDivider(width: 1, thickness: 1),
                  Expanded(child: tabs(phone: false)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// The phone tab bar: a rounded bar inset 16 points from the sides and
/// lifted above the home indicator, translucent with a blur, the current
/// tab marked by a tinted pill. Lists scroll under it.
class _FloatingTabBar extends StatelessWidget {
  final List<NavigationDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _FloatingTabBar({required this.destinations, required this.selectedIndex, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final theme = NavigationBarTheme.of(context);
    final colors = context.colors;
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(DS.radiusPill),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: (theme.backgroundColor ?? colors.surfaceTop).withValues(alpha: 0.82),
              borderRadius: BorderRadius.circular(DS.radiusPill),
              border: Border.all(color: colors.hairline),
            ),
            padding: const EdgeInsets.all(6),
            child: Row(
              children: [
                for (final (i, d) in destinations.indexed)
                  Expanded(
                    child: Semantics(
                      button: true,
                      selected: i == selectedIndex,
                      label: d.label,
                      excludeSemantics: true,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(DS.radiusPill),
                        onTap: () => onSelected(i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          decoration: BoxDecoration(
                            color: i == selectedIndex ? colors.brand.withValues(alpha: 0.16) : Colors.transparent,
                            borderRadius: BorderRadius.circular(DS.radiusPill),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconTheme(
                                data: theme.iconTheme?.resolve({if (i == selectedIndex) WidgetState.selected}) ?? const IconThemeData(),
                                child: i == selectedIndex ? (d.selectedIcon ?? d.icon) : d.icon,
                              ),
                              const SizedBox(height: 2),
                              Text(d.label, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.labelTextStyle?.resolve({if (i == selectedIndex) WidgetState.selected})),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
