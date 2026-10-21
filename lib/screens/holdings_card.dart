import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/app_cubit.dart';
import '../blocs/app_state.dart';
import '../l10n/app_localizations.dart';
import '../models/asset.dart';
import '../models/holding_totals.dart';
import '../models/metal_breakdown.dart';
import '../theme/design_system.dart';
import '../theme/masking.dart';
import '../theme/qima_colors.dart';
import '../theme/strings.dart';
import '../widgets/stat_pill.dart';
import 'holdings_screen.dart';

/// Compact holdings summary card on the instrument detail screen: "N
/// transactions ›" plus Value/Gain/Gain % (spec §v2-A "Instrument detail").
/// Tapping it opens the ledger on [HoldingsScreen]. Shows an "add your
/// first" prompt with no transactions, and the realised result once a
/// position has been sold off entirely.
class HoldingsCard extends StatelessWidget {
  final Instrument instrument;
  final String displayCurrency;

  /// The unit/karat of the watch card the user opened this from — used as
  /// the reference for the "Held … · avg …" line and forwarded to
  /// [HoldingsScreen] and the lot editor. Falls back to the instrument's
  /// default unit and no karat when absent.
  final PriceUnit? refUnit;
  final GoldKarat? refKarat;

  const HoldingsCard({
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

    return BlocBuilder<AppCubit, AppState>(
      buildWhen: (previous, current) =>
          previous.hideBalances != current.hideBalances || previous.ledger != current.ledger || previous.rates != current.rates,
      builder: (context, state) {
        // Recomputed on every rebuild (rather than hoisted above the
        // BlocBuilder) so a saved or deleted transaction shows at once.
        final lots = cubit.lotsFor(instrument);
        final transactionCount = cubit.transactionsFor(instrument).length;
        final position = state.ledger[instrument.id];
        final valuation = cubit.valuationFor(instrument, displayCurrency);
        final hidden = state.hideBalances;
        final held = HoldingTotals.totalHeld(lots: lots, refUnit: unit, refKarat: refKarat);
        final averageCost = HoldingTotals.averageCost(
          lots: lots,
          refUnit: unit,
          refKarat: refKarat,
          displayCurrency: displayCurrency,
          rates: state.rates,
        );
        return DSCard(
          child: InkWell(
            borderRadius: BorderRadius.circular(DS.radiusCard),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => HoldingsScreen(
                  instrument: instrument,
                  displayCurrency: displayCurrency,
                  refUnit: refUnit,
                  refKarat: refKarat,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Text(l10n.detailHoldings,
                        style: TextStyle(color: colors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(width: DS.spaceXS),
                    Text(
                      l10n.portfolioTransactionCount(transactionCount),
                      style: TextStyle(color: colors.textTertiary, fontSize: 13),
                    ),
                    const Spacer(),
                    Icon(Icons.chevron_right, color: colors.textTertiary),
                  ],
                ),
                if (valuation == null)
                  Padding(
                    padding: const EdgeInsets.only(top: DS.spaceSM),
                    child: Text(
                      transactionCount == 0 || position == null
                          ? l10n.holdingsEmpty
                          : l10n.ledgerClosedLine(Masking.signedAmount(
                              position.realised.inCurrency(displayCurrency, state.rates),
                              hidden: hidden,
                              isUp: position.realised.inCurrency(displayCurrency, state.rates).amount >= 0,
                            )),
                      style: TextStyle(color: colors.textTertiary),
                    ),
                  )
                else ...[
                  if (averageCost != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      l10n.holdingsHeldLine(
                        hidden ? Masking.mask : quantityWithUnitKaratLabel(context, held, unit, refKarat),
                        Masking.amount(averageCost, hidden: hidden),
                      ),
                      style: TextStyle(color: colors.textTertiary, fontSize: 12),
                    ),
                  ],
                  const SizedBox(height: DS.spaceSM),
                  Row(
                    children: [
                      Expanded(child: StatPill(title: l10n.holdingsValue, value: Masking.amount(valuation.value, hidden: hidden))),
                      const SizedBox(width: DS.spaceXS),
                      Expanded(
                        child: StatPill(
                          title: l10n.holdingsGain,
                          value: Masking.signedAmount(valuation.gain, hidden: hidden, isUp: valuation.isUp),
                          tint: QimaColors.trendColor(valuation.isUp, colors),
                        ),
                      ),
                      const SizedBox(width: DS.spaceXS),
                      Expanded(
                        child: StatPill(
                          title: l10n.holdingsGainPercent,
                          value: signedFigure('${(valuation.gainFraction * 100).toStringAsFixed(2)}%', isUp: valuation.isUp),
                          tint: QimaColors.trendColor(valuation.isUp, colors),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
