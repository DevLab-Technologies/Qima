import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../blocs/app_cubit.dart';
import '../blocs/app_state.dart';
import '../l10n/app_localizations.dart';
import '../models/asset.dart';
import '../models/holding.dart';
import '../models/holding_totals.dart';
import '../models/holding_transaction.dart';
import '../models/ledger.dart';
import '../models/metal_breakdown.dart';
import '../models/money.dart';
import '../theme/design_system.dart';
import '../theme/help_topics.dart';
import '../theme/masking.dart';
import '../theme/qima_colors.dart';
import '../theme/strings.dart';
import '../widgets/confirm_delete_dialog.dart';
import '../widgets/help_button.dart';
import 'transaction_editor_screen.dart';

/// One holding's ledger (v3, Figma "Gold · Transactions"): what's held, at
/// what average cost, its unrealised and realised gain, and every
/// transaction behind those numbers, newest first. Nothing on this screen
/// is stored except the rows themselves — the summary is re-derived from
/// them on every change.
class HoldingsScreen extends StatelessWidget {
  final Instrument instrument;
  final String displayCurrency;

  /// The unit/karat of the watch card the user came from — the reference
  /// the totals are expressed at. Falls back to the instrument's default
  /// unit and fine (24K) when there's no originating card.
  final PriceUnit? refUnit;
  final GoldKarat? refKarat;

  const HoldingsScreen({
    super.key,
    required this.instrument,
    required this.displayCurrency,
    this.refUnit,
    this.refKarat,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AppCubit>();
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final unit = refUnit ?? instrument.quotation.defaultUnit;
    final name = displayLabel(context, instrument.nameKey);

    void openEditor([HoldingTransaction? existing]) => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TransactionEditorScreen(
              instrument: instrument,
              defaultCurrency: displayCurrency,
              defaultUnit: unit,
              defaultKarat: refKarat,
              existing: existing,
            ),
          ),
        );

    return ScreenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(refKarat == null ? name : l10n.ledgerTitleWithKarat(name, displayLabel(context, refKarat!.shortLabelKey))),
          actions: [
            const HelpButton(topic: HelpTopicId.holdings),
            TextButton.icon(
              onPressed: openEditor,
              icon: const Icon(Icons.add, size: 18),
              label: Text(l10n.ledgerAdd),
            ),
          ],
        ),
        body: BlocBuilder<AppCubit, AppState>(
          builder: (context, state) {
            final transactions = cubit.transactionsFor(instrument);
            final position = state.ledger[instrument.id];
            final hidden = state.hideBalances;

            if (transactions.isEmpty) {
              return ListView(
                padding: const EdgeInsets.all(DS.spaceMD),
                children: [
                  DSCard(
                    // Stretched: the app's filled buttons are full width and
                    // carry no side padding of their own.
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(l10n.holdingsEmpty, style: TextStyle(color: colors.textSecondary)),
                        const SizedBox(height: DS.spaceSM),
                        FilledButton.icon(onPressed: openEditor, icon: const Icon(Icons.add), label: Text(l10n.ledgerAddFirst)),
                      ],
                    ),
                  ),
                ],
              );
            }

            return ListView(
              padding: const EdgeInsets.all(DS.spaceMD),
              children: [
                if (position != null && position.overdrawn.isNotEmpty) ...[
                  _OverdrawnBanner(),
                  const SizedBox(height: DS.spaceSM),
                ],
                DSCard(
                  child: _Summary(
                    instrument: instrument,
                    position: position,
                    lots: cubit.lotsFor(instrument),
                    unit: unit,
                    karat: refKarat,
                    displayCurrency: displayCurrency,
                    state: state,
                  ),
                ),
                const SizedBox(height: DS.spaceMD),
                DSCard(
                  padding: const EdgeInsets.symmetric(horizontal: DS.spaceMD, vertical: DS.spaceXS),
                  child: Column(
                    children: [
                      for (var i = 0; i < transactions.length; i++) ...[
                        if (i > 0) Divider(color: colors.hairline, height: 1),
                        _TransactionRow(
                          transaction: transactions[i],
                          hidden: hidden,
                          overdrawn: position?.overdrawn.contains(transactions[i].id) ?? false,
                          onTap: () => openEditor(transactions[i]),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  final Instrument instrument;
  final InstrumentPosition? position;
  final List<HoldingLot> lots;
  final PriceUnit unit;
  final GoldKarat? karat;
  final String displayCurrency;
  final AppState state;

  const _Summary({
    required this.instrument,
    required this.position,
    required this.lots,
    required this.unit,
    required this.karat,
    required this.displayCurrency,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AppCubit>();
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final hidden = state.hideBalances;
    final valuation = cubit.valuationFor(instrument, displayCurrency);
    final held = HoldingTotals.totalHeld(lots: lots, refUnit: unit, refKarat: karat);
    final average = HoldingTotals.averageCost(
      lots: lots,
      refUnit: unit,
      refKarat: karat,
      displayCurrency: displayCurrency,
      rates: state.rates,
    );
    final position = this.position;
    final realised = position?.realised.inCurrency(displayCurrency, state.rates);
    final showRealised = position != null && (position.disposals.isNotEmpty || !position.realised.isZero);
    final unitText = displayLabel(context, unit.abbreviationKey ?? unit.labelKey);

    Widget row(String label, String value, {Color? tint}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Expanded(child: Text(label, style: TextStyle(color: colors.textSecondary))),
              Flexible(
                child: Text(value,
                    textAlign: TextAlign.end,
                    style: TextStyle(color: tint ?? colors.textPrimary, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.ledgerHolding.toUpperCase(),
            style: DS.overline(context, color: colors.textTertiary, fontSize: 11, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        if (lots.isEmpty)
          Text(l10n.ledgerNothingHeld, style: TextStyle(color: colors.textSecondary, fontSize: 20, fontWeight: FontWeight.w700))
        else
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              hidden ? Masking.mask : quantityWithUnitKaratLabel(context, held, unit, karat),
              style: TextStyle(color: colors.textPrimary, fontSize: 28, fontWeight: FontWeight.w800),
            ),
          ),
        if (lots.isNotEmpty && HoldingTotals.isMixed(lots)) ...[
          const SizedBox(height: 2),
          Text(
            HoldingTotals.isMixedKarat(lots)
                ? l10n.holdingsMixedNote(displayLabel(context, (karat ?? GoldKarat.k24).shortLabelKey))
                : l10n.holdingsMixedUnitsNote,
            style: TextStyle(color: colors.textTertiary, fontSize: 11),
          ),
        ],
        Divider(color: colors.hairline, height: DS.spaceLG),
        if (average != null) row(l10n.holdingsAverageCost, perUnitLabel(l10n, Masking.amount(average, hidden: false), unit, unitText)),
        if (valuation != null) ...[
          row(l10n.ledgerMarketValue, Masking.amount(valuation.value, hidden: hidden)),
          row(
            l10n.ledgerUnrealised,
            hidden
                ? Masking.mask
                : l10n.ledgerGainWithPercent(
                    Masking.signedAmount(valuation.gain, hidden: false, isUp: valuation.isUp),
                    signedFigure('${(valuation.gainFraction * 100).toStringAsFixed(1)}%', isUp: valuation.isUp),
                  ),
            tint: QimaColors.trendColor(valuation.isUp, colors),
          ),
        ],
        if (showRealised && realised != null)
          row(
            l10n.ledgerRealised,
            Masking.signedAmount(realised, hidden: hidden, isUp: realised.amount >= 0),
            tint: QimaColors.trendColor(realised.amount >= 0, colors),
          ),
      ],
    );
  }
}

class _TransactionRow extends StatelessWidget {
  final HoldingTransaction transaction;
  final bool hidden;
  final bool overdrawn;
  final VoidCallback onTap;

  const _TransactionRow({required this.transaction, required this.hidden, required this.overdrawn, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AppCubit>();
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final t = transaction;

    final title = t.kind == TransactionKind.fee
        ? (t.note.isEmpty ? l10n.transactionKindFee : t.note)
        : quantityWithUnitKaratLabel(context, t.quantity, t.unit, t.karat);
    final date = transactionDateLabel(context, t.date);
    final String detail;
    switch (t.kind) {
      case TransactionKind.buy:
      case TransactionKind.sell:
        final price = perUnitLabel(l10n, Masking.amount(Money(t.unitPrice, t.currency), hidden: hidden), t.unit,
            displayLabel(context, t.unit.abbreviationKey ?? t.unit.labelKey));
        detail = t.fee > 0
            ? l10n.ledgerDetailWithFee(date, price, Masking.amount(Money(t.fee, t.currency), hidden: hidden))
            : l10n.ledgerDetail(date, price);
      case TransactionKind.transferIn:
        detail = t.unitPrice == 0 ? l10n.ledgerDetail(date, l10n.ledgerNoCostBasis) : l10n.ledgerDetail(date, l10n.ledgerCostCarried);
      case TransactionKind.transferOut:
        detail = date;
      case TransactionKind.fee:
        detail = t.note.isEmpty ? date : l10n.ledgerDetail(date, l10n.transactionKindFee);
    }

    final String amount;
    final Color amountColor;
    switch (t.kind) {
      case TransactionKind.buy:
        amount = Masking.signedAmount(Money(-t.totalCost, t.currency), hidden: hidden, isUp: false);
        amountColor = colors.textPrimary;
      case TransactionKind.sell:
        amount = Masking.signedAmount(Money(t.netProceeds, t.currency), hidden: hidden, isUp: true);
        amountColor = colors.up;
      case TransactionKind.fee:
        amount = Masking.signedAmount(Money(-t.fee, t.currency), hidden: hidden, isUp: false);
        amountColor = colors.textPrimary;
      case TransactionKind.transferIn:
      case TransactionKind.transferOut:
        amount = '—';
        amountColor = colors.textTertiary;
    }

    return Dismissible(
      key: ValueKey(t.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => confirmDeleteTransaction(context, cubit, t),
      onDismissed: (_) {},
      background: Container(
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsetsDirectional.only(end: DS.spaceMD),
        child: Icon(Icons.delete, color: colors.down),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: DS.spaceSM),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        TransactionKindChip(kind: t.kind),
                        const SizedBox(width: DS.spaceXS),
                        Flexible(
                          child: Text(title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w600)),
                        ),
                        if (overdrawn) ...[
                          const SizedBox(width: 4),
                          Icon(Icons.warning_amber_rounded, size: 16, color: colors.down),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(detail, style: TextStyle(color: colors.textTertiary, fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(width: DS.spaceSM),
              Text(amount, style: TextStyle(color: amountColor, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}

class _OverdrawnBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    return DSCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: colors.down),
          const SizedBox(width: DS.spaceSM),
          Expanded(child: Text(l10n.ledgerOverdrawnBanner, style: TextStyle(color: colors.textSecondary, fontSize: 13))),
        ],
      ),
    );
  }
}

/// "Buy", "Sell", "Fee", "Transfer in"… as a small tinted chip.
class TransactionKindChip extends StatelessWidget {
  final TransactionKind kind;

  const TransactionKindChip({super.key, required this.kind});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final color = switch (kind) {
      TransactionKind.buy => colors.up,
      TransactionKind.sell => colors.down,
      TransactionKind.fee => colors.accentFiat,
      TransactionKind.transferIn || TransactionKind.transferOut => colors.textSecondary,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(6)),
      child: Text(transactionKindLabel(l10n, kind),
          style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}

String transactionKindLabel(AppLocalizations l10n, TransactionKind kind) {
  switch (kind) {
    case TransactionKind.buy:
      return l10n.transactionKindBuy;
    case TransactionKind.sell:
      return l10n.transactionKindSell;
    case TransactionKind.transferIn:
      return l10n.transactionKindTransferIn;
    case TransactionKind.transferOut:
      return l10n.transactionKindTransferOut;
    case TransactionKind.fee:
      return l10n.transactionKindFee;
  }
}

/// "$74.10 / g" — or just "$74.10" for a share, coin or currency, where a
/// per-unit suffix ("/ Each") only adds noise.
String perUnitLabel(AppLocalizations l10n, String amount, PriceUnit unit, String unitText) =>
    unit == PriceUnit.each ? amount : l10n.ledgerPerUnit(amount, unitText);

/// "12 Mar 2026" with Western digits, like the other dates on these screens.
String transactionDateLabel(BuildContext context, DateTime date) => dateWithYear(context, date);

/// Asks before deleting [transaction], then deletes it — unless that would
/// leave a later sale selling more than was held, in which case it explains
/// which sale and keeps the row. Returns whether it was deleted.
Future<bool> confirmDeleteTransaction(BuildContext context, AppCubit cubit, HoldingTransaction transaction) async {
  final l10n = AppLocalizations.of(context)!;
  final blocking = cubit.conflictForDelete(transaction);
  if (blocking != null) {
    await showLedgerConflict(context, blocking, deleting: true);
    return false;
  }
  final confirmed = await confirmDelete(
    context,
    title: l10n.confirmDeleteTransactionTitle,
    message: l10n.confirmDeleteTransactionMessage(transactionSummary(context, transaction, hidden: cubit.state.hideBalances)),
    confirmLabel: l10n.commonDelete,
  );
  if (!confirmed) return false;
  final conflict = await cubit.deleteTransaction(transaction);
  if (conflict != null && context.mounted) {
    await showLedgerConflict(context, conflict, deleting: true);
    return false;
  }
  return true;
}

/// Explains why a save or delete was refused: it would leave [sale] selling
/// more than was held on its date.
Future<void> showLedgerConflict(BuildContext context, HoldingTransaction sale, {required bool deleting}) {
  final l10n = AppLocalizations.of(context)!;
  final kind = transactionKindLabel(l10n, sale.kind);
  final date = transactionDateLabel(context, sale.date);
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(deleting ? l10n.ledgerConflictDeleteTitle : l10n.ledgerConflictSaveTitle),
      content: Text(l10n.ledgerConflictMessage(kind, date)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(MaterialLocalizations.of(context).okButtonLabel),
        ),
      ],
    ),
  );
}

/// "Sell · 20 g · 21K · 18 Aug 2026" — one line naming a transaction, for
/// confirmations.
String transactionSummary(BuildContext context, HoldingTransaction t, {required bool hidden}) {
  final l10n = AppLocalizations.of(context)!;
  final parts = <String>[
    transactionKindLabel(l10n, t.kind),
    if (t.kind == TransactionKind.fee)
      Masking.amount(Money(t.fee, t.currency), hidden: hidden)
    else
      quantityWithUnitKaratLabel(context, t.quantity, t.unit, t.karat),
    transactionDateLabel(context, t.date),
  ];
  return parts.join(' · ');
}

/// "150 g · 21K" — a quantity expressed at [unit]/[karat], formatted the
/// way every holdings list shows quantities. Never masked by itself: a bare
/// quantity on a single row isn't a balance (callers mask totals).
String quantityWithUnitKaratLabel(BuildContext context, double quantity, PriceUnit unit, GoldKarat? karat) {
  final unitSuffix = unit.abbreviationKey != null ? ' ${displayLabel(context, unit.abbreviationKey!)}' : '';
  final karatSuffix = karat != null ? ' · ${displayLabel(context, karat.shortLabelKey)}' : '';
  return '${_formatQty(quantity)}$unitSuffix$karatSuffix';
}

/// "117,000", "2.5", "0.1234": grouped like the app's money amounts, up to
/// four decimals with trailing zeros dropped.
String _formatQty(double value) => (NumberFormat.decimalPattern()..maximumFractionDigits = 4).format(value);
