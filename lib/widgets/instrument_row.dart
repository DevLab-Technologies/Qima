import 'package:flutter/material.dart';

import '../models/instrument_presentation.dart';
import '../theme/design_system.dart';
import '../theme/price_chart.dart';
import '../theme/strings.dart';
import 'instrument_icon.dart';

/// Watchlist row: icon, name/detail line, a small non-interactive sparkline,
/// and price + windowed change. Mirrors `InstrumentRow.swift`.
class InstrumentRow extends StatelessWidget {
  final InstrumentPresentation presentation;
  final VoidCallback? onTap;

  const InstrumentRow({super.key, required this.presentation, this.onTap});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final change = presentation.sparklineChange(now);
    final unitSuffix = presentation.unitSuffix != null ? ' ${displayLabel(context, presentation.unitSuffix!)}' : '';
    final karat = presentation.karatLabel != null ? ' · ${displayLabel(context, presentation.karatLabel!)}' : '';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DS.radiusTile),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: DS.spaceSM, horizontal: DS.spaceXS),
        child: Row(
          children: [
            InstrumentIcon(instrument: presentation.instrument),
            const SizedBox(width: DS.spaceSM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayLabel(context, presentation.instrument.nameKey),
                    style: const TextStyle(color: DS.textPrimary, fontSize: 15, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${presentation.symbol} · ${presentation.displayCurrency}$unitSuffix$karat',
                    style: const TextStyle(color: DS.textTertiary, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: DS.spaceSM),
            SizedBox(
              width: 64,
              height: 34,
              child: presentation.sparklinePoints(now).length >= 2
                  ? PriceChartView(
                      points: presentation.sparklinePoints(now),
                      isTrendingUp: change?.isUp ?? presentation.isTrendingUp,
                      accent: DS.trendColor(change?.isUp ?? presentation.isTrendingUp),
                      showsAxes: false,
                      lineWidth: 1.5,
                    )
                  : const SizedBox.shrink(),
            ),
            const SizedBox(width: DS.spaceSM),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  presentation.latestPrice,
                  style: const TextStyle(color: DS.textPrimary, fontSize: 15, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                if (change != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        change.isUp ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                        color: DS.trendColor(change.isUp),
                        size: 16,
                      ),
                      Text(
                        '${(change.percentValue.abs() * 100).toStringAsFixed(2)}%',
                        style: TextStyle(color: DS.trendColor(change.isUp), fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  )
                else
                  const Text('—', style: TextStyle(color: DS.textTertiary, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
