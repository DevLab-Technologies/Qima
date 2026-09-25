import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/app_cubit.dart';
import '../blocs/app_state.dart';
import '../l10n/app_localizations.dart';
import '../models/price_alert.dart';
import '../models/watch_card.dart';
import '../services/system_settings.dart';
import '../theme/design_system.dart';
import '../theme/help_topics.dart';
import '../theme/instrument_theme.dart';
import '../theme/qima_colors.dart';
import '../theme/strings.dart';
import '../widgets/confirm_delete_dialog.dart';
import '../widgets/help_button.dart';
import '../widgets/instrument_icon.dart';
import 'alert_editor_sheet.dart';
import 'instrument_detail_screen.dart';

/// Full alerts management screen, opened from Settings → Alerts → "Price
/// alerts" (spec Phase 5): an info note about background check cadence,
/// alerts grouped by card under an instrument icon header, enable switches,
/// a fired-state caption, an empty state, and a "Notifications are off"
/// banner with "Open settings" when the OS permission is denied. Swipe to
/// delete with the same confirmation every other list in the app uses.
class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<AppCubit>().refreshNotificationStatus());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Catches the user flipping the OS notification toggle for Qima while
    // "Open settings" had them backgrounded, so the banner clears the
    // moment they come back instead of looking stale.
    if (state == AppLifecycleState.resumed && mounted) {
      context.read<AppCubit>().refreshNotificationStatus();
    }
  }

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
          title: Text(l10n.alertsScreenTitle),
          actions: const [HelpButton(topic: HelpTopicId.priceAlerts)],
        ),
        body: BlocBuilder<AppCubit, AppState>(
          builder: (context, state) {
            final alerts = state.alerts;
            final grouped = <String, List<PriceAlert>>{};
            for (final alert in alerts) {
              grouped.putIfAbsent(alert.cardID, () => []).add(alert);
            }
            final cardsByID = {for (final c in state.cards) c.id: c};

            return ListView(
              padding: const EdgeInsets.all(DS.spaceMD),
              children: [
                if (!state.notificationsEnabled) ...[
                  _NotificationsOffBanner(onOpenSettings: SystemSettings.openNotificationSettings),
                  const SizedBox(height: DS.spaceMD),
                ],
                DSCard(
                  child: Text(l10n.alertsScreenInfo, style: TextStyle(color: colors.textTertiary, fontSize: 12)),
                ),
                const SizedBox(height: DS.spaceMD),
                if (alerts.isEmpty)
                  _EmptyState(l10n: l10n, colors: colors)
                else
                  for (final entry in grouped.entries)
                    if (cardsByID[entry.key] != null)
                      _CardGroup(card: cardsByID[entry.key]!, alerts: entry.value, cubit: cubit),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final AppLocalizations l10n;
  final QimaColors colors;

  const _EmptyState({required this.l10n, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DS.spaceXL),
      child: Column(
        children: [
          Icon(Icons.notifications_none, color: colors.textTertiary, size: 40),
          const SizedBox(height: DS.spaceSM),
          Text(l10n.alertsScreenEmptyTitle, style: TextStyle(color: colors.textSecondary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(
            l10n.alertsScreenEmptyMessage,
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.textTertiary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _NotificationsOffBanner extends StatelessWidget {
  final VoidCallback onOpenSettings;

  const _NotificationsOffBanner({required this.onOpenSettings});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    return DSCard(
      child: Row(
        children: [
          Icon(Icons.notifications_off_outlined, color: colors.down),
          const SizedBox(width: DS.spaceSM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.alertsScreenNotificationsOff, style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(l10n.alertsScreenNotificationsOffMessage, style: TextStyle(color: colors.textTertiary, fontSize: 12)),
              ],
            ),
          ),
          TextButton(onPressed: onOpenSettings, child: Text(l10n.alertsScreenOpenSettings)),
        ],
      ),
    );
  }
}

class _CardGroup extends StatelessWidget {
  final WatchCard card;
  final List<PriceAlert> alerts;
  final AppCubit cubit;

  const _CardGroup({required this.card, required this.alerts, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final instrument = card.instrument;
    if (instrument == null) return const SizedBox.shrink();
    final colors = context.colors;
    final accent = InstrumentTheme.accentColor(instrument, colors);

    return Padding(
      padding: const EdgeInsets.only(bottom: DS.spaceMD),
      child: DSCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(DS.radiusTile),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => InstrumentDetailScreen(card: card)),
              ),
              child: Row(
                children: [
                  InstrumentIcon(instrument: instrument, size: 28),
                  const SizedBox(width: DS.spaceSM),
                  Expanded(
                    child: Text(
                      displayLabel(context, instrument.nameKey),
                      style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w700),
                    ),
                  ),
                  Icon(Icons.chevron_right, color: colors.textTertiary),
                ],
              ),
            ),
            for (final alert in alerts) ...[
              Divider(color: colors.hairline, height: DS.spaceLG),
              _AlertTile(alert: alert, card: card, cubit: cubit, accent: accent),
            ],
          ],
        ),
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  final PriceAlert alert;
  final WatchCard card;
  final AppCubit cubit;
  final Color accent;

  const _AlertTile({required this.alert, required this.card, required this.cubit, required this.accent});

  String _summary(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final converter = cubit.presentation(card).converter;
    switch (alert.kind) {
      case AlertKind.above:
        return '${l10n.alertKindAbove} ${converter.money(alert.target).formatted()}';
      case AlertKind.below:
        return '${l10n.alertKindBelow} ${converter.money(alert.target).formatted()}';
      case AlertKind.percentMove:
        final percent = (alert.percent * 100).toStringAsFixed(0);
        final direction = displayLabel(context, alert.direction.labelKey);
        final window = displayLabel(context, alert.window.labelKey);
        return '$direction $percent% · $window';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return Dismissible(
      key: ValueKey('alert-dismissible-${alert.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => confirmDelete(
        context,
        title: l10n.confirmDeleteAlertTitle,
        message: l10n.confirmDeleteAlertMessage,
        confirmLabel: l10n.commonDelete,
      ),
      onDismissed: (_) => cubit.deleteAlert(alert),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: DS.spaceMD),
        child: Icon(Icons.delete, color: colors.down),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(DS.radiusTile),
        onTap: () => AlertEditorSheet.show(context, card: card, existing: alert),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _summary(context),
                      style: TextStyle(color: alert.enabled ? colors.textPrimary : colors.textTertiary, fontSize: 14),
                    ),
                    FutureBuilder(
                      future: cubit.runtimeStateFor(alert.id),
                      builder: (context, snapshot) {
                        final firedAt = snapshot.data?.lastFiredAt;
                        if (firedAt == null || alert.enabled) return const SizedBox.shrink();
                        final today = DateTime.now();
                        final isToday =
                            firedAt.year == today.year && firedAt.month == today.month && firedAt.day == today.day;
                        if (!isToday) return const SizedBox.shrink();
                        final time =
                            '${firedAt.hour.toString().padLeft(2, '0')}:${firedAt.minute.toString().padLeft(2, '0')}';
                        return Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            l10n.alertsScreenFiredToday(time),
                            style: TextStyle(color: colors.textTertiary, fontSize: 11),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Switch(
                value: alert.enabled,
                activeThumbColor: colors.onBrand,
                activeTrackColor: colors.brand,
                onChanged: (value) => cubit.setAlertEnabled(alert, value),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
