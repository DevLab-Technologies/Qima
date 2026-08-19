import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../blocs/app_cubit.dart';
import '../l10n/app_localizations.dart';
import '../models/asset.dart';
import '../models/watch_card.dart';
import '../theme/design_system.dart';
import '../theme/strings.dart';
import 'currency_picker.dart';

/// Add a custom stock or index/ETF ticker not in the built-in catalog.
/// Mirrors `CustomTickerView.swift`, extended with an asset-class picker
/// (spec §1.8/§4.2 — custom tickers are only allowed for the two
/// Yahoo-quote-routed classes, stock and index/ETF).
class CustomTickerScreen extends StatefulWidget {
  /// Which option the asset-class picker opens on. Defaults to stock to
  /// preserve prior behavior; the "Add custom ticker" entry point in the
  /// Index section of [AddInstrumentScreen] pre-selects [AssetClass.indices]
  /// instead.
  final AssetClass initialAssetClass;

  const CustomTickerScreen({super.key, this.initialAssetClass = AssetClass.stock});

  @override
  State<CustomTickerScreen> createState() => _CustomTickerScreenState();
}

class _CustomTickerScreenState extends State<CustomTickerScreen> {
  final _symbolController = TextEditingController();
  final _nameController = TextEditingController();
  String _currency = 'USD';
  late AssetClass _assetClass;
  bool _isSubmitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<AppCubit>();
    _currency = cubit.state.baseCurrency;
    _assetClass = widget.initialAssetClass;
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final symbol = _symbolController.text.trim();
    if (symbol.isEmpty) {
      setState(() => _error = l10n.addCustomTickerSymbolRequired);
      return;
    }
    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    final cubit = context.read<AppCubit>();
    try {
      await cubit.validateCustomTicker(symbol, _nameController.text.trim(), assetClass: _assetClass);
      final instrument = await cubit.addCustomTicker(symbol, _nameController.text.trim(), assetClass: _assetClass);
      final card = WatchCard(
        id: const Uuid().v4(),
        instrumentID: instrument.id,
        currency: _currency,
        unit: instrument.quotation.defaultUnit,
      );
      await cubit.addCard(card);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = l10n.addCustomTickerError;
        });
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AppCubit>();
    final l10n = AppLocalizations.of(context)!;

    return ScreenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(backgroundColor: Colors.transparent, title: Text(l10n.addCustomTickerTitle)),
        body: ListView(
          padding: const EdgeInsets.all(DS.spaceMD),
          children: [
            DSCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _symbolController,
                    textCapitalization: TextCapitalization.characters,
                    autocorrect: false,
                    style: const TextStyle(color: DS.textPrimary),
                    decoration: InputDecoration(
                      labelText: l10n.addCustomTickerSymbol,
                      hintText: l10n.addCustomTickerHint,
                      labelStyle: const TextStyle(color: DS.textTertiary),
                      filled: true,
                      fillColor: DS.tileTop,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(DS.radiusTile), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: DS.spaceSM),
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(color: DS.textPrimary),
                    decoration: InputDecoration(
                      labelText: l10n.addCustomTickerName,
                      labelStyle: const TextStyle(color: DS.textTertiary),
                      filled: true,
                      fillColor: DS.tileTop,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(DS.radiusTile), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: DS.spaceSM),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: SegmentedButton<AssetClass>(
                      segments: [
                        ButtonSegment(
                          value: AssetClass.stock,
                          label: Text(displayLabel(context, AssetClass.stock.titleKey)),
                        ),
                        ButtonSegment(
                          value: AssetClass.indices,
                          label: Text(displayLabel(context, AssetClass.indices.titleKey)),
                        ),
                      ],
                      selected: {_assetClass},
                      onSelectionChanged: (s) => setState(() => _assetClass = s.first),
                      style: DS.segmentedButtonStyle(DS.textPrimary),
                    ),
                  ),
                  const SizedBox(height: DS.spaceSM),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.commonCurrency, style: const TextStyle(color: DS.textPrimary)),
                    trailing: Text(_currency, style: const TextStyle(color: DS.textSecondary)),
                    onTap: () async {
                      final selected = await CurrencyPicker.show(
                        context,
                        selected: _currency,
                        currencies: cubit.state.rates.availableCurrencies,
                      );
                      if (selected != null) setState(() => _currency = selected);
                    },
                  ),
                ],
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: DS.spaceSM),
              Text(_error!, style: const TextStyle(color: DS.down)),
            ],
            const SizedBox(height: DS.spaceLG),
            FilledButton(
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(l10n.addCustomTickerSubmit),
            ),
          ],
        ),
      ),
    );
  }
}
