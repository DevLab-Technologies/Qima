import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/app_cubit.dart';
import '../l10n/app_localizations.dart';
import '../models/asset.dart';
import '../models/instrument_catalog.dart';
import '../models/instrument_search.dart';
import '../theme/design_system.dart';
import '../theme/qima_colors.dart';
import '../theme/strings.dart';
import '../widgets/confirm_delete_dialog.dart';
import '../widgets/instrument_icon.dart';
import 'card_config_screen.dart';
import 'custom_ticker_screen.dart';

/// Grouped-by-asset-class list of all catalog instruments, plus a "custom
/// ticker" entry in the stock section. A pinned search field filters the
/// catalog by localized name or symbol; when the query doesn't match
/// anything (or to add something genuinely missing), an "Add as custom
/// ticker" row is always offered. Mirrors `AddInstrumentView.swift`.
class AddInstrumentScreen extends StatefulWidget {
  const AddInstrumentScreen({super.key});

  @override
  State<AddInstrumentScreen> createState() => _AddInstrumentScreenState();
}

class _AddInstrumentScreenState extends State<AddInstrumentScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AppCubit>();
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final query = _query.trim();

    return ScreenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(backgroundColor: Colors.transparent, title: Text(l10n.addTitle)),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(DS.spaceMD, DS.spaceMD, DS.spaceMD, DS.spaceSM),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                style: TextStyle(color: colors.textPrimary),
                decoration: InputDecoration(
                  hintText: l10n.addSearchHint,
                  hintStyle: TextStyle(color: colors.textTertiary),
                  prefixIcon: Icon(Icons.search, color: colors.textTertiary),
                  filled: true,
                  fillColor: colors.tileTop,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(DS.radiusTile), borderSide: BorderSide.none),
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            Expanded(
              child: query.isEmpty
                  ? _catalogList(context, cubit)
                  : _searchResults(context, cubit, query),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------
  // Empty query: the plain catalog, grouped by asset class.
  // -------------------------------------------------------------------

  Widget _catalogList(BuildContext context, AppCubit cubit) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(DS.spaceMD, 0, DS.spaceMD, DS.spaceMD),
      children: [
        for (final assetClass in AssetClass.values) _section(context, cubit, assetClass),
      ],
    );
  }

  Widget _section(BuildContext context, AppCubit cubit, AssetClass assetClass) {
    final instruments = InstrumentCatalog.all.where((i) => i.assetClass == assetClass).toList();
    final showsCustomTickerRow = assetClass == AssetClass.stock || assetClass == AssetClass.indices;
    if (instruments.isEmpty && !showsCustomTickerRow) return const SizedBox.shrink();
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.only(bottom: DS.spaceLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _GroupHeader(text: displayLabel(context, assetClass.titleKey).toUpperCase()),
          DSCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (final instrument in instruments)
                  _InstrumentTile(
                    instrument: instrument,
                    isCustom: cubit.isCustom(instrument.id),
                    onTap: () => _openConfig(context, instrument),
                    onDeleteCustom: () async {
                      await cubit.removeCustomInstrument(instrument.id);
                      setState(() {});
                    },
                  ),
                if (showsCustomTickerRow)
                  ListTile(
                    leading: Icon(Icons.add_circle_outline, color: colors.textPrimary),
                    title: Text(AppLocalizations.of(context)!.addCustomTickerTitle, style: TextStyle(color: colors.textPrimary)),
                    onTap: () => _openCustomTicker(context, initialAssetClass: assetClass),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------
  // Non-empty query: grouped search results, or a no-results state.
  // -------------------------------------------------------------------

  Widget _searchResults(BuildContext context, AppCubit cubit, String query) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final groups = InstrumentSearch.search(
      InstrumentCatalog.all,
      query,
      displayName: (i) => displayLabel(context, i.nameKey),
    );

    if (groups.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(DS.spaceMD),
        children: [
          const SizedBox(height: DS.spaceXL),
          Icon(Icons.search_off, color: colors.textTertiary, size: 40),
          const SizedBox(height: DS.spaceMD),
          Text(
            l10n.addSearchNoResultsTitle(query),
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: DS.spaceXS),
          Text(
            l10n.addSearchNoResultsMessage,
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.textTertiary),
          ),
          const SizedBox(height: DS.spaceLG),
          FilledButton(
            onPressed: () => _openCustomTicker(context, initialSymbol: query),
            child: Text(l10n.addSearchNoResultsButton(query)),
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(DS.spaceMD, 0, DS.spaceMD, DS.spaceMD),
      children: [
        for (final group in groups) _searchGroup(context, cubit, group),
        _CustomTickerRow(query: query, onTap: () => _openCustomTicker(context, initialSymbol: query)),
      ],
    );
  }

  Widget _searchGroup(BuildContext context, AppCubit cubit, InstrumentSearchGroup group) {
    final header = '${displayLabel(context, group.assetClass.titleKey).toUpperCase()} · ${group.matches.length}';
    return Padding(
      padding: const EdgeInsets.only(bottom: DS.spaceLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _GroupHeader(text: header),
          DSCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (final match in group.matches)
                  _InstrumentTile(
                    instrument: match.instrument,
                    isCustom: cubit.isCustom(match.instrument.id),
                    nameRanges: match.nameRanges,
                    symbolRanges: match.symbolRanges,
                    onTap: () => _openConfig(context, match.instrument),
                    onDeleteCustom: () async {
                      await cubit.removeCustomInstrument(match.instrument.id);
                      setState(() {});
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openConfig(BuildContext context, Instrument instrument) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CardConfigScreen(instrument: instrument)),
    );
  }

  void _openCustomTicker(BuildContext context, {AssetClass initialAssetClass = AssetClass.stock, String? initialSymbol}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CustomTickerScreen(initialAssetClass: initialAssetClass, initialSymbol: initialSymbol),
      ),
    );
    if (mounted) setState(() {});
  }
}

class _GroupHeader extends StatelessWidget {
  final String text;

  const _GroupHeader({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DS.spaceXS, left: 4),
      child: Text(
        text,
        style: TextStyle(color: context.colors.textTertiary, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5),
      ),
    );
  }
}

/// The `Add "<query>" as a custom ticker` row shown after search results —
/// ALWAYS last, whether or not the catalog matched anything, since the
/// catalog can never cover every stock/ETF/index ticker that exists.
class _CustomTickerRow extends StatelessWidget {
  final String query;
  final VoidCallback onTap;

  const _CustomTickerRow({required this.query, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    return DSCard(
      padding: EdgeInsets.zero,
      child: ListTile(
        leading: Icon(Icons.add_circle_outline, color: colors.textPrimary),
        title: Text(l10n.addSearchCustomTickerTitle(query), style: TextStyle(color: colors.textPrimary)),
        subtitle: Text(l10n.addSearchCustomTickerSubtitle, style: TextStyle(color: colors.textTertiary, fontSize: 12)),
        onTap: onTap,
      ),
    );
  }
}

class _InstrumentTile extends StatelessWidget {
  final Instrument instrument;
  final bool isCustom;
  final VoidCallback onTap;
  final VoidCallback onDeleteCustom;
  final List<MatchRange> nameRanges;
  final List<MatchRange> symbolRanges;

  const _InstrumentTile({
    required this.instrument,
    required this.isCustom,
    required this.onTap,
    required this.onDeleteCustom,
    this.nameRanges = const [],
    this.symbolRanges = const [],
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final name = displayLabel(context, instrument.nameKey);
    final tile = ListTile(
      leading: InstrumentIcon(instrument: instrument, size: 32),
      title: _HighlightedText(
        text: name,
        ranges: nameRanges,
        style: TextStyle(color: colors.textPrimary),
        highlightColor: colors.brandText,
      ),
      subtitle: _HighlightedText(
        text: instrument.symbol,
        ranges: symbolRanges,
        style: TextStyle(color: colors.textTertiary, fontSize: 12),
        highlightColor: colors.brandText,
      ),
      trailing: Icon(Icons.chevron_right, color: colors.textTertiary),
      onTap: onTap,
    );

    if (!isCustom) return tile;

    final l10n = AppLocalizations.of(context)!;
    return Dismissible(
      key: ValueKey(instrument.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => confirmDelete(
        context,
        title: l10n.confirmRemoveTickerTitle(instrument.symbol),
        message: l10n.confirmRemoveTickerMessage,
        confirmLabel: l10n.commonRemove,
      ),
      onDismissed: (_) => onDeleteCustom(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: DS.spaceMD),
        child: Icon(Icons.delete, color: colors.down),
      ),
      child: tile,
    );
  }
}

/// Renders [text] with [ranges] shown bold + [highlightColor], everything
/// else in [style] — the search-match highlighting used by result rows.
class _HighlightedText extends StatelessWidget {
  final String text;
  final List<MatchRange> ranges;
  final TextStyle style;
  final Color highlightColor;

  const _HighlightedText({
    required this.text,
    required this.ranges,
    required this.style,
    required this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    if (ranges.isEmpty) return Text(text, style: style);

    final runes = text.runes.toList();
    final spans = <TextSpan>[];
    var cursor = 0;
    final sorted = [...ranges]..sort((a, b) => a.start.compareTo(b.start));
    for (final range in sorted) {
      final start = range.start.clamp(0, runes.length);
      final end = range.end.clamp(start, runes.length);
      if (start > cursor) {
        spans.add(TextSpan(text: String.fromCharCodes(runes.sublist(cursor, start))));
      }
      spans.add(TextSpan(
        text: String.fromCharCodes(runes.sublist(start, end)),
        style: TextStyle(color: highlightColor, fontWeight: FontWeight.w800),
      ));
      cursor = end;
    }
    if (cursor < runes.length) {
      spans.add(TextSpan(text: String.fromCharCodes(runes.sublist(cursor))));
    }
    return Text.rich(TextSpan(style: style, children: spans));
  }
}
