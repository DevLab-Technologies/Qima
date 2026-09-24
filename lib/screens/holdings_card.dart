import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/app_cubit.dart';
import '../blocs/app_state.dart';
import '../l10n/app_localizations.dart';
import '../models/asset.dart';
import '../theme/design_system.dart';
import '../theme/masking.dart';
import '../theme/qima_colors.dart';
import '../theme/strings.dart';
import 'holdings_screen.dart';

/// Compact holdings summary card on the instrument detail screen: "N lots ›"
/// plus Value/Gain/Gain % (spec §v2-A "Instrument detail"). Tapping it opens
/// the full lot list on [HoldingsScreen]. Shows an "add first lot" prompt
/// when the instrument has no lots yet.
class HoldingsCard extends StatelessWidget {
  final Instrument instrument;
  final String displayCurrency;

  const HoldingsCard({super.key, required this.instrument, required this.displayCurrency});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AppCubit>();
    final lotCount = cubit.lotsFor(instrument).length;
    final valuation = cubit.valuationFor(instrument, displayCurrency);
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return BlocBuilder<AppCubit, AppState>(
      buildWhen: (previous, current) => previous.hideBalances != current.hideBalances,
      builder: (context, state) {
        final hidden = state.hideBalances;
        return DSCard(
          child: InkWell(
            borderRadius: BorderRadius.circular(DS.radiusCard),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => HoldingsScreen(instrument: instrument, displayCurrency: displayCurrency),
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
                      l10n.portfolioLotCount(lotCount),
                      style: TextStyle(color: colors.textTertiary, fontSize: 13),
                    ),
                    const Spacer(),
                    Icon(Icons.chevron_right, color: colors.textTertiary),
                  ],
                ),
                if (valuation == null)
                  Padding(
                    padding: const EdgeInsets.only(top: DS.spaceSM),
                    child: Text(l10n.holdingsEmpty, style: TextStyle(color: colors.textTertiary)),
                  )
                else ...[
                  const SizedBox(height: DS.spaceSM),
                  Row(
                    children: [
                      Expanded(child: _metric(colors, l10n.holdingsValue, Masking.amount(valuation.value, hidden: hidden))),
                      const SizedBox(width: DS.spaceXS),
                      Expanded(
                        child: _metric(
                          colors,
                          l10n.holdingsGain,
                          Masking.signedAmount(valuation.gain, hidden: hidden, isUp: valuation.isUp),
                          tint: QimaColors.trendColor(valuation.isUp, colors),
                        ),
                      ),
                      const SizedBox(width: DS.spaceXS),
                      Expanded(
                        child: _metric(
                          colors,
                          l10n.holdingsGainPercent,
                          signedFigure('${(valuation.gainFraction * 100).toStringAsFixed(2)}%', isUp: valuation.isUp),
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

  Widget _metric(QimaColors colors, String label, String value, {Color? tint}) {
    return DSTile(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label.toUpperCase(), style: TextStyle(color: colors.textTertiary, fontSize: 10)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(color: tint ?? colors.textPrimary, fontSize: 14, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
