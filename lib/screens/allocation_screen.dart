import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/app_cubit.dart';
import '../blocs/app_state.dart';
import '../l10n/app_localizations.dart';
import '../models/allocation.dart';
import '../models/instrument_catalog.dart';
import '../models/asset_group.dart';
import '../theme/design_system.dart';
import '../theme/help_topics.dart';
import '../theme/instrument_theme.dart';
import '../theme/qima_colors.dart';
import '../theme/strings.dart';
import '../widgets/allocation_bars.dart';
import '../widgets/allocation_donut.dart';
import '../widgets/help_button.dart';
import '../widgets/section_header.dart';

/// Allocation detail (v3, Figma "Portfolio · Allocation detail"): the split
/// by group, metals by karat and form, and how each group's share moved
/// since 1 January.
class AllocationScreen extends StatelessWidget {
  const AllocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AppCubit>();
    final l10n = AppLocalizations.of(context)!;

    return ScreenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(l10n.allocationTitle),
          actions: const [HelpButton(topic: HelpTopicId.portfolio)],
        ),
        body: BlocBuilder<AppCubit, AppState>(
          builder: (context, state) {
            final colors = context.colors;
            final held = cubit.heldInstruments;
            final groups = Allocation.byGroup(held, state.baseCurrency);
            final metals = Allocation.metalsByForm(
              lots: state.lots,
              rates: state.rates,
              baseCurrency: state.baseCurrency,
              latestUSD: cubit.latestUSD,
              resolve: InstrumentCatalog.instrument,
            );
            final drift = Allocation.drift(
              ledger: state.ledger,
              heldNow: held,
              seriesByID: state.seriesByID,
              fxHistory: state.fxHistory,
              rates: state.rates,
              baseCurrency: state.baseCurrency,
              resolve: InstrumentCatalog.instrument,
              now: DateTime.now(),
            );

            if (groups.isEmpty) {
              return ListView(
                padding: const EdgeInsets.all(DS.spaceMD),
                children: [DSCard(child: Text(l10n.portfolioEmpty, style: TextStyle(color: colors.textTertiary)))],
              );
            }

            return ListView(
              padding: const EdgeInsets.all(DS.spaceMD),
              children: [
                SectionHeader(l10n.allocationByGroup),
                DSCard(child: groupBars(context, groups, hidden: state.hideBalances)),
                if (metals.isNotEmpty) ...[
                  const SizedBox(height: DS.spaceLG),
                  SectionHeader(l10n.allocationMetalsByForm),
                  DSCard(child: _metalBars(context, metals, hidden: state.hideBalances)),
                ],
                if (drift != null) ...[
                  const SizedBox(height: DS.spaceLG),
                  _DriftCard(result: drift),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _metalBars(BuildContext context, List<AllocationShare<MetalForm>> metals, {required bool hidden}) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    // Several karats of one metal get successive shades of its accent, the
    // same way the portfolio donut tells same-class holdings apart.
    final seen = <String, int>{};
    return AllocationBars(
      hidden: hidden,
      bars: [
        for (final share in metals)
          AllocationBar(
            label: share.key.karat == null
                ? displayLabel(context, share.key.instrument.nameKey)
                : l10n.allocationMetalForm(
                    displayLabel(context, share.key.instrument.nameKey), displayLabel(context, share.key.karat!.shortLabelKey)),
            value: share.value,
            fraction: share.fraction,
            color: shadeAccent(
              InstrumentTheme.accentColor(share.key.instrument, colors),
              seen.update(share.key.instrument.id, (n) => n + 1, ifAbsent: () => 0),
            ),
          ),
      ],
    );
  }
}

/// Bars for the split by group — shared by this screen and the portfolio
/// tab's allocation card.
Widget groupBars(BuildContext context, List<AllocationShare<AssetGroup>> groups, {required bool hidden}) {
  final l10n = AppLocalizations.of(context)!;
  final colors = context.colors;
  return AllocationBars(
    hidden: hidden,
    bars: [
      for (final share in groups)
        AllocationBar(
          label: assetGroupLabel(l10n, share.key),
          value: share.value,
          fraction: share.fraction,
          color: InstrumentTheme.groupColor(share.key, colors),
        ),
    ],
  );
}

class _DriftCard extends StatelessWidget {
  final DriftResult result;

  const _DriftCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final result = this.result;

    switch (result) {
      case DriftPending(:final availableOn):
        return _note(context, l10n.allocationDriftPendingTitle, l10n.allocationDriftPending(dateWithYear(context, availableOn)));
      case DriftNoPriceHistory():
        return _note(context, l10n.allocationDriftTitle, l10n.allocationDriftNoHistory);
      case DriftReady(:final since, :final rows):
        String pct(double fraction) => percentLabel(context, (fraction * 100).roundToDouble());
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionHeader(l10n.allocationDriftSince(dateWithYear(context, since))),
            DSCard(
              child: Column(
                children: [
                  for (var i = 0; i < rows.length; i++) ...[
                    if (i > 0) const SizedBox(height: DS.spaceSM),
                    Row(
                      children: [
                        Expanded(
                          child: Text(assetGroupLabel(l10n, rows[i].group), style: TextStyle(color: colors.textSecondary)),
                        ),
                        Text(
                          l10n.allocationDriftChange(pct(rows[i].from), pct(rows[i].to)),
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: rows[i].pointsChange == 0
                                ? colors.textSecondary
                                : QimaColors.trendColor(rows[i].pointsChange > 0, colors),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
    }
  }

  Widget _note(BuildContext context, String title, String body) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title),
        DSCard(child: Text(body, style: TextStyle(color: colors.textSecondary, fontSize: 13))),
      ],
    );
  }
}
