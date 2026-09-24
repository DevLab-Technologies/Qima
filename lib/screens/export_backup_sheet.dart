import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../blocs/app_cubit.dart';
import '../blocs/app_state.dart';
import '../l10n/app_localizations.dart';
import '../theme/design_system.dart';
import '../theme/qima_colors.dart';

/// "Export backup" bottom sheet (spec Phase 6): a file summary card (name,
/// size, counts), a "Protect with a password" switch that reveals
/// password/confirm fields, a warning note when unprotected, and a
/// "Save or share…" action.
///
/// The password never leaves this widget's local `TextEditingController`s
/// except as a direct argument to `BackupService.exportJson` — it's never
/// logged, stored in [AppState]/persisted, or passed through any
/// intermediate object.
class ExportBackupSheet extends StatefulWidget {
  const ExportBackupSheet({super.key});

  static Future<void> show(BuildContext context) {
    final colors = context.colors;
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.overlay,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(DS.radiusCard)),
      ),
      builder: (sheetContext) => const ExportBackupSheet(),
    );
  }

  @override
  State<ExportBackupSheet> createState() => _ExportBackupSheetState();
}

class _ExportBackupSheetState extends State<ExportBackupSheet> {
  bool _protect = false;
  bool _obscure = true;
  bool _working = false;
  String? _error;
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  bool get _passwordValid => !_protect || _passwordController.text.length >= 8;

  bool get _passwordsMatch => !_protect || _passwordController.text == _confirmController.text;

  bool get _canExport => _passwordValid && _passwordsMatch && !_working;

  Future<void> _export(BuildContext context) async {
    final cubit = context.read<AppCubit>();
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _working = true;
      _error = null;
    });
    try {
      final box = context.findRenderObject() as RenderBox?;
      final origin = box == null ? null : (box.localToGlobal(Offset.zero) & box.size);
      final completed = await cubit.backupService.exportJson(
        password: _protect ? _passwordController.text : null,
        sharePositionOrigin: origin,
      );
      if (!context.mounted) return;
      if (completed) {
        Navigator.of(context).pop();
      } else {
        setState(() => _working = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _working = false;
        _error = l10n.backupExportSheetFailed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AppCubit>();
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final now = DateTime.now();
    final filename = 'qima-backup-${DateFormat('yyyy-MM-dd').format(now)}.json';
    final state = cubit.state;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: DS.spaceMD,
          right: DS.spaceMD,
          top: DS.spaceMD,
          bottom: MediaQuery.of(context).viewInsets.bottom + DS.spaceMD,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.backupExportSheetTitle,
                style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w700, fontSize: 18),
              ),
              const SizedBox(height: DS.spaceMD),
              DSCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _row(colors, l10n.backupExportSheetFileName, filename),
                    const SizedBox(height: DS.spaceXS),
                    _row(
                      colors,
                      l10n.backupExportSheetFileContents,
                      l10n.backupExportSheetContentsSummary(
                        state.cards.length,
                        state.lots.length,
                        _customTickerCount(cubit),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: DS.spaceLG),
              DSCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.backupExportSheetProtectTitle, style: TextStyle(color: colors.textPrimary)),
                      subtitle: Text(
                        l10n.backupExportSheetProtectSubtitle,
                        style: TextStyle(color: colors.textTertiary, fontSize: 12),
                      ),
                      value: _protect,
                      activeThumbColor: colors.onBrand,
                      activeTrackColor: colors.brand,
                      onChanged: (value) => setState(() => _protect = value),
                    ),
                    if (_protect) ...[
                      const SizedBox(height: DS.spaceSM),
                      _passwordField(
                        colors,
                        l10n.backupExportSheetPasswordLabel,
                        _passwordController,
                        errorText: _passwordController.text.isNotEmpty && !_passwordValid
                            ? l10n.backupExportSheetPasswordTooShort
                            : null,
                      ),
                      const SizedBox(height: DS.spaceSM),
                      _passwordField(
                        colors,
                        l10n.backupExportSheetPasswordConfirmLabel,
                        _confirmController,
                        errorText: _confirmController.text.isNotEmpty && !_passwordsMatch
                            ? l10n.backupExportSheetPasswordMismatch
                            : null,
                      ),
                    ],
                  ],
                ),
              ),
              if (!_protect) ...[
                const SizedBox(height: DS.spaceSM),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: colors.textTertiary, size: 16),
                    const SizedBox(width: DS.spaceXS),
                    Expanded(
                      child: Text(
                        l10n.backupExportSheetUnprotectedWarning,
                        style: TextStyle(color: colors.textTertiary, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: DS.spaceSM),
                Text(_error!, style: TextStyle(color: colors.down, fontSize: 12)),
              ],
              const SizedBox(height: DS.spaceLG),
              FilledButton(
                onPressed: _canExport ? () => _export(context) : null,
                child: _working
                    ? SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: colors.onBrand),
                      )
                    : Text(l10n.backupExportSheetAction),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Custom ticker count isn't tracked directly in [AppState]; approximate
  /// it from the watchlist cards whose instrument isn't built-in. The exact
  /// count comes from the exported payload itself (shown on the
  /// import-preview side) — this is a best-effort summary for the export
  /// sheet only.
  int _customTickerCount(AppCubit cubit) {
    final ids = <String>{};
    for (final card in cubit.state.cards) {
      if (cubit.isCustom(card.instrumentID)) ids.add(card.instrumentID);
    }
    return ids.length;
  }

  Widget _row(QimaColors colors, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(label, style: TextStyle(color: colors.textTertiary, fontSize: 12))),
        Expanded(
          flex: 2,
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(color: colors.textPrimary, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _passwordField(
    QimaColors colors,
    String label,
    TextEditingController controller, {
    String? errorText,
  }) {
    return TextField(
      controller: controller,
      obscureText: _obscure,
      autocorrect: false,
      enableSuggestions: false,
      style: TextStyle(color: colors.textPrimary),
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: colors.textTertiary),
        errorText: errorText,
        filled: true,
        fillColor: colors.tileTop,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(DS.radiusTile), borderSide: BorderSide.none),
        suffixIcon: IconButton(
          icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: colors.textTertiary),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      ),
    );
  }
}
