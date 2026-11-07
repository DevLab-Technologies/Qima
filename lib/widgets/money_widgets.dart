import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../l10n/app_localizations.dart';
import '../models/book.dart';
import '../models/book_account.dart';
import '../models/book_entry.dart';
import '../theme/design_system.dart';
import '../theme/money_labels.dart';
import '../theme/qima_colors.dart';

/// A titled card holding rows, the building block of every money screen.
class MoneySection extends StatelessWidget {
  final String? title;
  final Widget? trailing;
  final List<Widget> children;
  final VoidCallback? onTitleTap;

  const MoneySection({super.key, this.title, this.trailing, required this.children, this.onTitleTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: DS.spaceMD),
      child: DSCard(
        padding: const EdgeInsets.symmetric(vertical: DS.spaceSM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (title != null)
              InkWell(
                onTap: onTitleTap,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(DS.spaceMD, DS.space2XS, DS.spaceMD, DS.spaceXS),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(title!, style: TextStyle(color: colors.textSecondary, fontSize: 13, fontWeight: FontWeight.w700)),
                      ),
                      ?trailing,
                      if (onTitleTap != null && trailing == null) Icon(Icons.chevron_right, size: 18, color: colors.textTertiary),
                    ],
                  ),
                ),
              ),
            ...children,
          ],
        ),
      ),
    );
  }
}

/// One row: an icon, a title with an optional subtitle, and a figure.
class MoneyRow extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String? subtitle;
  final String? trailing;
  final String? trailingSub;
  final Color? trailingColor;
  final bool strike;
  final bool bold;
  final VoidCallback? onTap;

  const MoneyRow({
    super.key,
    this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.trailingSub,
    this.trailingColor,
    this.strike = false,
    this.bold = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final deco = strike ? TextDecoration.lineThrough : null;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: DS.spaceMD, vertical: DS.spaceSM),
        child: LayoutBuilder(builder: (context, constraints) => Row(
          children: [
            if (icon != null) ...[
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: colors.brand.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, size: 20, color: colors.brandText),
              ),
              const SizedBox(width: DS.spaceSM),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: colors.textPrimary, fontSize: 15, fontWeight: bold ? FontWeight.w700 : FontWeight.w500, decoration: deco)),
                  if (subtitle != null && subtitle!.isNotEmpty)
                    Text(subtitle!, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: colors.textTertiary, fontSize: 12)),
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: DS.spaceSM),
              // A figure takes at most half the row and shrinks to fit
              // rather than being cut, so the title always has room.
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: constraints.maxWidth / 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerEnd,
                      // Figures always read left to right, in Arabic too.
                      child: Directionality(
                        textDirection: TextDirection.ltr,
                        child: Text(trailing!,
                            maxLines: 1,
                            style: TextStyle(
                                color: trailingColor ?? colors.textPrimary,
                                fontSize: 15,
                                fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
                                decoration: deco)),
                      ),
                    ),
                    if (trailingSub != null)
                      Text(trailingSub!, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: colors.textTertiary, fontSize: 11)),
                  ],
                ),
              ),
            ],
            if (onTap != null) Padding(padding: const EdgeInsetsDirectional.only(start: 4), child: Icon(Icons.chevron_right, size: 18, color: colors.textTertiary)),
          ],
        )),
      ),
    );
  }
}

/// A short message where a list is empty, with an optional action.
class MoneyEmpty extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? action;
  final VoidCallback? onAction;

  const MoneyEmpty({super.key, required this.icon, required this.title, required this.message, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.all(DS.spaceLG),
      child: Column(
        children: [
          Icon(icon, size: 40, color: colors.textTertiary),
          const SizedBox(height: DS.spaceSM),
          Text(title, textAlign: TextAlign.center, style: TextStyle(color: colors.textPrimary, fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: DS.space2XS),
          Text(message, textAlign: TextAlign.center, style: TextStyle(color: colors.textSecondary, fontSize: 14)),
          if (action != null) ...[
            const SizedBox(height: DS.spaceMD),
            FilledButton(onPressed: onAction, child: Text(action!)),
          ],
        ],
      ),
    );
  }
}

/// A money amount input. Figures are typed left to right in every language.
class AmountField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String currency;
  final bool autofocus;
  final String? helper;
  final ValueChanged<String>? onChanged;

  const AmountField({super.key, required this.controller, required this.label, required this.currency, this.autofocus = false, this.helper, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: autofocus,
      onChanged: onChanged,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textDirection: TextDirection.ltr,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,٠-٩٫٬]'))],
      decoration: InputDecoration(labelText: label, suffixText: currency, helperText: helper, border: const OutlineInputBorder()),
    );
  }
}

/// Picks one of [accounts].
class AccountPicker extends StatelessWidget {
  final String label;
  final List<BookAccount> accounts;
  final BookAccount? value;
  final ValueChanged<BookAccount?> onChanged;

  const AccountPicker({super.key, required this.label, required this.accounts, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final selected = accounts.any((a) => a.id == value?.id) ? value!.id : null;
    return DropdownButtonFormField<String>(
      // The field keeps its own value after the first build; a new choice
      // or a new list from the caller starts it again.
      key: ValueKey('$selected|${accounts.map((a) => a.id).join(',')}'),
      initialValue: selected,
      isExpanded: true,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      items: [
        for (final a in accounts)
          DropdownMenuItem(
            value: a.id,
            child: Row(
              children: [
                Icon(MoneyIcons.account(a), size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text(a.currency == null ? l10n.accountName(a) : '${l10n.accountName(a)} · ${a.currency}', overflow: TextOverflow.ellipsis)),
              ],
            ),
          ),
      ],
      onChanged: (id) => onChanged(accounts.where((a) => a.id == id).firstOrNull),
    );
  }
}

/// A date the person can change; never in the future unless [allowFuture].
class DateField extends StatelessWidget {
  final String label;
  final DateTime value;
  final ValueChanged<DateTime> onChanged;
  final bool allowFuture;

  const DateField({super.key, required this.label, required this.value, required this.onChanged, this.allowFuture = false});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    return InkWell(
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: value,
          firstDate: DateTime(1950),
          lastDate: allowFuture ? DateTime(now.year + 30) : now,
        );
        // Keep the time of day so entries on one day stay in the order made.
        if (picked != null) onChanged(DateTime(picked.year, picked.month, picked.day, value.hour, value.minute, value.second));
      },
      child: InputDecorator(
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder(), suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18)),
        child: Text(DateFormat.yMMMd(locale).format(value)),
      ),
    );
  }
}

/// What a list row shows for an entry.
class EntrySummary {
  final String title;
  final String subtitle;

  /// Minor units of [currency], signed the way the row shows it: negative
  /// is money out, positive money in, and zero sign for a move between the
  /// person's own accounts.
  final int amount;
  final String currency;
  final int sign;

  const EntrySummary(this.title, this.subtitle, this.amount, this.currency, this.sign);

  /// The entry as a list row. With [forAccount], the amount is that
  /// account's own change.
  static EntrySummary of(BookEntry e, Book book, AppLocalizations l10n, {String? forAccount}) {
    String name(String id) {
      final a = book.accounts[id];
      return a == null ? id : l10n.accountName(a);
    }

    final title = e.merchant.isNotEmpty ? e.merchant : l10n.template(e.template);
    final own = [
      for (final l in e.lines)
        if (book.accounts[l.accountId]?.side.onBalanceSheet ?? false) l,
    ];
    final flows = [
      for (final l in e.lines)
        if ({AccountSide.spending, AccountSide.income}.contains(book.accounts[l.accountId]?.side)) l,
    ];
    final subtitle = [
      if (e.merchant.isNotEmpty) l10n.template(e.template),
      for (final l in flows) name(l.accountId),
      for (final l in own) name(l.accountId),
    ];
    final subtitleText = {...subtitle}.join(' · ');

    if (forAccount != null) {
      final line = e.lines.firstWhere((l) => l.accountId == forAccount);
      final side = book.accounts[forAccount]?.side ?? AccountSide.own;
      final shown = line.amount * side.shownSign;
      // For a debt, "more owed" reads as money out.
      final signed = side == AccountSide.owe ? -shown : shown;
      return EntrySummary(title, subtitleText, signed, line.currency, signed.sign);
    }

    final spend = flows.where((l) => book.accounts[l.accountId]!.side == AccountSide.spending);
    final income = flows.where((l) => book.accounts[l.accountId]!.side == AccountSide.income);
    if (spend.isNotEmpty && income.isEmpty) {
      final total = spend.fold<int>(0, (a, l) => a + l.amount);
      return EntrySummary(title, subtitleText, -total, spend.first.currency, -total.sign);
    }
    if (income.isNotEmpty && spend.isEmpty) {
      final total = income.fold<int>(0, (a, l) => -l.amount + a);
      return EntrySummary(title, subtitleText, total, income.first.currency, total.sign);
    }
    // A move: show the largest amount without a sign.
    final biggest = e.lines.reduce((a, b) => a.amount.abs() >= b.amount.abs() ? a : b);
    return EntrySummary(title, subtitleText, biggest.amount.abs(), biggest.currency, 0);
  }
}

/// A transaction in a list.
class EntryRow extends StatelessWidget {
  final BookEntry entry;
  final Book book;
  final bool hidden;
  final String? forAccount;
  final VoidCallback? onTap;

  const EntryRow({super.key, required this.entry, required this.book, required this.hidden, this.forAccount, this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final s = EntrySummary.of(entry, book, l10n, forAccount: forAccount);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final text = minorText(s.amount.abs(), s.currency, hidden: hidden);
    return MoneyRow(
      icon: MoneyIcons.template(entry.template),
      title: s.title,
      subtitle: '${DateFormat.MMMd(locale).format(entry.date)} · ${s.subtitle}',
      trailing: s.sign < 0 ? '−$text' : (s.sign > 0 ? '+$text' : text),
      trailingColor: s.sign > 0 ? colors.up : null,
      strike: !entry.counts,
      onTap: onTap,
    );
  }
}

/// Shows a snackbar saying a feature was turned on, with Undo.
void showFeatureTurnedOn(BuildContext context, String featureName, VoidCallback undo) {
  final l10n = AppLocalizations.of(context)!;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(l10n.featureTurnedOn(featureName)),
    action: SnackBarAction(label: l10n.commonUndo, onPressed: undo),
  ));
}
