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

/// Opens the Add sheet, with everything that adds: putting an asset on the
/// watchlist first, then recording a purchase by voice, receipt or text.
/// Speak and Scan appear only where the device can do them; a mic that's
/// merely turned off still shows, and explains itself.
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
              Material(
                color: colors.tileTop,
                borderRadius: BorderRadius.circular(DS.radiusTile),
                child: ListTile(
                  key: const ValueKey('addSheetWatch'),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DS.radiusTile)),
                  leading: Icon(Icons.list_alt_outlined, size: 28, color: colors.brand),
                  title: Text(
                    l10n.addSheetWatch,
                    style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(l10n.addSheetWatchSubtitle, style: TextStyle(color: colors.textTertiary)),
                  trailing: Icon(Icons.chevron_right, color: colors.textTertiary),
                  onTap: () => choose(AddStart.search),
                ),
              ),
              const SizedBox(height: DS.spaceLG),
              Text(
                l10n.addSheetRecordTitle,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: colors.textPrimary, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(l10n.addSheetRecordSubtitle, style: TextStyle(color: colors.textTertiary, fontSize: 13)),
              const SizedBox(height: DS.spaceMD),
              Row(
                children: [
                  if (canSpeak) ...[
                    Expanded(
                      child: _Choice(
                        icon: Icons.mic_none,
                        label: l10n.addSheetSpeak,
                        onTap: () => choose(AddStart.speak),
                      ),
                    ),
                    const SizedBox(width: DS.spaceSM),
                  ],
                  if (canScan) ...[
                    Expanded(
                      child: _Choice(
                        icon: Icons.document_scanner_outlined,
                        label: l10n.addSheetScan,
                        onTap: () => choose(AddStart.scan),
                      ),
                    ),
                    const SizedBox(width: DS.spaceSM),
                  ],
                  Expanded(
                    child: _Choice(
                      icon: Icons.keyboard_outlined,
                      label: l10n.addSheetType,
                      onTap: () => choose(AddStart.type),
                    ),
                  ),
                ],
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

/// One of the large Speak / Scan / Type choices.
class _Choice extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _Choice({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: colors.tileTop,
      borderRadius: BorderRadius.circular(DS.radiusTile),
      child: InkWell(
        borderRadius: BorderRadius.circular(DS.radiusTile),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: DS.spaceMD, horizontal: DS.spaceXS),
          child: Column(
            children: [
              Icon(icon, size: 28, color: colors.brand),
              const SizedBox(height: DS.spaceXS),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
