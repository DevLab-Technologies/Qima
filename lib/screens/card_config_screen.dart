import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../blocs/app_cubit.dart';
import '../l10n/app_localizations.dart';
import '../models/asset.dart';
import '../models/metal_breakdown.dart';
import '../models/watch_card.dart';
import '../theme/design_system.dart';
import '../theme/instrument_theme.dart';
import '../theme/strings.dart';
import 'currency_picker.dart';

/// Configure currency/unit/karat before adding an instrument to the
/// watchlist. Mirrors `CardConfigView.swift`.
class CardConfigScreen extends StatefulWidget {
  final Instrument instrument;

  const CardConfigScreen({super.key, required this.instrument});

  @override
  State<CardConfigScreen> createState() => _CardConfigScreenState();
}

class _CardConfigScreenState extends State<CardConfigScreen> {
  late String _currency;
  late PriceUnit _unit;
  GoldKarat? _karat;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<AppCubit>();
    _currency = cubit.state.baseCurrency;
    _unit = widget.instrument.quotation.defaultUnit;
    _karat = widget.instrument.supportedKarats.isNotEmpty ? widget.instrument.supportedKarats.first : null;
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AppCubit>();
    final instrument = widget.instrument;
    final l10n = AppLocalizations.of(context)!;
    final accent = InstrumentTheme.accentColor(instrument);

    return ScreenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(backgroundColor: Colors.transparent, title: Text(displayLabel(context, instrument.nameKey))),
        body: ListView(
          padding: const EdgeInsets.all(DS.spaceMD),
          children: [
            DSCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
                  if (instrument.supportedUnits.length > 1) ...[
                    const SizedBox(height: DS.spaceSM),
                    Text(l10n.settingsUnit, style: const TextStyle(color: DS.textTertiary, fontSize: 12)),
                    const SizedBox(height: 4),
                    SegmentedButton<PriceUnit>(
                      segments: [
                        for (final unit in instrument.supportedUnits)
                          ButtonSegment(value: unit, label: Text(displayLabel(context, unit.labelKey))),
                      ],
                      selected: {_unit},
                      onSelectionChanged: (s) => setState(() => _unit = s.first),
                      style: DS.segmentedButtonStyle(accent),
                    ),
                  ],
                  if (instrument.supportedKarats.isNotEmpty) ...[
                    const SizedBox(height: DS.spaceSM),
                    Text(l10n.settingsKarat, style: const TextStyle(color: DS.textTertiary, fontSize: 12)),
                    const SizedBox(height: 4),
                    SegmentedButton<GoldKarat>(
                      segments: [
                        for (final karat in instrument.supportedKarats)
                          ButtonSegment(value: karat, label: Text(displayLabel(context, karat.shortLabelKey))),
                      ],
                      selected: {_karat ?? instrument.supportedKarats.first},
                      onSelectionChanged: (s) => setState(() => _karat = s.first),
                      style: DS.segmentedButtonStyle(accent),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: DS.spaceLG),
            FilledButton(
              onPressed: () async {
                final karat = _karat == GoldKarat.k24 ? null : _karat;
                final card = WatchCard(
                  id: const Uuid().v4(),
                  instrumentID: instrument.id,
                  currency: _currency,
                  unit: _unit,
                  karat: karat,
                );
                await cubit.addCard(card);
                if (context.mounted) Navigator.of(context).pop();
              },
              child: Text(l10n.cardConfigAddToWatchlist),
            ),
          ],
        ),
      ),
    );
  }
}
