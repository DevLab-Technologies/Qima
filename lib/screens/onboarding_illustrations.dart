import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/display_point.dart';
import '../theme/design_system.dart';
import '../theme/price_chart.dart';
import '../theme/qima_colors.dart';

/// Static (non-interactive, offline) sample series used only to draw the
/// onboarding illustrations' sparklines/charts — never real price data, and
/// never fetched, so the tour renders identically on a brand-new install
/// before any quote has loaded.
List<DisplayPoint> _sampleSeries(List<double> values) {
  final now = DateTime.now();
  return [
    for (var i = 0; i < values.length; i++)
      DisplayPoint(date: now.subtract(Duration(days: values.length - i)), value: values[i]),
  ];
}

/// Step 1 (Welcome) illustration: the real app icon over a mini portfolio
/// hero card, echoing the Figma frame's "everything in one number" framing.
class WelcomeIllustration extends StatelessWidget {
  const WelcomeIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final series = _sampleSeries(const [38200, 39100, 38700, 40650, 41800, 43950, 45220, 48215]);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(DS.radiusCard),
          child: Image.asset('assets/icon/app_icon.png', width: 88, height: 88, fit: BoxFit.cover),
        ),
        const SizedBox(height: DS.spaceLG),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (final color in [colors.accentGold, colors.accentSilver, colors.accentCrypto, colors.accentStock, colors.accentIndex, colors.accentFiat])
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: CircleAvatar(radius: 14, backgroundColor: color),
              ),
          ],
        ),
        const SizedBox(height: DS.spaceLG),
        DSHeroCard(
          accent: colors.brand,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.portfolioTitle, style: TextStyle(color: colors.textTertiary, fontSize: 12)),
              const SizedBox(height: 4),
              Text('\$48,215.60', style: TextStyle(color: colors.textPrimary, fontSize: 26, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text('+\$2,909.30 · +6.42%', style: TextStyle(color: colors.up, fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: DS.spaceSM),
              SizedBox(
                height: 80,
                child: PriceChartView(points: series, isTrendingUp: true, accent: colors.brand, showsAxes: false),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Step 2 (Watchlist) illustration: a mini watchlist card with a sparkline,
/// echoing the real `InstrumentRow`.
class WatchlistIllustration extends StatelessWidget {
  const WatchlistIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final rows = [
      (l10n.assetGold, colors.accentGold, Icons.hexagon, '\$3,742.18', '+0.84%', true, const <double>[3680, 3700, 3690, 3715, 3730, 3742]),
      (l10n.assetSilver, colors.accentSilver, Icons.hexagon, '\$44.12', '-0.62%', false, const <double>[45, 44.7, 44.9, 44.5, 44.3, 44.12]),
      (l10n.assetBitcoin, colors.accentCrypto, Icons.currency_bitcoin, '\$112,480.00', '+2.31%', true, const <double>[107000, 108500, 109800, 110900, 111600, 112480]),
    ];

    return DSCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) Divider(color: colors.hairline, height: DS.spaceLG),
            _WatchRow(
              accent: rows[i].$2,
              icon: rows[i].$3,
              name: rows[i].$1,
              price: rows[i].$4,
              change: rows[i].$5,
              isUp: rows[i].$6,
              series: _sampleSeries(rows[i].$7),
            ),
          ],
        ],
      ),
    );
  }
}

class _WatchRow extends StatelessWidget {
  final Color accent;
  final IconData icon;
  final String name;
  final String price;
  final String change;
  final bool isUp;
  final List<DisplayPoint> series;

  const _WatchRow({
    required this.accent,
    required this.icon,
    required this.name,
    required this.price,
    required this.change,
    required this.isUp,
    required this.series,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        CircleAvatar(radius: 16, backgroundColor: accent, child: Icon(icon, color: colors.onBrand, size: 16)),
        const SizedBox(width: DS.spaceSM),
        Expanded(
          flex: 3,
          child: Text(
            name,
            style: TextStyle(color: colors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: DS.spaceSM),
        SizedBox(
          width: 44,
          height: 28,
          child: PriceChartView(points: series, isTrendingUp: isUp, accent: isUp ? colors.up : colors.down, showsAxes: false),
        ),
        const SizedBox(width: DS.spaceSM),
        Expanded(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: TextStyle(color: colors.textPrimary, fontSize: 13, fontWeight: FontWeight.w700),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                change,
                style: TextStyle(color: isUp ? colors.up : colors.down, fontSize: 11),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Step 3 (Holdings) illustration: a lot row plus a small summary strip,
/// echoing `HoldingsScreen`'s lot list.
class HoldingsIllustration extends StatelessWidget {
  const HoldingsIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;

    return DSCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: _stat(context, l10n.detailHoldings, '2.5 oz t')),
              Expanded(child: _stat(context, l10n.holdingsGain, '+\$1,240', valueColor: colors.up)),
            ],
          ),
          const SizedBox(height: DS.spaceMD),
          Divider(color: colors.hairline),
          const SizedBox(height: DS.spaceMD),
          _lotRow(context, '1.5 oz t · 24K', '\$1,900.00', DateTime.now().subtract(const Duration(days: 45))),
          const SizedBox(height: DS.spaceSM),
          _lotRow(context, '1.0 oz t · 22K', '\$1,975.00', DateTime.now().subtract(const Duration(days: 12))),
        ],
      ),
    );
  }

  Widget _stat(BuildContext context, String label, String value, {Color? valueColor}) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: colors.textTertiary, fontSize: 12)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(color: valueColor ?? colors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _lotRow(BuildContext context, String quantity, String unitCost, DateTime date) {
    final colors = context.colors;
    return DSTile(
      child: Row(
        children: [
          Icon(Icons.receipt_long_outlined, color: colors.textTertiary, size: 18),
          const SizedBox(width: DS.spaceSM),
          Expanded(
            child: Text(quantity, style: TextStyle(color: colors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
          ),
          Text(unitCost, style: TextStyle(color: colors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }
}

/// Step 4 (Alerts & widgets) illustration: an alert bell row plus a
/// portfolio widget tile, echoing `AlertsCard` and the Home Screen widget.
class AlertsWidgetsIllustration extends StatelessWidget {
  const AlertsWidgetsIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DSCard(
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: colors.brand.withValues(alpha: 0.18), shape: BoxShape.circle),
                child: Icon(Icons.notifications_active, color: colors.brandText, size: 20),
              ),
              const SizedBox(width: DS.spaceSM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.assetGold, style: TextStyle(color: colors.textPrimary, fontSize: 14, fontWeight: FontWeight.w700)),
                    Text('Above \$3,800.00', style: TextStyle(color: colors.textTertiary, fontSize: 12)),
                  ],
                ),
              ),
              Switch(value: true, onChanged: null, activeThumbColor: colors.onBrand, activeTrackColor: colors.brand),
            ],
          ),
        ),
        const SizedBox(height: DS.spaceMD),
        DSHeroCard(
          accent: colors.brand,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.widgets_outlined, color: colors.brandText, size: 18),
                  const SizedBox(width: DS.spaceXS),
                  Text(l10n.portfolioTitle, style: TextStyle(color: colors.textSecondary, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 4),
              Text('\$48,215.60', style: TextStyle(color: colors.textPrimary, fontSize: 20, fontWeight: FontWeight.w800)),
              Text('+6.42% · All time', style: TextStyle(color: colors.up, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }
}
