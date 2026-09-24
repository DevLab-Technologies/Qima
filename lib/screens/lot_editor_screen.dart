import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../blocs/app_cubit.dart';
import '../l10n/app_localizations.dart';
import '../models/asset.dart';
import '../models/holding.dart';
import '../models/metal_breakdown.dart';
import '../theme/design_system.dart';
import '../theme/instrument_theme.dart';
import '../theme/qima_colors.dart';
import '../theme/strings.dart';
import '../widgets/confirm_delete_dialog.dart';
import 'currency_picker.dart';
import 'holdings_screen.dart';

enum _CostMode { perUnit, total }

/// A karat selector is only meaningful for gold priced by weight — a troy
/// ounce lot is fine weight by convention (see [HoldingLot.karat]) and
/// non-gold instruments have no [Instrument.supportedKarats] at all.
bool _supportsKaratFor(Instrument instrument, PriceUnit unit) =>
    instrument.supportedKarats.isNotEmpty && unit != PriceUnit.troyOunce;

/// Add/edit a purchase lot. Mirrors `LotEditorView.swift`.
class LotEditorScreen extends StatefulWidget {
  final Instrument instrument;
  final HoldingLot? existing;
  final String defaultCurrency;

  /// The originating watch card's unit/karat, used as the default for a
  /// NEW lot (an existing lot always keeps its own stored unit/karat
  /// instead — see [_LotEditorScreenState.initState]).
  final PriceUnit? defaultUnit;
  final GoldKarat? defaultKarat;

  const LotEditorScreen({
    super.key,
    required this.instrument,
    required this.defaultCurrency,
    this.defaultUnit,
    this.defaultKarat,
    this.existing,
  });

  @override
  State<LotEditorScreen> createState() => _LotEditorScreenState();
}

class _LotEditorScreenState extends State<LotEditorScreen> {
  late final TextEditingController _quantityController;
  late final TextEditingController _unitCostController;
  late final TextEditingController _totalCostController;
  late PriceUnit _unit;
  GoldKarat? _karat;
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
    _unit = existing?.unit ?? widget.defaultUnit ?? widget.instrument.quotation.defaultUnit;
    _currency = existing?.costCurrency ?? widget.defaultCurrency;
    _date = existing?.date ?? DateTime.now();
    // Editing keeps the lot's own karat exactly as stored (including null =
    // fine/24K). A new lot defaults to the originating card's karat when the
    // starting unit supports one, else 24K (spec: "Default for a new lot:
    // the karat of the card the user came from (if gram/kg), else 24K" —
    // 24K is represented as karat == null, same as everywhere else).
    if (existing != null) {
      _karat = existing.karat;
    } else if (_supportsKaratFor(widget.instrument, _unit)) {
      _karat = widget.defaultKarat;
    } else {
      _karat = null;
    }
  }

  bool get _supportsKarat => _supportsKaratFor(widget.instrument, _unit);

  void _onUnitChanged(PriceUnit unit) {
    setState(() {
      _unit = unit;
      // Troy ounce is fine weight by convention: switching to it clears any
      // karat so the lot is never a "karat troy ounce" (spec).
      if (!_supportsKaratFor(widget.instrument, unit)) _karat = null;
    });
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
    final colors = context.colors;
    final accent = InstrumentTheme.accentColor(widget.instrument, colors);

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
                  final lot = widget.existing!;
                  final hidden = cubit.state.hideBalances;
                  final confirmed = await confirmDelete(
                    context,
                    title: l10n.confirmDeleteLotTitle,
                    message: l10n.confirmDeleteLotMessage(
                        '${lotQuantityLabel(context, lot)} · ${lotDetailLabel(lot, hidden: hidden)}'),
                    confirmLabel: l10n.commonDelete,
                  );
                  if (!confirmed) return;
                  await cubit.deleteLot(lot);
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
                  _field(colors, l10n.holdingsQuantity, _quantityController, onChanged: (_) => _onQuantityChanged()),
                  if (widget.instrument.supportedUnits.length > 1) ...[
                    const SizedBox(height: DS.spaceSM),
                    Wrap(
                      spacing: DS.spaceXS,
                      children: [
                        for (final unit in widget.instrument.supportedUnits)
                          DSChoiceChip(
                            label: displayLabel(context, unit.labelKey),
                            selected: _unit == unit,
                            onSelected: (_) => _onUnitChanged(unit),
                            accent: accent,
                          ),
                      ],
                    ),
                  ],
                  if (_supportsKarat) ...[
                    const SizedBox(height: DS.spaceSM),
                    Text(l10n.settingsKarat, style: TextStyle(color: colors.textTertiary, fontSize: 12)),
                    const SizedBox(height: 4),
                    SegmentedButton<GoldKarat>(
                      segments: [
                        for (final karat in widget.instrument.supportedKarats)
                          ButtonSegment(value: karat, label: Text(displayLabel(context, karat.shortLabelKey))),
                      ],
                      selected: {_karat ?? GoldKarat.k24},
                      onSelectionChanged: (s) => setState(() => _karat = s.first == GoldKarat.k24 ? null : s.first),
                      style: DS.segmentedButtonStyle(colors, accent),
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
                    style: DS.segmentedButtonStyle(colors, accent),
                  ),
                  const SizedBox(height: DS.spaceSM),
                  if (_mode == _CostMode.perUnit) ...[
                    _field(colors, _unitCostLabel(context), _unitCostController, onChanged: (_) => setState(_syncFromUnitCost)),
                    const SizedBox(height: 4),
                    Text(
                      l10n.holdingsTotalCostPreview(_totalCostController.text),
                      style: TextStyle(color: colors.textTertiary, fontSize: 12),
                    ),
                  ] else ...[
                    _field(colors, l10n.holdingsTotalCost, _totalCostController, onChanged: (_) => setState(_syncFromTotalCost)),
                    const SizedBox(height: 4),
                    Text(
                      l10n.holdingsUnitCostPreview(_unitCostController.text),
                      style: TextStyle(color: colors.textTertiary, fontSize: 12),
                    ),
                  ],
                  const SizedBox(height: DS.spaceMD),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.commonCurrency, style: TextStyle(color: colors.textPrimary)),
                    trailing: Text(_currency, style: TextStyle(color: colors.textSecondary)),
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
                    title: Text(l10n.holdingsDate, style: TextStyle(color: colors.textPrimary)),
                    trailing: Text('${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}',
                        style: TextStyle(color: colors.textSecondary)),
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
                        karat: _supportsKarat ? _karat : null,
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

  /// "Unit cost" for an instrument with only one unit, "Unit cost (per g)"
  /// once there's a choice of unit, or "Unit cost (per g · 21K)" once a
  /// karat is also in play — so the field label always states exactly what
  /// basis the number the user types is on.
  String _unitCostLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (widget.instrument.supportedUnits.length <= 1 && !_supportsKarat) return l10n.holdingsUnitCost;
    final unitLabel = displayLabel(context, _unit.labelKey);
    if (_supportsKarat) {
      return l10n.holdingsUnitCostWithKarat(unitLabel, displayLabel(context, (_karat ?? GoldKarat.k24).shortLabelKey));
    }
    return l10n.holdingsUnitCostWithUnit(unitLabel);
  }

  Widget _field(QimaColors colors, String label, TextEditingController controller, {ValueChanged<String>? onChanged}) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: TextStyle(color: colors.textPrimary),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: colors.textTertiary),
        filled: true,
        fillColor: colors.tileTop,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(DS.radiusTile), borderSide: BorderSide.none),
      ),
    );
  }
}
