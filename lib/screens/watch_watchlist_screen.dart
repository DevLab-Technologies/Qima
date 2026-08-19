import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/app_cubit.dart';
import '../blocs/app_state.dart';
import '../l10n/app_localizations.dart';
import '../theme/design_system.dart';
import '../theme/strings.dart';
import '../widgets/instrument_icon.dart';

/// Compact, read-only watchlist for Wear OS. Mirrors `WatchWatchlistView.swift`
/// (spec §6): no add/edit/settings/reorder affordances, just a glanceable
/// list of whatever the shared watchlist already contains, driven by the
/// same [AppCubit] as the phone screen.
///
/// Kept intentionally simple: a vertically-scrollable column of rounded
/// tiles with generous horizontal padding, which stays clear of the corners
/// that round Wear OS screens crop away.
class WatchWatchlistScreen extends StatefulWidget {
  const WatchWatchlistScreen({super.key});

  @override
  State<WatchWatchlistScreen> createState() => _WatchWatchlistScreenState();
}

class _WatchWatchlistScreenState extends State<WatchWatchlistScreen> with WidgetsBindingObserver {
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
        body: SafeArea(
          child: BlocBuilder<AppCubit, AppState>(
            builder: (context, state) {
              if (!state.initialized) {
                return const Center(child: CircularProgressIndicator(strokeWidth: 2));
              }
              if (state.cards.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: DS.spaceMD),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_border, color: DS.textTertiary, size: 28),
                        const SizedBox(height: DS.spaceXS),
                        Text(
                          l10n.watchlistEmptyTitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: DS.textPrimary, fontSize: 13, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: DS.spaceSM, vertical: DS.spaceLG),
                itemCount: state.cards.length,
                itemBuilder: (context, index) {
                  final card = state.cards[index];
                  final presentation = cubit.presentation(card);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: DS.spaceSM),
                    child: _WatchRow(
                      instrumentName: displayLabel(context, presentation.instrument.nameKey),
                      karatLabel: presentation.karatLabel != null ? displayLabel(context, presentation.karatLabel!) : null,
                      price: presentation.latestPrice,
                      percentChange: presentation.percentChange,
                      isTrendingUp: presentation.isTrendingUp,
                      icon: InstrumentIcon(instrument: presentation.instrument, size: 24),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Single glanceable row: icon+name(+karat) header line, a big price, and a
/// trend line showing the whole-series percent change — matching
/// `WatchRow.swift`'s `percentChange`/`trendSymbol`/`trendColor`.
class _WatchRow extends StatelessWidget {
  final String instrumentName;
  final String? karatLabel;
  final String price;
  final double percentChange;
  final bool isTrendingUp;
  final Widget icon;

  const _WatchRow({
    required this.instrumentName,
    required this.karatLabel,
    required this.price,
    required this.percentChange,
    required this.isTrendingUp,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final accent = DS.trendColor(isTrendingUp);
    return DSTile(
      padding: const EdgeInsets.symmetric(horizontal: DS.spaceSM, vertical: DS.spaceSM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              icon,
              const SizedBox(width: DS.spaceXS),
              Expanded(
                child: Text(
                  karatLabel != null ? '$instrumentName · $karatLabel' : instrumentName,
                  style: const TextStyle(color: DS.textPrimary, fontSize: 12, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: DS.spaceXS),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              price,
              style: TextStyle(color: accent, fontSize: 20, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isTrendingUp ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                color: accent,
                size: 14,
              ),
              Text(
                '${(percentChange.abs() * 100).toStringAsFixed(2)}%',
                style: TextStyle(color: accent, fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
