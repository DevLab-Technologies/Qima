import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../blocs/app_cubit.dart';
import '../blocs/app_state.dart';
import '../l10n/app_localizations.dart';
import '../models/asset.dart';
import '../models/holding.dart';
import '../models/holding_totals.dart';
import '../models/metal_breakdown.dart';
import '../models/money.dart';
import '../theme/design_system.dart';
import '../theme/masking.dart';
import '../theme/qima_colors.dart';
import '../theme/strings.dart';
import '../widgets/confirm_delete_dialog.dart';
import 'lot_editor_screen.dart';

/// Full lot list for one instrument, opened from the instrument detail
/// screen's compact "N lots ›" holdings summary card (spec §v2-A "Instrument
/// detail"). Holds the lot list previously inline in `holdings_card.dart`,
/// including swipe-to-delete with the same confirmation dialog and the "+"
/// add-lot action.
class HoldingsScreen extends StatelessWidget {
  final Instrument instrument;
  final String displayCurrency;

  /// The unit/karat of the watch card the user opened Holdings from — the
  /// reference totals are expressed at. Falls back to the instrument's
  /// default unit and no karat (fine gold) when there's no originating card
  /// (e.g. instrument opened directly).
  final PriceUnit? refUnit;
  final GoldKarat? refKarat;

  const HoldingsScreen({
    super.key,
    required this.instrument,
    required this.displayCurrency,
    this.refUnit,
    this.refKarat,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AppCubit>();
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final unit = refUnit ?? instrument.quotation.defaultUnit;

    return ScreenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(l10n.detailHoldings),
          actions: [
            IconButton(
              icon: Icon(Icons.add_circle_outline, color: colors.textPrimary),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => LotEditorScreen(
                    instrument: instrument,
                    defaultCurrency: displayCurrency,
                    defaultUnit: unit,
                    defaultKarat: refKarat,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: BlocBuilder<AppCubit, AppState>(
          builder: (context, state) {
            final lots = cubit.lotsFor(instrument);
            final valuation = cubit.valuationFor(instrument, displayCurrency);
            final hidden = state.hideBalances;

            return ListView(
              padding: const EdgeInsets.all(DS.spaceMD),
              children: [
                if (valuation != null) ...[
                  DSCard(
                    child: _SummaryGrid(
                      valuation: valuation,
                      hidden: hidden,
                      lots: lots,
                      unit: unit,
                      karat: refKarat,
                      displayCurrency: displayCurrency,
                      rates: state.rates,
                    ),
                  ),
                  const SizedBox(height: DS.spaceMD),
                ] else
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: DS.spaceMD),
                    child: Text(l10n.holdingsEmpty, style: TextStyle(color: colors.textTertiary)),
                  ),
                for (final lot in lots)
                  Padding(
                    padding: const EdgeInsets.only(bottom: DS.spaceXS),
                    child: _LotTile(
                      lot: lot,
                      hidden: hidden,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => LotEditorScreen(
                            instrument: instrument,
                            defaultCurrency: displayCurrency,
                            defaultUnit: unit,
                            defaultKarat: refKarat,
                            existing: lot,
                          ),
                        ),
                      ),
                      onDelete: () => cubit.deleteLot(lot),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  final HoldingValuation valuation;
  final bool hidden;
  final List<HoldingLot> lots;
  final PriceUnit unit;
  final GoldKarat? karat;
  final String displayCurrency;
  final FXRates rates;

  const _SummaryGrid({
    required this.valuation,
    required this.hidden,
    required this.lots,
    required this.unit,
    required this.karat,
    required this.displayCurrency,
    required this.rates,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final gainPercent = (valuation.gainFraction * 100).toStringAsFixed(2);
    final held = HoldingTotals.totalHeld(lots: lots, refUnit: unit, refKarat: karat);
    final averageCost = HoldingTotals.averageCost(
      lots: lots,
      refUnit: unit,
      refKarat: karat,
      displayCurrency: displayCurrency,
      rates: rates,
    );
    final mixed = HoldingTotals.isMixed(lots);
    final mixedKarat = HoldingTotals.isMixedKarat(lots);
    final heldText = quantityWithUnitKaratLabel(context, held, unit, karat);
    final unitText = displayLabel(context, unit.labelKey);
    final averageText = averageCost == null
        ? '—'
        : karat == null
            ? l10n.holdingsAverageCostPerUnit(Masking.amount(averageCost, hidden: false), unitText)
            : l10n.holdingsAverageCostPerUnitKarat(
                Masking.amount(averageCost, hidden: false), unitText, displayLabel(context, karat!.shortLabelKey));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Fixed tile height: an aspect ratio made tiles balloon on tablets.
        GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisExtent: 62,
            mainAxisSpacing: DS.spaceXS,
            crossAxisSpacing: DS.spaceXS,
          ),
          children: [
            // Total held is a bare quantity, which — like a balance — reveals
            // wealth, so it's masked along with money amounts.
            _metric(colors, l10n.holdingsTotalHeld, hidden ? Masking.mask : heldText),
            _metric(colors, l10n.holdingsAverageCost, averageText),
            _metric(colors, l10n.holdingsValue, Masking.amount(valuation.value, hidden: hidden)),
            _metric(colors, l10n.holdingsCost, Masking.amount(valuation.cost, hidden: hidden)),
            _metric(colors, l10n.holdingsGain, Masking.signedAmount(valuation.gain, hidden: hidden, isUp: valuation.isUp),
                tint: QimaColors.trendColor(valuation.isUp, colors)),
            _metric(colors, l10n.holdingsGainPercent, signedFigure('$gainPercent%', isUp: valuation.isUp),
                tint: QimaColors.trendColor(valuation.isUp, colors)),
          ],
        ),
        if (mixed) ...[
          const SizedBox(height: DS.spaceXS),
          Text(
            // "Mixed karats" only when the karats actually differ (24K is
            // still a karat, so a null ref karat still gets its own label)
            // — a pure unit mismatch (e.g. some lots in g, some in oz t, all
            // fine gold) gets the plainer wording instead.
            mixedKarat
                ? l10n.holdingsMixedNote(displayLabel(context, (karat ?? GoldKarat.k24).shortLabelKey))
                : l10n.holdingsMixedUnitsNote,
            style: TextStyle(color: colors.textTertiary, fontSize: 11),
          ),
        ],
      ],
    );
  }

  Widget _metric(QimaColors colors, String label, String value, {Color? tint}) {
    return DSTile(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label.toUpperCase(), style: TextStyle(color: colors.textTertiary, fontSize: 10)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(color: tint ?? colors.textPrimary, fontSize: 14, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _LotTile extends StatelessWidget {
  final HoldingLot lot;
  final bool hidden;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _LotTile({required this.lot, required this.hidden, required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final qtyText = lotQuantityLabel(context, lot);
    final detailText = lotDetailLabel(lot, hidden: hidden);
    final l10n = AppLocalizations.of(context)!;
    return Dismissible(
      key: ValueKey(lot.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => confirmDelete(
        context,
        title: l10n.confirmDeleteLotTitle,
        message: l10n.confirmDeleteLotMessage('$qtyText · $detailText'),
        confirmLabel: l10n.commonDelete,
      ),
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: DS.spaceMD),
        decoration: BoxDecoration(
          gradient: DS.tileFill(colors),
          borderRadius: BorderRadius.circular(DS.radiusTile),
        ),
        child: Icon(Icons.delete, color: colors.down),
      ),
      child: DSTile(
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          onTap: onTap,
          title: Text(qtyText, style: TextStyle(color: colors.textPrimary)),
          subtitle: Text(
            detailText,
            style: TextStyle(color: colors.textTertiary, fontSize: 12),
          ),
          trailing: Text(
            Masking.amount(Money(lot.totalCost, lot.costCurrency), hidden: hidden),
            style: TextStyle(color: colors.textSecondary),
          ),
        ),
      ),
    );
  }
}

/// "5 oz t" or "100 g · 21K" — the lot's quantity with its unit and (for a
/// karat lot) its karat, as shown in lot lists. Never masked: a bare
/// quantity isn't a money amount. Unlike [quantityWithUnitKaratLabel] this
/// always shows the LOT's own stored karat, never a reference karat — a
/// lot tile must reflect what the lot actually is.
String lotQuantityLabel(BuildContext context, HoldingLot lot) =>
    quantityWithUnitKaratLabel(context, lot.quantity, lot.unit, lot.karat);

/// "150 g · 21K" — a quantity already expressed at [unit]/[karat] (e.g. a
/// totals figure from [HoldingTotals]), formatted the same way
/// [lotQuantityLabel] formats a single lot's own quantity/unit/karat.
String quantityWithUnitKaratLabel(BuildContext context, double quantity, PriceUnit unit, GoldKarat? karat) {
  final unitSuffix = unit.abbreviationKey != null ? ' ${displayLabel(context, unit.abbreviationKey!)}' : '';
  final karatSuffix = karat != null ? ' · ${displayLabel(context, karat.shortLabelKey)}' : '';
  return '${_formatQty(quantity)}$unitSuffix$karatSuffix';
}

/// "$3,120.00 · 2024-03-14" — the lot's unit cost and purchase date. The
/// unit cost is masked when [hidden] (used in both the lot list subtitle and
/// the delete-confirmation message, so a swipe-to-delete prompt never leaks
/// an amount while balances are hidden).
String lotDetailLabel(HoldingLot lot, {bool hidden = false}) =>
    '${Masking.amount(Money(lot.unitCost, lot.costCurrency), hidden: hidden)} · '
    '${lot.date.year}-${lot.date.month.toString().padLeft(2, '0')}-${lot.date.day.toString().padLeft(2, '0')}';

/// "117,000", "2.5", "0.1234": grouped like the app's money amounts, up to
/// four decimals with trailing zeros dropped.
String _formatQty(double value) => (NumberFormat.decimalPattern()..maximumFractionDigits = 4).format(value);
