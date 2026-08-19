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
import '../theme/strings.dart';
import '../widgets/instrument_icon.dart';
import '../widgets/stat_pill.dart';
import 'currency_picker.dart';
import 'holdings_card.dart';

/// The main instrument screen: hero price card, metal breakdown, chart with
/// range chips, holdings, and a stats row. Mirrors
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
  bool _showsExtendedRanges = false;

  @override
  void initState() {
    super.initState();
    _card = widget.card;
    final cubit = context.read<AppCubit>();
    _range = cubit.state.preferredChartRange;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final presentation = cubit.presentation(_card);
      if (presentation.series.isEmpty) {
        cubit.refresh(presentation.instrument);
      }
    });
  }

  void _select(ChartRange range) {
    setState(() => _range = range);
    context.read<AppCubit>().setPreferredChartRange(range);
  }

  void _revealAllTime() {
    final cubit = context.read<AppCubit>();
    setState(() {
      _showsExtendedRanges = true;
      _range = ChartRange.all;
    });
    final presentation = cubit.presentation(_card);
    cubit.loadHistory(presentation.instrument, _card.currency);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AppCubit>();
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<AppCubit, AppState>(
      builder: (context, state) {
        final presentation = cubit.presentation(_card);
        final instrument = presentation.instrument;
        final now = DateTime.now();
        final availableRanges = ChartRange.available(presentation.points, now, includeExtended: _showsExtendedRanges);
        final effectiveRange = availableRanges.contains(_range) ? _range : availableRanges.last;
        final windowChange = presentation.change(effectiveRange, now);
        final accent = InstrumentTheme.accentColor(instrument);

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
                padding: const EdgeInsets.all(DS.spaceMD),
                children: [
                  _CurrentPriceCard(presentation: presentation, change: windowChange, accent: accent),
                  if (instrument.assetClass == AssetClass.metal) ...[
                    const SizedBox(height: DS.spaceMD),
                    _MetalBreakdownCard(presentation: presentation),
                  ],
                  const SizedBox(height: DS.spaceMD),
                  DSCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Text(l10n.detailHistory, style: const TextStyle(color: DS.textPrimary, fontWeight: FontWeight.w700)),
                            const Spacer(),
                            TextButton(
                              onPressed: state.isLoadingHistory ? null : _revealAllTime,
                              child: state.isLoadingHistory
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : Text(l10n.detailLoadHistory),
                            ),
                          ],
                        ),
                        const SizedBox(height: DS.spaceXS),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (final range in availableRanges)
                                Padding(
                                  padding: const EdgeInsets.only(right: DS.spaceXS),
                                  child: DSChoiceChip(
                                    label: displayLabel(context, range.labelKey),
                                    selected: effectiveRange == range,
                                    onSelected: (_) => _select(range),
                                    accent: accent,
                                  ),
                                ),
                              if (!_showsExtendedRanges)
                                Padding(
                                  padding: const EdgeInsets.only(right: DS.spaceXS),
                                  child: DSChoiceChip(
                                    label: displayLabel(context, ChartRange.all.labelKey),
                                    selected: false,
                                    onSelected: (_) => _revealAllTime(),
                                    accent: accent,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: DS.spaceSM),
                        SizedBox(
                          height: 240,
                          child: KeyedSubtree(
                            key: ValueKey(effectiveRange),
                            child: _buildChart(context, presentation, effectiveRange, now, windowChange, accent, state),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: DS.spaceMD),
                  HoldingsCard(instrument: instrument, displayCurrency: _card.currency),
                  const SizedBox(height: DS.spaceMD),
                  _StatsRow(presentation: presentation, range: effectiveRange, now: now, change: windowChange),
                  if (state.phase == RefreshPhase.failed && state.errorMessage != null) ...[
                    const SizedBox(height: DS.spaceMD),
                    DSCard(
                      child: Text(
                        state.errorMessage!,
                        style: const TextStyle(color: DS.down),
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

  Widget _buildChart(
    BuildContext context,
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
            const Icon(Icons.show_chart, color: DS.textTertiary, size: 32),
            const SizedBox(height: DS.spaceSM),
            Text(l10n.detailNoHistoryTitle, style: const TextStyle(color: DS.textSecondary)),
            const SizedBox(height: 2),
            Text(l10n.detailNoHistoryMessage, style: const TextStyle(color: DS.textTertiary, fontSize: 12)),
            const SizedBox(height: DS.spaceXS),
            TextButton(onPressed: _revealAllTime, child: Text(l10n.detailLoadHistory)),
          ],
        ),
      );
    }
    return PriceChartView(
      points: windowed,
      isTrendingUp: windowChange?.isUp ?? presentation.isTrendingUp,
      accent: DS.trendColor(windowChange?.isUp ?? presentation.isTrendingUp),
      isInteractive: true,
      currencyCode: presentation.displayCurrency,
    );
  }
}

class _CurrentPriceCard extends StatelessWidget {
  final InstrumentPresentation presentation;
  final RangeChange? change;
  final Color accent;

  const _CurrentPriceCard({required this.presentation, required this.change, required this.accent});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return DSHeroCard(
      accent: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InstrumentIcon(instrument: presentation.instrument, size: 36),
              const SizedBox(width: DS.spaceSM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(displayLabel(context, presentation.instrument.nameKey),
                        style: const TextStyle(color: DS.textPrimary, fontWeight: FontWeight.w700)),
                    Text(presentation.symbol, style: const TextStyle(color: DS.textTertiary, fontSize: 12)),
                  ],
                ),
              ),
              if (presentation.hasData)
                Text(
                  '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(color: DS.textTertiary, fontSize: 12),
                ),
            ],
          ),
          const SizedBox(height: DS.spaceMD),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                presentation.latestPrice,
                style: const TextStyle(color: DS.textPrimary, fontSize: 38, fontWeight: FontWeight.w800),
              ),
              if (presentation.unitSuffix != null)
                Padding(
                  padding: const EdgeInsets.only(left: 6, bottom: 6),
                  child: Text('/ ${displayLabel(context, presentation.unitSuffix!)}',
                      style: const TextStyle(color: DS.textTertiary, fontSize: 14)),
                ),
              if (presentation.karatLabel != null)
                Padding(
                  padding: const EdgeInsets.only(left: 6, bottom: 6),
                  child: Text(displayLabel(context, presentation.karatLabel!),
                      style: const TextStyle(color: DS.textSecondary, fontSize: 14)),
                ),
            ],
          ),
          const SizedBox(height: DS.spaceSM),
          if (change != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: DS.spaceSM, vertical: 4),
              decoration: BoxDecoration(
                color: DS.trendColor(change!.isUp).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(DS.radiusPill),
              ),
              child: Text(
                '${change!.isUp ? '+' : ''}${(change!.percentValue * 100).toStringAsFixed(2)}%',
                style: TextStyle(color: DS.trendColor(change!.isUp), fontWeight: FontWeight.w700, fontSize: 13),
              ),
            )
          else if (!presentation.hasData)
            Text(AppLocalizations.of(context)!.pricePullToRefresh, style: const TextStyle(color: DS.textTertiary, fontSize: 12)),
        ],
      ),
    );
  }
}

class _MetalBreakdownCard extends StatelessWidget {
  final InstrumentPresentation presentation;

  const _MetalBreakdownCard({required this.presentation});

  @override
  Widget build(BuildContext context) {
    final rows = presentation.metalBreakdown;
    if (rows.isEmpty) return const SizedBox.shrink();
    return DSCard(
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 2.4,
        mainAxisSpacing: DS.spaceXS,
        crossAxisSpacing: DS.spaceXS,
        children: [
          for (final row in rows)
            DSTile(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(displayLabel(context, row.label), style: const TextStyle(color: DS.textTertiary, fontSize: 11)),
                  const SizedBox(height: 2),
                  Text(row.value, style: const TextStyle(color: DS.textPrimary, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final InstrumentPresentation presentation;
  final ChartRange range;
  final DateTime now;
  final RangeChange? change;

  const _StatsRow({required this.presentation, required this.range, required this.now, required this.change});

  @override
  Widget build(BuildContext context) {
    final windowed = range.filter(presentation.points, now);
    final high = windowed.isEmpty ? null : windowed.map((p) => p.value).reduce((a, b) => a > b ? a : b);
    final low = windowed.isEmpty ? null : windowed.map((p) => p.value).reduce((a, b) => a < b ? a : b);
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        Expanded(
          child: StatPill(
            title: l10n.statChange,
            value: change == null ? '—' : '${(change!.percentValue * 100).toStringAsFixed(2)}%',
            tint: change == null ? null : DS.trendColor(change!.isUp),
          ),
        ),
        const SizedBox(width: DS.spaceXS),
        Expanded(child: StatPill(title: l10n.statHigh, value: high?.toStringAsFixed(2) ?? '—')),
        const SizedBox(width: DS.spaceXS),
        Expanded(child: StatPill(title: l10n.statLow, value: low?.toStringAsFixed(2) ?? '—')),
        const SizedBox(width: DS.spaceXS),
        Expanded(child: StatPill(title: l10n.statPoints, value: '${windowed.length}')),
      ],
    );
  }
}
