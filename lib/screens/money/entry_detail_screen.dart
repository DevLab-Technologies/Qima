import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../blocs/app_cubit.dart';
import '../../blocs/money_cubit.dart';
import '../../l10n/app_localizations.dart';
import '../../models/book_account.dart';
import '../../models/book_entry.dart';
import '../../theme/design_system.dart';
import '../../theme/money_labels.dart';
import '../../theme/qima_colors.dart';
import '../../widgets/confirm_delete_dialog.dart';
import '../../widgets/money_widgets.dart';
import 'entry_editor_screen.dart';

/// One transaction: what it was, and How it adds up (14.8), its lines in
/// words. People never see "debit" or "credit".
class EntryDetailScreen extends StatelessWidget {
  final String entryId;

  const EntryDetailScreen({super.key, required this.entryId});

  static Future<void> open(BuildContext context, String id) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => EntryDetailScreen(entryId: id)));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final hidden = context.select<AppCubit, bool>((c) => c.state.hideBalances);
    final state = context.watch<MoneyCubit>().state;
    final entry = state.entries.where((e) => e.id == entryId).firstOrNull;
    if (entry == null) {
      return Scaffold(appBar: AppBar(), body: const SizedBox.shrink());
    }
    final book = state.book;
    final s = EntrySummary.of(entry, book, l10n);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final editKind = EntryKind.forEntry(entry);
    final amountText = minorText(s.amount.abs(), s.currency, hidden: hidden);

    return ScreenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(l10n.template(entry.template)),
          actions: [
            if (editKind != null)
              IconButton(
                tooltip: l10n.entryEditTitle,
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => EntryEditorScreen.open(context, editKind, existing: entry),
              ),
            IconButton(
              tooltip: l10n.commonDelete,
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                final ok = await confirmDelete(context, title: l10n.entryDeleteTitle, message: l10n.entryDeleteMessage, confirmLabel: l10n.commonDelete);
                if (!ok || !context.mounted) return;
                await context.read<MoneyCubit>().deleteEntry(entry.id);
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.title, style: TextStyle(color: colors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700, decoration: entry.counts ? null : TextDecoration.lineThrough)),
                  const SizedBox(height: DS.space2XS),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      s.sign < 0 ? '−$amountText' : (s.sign > 0 ? '+$amountText' : amountText),
                      style: TextStyle(color: s.sign > 0 ? colors.up : colors.textPrimary, fontSize: DS.figureHero, fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(height: DS.spaceXS),
                  Text(DateFormat.yMMMMEEEEd(locale).format(entry.date), style: TextStyle(color: colors.textSecondary)),
                  if (!entry.counts) Text(l10n.entryDeclinedHelp, style: TextStyle(color: colors.textTertiary)),
                  if (entry.note.isNotEmpty) ...[
                    const SizedBox(height: DS.spaceXS),
                    Text(entry.note, style: TextStyle(color: colors.textSecondary)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: DS.spaceMD),
            MoneySection(
              title: l10n.howItAddsUp,
              children: [
                for (final line in entry.lines) _LineRow(line: line, account: book.accounts[line.accountId], hidden: hidden),
                Padding(
                  padding: const EdgeInsets.fromLTRB(DS.spaceMD, DS.spaceXS, DS.spaceMD, DS.spaceXS),
                  child: Text(_explain(entry, book.accounts, l10n), style: TextStyle(color: colors.textTertiary, fontSize: 13)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// One sentence on what the entry did to spending and net worth.
  static String _explain(BookEntry e, Map<String, BookAccount> accounts, AppLocalizations l10n) {
    if (!e.counts) return l10n.hiuDeclined;
    final sides = {for (final l in e.lines) accounts[l.accountId]?.side};
    if (sides.contains(AccountSide.spending) && e.template != EntryTemplate.refund) return l10n.hiuSpending;
    if (sides.contains(AccountSide.income)) return l10n.hiuIncome;
    if (e.template == EntryTemplate.refund) return l10n.hiuRefund;
    if (sides.contains(AccountSide.worth)) return l10n.hiuWorth;
    return l10n.hiuMove;
  }
}

class _LineRow extends StatelessWidget {
  final EntryLine line;
  final BookAccount? account;
  final bool hidden;

  const _LineRow({required this.line, required this.account, required this.hidden});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final a = account;
    final name = a == null ? line.accountId : l10n.accountName(a);
    final shown = line.amount * (a?.side.shownSign ?? 1);
    final amount = minorText(shown.abs(), line.currency, hidden: hidden);
    final words = shown >= 0 ? l10n.hiuUp(name, amount) : l10n.hiuDown(name, amount);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DS.spaceMD, vertical: DS.spaceXS),
      child: Row(
        children: [
          Icon(shown >= 0 ? Icons.arrow_upward : Icons.arrow_downward, size: 16, color: colors.textTertiary),
          const SizedBox(width: DS.spaceSM),
          Expanded(child: Text(words, style: TextStyle(color: colors.textPrimary))),
          if (a != null) Text(l10n.accountType(a.type), style: TextStyle(color: colors.textTertiary, fontSize: 12)),
        ],
      ),
    );
  }
}

/// Every transaction, newest first, with a search and a filter by template.
class AllTransactionsScreen extends StatefulWidget {
  /// Narrow to one category or account.
  final String? accountId;
  final String? title;

  /// Narrow to entries dated from [from] to [to].
  final DateTime? from;
  final DateTime? to;

  const AllTransactionsScreen({super.key, this.accountId, this.title, this.from, this.to});

  @override
  State<AllTransactionsScreen> createState() => _AllTransactionsScreenState();
}

class _AllTransactionsScreenState extends State<AllTransactionsScreen> {
  String _query = '';
  EntryTemplate? _template;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final hidden = context.select<AppCubit, bool>((c) => c.state.hideBalances);
    final state = context.watch<MoneyCubit>().state;
    final book = state.book;
    final q = _query.trim().toLowerCase();
    final all = widget.accountId == null ? state.entriesNewestFirst : state.entriesFor(widget.accountId!);
    final templates = {for (final e in all) e.template}.toList()..sort((a, b) => a.index.compareTo(b.index));
    final shown = [
      for (final e in all)
        if ((_template == null || e.template == _template) &&
            (widget.from == null || !e.date.isBefore(widget.from!)) &&
            (widget.to == null || e.date.isBefore(widget.to!)) &&
            (q.isEmpty ||
                e.merchant.toLowerCase().contains(q) ||
                e.note.toLowerCase().contains(q) ||
                e.lines.any((l) => l10n.accountName(book.accounts[l.accountId] ?? SystemAccount.rounding.account).toLowerCase().contains(q))))
          e,
    ];
    final locale = Localizations.localeOf(context).toLanguageTag();

    // Grouped by month, as statements are.
    final rows = <Widget>[];
    String? month;
    for (final e in shown) {
      final m = DateFormat.yMMMM(locale).format(e.date);
      if (m != month) {
        month = m;
        rows.add(Padding(
          padding: const EdgeInsets.fromLTRB(DS.spaceMD, DS.spaceMD, DS.spaceMD, DS.space2XS),
          child: Text(m, style: TextStyle(color: colors.textSecondary, fontWeight: FontWeight.w700)),
        ));
      }
      rows.add(EntryRow(
        entry: e,
        book: book,
        hidden: hidden,
        forAccount: widget.accountId != null && (book.accounts[widget.accountId]?.side.onBalanceSheet ?? false) ? widget.accountId : null,
        onTap: () => EntryDetailScreen.open(context, e.id),
      ));
    }

    return ScreenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(backgroundColor: Colors.transparent, title: Text(widget.title ?? l10n.allTransactions)),
        body: ListView(
          padding: const EdgeInsets.only(bottom: DS.spaceXL),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(DS.spaceMD, DS.spaceSM, DS.spaceMD, 0),
              child: TextField(
                decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: l10n.transactionsSearch, border: const OutlineInputBorder()),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            if (templates.length > 1)
              SizedBox(
                height: 52,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: DS.spaceMD, vertical: DS.spaceXS),
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: 6),
                      child: ChoiceChip(label: Text(l10n.watchlistFilterAll), selected: _template == null, onSelected: (_) => setState(() => _template = null)),
                    ),
                    for (final t in templates)
                      Padding(
                        padding: const EdgeInsetsDirectional.only(end: 6),
                        child: ChoiceChip(label: Text(l10n.template(t)), selected: _template == t, onSelected: (_) => setState(() => _template = t)),
                      ),
                  ],
                ),
              ),
            if (shown.isEmpty)
              MoneyEmpty(icon: Icons.receipt_long_outlined, title: l10n.transactionsEmptyTitle, message: l10n.transactionsEmptyMessage)
            else
              ...rows,
          ],
        ),
      ),
    );
  }
}
