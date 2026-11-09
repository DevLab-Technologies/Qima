import 'dart:async';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../blocs/import_cubit.dart';
import '../../blocs/money_cubit.dart';
import '../../l10n/app_localizations.dart';
import '../../models/book.dart';
import '../../models/book_account.dart';
import '../../models/book_entry.dart';
import '../../models/categorizer.dart';
import '../../models/entry_builder.dart';
import '../../models/import_plan.dart';
import '../../models/minor_units.dart';
import '../../models/statement_facts.dart';
import '../../models/statement_reader.dart';
import '../../services/import/bank_messages.dart';
import '../../services/import/pasted_files.dart';
import '../../services/import/statement_files.dart';
import '../../theme/design_system.dart';
import '../../theme/money_labels.dart';
import '../../theme/qima_colors.dart';
import '../../widgets/money_widgets.dart';
import '../../theme/help_topics.dart';
import '../../widgets/help_button.dart';
import 'accounts_screens.dart';
import 'bank_messages_screen.dart';

/// Import a statement: from Files (PDF, Excel, CSV), screenshots from
/// Photos, or whatever of those is on the clipboard. Share › Qima from another app
/// lands in the same place.
Future<void> showImportSheet(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;
  final importer = context.read<ImportCubit>();
  final canPaste = await PastedFiles.available();
  if (!context.mounted) return;
  // The system Paste button hands the content over while the sheet, the
  // top route of this navigator, is open.
  final navigator = Navigator.of(context);
  if (canPaste) {
    PastedFiles.listen((files) {
      PastedFiles.stopListening();
      navigator.pop(files);
    });
  }
  final choice = await showModalBottomSheet<Object>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheet) => SafeArea(
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: Text(l10n.importFromFiles),
            subtitle: Text(l10n.importFromFilesHint),
            onTap: () => Navigator.of(sheet).pop('files'),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: Text(l10n.importFromPhotos),
            subtitle: Text(l10n.importFromPhotosHint),
            onTap: () => Navigator.of(sheet).pop('photos'),
          ),
          if (canPaste)
            ListTile(
              key: const ValueKey('importPaste'),
              leading: const Icon(Icons.content_paste_outlined),
              title: Text(l10n.importFromClipboard),
              subtitle: Text(l10n.importFromClipboardHint),
              trailing: PastedFiles.button(background: sheet.colors.brand, foreground: sheet.colors.onBrand),
            ),
          if (BankMessages.way != BankMessagesWay.none)
            ListTile(
              key: const ValueKey('importBankMessages'),
              leading: const Icon(Icons.sms_outlined),
              title: Text(l10n.bankMessagesEntry),
              subtitle: Text(l10n.bankMessagesEntryHint),
              onTap: () => Navigator.of(sheet).pop('messages'),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(DS.spaceMD, DS.spaceXS, DS.spaceMD, DS.spaceMD),
            child: Row(children: [
              Icon(Icons.ios_share, size: 16, color: sheet.colors.textTertiary),
              const SizedBox(width: DS.spaceXS),
              Expanded(child: Text(l10n.importShareTip, style: TextStyle(color: sheet.colors.textTertiary, fontSize: 13))),
            ]),
          ),
        ]),
      ),
    ),
  );
  if (canPaste) PastedFiles.stopListening();
  if (choice == null || !context.mounted) return;
  if (choice == 'messages') return BankMessagesScreen.open(context);
  final picked = <(String, List<int>)>[];
  if (choice == 'files') {
    final files = await openFiles(acceptedTypeGroups: [
      XTypeGroup(
        label: l10n.importStatement,
        extensions: const ['pdf', 'csv', 'tsv', 'xlsx', 'txt', ...StatementFiles.images],
        uniformTypeIdentifiers: const [
          'com.adobe.pdf',
          'public.comma-separated-values-text',
          'public.tab-separated-values-text',
          'org.openxmlformats.spreadsheetml.sheet',
          'public.plain-text',
          'public.image',
        ],
      ),
    ]);
    for (final f in files) {
      picked.add((f.name, await f.readAsBytes()));
    }
  } else if (choice is List<PastedFile>) {
    final when = DateFormat('yyyy-MM-dd HH.mm').format(DateTime.now());
    for (final f in choice) {
      final name = f.name ?? '${l10n.importPastedName} $when';
      picked.add((name.toLowerCase().endsWith('.${f.extension}') ? name : '$name.${f.extension}', f.bytes));
    }
  } else {
    final images = await ImagePicker().pickMultiImage(requestFullMetadata: false);
    for (final f in images) {
      picked.add((f.name, await f.readAsBytes()));
    }
  }
  if (picked.isEmpty || !context.mounted) return;
  unawaited(importer.addFiles(picked));
  unawaited(ImportReviewScreen.open(context));
}

/// On Home while something shared to Qima is being read or waits for
/// review.
class ImportBanner extends StatelessWidget {
  const ImportBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = maybeImportCubit(context);
    if (cubit == null) return const SizedBox.shrink();
    return BlocBuilder<ImportCubit, ImportState>(bloc: cubit, builder: (context, state) => _banner(context, state));
  }

  Widget _banner(BuildContext context, ImportState state) {
    if (state.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final waiting = state.items.where((i) => !i.done).length;
    return Padding(
      padding: const EdgeInsets.only(bottom: DS.spaceMD),
      child: DSCard(
        padding: EdgeInsets.zero,
        child: InkWell(
          key: const ValueKey('importBanner'),
          onTap: () => ImportReviewScreen.open(context),
          child: Padding(
            padding: const EdgeInsets.all(DS.spaceMD),
            child: Row(children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: colors.brand.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(12)),
                child: state.reading
                    ? Padding(padding: const EdgeInsets.all(11), child: CircularProgressIndicator(strokeWidth: 2, color: colors.brandText))
                    : Icon(Icons.inbox_outlined, color: colors.brandText),
              ),
              const SizedBox(width: DS.spaceSM),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(l10n.importBannerTitle, style: TextStyle(color: colors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700)),
                  Text(
                    state.reading
                        ? l10n.importReadingFiles(waiting)
                        // A screenshot of an account screen: a balance and no rows.
                        : state.rowCount == 0 && state.items.any((i) => i.facts.closing != null)
                            ? l10n.importReadyBalance
                            : l10n.importReadyRows(state.rowCount),
                    style: TextStyle(color: colors.textSecondary, fontSize: 13),
                  ),
                ]),
              ),
              Icon(Icons.chevron_right, color: colors.textTertiary),
            ]),
          ),
        ),
      ),
    );
  }
}

/// Everything read from the files in the inbox, ticked where Qima is
/// fairly sure, for the person to check before anything is added.
class ImportReviewScreen extends StatefulWidget {
  const ImportReviewScreen({super.key});

  static Future<void> open(BuildContext context) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ImportReviewScreen()));

  @override
  State<ImportReviewScreen> createState() => _ImportReviewScreenState();
}

class _ImportReviewScreenState extends State<ImportReviewScreen> {
  String? _accountId;
  final Map<String, bool> _ticked = {};
  final Map<String, bool> _isIn = {};
  final Map<String, String> _category = {};

  /// Rows the person corrected (name, amount, date), by candidate key.
  final Map<String, StatementRow> _edited = {};
  bool? _fixBalance;
  BalanceWay _balanceWay = BalanceWay.opening;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final money = context.watch<MoneyCubit>().state;
    final imports = context.watch<ImportCubit>().state;
    final accounts = money.balanceAccounts.where(ImportPlanner.canHoldStatement).toList();
    final allRows = [for (final i in imports.items) ...i.rows];
    final refs = [for (final i in imports.items) ...i.facts.refs];
    final account =
        accounts.where((a) => a.id == _accountId).firstOrNull ?? ImportPlanner.guessAccount(accounts, allRows, money.entries, refs: refs);

    final candidates = account == null
        ? const <ImportCandidate>[]
        : ImportPlanner.plan(files: [for (final i in imports.items) (i.id, _rowsOf(i))], account: account, book: money.book, rules: money.settings.categoryRules);
    final byFile = <String, List<ImportCandidate>>{};
    for (final c in candidates) {
      (byFile[c.fileId] ??= []).add(c);
    }
    bool ticked(ImportCandidate c) => _ticked[c.key] ?? c.suggested;
    final chosen = [for (final c in candidates) if (ticked(c)) c];
    final balance = account == null || imports.reading ? null : _balance(account, chosen, imports, money.book, context.read<MoneyCubit>().builder);
    // A statement or loan screen with no new rows can still set the balance.
    final applyBalance = balance != null && (_fixBalance ?? balance.suggested);

    final body = <Widget>[];
    if (account == null) {
      body.add(MoneyEmpty(
        icon: Icons.account_balance_outlined,
        title: l10n.importNoAccountTitle,
        message: l10n.importNoAccountBody,
        action: l10n.accountAdd,
        onAction: () => AccountEditorScreen.open(context, types: const [AccountType.debit, AccountType.credit, AccountType.cash]),
      ));
    } else {
      body.add(Padding(
        padding: const EdgeInsets.only(bottom: DS.spaceSM),
        child: AccountPicker(
          key: ValueKey('importAccount-${account.id}'),
          label: l10n.importIntoAccount,
          accounts: accounts,
          value: account,
          onChanged: (a) => setState(() {
            _accountId = a?.id;
            _fixBalance = null;
            _balanceWay = BalanceWay.opening;
          }),
        ),
      ));
      if (balance != null) body.add(_balanceTile(account, balance));
    }
    body.add(Padding(
      padding: const EdgeInsets.only(bottom: DS.spaceMD),
      child: Row(children: [
        Icon(Icons.lock_outline, size: 14, color: colors.textTertiary),
        const SizedBox(width: DS.spaceXS),
        Expanded(child: Text(l10n.importReadOnDevice, style: TextStyle(color: colors.textTertiary, fontSize: 12))),
      ]),
    ));
    if (imports.isEmpty) {
      body.add(MoneyEmpty(icon: Icons.inbox_outlined, title: l10n.importEmpty, message: l10n.importShareTip));
    }

    for (final item in imports.items) {
      final rows = byFile[item.id] ?? const <ImportCandidate>[];
      final status = switch (item.status) {
        ImportStatus.waiting => l10n.importStatusWaiting,
        ImportStatus.reading => l10n.importStatusReading,
        ImportStatus.alreadyImported => l10n.importStatusAlready,
        ImportStatus.unsupported => l10n.importStatusUnsupported,
        ImportStatus.unreadable => l10n.importStatusUnreadable,
        ImportStatus.read => item.rows.isEmpty ? l10n.importStatusNothing : l10n.importRowFound(item.rows.length),
      };
      body.add(MoneySection(
        title: item.file.name,
        trailing: IconButton(
          tooltip: l10n.importRemoveFile,
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.close, size: 18),
          onPressed: _saving ? null : () => context.read<ImportCubit>().remove([item.id]),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(DS.spaceMD, 0, DS.spaceMD, DS.spaceXS),
            child: Row(children: [
              if (!item.done) ...[
                const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 1.5)),
                const SizedBox(width: DS.spaceXS),
              ],
              Expanded(child: Text(status, style: TextStyle(color: colors.textTertiary, fontSize: 12))),
            ]),
          ),
          if (item.status == ImportStatus.read && !item.facts.isEmpty)
            _FactsLine(
              facts: item.facts,
              // The check runs on what will be added: the ticked rows, as
              // corrected, each the way it was set to go.
              rows: [
                for (final c in rows)
                  if (ticked(c)) c.row.copyWith(amount: (_isIn[c.key] ?? c.row.isIn) ? c.row.amount.abs() : -c.row.amount.abs()),
              ],
              currency: item.facts.currency ?? account?.currency ?? '',
            ),
          if (account != null)
            for (final c in rows)
              _CandidateRow(
                candidate: c,
                currency: c.row.currency ?? account.currency ?? '',
                ticked: ticked(c),
                isIn: _isIn[c.key] ?? c.row.isIn,
                categoryName: _categoryName(l10n, money.book.accounts[_category[c.key] ?? c.categoryId] ?? money.book.accounts.values.first),
                onTicked: (v) => setState(() => _ticked[c.key] = v),
                onTap: () => _edit(c, money, account),
              ),
        ],
      ));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.importReviewTitle),
        actions: [
          const HelpButton(topic: HelpTopicId.importStatement),
          if (!imports.isEmpty)
            TextButton(onPressed: _saving ? null : () => _discardAll(imports), child: Text(l10n.importDiscardAll)),
        ],
      ),
      body: ListView(padding: const EdgeInsets.fromLTRB(DS.spaceMD, DS.spaceSM, DS.spaceMD, DS.spaceLG), children: body),
      bottomNavigationBar: account == null || imports.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(DS.spaceMD, DS.spaceXS, DS.spaceMD, DS.spaceSM),
                child: FilledButton(
                  key: const ValueKey('importAdd'),
                  onPressed: _saving || (chosen.isEmpty && imports.reading)
                      ? null
                      : chosen.isEmpty && !applyBalance
                          ? () => _discardAll(imports)
                          : () => _add(account, chosen, imports),
                  child: Text(chosen.isNotEmpty
                      ? l10n.importAddCount(chosen.length)
                      : applyBalance
                          ? l10n.importApplyBalance
                          : l10n.importDiscardAll),
                ),
              ),
            ),
    );
  }

  /// A file's rows with the person's corrections in.
  List<StatementRow> _rowsOf(ImportItem item) => [
        for (var i = 0; i < item.rows.length; i++) _edited['${item.id}:$i'] ?? item.rows[i],
      ];

  String _categoryName(AppLocalizations l10n, BookAccount a) =>
      a.side.onBalanceSheet ? l10n.importTransferWith(l10n.accountName(a)) : l10n.accountName(a);

  /// Lets the person correct a row before it is added: its name, amount,
  /// date and direction, and what it is (a category, or a move to or from
  /// another of their accounts).
  Future<void> _edit(ImportCandidate c, MoneyState money, BookAccount account) async {
    final l10n = AppLocalizations.of(context)!;
    final currency = account.currency ?? 'SAR';
    var isIn = _isIn[c.key] ?? c.row.isIn;
    var category = _category[c.key] ?? c.categoryId;
    var date = c.row.date;
    final nameText = c.row.description.isEmpty ? c.row.detail : c.row.description;
    final amountText = minorFieldText(MinorUnits.fromMajor(c.row.amount.abs(), currency), currency);
    final others = ImportPlanner.counterparts(money.balanceAccounts, account);
    final result = await showModalBottomSheet<(bool, String, StatementRow)>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _SheetFields(name: nameText, amount: amountText, builder: (sheet, name, amount) => StatefulBuilder(builder: (sheet, setSheet) {
        final side = isIn ? AccountSide.income : AccountSide.spending;
        final cats = money.categories(side);
        // Money back from a shop keeps its spending category (a refund).
        final options = isIn ? [...cats, ...money.categories(AccountSide.spending)] : cats;
        if (!options.any((a) => a.id == category) && !others.any((a) => a.id == category)) category = cats.firstOrNull?.id ?? category;
        StatementRow? edited() {
          final minor = parseMinor(amount.text, currency);
          if (minor == null || minor <= 0) return null;
          final text = name.text.trim();
          final major = MinorUnits.toMajor(minor, currency);
          final changedName = text != nameText;
          return StatementRow(
            date: date,
            dateGuessed: c.row.dateGuessed && date == c.row.date,
            description: changedName ? text : c.row.description,
            detail: changedName ? '' : c.row.detail,
            amount: isIn ? major : -major,
            signGuessed: false,
            currency: c.row.currency,
            balance: c.row.balance,
            line: c.row.line,
            doubtful: c.row.doubtful,
          );
        }

        void done(String id) {
          final row = edited();
          if (row == null) return;
          Navigator.of(sheet).pop((isIn, id, row));
        }

        Widget tile(BookAccount a, {required String title}) => ListTile(
              key: ValueKey('importPick-${a.id}'),
              leading: Icon(MoneyIcons.account(a)),
              title: Text(title),
              trailing: a.id == category ? Icon(Icons.check, color: sheet.colors.brandText) : null,
              onTap: () => done(a.id),
            );
        final heading = TextStyle(color: sheet.colors.textSecondary, fontSize: 13, fontWeight: FontWeight.w700);
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(sheet).bottom),
            child: ListView(shrinkWrap: true, padding: const EdgeInsets.only(bottom: DS.spaceMD), children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: DS.spaceMD),
                child: Row(children: [
                  Expanded(child: Text(l10n.importEditRow, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700))),
                  TextButton(key: const ValueKey('importRowDone'), onPressed: () => done(category), child: Text(l10n.commonDone)),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(DS.spaceMD, DS.spaceSM, DS.spaceMD, 0),
                child: TextField(
                  key: const ValueKey('importRowName'),
                  controller: name,
                  decoration: InputDecoration(labelText: l10n.importRowName, border: const OutlineInputBorder()),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(DS.spaceMD, DS.spaceSM, DS.spaceMD, 0),
                child: AmountField(key: const ValueKey('importRowAmount'), controller: amount, label: l10n.entryAmount, currency: currency),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(DS.spaceMD, DS.spaceSM, DS.spaceMD, 0),
                child: DateField(label: l10n.entryDate, value: date, onChanged: (d) => setSheet(() => date = DateTime(d.year, d.month, d.day, date.hour, date.minute))),
              ),
              Padding(
                padding: const EdgeInsets.all(DS.spaceMD),
                child: SegmentedButton<bool>(
                  segments: [
                    ButtonSegment(value: false, label: Text(l10n.moneyOut), icon: const Icon(Icons.north_east, size: 16)),
                    ButtonSegment(value: true, label: Text(l10n.moneyIn), icon: const Icon(Icons.south_west, size: 16)),
                  ],
                  selected: {isIn},
                  onSelectionChanged: (v) => setSheet(() {
                    isIn = v.first;
                    if (others.any((a) => a.id == category)) return;
                    category = ImportPlanner.guessCategory(c.row.description,
                            detail: c.row.detail, isIn: isIn, categorizer: Categorizer(money.book, rules: money.settings.categoryRules))
                        .categoryId;
                  }),
                ),
              ),
              if (others.isNotEmpty) ...[
                Padding(padding: const EdgeInsets.symmetric(horizontal: DS.spaceMD), child: Text(l10n.importBetweenAccounts, style: heading)),
                for (final a in others) tile(a, title: l10n.accountName(a)),
                const SizedBox(height: DS.spaceSM),
              ],
              Padding(padding: const EdgeInsets.symmetric(horizontal: DS.spaceMD), child: Text(l10n.importCategory, style: heading)),
              for (final a in options) tile(a, title: l10n.accountName(a)),
            ]),
          ),
        );
      })),
    );
    if (result == null || !mounted) return;
    setState(() {
      _isIn[c.key] = result.$1;
      _category[c.key] = result.$2;
      if (result.$3 != c.row) _edited[c.key] = result.$3;
      _ticked[c.key] = true;
    });
  }

  Future<void> _add(BookAccount account, List<ImportCandidate> chosen, ImportState imports) async {
    final l10n = AppLocalizations.of(context)!;
    final money = context.read<MoneyCubit>();
    final importer = context.read<ImportCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _saving = true);
    try {
      final book = money.state.book;
      final builder = money.builder;
      final entries = _entries(account, chosen, book, builder);
      final balance = _balance(account, chosen, imports, book, builder, entries: entries);
      final fix = balance != null && (_fixBalance ?? balance.suggested) ? balance.entry : null;
      final finished = [for (final i in imports.items) if (i.done) i];
      await money.importEntries([...entries, ?fix], fileHashes: [for (final i in finished) if (i.status == ImportStatus.read) ?i.hash]);
      await _keepRefs(money, account, [for (final i in finished) if (i.status == ImportStatus.read) i.facts]);
      await money.learnCategories(_picked(chosen, book));
      await importer.remove(finished.map((i) => i.id));
      if (entries.isNotEmpty) messenger.showSnackBar(SnackBar(content: Text(l10n.importAdded(entries.length))));
      if (importer.state.isEmpty) navigator.pop();
    } on BookRejected catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.issues.map((i) => i.detail).join('\n'))));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  /// The categories the person picked over the guess, to use for those
  /// merchants next time.
  Map<String, String> _picked(List<ImportCandidate> chosen, Book book) {
    final out = <String, String>{};
    for (final c in chosen) {
      final picked = _category[c.key];
      final category = picked == null ? null : book.accounts[picked];
      if (category == null || picked == c.categoryId || Categorizer.isUncategorized(picked!) || category.side.onBalanceSheet) continue;
      var key = Categorizer.merchantKey(c.row.description);
      if (key.isEmpty) key = Categorizer.merchantKey(c.row.detail);
      if (key.isNotEmpty) out[Categorizer.ruleKey(key, isIn: category.side == AccountSide.income)] = category.id;
    }
    return out;
  }

  List<BookEntry> _entries(BookAccount account, List<ImportCandidate> chosen, Book book, EntryBuilder builder) => [
        for (final c in chosen)
          ImportPlanner.entryFor(
            builder: builder,
            account: account,
            category: book.accounts[_category[c.key] ?? c.categoryId]!,
            row: c.row,
            isIn: _isIn[c.key] ?? c.row.isIn,
          ),
      ];

  /// The entry that brings [account] to the statement's closing balance
  /// with the ticked rows in, and the figures to explain it. Null when the
  /// statements give no balance or the book already agrees.
  _BalanceFix? _balance(BookAccount account, List<ImportCandidate> chosen, ImportState imports, Book book, EntryBuilder builder,
      {List<BookEntry>? entries}) {
    final readFiles = [for (final i in imports.items) if (i.status == ImportStatus.read) i];
    final balance = ImportPlanner.statementBalance([for (final i in readFiles) (i.facts, i.rows)], account);
    if (balance == null) return null;
    final added = entries ?? _entries(account, chosen, book, builder);
    final fix = ImportPlanner.balanceEntry(builder: builder, book: book, account: account, added: added, balance: balance, way: _balanceWay);
    if (fix == null) return null;
    return _BalanceFix(fix.entry, balance, account.currency ?? '',
        delta: fix.statement - fix.tracked, tracked: fix.tracked, opening: fix.fresh, balanceOnly: readFiles.every((i) => i.rows.isEmpty));
  }

  Widget _balanceTile(BookAccount account, _BalanceFix fix) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final locale = Localizations.localeOf(context).toLanguageTag();
    String amount(int minor) => moneyText(MinorUnits.toMajor(minor, fix.currency), fix.currency, hidden: false);
    final on = _fixBalance ?? fix.suggested;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CheckboxListTile(
          key: const ValueKey('importBalance'),
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          value: on,
          onChanged: _saving ? null : (v) => setState(() => _fixBalance = v ?? false),
          title: Text(
            fix.opening ? l10n.importOpeningBalance(amount(fix.delta)) : l10n.importMatchBalance(amount(fix.delta + fix.tracked)),
            style: TextStyle(color: colors.textPrimary, fontSize: 15, fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            l10n.importBalanceDetail(DateFormat.yMMMd(locale).format(fix.balance.date), amount(fix.tracked)),
            style: TextStyle(color: colors.textTertiary, fontSize: 12),
          ),
        ),
        // A first balance is simply the opening; a later one can be either.
        if (on && !fix.opening)
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 40),
            child: BalanceWayPicker(value: _balanceWay, onChanged: _saving ? null : (w) => setState(() => _balanceWay = w)),
          ),
      ],
    );
  }

  /// Remembers the statement's account or card number on [account], and
  /// takes it off any other account, so the next statement from it is
  /// matched straight away.
  Future<void> _keepRefs(MoneyCubit money, BookAccount account, List<StatementFacts> files) async {
    final keep = ImportPlanner.refsToKeep(files);
    if (keep.isEmpty) return;
    final current = money.state.book.accounts[account.id] ?? account;
    if (keep.every(current.statementRefs.contains)) return;
    await money.giveStatementRefs(current, {...current.statementRefs, ...keep}.toList());
  }

  Future<void> _discardAll(ImportState imports) async {
    final l10n = AppLocalizations.of(context)!;
    final importer = context.read<ImportCubit>();
    final navigator = Navigator.of(context);
    final yes = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        content: Text(l10n.importDiscardConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.of(d).pop(false), child: Text(l10n.commonCancel)),
          TextButton(onPressed: () => Navigator.of(d).pop(true), child: Text(l10n.importDiscard)),
        ],
      ),
    );
    if (yes != true) return;
    await importer.remove(imports.items.map((i) => i.id));
    if (mounted) navigator.pop();
  }
}

/// Owns the row editor's text fields for as long as the sheet is on
/// screen, closing animation included.
class _SheetFields extends StatefulWidget {
  final String name;
  final String amount;
  final Widget Function(BuildContext context, TextEditingController name, TextEditingController amount) builder;

  const _SheetFields({required this.name, required this.amount, required this.builder});

  @override
  State<_SheetFields> createState() => _SheetFieldsState();
}

class _SheetFieldsState extends State<_SheetFields> {
  late final _name = TextEditingController(text: widget.name);
  late final _amount = TextEditingController(text: widget.amount);

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _name, _amount);
}

/// What a matched entry is called on a flag: its merchant, else the text
/// it arrived as, else "Transaction".
String _matchName(AppLocalizations l10n, BookEntry? e) {
  if (e == null) return l10n.importEditRow;
  if (e.merchant.trim().isNotEmpty) return e.merchant.trim();
  if (e.rawMerchant.trim().isNotEmpty) return e.rawMerchant.trim();
  return l10n.importEditRow;
}

class _CandidateRow extends StatelessWidget {
  final ImportCandidate candidate;
  final String currency;
  final bool ticked;
  final bool isIn;
  final String categoryName;
  final ValueChanged<bool> onTicked;
  final VoidCallback onTap;

  const _CandidateRow({
    required this.candidate,
    required this.currency,
    required this.ticked,
    required this.isIn,
    required this.categoryName,
    required this.onTicked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final row = candidate.row;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final notes = <(String, bool)>[
      if (candidate.flag == ImportFlag.inBook) (l10n.importFlagInBook, true),
      if (candidate.flag == ImportFlag.maybeInBook)
        (l10n.importFlagMaybeInBook(_matchName(l10n, candidate.match), DateFormat.MMMd(locale).format(candidate.match?.date ?? row.date)), true),
      if (candidate.flag == ImportFlag.repeated) (l10n.importFlagRepeated, true),
      if (candidate.flag == ImportFlag.otherCurrency) (l10n.importFlagCurrency(row.currency ?? ''), true),
      if (candidate.flag == ImportFlag.notTransaction) (l10n.importFlagNotTransaction, true),
      if (row.signGuessed && candidate.flag == null) (l10n.importSignGuessed, false),
      if (row.dateGuessed) (l10n.importDateGuessed, false),
    ];
    final amount = moneyText(row.amount.abs(), currency, hidden: false);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(DS.spaceXS, DS.space2XS, DS.spaceMD, DS.space2XS),
        child: LayoutBuilder(builder: (context, constraints) => Row(children: [
          Checkbox(value: ticked, onChanged: (v) => onTicked(v ?? false)),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(row.description.isEmpty ? row.detail : row.description,
                  maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: colors.textPrimary, fontSize: 15, fontWeight: FontWeight.w500)),
              Text('${DateFormat.yMMMd(locale).format(row.date)} · $categoryName',
                  maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: colors.textTertiary, fontSize: 12)),
              for (final (text, warn) in notes)
                Text(text, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: warn ? colors.down : colors.brandText, fontSize: 12)),
            ]),
          ),
          const SizedBox(width: DS.spaceSM),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.4),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerEnd,
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: Text(isIn ? '+$amount' : '-$amount',
                    maxLines: 1, style: TextStyle(color: isIn ? colors.up : colors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ])),
      ),
    );
  }
}

/// A balance entry offered on the review screen, with what it explains.
class _BalanceFix {
  final BookEntry entry;
  final StatementBalance balance;
  final String currency;

  /// What the entry adds to the account, as people read it, in minor units.
  final int delta;

  /// The account's balance on the statement's last day without the entry.
  final int tracked;

  /// The files gave a balance and no transactions, such as a screenshot of
  /// a banking app's account screen: setting the balance is why they came.
  final bool balanceOnly;

  /// The account had nothing before this import: the entry is its opening
  /// balance.
  final bool opening;

  const _BalanceFix(this.entry, this.balance, this.currency, {required this.delta, required this.tracked, required this.opening, required this.balanceOnly});

  /// Offered ticked: an opening balance, or a balance that came alone.
  /// A correction next to imported rows stays unticked, as the rows may
  /// already explain it.
  bool get suggested => opening || balanceOnly;
}

/// What a statement says about itself, under its file name: the account,
/// the period, the balances and whether the rows read add up to them.
class _FactsLine extends StatelessWidget {
  final StatementFacts facts;
  final List<StatementRow> rows;
  final String currency;

  const _FactsLine({required this.facts, required this.rows, required this.currency});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final locale = Localizations.localeOf(context).toLanguageTag();
    String amount(double v) => moneyText(v, currency, hidden: false);
    final from = facts.from, to = facts.to;
    final about = [
      for (final r in facts.refs.take(2))
        switch (r.kind) {
          StatementRefKind.card => l10n.importRefCard(r.last4),
          StatementRefKind.account => l10n.importRefAccount(r.last4),
          StatementRefKind.iban => l10n.importRefIban(r.last4),
        },
      if (from != null && to != null) '${DateFormat.yMMMd(locale).format(from)} – ${DateFormat.yMMMd(locale).format(to)}',
    ];
    final opening = facts.opening, closing = facts.closing;
    final check = Reconciliation.of(facts, [for (final r in rows) if (!r.doubtful) r]);
    final style = TextStyle(color: colors.textTertiary, fontSize: 12);
    return Padding(
      padding: const EdgeInsets.fromLTRB(DS.spaceMD, 0, DS.spaceMD, DS.spaceXS),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (about.isNotEmpty) Text(about.join(' · '), maxLines: 2, overflow: TextOverflow.ellipsis, style: style),
        if (opening != null && closing != null)
          Text(l10n.importBalances(amount(opening), amount(closing)), maxLines: 2, overflow: TextOverflow.ellipsis, style: style),
        if (check != null)
          Row(children: [
            Icon(check.addsUp ? Icons.check_circle_outline : Icons.error_outline, size: 14, color: check.addsUp ? colors.up : colors.down),
            const SizedBox(width: DS.spaceXS),
            Expanded(
              child: Text(check.addsUp ? l10n.importAddsUp : l10n.importGap(amount(check.gap.abs())),
                  maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: check.addsUp ? colors.up : colors.down, fontSize: 12)),
            ),
          ]),
      ]),
    );
  }
}
