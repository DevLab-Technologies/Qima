import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/app_cubit.dart';
import '../blocs/app_state.dart';
import '../l10n/app_localizations.dart';
import '../models/chart_range.dart';
import '../services/preferences.dart';
import '../theme/design_system.dart';
import '../theme/qima_colors.dart';
import '../theme/strings.dart';
import 'currency_picker.dart';

/// Single settings sheet: base currency, default chart range, widget refresh
/// interval, language, and a static data-sources footer. Mirrors
/// `SettingsView.swift`.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AppCubit>();
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return ScreenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(backgroundColor: Colors.transparent, title: Text(l10n.settingsTitle)),
        body: BlocBuilder<AppCubit, AppState>(
          builder: (context, _) {
            final state = cubit.state;
            return ListView(
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
