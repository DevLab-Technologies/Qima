import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/app_cubit.dart';
import '../l10n/app_localizations.dart';
import '../screens/add_instrument_screen.dart';
import '../services/dictation_service.dart';
import '../theme/design_system.dart';
import '../theme/qima_colors.dart';

/// The round + docked in the centre of the phone bottom bar, and at the top
/// of the side rail. It opens the Add sheet.
class AddButton extends StatelessWidget {
  const AddButton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return FloatingActionButton(
      heroTag: null,
      tooltip: AppLocalizations.of(context)!.addButton,
      shape: const CircleBorder(),
      backgroundColor: colors.brand,
      foregroundColor: colors.onBrand,
      elevation: 2,
      onPressed: () => showAddSheet(context),
      child: const Icon(Icons.add, size: 30),
    );
  }
}

/// Opens the Add sheet: put an asset on the watchlist, or add a holding by
/// typing, speaking or scanning a receipt. The holding row names only what
/// this device can do; a mic that's merely turned off still counts, and
/// explains itself on the Add screen.
Future<void> showAddSheet(BuildContext context) async {
  final cubit = context.read<AppCubit>();
  final tag = dictationLocaleTag(Localizations.localeOf(context));
  const unavailable = Duration(seconds: 1);
  final (dictation, scan) = await (
    cubit.dictation.availability(tag).timeout(unavailable, onTimeout: () => DictationAvailability.unsupported),
    cubit.textRecognition.isAvailable().timeout(unavailable, onTimeout: () => false),
  ).wait;
  if (!context.mounted) return;
  final start = await showModalBottomSheet<AddStart>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => _AddSheet(canSpeak: dictation != DictationAvailability.unsupported, canScan: scan),
  );
  if (start == null || !context.mounted) return;
  unawaited(Navigator.of(context).push(MaterialPageRoute(builder: (_) => AddInstrumentScreen(start: start))));
}

class _AddSheet extends StatelessWidget {
  final bool canSpeak;
  final bool canScan;

  const _AddSheet({required this.canSpeak, required this.canScan});

  /// Siri and Shortcuts answer questions on iOS 17 and macOS 14 and later.
  static bool get _hasSiri =>
      !kIsWeb && (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS);

  String _holdingSubtitle(AppLocalizations l10n) => switch ((canSpeak, canScan)) {
    (true, true) => l10n.addSheetHoldingSpeakScan,
    (true, false) => l10n.addSheetHoldingSpeak,
    (false, true) => l10n.addSheetHoldingScan,
    (false, false) => l10n.addSheetHoldingType,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    void choose(AddStart start) => Navigator.of(context).pop(start);
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(DS.spaceMD, 0, DS.spaceMD, DS.spaceMD),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Choice(
                key: const ValueKey('addSheetWatch'),
                icon: Icons.list_alt_outlined,
                title: l10n.addSheetWatch,
                subtitle: l10n.addSheetWatchSubtitle,
                onTap: () => choose(AddStart.watchlist),
              ),
              const SizedBox(height: DS.spaceSM),
              _Choice(
                key: const ValueKey('addSheetHolding'),
                icon: Icons.pie_chart_outline,
                title: l10n.addHoldingTitle,
                subtitle: _holdingSubtitle(l10n),
                onTap: () => choose(AddStart.holding),
              ),
              if (_hasSiri)
                Padding(
                  padding: const EdgeInsets.only(top: DS.spaceMD),
                  child: Row(
                    children: [
                      Icon(Icons.record_voice_over_outlined, size: 16, color: colors.textTertiary),
                      const SizedBox(width: DS.spaceXS),
                      Expanded(
                        child: Text(l10n.addSheetSiriTip, style: TextStyle(color: colors.textTertiary, fontSize: 13)),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One of the two rows: Add to watchlist, Add holding.
class _Choice extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _Choice({super.key, required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: colors.tileTop,
      borderRadius: BorderRadius.circular(DS.radiusTile),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DS.radiusTile)),
        contentPadding: const EdgeInsets.symmetric(horizontal: DS.spaceMD, vertical: DS.spaceXS),
        leading: Icon(icon, size: 28, color: colors.brand),
        title: Text(title, style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: TextStyle(color: colors.textTertiary)),
        trailing: Icon(Icons.chevron_right, color: colors.textTertiary),
        onTap: onTap,
      ),
    );
  }
}
