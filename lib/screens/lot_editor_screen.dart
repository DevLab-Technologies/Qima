import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../blocs/app_cubit.dart';
import '../l10n/app_localizations.dart';
import '../models/asset.dart';
import '../models/holding.dart';
import '../theme/design_system.dart';
import '../theme/instrument_theme.dart';
import '../theme/strings.dart';
import 'currency_picker.dart';

enum _CostMode { perUnit, total }

/// Add/edit a purchase lot. Mirrors `LotEditorView.swift`.
class LotEditorScreen extends StatefulWidget {
  final Instrument instrument;
  final HoldingLot? existing;
  final String defaultCurrency;

  const LotEditorScreen({super.key, required this.instrument, required this.defaultCurrency, this.existing});

  @override
  State<LotEditorScreen> createState() => _LotEditorScreenState();
}

class _LotEditorScreenState extends State<LotEditorScreen> {
  late final TextEditingController _quantityController;
  late final TextEditingController _unitCostController;
  late final TextEditingController _totalCostController;
  late PriceUnit _unit;
  late String _currency;
  late DateTime _date;
  _CostMode _mode = _CostMode.perUnit;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _quantityController = TextEditingController(text: existing != null ? _trim(existing.quantity) : '');
    _unitCostController = TextEditingController(text: existing != null ? _trim(existing.unitCost) : '');
    _totalCostController = TextEditingController(text: existing != null ? _trim(existing.totalCost) : '');
    _unit = existing?.unit ?? widget.instrument.quotation.defaultUnit;
    _currency = existing?.costCurrency ?? widget.defaultCurrency;
    _date = existing?.date ?? DateTime.now();
  }

  String _trim(double value) {
    if (value == value.roundToDouble()) return value.toStringAsFixed(0);
    return value.toString();
  }

  double _parse(String text) => double.tryParse(text.trim()) ?? 0;

  void _syncFromUnitCost() {
    final qty = _parse(_quantityController.text);
    final unitCost = _parse(_unitCostController.text);
    _totalCostController.text = _trim(qty * unitCost);
  }

  void _syncFromTotalCost() {
    final qty = _parse(_quantityController.text);
    final total = _parse(_totalCostController.text);
    _unitCostController.text = qty > 0 ? _trim(total / qty) : '0';
  }

  void _onQuantityChanged() {
    setState(() {
      if (_mode == _CostMode.perUnit) {
        _syncFromUnitCost();
      } else {
        _syncFromTotalCost();
      }
    });
  }

  bool get _isValid => _parse(_quantityController.text) > 0 && _parse(_unitCostController.text) > 0;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AppCubit>();
    final isEditing = widget.existing != null;
    final l10n = AppLocalizations.of(context)!;
    final accent = InstrumentTheme.accentColor(widget.instrument);

    return ScreenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(isEditing ? l10n.holdingsEdit : l10n.holdingsNew),
          actions: [
            if (isEditing)
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () async {
                  await cubit.deleteLot(widget.existing!);
                  if (context.mounted) Navigator.of(context).pop();
                },
              ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(DS.spaceMD),
          children: [
            DSCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _field(l10n.holdingsQuantity, _quantityController, onChanged: (_) => _onQuantityChanged()),
                  if (widget.instrument.supportedUnits.length > 1) ...[
                    const SizedBox(height: DS.spaceSM),
                    Wrap(
                      spacing: DS.spaceXS,
                      children: [
                        for (final unit in widget.instrument.supportedUnits)
                          DSChoiceChip(
                            label: displayLabel(context, unit.labelKey),
                            selected: _unit == unit,
                            onSelected: (_) => setState(() => _unit = unit),
                            accent: accent,
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: DS.spaceMD),
                  SegmentedButton<_CostMode>(
                    segments: [
                      ButtonSegment(value: _CostMode.perUnit, label: Text(l10n.holdingsCostModePerUnit)),
                      ButtonSegment(value: _CostMode.total, label: Text(l10n.holdingsCostModeTotal)),
                    ],
                    selected: {_mode},
                    onSelectionChanged: (s) => setState(() => _mode = s.first),
                    style: DS.segmentedButtonStyle(accent),
                  ),
                  const SizedBox(height: DS.spaceSM),
                  if (_mode == _CostMode.perUnit) ...[
                    _field(l10n.holdingsUnitCost, _unitCostController, onChanged: (_) => setState(_syncFromUnitCost)),
                    const SizedBox(height: 4),
                    Text(
                      l10n.holdingsTotalCostPreview(_totalCostController.text),
                      style: const TextStyle(color: DS.textTertiary, fontSize: 12),
                    ),
                  ] else ...[
                    _field(l10n.holdingsTotalCost, _totalCostController, onChanged: (_) => setState(_syncFromTotalCost)),
                    const SizedBox(height: 4),
                    Text(
                      l10n.holdingsUnitCostPreview(_unitCostController.text),
                      style: const TextStyle(color: DS.textTertiary, fontSize: 12),
                    ),
                  ],
                  const SizedBox(height: DS.spaceMD),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.commonCurrency, style: const TextStyle(color: DS.textPrimary)),
                    trailing: Text(_currency, style: const TextStyle(color: DS.textSecondary)),
                    onTap: () async {
                      final selected = await CurrencyPicker.show(
                        context,
                        selected: _currency,
                        currencies: cubit.state.rates.availableCurrencies,
                      );
                      if (selected != null) setState(() => _currency = selected);
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.holdingsDate, style: const TextStyle(color: DS.textPrimary)),
                    trailing: Text('${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}',
                        style: const TextStyle(color: DS.textSecondary)),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _date,
                        firstDate: DateTime(1990),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) setState(() => _date = picked);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: DS.spaceLG),
            FilledButton(
              onPressed: _isValid
                  ? () async {
                      final lot = HoldingLot(
                        id: widget.existing?.id ?? const Uuid().v4(),
                        instrumentID: widget.instrument.id,
                        quantity: _parse(_quantityController.text),
                        unit: _unit,
                        unitCost: _parse(_unitCostController.text),
                        costCurrency: _currency,
                        date: _date,
                      );
                      await cubit.saveLot(lot);
                      if (context.mounted) Navigator.of(context).pop();
                    }
                  : null,
              child: Text(l10n.holdingsSave),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController controller, {ValueChanged<String>? onChanged}) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(color: DS.textPrimary),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: DS.textTertiary),
        filled: true,
        fillColor: DS.tileTop,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(DS.radiusTile), borderSide: BorderSide.none),
      ),
    );
  }
}
