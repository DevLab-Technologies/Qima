import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../blocs/app_cubit.dart';
import '../l10n/app_localizations.dart';
import '../models/backup.dart';
import '../services/backup/backup_codec.dart';
import '../services/backup/backup_service.dart';
import '../theme/design_system.dart';
import '../theme/qima_colors.dart';
import '../widgets/confirm_delete_dialog.dart';

/// Import preview (spec Phase 6): shows the picked file's summary, prompts
/// for a password if it's encrypted, lets the user choose Merge vs Replace
/// with a live diff, and restores on confirmation. Also handles the
/// "picked a CSV, not a JSON backup" and generic parse-error states.
///
/// The password the user types here is held only in this widget's local
/// [TextEditingController] and passed directly to
/// `BackupService.preview`/`AppCubit.restoreFromBackup` — never logged or
/// persisted.
class ImportPreviewScreen extends StatefulWidget {
  final PickedBackupFile picked;

  const ImportPreviewScreen({super.key, required this.picked});

  @override
  State<ImportPreviewScreen> createState() => _ImportPreviewScreenState();
}

enum _Stage { loading, needsPassword, ready, csvError, error }

class _ImportPreviewScreenState extends State<ImportPreviewScreen> {
  _Stage _stage = _Stage.loading;
  BackupEnvelope? _envelope;
  BackupPreview? _preview;
  BackupImportMode _mode = BackupImportMode.merge;
  BackupErrorKind? _errorKind;
  bool _restoring = false;
  final _passwordController = TextEditingController();
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    if (widget.picked.looksLikeCsv) {
      setState(() => _stage = _Stage.csvError);
      return;
    }
    final cubit = context.read<AppCubit>();
    try {
      final envelope = cubit.backupService.parseEnvelope(widget.picked.raw);
      _envelope = envelope;
      if (envelope.encrypted) {
        setState(() => _stage = _Stage.needsPassword);
      } else {
        await _loadPreview(cubit);
      }
    } on BackupError catch (e) {
      setState(() {
        _errorKind = e.kind;
        _stage = _Stage.error;
      });
    }
  }

  Future<void> _loadPreview(AppCubit cubit, {String? password}) async {
    final envelope = _envelope;
    if (envelope == null) return;
    try {
      final preview = await cubit.backupService.preview(envelope, password: password);
      if (!mounted) return;
      setState(() {
        _preview = preview;
        _passwordError = null;
        _stage = _Stage.ready;
      });
    } on BackupError catch (e) {
      if (!mounted) return;
      if (e.kind == BackupErrorKind.wrongPassword && envelope.encrypted) {
        setState(() {
          _passwordError = AppLocalizations.of(context)!.backupImportPasswordIncorrect;
          _stage = _Stage.needsPassword;
        });
      } else {
        setState(() {
          _errorKind = e.kind;
          _stage = _Stage.error;
        });
      }
    }
  }

  Future<void> _restore(BuildContext context) async {
    final cubit = context.read<AppCubit>();
    final l10n = AppLocalizations.of(context)!;
    final preview = _preview;
    if (preview == null) return;

    if (_mode == BackupImportMode.replace) {
      final confirmed = await confirmDelete(
        context,
        title: l10n.backupImportReplaceConfirmTitle,
        message: l10n.backupImportReplaceConfirmMessage,
        confirmLabel: l10n.backupImportReplaceConfirmAction,
      );
      if (!confirmed) return;
    }

    setState(() => _restoring = true);
    try {
      await cubit.restoreFromBackup(preview.payload, mode: _mode);
      if (!context.mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.backupImportSuccessSnackbar)));
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _restoring = false;
        _errorKind = BackupErrorKind.corrupted;
        _stage = _Stage.error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return ScreenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(backgroundColor: Colors.transparent, title: Text(l10n.backupImportPreviewTitle)),
        body: SafeArea(child: _body(context, l10n, colors)),
      ),
    );
  }

  Widget _body(BuildContext context, AppLocalizations l10n, QimaColors colors) {
    switch (_stage) {
      case _Stage.loading:
        return const Center(child: CircularProgressIndicator());
      case _Stage.csvError:
        return _ErrorState(
          icon: Icons.table_chart_outlined,
          title: l10n.backupImportCsvErrorTitle,
          message: l10n.backupImportCsvErrorMessage,
        );
      case _Stage.error:
        return _ErrorState(
          icon: Icons.error_outline,
          title: l10n.backupImportFailedTitle,
          message: BackupError(_errorKind ?? BackupErrorKind.corrupted).message(l10n),
        );
      case _Stage.needsPassword:
        return _passwordPrompt(context, l10n, colors);
      case _Stage.ready:
        return _readyBody(context, l10n, colors);
    }
  }

  Widget _passwordPrompt(BuildContext context, AppLocalizations l10n, QimaColors colors) {
    return Padding(
      padding: const EdgeInsets.all(DS.spaceMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _fileCard(l10n, colors),
          const SizedBox(height: DS.spaceLG),
          Text(l10n.backupImportPasswordPrompt, style: TextStyle(color: colors.textSecondary)),
          const SizedBox(height: DS.spaceSM),
          TextField(
            controller: _passwordController,
            obscureText: true,
            autocorrect: false,
            enableSuggestions: false,
            style: TextStyle(color: colors.textPrimary),
            onSubmitted: (_) => _loadPreview(context.read<AppCubit>(), password: _passwordController.text),
            decoration: InputDecoration(
              labelText: l10n.backupImportPasswordLabel,
              labelStyle: TextStyle(color: colors.textTertiary),
              errorText: _passwordError,
              filled: true,
              fillColor: colors.tileTop,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(DS.radiusTile), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: DS.spaceMD),
          FilledButton(
            onPressed: () => _loadPreview(context.read<AppCubit>(), password: _passwordController.text),
            child: Text(l10n.backupImportUnlock),
          ),
        ],
      ),
    );
  }

  Widget _readyBody(BuildContext context, AppLocalizations l10n, QimaColors colors) {
    final preview = _preview!;
    final diff = _mode == BackupImportMode.merge ? preview.mergeDiff : preview.replaceDiff;
    return ListView(
      padding: const EdgeInsets.all(DS.spaceMD),
      children: [
        _fileCard(l10n, colors),
        const SizedBox(height: DS.spaceLG),
        DSCard(
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: DS.spaceSM,
            crossAxisSpacing: DS.spaceSM,
            childAspectRatio: 2.6,
            children: [
              _countTile(colors, l10n.backupImportCountCards, '${preview.cardCount}'),
              _countTile(colors, l10n.backupImportCountLots, '${preview.lotCount}'),
              _countTile(colors, l10n.backupImportCountCustomTickers, '${preview.customTickerCount}'),
              _countTile(colors, l10n.backupImportCountSettings, '✓'),
            ],
          ),
        ),
        const SizedBox(height: DS.spaceLG),
        SegmentedButton<BackupImportMode>(
          segments: [
            ButtonSegment(value: BackupImportMode.merge, label: Text(l10n.backupImportModeMerge)),
            ButtonSegment(value: BackupImportMode.replace, label: Text(l10n.backupImportModeReplace)),
          ],
          selected: {_mode},
          onSelectionChanged: (selection) => setState(() => _mode = selection.first),
          style: DS.segmentedButtonStyle(colors, colors.brand),
        ),
        const SizedBox(height: DS.spaceXS),
        Text(
          _mode == BackupImportMode.merge ? l10n.backupImportModeMergeFooter : l10n.backupImportModeReplaceFooter,
          style: TextStyle(color: colors.textTertiary, fontSize: 12),
        ),
        const SizedBox(height: DS.spaceSM),
        Text(
          l10n.backupImportDiff(diff.added, diff.updated, diff.removed),
          style: TextStyle(color: colors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: DS.spaceLG),
        FilledButton(
          onPressed: _restoring ? null : () => _restore(context),
          style: _mode == BackupImportMode.replace
              ? FilledButton.styleFrom(backgroundColor: colors.down)
              : null,
          child: _restoring
              ? SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: colors.onBrand))
              : Text(l10n.backupImportRestoreButton),
        ),
      ],
    );
  }

  Widget _fileCard(AppLocalizations l10n, QimaColors colors) {
    final envelope = _envelope;
    return DSCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.description_outlined, color: colors.brand),
              const SizedBox(width: DS.spaceSM),
              Expanded(
                child: Text(
                  widget.picked.name,
                  style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w700),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (envelope?.encrypted == true) Icon(Icons.lock_outline, color: colors.textTertiary, size: 16),
            ],
          ),
          if (envelope != null) ...[
            const SizedBox(height: DS.spaceXS),
            Text(
              l10n.backupImportFileCreated(DateFormat.yMMMd().add_Hm().format(envelope.createdAt.toLocal())),
              style: TextStyle(color: colors.textTertiary, fontSize: 12),
            ),
            Text(
              l10n.backupImportFileAppVersion(envelope.app.version),
              style: TextStyle(color: colors.textTertiary, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  Widget _countTile(QimaColors colors, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: DS.spaceSM, vertical: DS.spaceXS),
      decoration: DS.tile(colors),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
          Text(label, style: TextStyle(color: colors.textTertiary, fontSize: 11), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _ErrorState({required this.icon, required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DS.spaceLG),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: colors.down, size: 40),
            const SizedBox(height: DS.spaceMD),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: DS.spaceXS),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.textTertiary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
