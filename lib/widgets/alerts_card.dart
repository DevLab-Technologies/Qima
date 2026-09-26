import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/app_cubit.dart';
import '../blocs/app_state.dart';
import '../l10n/app_localizations.dart';
import '../models/price_alert.dart';
import '../models/watch_card.dart';
import '../screens/alert_editor_sheet.dart';
import '../theme/design_system.dart';
import '../theme/qima_colors.dart';
import '../theme/strings.dart';

/// "Alerts" card on the instrument detail screen (spec Phase 5, Figma
/// "Instrument detail · Alerts card"): lists this card's alerts with a short
/// human-readable summary and an enable switch each, plus a "+ Add alert"
/// row. Tapping a row opens [AlertEditorSheet] to edit it.
class AlertsCard extends StatelessWidget {
  final WatchCard card;

  const AlertsCard({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AppCubit>();
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return BlocBuilder<AppCubit, AppState>(
      buildWhen: (previous, current) => previous.alerts != current.alerts,
      builder: (context, state) {
        final alerts = cubit.alertsFor(card.id);
        return DSCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(
                    l10n.alertsCardTitle,
                    style: TextStyle(color: colors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.add_circle_outline, color: colors.brand),
                    tooltip: l10n.alertsCardAdd,
                    onPressed: () => AlertEditorSheet.show(context, card: card),
                  ),
                ],
              ),
              if (alerts.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: DS.spaceXS),
                  child: Text(l10n.alertsCardEmpty, style: TextStyle(color: colors.textTertiary)),
                )
              else
                for (final alert in alerts) _AlertRow(alert: alert, card: card),
            ],
          ),
        );
      },
    );
  }
}

class _AlertRow extends StatelessWidget {
  final PriceAlert alert;
  final WatchCard card;

  const _AlertRow({required this.alert, required this.card});

  String _summary(BuildContext context, AppCubit cubit) {
    final l10n = AppLocalizations.of(context)!;
    final converter = cubit.presentation(card).converter;
    switch (alert.kind) {
      case AlertKind.above:
        return '${l10n.alertKindAbove} ${converter.money(alert.target).formatted()}';
      case AlertKind.below:
        return '${l10n.alertKindBelow} ${converter.money(alert.target).formatted()}';
      case AlertKind.percentMove:
        final percent = (alert.percent * 100).toStringAsFixed(0);
        final direction = displayLabel(context, alert.direction.labelKey);
        final window = displayLabel(context, alert.window.labelKey);
        return '$direction $percent% · $window';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AppCubit>();
    final colors = context.colors;

    return InkWell(
      borderRadius: BorderRadius.circular(DS.radiusTile),
      onTap: () => AlertEditorSheet.show(context, card: card, existing: alert),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: DS.spaceXS),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _summary(context, cubit),
                style: TextStyle(
                  color: alert.enabled ? colors.textPrimary : colors.textTertiary,
                  fontSize: 14,
                ),
              ),
            ),
            Switch(
              value: alert.enabled,
              activeThumbColor: colors.onBrand,
              activeTrackColor: colors.brand,
              onChanged: (value) => cubit.setAlertEnabled(alert, value),
            ),
          ],
        ),
      ),
    );
  }
}
