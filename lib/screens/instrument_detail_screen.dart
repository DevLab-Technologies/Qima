import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/app_cubit.dart';
import '../blocs/app_state.dart';
import '../l10n/app_localizations.dart';
import '../models/asset.dart';
import '../models/chart_range.dart';
import '../models/instrument_presentation.dart';
import '../models/watch_card.dart';
import '../theme/design_system.dart';
import '../theme/instrument_theme.dart';
import '../theme/price_chart.dart';
import '../theme/qima_colors.dart';
import '../theme/strings.dart';
import '../widgets/alerts_card.dart';
import '../widgets/instrument_icon.dart';
import '../widgets/key_stats_grid.dart';
import '../widgets/unit_price_carousel.dart';
import 'alert_editor_sheet.dart';
import 'currency_picker.dart';
import 'holdings_card.dart';

/// Chart-first ranges offered on the instrument detail screen. Every range
/// is always shown — none are gated behind a "load history" action; picking
/// one that needs data beyond what's cached triggers a lazy background load
/// instead (spec §v2-A "Instrument detail").
const List<ChartRange> _detailRanges = [
  ChartRange.day1,
  ChartRange.day3,
  ChartRange.day7,
  ChartRange.month1,
  ChartRange.month3,
  ChartRange.month6,
  ChartRange.ytd,
  ChartRange.year1,
  ChartRange.all,
];

/// The main instrument screen: an open (no-card) price header, a full-width
/// chart with range chips, key stats, a price-per-unit carousel (metals
/// only), and a compact holdings summary. Mirrors
/// `InstrumentDetailView.swift`.
class InstrumentDetailScreen extends StatefulWidget {
  final WatchCard card;

  const InstrumentDetailScreen({super.key, required this.card});

  @override
  State<InstrumentDetailScreen> createState() => _InstrumentDetailScreenState();
}

class _InstrumentDetailScreenState extends State<InstrumentDetailScreen> {
  late WatchCard _card;
  late ChartRange _range;

  @override
  void initState() {
    super.initState();
    _card = widget.card;
    final cubit = context.read<AppCubit>();
    final preferred = cubit.state.preferredChartRange;
    _range = _detailRanges.contains(preferred) ? preferred : ChartRange.fallbackDefault;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final presentation = cubit.presentation(_card);
      if (presentation.series.isEmpty) {
        cubit.refresh(presentation.instrument);
      }
      _ensureHistoryFor(_range);
    });
  }

  /// Triggers a lazy history backfill the first time a range that needs
  /// data older than what's cached is selected — the replacement for the
  /// old explicit "Load history" button. Cheap to call repeatedly:
  /// `AppCubit.loadHistory` itself no-ops while already loading, and this
  /// only fires when the currently available points don't reach back far
  /// enough for the requested range.
  void _ensureHistoryFor(ChartRange range) {
    final cubit = context.read<AppCubit>();
    final presentation = cubit.presentation(_card);
    final now = DateTime.now();
    final points = presentation.points;
    final start = range.startDate(now);
    final reachesBack = points.length >= 2 &&
        (start == null ? true : !points.first.date.isAfter(start));
    if (reachesBack) return;
    cubit.loadHistory(presentation.instrument, _card.currency);
  }

  void _select(ChartRange range) {
    setState(() => _range = range);
    if (!range.isExtended) {
      context.read<AppCubit>().setPreferredChartRange(range);
    }
    _ensureHistoryFor(range);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AppCubit>();
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return BlocBuilder<AppCubit, AppState>(
      builder: (context, state) {
        final presentation = cubit.presentation(_card);
        final instrument = presentation.instrument;
        final now = DateTime.now();
        final windowChange = presentation.change(_range, now);
        final accent = InstrumentTheme.accentColor(instrument, colors);
        final lastQuoteTime = presentation.series.latest?.timestamp.toLocal();

        return ScreenBackground(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              title: Text(displayLabel(context, instrument.nameKey)),
              actions: [
                PopupMenuButton<String>(
                  icon: const Icon(Icons.tune),
                  onSelected: (value) async {
                    if (value == 'currency') {
                      final selected = await CurrencyPicker.show(
                        context,
                        selected: _card.currency,
                        currencies: state.rates.availableCurrencies,
                      );
                      if (selected != null) {
                        final updated = _card.copyWith(currency: selected);
                        setState(() => _card = updated);
                        await cubit.updateCard(updated);
                      }
                    } else if (value.startsWith('unit:')) {
                      final unit = PriceUnit.values.byName(value.substring(5));
                      final updated = _card.copyWith(unit: unit);
                      setState(() => _card = updated);
                      await cubit.updateCard(updated);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(value: 'currency', child: Text(l10n.detailChangeCurrency)),
                    for (final unit in instrument.supportedUnits)
                      PopupMenuItem(
                        value: 'unit:${unit.name}',
                        child: Text(l10n.detailShowPerUnit(displayLabel(context, unit.labelKey))),
                      ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  tooltip: l10n.alertBellTooltip,
                  onPressed: () => AlertEditorSheet.show(context, card: _card),
                ),
                IconButton(
                  icon: state.phase == RefreshPhase.refreshing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                  onPressed: () => cubit.refresh(instrument),
                ),
              ],
            ),
            body: RefreshIndicator(
              onRefresh: () => cubit.refresh(instrument),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: DS.spaceMD, vertical: DS.spaceSM),
                children: [
                  // Open header — no card background, per spec: icon, name,
                  // symbol/unit line, big price, change pill.
                  Row(
                    children: [
                      InstrumentIcon(instrument: instrument, size: 40),
                      const SizedBox(width: DS.spaceSM),
                      Expanded(
                        child: Text(
                          '${presentation.symbol} · ${presentation.displayCurrency}'
                          '${presentation.unitSuffix != null ? ' / ${displayLabel(context, presentation.unitSuffix!)}' : ''}',
                          style: TextStyle(color: colors.textTertiary, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: DS.spaceSM),
                  Text(
                    presentation.latestPrice,
                    style: TextStyle(color: colors.textPrimary, fontSize: 40, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: DS.spaceXS),
                  Row(
                    children: [
                      if (windowChange != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: DS.spaceSM, vertical: 4),
                          decoration: BoxDecoration(
                            color: QimaColors.trendColor(windowChange.isUp, colors).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(DS.radiusPill),
                          ),
                          child: Text(
                            signedFigure('${(windowChange.percentValue * 100).toStringAsFixed(2)}%', isUp: windowChange.isUp),
                            style: TextStyle(
                              color: QimaColors.trendColor(windowChange.isUp, colors),
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        )
                      else if (!presentation.hasData)
                        Text(l10n.pricePullToRefresh, style: TextStyle(color: colors.textTertiary, fontSize: 12)),
                      const SizedBox(width: DS.spaceSM),
                      Expanded(
                        child: Text(
                          lastQuoteTime == null
                              ? ''
                              : '${displayLabel(context, _range.labelKey)} · ${l10n.detailUpdatedAt(_timeOfDay(lastQuoteTime))}',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: colors.textTertiary, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: DS.spaceMD),
                  AlertsCard(card: _card),
                  const SizedBox(height: DS.spaceMD),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final range in _detailRanges)
                          Padding(
                            padding: const EdgeInsets.only(right: DS.spaceXS),
                            child: DSChoiceChip(
                              label: displayLabel(context, range.labelKey),
                              selected: _range == range,
                              onSelected: (_) => _select(range),
                              accent: accent,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: DS.spaceSM),
                  SizedBox(
                    height: 260,
                    child: KeyedSubtree(
                      key: ValueKey(_range),
                      child: _buildChart(context, colors, presentation, _range, now, windowChange, accent, state),
                    ),
                  ),
                  const SizedBox(height: DS.spaceMD),
                  KeyStatsGrid(
                    windowed: _range.filter(presentation.points, now),
                    changePercent: windowChange?.percentValue,
                    changeIsUp: windowChange?.isUp,
                  ),
                  if (instrument.assetClass == AssetClass.metal) ...[
                    const SizedBox(height: DS.spaceMD),
                    UnitPriceCarousel(rows: presentation.metalBreakdown),
                  ],
                  const SizedBox(height: DS.spaceMD),
                  HoldingsCard(instrument: instrument, displayCurrency: _card.currency),
                  if (state.phase == RefreshPhase.failed && state.errorMessage != null) ...[
                    const SizedBox(height: DS.spaceMD),
                    DSCard(
                      child: Text(
                        displayLabel(context, state.errorMessage!),
                        style: TextStyle(color: colors.down),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _timeOfDay(DateTime time) => '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  Widget _buildChart(
    BuildContext context,
    QimaColors colors,
    InstrumentPresentation presentation,
    ChartRange range,
    DateTime now,
    RangeChange? windowChange,
    Color accent,
    AppState state,
  ) {
    final windowed = range.filter(presentation.points, now);
    if (windowed.length < 2) {
      if (state.isLoadingHistory) {
        return const Center(child: CircularProgressIndicator());
      }
      final l10n = AppLocalizations.of(context)!;
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.show_chart, color: colors.textTertiary, size: 32),
            const SizedBox(height: DS.spaceSM),
            Text(l10n.detailNoHistoryTitle, style: TextStyle(color: colors.textSecondary)),
            const SizedBox(height: 2),
            Text(l10n.detailNoHistoryMessage, style: TextStyle(color: colors.textTertiary, fontSize: 12)),
          ],
        ),
      );
    }
    return PriceChartView(
      points: windowed,
      isTrendingUp: windowChange?.isUp ?? presentation.isTrendingUp,
      accent: QimaColors.trendColor(windowChange?.isUp ?? presentation.isTrendingUp, colors),
      isInteractive: true,
      currencyCode: presentation.displayCurrency,
    );
  }
}
