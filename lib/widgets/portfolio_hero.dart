import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/chart_range.dart';
import '../models/display_point.dart';
import '../models/holding.dart';
import '../models/money.dart';
import '../models/portfolio_history.dart';
import '../theme/design_system.dart';
import '../theme/price_chart.dart';
import '../theme/qima_colors.dart';
import '../theme/strings.dart';

/// Watchlist portfolio hero card: value, a brand-gold portfolio chart (never
/// trend-colored, per spec §v2-A), the range's gain-change headline, and
/// 1W/1M/3M/1Y/All range chips. Tapping anywhere outside the chip row opens
/// the full portfolio screen.
class PortfolioHero extends StatelessWidget {
  final HoldingValuation valuation;
  final List<PortfolioHistoryPoint> history;
  final PortfolioRangeChange? change;
  final ChartRange selectedRange;
  final ValueChanged<ChartRange> onSelectRange;
  final VoidCallback onTap;

  const PortfolioHero({
    super.key,
    required this.valuation,
    required this.history,
    required this.change,
    required this.selectedRange,
    required this.onSelectRange,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final points = history.map((p) => DisplayPoint(date: p.date, value: p.value)).toList();

    return DSHeroCard(
      accent: colors.brand,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DS.radiusCard),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.portfolioTitle, style: TextStyle(color: colors.textTertiary, fontSize: 12)),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  valuation.value.formatted(),
                  style: TextStyle(color: colors.textPrimary, fontSize: 28, fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 2),
            if (change != null)
              Row(
                children: [
                  Text(
                    '${signedFigure(_moneyDelta(context, change!.gainDelta, valuation.value.currencyCode), isUp: change!.isUp)} '
                    '· ${signedFigure('${(change!.percentValue * 100).toStringAsFixed(2)}%', isUp: change!.isUp)}',
                    style: TextStyle(color: QimaColors.trendColor(change!.isUp, colors), fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    displayLabel(context, selectedRange.labelKey),
                    style: TextStyle(color: colors.textTertiary, fontSize: 12),
                  ),
                ],
              )
            else
              Text(l10n.portfolioNoChange, style: TextStyle(color: colors.textTertiary, fontSize: 12)),
            const SizedBox(height: DS.spaceSM),
            SizedBox(
              height: 100,
              child: points.length >= 2
                  ? PriceChartView(
                      points: points,
                      isTrendingUp: change?.isUp ?? true,
                      accent: colors.brand,
                      lineColor: colors.brand,
                      showsAxes: false,
                      lineWidth: 2,
                    )
                  : Center(
                      child: Text(l10n.portfolioNoHistory, style: TextStyle(color: colors.textTertiary, fontSize: 12)),
                    ),
            ),
            const SizedBox(height: DS.spaceSM),
            // Stops taps on the chip row from bubbling up to the card's own
            // onTap (which would open the portfolio screen instead of just
            // switching ranges).
            GestureDetector(
              onTap: () {},
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final range in ChartRange.portfolioSelectable)
                      Padding(
                        padding: const EdgeInsets.only(right: DS.spaceXS),
                        child: DSChoiceChip(
                          label: displayLabel(context, range.labelKey),
                          selected: selectedRange == range,
                          onSelected: (_) => onSelectRange(range),
                          accent: colors.brand,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Reuses [Money]'s own magnitude formatting so the delta gets the same
  /// currency symbol/decimal rules as everywhere else; the sign is applied
  /// separately by [signedFigure], so the amount is passed through as its
  /// absolute value to avoid a redundant "-" prefix from Money too.
  String _moneyDelta(BuildContext context, double amount, String currencyCode) {
    return Money(amount.abs(), currencyCode).formatted();
  }
}
