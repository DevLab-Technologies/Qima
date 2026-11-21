import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/app_cubit.dart';
import '../l10n/app_localizations.dart';
import '../screens/add_instrument_screen.dart';
import '../screens/money/accounts_screens.dart';
import '../screens/money/asset_screens.dart';
import '../screens/money/entry_editor_screen.dart';
import '../screens/money/import_screens.dart';
import '../screens/money/more_money_screens.dart';
import '../theme/money_labels.dart';
import '../services/dictation_service.dart';
import '../theme/design_system.dart';
import '../theme/help_topics.dart';
import '../theme/qima_colors.dart';

/// The round + docked in the centre of the phone bottom bar, and at the top
/// of the side rail. It opens the Add sheet.
class AddButton extends StatelessWidget {
  const AddButton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return FloatingActionButton(
      heroTag: null,
      tooltip: AppLocalizations.of(context)!.addButton,
      shape: const CircleBorder(),
      backgroundColor: colors.brand,
      foregroundColor: colors.onBrand,
      elevation: 2,
      onPressed: () => showAddSheet(context),
      child: const Icon(Icons.add, size: 30),
    );
  }
}

/// Opens the Add sheet: put an asset on the watchlist, or add a holding by
/// typing, speaking or scanning a receipt. The holding row names only what
/// this device can do; a mic that's merely turned off still counts, and
/// explains itself on the Add screen.
Future<void> showAddSheet(BuildContext context) async {
  final cubit = context.read<AppCubit>();
  final tag = dictationLocaleTag(Localizations.localeOf(context));
  const unavailable = Duration(seconds: 1);
  final (dictation, scan) = await (
    cubit.dictation.availability(tag).timeout(unavailable, onTimeout: () => DictationAvailability.unsupported),
    cubit.textRecognition.isAvailable().timeout(unavailable, onTimeout: () => false),
  ).wait;
  if (!context.mounted) return;
  final choice = await showModalBottomSheet<Object>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    // A tall sheet stops below the status bar, drag handle in view.
    useSafeArea: true,
    builder: (_) => _AddSheet(canSpeak: dictation != DictationAvailability.unsupported, canScan: scan),
  );
  if (choice == null || !context.mounted) return;
  switch (choice) {
    case AddStart start:
      unawaited(Navigator.of(context).push(MaterialPageRoute(builder: (_) => AddInstrumentScreen(start: start))));
    case EntryKind kind:
      unawaited(EntryEditorScreen.open(context, kind));
    case _MoreChoice.more:
      await _showMore(context);
    case _MoreChoice.import:
      await showImportSheet(context);
  }
}

enum _MoreChoice { more, account, asset, recurring, billSplit, import }

/// Everything else that can be added, under More.
Future<void> _showMore(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;
  final choice = await showModalBottomSheet<Object>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    // A tall sheet stops below the status bar, drag handle in view.
    useSafeArea: true,
    builder: (sheetContext) {
      Widget row(IconData icon, String title, Object value) =>
          ListTile(leading: Icon(icon), title: Text(title), onTap: () => Navigator.of(sheetContext).pop(value));
      return SafeArea(
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            for (final k in [
              EntryKind.cardPayment,
              EntryKind.loanPayment,
              EntryKind.lent,
              EntryKind.borrowed,
              EntryKind.repaymentIn,
              EntryKind.repaymentOut,
              EntryKind.refund,
              EntryKind.swap,
            ])
              row(MoneyIcons.template(k.template), l10n.template(k.template), k),
            row(Icons.call_split, l10n.featBillSplit, _MoreChoice.billSplit),
            row(Icons.event_repeat, l10n.recurringAdd, _MoreChoice.recurring),
            row(Icons.account_balance_outlined, l10n.accountAdd, _MoreChoice.account),
            row(Icons.home_work_outlined, l10n.assetAdd, _MoreChoice.asset),
          ]),
        ),
      );
    },
  );
  if (choice == null || !context.mounted) return;
  switch (choice) {
    case EntryKind kind:
      unawaited(EntryEditorScreen.open(context, kind));
    case _MoreChoice.account:
      unawaited(AccountEditorScreen.open(context));
    case _MoreChoice.asset:
      unawaited(AssetEditorScreen.open(context));
    case _MoreChoice.recurring:
      unawaited(RecurringEditorScreen.open(context));
    case _MoreChoice.billSplit:
      unawaited(Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BillSplitScreen())));
  }
}

class _AddSheet extends StatelessWidget {
  final bool canSpeak;
  final bool canScan;

  const _AddSheet({required this.canSpeak, required this.canScan});

  String _holdingSubtitle(AppLocalizations l10n) => switch ((canSpeak, canScan)) {
    (true, true) => l10n.addSheetHoldingSpeakScan,
    (true, false) => l10n.addSheetHoldingSpeak,
    (false, true) => l10n.addSheetHoldingScan,
    (false, false) => l10n.addSheetHoldingType,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    void choose(Object choice) => Navigator.of(context).pop(choice);
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(DS.spaceMD, 0, DS.spaceMD, DS.spaceMD),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Choice(
                key: const ValueKey('addSheetSpend'),
                icon: Icons.swap_vert,
                title: l10n.addSheetTransaction,
                subtitle: l10n.addSheetTransactionSubtitle,
                onTap: () => choose(EntryKind.spend),
              ),
              const SizedBox(height: DS.spaceSM),
              _Choice(
                key: const ValueKey('addSheetImport'),
                icon: Icons.receipt_long_outlined,
                title: l10n.importStatement,
                subtitle: l10n.importStatementSubtitle,
                onTap: () => choose(_MoreChoice.import),
              ),
              const SizedBox(height: DS.spaceSM),
              _Choice(
                key: const ValueKey('addSheetWatch'),
                icon: Icons.list_alt_outlined,
                title: l10n.addSheetWatch,
                subtitle: l10n.addSheetWatchSubtitle,
                onTap: () => choose(AddStart.watchlist),
              ),
              const SizedBox(height: DS.spaceSM),
              _Choice(
                key: const ValueKey('addSheetHolding'),
                icon: Icons.pie_chart_outline,
                title: l10n.addHoldingTitle,
                subtitle: _holdingSubtitle(l10n),
                onTap: () => choose(AddStart.holding),
              ),
              const SizedBox(height: DS.spaceSM),
              _Choice(
                key: const ValueKey('addSheetMore'),
                icon: Icons.more_horiz,
                title: l10n.addSheetMore,
                subtitle: l10n.addSheetMoreSubtitle,
                onTap: () => choose(_MoreChoice.more),
              ),
              if (assistantSupportedOnThisPlatform)
                Padding(
                  padding: const EdgeInsets.only(top: DS.spaceMD),
                  child: Row(
                    children: [
                      Icon(Icons.record_voice_over_outlined, size: 16, color: colors.textTertiary),
                      const SizedBox(width: DS.spaceXS),
                      Expanded(
                        child: Text(l10n.addSheetSiriTip, style: TextStyle(color: colors.textTertiary, fontSize: 13)),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One of the two rows: Add to watchlist, Add holding.
class _Choice extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _Choice({super.key, required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: colors.tileTop,
      borderRadius: BorderRadius.circular(DS.radiusTile),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DS.radiusTile)),
        contentPadding: const EdgeInsets.symmetric(horizontal: DS.spaceMD, vertical: DS.spaceXS),
        leading: Icon(icon, size: 28, color: colors.brand),
        title: Text(title, style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: TextStyle(color: colors.textTertiary)),
        trailing: Icon(Icons.chevron_right, color: colors.textTertiary),
        onTap: onTap,
      ),
    );
  }
}
