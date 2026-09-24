import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/app_cubit.dart';
import '../blocs/app_state.dart';
import '../l10n/app_localizations.dart';
import '../models/asset.dart';
import '../models/watch_card.dart';
import '../theme/design_system.dart';
import '../theme/qima_colors.dart';
import '../theme/strings.dart';
import '../widgets/asset_class_filter.dart';
import '../widgets/confirm_delete_dialog.dart';
import '../widgets/instrument_row.dart';
import '../widgets/portfolio_hero.dart';
import 'add_instrument_screen.dart';
import 'instrument_detail_screen.dart';
import 'portfolio_detail_screen.dart';

/// Root watchlist screen. Mirrors `ContentView.swift`: auto-refresh loop
/// keyed to app lifecycle, empty state, portfolio hero chart, an
/// asset-class filter, and a reorderable/dismissible instrument list (v2-A
/// "Chart-first" layout).
///
/// Used two ways (spec §v2-C): standalone as a pushed/root route (its own
/// price-refresh loop, tapping the hero pushes [PortfolioDetailScreen]), or
/// hosted as the Watchlist tab of `HomeShell`, which owns the refresh loop
/// itself (so the two never race with duplicate timers) and passes
/// [manageRefreshLifecycle]: false plus [onOpenPortfolio] to switch tabs
/// instead of pushing.
class WatchlistScreen extends StatefulWidget {
  final bool manageRefreshLifecycle;
  final VoidCallback? onOpenPortfolio;
  final ScrollController? scrollController;

  const WatchlistScreen({
    super.key,
    this.manageRefreshLifecycle = true,
    this.onOpenPortfolio,
    this.scrollController,
  });

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> with WidgetsBindingObserver {
  Timer? _timer;
  AssetClass? _filter;

  @override
  void initState() {
    super.initState();
    if (widget.manageRefreshLifecycle) {
      WidgetsBinding.instance.addObserver(this);
      WidgetsBinding.instance.addPostFrameCallback((_) => _onForeground());
    }
  }

  @override
  void dispose() {
    if (widget.manageRefreshLifecycle) {
      WidgetsBinding.instance.removeObserver(this);
    }
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
    final colors = context.colors;

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
                      Icon(Icons.star_border, color: colors.textTertiary, size: 48),
                      const SizedBox(height: DS.spaceMD),
                      Text(
                        l10n.watchlistEmptyTitle,
                        style: TextStyle(color: colors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: DS.spaceXS),
                      Text(
                        l10n.watchlistEmptyMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: colors.textTertiary),
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

            // Only classes actually present in the watchlist get a filter
            // chip; a class with zero cards never shows an empty chip.
            final availableClasses = <AssetClass>{
              for (final card in state.cards)
                if (card.instrument != null) card.instrument!.assetClass,
            };
            if (_filter != null && !availableClasses.contains(_filter)) {
              // The only tracked instrument of the selected class was
              // removed from underneath the filter (e.g. via swipe-delete):
              // fall back to "All" next frame rather than showing an empty
              // list with no way to tell why (can't call setState mid-build).
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) setState(() => _filter = null);
              });
            }

            final filteredCards = _filter == null
                ? state.cards
                : state.cards.where((c) => c.instrument?.assetClass == _filter).toList();

            // Reordering only makes sense (and only mutates the real
            // underlying order) when every card is visible, i.e. filter is
            // "All" — otherwise a drag would silently reorder within a
            // filtered subset while writing indices back into the full list.
            final canReorder = _filter == null;

            return ListView(
              controller: widget.scrollController,
              padding: const EdgeInsets.all(DS.spaceMD),
              children: [
                if (valuation != null) ...[
                  PortfolioHero(
                    valuation: valuation,
                    history: cubit.portfolioHistory(state.preferredPortfolioRange),
                    change: cubit.portfolioChange(state.preferredPortfolioRange),
                    selectedRange: state.preferredPortfolioRange,
                    onSelectRange: cubit.setPreferredPortfolioRange,
                    onTap: widget.onOpenPortfolio ??
                        () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const PortfolioDetailScreen()),
                            ),
                    hideBalances: state.hideBalances,
                    onToggleHideBalances: cubit.toggleHideBalances,
                  ),
                  const SizedBox(height: DS.spaceMD),
                ],
                if (availableClasses.length > 1) ...[
                  AssetClassFilter(
                    availableClasses: availableClasses,
                    selected: _filter,
                    onSelected: (value) => setState(() => _filter = value),
                  ),
                  const SizedBox(height: DS.spaceMD),
                ],
                if (filteredCards.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: DS.spaceLG),
                    child: Center(
                      child: Text(l10n.watchlistEmptyMessage, style: TextStyle(color: colors.textTertiary)),
                    ),
                  )
                else
                  DSCard(
                    padding: const EdgeInsets.symmetric(horizontal: DS.spaceXS, vertical: DS.spaceXS),
                    child: canReorder
                        ? ReorderableListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            // See buildDefaultDragHandles note on the
                            // instrument-detail-screen sibling usage above:
                            // the default drag-handle icon overlaps trailing
                            // row content on desktop, so it's disabled in
                            // favor of the long-press-anywhere gesture.
                            buildDefaultDragHandles: false,
                            itemCount: filteredCards.length,
                            onReorder: cubit.move,
                            itemBuilder: (context, index) => ReorderableDelayedDragStartListener(
                              key: ValueKey(filteredCards[index].id),
                              index: index,
                              child: _row(context, cubit, l10n, colors, filteredCards[index]),
                            ),
                          )
                        : Column(
                            children: [
                              for (final card in filteredCards)
                                KeyedSubtree(
                                  key: ValueKey(card.id),
                                  child: _row(context, cubit, l10n, colors, card),
                                ),
                            ],
                          ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _row(BuildContext context, AppCubit cubit, AppLocalizations l10n, QimaColors colors, WatchCard card) {
    final presentation = cubit.presentation(card);
    return Dismissible(
      key: ValueKey('dismissible-${card.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => confirmDelete(
        context,
        title: l10n.confirmRemoveCardTitle(displayLabel(context, presentation.instrument.nameKey)),
        message: l10n.confirmRemoveCardMessage,
        confirmLabel: l10n.commonRemove,
      ),
      onDismissed: (_) => cubit.removeCard(card.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: DS.spaceMD),
        child: Icon(Icons.delete, color: colors.down),
      ),
      child: InstrumentRow(
        presentation: presentation,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => InstrumentDetailScreen(card: card)),
        ),
      ),
    );
  }
}
