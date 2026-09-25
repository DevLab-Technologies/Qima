import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../l10n/currency_names.dart';
import '../theme/design_system.dart';
import '../theme/help_topics.dart';
import '../theme/qima_colors.dart';
import '../widgets/help_button.dart';

/// Searchable currency list — matches ISO code or the localized currency
/// name, case-insensitive substring. Mirrors `CurrencyPicker.swift`.
class CurrencyPicker extends StatefulWidget {
  final String selected;
  final List<String> currencies;

  const CurrencyPicker({super.key, required this.selected, required this.currencies});

  static Future<String?> show(BuildContext context, {required String selected, required List<String> currencies}) {
    return Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => CurrencyPicker(selected: selected, currencies: currencies)),
    );
  }

  @override
  State<CurrencyPicker> createState() => _CurrencyPickerState();
}

class _CurrencyPickerState extends State<CurrencyPicker> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    String nameFor(String code) => currencyDisplayName(code, languageCode);
    final query = _query.trim().toLowerCase();
    final filtered = widget.currencies.where((code) {
      if (query.isEmpty) return true;
      return code.toLowerCase().contains(query) || nameFor(code).toLowerCase().contains(query);
    }).toList();

    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    return ScreenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(l10n.commonCurrency),
          actions: const [HelpButton(topic: HelpTopicId.currencyPicker)],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(DS.spaceMD),
              child: TextField(
                autofocus: false,
                style: TextStyle(color: colors.textPrimary),
                decoration: InputDecoration(
                  hintText: l10n.currencyPickerSearchHint,
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
              child: ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final code = filtered[index];
                  final isSelected = code == widget.selected;
                  return ListTile(
                    title: Text(code, style: TextStyle(color: colors.textPrimary)),
                    subtitle: Text(nameFor(code), style: TextStyle(color: colors.textTertiary)),
                    trailing: isSelected ? Icon(Icons.check, color: colors.up) : null,
                    onTap: () => Navigator.of(context).pop(code),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
