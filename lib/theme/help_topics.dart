import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/help_topic.dart';

/// Every page that has a help topic, in the order the "How Qima works"
/// index sheet lists them (spec "Help on every page"). Not every page with
/// a [HelpButton] has an entry here 1:1 with the app's navigation order —
/// this is the *catalog* order, grouped the way a user would expect to
/// scan it (main tabs first, then the flows opened from them).
enum HelpTopicId {
  watchlist,
  assetDetail,
  portfolio,
  holdings,
  lotEditor,
  addAsset,
  cardConfig,
  customTicker,
  currencyPicker,
  priceAlerts,
  alertEditor,
  settings,
  backup,
  importPreview,
  widgets,
}

/// Resolves every [HelpTopicId] to its localized [HelpTopic]. A function
/// (not a const map) because the content is localized and, for
/// [HelpTopicId.widgets]/[HelpTopicId.holdings]'s app-lock wording
/// elsewhere, platform-dependent.
HelpTopic helpTopicFor(BuildContext context, HelpTopicId id) {
  final l10n = AppLocalizations.of(context)!;
  switch (id) {
    case HelpTopicId.watchlist:
      return HelpTopic(
        title: l10n.helpWatchlistTitle,
        summary: l10n.helpWatchlistSummary,
        steps: [
          HelpStep(icon: Icons.touch_app_outlined, title: l10n.helpWatchlistStep1Title, body: l10n.helpWatchlistStep1Body),
          HelpStep(icon: Icons.add_circle_outline, title: l10n.helpWatchlistStep2Title, body: l10n.helpWatchlistStep2Body),
          HelpStep(icon: Icons.filter_list, title: l10n.helpWatchlistStep3Title, body: l10n.helpWatchlistStep3Body),
          HelpStep(icon: Icons.show_chart, title: l10n.helpWatchlistStep4Title, body: l10n.helpWatchlistStep4Body),
          HelpStep(icon: Icons.refresh, title: l10n.helpWatchlistStep5Title, body: l10n.helpWatchlistStep5Body),
        ],
      );
    case HelpTopicId.assetDetail:
      return HelpTopic(
        title: l10n.helpAssetDetailTitle,
        summary: l10n.helpAssetDetailSummary,
        steps: [
          HelpStep(icon: Icons.date_range_outlined, title: l10n.helpAssetDetailStep1Title, body: l10n.helpAssetDetailStep1Body),
          HelpStep(icon: Icons.tune, title: l10n.helpAssetDetailStep2Title, body: l10n.helpAssetDetailStep2Body),
          HelpStep(icon: Icons.view_column_outlined, title: l10n.helpAssetDetailStep3Title, body: l10n.helpAssetDetailStep3Body),
          HelpStep(icon: Icons.notifications_outlined, title: l10n.helpAssetDetailStep4Title, body: l10n.helpAssetDetailStep4Body),
          HelpStep(icon: Icons.account_balance_wallet_outlined, title: l10n.helpAssetDetailStep5Title, body: l10n.helpAssetDetailStep5Body),
        ],
      );
    case HelpTopicId.portfolio:
      return HelpTopic(
        title: l10n.helpPortfolioTitle,
        summary: l10n.helpPortfolioSummary,
        steps: [
          HelpStep(icon: Icons.donut_large_outlined, title: l10n.helpPortfolioStep1Title, body: l10n.helpPortfolioStep1Body),
          HelpStep(icon: Icons.touch_app_outlined, title: l10n.helpPortfolioStep2Title, body: l10n.helpPortfolioStep2Body),
          HelpStep(icon: Icons.add_circle_outline, title: l10n.helpPortfolioStep3Title, body: l10n.helpPortfolioStep3Body),
          HelpStep(icon: Icons.currency_exchange, title: l10n.helpPortfolioStep4Title, body: l10n.helpPortfolioStep4Body),
          HelpStep(icon: Icons.visibility_off_outlined, title: l10n.helpPortfolioStep5Title, body: l10n.helpPortfolioStep5Body),
        ],
      );
    case HelpTopicId.holdings:
      return HelpTopic(
        title: l10n.helpHoldingsTitle,
        summary: l10n.helpHoldingsSummary,
        steps: [
          HelpStep(icon: Icons.summarize_outlined, title: l10n.helpHoldingsStep1Title, body: l10n.helpHoldingsStep1Body),
          HelpStep(icon: Icons.add_circle_outline, title: l10n.helpHoldingsStep2Title, body: l10n.helpHoldingsStep2Body),
          HelpStep(icon: Icons.edit_outlined, title: l10n.helpHoldingsStep3Title, body: l10n.helpHoldingsStep3Body),
        ],
      );
    case HelpTopicId.lotEditor:
      return HelpTopic(
        title: l10n.helpLotEditorTitle,
        summary: l10n.helpLotEditorSummary,
        steps: [
          HelpStep(icon: Icons.scale_outlined, title: l10n.helpLotEditorStep1Title, body: l10n.helpLotEditorStep1Body),
          HelpStep(icon: Icons.diamond_outlined, title: l10n.helpLotEditorStep2Title, body: l10n.helpLotEditorStep2Body),
          HelpStep(icon: Icons.payments_outlined, title: l10n.helpLotEditorStep3Title, body: l10n.helpLotEditorStep3Body),
          HelpStep(icon: Icons.calendar_today_outlined, title: l10n.helpLotEditorStep4Title, body: l10n.helpLotEditorStep4Body),
          HelpStep(icon: Icons.check_circle_outline, title: l10n.helpLotEditorStep5Title, body: l10n.helpLotEditorStep5Body),
        ],
      );
    case HelpTopicId.addAsset:
      return HelpTopic(
        title: l10n.helpAddAssetTitle,
        summary: l10n.helpAddAssetSummary,
        steps: [
          HelpStep(icon: Icons.search, title: l10n.helpAddAssetStep1Title, body: l10n.helpAddAssetStep1Body),
          HelpStep(icon: Icons.touch_app_outlined, title: l10n.helpAddAssetStep2Title, body: l10n.helpAddAssetStep2Body),
          HelpStep(icon: Icons.add_circle_outline, title: l10n.helpAddAssetStep3Title, body: l10n.helpAddAssetStep3Body),
          HelpStep(icon: Icons.undo, title: l10n.helpAddAssetStep4Title, body: l10n.helpAddAssetStep4Body),
        ],
      );
    case HelpTopicId.cardConfig:
      return HelpTopic(
        title: l10n.helpCardConfigTitle,
        summary: l10n.helpCardConfigSummary,
        steps: [
          HelpStep(icon: Icons.currency_exchange, title: l10n.helpCardConfigStep1Title, body: l10n.helpCardConfigStep1Body),
          HelpStep(icon: Icons.scale_outlined, title: l10n.helpCardConfigStep2Title, body: l10n.helpCardConfigStep2Body),
          HelpStep(icon: Icons.diamond_outlined, title: l10n.helpCardConfigStep3Title, body: l10n.helpCardConfigStep3Body),
          HelpStep(icon: Icons.add_circle_outline, title: l10n.helpCardConfigStep4Title, body: l10n.helpCardConfigStep4Body),
        ],
      );
    case HelpTopicId.customTicker:
      return HelpTopic(
        title: l10n.helpCustomTickerTitle,
        summary: l10n.helpCustomTickerSummary,
        steps: [
          HelpStep(icon: Icons.edit_outlined, title: l10n.helpCustomTickerStep1Title, body: l10n.helpCustomTickerStep1Body),
          HelpStep(icon: Icons.fact_check_outlined, title: l10n.helpCustomTickerStep2Title, body: l10n.helpCustomTickerStep2Body),
          HelpStep(icon: Icons.add_circle_outline, title: l10n.helpCustomTickerStep3Title, body: l10n.helpCustomTickerStep3Body),
        ],
      );
    case HelpTopicId.currencyPicker:
      return HelpTopic(
        title: l10n.helpCurrencyPickerTitle,
        summary: l10n.helpCurrencyPickerSummary,
        steps: [
          HelpStep(icon: Icons.search, title: l10n.helpCurrencyPickerStep1Title, body: l10n.helpCurrencyPickerStep1Body),
          HelpStep(icon: Icons.touch_app_outlined, title: l10n.helpCurrencyPickerStep2Title, body: l10n.helpCurrencyPickerStep2Body),
        ],
      );
    case HelpTopicId.priceAlerts:
      return HelpTopic(
        title: l10n.helpPriceAlertsTitle,
        summary: l10n.helpPriceAlertsSummary,
        steps: [
          HelpStep(icon: Icons.add_alert_outlined, title: l10n.helpPriceAlertsStep1Title, body: l10n.helpPriceAlertsStep1Body),
          HelpStep(icon: Icons.pause_circle_outline, title: l10n.helpPriceAlertsStep2Title, body: l10n.helpPriceAlertsStep2Body),
          HelpStep(icon: Icons.edit_outlined, title: l10n.helpPriceAlertsStep3Title, body: l10n.helpPriceAlertsStep3Body),
          HelpStep(icon: Icons.schedule_outlined, title: l10n.helpPriceAlertsStep4Title, body: l10n.helpPriceAlertsStep4Body),
          HelpStep(icon: Icons.notifications_off_outlined, title: l10n.helpPriceAlertsStep5Title, body: l10n.helpPriceAlertsStep5Body),
        ],
      );
    case HelpTopicId.alertEditor:
      return HelpTopic(
        title: l10n.helpAlertEditorTitle,
        summary: l10n.helpAlertEditorSummary,
        steps: [
          HelpStep(icon: Icons.trending_up, title: l10n.helpAlertEditorStep1Title, body: l10n.helpAlertEditorStep1Body),
          HelpStep(icon: Icons.percent, title: l10n.helpAlertEditorStep2Title, body: l10n.helpAlertEditorStep2Body),
          HelpStep(icon: Icons.info_outline, title: l10n.helpAlertEditorStep3Title, body: l10n.helpAlertEditorStep3Body),
          HelpStep(icon: Icons.repeat, title: l10n.helpAlertEditorStep4Title, body: l10n.helpAlertEditorStep4Body),
        ],
      );
    case HelpTopicId.settings:
      return HelpTopic(
        title: l10n.helpSettingsTitle,
        summary: l10n.helpSettingsSummary,
        steps: [
          HelpStep(icon: Icons.palette_outlined, title: l10n.helpSettingsStep1Title, body: l10n.helpSettingsStep1Body),
          HelpStep(icon: Icons.lock_outline, title: l10n.helpSettingsStep2Title, body: l10n.helpSettingsStep2Body),
          HelpStep(icon: Icons.notifications_outlined, title: l10n.helpSettingsStep3Title, body: l10n.helpSettingsStep3Body),
          HelpStep(icon: Icons.backup_outlined, title: l10n.helpSettingsStep4Title, body: l10n.helpSettingsStep4Body),
          HelpStep(icon: Icons.tune, title: l10n.helpSettingsStep5Title, body: l10n.helpSettingsStep5Body),
        ],
      );
    case HelpTopicId.backup:
      return HelpTopic(
        title: l10n.helpBackupTitle,
        summary: l10n.helpBackupSummary,
        steps: [
          HelpStep(icon: Icons.description_outlined, title: l10n.helpBackupStep1Title, body: l10n.helpBackupStep1Body),
          HelpStep(icon: Icons.password_outlined, title: l10n.helpBackupStep2Title, body: l10n.helpBackupStep2Body),
          HelpStep(icon: Icons.ios_share, title: l10n.helpBackupStep3Title, body: l10n.helpBackupStep3Body),
          HelpStep(icon: Icons.restore, title: l10n.helpBackupStep4Title, body: l10n.helpBackupStep4Body),
          HelpStep(icon: Icons.table_chart_outlined, title: l10n.helpBackupStep5Title, body: l10n.helpBackupStep5Body),
        ],
      );
    case HelpTopicId.importPreview:
      return HelpTopic(
        title: l10n.helpImportPreviewTitle,
        summary: l10n.helpImportPreviewSummary,
        steps: [
          HelpStep(icon: Icons.fact_check_outlined, title: l10n.helpImportPreviewStep1Title, body: l10n.helpImportPreviewStep1Body),
          HelpStep(icon: Icons.merge_type, title: l10n.helpImportPreviewStep2Title, body: l10n.helpImportPreviewStep2Body),
          HelpStep(icon: Icons.check_circle_outline, title: l10n.helpImportPreviewStep3Title, body: l10n.helpImportPreviewStep3Body),
        ],
      );
    case HelpTopicId.widgets:
      return HelpTopic(
        title: l10n.helpWidgetsTitle,
        summary: l10n.helpWidgetsSummary,
        steps: [
          HelpStep(icon: Icons.touch_app_outlined, title: l10n.helpWidgetsStep1Title, body: l10n.helpWidgetsStep1Body),
          HelpStep(icon: Icons.search, title: l10n.helpWidgetsStep2Title, body: l10n.helpWidgetsStep2Body),
          HelpStep(icon: Icons.tune, title: l10n.helpWidgetsStep3Title, body: l10n.helpWidgetsStep3Body),
          HelpStep(icon: Icons.lock_outline, title: l10n.helpWidgetsStep4Title, body: l10n.helpWidgetsStep4Body),
        ],
        footnote: l10n.helpWidgetsNote,
      );
  }
}

/// Whether widgets (and therefore [HelpTopicId.widgets]) are offered on
/// this platform at all — iOS only, matching `home_widget_service.dart`/
/// the Settings Help group (spec "Settings gets a Help group ... on iOS
/// only 'Add a widget'").
bool get widgetsSupportedOnThisPlatform => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
