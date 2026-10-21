import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/app_cubit.dart';
import '../blocs/app_state.dart';
import '../l10n/app_localizations.dart';
import '../models/asset.dart';
import '../models/hijri_date.dart';
import '../models/holding_totals.dart';
import '../models/metal_breakdown.dart';
import '../models/zakat.dart';
import '../theme/design_system.dart';
import '../theme/help_topics.dart';
import '../theme/masking.dart';
import '../theme/qima_colors.dart';
import '../theme/strings.dart';
import '../widgets/help_button.dart';
import '../widgets/section_header.dart';
import '../widgets/instrument_icon.dart';
import 'hawl_date_picker.dart';
import 'holdings_screen.dart';
import 'zakat_settings_screen.dart';

/// Zakat overview (v3, Figma "Zakat · Overview"): the amount due at 2.5%,
/// today's nisab and where the user stands against it, their hawl, and the
/// list of held assets with what counts and why.
///
/// Recomputed on every state change from the live holdings and prices —
/// nothing here is stored except the user's [ZakatSettings].
class ZakatScreen extends StatefulWidget {
  const ZakatScreen({super.key});

  @override
  State<ZakatScreen> createState() => _ZakatScreenState();
}

class _ZakatScreenState extends State<ZakatScreen> {
  @override
  void initState() {
    super.initState();
    // The nisab needs gold and silver prices even if the user tracks
    // neither.
    context.read<AppCubit>().ensureNisabPrices();
  }

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
          title: Text(l10n.zakatTitle),
          actions: [
            const HelpButton(topic: HelpTopicId.zakat),
            IconButton(
              icon: const Icon(Icons.tune),
              tooltip: l10n.zakatSettingsTitle,
              onPressed: () =>
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ZakatSettingsScreen())),
            ),
          ],
        ),
        body: BlocBuilder<AppCubit, AppState>(
          builder: (context, state) {
            final assessment = cubit.zakatAssessment;
            final schedule = HawlSchedule.of(state.zakatSettings, DateTime.now());
            final hidden = state.hideBalances;

            if (assessment.status == NisabStatus.noHoldings) {
              return ListView(
                padding: const EdgeInsets.all(DS.spaceMD),
                children: [
                  DSCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.volunteer_activism_outlined, color: colors.brandText, size: 32),
                        const SizedBox(height: DS.spaceSM),
                        Text(l10n.zakatEmptyTitle,
                            style: TextStyle(color: colors.textPrimary, fontSize: 17, fontWeight: FontWeight.w700)),
                        const SizedBox(height: DS.spaceXS),
                        Text(l10n.zakatEmptyMessage, style: TextStyle(color: colors.textSecondary)),
                      ],
                    ),
                  ),
                  const SizedBox(height: DS.spaceLG),
                  const _Disclaimer(),
                ],
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                await cubit.refreshAll();
                await cubit.ensureNisabPrices();
              },
              child: ListView(
                padding: const EdgeInsets.all(DS.spaceMD),
                children: [
                  _DueHero(assessment: assessment, schedule: schedule, hidden: hidden),
                  const SizedBox(height: DS.spaceLG),
                  SectionHeader(l10n.zakatNisabSection),
                  _NisabCard(assessment: assessment, settings: state.zakatSettings, schedule: schedule, hidden: hidden),
                  const SizedBox(height: DS.spaceLG),
                  SectionHeader(l10n.zakatWhatCountsSection),
                  _WhatCountsCard(assessment: assessment, hidden: hidden),
                  const SizedBox(height: DS.spaceLG),
                  const _Disclaimer(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DueHero extends StatelessWidget {
  final ZakatAssessment assessment;
  final HawlSchedule? schedule;
  final bool hidden;

  const _DueHero({required this.assessment, required this.schedule, required this.hidden});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final base = Masking.amount(assessment.base, hidden: hidden);

    final String statusLabel;
    final Color statusColor;
    switch (assessment.status) {
      case NisabStatus.above:
        statusLabel = l10n.zakatStatusAbove;
        statusColor = colors.up;
      case NisabStatus.below:
        statusLabel = l10n.zakatStatusBelow;
        statusColor = colors.textSecondary;
      case NisabStatus.thresholdUnknown:
      case NisabStatus.noHoldings:
        statusLabel = l10n.zakatStatusUnknown;
        statusColor = colors.textTertiary;
    }

    final String explanation;
    switch (assessment.status) {
      case NisabStatus.above:
        final s = schedule;
        if (s == null) {
          explanation = l10n.zakatExplainAboveNoHawl(base);
        } else if (s.completesToday) {
          explanation = l10n.zakatExplainAboveToday(base);
        } else {
          explanation = l10n.zakatExplainAboveUpcoming(
              base, dateWithYear(context, s.next), s.daysUntilNext);
        }
      case NisabStatus.below:
        explanation = l10n.zakatExplainBelow(base, Masking.amount(assessment.threshold!, hidden: false));
      case NisabStatus.thresholdUnknown:
      case NisabStatus.noHoldings:
        explanation = l10n.zakatExplainUnknown(displayLabel(context, _metalNameKey(assessment.basis)));
    }

    return DSHeroCard(
      accent: colors.brand,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: DS.spaceSM, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(DS.radiusPill),
            ),
            child: Text(statusLabel, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: DS.spaceSM),
          Text(l10n.zakatDueLabel(percentLabel(context, ZakatAssessment.rate * 100)).toUpperCase(),
              style: TextStyle(color: colors.textTertiary, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              Masking.amount(assessment.due, hidden: hidden),
              maxLines: 1,
              style: TextStyle(color: colors.textPrimary, fontSize: 32, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: DS.spaceXS),
          Text(explanation, style: TextStyle(color: colors.textSecondary, fontSize: 13)),
          if (assessment.status == NisabStatus.thresholdUnknown) ...[
            const SizedBox(height: DS.spaceSM),
            OutlinedButton.icon(
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(l10n.zakatRetry),
              onPressed: () => context.read<AppCubit>().ensureNisabPrices(),
            ),
          ],
          if (assessment.hasUnpricedHoldings) ...[
            const SizedBox(height: DS.spaceSM),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 16, color: colors.textTertiary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(l10n.zakatUnpricedNote, style: TextStyle(color: colors.textTertiary, fontSize: 12)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _NisabCard extends StatelessWidget {
  final ZakatAssessment assessment;
  final ZakatSettings settings;
  final HawlSchedule? schedule;
  final bool hidden;

  const _NisabCard({required this.assessment, required this.settings, required this.schedule, required this.hidden});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AppCubit>();
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final basis = assessment.basis;
    final other = assessment.otherThreshold;
    final threshold = assessment.threshold;
    final start = settings.hawlStart;
    String dateFormat(DateTime d) => dateWithYear(context, d);

    // A long Hijri date ("12 Rabi al-Awwal 1446 AH") must wrap rather than
    // squeeze the title, so this is a Row, not a ListTile trailing.
    Widget row(String title, String value,
        {String? subtitle, VoidCallback? onTap, Color? valueColor, bool stacked = false}) {
      final valueStyle = TextStyle(color: valueColor ?? colors.textSecondary, fontWeight: FontWeight.w600);
      if (stacked) {
        return InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: DS.spaceSM),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: TextStyle(color: colors.textPrimary, fontSize: 15)),
                      Text(value, style: valueStyle),
                      if (subtitle != null)
                        Text(subtitle, style: TextStyle(color: colors.textTertiary, fontSize: 12)),
                    ],
                  ),
                ),
                if (onTap != null) Icon(Icons.chevron_right, size: 18, color: colors.textTertiary),
              ],
            ),
          ),
        );
      }
      return InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: DS.spaceSM),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(color: colors.textPrimary, fontSize: 15)),
                    if (subtitle != null)
                      Text(subtitle, style: TextStyle(color: colors.textTertiary, fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(width: DS.spaceSM),
              Flexible(
                flex: 2,
                child: Text(value, textAlign: TextAlign.end, style: valueStyle),
              ),
              if (onTap != null) Icon(Icons.chevron_right, size: 18, color: colors.textTertiary),
            ],
          ),
        ),
      );
    }

    final hijriStart = start == null ? null : HijriDate.fromGregorian(start);
    final String hawlValue;
    final String? hawlSubtitle;
    if (start == null) {
      hawlValue = l10n.zakatHawlSet;
      hawlSubtitle = l10n.zakatHawlNotSetSubtitle;
    } else if (settings.calendar == HawlCalendar.hijri && hijriStart != null) {
      hawlValue = hijriDateLabel(l10n, hijriStart);
      hawlSubtitle = _hawlNextLine(l10n, dateFormat, dateFormat(start));
    } else {
      hawlValue = dateFormat(start);
      hawlSubtitle = _hawlNextLine(l10n, dateFormat, hijriStart == null ? null : hijriDateLabel(l10n, hijriStart));
    }

    return DSCard(
      child: Column(
        children: [
          row(
            l10n.zakatBasisRow,
            l10n.zakatBasisValue(displayLabel(context, _metalNameKey(basis)), _grams(basis.fineGrams)),
            subtitle: other == null
                ? null
                : l10n.zakatOtherBasisLine(
                    displayLabel(context, _metalNameKey(basis.other)), Masking.amount(other, hidden: false)),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ZakatSettingsScreen())),
          ),
          Divider(color: colors.hairline, height: 1),
          row(l10n.zakatThresholdToday, threshold == null ? '—' : Masking.amount(threshold, hidden: false)),
          Divider(color: colors.hairline, height: 1),
          row(
            l10n.zakatYourBase,
            Masking.amount(assessment.base, hidden: hidden),
            valueColor: assessment.status == NisabStatus.above ? colors.up : null,
          ),
          Divider(color: colors.hairline, height: 1),
          row(
            l10n.zakatHawlStart,
            hawlValue,
            subtitle: hawlSubtitle,
            stacked: true,
            valueColor: start == null ? colors.brandText : null,
            onTap: () async {
              final picked = await pickHawlStart(context, calendar: settings.calendar, initial: start);
              if (picked != null) await cubit.updateZakatSettings((s) => s.copyWith(hawlStart: picked));
            },
          ),
        ],
      ),
    );
  }

  /// "2 Mar 2026 · next completes 19 Feb 2027" — the start in the other
  /// calendar, then the upcoming completion.
  String? _hawlNextLine(AppLocalizations l10n, String Function(DateTime) format, String? otherCalendar) {
    final s = schedule;
    final parts = <String>[
      ?otherCalendar,
      if (s != null) s.completesToday ? l10n.zakatHawlCompletesToday : l10n.zakatHawlNext(format(s.next)),
    ];
    return parts.isEmpty ? null : parts.join(' · ');
  }
}

class _WhatCountsCard extends StatelessWidget {
  final ZakatAssessment assessment;
  final bool hidden;

  const _WhatCountsCard({required this.assessment, required this.hidden});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AppCubit>();
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return DSCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < assessment.lines.length; i++) ...[
            if (i > 0) Divider(color: colors.hairline, height: 1),
            _LineRow(
              line: assessment.lines[i],
              hidden: hidden,
              onToggle: () => cubit.updateZakatSettings((s) => s.toggleHolding(assessment.lines[i].instrument)),
            ),
          ],
          const SizedBox(height: DS.spaceXS),
          Text(l10n.zakatWhatCountsFooter, style: TextStyle(color: colors.textTertiary, fontSize: 12)),
        ],
      ),
    );
  }
}

class _LineRow extends StatelessWidget {
  final ZakatLine line;
  final bool hidden;
  final VoidCallback onToggle;

  const _LineRow({required this.line, required this.hidden, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final instrument = line.instrument;
    final unit = instrument.quotation.defaultUnit == PriceUnit.troyOunce ? PriceUnit.gram : instrument.quotation.defaultUnit;
    final held = HoldingTotals.totalHeld(lots: line.lots, refUnit: unit);
    // Gold counts by fine content, so its total reads as 24K grams.
    final karat = instrument.supportedKarats.isNotEmpty ? GoldKarat.k24 : null;
    final quantity = hidden ? Masking.mask : quantityWithUnitKaratLabel(context, held, unit, karat);
    final name = displayLabel(context, instrument.nameKey);

    final String? reason;
    switch (line.exclusion) {
      case ZakatExclusion.classOff:
        reason = l10n.zakatExcludedClass(assetGroupLabel(l10n, line.assetGroup));
      case ZakatExclusion.holdingOff:
        reason = l10n.zakatExcludedHolding;
      case ZakatExclusion.noPrice:
        reason = l10n.zakatExcludedNoPrice;
      case null:
        reason = null;
    }
    final value = line.value;
    final valueText = value == null ? '—' : Masking.amount(value, hidden: hidden);

    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      secondary: InstrumentIcon(instrument: instrument, size: 32),
      title: Text(l10n.zakatLineTitle(name, quantity), style: TextStyle(color: colors.textPrimary)),
      // Only a value that's been left out is struck through, never the
      // reason next to it.
      subtitle: Text.rich(
        TextSpan(
          style: TextStyle(color: line.counts ? colors.textSecondary : colors.textTertiary, fontSize: 12),
          children: [
            TextSpan(
              text: valueText,
              style: TextStyle(decoration: line.counts || value == null ? null : TextDecoration.lineThrough),
            ),
            if (reason != null) TextSpan(text: ' · $reason'),
          ],
        ),
      ),
      // An unpriced asset that's included still shows "on": it will count
      // as soon as its price loads.
      value: line.exclusion != ZakatExclusion.classOff && line.exclusion != ZakatExclusion.holdingOff,
      activeThumbColor: colors.onBrand,
      activeTrackColor: colors.brand,
      onChanged: (_) => onToggle(),
    );
  }
}

class _Disclaimer extends StatelessWidget {
  const _Disclaimer();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.balance_outlined, size: 16, color: colors.textTertiary),
        const SizedBox(width: 6),
        Expanded(child: Text(l10n.zakatDisclaimer, style: TextStyle(color: colors.textTertiary, fontSize: 12))),
      ],
    );
  }
}

String _metalNameKey(NisabBasis basis) => basis == NisabBasis.gold ? 'asset.gold' : 'asset.silver';

String _grams(double grams) => grams == grams.roundToDouble() ? grams.toStringAsFixed(0) : grams.toString();
