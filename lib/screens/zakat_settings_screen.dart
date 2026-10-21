import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/app_cubit.dart';
import '../blocs/app_state.dart';
import '../l10n/app_localizations.dart';
import '../models/hijri_date.dart';
import '../models/zakat.dart';
import '../theme/design_system.dart';
import '../theme/help_topics.dart';
import '../theme/masking.dart';
import '../theme/qima_colors.dart';
import '../theme/strings.dart';
import '../widgets/help_button.dart';
import '../widgets/section_header.dart';
import '../services/system_settings.dart';
import 'hawl_date_picker.dart';
import 'zakat_screen.dart' show zakatClassLabel;

/// Zakat settings (v3, Figma "Zakat · Settings"): nisab basis, which asset
/// classes count, the hawl calendar and start date, and the reminder. Every
/// change saves immediately and syncs like the base currency.
class ZakatSettingsScreen extends StatefulWidget {
  const ZakatSettingsScreen({super.key});

  @override
  State<ZakatSettingsScreen> createState() => _ZakatSettingsScreenState();
}

class _ZakatSettingsScreenState extends State<ZakatSettingsScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // The reminder row says whether notifications are actually allowed.
    context.read<AppCubit>().refreshNotificationStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Coming back from system Settings after allowing notifications.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) context.read<AppCubit>().refreshNotificationStatus();
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
          title: Text(l10n.zakatSettingsTitle),
          actions: const [HelpButton(topic: HelpTopicId.zakat)],
        ),
        body: BlocBuilder<AppCubit, AppState>(
          builder: (context, state) {
            final settings = state.zakatSettings;
            // Every change applies to the cubit's current settings, never this
            // build's snapshot, so two quick taps can't undo each other.
            void update(ZakatSettings Function(ZakatSettings) change) => cubit.updateZakatSettings(change);

            final gold = ZakatAssessment.thresholdFor(NisabBasis.gold,
                rates: state.rates, baseCurrency: state.baseCurrency, latestUSD: cubit.latestUSD);
            final silver = ZakatAssessment.thresholdFor(NisabBasis.silver,
                rates: state.rates, baseCurrency: state.baseCurrency, latestUSD: cubit.latestUSD);

            String basisSubtitle(NisabBasis basis) {
              final mine = basis == NisabBasis.gold ? gold : silver;
              final theirs = basis == NisabBasis.gold ? silver : gold;
              if (mine == null) return l10n.zakatBasisPriceMissing;
              final amount = Masking.amount(mine, hidden: false);
              if (theirs == null) return l10n.zakatBasisToday(amount);
              return mine.amount >= theirs.amount ? l10n.zakatBasisHigher(amount) : l10n.zakatBasisLower(amount);
            }

            final start = settings.hawlStart;
            final hijriStart = start == null ? null : HijriDate.fromGregorian(start);
            String dateFormat(DateTime d) => dateWithYear(context, d);
            final String startValue;
            final String? startSubtitle;
            if (start == null) {
              startValue = l10n.zakatHawlSet;
              startSubtitle = l10n.zakatHawlNotSetSubtitle;
            } else if (settings.calendar == HawlCalendar.hijri && hijriStart != null) {
              startValue = hijriDateLabel(l10n, hijriStart);
              startSubtitle = dateFormat(start);
            } else {
              startValue = dateFormat(start);
              startSubtitle = hijriStart == null ? null : hijriDateLabel(l10n, hijriStart);
            }

            return ListView(
              padding: const EdgeInsets.all(DS.spaceMD),
              children: [
                SectionHeader(l10n.zakatNisabBasisSection),
                DSCard(
                  child: RadioGroup<NisabBasis>(
                    groupValue: settings.basis,
                    onChanged: (value) {
                      if (value != null) update((s) => s.copyWith(basis: value));
                    },
                    child: Column(
                      children: [
                        for (final basis in NisabBasis.values)
                          RadioListTile<NisabBasis>(
                            contentPadding: EdgeInsets.zero,
                            value: basis,
                            activeColor: colors.brand,
                            title: Text(
                              l10n.zakatBasisValue(
                                  displayLabel(context, basis == NisabBasis.gold ? 'asset.gold' : 'asset.silver'),
                                  basis.fineGrams.toStringAsFixed(0)),
                              style: TextStyle(color: colors.textPrimary),
                            ),
                            subtitle: Text(basisSubtitle(basis), style: TextStyle(color: colors.textTertiary, fontSize: 12)),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: DS.spaceLG),
                SectionHeader(l10n.zakatClassesSection),
                DSCard(
                  child: Column(
                    children: [
                      for (final zakatClass in ZakatClass.values)
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(zakatClassLabel(l10n, zakatClass), style: TextStyle(color: colors.textPrimary)),
                          subtitle: Text(_classSubtitle(l10n, zakatClass),
                              style: TextStyle(color: colors.textTertiary, fontSize: 12)),
                          value: settings.includedClasses.contains(zakatClass),
                          activeThumbColor: colors.onBrand,
                          activeTrackColor: colors.brand,
                          onChanged: (_) => update((s) => s.toggleClass(zakatClass)),
                        ),
                      if (settings.holdingOverrides.isNotEmpty) ...[
                        Divider(color: colors.hairline),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(l10n.zakatOverridesCount(settings.holdingOverrides.length),
                              style: TextStyle(color: colors.textPrimary)),
                          subtitle: Text(l10n.zakatOverridesSubtitle,
                              style: TextStyle(color: colors.textTertiary, fontSize: 12)),
                          trailing: TextButton(
                            onPressed: () => update((s) => s.copyWith(holdingOverrides: const {})),
                            child: Text(l10n.zakatOverridesReset),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: DS.spaceLG),
                SectionHeader(l10n.zakatHawlSection),
                DSCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(l10n.zakatCalendar, style: TextStyle(color: colors.textTertiary, fontSize: 12)),
                      const SizedBox(height: 4),
                      SegmentedButton<HawlCalendar>(
                        segments: [
                          ButtonSegment(value: HawlCalendar.hijri, label: Text(l10n.zakatCalendarHijri)),
                          ButtonSegment(value: HawlCalendar.gregorian, label: Text(l10n.zakatCalendarGregorian)),
                        ],
                        selected: {settings.calendar},
                        onSelectionChanged: (s) => update((current) => current.copyWith(calendar: s.first)),
                        style: DS.segmentedButtonStyle(colors, colors.brand),
                      ),
                      if (settings.calendar == HawlCalendar.gregorian) ...[
                        const SizedBox(height: DS.spaceXS),
                        Text(l10n.zakatGregorianNote(percentLabel(context, 2.577), percentLabel(context, ZakatAssessment.rate * 100)), style: TextStyle(color: colors.textTertiary, fontSize: 12)),
                      ],
                      const SizedBox(height: DS.spaceSM),
                      // The date sits under the label, not in `trailing`: a
                      // Hijri date is too long for a trailing slot.
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.zakatHawlStart, style: TextStyle(color: colors.textPrimary)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(startValue,
                                style: TextStyle(
                                    color: start == null ? colors.brandText : colors.textSecondary,
                                    fontWeight: FontWeight.w600)),
                            if (startSubtitle != null)
                              Text(startSubtitle, style: TextStyle(color: colors.textTertiary, fontSize: 12)),
                          ],
                        ),
                        trailing: Icon(Icons.chevron_right, color: colors.textTertiary),
                        onTap: () async {
                          final picked = await pickHawlStart(context, calendar: settings.calendar, initial: start);
                          if (picked != null) update((s) => s.copyWith(hawlStart: picked));
                        },
                      ),
                      if (start != null)
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: TextButton(
                            onPressed: () => update((s) => s.copyWith(clearHawlStart: true, remind: false)),
                            child: Text(l10n.zakatHawlClear),
                          ),
                        ),
                      Divider(color: colors.hairline),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.zakatRemind, style: TextStyle(color: colors.textPrimary)),
                        subtitle: Text(
                          start == null
                              ? l10n.zakatRemindNeedsStart
                              : state.notificationsEnabled
                                  ? l10n.zakatRemindSubtitle
                                  : l10n.zakatRemindNotificationsOff,
                          style: TextStyle(color: colors.textTertiary, fontSize: 12),
                        ),
                        value: settings.remind && start != null,
                        activeThumbColor: colors.onBrand,
                        activeTrackColor: colors.brand,
                        onChanged: start == null ? null : (value) => update((s) => s.copyWith(remind: value)),
                      ),
                      if (start != null && settings.remind && !state.notificationsEnabled)
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: TextButton(
                            onPressed: SystemSettings.openNotificationSettings,
                            child: Text(l10n.alertsScreenOpenSettings),
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

  String _classSubtitle(AppLocalizations l10n, ZakatClass zakatClass) {
    switch (zakatClass) {
      case ZakatClass.metals:
        return l10n.zakatClassMetalsSubtitle;
      case ZakatClass.crypto:
        return l10n.zakatClassCryptoSubtitle;
      case ZakatClass.equities:
        return l10n.zakatClassEquitiesSubtitle;
      case ZakatClass.cash:
        return l10n.zakatClassCashSubtitle;
    }
  }
}
