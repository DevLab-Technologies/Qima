import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../blocs/app_cubit.dart';
import '../blocs/app_state.dart';
import '../l10n/app_localizations.dart';
import '../services/backup/backup_service.dart';
import '../theme/design_system.dart';
import '../theme/qima_colors.dart';
import 'export_backup_sheet.dart';
import 'import_preview_screen.dart';

/// Settings → Backup & restore (spec Phase 6): a "stored only on this
/// phone" status card (with an in-app reminder card when a backup is due),
/// an Export section (full JSON backup / holdings CSV), a Restore section,
/// and a monthly-reminder toggle.
class BackupScreen extends StatelessWidget {
  const BackupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AppCubit>();
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return ScreenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(backgroundColor: Colors.transparent, title: Text(l10n.backupTitle)),
        body: BlocBuilder<AppCubit, AppState>(
          builder: (context, state) {
            return ListView(
              padding: const EdgeInsets.all(DS.spaceMD),
              children: [
                if (state.backupReminderDue) ...[
                  _ReminderCard(onBackUpNow: () => _openExportSheet(context)),
                  const SizedBox(height: DS.spaceMD),
                ],
                DSCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lock_outline, color: colors.textSecondary, size: 20),
                          const SizedBox(width: DS.spaceXS),
                          Expanded(
                            child: Text(
                              l10n.backupStatusTitle,
                              style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: DS.spaceXS),
                      Text(l10n.backupStatusMessage, style: TextStyle(color: colors.textTertiary, fontSize: 12)),
                      const SizedBox(height: DS.spaceSM),
                      Text(
                        cubit.backupServiceOrNull?.lastBackupAt == null
                            ? l10n.backupLastBackupNever
                            : l10n.backupLastBackup(DateFormat.yMMMd().format(cubit.backupServiceOrNull!.lastBackupAt!)),
                        style: TextStyle(color: colors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: DS.spaceLG),
                _SectionHeader(l10n.backupExportSection),
                DSCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.description_outlined, color: colors.brand),
                        title: Text(l10n.backupExportFullTitle, style: TextStyle(color: colors.textPrimary)),
                        subtitle: Text(
                          l10n.backupExportFullSubtitle,
                          style: TextStyle(color: colors.textTertiary, fontSize: 12),
                        ),
                        trailing: Icon(Icons.chevron_right, color: colors.textTertiary),
                        onTap: () => _openExportSheet(context),
                      ),
                      Divider(color: colors.hairline, height: 1),
                      ListTile(
                        leading: Icon(Icons.table_chart_outlined, color: colors.brand),
                        title: Text(l10n.backupExportCsvTitle, style: TextStyle(color: colors.textPrimary)),
                        subtitle: Text(
                          l10n.backupExportCsvSubtitle,
                          style: TextStyle(color: colors.textTertiary, fontSize: 12),
                        ),
                        trailing: Icon(Icons.chevron_right, color: colors.textTertiary),
                        onTap: () => _exportCsv(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: DS.spaceLG),
                _SectionHeader(l10n.backupRestoreSection),
                DSCard(
                  padding: EdgeInsets.zero,
                  child: ListTile(
                    leading: Icon(Icons.file_open_outlined, color: colors.brand),
                    title: Text(l10n.backupRestoreTitle, style: TextStyle(color: colors.textPrimary)),
                    subtitle: Text(
                      l10n.backupRestoreSubtitle,
                      style: TextStyle(color: colors.textTertiary, fontSize: 12),
                    ),
                    trailing: Icon(Icons.chevron_right, color: colors.textTertiary),
                    onTap: () => _pickAndPreview(context),
                  ),
                ),
                const SizedBox(height: DS.spaceLG),
                _SectionHeader(l10n.backupReminderSection),
                const _ReminderToggleCard(),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _openExportSheet(BuildContext context) async {
    await ExportBackupSheet.show(context);
  }

  Future<void> _exportCsv(BuildContext context) async {
    final cubit = context.read<AppCubit>();
    final l10n = AppLocalizations.of(context)!;
    final box = context.findRenderObject() as RenderBox?;
    final origin = box == null ? null : (box.localToGlobal(Offset.zero) & box.size);
    await cubit.backupService.exportHoldingsCsv(lots: cubit.state.lots, l10n: l10n, sharePositionOrigin: origin);
  }

  Future<void> _pickAndPreview(BuildContext context) async {
    final cubit = context.read<AppCubit>();
    final picked = await cubit.backupService.pickBackupFile();
    if (picked == null || !context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ImportPreviewScreen(picked: picked)),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  final VoidCallback onBackUpNow;

  const _ReminderCard({required this.onBackUpNow});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    return DSCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, color: colors.down),
          const SizedBox(width: DS.spaceSM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.backupReminderCardTitle,
                  style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(l10n.backupReminderCardMessage, style: TextStyle(color: colors.textTertiary, fontSize: 12)),
                const SizedBox(height: DS.spaceSM),
                TextButton(
                  style: TextButton.styleFrom(foregroundColor: colors.brand, padding: EdgeInsets.zero),
                  onPressed: onBackUpNow,
                  child: Text(l10n.backupReminderCardAction),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The "Remind me to back up" switch. [BackupService.reminderEnabled] is a
/// local `SharedPreferences` flag, not part of [AppState] — kept as its own
/// small stateful widget (rather than threading it through the cubit's
/// state) so flipping it rebuilds only this row, and reads back the
/// just-written value directly rather than relying on a whole-screen
/// `setState`.
class _ReminderToggleCard extends StatefulWidget {
  const _ReminderToggleCard();

  @override
  State<_ReminderToggleCard> createState() => _ReminderToggleCardState();
}

class _ReminderToggleCardState extends State<_ReminderToggleCard> {
  late bool _enabled;

  @override
  void initState() {
    super.initState();
    _enabled = context.read<AppCubit>().backupServiceOrNull?.reminderEnabled ?? true;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    return DSCard(
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(l10n.backupReminderToggleTitle, style: TextStyle(color: colors.textPrimary)),
        subtitle: Text(l10n.backupReminderToggleSubtitle, style: TextStyle(color: colors.textTertiary, fontSize: 12)),
        value: _enabled,
        activeThumbColor: colors.onBrand,
        activeTrackColor: colors.brand,
        onChanged: (value) async {
          setState(() => _enabled = value);
          await context.read<AppCubit>().backupService.setReminderEnabled(value);
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DS.spaceXS, left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(color: context.colors.textTertiary, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5),
      ),
    );
  }
}
