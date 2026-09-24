import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/app_cubit.dart';
import '../blocs/app_state.dart';
import '../l10n/app_localizations.dart';
import '../models/holding.dart';
import '../theme/design_system.dart';
import '../theme/masking.dart';
import '../theme/qima_colors.dart';
import '../theme/strings.dart';
import '../widgets/allocation_donut.dart';
import '../widgets/instrument_icon.dart';
import 'instrument_detail_screen.dart';

/// Portfolio breakdown: an allocation-donut hero (total value, gain, cost)
/// plus one row per held instrument — name, lot count/weight, value, gain,
/// and a thin weight bar in the holding's accent color (spec §v2-A
/// "Portfolio"). Mirrors `PortfolioDetailView.swift`.
class PortfolioDetailScreen extends StatelessWidget {
  const PortfolioDetailScreen({super.key});

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
          title: Text(l10n.portfolioTitle),
          actions: [
            BlocBuilder<AppCubit, AppState>(
              buildWhen: (previous, current) => previous.hideBalances != current.hideBalances,
              builder: (context, state) {
                return IconButton(
                  icon: Icon(state.hideBalances ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                  tooltip: state.hideBalances ? l10n.privacyShowBalances : l10n.privacyHideBalances,
                  onPressed: cubit.toggleHideBalances,
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<AppCubit, AppState>(
          builder: (context, state) {
            final hidden = state.hideBalances;
            final valuation = cubit.portfolioValuation;
            final heldInstruments = cubit.heldInstruments;
            final slices = resolveAllocation(heldInstruments, colors);
            final sliceByID = {for (final s in slices) s.holding.id: s};

            return ListView(
              padding: const EdgeInsets.all(DS.spaceMD),
              children: [
                if (valuation != null)
                  DSHeroCard(
                    accent: colors.brand,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        AllocationDonut(
                          slices: slices,
                          centerValue: Masking.compactAmount(valuation.value, hidden: hidden),
                          centerLabel: l10n.portfolioValue,
                        ),
                        const SizedBox(width: DS.spaceLG),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l10n.portfolioValue, style: TextStyle(color: colors.textTertiary, fontSize: 12)),
                              const SizedBox(height: 4),
                              Text(
                                Masking.amount(valuation.value, hidden: hidden),
                                style: TextStyle(color: colors.textPrimary, fontSize: 24, fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: DS.spaceSM),
                              _metricTile(
                                colors,
                                l10n.holdingsGain,
                                Masking.signedAmount(valuation.gain, hidden: hidden, isUp: valuation.isUp),
                                tint: QimaColors.trendColor(valuation.isUp, colors),
                              ),
                              const SizedBox(height: DS.spaceXS),
                              _metricTile(colors, l10n.holdingsCost, Masking.amount(valuation.cost, hidden: hidden)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  DSCard(
                    child: Text(l10n.portfolioEmpty,
                        style: TextStyle(color: colors.textTertiary)),
                  ),
                const SizedBox(height: DS.spaceLG),
                for (final held in heldInstruments)
                  Padding(
                    padding: const EdgeInsets.only(bottom: DS.spaceSM),
                    child: _HoldingRow(
                      held: held,
                      color: sliceByID[held.id]?.color ?? colors.brand,
                      fraction: sliceByID[held.id]?.fraction ?? 0,
                      hidden: hidden,
                      onTap: () {
                        final card = cubit.firstCard(held.instrument);
                        if (card != null) {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => InstrumentDetailScreen(card: card)),
                          );
                        }
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _metricTile(QimaColors colors, String label, String value, {Color? tint}) {
    return DSTile(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label.toUpperCase(), style: TextStyle(color: colors.textTertiary, fontSize: 10)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(color: tint ?? colors.textPrimary, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _HoldingRow extends StatelessWidget {
  final HeldInstrument held;
  final Color color;
  final double fraction;
  final bool hidden;
  final VoidCallback onTap;

  const _HoldingRow({
    required this.held,
    required this.color,
    required this.fraction,
    required this.hidden,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final weightPercent = (fraction * 100).toStringAsFixed(1);

    return DSCard(
      child: InkWell(
        borderRadius: BorderRadius.circular(DS.radiusCard),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                InstrumentIcon(instrument: held.instrument, size: 36),
                const SizedBox(width: DS.spaceSM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(displayLabel(context, held.instrument.nameKey),
                          style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w600)),
                      Text(
                        '${l10n.portfolioLotCount(held.lotCount)} · $weightPercent%',
                        style: TextStyle(color: colors.textTertiary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(Masking.amount(held.valuation.value, hidden: hidden),
                        style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w700)),
                    Text(
                      Masking.signedAmount(held.valuation.gain, hidden: hidden, isUp: held.valuation.isUp),
                      style: TextStyle(color: QimaColors.trendColor(held.valuation.isUp, colors), fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: DS.spaceSM),
            ClipRRect(
              borderRadius: BorderRadius.circular(DS.radiusPill),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      Container(height: 4, color: colors.hairline),
                      Container(
                        height: 4,
                        width: constraints.maxWidth * fraction.clamp(0.0, 1.0),
                        color: color,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
