import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/app_cubit.dart';
import '../blocs/app_state.dart';
import '../l10n/app_localizations.dart';
import '../theme/design_system.dart';
import '../theme/strings.dart';
import '../widgets/instrument_icon.dart';
import 'instrument_detail_screen.dart';

/// Portfolio breakdown: header totals + one row per held instrument.
/// Mirrors `PortfolioDetailView.swift`.
class PortfolioDetailScreen extends StatelessWidget {
  const PortfolioDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AppCubit>();
    final l10n = AppLocalizations.of(context)!;

    return ScreenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(backgroundColor: Colors.transparent, title: Text(l10n.portfolioTitle)),
        body: BlocBuilder<AppCubit, AppState>(
          builder: (context, _) {
            final valuation = cubit.portfolioValuation;
            final heldInstruments = cubit.heldInstruments;

            return ListView(
              padding: const EdgeInsets.all(DS.spaceMD),
              children: [
                if (valuation != null)
                  DSHeroCard(
                    accent: DS.trendColor(valuation.isUp),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.portfolioValue, style: const TextStyle(color: DS.textTertiary, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(
                          valuation.value.formatted(),
                          style: const TextStyle(color: DS.textPrimary, fontSize: 30, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: DS.spaceSM),
                        Row(
                          children: [
                            Expanded(child: _metricTile(l10n.holdingsCost, valuation.cost.formatted())),
                            const SizedBox(width: DS.spaceXS),
                            Expanded(
                              child: _metricTile(
                                l10n.holdingsGain,
                                '${valuation.isUp ? '+' : ''}${valuation.gain.formatted()}',
                                tint: DS.trendColor(valuation.isUp),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                else
                  DSCard(
                    child: Text(l10n.portfolioEmpty,
                        style: const TextStyle(color: DS.textTertiary)),
                  ),
                const SizedBox(height: DS.spaceLG),
                for (final held in heldInstruments)
                  Padding(
                    padding: const EdgeInsets.only(bottom: DS.spaceSM),
                    child: DSCard(
                      child: InkWell(
                        onTap: () {
                          final card = cubit.firstCard(held.instrument);
                          if (card != null) {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => InstrumentDetailScreen(card: card)),
                            );
                          }
                        },
                        child: Row(
                          children: [
                            InstrumentIcon(instrument: held.instrument, size: 36),
                            const SizedBox(width: DS.spaceSM),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(displayLabel(context, held.instrument.nameKey),
                                      style: const TextStyle(color: DS.textPrimary, fontWeight: FontWeight.w600)),
                                  Text(l10n.portfolioLotCount(held.lotCount),
                                      style: const TextStyle(color: DS.textTertiary, fontSize: 12)),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(held.valuation.value.formatted(),
                                    style: const TextStyle(color: DS.textPrimary, fontWeight: FontWeight.w700)),
                                Text(
                                  '${held.valuation.isUp ? '+' : ''}${held.valuation.gain.formatted()}',
                                  style: TextStyle(color: DS.trendColor(held.valuation.isUp), fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _metricTile(String label, String value, {Color? tint}) {
    return DSTile(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label.toUpperCase(), style: const TextStyle(color: DS.textTertiary, fontSize: 10)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(color: tint ?? DS.textPrimary, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
