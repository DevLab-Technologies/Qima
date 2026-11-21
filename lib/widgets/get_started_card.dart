import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/app_cubit.dart';
import '../blocs/app_state.dart';
import '../blocs/money_cubit.dart';
import '../l10n/app_localizations.dart';
import '../models/book_account.dart';
import '../models/book_entry.dart';
import '../models/setup_answers.dart';
import '../screens/add_instrument_screen.dart';
import '../screens/alerts_screen.dart';
import '../screens/money/accounts_screens.dart';
import '../screens/money/asset_screens.dart';
import '../screens/money/bank_messages_screen.dart';
import '../screens/money/entry_editor_screen.dart';
import '../services/import/bank_messages.dart';
import '../theme/design_system.dart';
import '../theme/qima_colors.dart';

/// The first steps that follow from the setup answers, for this device:
/// bank messages are left out where Qima can't read them.
List<StartTask> startTasksFor(SetupAnswers setup) => [
      for (final t in setup.tasks)
        if (t != StartTask.bankMessages || BankMessages.way != BankMessagesWay.none) t,
    ];

/// Whether [task] has been done, read from what is in the app, so a task
/// ticks itself wherever the person does it and never needs marking.
bool startTaskDone(StartTask task, AppState app, MoneyState money) => switch (task) {
      StartTask.account => money.accounts.any((a) => !a.archived && const {AccountType.cash, AccountType.debit, AccountType.credit}.contains(a.type)),
      // An account's opening balance and a valuation are not transactions
      // the person recorded.
      StartTask.transaction => money.entries.any((e) => e.template != EntryTemplate.opening && e.template != EntryTemplate.valuation),
      StartTask.holding => app.transactions.isNotEmpty,
      StartTask.asset => money.ofType(AccountType.asset).isNotEmpty,
      StartTask.alert => app.alerts.isNotEmpty,
      StartTask.bankMessages => money.settings.askedBankMessages || money.settings.messageSenders.isNotEmpty,
    };

/// Whether Home shows the Get started card: setup was answered, the card
/// was not closed, and something on it is still to do.
bool showsGetStarted(AppState app, MoneyState money) {
  final setup = app.setup;
  if (setup == null || app.getStartedDismissed || !money.loaded) return false;
  return startTasksFor(setup).any((t) => !startTaskDone(t, app, money));
}

/// Home's Get started card: the first steps for what the person said they
/// want Qima for, each opening the screen that does it. It stays until
/// every step is done or the card is closed.
class GetStartedCard extends StatelessWidget {
  const GetStartedCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final app = context.watch<AppCubit>().state;
    final money = context.watch<MoneyCubit>().state;
    final tasks = startTasksFor(app.setup ?? const SetupAnswers());
    final done = {for (final t in tasks) if (startTaskDone(t, app, money)) t};
    // Setting Qima up is the first step, already done.
    final total = tasks.length + 1;
    final finished = done.length + 1;

    return DSCard(
      padding: const EdgeInsetsDirectional.fromSTEB(DS.spaceMD, DS.spaceXS, DS.spaceXS, DS.spaceXS),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(l10n.startCardTitle, style: TextStyle(color: colors.textPrimary, fontSize: 17, fontWeight: FontWeight.w700)),
              ),
              Text(l10n.startCardProgress(finished, total), style: TextStyle(color: colors.textTertiary, fontSize: 13)),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                tooltip: l10n.startCardDismiss,
                onPressed: context.read<AppCubit>().dismissGetStarted,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(end: DS.spaceSM, bottom: DS.spaceXS),
            child: ExcludeSemantics(
              child: Row(
                children: [
                  for (var i = 0; i < total; i++)
                    Expanded(
                      child: Container(
                        height: 4,
                        margin: const EdgeInsetsDirectional.only(end: 4),
                        decoration: BoxDecoration(
                          color: i < finished ? colors.brand : colors.hairlineStrong,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          _TaskRow(label: l10n.startCardSetUp, done: true),
          for (final t in tasks)
            _TaskRow(
              label: switch (t) {
                StartTask.account => l10n.startTaskAccount,
                StartTask.transaction => l10n.startTaskTransaction,
                StartTask.holding => l10n.startTaskHolding,
                StartTask.asset => l10n.startTaskAsset,
                StartTask.alert => l10n.startTaskAlert,
                StartTask.bankMessages => l10n.startTaskBankMessages,
              },
              done: done.contains(t),
              onTap: () => _open(context, t),
            ),
        ],
      ),
    );
  }

  static void _open(BuildContext context, StartTask task) {
    switch (task) {
      case StartTask.account:
        AccountEditorScreen.open(context);
      case StartTask.transaction:
        EntryEditorScreen.open(context, EntryKind.spend);
      case StartTask.holding:
        Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const AddInstrumentScreen(start: AddStart.holding)));
      case StartTask.asset:
        AssetEditorScreen.open(context);
      case StartTask.alert:
        Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const AlertsScreen()));
      case StartTask.bankMessages:
        BankMessagesScreen.open(context);
    }
  }
}

class _TaskRow extends StatelessWidget {
  final String label;
  final bool done;
  final VoidCallback? onTap;

  const _TaskRow({required this.label, required this.done, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      checked: done,
      button: !done,
      child: InkWell(
        borderRadius: BorderRadius.circular(DS.radiusTile),
        // A finished step has nothing left to open.
        onTap: done ? null : onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Row(
            children: [
              Icon(done ? Icons.check_circle : Icons.radio_button_unchecked, color: done ? colors.brand : colors.hairlineStrong, size: 24),
              const SizedBox(width: DS.spaceSM),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: done ? colors.textTertiary : colors.textPrimary,
                    fontSize: 16,
                    fontWeight: done ? FontWeight.w400 : FontWeight.w500,
                  ),
                ),
              ),
              if (!done)
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: DS.spaceXS),
                  child: Icon(Icons.chevron_right, color: colors.textTertiary),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
