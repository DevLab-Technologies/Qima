import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/app_cubit.dart';
import '../../blocs/money_cubit.dart';
import '../../l10n/app_localizations.dart';
import '../../models/book_account.dart';
import '../../models/categorizer.dart';
import '../../models/default_categories.dart';
import '../../theme/design_system.dart';
import '../../theme/money_labels.dart';
import '../../theme/qima_colors.dart';
import '../../widgets/money_widgets.dart';
import 'entry_detail_screen.dart';

/// Every uncategorized entry, grouped by merchant. One choice sorts a group
/// and is remembered for that merchant's next imports.
class ToCategorizeScreen extends StatelessWidget {
  const ToCategorizeScreen({super.key});

  static Future<void> open(BuildContext context) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ToCategorizeScreen()));

  /// How many entries wait for a category.
  static int count(MoneyState state) => state.uncategorized.fold(0, (n, g) => n + g.entries.length);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final state = context.watch<MoneyCubit>().state;
    final hidden = context.select<AppCubit, bool>((c) => c.state.hideBalances);
    final groups = state.uncategorized;
    return ScreenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(backgroundColor: Colors.transparent, title: Text(l10n.toCategorizeTitle)),
        body: ListView(
          padding: const EdgeInsets.all(DS.spaceMD),
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: DS.spaceMD),
              child: Text(groups.isEmpty ? l10n.toCategorizeEmpty : l10n.toCategorizeHint, style: TextStyle(color: colors.textSecondary)),
            ),
            for (final g in groups)
              MoneySection(
                key: ValueKey('group:${g.isIn}:${g.key}:${g.entries.first.id}'),
                title: _name(g),
                trailing: TextButton.icon(
                  key: ValueKey('pick:${g.entries.first.id}'),
                  icon: const Icon(Icons.label_outline, size: 18),
                  label: Text(l10n.importCategory),
                  onPressed: () => _pick(context, g),
                ),
                children: [
                  for (final e in g.entries) EntryRow(entry: e, book: state.book, hidden: hidden, onTap: () => EntryDetailScreen.open(context, e.id)),
                ],
              ),
          ],
        ),
      ),
    );
  }

  static String _name(UncategorizedGroup g) {
    final e = g.entries.first;
    return e.merchant.isNotEmpty ? e.merchant : e.rawMerchant;
  }

  Future<void> _pick(BuildContext context, UncategorizedGroup g) async {
    final l10n = AppLocalizations.of(context)!;
    final money = context.read<MoneyCubit>();
    final side = g.isIn ? AccountSide.income : AccountSide.spending;
    final options = [for (final c in money.state.categories(side)) if (!Categorizer.isUncategorized(c.id)) c];
    final picked = await showModalBottomSheet<BookAccount>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheet) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: DS.spaceMD),
            child: Text(_name(g), maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          ),
          Flexible(
            child: ListView(shrinkWrap: true, children: [
              for (final c in options)
                ListTile(leading: Icon(MoneyIcons.account(c)), title: Text(l10n.accountName(c)), onTap: () => Navigator.of(sheet).pop(c)),
            ]),
          ),
        ]),
      ),
    );
    if (picked == null || !context.mounted) return;
    await money.categorize([for (final e in g.entries) e.id], picked.id, ruleKey: g.key.isEmpty ? null : g.ruleKey);

    // Earlier entries from the same merchant that went to Other: offered,
    // never moved silently.
    if (g.key.isEmpty || !context.mounted) return;
    final otherId = g.isIn ? DefaultCategories.otherIncome : DefaultCategories.other;
    final other = money.state.book.accounts[otherId];
    if (other == null || picked.id == otherId) return;
    final earlier = Categorizer.withMerchantIn(money.state.book, g.key, otherId);
    if (earlier.isEmpty) return;
    final yes = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        content: Text(l10n.toCategorizeAlso(earlier.length, _name(g), l10n.accountName(picked), l10n.accountName(other))),
        actions: [
          TextButton(onPressed: () => Navigator.of(d).pop(false), child: Text(l10n.commonCancel)),
          FilledButton(onPressed: () => Navigator.of(d).pop(true), child: Text(l10n.toCategorizeAlsoYes)),
        ],
      ),
    );
    if (yes == true) await money.categorize([for (final e in earlier) e.id], picked.id);
  }
}
