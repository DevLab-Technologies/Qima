import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/import_cubit.dart';
import '../../l10n/app_localizations.dart';
import '../../services/import/bank_messages.dart';
import '../../theme/design_system.dart';
import '../../theme/qima_colors.dart';
import '../../widgets/money_widgets.dart';
import '../../theme/help_topics.dart';
import '../../widgets/help_button.dart';
import 'import_screens.dart';

/// Bank text messages into Qima: on Android Qima reads them once allowed;
/// on iOS a Shortcuts automation sends them. Either way each one waits in
/// review before anything is added.
class BankMessagesScreen extends StatefulWidget {
  const BankMessagesScreen({super.key});

  static Future<void> open(BuildContext context) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BankMessagesScreen()));

  @override
  State<BankMessagesScreen> createState() => _BankMessagesScreenState();
}

class _BankMessagesScreenState extends State<BankMessagesScreen> {
  BankMessagesStatus? _status;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    if (BankMessages.way == BankMessagesWay.readSms) {
      BankMessages.status().then((s) {
        if (mounted) setState(() => _status = s);
      });
    }
  }

  Future<void> _toggle(bool on) async {
    setState(() => _busy = true);
    final s = on ? await BankMessages.enable() : await BankMessages.disable();
    if (!mounted) return;
    setState(() {
      _status = s;
      _busy = false;
    });
    if (on && !s.granted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.bankMessagesDenied)));
    }
  }

  Future<void> _importRecent() async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final importer = context.read<ImportCubit>();
    setState(() => _busy = true);
    final n = await BankMessages.importRecent();
    await importer.checkInbox();
    if (!mounted) return;
    setState(() => _busy = false);
    messenger.showSnackBar(SnackBar(content: Text(l10n.bankMessagesFound(n))));
    if (n > 0) await ImportReviewScreen.open(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final note = TextStyle(color: colors.textTertiary, fontSize: 13);
    final status = _status;
    final children = <Widget>[
      Padding(
        padding: const EdgeInsets.only(bottom: DS.spaceMD),
        child: Text(l10n.bankMessagesIntro, style: TextStyle(color: colors.textSecondary, fontSize: 15)),
      ),
    ];
    switch (BankMessages.way) {
      case BankMessagesWay.readSms:
        children.add(MoneySection(children: [
          SwitchListTile(
            key: const ValueKey('bankMessagesSwitch'),
            value: status?.enabled ?? false,
            onChanged: status == null || _busy ? null : _toggle,
            title: Text(l10n.bankMessagesRead),
            subtitle: Text(l10n.bankMessagesReadHint),
          ),
          ListTile(
            key: const ValueKey('bankMessagesRecent'),
            enabled: (status?.granted ?? false) && !_busy,
            leading: const Icon(Icons.history),
            title: Text(l10n.bankMessagesRecent),
            subtitle: Text(l10n.bankMessagesRecentHint),
            onTap: _importRecent,
          ),
        ]));
      case BankMessagesWay.shortcutsAutomation:
        Widget numbered(List<String> steps) => Column(children: [
              for (final (i, step) in steps.indexed)
                ListTile(
                  leading: CircleAvatar(
                    radius: 13,
                    backgroundColor: colors.brand.withValues(alpha: 0.16),
                    child: Text('${i + 1}', style: TextStyle(color: colors.brandText, fontSize: 13, fontWeight: FontWeight.w700)),
                  ),
                  title: Text(step, style: const TextStyle(fontSize: 15)),
                ),
            ]);
        children.add(MoneySection(title: l10n.bankMessagesSetUp, children: [
          numbered([l10n.bankMessagesStep1, l10n.bankMessagesStep2, l10n.bankMessagesStep3, l10n.bankMessagesStep4]),
        ]));
        // Wallet's own automation: every Apple Pay payment, texted or not.
        children.add(MoneySection(key: const ValueKey('applePaySetUp'), title: l10n.applePaySetUp, children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: DS.spaceMD, vertical: DS.spaceXS),
            child: Text(l10n.applePayIntro, style: note),
          ),
          numbered([l10n.applePayStep1, l10n.applePayStep2, l10n.applePayStep3, l10n.applePayStep4]),
        ]));
        children.add(FilledButton.icon(
          key: const ValueKey('bankMessagesShortcuts'),
          onPressed: BankMessages.openShortcuts,
          icon: const Icon(Icons.open_in_new),
          label: Text(l10n.bankMessagesOpenShortcuts),
        ));
      case BankMessagesWay.none:
        children.add(Text(l10n.bankMessagesUnavailable, style: note));
    }
    children.add(Padding(
      padding: const EdgeInsets.only(top: DS.spaceMD),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(Icons.lock_outline, size: 14, color: colors.textTertiary),
        const SizedBox(width: DS.spaceXS),
        Expanded(child: Text(l10n.bankMessagesPrivacy, style: note)),
      ]),
    ));
    return Scaffold(
      appBar: AppBar(title: Text(l10n.bankMessagesTitle), actions: const [HelpButton(topic: HelpTopicId.bankMessages)]),
      body: ListView(padding: const EdgeInsets.fromLTRB(DS.spaceMD, DS.spaceSM, DS.spaceMD, DS.spaceLG), children: children),
    );
  }
}
