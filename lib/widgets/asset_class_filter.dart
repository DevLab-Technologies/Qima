import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/asset.dart';
import '../theme/design_system.dart';
import '../theme/qima_colors.dart';
import '../theme/strings.dart';

/// Watchlist asset-class filter chips: "All" plus one chip per class
/// actually present in the current watchlist (spec §v2-A "Watchlist") — a
/// class with nothing tracked never shows an empty chip.
class AssetClassFilter extends StatelessWidget {
  final Set<AssetClass> availableClasses;
  final AssetClass? selected;
  final ValueChanged<AssetClass?> onSelected;

  const AssetClassFilter({
    super.key,
    required this.availableClasses,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (availableClasses.length <= 1) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    // Stable, deliberate ordering rather than whatever order they first
    // appeared in the watchlist.
    const order = [AssetClass.metal, AssetClass.crypto, AssetClass.stock, AssetClass.indices, AssetClass.fiat];
    final ordered = order.where(availableClasses.contains).toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: DS.spaceXS),
            child: DSChoiceChip(
              label: l10n.watchlistFilterAll,
              selected: selected == null,
              onSelected: (_) => onSelected(null),
              accent: colors.brand,
            ),
          ),
          for (final assetClass in ordered)
            Padding(
              padding: const EdgeInsets.only(right: DS.spaceXS),
              child: DSChoiceChip(
                label: displayLabel(context, assetClass.titleKey),
                selected: selected == assetClass,
                onSelected: (_) => onSelected(assetClass),
                accent: colors.brand,
              ),
            ),
        ],
      ),
    );
  }
}
