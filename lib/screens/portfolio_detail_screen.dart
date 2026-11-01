import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/app_cubit.dart';
import '../blocs/app_state.dart';
import '../l10n/app_localizations.dart';
import '../models/allocation.dart';
import '../models/asset_group.dart';
import '../models/asset.dart';
import '../models/holding.dart';
import '../models/zakat.dart';
import '../theme/design_system.dart';
import '../theme/help_topics.dart';
import '../theme/masking.dart';
import '../theme/qima_colors.dart';
import '../theme/strings.dart';
import '../theme/summaries.dart';
import '../widgets/allocation_donut.dart';
import '../widgets/help_button.dart';
import '../widgets/instrument_icon.dart';
import '../widgets/section_header.dart';
import '../widgets/stat_pill.dart';
import 'allocation_screen.dart';
import 'holdings_screen.dart';
import 'instrument_detail_screen.dart';
import 'zakat_screen.dart';

/// Portfolio breakdown: an allocation-donut hero (total value, gain, cost)
/// plus one row per held instrument — name, lot count/weight, value, gain,
/// and a thin weight bar in the holding's accent color (spec §v2-A
/// "Portfolio"). Mirrors `PortfolioDetailView.swift`.
///
/// Used two ways (spec §v2-C): pushed on the root navigator (default —
/// shows a back arrow like any other pushed screen) or hosted as
/// `HomeShell`'s Portfolio tab, which passes [asTab]: true so no back arrow
/// is shown (there's nothing to pop to; the tab bar itself gets you back to
/// Watchlist) and a title with 16px leading padding per the Figma frame.
class PortfolioDetailScreen extends StatelessWidget {
  final bool asTab;
  final ScrollController? scrollController;

  const PortfolioDetailScreen({super.key, this.asTab = false, this.scrollController});

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
          automaticallyImplyLeading: !asTab,
          titleSpacing: asTab ? 16 : null,
          title: Text(l10n.portfolioTitle),
          actions: [
            const HelpButton(topic: HelpTopicId.portfolio),
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
            final realised = cubit.portfolioRealised;
            final closed = cubit.closedPositions;

            void openHolding(Instrument instrument) {
              final card = cubit.firstCard(instrument);
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => card != null
                    ? InstrumentDetailScreen(card: card)
                    // Not on the watchlist: straight to its ledger.
                    : HoldingsScreen(instrument: instrument, displayCurrency: state.baseCurrency),
              ));
            }

            return ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(DS.spaceMD),
              children: [
                if (valuation != null)
                  DSHeroCard(
                    accent: colors.brand,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(l10n.portfolioValue, style: TextStyle(color: colors.textTertiary, fontSize: 12)),
                                  const SizedBox(height: DS.space2XS),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: AlignmentDirectional.centerStart,
                                    child: Text(
                                      Masking.amount(valuation.value, hidden: hidden),
                                      maxLines: 1,
                                      style: TextStyle(
                                        color: colors.textPrimary,
                                        fontSize: DS.figureHero,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: DS.spaceMD),
                            AllocationDonut(slices: slices, size: 64, strokeWidth: 10),
                          ],
                        ),
                        const SizedBox(height: DS.spaceMD),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: StatPill(
                                title: l10n.holdingsGain,
                                value: Masking.signedAmount(valuation.gain, hidden: hidden, isUp: valuation.isUp),
                                tint: QimaColors.trendColor(valuation.isUp, colors),
                              ),
                            ),
                            const SizedBox(width: DS.spaceMD),
                            Expanded(
                              child: StatPill(
                                title: l10n.holdingsCost,
                                value: Masking.amount(valuation.cost, hidden: hidden),
                              ),
                            ),
                            if (realised != null) ...[
                              const SizedBox(width: DS.spaceMD),
                              Expanded(
                                child: StatPill(
                                  title: l10n.ledgerRealised,
                                  value: Masking.signedAmount(realised, hidden: hidden, isUp: realised.amount >= 0),
                                  tint: QimaColors.trendColor(realised.amount >= 0, colors),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  )
                else
                  DSCard(
                    child: Text(l10n.portfolioEmpty,
                        style: TextStyle(color: colors.textTertiary)),
                  ),
                if (state.plainSummaries)
                  if (cubit.periodSummary() case final summary?) ...[
                    const SizedBox(height: DS.spaceSM),
                    _SummaryCard(
                      sentence: periodSummarySentence(context, summary, currency: state.baseCurrency, hidden: hidden),
                      hidden: hidden,
                    ),
                  ],
                if (state.lots.isNotEmpty) ...[
                  const SizedBox(height: DS.spaceSM),
                  _ZakatEntry(assessment: cubit.zakatAssessment, hidden: hidden),
                ],
                if (heldInstruments.isNotEmpty) ...[
                  const SizedBox(height: DS.spaceSM),
                  _AllocationCard(
                    groups: Allocation.byGroup(heldInstruments, state.baseCurrency),
                    hidden: hidden,
                  ),
                ],
                const SizedBox(height: DS.spaceLG),
                for (final held in heldInstruments)
                  Padding(
                    padding: const EdgeInsets.only(bottom: DS.spaceSM),
                    child: _HoldingRow(
                      held: held,
                      color: sliceByID[held.id]?.color ?? colors.brand,
                      fraction: sliceByID[held.id]?.fraction ?? 0,
                      hidden: hidden,
                      onTap: () => openHolding(held.instrument),
                    ),
                  ),
                if (closed.isNotEmpty) ...[
                  const SizedBox(height: DS.spaceSM),
                  SectionHeader(l10n.portfolioClosedPositions),
                  DSCard(
                    padding: const EdgeInsets.symmetric(horizontal: DS.spaceMD, vertical: DS.spaceXS),
                    child: Column(
                      children: [
                        for (final c in closed)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: InstrumentIcon(instrument: c.instrument, size: 32),
                            title: Text(displayLabel(context, c.instrument.nameKey), style: TextStyle(color: colors.textPrimary)),
                            subtitle: Text(l10n.ledgerRealised, style: TextStyle(color: colors.textTertiary, fontSize: 12)),
                            trailing: Text(
                              Masking.signedAmount(c.realised, hidden: hidden, isUp: c.realised.amount >= 0),
                              style: TextStyle(
                                color: QimaColors.trendColor(c.realised.amount >= 0, colors),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            onTap: () => openHolding(c.instrument),
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

/// The past month in a sentence (v4 phase 3), when turned on in Settings.
/// Shows the template sentence at once; with the on-device model on, swaps
/// in its wording once that passes `acceptPhrasing` (phase 6).
class _SummaryCard extends StatefulWidget {
  final String sentence;
  final bool hidden;

  const _SummaryCard({required this.sentence, required this.hidden});

  @override
  State<_SummaryCard> createState() => _SummaryCardState();
}

class _SummaryCardState extends State<_SummaryCard> {
  String? _phrased;
  String? _for;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _phrase();
  }

  @override
  void didUpdateWidget(covariant _SummaryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _phrase();
  }

  void _phrase() {
    // Masked sentences have nothing to word better.
    final cubit = context.read<AppCubit>();
    // Turning the model on or off words the same sentence again.
    final key = '${cubit.state.onDeviceModel}|${widget.sentence}';
    if (widget.hidden || key == _for) return;
    _for = key;
    _phrased = null;
    cubit.phrased(widget.sentence, Localizations.localeOf(context).toLanguageTag()).then((value) {
      if (mounted && _for == key) setState(() => _phrased = value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final sentence = widget.hidden ? widget.sentence : (_phrased ?? widget.sentence);
    return DSCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.summaryTitle, style: TextStyle(color: colors.textTertiary, fontSize: 12)),
          const SizedBox(height: DS.space2XS),
          Text(sentence, style: TextStyle(color: colors.textPrimary, fontSize: 15, height: 1.4)),
        ],
      ),
    );
  }
}

/// Split by group (v3, Figma "Portfolio · value over time" allocation
/// card); the card opens the full allocation detail.
class _AllocationCard extends StatelessWidget {
  final List<AllocationShare<AssetGroup>> groups;
  final bool hidden;

  const _AllocationCard({required this.groups, required this.hidden});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    return DSCard(
      child: InkWell(
        borderRadius: BorderRadius.circular(DS.radiusCard),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AllocationScreen())),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.allocationTitle.toUpperCase(),
                    style: DS.overline(context, color: colors.textTertiary, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
                Text(l10n.allocationDetails, style: TextStyle(color: colors.brandText, fontSize: 13)),
                Icon(Icons.chevron_right, size: 18, color: colors.brandText),
              ],
            ),
            const SizedBox(height: DS.spaceSM),
            // A single group would only repeat the total above at 100%;
            // the card stays as the way into the karat breakdown.
            if (groups.length == 1)
              Text(
                l10n.allocationSingleGroup(assetGroupLabel(l10n, groups.single.key)),
                style: TextStyle(color: colors.textSecondary),
              )
            else
              groupBars(context, groups, hidden: hidden),
          ],
        ),
      ),
    );
  }
}

/// One-line doorway to the zakat screen under the portfolio hero (v3):
/// what's due when above nisab, otherwise where the user stands.
class _ZakatEntry extends StatelessWidget {
  final ZakatAssessment assessment;
  final bool hidden;

  const _ZakatEntry({required this.assessment, required this.hidden});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final String subtitle;
    switch (assessment.status) {
      case NisabStatus.above:
        subtitle = l10n.zakatEntryDue(Masking.amount(assessment.due, hidden: hidden));
      case NisabStatus.below:
        subtitle = l10n.zakatStatusBelow;
      case NisabStatus.thresholdUnknown:
      case NisabStatus.noHoldings:
        subtitle = l10n.zakatEntryCalculate;
    }
    return DSCard(
      padding: EdgeInsets.zero,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: DS.spaceMD, vertical: 2),
        leading: Icon(Icons.volunteer_activism_outlined, color: colors.brandText),
        title: Text(l10n.zakatTitle, style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: TextStyle(color: colors.textTertiary, fontSize: 12)),
        trailing: Icon(Icons.chevron_right, color: colors.textTertiary),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ZakatScreen())),
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
                        '${l10n.portfolioTransactionCount(held.transactionCount)} · $weightPercent%',
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
