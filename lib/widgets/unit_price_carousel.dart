import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/metal_breakdown.dart';
import '../theme/design_system.dart';
import '../theme/qima_colors.dart';
import '../theme/strings.dart';

/// "Price per unit" horizontal carousel for metals: troy ounce, kilogram and
/// per-karat (or plain) gram tiles from [InstrumentPresentation.metalBreakdown]
/// (spec §v2-A "Instrument detail"). Empty (and hidden by the caller) for
/// non-metal instruments.
class UnitPriceCarousel extends StatelessWidget {
  final List<MetalBreakdownRow> rows;

  const UnitPriceCarousel({super.key, required this.rows});

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return DSCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.detailPricePerUnit, style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w700)),
          const SizedBox(height: DS.spaceSM),
          SizedBox(
            height: 66,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: rows.length,
              separatorBuilder: (context, index) => const SizedBox(width: DS.spaceXS),
              itemBuilder: (context, index) {
                final row = rows[index];
                return SizedBox(
                  width: 118,
                  child: DSTile(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          displayLabel(context, row.label),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: colors.textTertiary, fontSize: 11),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          row.value,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
