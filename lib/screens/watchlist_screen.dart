import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/app_cubit.dart';
import '../blocs/app_state.dart';
import '../l10n/app_localizations.dart';
import '../theme/design_system.dart';
import '../widgets/instrument_row.dart';
import 'add_instrument_screen.dart';
import 'instrument_detail_screen.dart';
import 'portfolio_detail_screen.dart';
import 'settings_screen.dart';

/// Root watchlist screen. Mirrors `ContentView.swift`: auto-refresh loop
/// keyed to app lifecycle, empty state, portfolio banner, reorderable /
/// dismissible instrument list.
class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> with WidgetsBindingObserver {
  Timer? _timer;

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

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AppCubit>();
    final l10n = AppLocalizations.of(context)!;

    return ScreenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(l10n.appTitle),
          actions: [
            BlocBuilder<AppCubit, AppState>(
              builder: (context, state) {
                return IconButton(
                  icon: state.phase == RefreshPhase.refreshing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                  onPressed: () => cubit.refreshAll(),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddInstrumentScreen()),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              ),
            ),
          ],
        ),
        body: BlocBuilder<AppCubit, AppState>(
          builder: (context, state) {
            if (!state.initialized) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.cards.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(DS.spaceLG),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_border, color: DS.textTertiary, size: 48),
                      const SizedBox(height: DS.spaceMD),
                      Text(
                        l10n.watchlistEmptyTitle,
                        style: const TextStyle(color: DS.textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: DS.spaceXS),
                      Text(
                        l10n.watchlistEmptyMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: DS.textTertiary),
                      ),
                      const SizedBox(height: DS.spaceLG),
                      FilledButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const AddInstrumentScreen()),
                        ),
                        child: Text(l10n.watchlistAdd),
                      ),
                    ],
                  ),
                ),
              );
            }

            final valuation = cubit.portfolioValuation;

            return ReorderableListView.builder(
              padding: const EdgeInsets.all(DS.spaceMD),
              // The default desktop drag handle (a small `Icons.drag_handle`
              // icon Flutter stacks over the trailing edge of every row) has
              // no room reserved for it in `InstrumentRow`'s layout, so it
              // paints directly on top of the price text on macOS/Windows/
              // Linux. We disable it and fall back to the same long-press-
              // anywhere-on-the-row gesture Flutter uses by default on
              // mobile, which needs no dedicated on-row affordance.
              buildDefaultDragHandles: false,
              itemCount: state.cards.length + (valuation != null ? 1 : 0),
              onReorder: (oldIndex, newIndex) {
                if (valuation != null) {
                  if (oldIndex == 0 || newIndex == 0) return;
                  oldIndex -= 1;
                  newIndex -= 1;
                }
                cubit.move(oldIndex, newIndex);
              },
              itemBuilder: (context, index) {
                if (valuation != null && index == 0) {
                  return Padding(
                    key: const ValueKey('portfolio-summary'),
                    padding: const EdgeInsets.only(bottom: DS.spaceMD),
                    child: InkWell(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const PortfolioDetailScreen()),
                      ),
                      child: DSHeroCard(
                        accent: DS.trendColor(valuation.isUp),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(l10n.portfolioTitle, style: const TextStyle(color: DS.textTertiary, fontSize: 12)),
                                  Text(
                                    valuation.value.formatted(),
                                    style: const TextStyle(color: DS.textPrimary, fontSize: 26, fontWeight: FontWeight.w800),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${valuation.isUp ? '+' : ''}${(valuation.gainFraction * 100).toStringAsFixed(2)}%',
                              style: TextStyle(color: DS.trendColor(valuation.isUp), fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                final cardIndex = valuation != null ? index - 1 : index;
                final card = state.cards[cardIndex];
                final presentation = cubit.presentation(card);

                return ReorderableDelayedDragStartListener(
                  key: ValueKey(card.id),
                  index: index,
                  child: Dismissible(
                    key: ValueKey('dismissible-${card.id}'),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) => cubit.removeCard(card.id),
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: DS.spaceMD),
                      child: const Icon(Icons.delete, color: DS.down),
                    ),
                    child: InstrumentRow(
                      presentation: presentation,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => InstrumentDetailScreen(card: card)),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
