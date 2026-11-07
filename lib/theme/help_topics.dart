import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/help_topic.dart';
import '../services/import/bank_messages.dart';

/// Every page that has a help topic, in the order the "How Qima works"
/// index sheet lists them (spec "Help on every page"): v5's money pages
/// first, then prices, holdings and settings. Not every page with
/// a [HelpButton] has an entry here 1:1 with the app's navigation order —
/// this is the *catalog* order, grouped the way a user would expect to
/// scan it (main tabs first, then the flows opened from them).
enum HelpTopicId {
  home,
  money,
  newTransaction,
  transactions,
  accounts,
  balanceSheet,
  assets,
  importStatement,
  bankMessages,
  categories,
  budget,
  recurring,
  people,
  features,
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
  zakat,
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
    case HelpTopicId.home:
      return HelpTopic(
        title: l10n.navHome,
        summary: l10n.helpHomeSummary,
        steps: [
          HelpStep(icon: Icons.account_balance_wallet_outlined, title: l10n.helpHomeStep1Title, body: l10n.helpHomeStep1Body),
          HelpStep(icon: Icons.dashboard_customize_outlined, title: l10n.helpHomeStep2Title, body: l10n.helpHomeStep2Body),
          HelpStep(icon: Icons.swap_vert, title: l10n.helpHomeStep3Title, body: l10n.helpHomeStep3Body),
          HelpStep(icon: Icons.visibility_off_outlined, title: l10n.helpHomeStep4Title, body: l10n.helpHomeStep4Body),
          HelpStep(icon: Icons.add_circle_outline, title: l10n.helpHomeStep5Title, body: l10n.helpHomeStep5Body),
          if (assistantSupportedOnThisPlatform)
            HelpStep(icon: Icons.record_voice_over_outlined, title: l10n.helpPortfolioStep7Title, body: l10n.helpPortfolioStep7Body),
        ],
      );
    case HelpTopicId.money:
      return HelpTopic(
        title: l10n.navMoney,
        summary: l10n.helpMoneySummary,
        steps: [
          HelpStep(icon: Icons.date_range_outlined, title: l10n.helpMoneyStep1Title, body: l10n.helpMoneyStep1Body),
          HelpStep(icon: Icons.speed, title: l10n.helpMoneyStep2Title, body: l10n.helpMoneyStep2Body),
          HelpStep(icon: Icons.donut_large_outlined, title: l10n.helpMoneyStep3Title, body: l10n.helpMoneyStep3Body),
          HelpStep(icon: Icons.swap_vert, title: l10n.helpMoneyStep4Title, body: l10n.helpMoneyStep4Body),
          HelpStep(icon: Icons.lightbulb_outline, title: l10n.helpMoneyStep5Title, body: l10n.helpMoneyStep5Body),
        ],
      );
    case HelpTopicId.newTransaction:
      return HelpTopic(
        title: l10n.entryNewTitle,
        summary: l10n.helpNewTransactionSummary,
        steps: [
          HelpStep(icon: Icons.tab, title: l10n.helpNewTransactionStep1Title, body: l10n.helpNewTransactionStep1Body),
          HelpStep(icon: Icons.mic_none, title: l10n.helpNewTransactionStep2Title, body: l10n.helpNewTransactionStep2Body),
          HelpStep(icon: Icons.category_outlined, title: l10n.helpNewTransactionStep3Title, body: l10n.helpNewTransactionStep3Body),
          HelpStep(icon: Icons.block, title: l10n.helpNewTransactionStep4Title, body: l10n.helpNewTransactionStep4Body),
        ],
      );
    case HelpTopicId.transactions:
      return HelpTopic(
        title: l10n.allTransactions,
        summary: l10n.helpTransactionsSummary,
        steps: [
          HelpStep(icon: Icons.touch_app_outlined, title: l10n.helpTransactionsStep1Title, body: l10n.helpTransactionsStep1Body),
          HelpStep(icon: Icons.info_outline, title: l10n.helpTransactionsStep2Title, body: l10n.helpTransactionsStep2Body),
          HelpStep(icon: Icons.edit_outlined, title: l10n.helpTransactionsStep3Title, body: l10n.helpTransactionsStep3Body),
        ],
      );
    case HelpTopicId.accounts:
      return HelpTopic(
        title: l10n.cardAccounts,
        summary: l10n.helpAccountsSummary,
        steps: [
          HelpStep(icon: Icons.add_circle_outline, title: l10n.helpAccountsStep1Title, body: l10n.helpAccountsStep1Body),
          HelpStep(icon: Icons.fact_check_outlined, title: l10n.helpAccountsStep2Title, body: l10n.helpAccountsStep2Body),
          HelpStep(icon: Icons.payments_outlined, title: l10n.helpAccountsStep3Title, body: l10n.helpAccountsStep3Body),
          HelpStep(icon: Icons.credit_card, title: l10n.helpAccountsStep4Title, body: l10n.helpAccountsStep4Body),
          HelpStep(icon: Icons.archive_outlined, title: l10n.helpAccountsStep5Title, body: l10n.helpAccountsStep5Body),
        ],
      );
    case HelpTopicId.balanceSheet:
      return HelpTopic(
        title: l10n.balanceSheet,
        summary: l10n.helpBalanceSheetSummary,
        steps: [
          HelpStep(icon: Icons.account_balance_outlined, title: l10n.helpBalanceSheetStep1Title, body: l10n.helpBalanceSheetStep1Body),
          HelpStep(icon: Icons.credit_card, title: l10n.helpBalanceSheetStep2Title, body: l10n.helpBalanceSheetStep2Body),
          HelpStep(icon: Icons.calculate_outlined, title: l10n.helpBalanceSheetStep3Title, body: l10n.helpBalanceSheetStep3Body),
          HelpStep(icon: Icons.toggle_off_outlined, title: l10n.helpBalanceSheetStep4Title, body: l10n.helpBalanceSheetStep4Body),
        ],
      );
    case HelpTopicId.assets:
      return HelpTopic(
        title: l10n.sheetAssets,
        summary: l10n.helpAssetsSummary,
        steps: [
          HelpStep(icon: Icons.add_circle_outline, title: l10n.helpAssetsStep1Title, body: l10n.helpAssetsStep1Body),
          HelpStep(icon: Icons.edit_calendar_outlined, title: l10n.helpAssetsStep2Title, body: l10n.helpAssetsStep2Body),
          HelpStep(icon: Icons.link, title: l10n.helpAssetsStep3Title, body: l10n.helpAssetsStep3Body),
          HelpStep(icon: Icons.sell_outlined, title: l10n.helpAssetsStep4Title, body: l10n.helpAssetsStep4Body),
        ],
      );
    case HelpTopicId.importStatement:
      return HelpTopic(
        title: l10n.importStatement,
        summary: l10n.helpImportStatementSummary,
        steps: [
          HelpStep(icon: Icons.upload_file_outlined, title: l10n.helpImportStatementStep1Title, body: l10n.helpImportStatementStep1Body),
          HelpStep(icon: Icons.fact_check_outlined, title: l10n.helpImportStatementStep2Title, body: l10n.helpImportStatementStep2Body),
          HelpStep(icon: Icons.balance_outlined, title: l10n.helpImportStatementStep3Title, body: l10n.helpImportStatementStep3Body),
          HelpStep(icon: Icons.check_circle_outline, title: l10n.helpImportStatementStep4Title, body: l10n.helpImportStatementStep4Body),
        ],
      );
    case HelpTopicId.bankMessages:
      return HelpTopic(
        title: l10n.bankMessagesTitle,
        summary: l10n.helpBankMessagesSummary,
        steps: [
          if (BankMessages.way != BankMessagesWay.shortcutsAutomation)
            HelpStep(icon: Icons.sms_outlined, title: l10n.helpBankMessagesStep1Title, body: l10n.helpBankMessagesStep1Body),
          if (BankMessages.way != BankMessagesWay.readSms)
            HelpStep(icon: Icons.bolt_outlined, title: l10n.helpBankMessagesStep2Title, body: l10n.helpBankMessagesStep2Body),
          HelpStep(icon: Icons.fact_check_outlined, title: l10n.helpBankMessagesStep3Title, body: l10n.helpBankMessagesStep3Body),
          HelpStep(icon: Icons.lock_outline, title: l10n.helpBankMessagesStep4Title, body: l10n.helpBankMessagesStep4Body),
        ],
      );
    case HelpTopicId.categories:
      return HelpTopic(
        title: l10n.categoriesTitle,
        summary: l10n.helpCategoriesSummary,
        steps: [
          HelpStep(icon: Icons.label_outline, title: l10n.helpCategoriesStep1Title, body: l10n.helpCategoriesStep1Body),
          HelpStep(icon: Icons.history, title: l10n.helpCategoriesStep2Title, body: l10n.helpCategoriesStep2Body),
          HelpStep(icon: Icons.edit_outlined, title: l10n.helpCategoriesStep3Title, body: l10n.helpCategoriesStep3Body),
          HelpStep(icon: Icons.auto_fix_off_outlined, title: l10n.helpCategoriesStep4Title, body: l10n.helpCategoriesStep4Body),
        ],
      );
    case HelpTopicId.budget:
      return HelpTopic(
        title: l10n.featBudget,
        summary: l10n.helpBudgetSummary,
        steps: [
          HelpStep(icon: Icons.add_circle_outline, title: l10n.helpBudgetStep1Title, body: l10n.helpBudgetStep1Body),
          HelpStep(icon: Icons.speed, title: l10n.helpBudgetStep2Title, body: l10n.helpBudgetStep2Body),
          HelpStep(icon: Icons.info_outline, title: l10n.helpBudgetStep3Title, body: l10n.helpBudgetStep3Body),
        ],
      );
    case HelpTopicId.recurring:
      return HelpTopic(
        title: l10n.featRecurring,
        summary: l10n.helpRecurringSummary,
        steps: [
          HelpStep(icon: Icons.add_circle_outline, title: l10n.helpRecurringStep1Title, body: l10n.helpRecurringStep1Body),
          HelpStep(icon: Icons.event_outlined, title: l10n.helpRecurringStep2Title, body: l10n.helpRecurringStep2Body),
          HelpStep(icon: Icons.edit_outlined, title: l10n.helpRecurringStep3Title, body: l10n.helpRecurringStep3Body),
        ],
      );
    case HelpTopicId.people:
      return HelpTopic(
        title: l10n.featPeople,
        summary: l10n.helpPeopleSummary,
        steps: [
          HelpStep(icon: Icons.call_made, title: l10n.helpPeopleStep1Title, body: l10n.helpPeopleStep1Body),
          HelpStep(icon: Icons.call_received, title: l10n.helpPeopleStep2Title, body: l10n.helpPeopleStep2Body),
          HelpStep(icon: Icons.call_split, title: l10n.helpPeopleStep3Title, body: l10n.helpPeopleStep3Body),
        ],
      );
    case HelpTopicId.features:
      return HelpTopic(
        title: l10n.featuresTitle,
        summary: l10n.helpFeaturesSummary,
        steps: [
          HelpStep(icon: Icons.toggle_on_outlined, title: l10n.helpFeaturesStep1Title, body: l10n.helpFeaturesStep1Body),
          HelpStep(icon: Icons.auto_awesome_outlined, title: l10n.helpFeaturesStep2Title, body: l10n.helpFeaturesStep2Body),
        ],
      );
    case HelpTopicId.watchlist:
      return HelpTopic(
        title: l10n.helpWatchlistTitle,
        summary: l10n.helpWatchlistSummary,
        steps: [
          HelpStep(icon: Icons.touch_app_outlined, title: l10n.helpWatchlistStep1Title, body: l10n.helpWatchlistStep1Body),
          HelpStep(icon: Icons.add_circle_outline, title: l10n.helpWatchlistStep2Title, body: l10n.helpWatchlistStep2Body),
          HelpStep(icon: Icons.filter_list, title: l10n.helpWatchlistStep3Title, body: l10n.helpWatchlistStep3Body),
          HelpStep(icon: Icons.refresh, title: l10n.helpWatchlistStep5Title, body: l10n.helpWatchlistStep5Body),
          HelpStep(icon: Icons.swap_vert, title: l10n.helpWatchlistStep6Title, body: l10n.helpWatchlistStep6Body),
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
          HelpStep(icon: Icons.add_alert_outlined, title: l10n.helpAssetDetailStep4Title, body: l10n.helpAssetDetailStep4Body),
          HelpStep(icon: Icons.account_balance_wallet_outlined, title: l10n.helpAssetDetailStep5Title, body: l10n.helpAssetDetailStep5Body),
          HelpStep(icon: Icons.ios_share, title: l10n.helpAssetDetailStep6Title, body: l10n.helpAssetDetailStep6Body),
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
          HelpStep(icon: Icons.notes, title: l10n.helpPortfolioStep6Title, body: l10n.helpPortfolioStep6Body),
          if (assistantSupportedOnThisPlatform)
            HelpStep(icon: Icons.record_voice_over_outlined, title: l10n.helpPortfolioStep7Title, body: l10n.helpPortfolioStep7Body),
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
        footnote: l10n.ledgerFootnote,
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
          HelpStep(icon: Icons.edit_note, title: l10n.helpAddAssetStep5Title, body: l10n.helpAddAssetStep5Body),
          HelpStep(icon: Icons.phonelink_lock_outlined, title: l10n.helpAddAssetStep6Title, body: l10n.helpAddAssetStep6Body),
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
          HelpStep(icon: Icons.memory_outlined, title: l10n.helpSettingsStep6Title, body: l10n.helpSettingsStep6Body),
        ],
      );
    case HelpTopicId.zakat:
      return HelpTopic(
        title: l10n.helpZakatTitle,
        summary: l10n.helpZakatSummary,
        steps: [
          HelpStep(icon: Icons.scale_outlined, title: l10n.helpZakatStep1Title, body: l10n.helpZakatStep1Body),
          HelpStep(icon: Icons.checklist_outlined, title: l10n.helpZakatStep2Title, body: l10n.helpZakatStep2Body),
          HelpStep(icon: Icons.event_outlined, title: l10n.helpZakatStep3Title, body: l10n.helpZakatStep3Body),
          HelpStep(icon: Icons.balance_outlined, title: l10n.helpZakatStep4Title, body: l10n.helpZakatStep4Body),
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
        footnote: l10n.csvImportSkipNote,
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

/// Whether Siri and Shortcuts can answer about Qima here: iOS and macOS,
/// matching the App Intents the Apple targets ship.
bool get assistantSupportedOnThisPlatform =>
    !kIsWeb && (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS);
