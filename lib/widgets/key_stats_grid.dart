import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/display_point.dart';
import '../theme/design_system.dart';
import '../theme/qima_colors.dart';
import '../theme/strings.dart';
import 'stat_pill.dart';

/// "Key stats" 2x2 grid on the instrument detail screen: Change, Points,
/// High, Low for the currently-selected range (spec §v2-A "Instrument
/// detail").
class KeyStatsGrid extends StatelessWidget {
  final List<DisplayPoint> windowed;
  final double? changePercent;
  final bool? changeIsUp;

  const KeyStatsGrid({super.key, required this.windowed, required this.changePercent, required this.changeIsUp});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final high = windowed.isEmpty ? null : windowed.map((p) => p.value).reduce((a, b) => a > b ? a : b);
    final low = windowed.isEmpty ? null : windowed.map((p) => p.value).reduce((a, b) => a < b ? a : b);

    return DSCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.detailKeyStats, style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w700)),
          const SizedBox(height: DS.spaceSM),
          GridView(
            shrinkWrap: true,
            // Without this the grid inherits the screen's safe-area inset as
            // bottom padding, leaving an empty band at the foot of the card.
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              // Room for Arabic's taller small text (Almarai) as well as SF.
              mainAxisExtent: 52,
              mainAxisSpacing: DS.spaceSM,
              crossAxisSpacing: DS.spaceMD,
            ),
            children: [
              StatPill(
                title: l10n.statChange,
                value: changePercent == null
                    ? '—'
                    : signedFigure('${(changePercent! * 100).toStringAsFixed(2)}%', isUp: changeIsUp ?? true),
                tint: changePercent == null ? null : QimaColors.trendColor(changeIsUp ?? true, colors),
              ),
              StatPill(title: l10n.statPoints, value: '${windowed.length}'),
              StatPill(title: l10n.statHigh, value: high?.toStringAsFixed(2) ?? '—'),
              StatPill(title: l10n.statLow, value: low?.toStringAsFixed(2) ?? '—'),
            ],
          ),
        ],
      ),
    );
  }
}
