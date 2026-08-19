import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/app_cubit.dart';
import '../l10n/app_localizations.dart';
import '../models/asset.dart';
import '../models/holding.dart';
import '../models/money.dart';
import '../theme/design_system.dart';
import '../theme/strings.dart';
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

    return DSCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(l10n.detailHoldings, style: const TextStyle(color: DS.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: DS.textPrimary),
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
                style: const TextStyle(color: DS.textTertiary),
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
    final gainPercent = (valuation.gainFraction * 100).toStringAsFixed(2);
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2.6,
      mainAxisSpacing: DS.spaceXS,
      crossAxisSpacing: DS.spaceXS,
      children: [
        _metric(l10n.holdingsValue, valuation.value.formatted()),
        _metric(l10n.holdingsCost, valuation.cost.formatted()),
        _metric(l10n.holdingsGain, valuation.gain.formatted(), tint: DS.trendColor(valuation.isUp)),
        _metric(l10n.holdingsGainPercent, '${valuation.isUp ? '+' : ''}$gainPercent%', tint: DS.trendColor(valuation.isUp)),
      ],
    );
  }

  Widget _metric(String label, String value, {Color? tint}) {
    return DSTile(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label.toUpperCase(), style: const TextStyle(color: DS.textTertiary, fontSize: 10)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(color: tint ?? DS.textPrimary, fontSize: 14, fontWeight: FontWeight.w700)),
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
    final unitSuffix = lot.unit.abbreviationKey != null ? ' ${displayLabel(context, lot.unit.abbreviationKey!)}' : '';
    final qtyText = '${_formatQty(lot.quantity)}$unitSuffix';
    return Dismissible(
      key: ValueKey(lot.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: DS.spaceMD),
        child: const Icon(Icons.delete, color: DS.down),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        onTap: onTap,
        title: Text(qtyText, style: const TextStyle(color: DS.textPrimary)),
        subtitle: Text(
          '${Money(lot.unitCost, lot.costCurrency).formatted()} · ${lot.date.year}-${lot.date.month.toString().padLeft(2, '0')}-${lot.date.day.toString().padLeft(2, '0')}',
          style: const TextStyle(color: DS.textTertiary, fontSize: 12),
        ),
        trailing: Text(
          Money(lot.totalCost, lot.costCurrency).formatted(),
          style: const TextStyle(color: DS.textSecondary),
        ),
      ),
    );
  }

  String _formatQty(double value) {
    var text = value.toStringAsFixed(4);
    while (text.endsWith('0')) {
      text = text.substring(0, text.length - 1);
    }
    if (text.endsWith('.')) text = text.substring(0, text.length - 1);
    return text;
  }
}
