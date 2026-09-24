import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/app_cubit.dart';
import '../l10n/app_localizations.dart';
import '../models/asset.dart';
import '../models/instrument_catalog.dart';
import '../theme/design_system.dart';
import '../theme/qima_colors.dart';
import '../theme/strings.dart';
import '../widgets/confirm_delete_dialog.dart';
import '../widgets/instrument_icon.dart';
import 'card_config_screen.dart';
import 'custom_ticker_screen.dart';

/// Grouped-by-asset-class list of all catalog instruments, plus a "custom
/// ticker" entry in the stock section. Mirrors `AddInstrumentView.swift`.
class AddInstrumentScreen extends StatefulWidget {
  const AddInstrumentScreen({super.key});

  @override
  State<AddInstrumentScreen> createState() => _AddInstrumentScreenState();
}

class _AddInstrumentScreenState extends State<AddInstrumentScreen> {
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AppCubit>();

    return ScreenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(backgroundColor: Colors.transparent, title: Text(AppLocalizations.of(context)!.addTitle)),
        body: ListView(
          padding: const EdgeInsets.all(DS.spaceMD),
          children: [
            for (final assetClass in AssetClass.values) _section(context, cubit, assetClass),
          ],
        ),
      ),
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
          Padding(
            padding: const EdgeInsets.only(bottom: DS.spaceXS, left: 4),
            child: Text(
              displayLabel(context, assetClass.titleKey).toUpperCase(),
              style: TextStyle(color: colors.textTertiary, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5),
            ),
          ),
          DSCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (final instrument in instruments)
                  _InstrumentTile(
                    instrument: instrument,
                    isCustom: cubit.isCustom(instrument.id),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => CardConfigScreen(instrument: instrument)),
                    ),
                    onDeleteCustom: () async {
                      await cubit.removeCustomInstrument(instrument.id);
                      setState(() {});
                    },
                  ),
                if (showsCustomTickerRow)
                  ListTile(
                    leading: Icon(Icons.add_circle_outline, color: colors.textPrimary),
                    title: Text(AppLocalizations.of(context)!.addCustomTickerTitle, style: TextStyle(color: colors.textPrimary)),
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => CustomTickerScreen(initialAssetClass: assetClass)),
                      );
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
}

class _InstrumentTile extends StatelessWidget {
  final Instrument instrument;
  final bool isCustom;
  final VoidCallback onTap;
  final VoidCallback onDeleteCustom;

  const _InstrumentTile({
    required this.instrument,
    required this.isCustom,
    required this.onTap,
    required this.onDeleteCustom,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tile = ListTile(
      leading: InstrumentIcon(instrument: instrument, size: 32),
      title: Text(displayLabel(context, instrument.nameKey), style: TextStyle(color: colors.textPrimary)),
      subtitle: Text(instrument.symbol, style: TextStyle(color: colors.textTertiary, fontSize: 12)),
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
