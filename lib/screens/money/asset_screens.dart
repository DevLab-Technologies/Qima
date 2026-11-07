import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../blocs/app_cubit.dart';
import '../../blocs/money_cubit.dart';
import '../../l10n/app_localizations.dart';
import '../../models/book_account.dart';
import '../../models/net_worth.dart';
import '../../theme/design_system.dart';
import '../../theme/money_labels.dart';
import '../../theme/qima_colors.dart';
import '../../widgets/confirm_delete_dialog.dart';
import '../../widgets/currency_field.dart';
import '../../widgets/money_widgets.dart';
import '../../theme/help_topics.dart';
import '../../widgets/help_button.dart';
import 'entry_detail_screen.dart';

/// 14.1 Property and more: the assets the person values themselves, with
/// their total. 14.7 when there are none.
class AssetsScreen extends StatelessWidget {
  const AssetsScreen({super.key});

  static Future<void> open(BuildContext context) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AssetsScreen()));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final app = context.select<AppCubit, (bool, String)>((c) => (c.state.hideBalances, c.state.baseCurrency));
    final rates = context.read<AppCubit>().state.rates;
    final (hidden, base) = app;
    final state = context.watch<MoneyCubit>().state;
    final book = state.book;
    final assets = state.ofType(AccountType.asset);
    final summary = NetWorthSummary.of(book: book, holdingsValue: 0, currency: base, rates: rates);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final money = context.read<MoneyCubit>();

    return ScreenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(l10n.sheetAssets),
          actions: [const HelpButton(topic: HelpTopicId.assets), IconButton(tooltip: l10n.assetAdd, icon: const Icon(Icons.add), onPressed: () => AssetEditorScreen.open(context))],
        ),
        body: ListView(
          padding: const EdgeInsets.all(DS.spaceMD),
          children: assets.isEmpty
              ? [
                  MoneyEmpty(
                    icon: Icons.home_work_outlined,
                    title: l10n.assetsEmptyTitle,
                    message: l10n.assetsEmptyMessage,
                    action: l10n.assetAdd,
                    onAction: () => AssetEditorScreen.open(context),
                  ),
                ]
              : [
                  DSHeroCard(
                    accent: colors.brand,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.assetsTotal, style: TextStyle(color: colors.textTertiary, fontSize: 12)),
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Text(moneyText(summary.group(SheetGroup.assets).amount, base, hidden: hidden),
                              style: TextStyle(color: colors.textPrimary, fontSize: DS.figureHero, fontWeight: FontWeight.w800)),
                        ),
                        Text(l10n.assetsTotalHelp, style: TextStyle(color: colors.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(height: DS.spaceMD),
                  MoneySection(
                    children: [
                      for (final a in assets)
                        Builder(builder: (context) {
                          final history = money.valueHistory(a.id);
                          final updated = history.isEmpty ? null : history.last.$1;
                          return MoneyRow(
                            icon: MoneyIcons.account(a),
                            title: a.name,
                            subtitle: [
                              l10n.assetKind(a.assetKind ?? AssetKind.other),
                              if (updated != null) l10n.assetUpdated(DateFormat.yMMMd(locale).format(updated)),
                              if (!a.countsInNetWorth) l10n.accountLeftOut,
                            ].join(' · '),
                            trailing: minorText(book.balanceOf(a.id), a.currency!, hidden: hidden),
                            onTap: () => AssetDetailScreen.open(context, a.id),
                          );
                        }),
                    ],
                  ),
                ],
        ),
      ),
    );
  }
}

/// 14.2 and 14.3: add an asset (kind first, then the form), or edit one.
/// Only the name and today's value are needed.
class AssetEditorScreen extends StatefulWidget {
  final BookAccount? existing;

  const AssetEditorScreen({super.key, this.existing});

  static Future<void> open(BuildContext context, {BookAccount? existing}) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => AssetEditorScreen(existing: existing)));

  @override
  State<AssetEditorScreen> createState() => _AssetEditorScreenState();
}

class _AssetEditorScreenState extends State<AssetEditorScreen> {
  final _name = TextEditingController();
  final _value = TextEditingController();
  final _cost = TextEditingController();
  final _note = TextEditingController();
  AssetKind? _kind;
  late String _currency;
  DateTime? _bought;
  String? _loanId;
  bool _counts = true;
  bool _forSale = false;
  String? _error;

  bool get _editing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _currency = e?.currency ?? context.read<AppCubit>().state.baseCurrency;
    if (e != null) {
      _kind = e.assetKind ?? AssetKind.other;
      _name.text = e.name;
      _note.text = e.note;
      _bought = e.boughtOn;
      _loanId = e.securedLoanId;
      _counts = e.countsInNetWorth;
      _forSale = e.heldForSale;
      if (e.cost != null) _cost.text = minorFieldText(e.cost!, _currency);
    }
  }

  @override
  void dispose() {
    for (final c in [_name, _value, _cost, _note]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final money = context.read<MoneyCubit>();
    final name = _name.text.trim();
    if (name.isEmpty) return setState(() => _error = l10n.accountErrorName);
    final cost = _cost.text.trim().isEmpty ? null : parseMinor(_cost.text, _currency);
    final e = widget.existing;
    if (e != null) {
      await money.updateAccount(e.copyWith(
        name: name,
        assetKind: _kind,
        boughtOn: _bought,
        clearBoughtOn: _bought == null,
        cost: cost,
        clearCost: cost == null,
        securedLoanId: _loanId,
        clearSecuredLoan: _loanId == null,
        countsInNetWorth: _counts,
        heldForSale: _forSale,
        note: _note.text.trim(),
      ));
      if (mounted) Navigator.of(context).pop();
      return;
    }
    final value = parseMinor(_value.text, _currency);
    if (value == null || value < 0) return setState(() => _error = l10n.assetErrorValue);
    final asset = BookAccount(
      id: money.newId(),
      name: name,
      side: AccountSide.own,
      type: AccountType.asset,
      currency: _currency,
      assetKind: _kind,
      boughtOn: _bought,
      cost: cost,
      securedLoanId: _loanId,
      countsInNetWorth: _counts,
      heldForSale: _forSale,
      note: _note.text.trim(),
    );
    // The first value is dated today; with a price paid and a date bought,
    // that becomes the first point and today's value a valuation after it.
    final now = DateTime.now();
    if (cost != null && _bought != null && _bought!.isBefore(now)) {
      await money.addAccount(asset, opening: cost, openedOn: _bought);
      await money.revalue(money.state.book.accounts[asset.id]!, value, now);
    } else {
      await money.addAccount(asset, opening: value, openedOn: now);
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final app = context.read<AppCubit>().state;
    final loans = context.watch<MoneyCubit>().state.ofType(AccountType.loan);

    if (_kind == null) {
      return ScreenBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(backgroundColor: Colors.transparent, title: Text(l10n.assetAdd), actions: const [HelpButton(topic: HelpTopicId.assets)]),
          body: ListView(
            padding: const EdgeInsets.all(DS.spaceMD),
            children: [
              MoneySection(
                children: [
                  for (final k in AssetKind.values)
                    MoneyRow(icon: MoneyIcons.assetKind(k), title: l10n.assetKind(k), subtitle: _kindHint(l10n, k), onTap: () => setState(() => _kind = k)),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: colors.textTertiary),
                  const SizedBox(width: DS.spaceXS),
                  Expanded(child: Text(l10n.assetGoldNote, style: TextStyle(color: colors.textTertiary, fontSize: 13))),
                ],
              ),
            ],
          ),
        ),
      );
    }

    final fields = <Widget>[
      Row(children: [
        Icon(MoneyIcons.assetKind(_kind!), color: colors.brandText),
        const SizedBox(width: DS.spaceSM),
        Text(l10n.assetKind(_kind!), style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w700)),
      ]),
      TextField(
        controller: _name,
        autofocus: !_editing,
        decoration: InputDecoration(labelText: l10n.accountNameLabel, hintText: _kindHint(l10n, _kind!), border: const OutlineInputBorder()),
      ),
      if (!_editing)
        CurrencyField(
          label: l10n.accountCurrency,
          selected: _currency,
          baseCurrency: app.baseCurrency,
          currencies: {...app.rates.availableCurrencies, app.baseCurrency}.toList()..sort(),
          onChanged: (c) => setState(() => _currency = c),
        ),
      if (!_editing) AmountField(controller: _value, label: l10n.assetValueToday, currency: _currency),
      AmountField(controller: _cost, label: l10n.assetCost, currency: _currency, helper: l10n.optional),
      _OptionalDate(label: l10n.assetBought, value: _bought, onChanged: (d) => setState(() => _bought = d)),
      if (loans.isNotEmpty)
        DropdownButtonFormField<String?>(
          initialValue: _loanId,
          isExpanded: true,
          decoration: InputDecoration(labelText: l10n.assetLoan, border: const OutlineInputBorder()),
          items: [
            DropdownMenuItem<String?>(value: null, child: Text(l10n.assetNoLoan)),
            for (final l in loans) DropdownMenuItem<String?>(value: l.id, child: Text(l.name)),
          ],
          onChanged: (v) => setState(() => _loanId = v),
        ),
      TextField(controller: _note, decoration: InputDecoration(labelText: l10n.entryNote, border: const OutlineInputBorder())),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(l10n.accountCounts),
        subtitle: Text(l10n.accountCountsHelp),
        value: _counts,
        onChanged: (v) => setState(() => _counts = v),
      ),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(l10n.assetForSale),
        subtitle: Text(l10n.assetForSaleHelp),
        value: _forSale,
        onChanged: (v) => setState(() => _forSale = v),
      ),
      if (_error != null) Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
    ];

    return ScreenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(_editing ? l10n.assetEdit : l10n.assetAdd),
          actions: [const HelpButton(topic: HelpTopicId.assets), TextButton(onPressed: _save, child: Text(l10n.holdingsSave))],
        ),
        body: ListView(
          padding: const EdgeInsets.all(DS.spaceMD),
          children: [for (final f in fields) Padding(padding: const EdgeInsets.only(bottom: DS.spaceMD), child: f)],
        ),
      ),
    );
  }

  static String _kindHint(AppLocalizations l10n, AssetKind k) => switch (k) {
        AssetKind.property => l10n.assetKindPropertyHint,
        AssetKind.vehicle => l10n.assetKindVehicleHint,
        AssetKind.business => l10n.assetKindBusinessHint,
        AssetKind.valuables => l10n.assetKindValuablesHint,
        AssetKind.other => l10n.assetKindOtherHint,
      };
}

class _OptionalDate extends StatelessWidget {
  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  const _OptionalDate({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toLanguageTag();
    return InkWell(
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(context: context, initialDate: value ?? now, firstDate: DateTime(1950), lastDate: now);
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          helperText: l10n.optional,
          border: const OutlineInputBorder(),
          suffixIcon: value == null ? const Icon(Icons.calendar_today_outlined, size: 18) : IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () => onChanged(null)),
        ),
        child: Text(value == null ? '' : DateFormat.yMMMd(locale).format(value!)),
      ),
    );
  }
}

/// 14.4 An asset: its value with the date it was set, the change since it
/// was bought, a step chart of its valuations, what part is the person's
/// own when a loan is secured on it, and its history.
class AssetDetailScreen extends StatelessWidget {
  final String assetId;

  const AssetDetailScreen({super.key, required this.assetId});

  static Future<void> open(BuildContext context, String id) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => AssetDetailScreen(assetId: id)));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final hidden = context.select<AppCubit, bool>((c) => c.state.hideBalances);
    final money = context.read<MoneyCubit>();
    final state = context.watch<MoneyCubit>().state;
    final a = state.book.accounts[assetId];
    if (a == null) return Scaffold(appBar: AppBar());
    final ccy = a.currency!;
    final value = state.book.balanceOf(a.id);
    final history = money.valueHistory(a.id);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final cost = a.cost;
    final change = cost == null ? null : value - cost;
    final loan = a.securedLoanId == null ? null : state.book.accounts[a.securedLoanId];
    final owed = loan == null ? 0 : state.book.balanceOf(loan.id);
    final entries = state.entriesFor(a.id);

    return ScreenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(a.name),
          actions: [
            const HelpButton(topic: HelpTopicId.assets),
            PopupMenuButton<String>(
              onSelected: (v) async {
                if (v == 'edit') {
                  await AssetEditorScreen.open(context, existing: a);
                } else if (v == 'remove') {
                  final ok = await confirmDelete(context, title: l10n.assetRemoveTitle, message: l10n.assetRemoveMessage, confirmLabel: l10n.commonDelete);
                  if (!ok) return;
                  await money.removeAccount(a.id);
                  if (context.mounted) Navigator.of(context).pop();
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(value: 'edit', child: Text(l10n.assetEdit)),
                PopupMenuItem(value: 'remove', child: Text(l10n.assetRemoveTitle)),
              ],
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(DS.spaceMD),
          children: [
            DSHeroCard(
              accent: colors.brand,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.assetKind(a.assetKind ?? AssetKind.other), style: TextStyle(color: colors.textTertiary, fontSize: 12)),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(minorText(value, ccy, hidden: hidden), style: TextStyle(color: colors.textPrimary, fontSize: DS.figureHero, fontWeight: FontWeight.w800)),
                  ),
                  if (history.isNotEmpty) Text(l10n.assetUpdated(DateFormat.yMMMd(locale).format(history.last.$1)), style: TextStyle(color: colors.textSecondary, fontSize: 12)),
                  if (change != null)
                    Text(
                      l10n.assetSinceBought('${change >= 0 ? '+' : '−'}${minorText(change.abs(), ccy, hidden: hidden)}'),
                      style: TextStyle(color: change >= 0 ? colors.up : colors.down, fontWeight: FontWeight.w600),
                    ),
                  if (history.length > 1) ...[
                    const SizedBox(height: DS.spaceMD),
                    SizedBox(height: 120, child: ValueStepChart(points: history, currency: ccy, color: colors.brand, hidden: hidden)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: DS.spaceMD),
            Row(
              children: [
                Expanded(child: FilledButton.icon(onPressed: () => showUpdateValueSheet(context, a), icon: const Icon(Icons.edit_outlined), label: Text(l10n.assetUpdateValue))),
                const SizedBox(width: DS.spaceSM),
                Expanded(child: OutlinedButton.icon(onPressed: () => SellAssetScreen.open(context, a), icon: const Icon(Icons.sell_outlined), label: Text(l10n.assetSold))),
              ],
            ),
            const SizedBox(height: DS.spaceMD),
            if (loan != null)
              MoneySection(
                title: l10n.assetYours,
                children: [
                  MoneyRow(title: l10n.assetValue, trailing: minorText(value, ccy, hidden: hidden)),
                  MoneyRow(title: l10n.assetStillOwed(loan.name), trailing: '−${minorText(owed, loan.currency!, hidden: hidden)}'),
                  if (loan.currency == ccy) MoneyRow(title: l10n.assetYoursTotal, bold: true, trailing: minorText(value - owed, ccy, hidden: hidden)),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(DS.spaceMD, 0, DS.spaceMD, DS.spaceXS),
                    child: Text(l10n.assetYoursHelp, style: TextStyle(color: colors.textTertiary, fontSize: 12)),
                  ),
                ],
              ),
            MoneySection(
              title: l10n.assetHistory,
              children: [
                for (final e in entries)
                  EntryRow(entry: e, book: state.book, hidden: hidden, forAccount: a.id, onTap: () => EntryDetailScreen.open(context, e.id)),
              ],
            ),
            if (a.note.isNotEmpty) Text(a.note, style: TextStyle(color: colors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

/// The value line steps from one valuation to the next, because Qima never
/// invents a price between updates.
class ValueStepChart extends StatelessWidget {
  final List<(DateTime, int)> points;
  final String currency;
  final Color color;
  final bool hidden;

  const ValueStepChart({super.key, required this.points, required this.currency, required this.color, required this.hidden});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final locale = Localizations.localeOf(context).toLanguageTag();
    return Column(
      children: [
        Expanded(
          child: Semantics(
            label: [for (final p in points) '${DateFormat.yMMM(locale).format(p.$1)} ${minorText(p.$2, currency, hidden: hidden)}'].join(', '),
            child: CustomPaint(size: Size.infinite, painter: _StepPainter(points, color, colors.hairline)),
          ),
        ),
        const SizedBox(height: 4),
        // Dates read left to right like the chart, in every language.
        Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(DateFormat.yMMM(locale).format(points.first.$1), style: TextStyle(color: colors.textTertiary, fontSize: 11)),
              Text(DateFormat.yMMM(locale).format(points.last.$1), style: TextStyle(color: colors.textTertiary, fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }
}

class _StepPainter extends CustomPainter {
  final List<(DateTime, int)> points;
  final Color color;
  final Color grid;

  _StepPainter(this.points, this.color, this.grid);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    final t0 = points.first.$1.millisecondsSinceEpoch.toDouble();
    final t1 = points.last.$1.millisecondsSinceEpoch.toDouble();
    final values = points.map((p) => p.$2.toDouble());
    var lo = values.reduce((a, b) => a < b ? a : b), hi = values.reduce((a, b) => a > b ? a : b);
    if (hi == lo) {
      hi += 1;
      lo -= 1;
    }
    double x(DateTime t) => t1 == t0 ? 0 : (t.millisecondsSinceEpoch - t0) / (t1 - t0) * size.width;
    double y(int v) => size.height - 4 - (v - lo) / (hi - lo) * (size.height - 8);
    final path = Path()..moveTo(x(points.first.$1), y(points.first.$2));
    for (var i = 1; i < points.length; i++) {
      path.lineTo(x(points[i].$1), y(points[i - 1].$2));
      path.lineTo(x(points[i].$1), y(points[i].$2));
    }
    canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), Paint()..color = grid);
    canvas.drawPath(path, Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke);
    for (final p in points) {
      canvas.drawCircle(Offset(x(p.$1), y(p.$2)), 3, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(_StepPainter old) => old.points != points || old.color != color;
}

/// 14.5 Update the value: a new dated valuation.
Future<void> showUpdateValueSheet(BuildContext context, BookAccount asset) async {
  final l10n = AppLocalizations.of(context)!;
  final money = context.read<MoneyCubit>();
  final current = money.state.book.balanceOf(asset.id);
  final value = TextEditingController(text: minorFieldText(current, asset.currency!));
  final note = TextEditingController();
  var date = DateTime.now();
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    // A tall sheet stops below the status bar, drag handle in view.
    useSafeArea: true,
    showDragHandle: true,
    builder: (sheetContext) => StatefulBuilder(
      builder: (sheetContext, setSheet) => Padding(
        padding: EdgeInsets.fromLTRB(DS.spaceMD, 0, DS.spaceMD, MediaQuery.of(sheetContext).viewInsets.bottom + DS.spaceMD),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.assetUpdateValue, style: Theme.of(sheetContext).textTheme.titleLarge),
            const SizedBox(height: DS.spaceXS),
            Text(l10n.assetUpdateHelp, style: TextStyle(color: sheetContext.colors.textSecondary)),
            const SizedBox(height: DS.spaceMD),
            AmountField(controller: value, autofocus: true, label: l10n.assetNewValue, currency: asset.currency!),
            const SizedBox(height: DS.spaceMD),
            DateField(label: l10n.entryDate, value: date, onChanged: (d) => setSheet(() => date = d)),
            const SizedBox(height: DS.spaceMD),
            TextField(controller: note, decoration: InputDecoration(labelText: l10n.assetValueSource, border: const OutlineInputBorder())),
            const SizedBox(height: DS.spaceMD),
            FilledButton(
              onPressed: () async {
                final v = parseMinor(value.text, asset.currency!);
                if (v == null || v < 0) return;
                await money.revalue(asset, v, date, note: note.text.trim());
                if (sheetContext.mounted) Navigator.of(sheetContext).pop();
              },
              child: Text(l10n.holdingsSave),
            ),
          ],
        ),
      ),
    ),
  );
  value.dispose();
  note.dispose();
}

/// 14.6 Sold it: the money goes into an account, the gap from the last
/// value is the gain or loss, and a secured loan can be paid off.
class SellAssetScreen extends StatefulWidget {
  final BookAccount asset;

  const SellAssetScreen({super.key, required this.asset});

  static Future<void> open(BuildContext context, BookAccount asset) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => SellAssetScreen(asset: asset)));

  @override
  State<SellAssetScreen> createState() => _SellAssetScreenState();
}

class _SellAssetScreenState extends State<SellAssetScreen> {
  final _price = TextEditingController();
  BookAccount? _into;
  DateTime _date = DateTime.now();
  bool _payOff = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    final money = context.read<MoneyCubit>().state;
    final choices = [...money.ofType(AccountType.debit), ...money.ofType(AccountType.cash)];
    _into = choices.where((a) => a.currency == widget.asset.currency).firstOrNull ?? choices.firstOrNull;
  }

  @override
  void dispose() {
    _price.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final hidden = context.select<AppCubit, bool>((c) => c.state.hideBalances);
    final state = context.watch<MoneyCubit>().state;
    final a = widget.asset;
    final carried = state.book.balanceOf(a.id, asOf: _date);
    final choices = [...state.ofType(AccountType.debit), ...state.ofType(AccountType.cash)];
    final loan = a.securedLoanId == null ? null : state.book.accounts[a.securedLoanId];
    final owed = loan == null ? 0 : state.book.balanceOf(loan.id);
    final price = _into == null ? null : parseMinor(_price.text, _into!.currency!);
    final sameCcy = _into?.currency == a.currency;
    final gap = price != null && sameCcy ? price - carried : null;

    return ScreenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(backgroundColor: Colors.transparent, title: Text(l10n.assetSellTitle(a.name)), actions: const [HelpButton(topic: HelpTopicId.assets)]),
        body: choices.isEmpty
            ? MoneyEmpty(icon: Icons.account_balance_outlined, title: l10n.entryNeedsAccountTitle, message: l10n.entryNeedsAccountMessage)
            : ListView(
                padding: const EdgeInsets.all(DS.spaceMD),
                children: [
                  Text(l10n.assetLastValue(minorText(carried, a.currency!, hidden: hidden)), style: TextStyle(color: colors.textSecondary)),
                  const SizedBox(height: DS.spaceMD),
                  AccountPicker(label: l10n.assetSoldInto, accounts: choices, value: _into, onChanged: (v) => setState(() => _into = v)),
                  const SizedBox(height: DS.spaceMD),
                  AmountField(controller: _price, autofocus: true, label: l10n.assetSoldFor, currency: _into?.currency ?? a.currency!, onChanged: (_) => setState(() {})),
                  const SizedBox(height: DS.spaceMD),
                  DateField(label: l10n.entryDate, value: _date, onChanged: (d) => setState(() => _date = d)),
                  if (gap != null && gap != 0) ...[
                    const SizedBox(height: DS.spaceMD),
                    Text(
                      gap > 0 ? l10n.assetGain(minorText(gap, a.currency!, hidden: hidden)) : l10n.assetLoss(minorText(-gap, a.currency!, hidden: hidden)),
                      style: TextStyle(color: gap > 0 ? colors.up : colors.down, fontWeight: FontWeight.w600),
                    ),
                    Text(l10n.assetGainHelp, style: TextStyle(color: colors.textTertiary, fontSize: 12)),
                  ],
                  if (loan != null && owed > 0 && _into?.currency == loan.currency)
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.assetPayOff(loan.name)),
                      subtitle: Text(l10n.assetPayOffHelp(minorText(owed, loan.currency!, hidden: hidden))),
                      value: _payOff,
                      onChanged: (v) => setState(() => _payOff = v),
                    ),
                  if (_error != null) Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  const SizedBox(height: DS.spaceMD),
                  FilledButton(
                    onPressed: () async {
                      if (_into == null || price == null || price <= 0) return setState(() => _error = l10n.entryErrorAmount);
                      try {
                        await context.read<MoneyCubit>().sellAsset(a,
                            proceeds: price, into: _into!, date: _date, payOffLoan: _payOff && loan != null && _into!.currency == loan.currency);
                      } on ArgumentError {
                        return setState(() => _error = l10n.entryErrorRate);
                      }
                      if (!context.mounted) return;
                      Navigator.of(context)
                        ..pop()
                        ..pop();
                    },
                    child: Text(l10n.assetSold),
                  ),
                ],
              ),
      ),
    );
  }
}
