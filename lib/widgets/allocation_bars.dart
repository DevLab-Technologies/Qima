import 'package:flutter/material.dart';

import '../models/money.dart';
import '../theme/design_system.dart';
import '../theme/masking.dart';
import '../theme/qima_colors.dart';
import '../theme/strings.dart';

/// One row of an [AllocationBars] list.
class AllocationBar {
  final String label;
  final Money value;
  final double fraction;
  final Color color;

  const AllocationBar({required this.label, required this.value, required this.fraction, required this.color});
}

/// Labelled share bars (Figma "Allocation"): a colour dot, the label, the
/// amount and its percentage, then a thin bar filled to that share. Amounts
/// follow the hide-balances switch; percentages don't reveal wealth and
/// stay visible, as on the portfolio rows.
class AllocationBars extends StatelessWidget {
  final List<AllocationBar> bars;
  final bool hidden;

  const AllocationBars({super.key, required this.bars, required this.hidden});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < bars.length; i++) ...[
          if (i > 0) const SizedBox(height: DS.spaceSM),
          Row(
            children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: bars[i].color, shape: BoxShape.circle)),
              const SizedBox(width: DS.spaceXS),
              Expanded(
                child: Text(bars[i].label,
                    maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: colors.textPrimary)),
              ),
              Text(
                Masking.amount(bars[i].value, hidden: hidden),
                style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: DS.spaceXS),
              SizedBox(
                width: 44,
                child: Text(
                  percentLabel(context, (bars[i].fraction * 100).roundToDouble()),
                  textAlign: TextAlign.end,
                  style: TextStyle(color: colors.textTertiary, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(DS.radiusPill),
            child: LinearProgressIndicator(
              value: bars[i].fraction.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: colors.hairline,
              valueColor: AlwaysStoppedAnimation(bars[i].color),
            ),
          ),
        ],
      ],
    );
  }
}
