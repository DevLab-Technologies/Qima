import 'package:flutter/foundation.dart' show kIsWeb, TargetPlatform, defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../blocs/app_cubit.dart';
import '../blocs/app_state.dart';
import '../l10n/app_localizations.dart';
import '../models/chart_range.dart';
import '../services/app_lock_service.dart';
import '../services/preferences.dart';
import '../theme/design_system.dart';
import '../theme/qima_colors.dart';
import '../theme/strings.dart';
import 'alerts_screen.dart';
import 'backup_screen.dart';
import 'currency_picker.dart';

/// Single settings sheet: base currency, default chart range, widget refresh
/// interval, language, and a static data-sources footer. Mirrors
/// `SettingsView.swift`.
///
/// Used two ways (spec §v2-C): pushed on the root navigator (default — back
/// arrow like any other pushed screen) or hosted as `HomeShell`'s Settings
/// tab, which passes [asTab]: true so no back arrow is shown.
class SettingsScreen extends StatelessWidget {
  final bool asTab;
  final ScrollController? scrollController;

  const SettingsScreen({super.key, this.asTab = false, this.scrollController});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AppCubit>();
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return ScreenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: !asTab,
          titleSpacing: asTab ? 16 : null,
          title: Text(l10n.settingsTitle),
        ),
        body: BlocBuilder<AppCubit, AppState>(
          builder: (context, _) {
            final state = cubit.state;
            return ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(DS.spaceMD),
              children: [
                _SectionHeader(l10n.settingsAppearance),
                DSCard(
                  child: SegmentedButton<Appearance>(
                    segments: [
                      ButtonSegment(value: Appearance.system, label: Text(l10n.settingsAppearanceSystem)),
                      ButtonSegment(value: Appearance.light, label: Text(l10n.settingsAppearanceLight)),
                      ButtonSegment(value: Appearance.dark, label: Text(l10n.settingsAppearanceDark)),
                    ],
                    selected: {state.appearance},
                    onSelectionChanged: (selection) => cubit.setAppearance(selection.first),
                    style: DS.segmentedButtonStyle(colors, colors.brand),
                  ),
                ),
                const SizedBox(height: DS.spaceLG),
                _SectionHeader(l10n.settingsAlerts),
                const _AlertsSection(),
                const SizedBox(height: DS.spaceLG),
                _SectionHeader(l10n.settingsPrivacy),
                const _PrivacySecuritySection(),
                const SizedBox(height: DS.spaceLG),
                if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) ...[
                  _SectionHeader(l10n.settingsICloudSync),
                  const _ICloudSyncSection(),
                  const SizedBox(height: DS.spaceLG),
                ],
                _SectionHeader(l10n.settingsBackup),
                const _BackupSection(),
                const SizedBox(height: DS.spaceLG),
                _SectionHeader(l10n.settingsBaseCurrency),
                DSCard(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.settingsPortfolioCurrency, style: TextStyle(color: colors.textPrimary)),
                    subtitle: Text(
                      l10n.settingsBaseCurrencyFooter,
                      style: TextStyle(color: colors.textTertiary),
                    ),
                    trailing: Text(state.baseCurrency, style: TextStyle(color: colors.textSecondary)),
                    onTap: () async {
                      final selected = await CurrencyPicker.show(
                        context,
                        selected: state.baseCurrency,
                        currencies: state.rates.availableCurrencies,
                      );
                      if (selected != null) await cubit.setBaseCurrency(selected);
                    },
                  ),
                ),
                const SizedBox(height: DS.spaceLG),
                _SectionHeader(l10n.settingsDefaultRange),
                DSCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Wrap(
                        spacing: DS.spaceXS,
                        runSpacing: DS.spaceXS,
                        children: [
                          for (final range in ChartRange.defaultSelectable)
                            DSChoiceChip(
                              label: displayLabel(context, range.labelKey),
                              selected: state.preferredChartRange == range,
                              onSelected: (_) => cubit.setPreferredChartRange(range),
                            ),
                        ],
                      ),
                      const SizedBox(height: DS.spaceXS),
                      Text(l10n.settingsDefaultRangeFooter, style: TextStyle(color: colors.textTertiary, fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(height: DS.spaceLG),
                _SectionHeader(l10n.settingsWidgetRefresh),
                DSCard(
                  child: Column(
                    children: [
                      RadioGroup<WidgetRefreshInterval>(
                        groupValue: state.widgetRefreshInterval,
                        onChanged: (value) {
                          if (value != null) cubit.setWidgetRefreshInterval(value);
                        },
                        child: Column(
                          children: [
                            for (final interval in WidgetRefreshInterval.values)
                              RadioListTile<WidgetRefreshInterval>(
                                contentPadding: EdgeInsets.zero,
                                title: Text(displayLabel(context, interval.labelKey), style: TextStyle(color: colors.textPrimary)),
                                value: interval,
                                activeColor: colors.brand,
                              ),
                          ],
                        ),
                      ),
                      Divider(color: colors.hairline),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: DS.spaceSM),
                        child: Text(
                          l10n.settingsWidgetRefreshFooter,
                          style: TextStyle(color: colors.textTertiary, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: DS.spaceLG),
                _SectionHeader(l10n.settingsAbout),
                DSCard(
                  child: Column(
                    children: [
                      RadioGroup<AppLanguage>(
                        groupValue: state.appLanguage,
                        onChanged: (value) {
                          if (value != null) cubit.setAppLanguage(value);
                        },
                        child: Column(
                          children: [
                            for (final language in AppLanguage.values)
                              RadioListTile<AppLanguage>(
                                contentPadding: EdgeInsets.zero,
                                title: Text(
                                  language == AppLanguage.system ? l10n.settingsLanguageSystem : language.nativeName,
                                  style: TextStyle(color: colors.textPrimary),
                                ),
                                value: language,
                                activeColor: colors.brand,
                              ),
                          ],
                        ),
                      ),
                      Divider(color: colors.hairline),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: DS.spaceSM),
                        child: Text(
                          l10n.settingsDataSource,
                          style: TextStyle(color: colors.textTertiary, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// "Alerts" settings card (spec Phase 5): a "Price alerts" row (count
/// summary, opens [AlertsScreen]), a "Notifications" status row, and a
/// "Deliver alerts on this device" switch.
class _AlertsSection extends StatelessWidget {
  const _AlertsSection();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AppCubit>();
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return BlocBuilder<AppCubit, AppState>(
      bloc: cubit,
      builder: (context, state) {
        return DSCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.settingsAlertsPriceAlerts, style: TextStyle(color: colors.textPrimary)),
                subtitle: Text(
                  l10n.settingsAlertsCount(state.alerts.length),
                  style: TextStyle(color: colors.textTertiary, fontSize: 12),
                ),
                trailing: Icon(Icons.chevron_right, color: colors.textTertiary),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AlertsScreen())),
              ),
              Divider(color: colors.hairline, height: DS.spaceLG),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.settingsAlertsNotifications, style: TextStyle(color: colors.textPrimary)),
                trailing: Text(
                  state.notificationsEnabled ? l10n.settingsAlertsNotificationsOn : l10n.settingsAlertsNotificationsOff,
                  style: TextStyle(color: colors.textSecondary),
                ),
              ),
              Divider(color: colors.hairline, height: DS.spaceLG),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.settingsAlertsDeliverOnDevice, style: TextStyle(color: colors.textPrimary)),
                subtitle: Text(
                  l10n.settingsAlertsDeliverOnDeviceFooter,
                  style: TextStyle(color: colors.textTertiary, fontSize: 12),
                ),
                value: state.deliverAlertsOnThisDevice,
                activeThumbColor: colors.onBrand,
                activeTrackColor: colors.brand,
                onChanged: (value) => cubit.setDeliverAlertsOnThisDevice(value),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// "Privacy & security" settings card: a "Hide balances" switch and an "App
/// lock" switch + "Lock after" row (spec Phase 4, Figma "Settings hub ·
/// Privacy & security card"). App lock is only offered when the device
/// actually supports biometrics or a passcode — [AppLockService.isSupported]
/// is resolved once via a [FutureBuilder] and, while it's false, the tile is
/// shown disabled with an explanatory subtitle rather than hidden entirely,
/// so a user on unsupported hardware understands why it's unavailable
/// instead of wondering if the feature is missing.
class _PrivacySecuritySection extends StatefulWidget {
  const _PrivacySecuritySection();

  @override
  State<_PrivacySecuritySection> createState() => _PrivacySecuritySectionState();
}

class _PrivacySecuritySectionState extends State<_PrivacySecuritySection> {
  late final Future<bool> _supported;

  @override
  void initState() {
    super.initState();
    _supported = context.read<AppCubit>().appLockService.isSupported;
  }

  /// `local_auth` ships no web or Linux implementation at all — rather than
  /// showing a permanently-disabled tile on platforms that can never
  /// support it, the App lock rows are omitted entirely there (spec Phase 4:
  /// "hide the setting on web/linux"). Other platforms with no biometric
  /// enrollment/passcode instead show the tile disabled with an
  /// explanation, since that's a fixable state the user can act on.
  bool get _appLockPlatformSupported {
    if (kIsWeb) return false;
    return defaultTargetPlatform != TargetPlatform.linux;
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AppCubit>();
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    // This widget is placed as a `const` child inside SettingsScreen's own
    // outer BlocBuilder, so Flutter's element diffing can skip rebuilding
    // this whole subtree when the parent rebuilds but the const widget
    // instance is unchanged — its own BlocBuilder subscription is what
    // actually keeps the hide-balances/app-lock switches and the "Lock
    // after" row in sync with AppCubit, independent of the parent.
    return BlocBuilder<AppCubit, AppState>(
      bloc: cubit,
      builder: (context, state) {
        return FutureBuilder<bool>(
          future: _supported,
          builder: (context, snapshot) {
            // Defaults to "supported" while the check is in flight, so the
            // switch doesn't flash disabled-then-enabled on every settings
            // open; it only locks into the disabled state once the check
            // resolves false.
            final lockSupported = snapshot.data ?? true;
            final checkDone = snapshot.connectionState == ConnectionState.done;

            return DSCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.settingsHideBalances, style: TextStyle(color: colors.textPrimary)),
                    subtitle:
                        Text(l10n.settingsHideBalancesFooter, style: TextStyle(color: colors.textTertiary, fontSize: 12)),
                    value: state.hideBalances,
                    activeThumbColor: colors.onBrand,
                    activeTrackColor: colors.brand,
                    onChanged: (value) => cubit.setHideBalances(value),
                  ),
                  if (_appLockPlatformSupported) ...[
                    Divider(color: colors.hairline, height: DS.spaceLG),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.settingsAppLock, style: TextStyle(color: colors.textPrimary)),
                      subtitle: Text(
                        checkDone && !lockSupported ? l10n.settingsAppLockUnavailable : l10n.settingsAppLockFooter,
                        style: TextStyle(color: colors.textTertiary, fontSize: 12),
                      ),
                      value: state.appLockEnabled,
                      activeThumbColor: colors.onBrand,
                      activeTrackColor: colors.brand,
                      onChanged: !checkDone || !lockSupported
                          ? null
                          : (value) async {
                              final enabled = await cubit.setAppLockEnabled(value, reason: l10n.appLockAuthReason);
                              if (!enabled && value && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(l10n.settingsAppLockFailed)),
                                );
                              }
                            },
                    ),
                    if (state.appLockEnabled) ...[
                      Divider(color: colors.hairline, height: DS.spaceLG),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.settingsLockAfter, style: TextStyle(color: colors.textPrimary)),
                        trailing: Text(
                          displayLabel(context, state.lockGrace.labelKey),
                          style: TextStyle(color: colors.textSecondary),
                        ),
                        onTap: () => _showLockAfterSheet(context, cubit),
                      ),
                    ],
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showLockAfterSheet(BuildContext context, AppCubit cubit) async {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.overlay,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(DS.radiusCard)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: DS.spaceMD),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: DS.spaceMD),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      l10n.settingsLockAfter,
                      style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                  ),
                ),
                BlocBuilder<AppCubit, AppState>(
                  bloc: cubit,
                  builder: (context, state) {
                    return RadioGroup<LockGrace>(
                      groupValue: state.lockGrace,
                      onChanged: (value) {
                        if (value == null) return;
                        cubit.setLockGrace(value);
                        Navigator.of(sheetContext).pop();
                      },
                      child: Column(
                        children: [
                          for (final grace in LockGrace.values)
                            RadioListTile<LockGrace>(
                              title: Text(displayLabel(context, grace.labelKey), style: TextStyle(color: colors.textPrimary)),
                              value: grace,
                              activeColor: colors.brand,
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// "iCloud sync" settings card (spec Phase 7, iOS only — [SettingsScreen]
/// only builds this section on iOS): a "Sync with iCloud" switch plus a
/// status line reflecting [AppState.cloudSyncStatus]. Turning the switch on
/// merges — never wipes — this device's local data with whatever's already
/// in iCloud (see `AppCubit.setICloudSyncEnabled`); turning it off just
/// stops listening for changes, it never deletes anything.
class _ICloudSyncSection extends StatelessWidget {
  const _ICloudSyncSection();

  String _statusText(BuildContext context, AppState state, AppLocalizations l10n) {
    switch (state.cloudSyncStatus) {
      case CloudSyncStatus.disabled:
        return '';
      case CloudSyncStatus.syncing:
        return l10n.settingsICloudSyncStatusSyncing;
      case CloudSyncStatus.notSignedIn:
        return l10n.settingsICloudSyncStatusNotSignedIn;
      case CloudSyncStatus.storageFull:
        return l10n.settingsICloudSyncStatusStorageFull;
      case CloudSyncStatus.upToDate:
        final at = state.lastCloudSyncAt;
        if (at == null) return l10n.settingsICloudSyncStatusSyncing;
        return l10n.settingsICloudSyncStatusUpToDate(DateFormat.Hm(Localizations.localeOf(context).toString()).format(at.toLocal()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AppCubit>();
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return BlocBuilder<AppCubit, AppState>(
      bloc: cubit,
      builder: (context, state) {
        final statusText = _statusText(context, state, l10n);
        final statusColor = state.cloudSyncStatus == CloudSyncStatus.storageFull ||
                state.cloudSyncStatus == CloudSyncStatus.notSignedIn
            ? colors.down
            : colors.textTertiary;

        return DSCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.settingsICloudSyncSwitch, style: TextStyle(color: colors.textPrimary)),
                subtitle: Text(l10n.settingsICloudSyncFooter, style: TextStyle(color: colors.textTertiary, fontSize: 12)),
                value: state.iCloudSyncEnabled,
                activeThumbColor: colors.onBrand,
                activeTrackColor: colors.brand,
                onChanged: (value) => cubit.setICloudSyncEnabled(value),
              ),
              if (state.iCloudSyncEnabled && statusText.isNotEmpty) ...[
                Divider(color: colors.hairline, height: DS.spaceLG),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: DS.spaceXS),
                  child: Text(statusText, style: TextStyle(color: statusColor, fontSize: 12)),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// "Backup & restore" settings row (spec Phase 6): opens [BackupScreen],
/// subtitle shows the last backup's relative date and counts, or "Never
/// backed up".
class _BackupSection extends StatelessWidget {
  const _BackupSection();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AppCubit>();
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return BlocBuilder<AppCubit, AppState>(
      bloc: cubit,
      builder: (context, state) {
        final lastBackupAt = cubit.backupServiceOrNull?.lastBackupAt;
        final instrumentCount = cubit.heldInstruments.length;
        final subtitle = lastBackupAt == null
            ? l10n.settingsBackupSubtitleNever
            : l10n.settingsBackupSubtitle(
                MaterialLocalizations.of(context).formatMediumDate(lastBackupAt),
                instrumentCount,
                state.lots.length,
              );
        return DSCard(
          padding: EdgeInsets.zero,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: DS.spaceMD, vertical: DS.spaceXS),
            title: Text(l10n.settingsBackup, style: TextStyle(color: colors.textPrimary)),
            subtitle: Text(subtitle, style: TextStyle(color: colors.textTertiary, fontSize: 12)),
            trailing: Icon(Icons.chevron_right, color: colors.textTertiary),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BackupScreen())),
          ),
        );
      },
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
