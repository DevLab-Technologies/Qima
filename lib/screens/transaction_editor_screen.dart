import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../blocs/app_cubit.dart';
import '../blocs/app_state.dart';
import '../l10n/app_localizations.dart';
import '../models/asset.dart';
import '../models/holding_totals.dart';
import '../models/holding_transaction.dart';
import '../models/ledger.dart';
import '../models/metal_breakdown.dart';
import '../models/money.dart';
import '../theme/design_system.dart';
import '../theme/help_topics.dart';
import '../theme/instrument_theme.dart';
import '../theme/masking.dart';
import '../theme/qima_colors.dart';
import '../theme/strings.dart';
import '../widgets/help_button.dart';
import '../widgets/section_header.dart';
import 'currency_picker.dart';
import 'holdings_screen.dart';

/// The four choices at the top of the editor; [TransactionKind] splits
/// transfers into in and out.
enum _Kind { buy, sell, transfer, fee }

enum _PriceMode { perUnit, total }

/// A karat selector only means something for gold priced by weight — a troy
/// ounce is fine weight by convention and other metals have no karats.
bool _supportsKarat(Instrument instrument, PriceUnit unit) =>
    instrument.supportedKarats.isNotEmpty && unit != PriceUnit.troyOunce;

/// Add or edit one ledger row (v3, Figma "New transaction · Sell"). A sell
/// previews what it realises against the weighted-average basis before it's
/// saved, and nothing can be saved that would sell more than was held.
class TransactionEditorScreen extends StatefulWidget {
  final Instrument instrument;
  final HoldingTransaction? existing;
  final String defaultCurrency;
  final PriceUnit? defaultUnit;
  final GoldKarat? defaultKarat;

  const TransactionEditorScreen({
    super.key,
    required this.instrument,
    required this.defaultCurrency,
    this.defaultUnit,
    this.defaultKarat,
    this.existing,
  });

  @override
  State<TransactionEditorScreen> createState() => _TransactionEditorScreenState();
}

class _TransactionEditorScreenState extends State<TransactionEditorScreen> {
  late final String _id = widget.existing?.id ?? const Uuid().v4();
  late _Kind _kind;
  bool _transferIn = true;
  late final TextEditingController _quantity;
  late final TextEditingController _price;
  late final TextEditingController _fee;
  late final TextEditingController _note;
  _PriceMode _priceMode = _PriceMode.perUnit;
  late PriceUnit _unit;
  GoldKarat? _karat;
  late String _currency;
  late DateTime _date;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _kind = switch (e?.kind) {
      TransactionKind.sell => _Kind.sell,
      TransactionKind.transferIn || TransactionKind.transferOut => _Kind.transfer,
      TransactionKind.fee => _Kind.fee,
      _ => _Kind.buy,
    };
    _transferIn = e?.kind != TransactionKind.transferOut;
    _quantity = TextEditingController(text: e == null || e.quantity == 0 ? '' : _trim(e.quantity));
    _price = TextEditingController(text: e == null || e.unitPrice == 0 ? '' : _trim(e.unitPrice));
    _fee = TextEditingController(text: e == null || e.fee == 0 ? '' : _trim(e.fee));
    _note = TextEditingController(text: e?.note ?? '');
    _currency = e?.currency ?? widget.defaultCurrency;
    _date = e?.date ?? _today();
    if (e != null) {
      _unit = e.unit;
      _karat = e.karat;
    } else {
      // A new row starts in the unit and karat already held when they're
      // all the same — selling some of a 21K holding should start at 21K,
      // whatever card the user came from.
      final held = context.read<AppCubit>().lotsFor(widget.instrument);
      final uniform = held.isNotEmpty && held.every((l) => l.unit == held.first.unit && l.karat == held.first.karat);
      _unit = uniform ? held.first.unit : (widget.defaultUnit ?? widget.instrument.quotation.defaultUnit);
      final karat = uniform ? held.first.karat : widget.defaultKarat;
      _karat = _supportsKarat(widget.instrument, _unit) ? karat : null;
    }
  }

  @override
  void dispose() {
    _quantity.dispose();
    _price.dispose();
    _fee.dispose();
    _note.dispose();
    super.dispose();
  }

  static DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static String _trim(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

  /// Accepts a comma decimal too ("2,5"), as typed on French and Spanish
  /// keyboards. Negative and non-numeric input reads as nothing.
  static double _parse(String text) {
    final v = double.tryParse(text.trim().replaceAll(',', '.'));
    return v == null || v.isNaN || v < 0 ? 0 : v;
  }

  TransactionKind get _transactionKind => switch (_kind) {
        _Kind.buy => TransactionKind.buy,
        _Kind.sell => TransactionKind.sell,
        _Kind.transfer => _transferIn ? TransactionKind.transferIn : TransactionKind.transferOut,
        _Kind.fee => TransactionKind.fee,
      };

  bool get _hasPrice => _kind == _Kind.buy || _kind == _Kind.sell || (_kind == _Kind.transfer && _transferIn);
  bool get _priceRequired => _kind == _Kind.buy || _kind == _Kind.sell;

  double get _quantityValue => _kind == _Kind.fee ? 0 : _parse(_quantity.text);

  /// Always per unit, whichever way it was typed.
  double get _unitPrice {
    if (!_hasPrice) return 0;
    final entered = _parse(_price.text);
    if (_priceMode == _PriceMode.perUnit) return entered;
    final q = _quantityValue;
    return q > 0 ? entered / q : 0;
  }

  HoldingTransaction get _candidate => HoldingTransaction(
        id: _id,
        instrumentID: widget.instrument.id,
        kind: _transactionKind,
        quantity: _quantityValue,
        unit: _unit,
        karat: _kind != _Kind.fee && _supportsKarat(widget.instrument, _unit) ? _karat : null,
        unitPrice: _unitPrice,
        fee: _parse(_fee.text),
        currency: _currency,
        date: _date,
        note: _note.text.trim(),
      );

  /// Why Save is disabled, if it is — shown under the form.
  String? _problem(AppCubit cubit) {
    final l10n = AppLocalizations.of(context)!;
    final c = _candidate;
    if (_kind == _Kind.fee) return c.fee > 0 ? null : l10n.transactionNeedsFee;
    if (c.quantity <= 0) return l10n.transactionNeedsQuantity;
    if (_priceRequired && c.unitPrice <= 0) return l10n.transactionNeedsPrice;
    final conflict = cubit.conflictForSave(c);
    if (conflict == null) return null;
    if (conflict.id == c.id) {
      final held = _heldBefore(cubit, c);
      return l10n.transactionMoreThanHeld(quantityWithUnitKaratLabel(context, held, _unit, c.karat));
    }
    return l10n.ledgerConflictMessage(transactionKindLabel(l10n, conflict.kind), transactionDateLabel(context, conflict.date));
  }

  /// What was held just before [c], expressed in the editor's unit/karat.
  double _heldBefore(AppCubit cubit, HoldingTransaction c) {
    final others = cubit.state.transactions.where((t) => t.id != c.id && t.instrumentID == c.instrumentID);
    final ordered = Ledger.ordered([...others, c]);
    final before = ordered.takeWhile((t) => t.id != c.id);
    final fine = Ledger.derive(before)[c.instrumentID]?.fineOunces ?? 0;
    return fine / _unit.multiplier / c.purity;
  }

  Future<void> _save(AppCubit cubit) async {
    final conflict = await cubit.saveTransaction(_candidate);
    if (!mounted) return;
    if (conflict != null) {
      await showLedgerConflict(context, conflict, deleting: false);
      return;
    }
    Navigator.of(context).pop();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(1970),
      lastDate: _today(),
    );
    if (picked != null) setState(() => _date = DateTime(picked.year, picked.month, picked.day));
  }

  void _onUnitChanged(PriceUnit unit) {
    setState(() {
      _unit = unit;
      // A troy ounce is fine weight by convention, never a karat ounce.
      if (!_supportsKarat(widget.instrument, unit)) _karat = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AppCubit>();
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final accent = InstrumentTheme.accentColor(widget.instrument, colors);
    final isEditing = widget.existing != null;

    return ScreenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(isEditing ? l10n.transactionEditTitle : l10n.transactionNewTitle),
          actions: [
            const HelpButton(topic: HelpTopicId.lotEditor),
            if (isEditing)
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: l10n.commonDelete,
                onPressed: () async {
                  final deleted = await confirmDeleteTransaction(context, cubit, widget.existing!);
                  if (deleted && context.mounted) Navigator.of(context).pop();
                },
              ),
            BlocBuilder<AppCubit, AppState>(
              builder: (context, _) => TextButton(
                onPressed: _problem(cubit) == null ? () => _save(cubit) : null,
                child: Text(l10n.holdingsSave),
              ),
            ),
          ],
        ),
        body: BlocBuilder<AppCubit, AppState>(
          builder: (context, state) {
            final problem = _problem(cubit);
            return GestureDetector(
              // Tapping outside a field closes the number pad, which has no
              // return key of its own.
              onTap: () => FocusScope.of(context).unfocus(),
              behavior: HitTestBehavior.translucent,
              child: ListView(
                padding: const EdgeInsets.all(DS.spaceMD),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                children: [
                  SegmentedButton<_Kind>(
                    segments: [
                      ButtonSegment(value: _Kind.buy, label: Text(l10n.transactionKindBuy)),
                      ButtonSegment(value: _Kind.sell, label: Text(l10n.transactionKindSell)),
                      ButtonSegment(value: _Kind.transfer, label: Text(l10n.transactionKindTransfer)),
                      ButtonSegment(value: _Kind.fee, label: Text(l10n.transactionKindFee)),
                    ],
                    showSelectedIcon: false,
                    selected: {_kind},
                    onSelectionChanged: (s) => setState(() => _kind = s.first),
                    style: DS.segmentedButtonStyle(colors, accent),
                  ),
                  if (_kind == _Kind.transfer) ...[
                    const SizedBox(height: DS.spaceSM),
                    SegmentedButton<bool>(
                      segments: [
                        ButtonSegment(value: true, label: Text(l10n.transactionTransferInLabel)),
                        ButtonSegment(value: false, label: Text(l10n.transactionTransferOutLabel)),
                      ],
                      selected: {_transferIn},
                      onSelectionChanged: (s) => setState(() => _transferIn = s.first),
                      style: DS.segmentedButtonStyle(colors, accent),
                    ),
                  ],
                  const SizedBox(height: DS.spaceMD),
                  DSCard(child: _fields(context, accent)),
                  if (problem != null) ...[
                    const SizedBox(height: DS.spaceSM),
                    Text(problem, style: TextStyle(color: colors.down, fontSize: 13)),
                  ],
                  if (_kind == _Kind.sell && problem == null) ...[
                    const SizedBox(height: DS.spaceMD),
                    _SellPreview(candidate: _candidate, state: state, unit: _unit),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _fields(BuildContext context, Color accent) {
    final cubit = context.read<AppCubit>();
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final unitLabel = displayLabel(context, _unit.labelKey);
    final supportsKarat = _supportsKarat(widget.instrument, _unit);
    final q = _quantityValue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_kind != _Kind.fee) ...[
          _numberField(colors, l10n.holdingsQuantity, _quantity),
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
          if (supportsKarat) ...[
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
            if (_karat != null && q > 0) ...[
              const SizedBox(height: 4),
              Text(
                l10n.transactionFineHint(quantityWithUnitKaratLabel(context, q * _karat!.purity, _unit, null)),
                style: TextStyle(color: colors.textTertiary, fontSize: 12),
              ),
            ],
          ],
          const SizedBox(height: DS.spaceMD),
        ],
        if (_hasPrice) ...[
          SegmentedButton<_PriceMode>(
            segments: [
              ButtonSegment(value: _PriceMode.perUnit, label: Text(l10n.holdingsCostModePerUnit)),
              ButtonSegment(value: _PriceMode.total, label: Text(l10n.holdingsCostModeTotal)),
            ],
            selected: {_priceMode},
            onSelectionChanged: (s) => setState(() {
              // Keep the same money amount when switching how it's typed.
              final perUnit = _unitPrice;
              _priceMode = s.first;
              final shown = _priceMode == _PriceMode.perUnit ? perUnit : perUnit * _quantityValue;
              _price.text = shown == 0 ? '' : _trim(double.parse(shown.toStringAsFixed(6)));
            }),
            style: DS.segmentedButtonStyle(colors, accent),
          ),
          const SizedBox(height: DS.spaceSM),
          _numberField(
            colors,
            _priceLabel(l10n, unitLabel, supportsKarat),
            _price,
            helper: _kind == _Kind.transfer ? l10n.transactionTransferCostHelper : null,
          ),
          const SizedBox(height: DS.spaceSM),
        ],
        _numberField(
          colors,
          _kind == _Kind.fee ? l10n.transactionFeeAmount : l10n.transactionFee,
          _fee,
        ),
        const SizedBox(height: DS.spaceSM),
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
          trailing: Text(transactionDateLabel(context, _date), style: TextStyle(color: colors.textSecondary)),
          onTap: _pickDate,
        ),
        TextField(
          controller: _note,
          maxLength: 120,
          onChanged: (_) => setState(() {}),
          style: TextStyle(color: colors.textPrimary),
          decoration: _decoration(colors, _kind == _Kind.fee ? l10n.transactionFeeLabel : l10n.transactionNote),
        ),
      ],
    );
  }

  String _priceLabel(AppLocalizations l10n, String unitLabel, bool supportsKarat) {
    if (_priceMode == _PriceMode.total) {
      return switch (_kind) {
        _Kind.sell => l10n.transactionTotalProceeds,
        _Kind.transfer => l10n.transactionTotalCarriedCost,
        _ => l10n.holdingsTotalCost,
      };
    }
    if (_unit == PriceUnit.each) {
      return switch (_kind) {
        _Kind.sell => l10n.transactionSalePricePlain,
        _Kind.transfer => l10n.transactionCarriedCostPlain,
        _ => l10n.transactionBuyPricePlain,
      };
    }
    final per = supportsKarat
        ? l10n.transactionPerUnitKarat(unitLabel, displayLabel(context, (_karat ?? GoldKarat.k24).shortLabelKey))
        : unitLabel;
    return switch (_kind) {
      _Kind.sell => l10n.transactionSalePrice(per),
      _Kind.transfer => l10n.transactionCarriedCost(per),
      _ => l10n.transactionBuyPrice(per),
    };
  }

  InputDecoration _decoration(QimaColors colors, String label, {String? helper}) => InputDecoration(
        labelText: label,
        helperText: helper,
        helperMaxLines: 2,
        labelStyle: TextStyle(color: colors.textTertiary),
        filled: true,
        fillColor: colors.tileTop,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(DS.radiusTile), borderSide: BorderSide.none),
      );

  Widget _numberField(QimaColors colors, String label, TextEditingController controller, {String? helper}) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: (_) => setState(() {}),
      style: TextStyle(color: colors.textPrimary),
      decoration: _decoration(colors, label, helper: helper),
    );
  }
}

/// What a sell would realise, before it's saved: proceeds, the share of the
/// average cost it releases, its fee, and the gain — plus what stays held.
/// Everything in the sale's own currency.
class _SellPreview extends StatelessWidget {
  final HoldingTransaction candidate;
  final AppState state;
  final PriceUnit unit;

  const _SellPreview({required this.candidate, required this.state, required this.unit});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final hidden = state.hideBalances;
    final currency = candidate.currency;
    final next = Ledger.derive([...state.transactions.where((t) => t.id != candidate.id), candidate]);
    final position = next[candidate.instrumentID];
    final effect = position?.disposals[candidate.id];
    if (position == null || effect == null) return const SizedBox.shrink();

    final released = effect.basisReleased.inCurrency(currency, state.rates);
    final gain = effect.realised.inCurrency(currency, state.rates);
    // What stays held, at the sale's own unit and karat.
    final remainingLots = position.openLots;
    final remainingQty = HoldingTotals.totalHeld(lots: remainingLots, refUnit: unit, refKarat: candidate.karat);
    final remainingAverage = HoldingTotals.averageCost(
      lots: remainingLots,
      refUnit: unit,
      refKarat: candidate.karat,
      displayCurrency: currency,
      rates: state.rates,
    );
    final unitText = displayLabel(context, unit.abbreviationKey ?? unit.labelKey);

    Widget row(String label, String value, {Color? tint, bool strong = false}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Expanded(child: Text(label, style: TextStyle(color: strong ? colors.textPrimary : colors.textSecondary))),
              Text(value, style: TextStyle(color: tint ?? colors.textPrimary, fontWeight: FontWeight.w700)),
            ],
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(l10n.transactionPreviewTitle),
        DSCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              row(l10n.transactionProceeds, Masking.amount(Money(candidate.gross, currency), hidden: hidden)),
              row(l10n.transactionBasisReleased, Masking.signedAmount(Money(-released.amount, currency), hidden: hidden, isUp: false)),
              if (candidate.fee > 0)
                row(l10n.transactionFee, Masking.signedAmount(Money(-candidate.fee, currency), hidden: hidden, isUp: false)),
              Divider(color: colors.hairline),
              row(
                l10n.transactionRealisedGain,
                Masking.signedAmount(gain, hidden: hidden, isUp: gain.amount >= 0),
                tint: QimaColors.trendColor(gain.amount >= 0, colors),
                strong: true,
              ),
              const SizedBox(height: DS.spaceXS),
              Text(
                remainingLots.isEmpty || remainingAverage == null
                    ? l10n.transactionPreviewClosesPosition
                    : l10n.transactionPreviewRemaining(
                        hidden ? Masking.mask : quantityWithUnitKaratLabel(context, remainingQty, unit, candidate.karat),
                        perUnitLabel(l10n, Masking.amount(remainingAverage, hidden: false), unit, unitText),
                      ),
                style: TextStyle(color: colors.textTertiary, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
