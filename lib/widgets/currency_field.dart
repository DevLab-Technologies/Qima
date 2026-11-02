import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../l10n/currency_names.dart';
import '../screens/currency_picker.dart';
import '../theme/design_system.dart';
import '../theme/qima_colors.dart';

/// Choosing a currency where an asset or a transaction is set up. Shows the
/// chosen code with its name, one-tap chips for common currencies, and how
/// many there are, so it reads as a choice from many rather than a fixed
/// "USD". "More" and the field itself open the full [CurrencyPicker].
class CurrencyField extends StatelessWidget {
  final String label;
  final String selected;

  /// The portfolio currency, offered first after the selection.
  final String baseCurrency;
  final List<String> currencies;
  final ValueChanged<String> onChanged;
  final Color? accent;

  const CurrencyField({
    super.key,
    required this.label,
    required this.selected,
    required this.baseCurrency,
    required this.currencies,
    required this.onChanged,
    this.accent,
  });

  /// Widely used currencies, tried in order after the selection and the
  /// portfolio currency.
  static const _common = ['USD', 'EUR', 'EGP', 'SAR', 'AED', 'GBP'];

  /// At most five quick choices, always including [selected].
  List<String> get suggestions {
    final available = currencies.toSet();
    final codes = <String>{};
    for (final code in [selected, baseCurrency, ..._common]) {
      if (code == selected || available.contains(code)) codes.add(code);
      if (codes.length == 5) break;
    }
    return codes.toList();
  }

  Future<void> _openPicker(BuildContext context) async {
    final code = await CurrencyPicker.show(context, selected: selected, currencies: currencies);
    if (code != null) onChanged(code);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final name = currencyDisplayName(selected, Localizations.localeOf(context).languageCode);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          button: true,
          label: '$label, $selected, $name',
          excludeSemantics: true,
          child: InkWell(
            borderRadius: BorderRadius.circular(DS.radiusTile),
            onTap: () => _openPicker(context),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: label,
                labelStyle: TextStyle(color: colors.textTertiary),
                helperText: l10n.currencyFieldCount(currencies.length),
                helperStyle: TextStyle(color: colors.textTertiary),
                filled: true,
                fillColor: colors.tileTop,
                suffixIcon: Icon(Icons.unfold_more, color: colors.textSecondary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DS.radiusTile),
                  borderSide: BorderSide.none,
                ),
              ),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: selected,
                      style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w600),
                    ),
                    TextSpan(
                      text: '  $name',
                      style: TextStyle(color: colors.textSecondary),
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
        const SizedBox(height: DS.spaceXS),
        Wrap(
          spacing: DS.spaceXS,
          runSpacing: DS.spaceXS,
          children: [
            for (final code in suggestions)
              DSChoiceChip(label: code, selected: code == selected, onSelected: (_) => onChanged(code), accent: accent),
            ActionChip(
              avatar: Icon(Icons.search, size: 18, color: colors.textSecondary),
              label: Text(l10n.currencyFieldMore),
              backgroundColor: colors.tileTop,
              side: BorderSide.none,
              shape: const StadiumBorder(),
              onPressed: () => _openPicker(context),
            ),
          ],
        ),
      ],
    );
  }
}
