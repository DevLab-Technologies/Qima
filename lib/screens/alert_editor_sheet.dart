import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../blocs/app_cubit.dart';
import '../l10n/app_localizations.dart';
import '../models/money.dart';
import '../models/price_alert.dart';
import '../models/watch_card.dart';
import '../services/price_converter.dart';
import '../theme/design_system.dart';
import '../theme/qima_colors.dart';
import '../theme/strings.dart';
import '../widgets/confirm_delete_dialog.dart';

enum _AlertType { price, percent }

/// The "New alert" / "Edit alert" bottom sheet (spec Phase 5): Price vs %
/// move segmented control, a target field with the card's currency/unit
/// suffix and a live "distance from current price" helper for Price alerts,
/// direction/window/percent chips for % move alerts, a Repeat switch, and
/// Create/Save + Delete. Mirrors the Figma "v2 · Features · Price alerts"
/// spec.
///
/// Presented via [AlertEditorSheet.show] rather than instantiated directly,
/// so callers don't need to know it's a bottom sheet.
class AlertEditorSheet extends StatefulWidget {
  final WatchCard card;
  final PriceAlert? existing;

  const AlertEditorSheet({super.key, required this.card, this.existing});

  static Future<void> show(BuildContext context, {required WatchCard card, PriceAlert? existing}) {
    final colors = context.colors;
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.overlay,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(DS.radiusCard)),
      ),
      builder: (sheetContext) => AlertEditorSheet(card: card, existing: existing),
    );
  }

  @override
  State<AlertEditorSheet> createState() => _AlertEditorSheetState();
}

class _AlertEditorSheetState extends State<AlertEditorSheet> {
  late _AlertType _type;
  late AlertKind _priceKind;
  late final TextEditingController _targetController;
  late AlertDirection _direction;
  late AlertWindow _window;
  late double _percent;
  late bool _repeats;

  static const List<double> _percentChoices = [0.01, 0.02, 0.03, 0.05, 0.10];

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _type = existing?.kind == AlertKind.percentMove ? _AlertType.percent : _AlertType.price;
    _priceKind = existing != null && existing.kind != AlertKind.percentMove ? existing.kind : AlertKind.above;
    _targetController = TextEditingController(text: existing != null ? _trim(existing.target) : '');
    _direction = existing?.direction ?? AlertDirection.either;
    _window = existing?.window ?? AlertWindow.h24;
    _percent = existing != null && existing.percent > 0 ? existing.percent : 0.05;
    _repeats = existing?.repeats ?? false;
  }

  @override
  void dispose() {
    _targetController.dispose();
    super.dispose();
  }

  String _trim(double value) {
    if (value == value.roundToDouble()) return value.toStringAsFixed(0);
    return value.toString();
  }

  double _parse(String text) => double.tryParse(text.trim()) ?? 0;

  bool get _isValid => _type == _AlertType.percent || _parse(_targetController.text) > 0;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AppCubit>();
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final presentation = cubit.presentation(widget.card);
    final currentPrice = presentation.latestMoney;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: DS.spaceMD,
          right: DS.spaceMD,
          top: DS.spaceMD,
          bottom: DS.spaceMD + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _isEditing ? l10n.alertEditorEditTitle : l10n.alertEditorNewTitle,
                      style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w700, fontSize: 18),
                    ),
                  ),
                  if (_isEditing)
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: colors.down),
                      onPressed: () => _delete(context, cubit, l10n),
                    ),
                ],
              ),
              const SizedBox(height: DS.spaceSM),
              SegmentedButton<_AlertType>(
                segments: [
                  ButtonSegment(value: _AlertType.price, label: Text(l10n.alertEditorTypePrice)),
                  ButtonSegment(value: _AlertType.percent, label: Text(l10n.alertEditorTypePercent)),
                ],
                selected: {_type},
                onSelectionChanged: (s) => setState(() => _type = s.first),
                style: DS.segmentedButtonStyle(colors, colors.brand),
              ),
              const SizedBox(height: DS.spaceMD),
              if (_type == _AlertType.price)
                _priceForm(context, colors, l10n, presentation.converter, currentPrice)
              else
                _percentForm(context, colors, l10n, currentPrice),
              const SizedBox(height: DS.spaceMD),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.alertEditorRepeat, style: TextStyle(color: colors.textPrimary)),
                subtitle: Text(l10n.alertEditorRepeatFooter, style: TextStyle(color: colors.textTertiary, fontSize: 12)),
                value: _repeats,
                activeThumbColor: colors.onBrand,
                activeTrackColor: colors.brand,
                onChanged: (value) => setState(() => _repeats = value),
              ),
              const SizedBox(height: DS.spaceSM),
              FilledButton(
                onPressed: _isValid ? () => _save(context, cubit) : null,
                child: Text(_isEditing ? l10n.alertEditorSave : l10n.alertEditorCreate),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _priceForm(
    BuildContext context,
    QimaColors colors,
    AppLocalizations l10n,
    PriceConverter converter,
    Money? currentPrice,
  ) {
    final suffix = converter.unit.abbreviationKey == null ? null : displayLabel(context, converter.unit.abbreviationKey!);
    final target = _parse(_targetController.text);

    String? helper;
    if (currentPrice != null && currentPrice.amount != 0 && target > 0) {
      final delta = target - currentPrice.amount;
      final percent = (delta / currentPrice.amount * 100).abs().toStringAsFixed(2);
      final deltaMoney = Money(delta.abs(), converter.currencyCode).formatted();
      helper = delta >= 0
          ? l10n.alertEditorHelperAbove(deltaMoney, percent)
          : l10n.alertEditorHelperBelow(deltaMoney, percent);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentedButton<AlertKind>(
          segments: [
            ButtonSegment(value: AlertKind.above, label: Text(l10n.alertEditorGoesAbove)),
            ButtonSegment(value: AlertKind.below, label: Text(l10n.alertEditorGoesBelow)),
          ],
          selected: {_priceKind},
          onSelectionChanged: (s) => setState(() => _priceKind = s.first),
          style: DS.segmentedButtonStyle(colors, colors.brand),
        ),
        const SizedBox(height: DS.spaceSM),
        TextField(
          controller: _targetController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: TextStyle(color: colors.textPrimary),
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            labelText: l10n.alertEditorTargetLabel,
            labelStyle: TextStyle(color: colors.textTertiary),
            suffixText: suffix,
            filled: true,
            fillColor: colors.tileTop,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(DS.radiusTile), borderSide: BorderSide.none),
            errorText: _targetController.text.isNotEmpty && target <= 0 ? l10n.alertEditorTargetRequired : null,
          ),
        ),
        if (helper != null) ...[
          const SizedBox(height: 4),
          Text(helper, style: TextStyle(color: colors.textTertiary, fontSize: 12)),
        ],
      ],
    );
  }

  Widget _percentForm(BuildContext context, QimaColors colors, AppLocalizations l10n, Money? currentPrice) {
    String summary() {
      if (currentPrice == null || currentPrice.amount == 0) return '';
      final low = Money(currentPrice.amount * (1 - _percent), currentPrice.currencyCode).formatted();
      final high = Money(currentPrice.amount * (1 + _percent), currentPrice.currencyCode).formatted();
      switch (_direction) {
        case AlertDirection.up:
          return l10n.alertEditorPercentSummaryUp(high);
        case AlertDirection.down:
          return l10n.alertEditorPercentSummaryDown(low);
        case AlertDirection.either:
          return l10n.alertEditorPercentSummary(low, high);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.alertEditorDirection, style: TextStyle(color: colors.textSecondary, fontSize: 13)),
        const SizedBox(height: DS.spaceXS),
        SegmentedButton<AlertDirection>(
          segments: [
            ButtonSegment(value: AlertDirection.up, label: Text(l10n.alertDirectionUp)),
            ButtonSegment(value: AlertDirection.down, label: Text(l10n.alertDirectionDown)),
            ButtonSegment(value: AlertDirection.either, label: Text(l10n.alertDirectionEither)),
          ],
          selected: {_direction},
          onSelectionChanged: (s) => setState(() => _direction = s.first),
          style: DS.segmentedButtonStyle(colors, colors.brand),
        ),
        const SizedBox(height: DS.spaceSM),
        Wrap(
          spacing: DS.spaceXS,
          runSpacing: DS.spaceXS,
          children: [
            for (final choice in _percentChoices)
              DSChoiceChip(
                label: '${(choice * 100).toStringAsFixed(0)}%',
                selected: _percent == choice,
                onSelected: (_) => setState(() => _percent = choice),
              ),
          ],
        ),
        const SizedBox(height: DS.spaceSM),
        Text(l10n.alertEditorWindow, style: TextStyle(color: colors.textSecondary, fontSize: 13)),
        const SizedBox(height: DS.spaceXS),
        SegmentedButton<AlertWindow>(
          segments: [
            ButtonSegment(value: AlertWindow.h24, label: Text(l10n.alertWindowWithin24h)),
            ButtonSegment(value: AlertWindow.d7, label: Text(l10n.alertWindowWithin7d)),
          ],
          selected: {_window},
          onSelectionChanged: (s) => setState(() => _window = s.first),
          style: DS.segmentedButtonStyle(colors, colors.brand),
        ),
        const SizedBox(height: DS.spaceSM),
        Text(summary(), style: TextStyle(color: colors.textTertiary, fontSize: 12)),
      ],
    );
  }

  Future<void> _save(BuildContext context, AppCubit cubit) async {
    final navigator = Navigator.of(context);
    final alert = PriceAlert(
      id: widget.existing?.id ?? const Uuid().v4(),
      cardID: widget.card.id,
      kind: _type == _AlertType.price ? _priceKind : AlertKind.percentMove,
      target: _type == _AlertType.price ? _parse(_targetController.text) : 0,
      percent: _type == _AlertType.percent ? _percent : 0,
      direction: _direction,
      window: _window,
      repeats: _repeats,
      enabled: widget.existing?.enabled ?? true,
      createdAt: widget.existing?.createdAt ?? DateTime.now(),
    );
    await cubit.saveAlert(alert);
    // Ask for notification permission the first time the user actually
    // creates an alert, rather than upfront at app launch — the point where
    // the request is contextual and expected, not permission-prompt fatigue.
    if (!_isEditing) {
      await cubit.requestNotificationPermission();
    }
    if (navigator.mounted) navigator.pop();
  }

  Future<void> _delete(BuildContext context, AppCubit cubit, AppLocalizations l10n) async {
    final existing = widget.existing;
    if (existing == null) return;
    final confirmed = await confirmDelete(
      context,
      title: l10n.confirmDeleteAlertTitle,
      message: l10n.confirmDeleteAlertMessage,
      confirmLabel: l10n.commonDelete,
    );
    if (!confirmed) return;
    await cubit.deleteAlert(existing);
    if (context.mounted) Navigator.of(context).pop();
  }
}
