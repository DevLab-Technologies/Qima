import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../blocs/app_cubit.dart';
import '../blocs/app_state.dart';
import '../l10n/app_localizations.dart';
import '../models/instrument_catalog.dart';
import '../models/money.dart';
import '../models/transaction_capture.dart';
import '../theme/design_system.dart';
import '../theme/masking.dart';
import '../theme/qima_colors.dart';
import '../theme/strings.dart';
import '../widgets/section_header.dart';
import 'holdings_screen.dart';
import 'transaction_editor_screen.dart';

/// What [TransactionCapture] needs from the running app: the catalog with
/// names in the user's language, the base currency and the currencies the
/// app can convert.
CaptureContext captureContextOf(BuildContext context, AppState state) {
  final now = DateTime.now();
  return CaptureContext(
    catalog: InstrumentCatalog.all,
    displayName: (i) => displayLabel(context, i.nameKey),
    baseCurrency: state.baseCurrency,
    currencies: {...state.rates.availableCurrencies, state.baseCurrency},
    today: DateTime(now.year, now.month, now.day),
  );
}

/// "Check this" (v4, Figma "Natural-language capture"): a captured sentence
/// laid out field by field, each saying which words it came from, with
/// anything guessed flagged. Nothing is saved until Confirm; Edit fields
/// opens the normal editor prefilled instead.
class CaptureReviewScreen extends StatefulWidget {
  final String text;
  final TransactionDraft draft;

  const CaptureReviewScreen({super.key, required this.text, required this.draft});

  @override
  State<CaptureReviewScreen> createState() => _CaptureReviewScreenState();
}

class _CaptureReviewScreenState extends State<CaptureReviewScreen> {
  // One id for this capture, so Confirm and Edit fields save the same row
  // however many times either is tried.
  late final String _id = const Uuid().v4();
  bool _saving = false;

  TransactionDraft get _draft => widget.draft;

  Future<void> _confirm() async {
    final cubit = context.read<AppCubit>();
    final transaction = _draft.toTransaction(_id);
    setState(() => _saving = true);
    final conflict = await cubit.saveTransaction(transaction);
    if (!mounted) return;
    setState(() => _saving = false);
    if (conflict != null) {
      await showLedgerConflict(context, conflict, deleting: false);
      return;
    }

    // Captured before navigating away tears this context down.
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final summary = transactionSummary(context, transaction, hidden: cubit.state.hideBalances);
    final l10n = AppLocalizations.of(context)!;
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => HoldingsScreen(
          instrument: _draft.instrument.value,
          displayCurrency: cubit.state.baseCurrency,
          refUnit: transaction.unit,
          refKarat: transaction.karat,
        ),
      ),
      (route) => route.isFirst,
    );
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(persist: false, content: Text(l10n.captureRecorded(summary))));
  }

  void _edit() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => TransactionEditorScreen(
          instrument: _draft.instrument.value,
          defaultCurrency: _draft.currency.value,
          draft: _draft.toTransaction(_id),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final canConfirm = _draft.isComplete && !_saving;

    return ScreenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(l10n.captureCheckTitle),
          actions: [
            TextButton(onPressed: canConfirm ? _confirm : null, child: Text(l10n.captureConfirm)),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(DS.spaceMD),
          children: [
            SectionHeader(l10n.captureYouWrote),
            DSCard(
              child: Text(
                widget.text,
                style: TextStyle(color: colors.textPrimary, fontSize: 16, height: 1.35),
              ),
            ),
            const SizedBox(height: DS.spaceLG),
            SectionHeader(l10n.captureRead),
            DSCard(
              padding: const EdgeInsets.symmetric(horizontal: DS.spaceMD, vertical: DS.space2XS),
              child: Column(children: _rows(context)),
            ),
            if (!_draft.isComplete) ...[
              const SizedBox(height: DS.spaceSM),
              Text(l10n.captureNeedsPrice, style: TextStyle(color: colors.down, fontSize: 13)),
            ],
            const SizedBox(height: DS.spaceLG),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(onPressed: _saving ? null : _edit, child: Text(l10n.captureEditFields)),
                ),
                const SizedBox(width: DS.spaceSM),
                Expanded(
                  child: FilledButton(onPressed: canConfirm ? _confirm : null, child: Text(l10n.captureConfirm)),
                ),
              ],
            ),
            const SizedBox(height: DS.spaceLG),
            _OnDeviceNote(),
            const SizedBox(height: DS.spaceSM),
            Text(
              l10n.captureFootnote,
              style: TextStyle(color: colors.textTertiary, fontSize: 12, height: 1.35),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _rows(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final d = _draft;

    String note(Captured<Object?>? field, {String? fallback}) =>
        field?.source != null ? l10n.captureFrom(field!.source!) : (fallback ?? l10n.captureAssumed);

    final instrument = d.instrument.value;
    final karat = d.karat;
    final assetNotes = {note(d.instrument), if (karat != null && karat.source != d.instrument.source) note(karat)};

    final price = d.unitPrice;
    final unitText = d.unit.value.abbreviationKey != null ? displayLabel(context, d.unit.value.abbreviationKey!) : '';
    final priceNotes = [
      if (price != null) note(price),
      if (d.total != null) l10n.captureTotalDivided,
      if (d.currency.source == null) l10n.captureBaseCurrency,
    ];

    final rows = <Widget>[
      _FieldRow(label: l10n.captureFieldType, value: transactionKindLabel(l10n, d.kind.value), note: note(d.kind), flagged: d.kind.guessed),
      _FieldRow(
        label: l10n.captureFieldAsset,
        value: karat == null
            ? displayLabel(context, instrument.nameKey)
            : '${displayLabel(context, instrument.nameKey)} · ${displayLabel(context, karat.value.shortLabelKey)}',
        note: assetNotes.join(' · '),
        flagged: d.instrument.guessed || (karat?.guessed ?? false),
      ),
      _FieldRow(
        label: l10n.captureFieldQuantity,
        value: quantityWithUnitKaratLabel(context, d.quantity.value, d.unit.value, null),
        note: note(d.quantity),
        flagged: d.quantity.guessed || d.unit.guessed,
      ),
      _FieldRow(
        label: l10n.captureFieldPrice,
        value: price == null
            ? '—'
            : perUnitLabel(l10n, Masking.amount(Money(price.value, d.currency.value), hidden: false), d.unit.value, unitText),
        note: price == null ? l10n.captureAssumed : priceNotes.join(' · '),
        flagged: price == null || price.guessed || d.currency.guessed,
      ),
      if (d.fee case final fee?)
        _FieldRow(
          label: l10n.captureFieldFee,
          value: Masking.amount(Money(fee.value, d.currency.value), hidden: false),
          note: note(fee),
          flagged: fee.guessed,
        ),
      _FieldRow(
        label: l10n.captureFieldDate,
        value: transactionDateLabel(context, d.date.value),
        note: note(d.date, fallback: l10n.captureToday),
        flagged: d.date.guessed,
      ),
    ];
    return [
      for (var i = 0; i < rows.length; i++) ...[
        if (i > 0) Divider(height: 1, color: context.colors.hairline),
        rows[i],
      ],
    ];
  }
}

/// One parsed field: what it is, what it was read as, and where from.
class _FieldRow extends StatelessWidget {
  final String label;
  final String value;
  final String note;
  final bool flagged;

  const _FieldRow({required this.label, required this.value, required this.note, required this.flagged});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DS.spaceSM),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: colors.textSecondary, fontSize: 15)),
                const SizedBox(height: 2),
                Text(note, style: TextStyle(color: colors.textTertiary, fontSize: 12)),
              ],
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (flagged) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: colors.brand.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(DS.radiusTile),
                    ),
                    child: Text(
                      l10n.captureCheck,
                      style: TextStyle(color: colors.brandText, fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: DS.spaceXS),
                ],
                Flexible(
                  child: Text(
                    value,
                    textAlign: TextAlign.end,
                    style: TextStyle(color: colors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The privacy line: this parse never leaves the device.
class _OnDeviceNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    return DSTile(
      padding: const EdgeInsets.all(DS.spaceSM),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: colors.up.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(6)),
            child: Text(l10n.captureOnDevice, style: TextStyle(color: colors.up, fontSize: 11, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: DS.spaceSM),
          Expanded(
            child: Text(l10n.captureNothingSent, style: TextStyle(color: colors.textSecondary, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
