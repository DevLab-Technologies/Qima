import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../theme/design_system.dart';

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

  String _nameFor(String code) {
    try {
      return NumberFormat.simpleCurrency(name: code).currencyName ?? code;
    } catch (_) {
      return code;
    }
  }

  @override
  Widget build(BuildContext context) {
    final query = _query.trim().toLowerCase();
    final filtered = widget.currencies.where((code) {
      if (query.isEmpty) return true;
      return code.toLowerCase().contains(query) || _nameFor(code).toLowerCase().contains(query);
    }).toList();

    final l10n = AppLocalizations.of(context)!;
    return ScreenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(backgroundColor: Colors.transparent, title: Text(l10n.commonCurrency)),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(DS.spaceMD),
              child: TextField(
                autofocus: false,
                style: const TextStyle(color: DS.textPrimary),
                decoration: InputDecoration(
                  hintText: l10n.currencyPickerSearchHint,
                  hintStyle: const TextStyle(color: DS.textTertiary),
                  prefixIcon: const Icon(Icons.search, color: DS.textTertiary),
                  filled: true,
                  fillColor: DS.tileTop,
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
                    title: Text(code, style: const TextStyle(color: DS.textPrimary)),
                    subtitle: Text(_nameFor(code), style: const TextStyle(color: DS.textTertiary)),
                    trailing: isSelected ? const Icon(Icons.check, color: DS.up) : null,
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
