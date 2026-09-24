import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/app_cubit.dart';
import '../l10n/app_localizations.dart';
import '../models/asset.dart';
import '../models/holding.dart';
import '../models/money.dart';
import '../theme/design_system.dart';
import '../theme/qima_colors.dart';
import '../theme/strings.dart';
import '../widgets/confirm_delete_dialog.dart';
import 'lot_editor_screen.dart';

/// Holdings summary + lot list for one instrument. Mirrors
/// `HoldingsCard.swift`.
class HoldingsCard extends StatelessWidget {
  final Instrument instrument;
  final String displayCurrency;

  const HoldingsCard({super.key, required this.instrument, required this.displayCurrency});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AppCubit>();
    final lots = cubit.lotsFor(instrument);
    final valuation = cubit.valuationFor(instrument, displayCurrency);
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return DSCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(l10n.detailHoldings, style: TextStyle(color: colors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.add_circle_outline, color: colors.textPrimary),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => LotEditorScreen(instrument: instrument, defaultCurrency: displayCurrency),
                  ),
                ),
              ),
            ],
          ),
          if (valuation == null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: DS.spaceMD),
              child: Text(
                l10n.holdingsEmpty,
                style: TextStyle(color: colors.textTertiary),
              ),
            )
          else ...[
            _SummaryGrid(valuation: valuation),
            const SizedBox(height: DS.spaceSM),
          ],
          for (final lot in lots)
            _LotTile(
              lot: lot,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => LotEditorScreen(
                    instrument: instrument,
                    defaultCurrency: displayCurrency,
                    existing: lot,
                  ),
                ),
              ),
              onDelete: () => cubit.deleteLot(lot),
            ),
        ],
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  final HoldingValuation valuation;

  const _SummaryGrid({required this.valuation});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final gainPercent = (valuation.gainFraction * 100).toStringAsFixed(2);
    // Fixed tile height: an aspect ratio made tiles balloon on tablets.
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 62,
        mainAxisSpacing: DS.spaceXS,
        crossAxisSpacing: DS.spaceXS,
      ),
      children: [
        _metric(colors, l10n.holdingsValue, valuation.value.formatted()),
        _metric(colors, l10n.holdingsCost, valuation.cost.formatted()),
        _metric(colors, l10n.holdingsGain, signedFigure(valuation.gain.formatted(), isUp: valuation.isUp),
            tint: QimaColors.trendColor(valuation.isUp, colors)),
        _metric(colors, l10n.holdingsGainPercent, signedFigure('$gainPercent%', isUp: valuation.isUp),
            tint: QimaColors.trendColor(valuation.isUp, colors)),
      ],
    );
  }

  Widget _metric(QimaColors colors, String label, String value, {Color? tint}) {
    return DSTile(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label.toUpperCase(), style: TextStyle(color: colors.textTertiary, fontSize: 10)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(color: tint ?? colors.textPrimary, fontSize: 14, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _LotTile extends StatelessWidget {
  final HoldingLot lot;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _LotTile({required this.lot, required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final qtyText = lotQuantityLabel(context, lot);
    final detailText = lotDetailLabel(lot);
    final l10n = AppLocalizations.of(context)!;
    return Dismissible(
      key: ValueKey(lot.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => confirmDelete(
        context,
        title: l10n.confirmDeleteLotTitle,
        message: l10n.confirmDeleteLotMessage('$qtyText · $detailText'),
        confirmLabel: l10n.commonDelete,
      ),
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: DS.spaceMD),
        child: Icon(Icons.delete, color: colors.down),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        onTap: onTap,
        title: Text(qtyText, style: TextStyle(color: colors.textPrimary)),
        subtitle: Text(
          detailText,
          style: TextStyle(color: colors.textTertiary, fontSize: 12),
        ),
        trailing: Text(
          Money(lot.totalCost, lot.costCurrency).formatted(),
          style: TextStyle(color: colors.textSecondary),
        ),
      ),
    );
  }
}

/// "5 oz t" — the lot's quantity with its unit, as shown in lot lists.
String lotQuantityLabel(BuildContext context, HoldingLot lot) {
  final unitSuffix = lot.unit.abbreviationKey != null ? ' ${displayLabel(context, lot.unit.abbreviationKey!)}' : '';
  return '${_formatQty(lot.quantity)}$unitSuffix';
}

/// "$3,120.00 · 2024-03-14" — the lot's unit cost and purchase date.
String lotDetailLabel(HoldingLot lot) =>
    '${Money(lot.unitCost, lot.costCurrency).formatted()} · ${lot.date.year}-${lot.date.month.toString().padLeft(2, '0')}-${lot.date.day.toString().padLeft(2, '0')}';

String _formatQty(double value) {
  var text = value.toStringAsFixed(4);
  while (text.endsWith('0')) {
    text = text.substring(0, text.length - 1);
  }
  if (text.endsWith('.')) text = text.substring(0, text.length - 1);
  return text;
}
