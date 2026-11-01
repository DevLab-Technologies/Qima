// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Qima';

  @override
  String get navWatchlist => 'Watchlist';

  @override
  String get watchlistAdd => 'Add asset';

  @override
  String get watchlistEmptyTitle => 'Your watchlist is empty';

  @override
  String get watchlistEmptyMessage =>
      'Add metals, crypto, stocks, or currencies to start tracking prices.';

  @override
  String get watchlistFilterAll => 'All';

  @override
  String get addTitle => 'Add asset';

  @override
  String get addSearchHint => 'Search, or describe a purchase';

  @override
  String addSearchCustomTickerTitle(String query) {
    return 'Add “$query” as a custom ticker';
  }

  @override
  String addSearchMatchedAlias(String alias) {
    return 'Also “$alias”';
  }

  @override
  String get addSearchCustomTickerSubtitle =>
      'For stocks, ETFs or indices not listed here';

  @override
  String addSearchNoResultsTitle(String query) {
    return 'No matches for “$query”';
  }

  @override
  String get addSearchNoResultsMessage =>
      'Nothing in the catalog matches that. You can still add it as a custom ticker.';

  @override
  String addSearchNoResultsButton(String query) {
    return 'Add $query as custom ticker';
  }

  @override
  String addedToWatchlist(String name) {
    return '$name added to watchlist';
  }

  @override
  String alreadyInWatchlist(String name) {
    return '$name is already in your watchlist';
  }

  @override
  String get addCustomTickerTitle => 'Add custom ticker';

  @override
  String get addCustomTickerSymbol => 'Ticker symbol';

  @override
  String get addCustomTickerName => 'Display name (optional)';

  @override
  String get addCustomTickerHint => 'e.g. AAPL, TSLA, VOO';

  @override
  String get addCustomTickerSymbolRequired => 'Enter a ticker symbol.';

  @override
  String get addCustomTickerError =>
      'Could not verify this ticker. Check the symbol and try again.';

  @override
  String get addCustomTickerSubmit => 'Add ticker';

  @override
  String get cardConfigAddToWatchlist => 'Add to watchlist';

  @override
  String get commonCurrency => 'Currency';

  @override
  String get currencyPickerSearchHint => 'Search currency';

  @override
  String get detailHoldings => 'Holdings';

  @override
  String get detailHistory => 'History';

  @override
  String get detailLoadHistory => 'Load history';

  @override
  String get detailNoHistoryTitle => 'No history yet';

  @override
  String get detailNoHistoryMessage =>
      'Load history to see the full price chart.';

  @override
  String get detailKeyStats => 'Key stats';

  @override
  String get detailPricePerUnit => 'Price per unit';

  @override
  String detailUpdatedAt(String time) {
    return 'Updated $time';
  }

  @override
  String get errorRefreshFailed =>
      'Couldn\'t refresh prices. Check your connection and try again.';

  @override
  String get detailChangeCurrency => 'Change currency';

  @override
  String detailShowPerUnit(String unit) {
    return 'Show per $unit';
  }

  @override
  String get holdingsEmpty =>
      'No transactions yet. Add a buy to start tracking this holding.';

  @override
  String get holdingsValue => 'Value';

  @override
  String get holdingsCost => 'Cost';

  @override
  String get holdingsGain => 'Gain';

  @override
  String get holdingsGainPercent => 'Gain %';

  @override
  String get holdingsQuantity => 'Quantity';

  @override
  String get holdingsCostModePerUnit => 'Per unit';

  @override
  String get holdingsCostModeTotal => 'Total';

  @override
  String get holdingsTotalCost => 'Total cost';

  @override
  String get holdingsDate => 'Date';

  @override
  String get holdingsSave => 'Save';

  @override
  String get holdingsTotalHeld => 'Total held';

  @override
  String get holdingsAverageCost => 'Average cost';

  @override
  String holdingsMixedNote(String karat) {
    return 'Mixed karats counted by gold content, shown as $karat.';
  }

  @override
  String get holdingsMixedUnitsNote => 'Mixed units counted by gold content.';

  @override
  String holdingsHeldLine(String quantity, String average) {
    return 'Held $quantity · avg $average';
  }

  @override
  String get portfolioTitle => 'Portfolio';

  @override
  String get portfolioValue => 'Total value';

  @override
  String get portfolioEmpty =>
      'No portfolio value yet — add a buy to any asset to get started.';

  @override
  String get portfolioNoChange => 'Not enough history for this range yet';

  @override
  String get portfolioNoHistory => 'Add a buy to see your portfolio chart';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsAppearanceSystem => 'System';

  @override
  String get settingsAppearanceLight => 'Light';

  @override
  String get settingsAppearanceDark => 'Dark';

  @override
  String get settingsBaseCurrency => 'Base currency';

  @override
  String get settingsPortfolioCurrency => 'Portfolio currency';

  @override
  String get settingsUnit => 'Unit';

  @override
  String get settingsKarat => 'Karat';

  @override
  String get settingsBaseCurrencyFooter =>
      'Used to total your portfolio value.';

  @override
  String get settingsDefaultRange => 'Default chart range';

  @override
  String get settingsDefaultRangeFooter =>
      'Used when opening an asset for the first time.';

  @override
  String get settingsWidgetRefresh => 'Widget refresh interval';

  @override
  String get settingsWidgetRefreshFooter =>
      'How often background widgets fetch new prices.';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSystem => 'Follow system';

  @override
  String get settingsDataSource =>
      'finance.yahoo.com · gold-api.com · er-api.com';

  @override
  String get settingsPrivacy => 'Privacy & security';

  @override
  String get settingsHideBalances => 'Hide balances';

  @override
  String get settingsHideBalancesFooter =>
      'Mask portfolio, holdings and transaction amounts throughout the app.';

  @override
  String get settingsAppLock => 'App lock';

  @override
  String get settingsAppLockFooter =>
      'Require Face ID, Touch ID or your device passcode to open Qima.';

  @override
  String get settingsAppLockUnavailable =>
      'Set up Face ID, Touch ID or a device passcode first.';

  @override
  String get settingsAppLockFailed =>
      'Couldn\'t verify it\'s you — app lock stays off.';

  @override
  String get settingsLockAfter => 'Lock after';

  @override
  String get lockGraceImmediately => 'Immediately';

  @override
  String get lockGrace1m => '1 minute';

  @override
  String get lockGrace5m => '5 minutes';

  @override
  String get lockGrace15m => '15 minutes';

  @override
  String get privacyHideBalances => 'Hide balances';

  @override
  String get privacyShowBalances => 'Show balances';

  @override
  String get appLockAuthReason => 'Unlock Qima to see your portfolio';

  @override
  String get appLockLockedTitle => 'Qima is locked';

  @override
  String get appLockLockedMessage =>
      'Unlock to see your portfolio and holdings.';

  @override
  String get appLockUnlockFaceID => 'Unlock with Face ID';

  @override
  String get appLockUnlockTouchID => 'Unlock with Touch ID';

  @override
  String get appLockUnlockGeneric => 'Unlock';

  @override
  String get appLockUseDevicePasscode => 'Use device passcode';

  @override
  String get statChange => 'Change';

  @override
  String get statHigh => 'High';

  @override
  String get statLow => 'Low';

  @override
  String get statPoints => 'Points';

  @override
  String get pricePullToRefresh => 'Pull to refresh';

  @override
  String get assetClassMetal => 'Metals';

  @override
  String get assetClassCrypto => 'Crypto';

  @override
  String get assetClassStock => 'Stocks';

  @override
  String get assetClassIndex => 'Indices';

  @override
  String get assetClassFiat => 'Currencies';

  @override
  String get assetGold => 'Gold';

  @override
  String get assetSilver => 'Silver';

  @override
  String get assetPlatinum => 'Platinum';

  @override
  String get assetPalladium => 'Palladium';

  @override
  String get assetBitcoin => 'Bitcoin';

  @override
  String get assetEthereum => 'Ethereum';

  @override
  String get assetApple => 'Apple';

  @override
  String get assetMicrosoft => 'Microsoft';

  @override
  String get assetNvidia => 'Nvidia';

  @override
  String get assetAmazon => 'Amazon';

  @override
  String get assetTesla => 'Tesla';

  @override
  String get assetAlphabet => 'Alphabet';

  @override
  String get assetSp500 => 'S&P 500';

  @override
  String get assetDowJones => 'Dow Jones';

  @override
  String get assetNasdaq => 'Nasdaq';

  @override
  String get assetRussell2000 => 'Russell 2000';

  @override
  String get assetFtse100 => 'FTSE 100';

  @override
  String get assetNikkei225 => 'Nikkei 225';

  @override
  String get assetDax => 'DAX';

  @override
  String get assetUsDollar => 'US Dollar';

  @override
  String get assetEuro => 'Euro';

  @override
  String get assetBritishPound => 'British Pound';

  @override
  String get assetEgyptianPound => 'Egyptian Pound';

  @override
  String get assetSaudiRiyal => 'Saudi Riyal';

  @override
  String get assetEmiratiDirham => 'Emirati Dirham';

  @override
  String get assetQatariRiyal => 'Qatari Riyal';

  @override
  String get assetKuwaitiDinar => 'Kuwaiti Dinar';

  @override
  String get assetOmaniRial => 'Omani Rial';

  @override
  String get assetBahrainiDinar => 'Bahraini Dinar';

  @override
  String get assetJordanianDinar => 'Jordanian Dinar';

  @override
  String get unitTroyOunce => 'Troy ounce';

  @override
  String get unitGram => 'Gram';

  @override
  String get unitKilogram => 'Kilogram';

  @override
  String get unitEach => 'Each';

  @override
  String get unitAbbrTroyOunce => 'oz t';

  @override
  String get unitAbbrGram => 'g';

  @override
  String get unitAbbrKilogram => 'kg';

  @override
  String get karatShort24 => '24K';

  @override
  String get karatShort22 => '22K';

  @override
  String get karatShort21 => '21K';

  @override
  String get karatShort18 => '18K';

  @override
  String get range1D => '1D';

  @override
  String get range3D => '3D';

  @override
  String get range7D => '7D';

  @override
  String get range1W => '1W';

  @override
  String get range1M => '1M';

  @override
  String get range3M => '3M';

  @override
  String get range6M => '6M';

  @override
  String get rangeYtd => 'YTD';

  @override
  String get range1Y => '1Y';

  @override
  String get range5Y => '5Y';

  @override
  String get rangeAll => 'All';

  @override
  String get refresh15m => '15 minutes';

  @override
  String get refresh30m => '30 minutes';

  @override
  String get refresh1h => '1 hour';

  @override
  String get refresh3h => '3 hours';

  @override
  String get refresh6h => '6 hours';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonRemove => 'Remove';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonUndo => 'Undo';

  @override
  String confirmRemoveCardTitle(String name) {
    return 'Remove $name from your watchlist?';
  }

  @override
  String get confirmRemoveCardMessage =>
      'Your holdings for this asset are kept.';

  @override
  String confirmRemoveTickerTitle(String symbol) {
    return 'Remove custom ticker $symbol?';
  }

  @override
  String get confirmRemoveTickerMessage =>
      'Any watchlist cards for it are removed too.';

  @override
  String get alertKindAbove => 'Goes above';

  @override
  String get alertKindBelow => 'Goes below';

  @override
  String get alertKindPercentMove => '% move';

  @override
  String get alertDirectionUp => 'Up';

  @override
  String get alertDirectionDown => 'Down';

  @override
  String get alertDirectionEither => 'Either';

  @override
  String get alertWindowWithin24h => 'Within 24 hours';

  @override
  String get alertWindowWithin7d => 'Within 7 days';

  @override
  String get alertWindow24h => '24 hours';

  @override
  String get alertWindow7d => '7 days';

  @override
  String get alertBellTooltip => 'Price alerts';

  @override
  String get alertsCardTitle => 'Alerts';

  @override
  String get alertsCardEmpty => 'No alerts yet for this asset.';

  @override
  String get alertsCardAdd => 'Add alert';

  @override
  String get alertEditorNewTitle => 'New alert';

  @override
  String get alertEditorEditTitle => 'Edit alert';

  @override
  String get alertEditorTypePrice => 'Price';

  @override
  String get alertEditorTypePercent => '% move';

  @override
  String get alertEditorGoesAbove => 'Goes above';

  @override
  String get alertEditorGoesBelow => 'Goes below';

  @override
  String get alertEditorTargetLabel => 'Target price';

  @override
  String get alertEditorTargetRequired => 'Enter a target price above zero.';

  @override
  String alertEditorHelperAbove(String delta, String percent) {
    return '+$delta · $percent% above the current price';
  }

  @override
  String alertEditorHelperBelow(String delta, String percent) {
    return '−$delta · $percent% below the current price';
  }

  @override
  String get alertEditorDirection => 'Direction';

  @override
  String get alertEditorWindow => 'Window';

  @override
  String alertEditorPercentSummary(String low, String high) {
    return 'Fires below $low or above $high';
  }

  @override
  String alertEditorPercentSummaryUp(String high) {
    return 'Fires above $high';
  }

  @override
  String alertEditorPercentSummaryDown(String low) {
    return 'Fires below $low';
  }

  @override
  String get alertEditorRepeat => 'Repeat';

  @override
  String get alertEditorRepeatFooter =>
      'Keep watching after it fires, instead of turning off.';

  @override
  String get alertEditorCreate => 'Create alert';

  @override
  String get alertEditorSave => 'Save';

  @override
  String get alertEditorDelete => 'Delete';

  @override
  String get alertsScreenTitle => 'Alerts';

  @override
  String get alertsScreenEmptyTitle => 'No alerts yet';

  @override
  String get alertsScreenEmptyMessage =>
      'Open an asset and tap the bell to set a price alert.';

  @override
  String alertsScreenFiredToday(String time) {
    return 'Fired today $time · switched off';
  }

  @override
  String get alertsScreenNotificationsOff => 'Notifications are off';

  @override
  String get alertsScreenNotificationsOffMessage =>
      'Turn on notifications for Qima to be alerted when a price target is hit.';

  @override
  String get alertsScreenOpenSettings => 'Open settings';

  @override
  String get confirmDeleteAlertTitle => 'Delete this alert?';

  @override
  String get confirmDeleteAlertMessage =>
      'You won\'t be notified for it again.';

  @override
  String get settingsAlerts => 'Alerts';

  @override
  String get settingsAlertsPriceAlerts => 'Price alerts';

  @override
  String settingsAlertsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count alerts',
      one: '1 alert',
      zero: 'No alerts',
    );
    return '$_temp0';
  }

  @override
  String get settingsAlertsNotifications => 'Notifications';

  @override
  String get settingsAlertsNotificationsOn => 'On';

  @override
  String get settingsAlertsNotificationsOff => 'Off';

  @override
  String get settingsAlertsDeliverOnDevice => 'Deliver alerts on this device';

  @override
  String get settingsAlertsDeliverOnDeviceFooter =>
      'Turn off if you don\'t want this device to notify you when an alert fires.';

  @override
  String alertNotificationTitleAbove(String name, String target) {
    return '$name is above $target';
  }

  @override
  String alertNotificationTitleBelow(String name, String target) {
    return '$name is below $target';
  }

  @override
  String alertNotificationTitlePercent(
    String name,
    String percent,
    String window,
  ) {
    return '$name moved $percent% in $window';
  }

  @override
  String alertNotificationBodyOneOff(String price, String unit) {
    return 'Now $price per $unit. This alert is now off.';
  }

  @override
  String alertNotificationBodyRepeat(String price, String unit) {
    return 'Now $price per $unit. You\'ll be told again the next time this happens.';
  }

  @override
  String get settingsBackup => 'Backup & restore';

  @override
  String get settingsBackupSubtitleNever => 'Never backed up';

  @override
  String settingsBackupSubtitle(
    String date,
    int instruments,
    int transactions,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      transactions,
      locale: localeName,
      other: '$transactions transactions',
      one: '1 transaction',
    );
    return 'Last backup $date · $instruments assets, $_temp0';
  }

  @override
  String get settingsICloudSync => 'iCloud sync';

  @override
  String get settingsICloudSyncSwitch => 'Sync with iCloud';

  @override
  String get settingsICloudSyncFooter =>
      'Keeps your watchlist, holdings, custom tickers and price alerts up to date across your devices.';

  @override
  String settingsICloudSyncStatusUpToDate(String time) {
    return 'Up to date · $time';
  }

  @override
  String get settingsICloudSyncStatusSyncing => 'Syncing…';

  @override
  String get settingsICloudSyncStatusNotSignedIn => 'Not signed in to iCloud';

  @override
  String get settingsICloudSyncStatusStorageFull =>
      'iCloud storage for Qima is full';

  @override
  String get backupTitle => 'Backup & restore';

  @override
  String get backupStatusTitle => 'Stored only on this phone';

  @override
  String get backupStatusMessage =>
      'Your data lives on this device only. Back it up so you can restore it here or on another device.';

  @override
  String backupLastBackup(String date) {
    return 'Last backup $date';
  }

  @override
  String get backupLastBackupNever => 'Never backed up';

  @override
  String get backupReminderCardTitle => 'Time for a backup';

  @override
  String get backupReminderCardMessage =>
      'It\'s been over 30 days since your last backup and your data has changed.';

  @override
  String get backupReminderCardAction => 'Back up now';

  @override
  String get backupReminderNotificationTitle => 'Time for a backup';

  @override
  String get backupReminderNotificationBody =>
      'It\'s been a while since your last Qima backup and your data has changed. Tap to back up now.';

  @override
  String get backupExportSection => 'Export';

  @override
  String get backupExportFullTitle => 'Full backup';

  @override
  String get backupExportFullSubtitle =>
      'Watchlist, holdings, custom tickers, alerts and settings (.json)';

  @override
  String get backupExportCsvTitle => 'Holdings spreadsheet';

  @override
  String get backupExportCsvSubtitle =>
      'Every transaction as a spreadsheet (.csv) — it imports back too';

  @override
  String get backupRestoreSection => 'Restore';

  @override
  String get backupRestoreTitle => 'Import a backup';

  @override
  String get backupRestoreSubtitle => 'Restore from a full backup file (.json)';

  @override
  String get backupReminderSection => 'Reminder';

  @override
  String get backupReminderToggleTitle => 'Remind me to back up';

  @override
  String get backupReminderToggleSubtitle =>
      'Get a monthly reminder if you haven\'t backed up recently and your data has changed.';

  @override
  String get backupExportSheetTitle => 'Export backup';

  @override
  String get backupExportSheetFileName => 'File name';

  @override
  String get backupExportSheetFileSize => 'Size';

  @override
  String get backupExportSheetFileContents => 'Contents';

  @override
  String backupExportSheetContentsSummary(
    int cards,
    int transactions,
    int customTickers,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      transactions,
      locale: localeName,
      other: '$transactions transactions',
      one: '1 transaction',
    );
    return '$cards watchlist cards · $_temp0 · $customTickers custom tickers';
  }

  @override
  String get backupExportSheetProtectTitle => 'Protect with a password';

  @override
  String get backupExportSheetProtectSubtitle =>
      'Encrypts the file with AES-256. If you forget this password, the backup can\'t be recovered.';

  @override
  String get backupExportSheetPasswordLabel => 'Password';

  @override
  String get backupExportSheetPasswordConfirmLabel => 'Confirm password';

  @override
  String get backupExportSheetPasswordTooShort => 'Use at least 8 characters.';

  @override
  String get backupExportSheetPasswordMismatch => 'Passwords don\'t match.';

  @override
  String get backupExportSheetUnprotectedWarning =>
      'Anyone with this file can read your data. Protect it with a password if you plan to store or send it somewhere less private.';

  @override
  String get backupExportSheetAction => 'Save or share…';

  @override
  String get backupExportSheetWorking => 'Preparing your backup…';

  @override
  String get backupExportSheetFailed =>
      'Couldn\'t create the backup. Try again.';

  @override
  String get backupImportPreviewTitle => 'Restore backup';

  @override
  String backupImportFileCreated(String date) {
    return 'Created $date';
  }

  @override
  String backupImportFileAppVersion(String version) {
    return 'Made with Qima $version';
  }

  @override
  String get backupImportCountCards => 'Watchlist cards';

  @override
  String get backupImportCountCustomTickers => 'Custom tickers';

  @override
  String get backupImportCountSettings => 'Settings included';

  @override
  String get backupImportPasswordPrompt =>
      'This backup is protected. Enter the password to continue.';

  @override
  String get backupImportPasswordLabel => 'Password';

  @override
  String get backupImportPasswordIncorrect =>
      'That password didn\'t work. Try again.';

  @override
  String get backupImportUnlock => 'Unlock';

  @override
  String get backupImportModeMerge => 'Merge';

  @override
  String get backupImportModeReplace => 'Replace';

  @override
  String get backupImportModeMergeFooter =>
      'Keeps what\'s on this phone and adds anything new or newer from the backup.';

  @override
  String get backupImportModeReplaceFooter =>
      'Replaces everything on this phone with the backup\'s contents.';

  @override
  String backupImportDiff(int added, int updated, int removed) {
    String _temp0 = intl.Intl.pluralLogic(
      added,
      locale: localeName,
      other: '+$added added',
      one: '+1 added',
      zero: '',
    );
    return '$_temp0 · $updated updated · $removed removed';
  }

  @override
  String get backupImportRestoreButton => 'Restore';

  @override
  String get backupImportReplaceConfirmTitle =>
      'Replace everything on this phone?';

  @override
  String get backupImportReplaceConfirmMessage =>
      'Your current watchlist, holdings, custom tickers and alerts will be replaced with the backup\'s contents. This can\'t be undone.';

  @override
  String get backupImportReplaceConfirmAction => 'Replace';

  @override
  String get backupImportSuccessSnackbar => 'Backup restored';

  @override
  String get backupImportFailedTitle => 'Couldn\'t restore this backup';

  @override
  String get backupImportCsvErrorTitle => 'This is a spreadsheet, not a backup';

  @override
  String get backupImportCsvErrorMessage =>
      'This is a spreadsheet, not a Qima backup. You can import its rows as transactions instead.';

  @override
  String get backupErrorNotQimaFile =>
      'This doesn\'t look like a Qima backup file.';

  @override
  String get backupErrorNewerVersion =>
      'This backup was made with a newer version of Qima. Update the app to restore it.';

  @override
  String get backupErrorWrongPassword => 'That password didn\'t work.';

  @override
  String get backupErrorCorrupted =>
      'This backup file is damaged and can\'t be restored.';

  @override
  String get backupCsvHeaderInstrument => 'Asset';

  @override
  String get backupCsvHeaderSymbol => 'Symbol';

  @override
  String get backupCsvHeaderQuantity => 'Quantity';

  @override
  String get backupCsvHeaderUnit => 'Unit';

  @override
  String get backupCsvHeaderKarat => 'Karat';

  @override
  String get backupCsvHeaderUnitCost => 'Price per unit';

  @override
  String get backupCsvHeaderCostCurrency => 'Currency';

  @override
  String get backupCsvHeaderTotalCost => 'Total';

  @override
  String get backupCsvHeaderDate => 'Date';

  @override
  String get commonContinue => 'Continue';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingGetStarted => 'Get started';

  @override
  String get onboardingStep1Title => 'Everything you own, in one number';

  @override
  String get onboardingStep1Body =>
      'Gold, silver, crypto, stocks, indices and currencies, added up in your currency.';

  @override
  String get onboardingStep2Title => 'Prices the way you buy';

  @override
  String get onboardingStep2Body =>
      'Live prices by gram, ounce or kilogram, 24K to 18K, in any currency. Tap + to add, tap a card for its chart.';

  @override
  String get onboardingStep3Title => 'Know what you hold';

  @override
  String get onboardingStep3Body =>
      'Record each purchase: quantity, unit, karat, cost and date. See what you hold, your average cost, value and gain.';

  @override
  String get onboardingStep4Title => 'Never miss a move';

  @override
  String get onboardingStep4Body =>
      'Get notified when a price crosses a level or moves by a percent. Put prices on your Home and Lock Screen.';

  @override
  String get onboardingStep5Title => 'Private by design';

  @override
  String get onboardingStep5Body =>
      'No account. Your data stays on this device, with optional iCloud sync, Face ID lock and file backups.';

  @override
  String get onboardingStep5BodyAndroid =>
      'No account. Your data stays on this device, with fingerprint or face unlock and file backups.';

  @override
  String get onboardingStep5BodyMac =>
      'No account. Your data stays on this Mac, with optional iCloud sync, Touch ID lock and file backups.';

  @override
  String get onboardingStep5PillNoAccount => 'No account';

  @override
  String get onboardingStep5PillOnDevice => 'On this device';

  @override
  String get onboardingStep5ICloudTitle => 'iCloud sync';

  @override
  String get onboardingStep5ICloudSubtitle =>
      'Optional · keeps devices in step';

  @override
  String get onboardingStep5AppLockTitle => 'App lock';

  @override
  String get onboardingStep5AppLockSubtitleApple => 'Face ID or fingerprint';

  @override
  String get onboardingStep5AppLockSubtitleGeneric =>
      'Fingerprint or face unlock';

  @override
  String get onboardingStep5AppLockSubtitleMac =>
      'Touch ID or your Mac password';

  @override
  String get onboardingStep5HideBalancesTitle => 'Hide balances';

  @override
  String get onboardingStep5HideBalancesSubtitle =>
      'Show •••• instead of amounts';

  @override
  String get onboardingBaseCurrencyTitle => 'Base currency';

  @override
  String get onboardingBaseCurrencySubtitle =>
      'From your region · change in Settings';

  @override
  String onboardingSemanticStepOf(int step, int total) {
    return 'Step $step of $total';
  }

  @override
  String get onboardingReplayTour => 'Replay the tour';

  @override
  String get helpButtonTooltip => 'Help';

  @override
  String get helpSheetAboutHeader => 'ABOUT THIS PAGE';

  @override
  String get helpSheetHowToHeader => 'HOW TO USE IT';

  @override
  String get helpSheetIndexHeader => 'HELP';

  @override
  String get helpSheetWidgetsHeader => 'HELP · SETTINGS';

  @override
  String get helpSheetCloseTooltip => 'Close';

  @override
  String get helpIndexIntro =>
      'Pick a page to see what it does and how to use it.';

  @override
  String get helpWatchlistTitle => 'Watchlist';

  @override
  String get helpWatchlistSummary =>
      'Live prices for everything you follow, with your portfolio total on top.';

  @override
  String get helpWatchlistStep1Title => 'Open a card';

  @override
  String get helpWatchlistStep1Body =>
      'Tap any card for its chart, key stats and your holdings.';

  @override
  String get helpWatchlistStep2Title => 'Add an asset';

  @override
  String get helpWatchlistStep2Body => 'Tap + and search by name or symbol.';

  @override
  String get helpWatchlistStep3Title => 'Filter the list';

  @override
  String get helpWatchlistStep3Body =>
      'Show only Metals, Crypto, Stocks, Indices or Currencies.';

  @override
  String get helpWatchlistStep4Title => 'Change the chart range';

  @override
  String get helpWatchlistStep4Body =>
      'Pick 1W to All under the portfolio chart.';

  @override
  String get helpWatchlistStep5Title => 'Refresh prices';

  @override
  String get helpWatchlistStep5Body =>
      'Tap refresh to fetch the latest prices now.';

  @override
  String get helpAssetDetailTitle => 'Asset detail';

  @override
  String get helpAssetDetailSummary =>
      'One asset\'s price, chart and stats, plus what you hold of it.';

  @override
  String get helpAssetDetailStep1Title => 'Pick a range';

  @override
  String get helpAssetDetailStep1Body =>
      'Switch between 1D and All under the chart.';

  @override
  String get helpAssetDetailStep2Title => 'Change unit, karat or currency';

  @override
  String get helpAssetDetailStep2Body =>
      'Tap the sliders at the top of the page.';

  @override
  String get helpAssetDetailStep3Title => 'Compare units';

  @override
  String get helpAssetDetailStep3Body =>
      'Price per unit shows ounce, kilogram and each karat side by side.';

  @override
  String get helpAssetDetailStep4Title => 'Set an alert';

  @override
  String get helpAssetDetailStep4Body =>
      'Tap + on the Alerts card to hear when the price crosses a level or moves by a percent.';

  @override
  String get helpAssetDetailStep5Title => 'Track what you own';

  @override
  String get helpAssetDetailStep5Body =>
      'Tap Holdings to see your transactions or add a buy or sale.';

  @override
  String get helpPortfolioTitle => 'Portfolio';

  @override
  String get helpPortfolioSummary =>
      'Everything you hold, added up in your base currency, with each asset\'s share and gain.';

  @override
  String get helpPortfolioStep1Title => 'Read the donut';

  @override
  String get helpPortfolioStep1Body =>
      'Each slice is one asset\'s share of your total value.';

  @override
  String get helpPortfolioStep2Title => 'Open an asset';

  @override
  String get helpPortfolioStep2Body =>
      'Tap a row to see its transactions, average cost and gain.';

  @override
  String get helpPortfolioStep3Title => 'Add a purchase';

  @override
  String get helpPortfolioStep3Body => 'Open an asset, then tap +.';

  @override
  String get helpPortfolioStep4Title => 'Change the currency';

  @override
  String get helpPortfolioStep4Body =>
      'Totals use your base currency, set in Settings.';

  @override
  String get helpPortfolioStep5Title => 'Hide amounts';

  @override
  String get helpPortfolioStep5Body =>
      'Turn on Hide balances in Settings to mask every value.';

  @override
  String get helpLotEditorTitle => 'Transaction';

  @override
  String get helpLotEditorSummary =>
      'Record one buy, sell, transfer or fee. Your holding, average cost and gains are worked out from these.';

  @override
  String get helpLotEditorStep1Title => 'Type';

  @override
  String get helpLotEditorStep1Body =>
      'Buy adds at a cost. Sell removes and realises a gain or loss. Transfer moves quantity in or out. Fee records a charge.';

  @override
  String get helpLotEditorStep2Title => 'Karat';

  @override
  String get helpLotEditorStep2Body =>
      'For gold by gram or kilogram, pick 24K, 22K, 21K or 18K. Everything is counted by gold content, so karats mix correctly.';

  @override
  String get helpLotEditorStep3Title => 'Price and fee';

  @override
  String get helpLotEditorStep3Body =>
      'Enter the price per unit or the total, and any commission. A sell shows what it realises before you save.';

  @override
  String get helpLotEditorStep4Title => 'Date';

  @override
  String get helpLotEditorStep4Body =>
      'The day it happened. A sale can’t be dated before you held enough.';

  @override
  String get helpLotEditorStep5Title => 'Save';

  @override
  String get helpLotEditorStep5Body =>
      'Edit or delete a transaction any time from the holding’s ledger.';

  @override
  String get helpAddAssetTitle => 'Add asset';

  @override
  String get helpAddAssetSummary =>
      'Find something to follow and add it to your watchlist.';

  @override
  String get helpAddAssetStep1Title => 'Search';

  @override
  String get helpAddAssetStep1Body =>
      'Type a name or symbol, like gold, BTC or AAPL.';

  @override
  String get helpAddAssetStep2Title => 'Pick a result';

  @override
  String get helpAddAssetStep2Body =>
      'It\'s added to your watchlist and its page opens.';

  @override
  String get helpAddAssetStep3Title => 'Not in the list?';

  @override
  String get helpAddAssetStep3Body =>
      'Add the symbol as a custom ticker. Qima checks it with the price provider first.';

  @override
  String get helpAddAssetStep4Title => 'Changed your mind?';

  @override
  String get helpAddAssetStep4Body =>
      'Tap Undo on the confirmation at the bottom.';

  @override
  String get helpPriceAlertsTitle => 'Price alerts';

  @override
  String get helpPriceAlertsSummary =>
      'Every alert you\'ve set, grouped by asset.';

  @override
  String get helpPriceAlertsStep1Title => 'New alert';

  @override
  String get helpPriceAlertsStep1Body =>
      'Tap +, or open an asset and tap the bell.';

  @override
  String get helpPriceAlertsStep2Title => 'Pause or resume';

  @override
  String get helpPriceAlertsStep2Body =>
      'Use the switch. One-off alerts switch themselves off after they fire.';

  @override
  String get helpPriceAlertsStep3Title => 'Change or delete';

  @override
  String get helpPriceAlertsStep3Body => 'Tap an alert to edit or remove it.';

  @override
  String get helpPriceAlertsStep4Title => 'When alerts arrive';

  @override
  String get helpPriceAlertsStep4Body =>
      'Prices are checked about every 15 minutes in the background, so an alert can arrive a few minutes late.';

  @override
  String get helpPriceAlertsStep5Title => 'No notifications?';

  @override
  String get helpPriceAlertsStep5Body =>
      'Allow notifications for Qima in system settings, or alerts can\'t reach you.';

  @override
  String get helpAlertEditorTitle => 'Alert editor';

  @override
  String get helpAlertEditorSummary =>
      'Choose when Qima should notify you about this asset.';

  @override
  String get helpAlertEditorStep1Title => 'Price';

  @override
  String get helpAlertEditorStep1Body =>
      'Notify when the price goes above or below your target.';

  @override
  String get helpAlertEditorStep2Title => '% move';

  @override
  String get helpAlertEditorStep2Body =>
      'Notify when it moves up, down or either way by 1-10% within 24 hours or 7 days.';

  @override
  String get helpAlertEditorStep3Title => 'Check the trigger';

  @override
  String get helpAlertEditorStep3Body =>
      'The line under your choice shows exactly which prices will fire it.';

  @override
  String get helpAlertEditorStep4Title => 'Repeat';

  @override
  String get helpAlertEditorStep4Body =>
      'Off: the alert fires once, then switches off. On: it fires every time.';

  @override
  String get helpSettingsTitle => 'Settings';

  @override
  String get helpSettingsSummary => 'Choices that apply across the whole app.';

  @override
  String get helpSettingsStep1Title => 'Appearance';

  @override
  String get helpSettingsStep1Body => 'System, Light or Dark.';

  @override
  String get helpSettingsStep2Title => 'Privacy & security';

  @override
  String get helpSettingsStep2Body =>
      'Hide balances, and lock Qima with Face ID or fingerprint.';

  @override
  String get helpSettingsStep3Title => 'Alerts';

  @override
  String get helpSettingsStep3Body =>
      'See every price alert and check that notifications are allowed.';

  @override
  String get helpSettingsStep4Title => 'Backup';

  @override
  String get helpSettingsStep4Body =>
      'Save everything to a file and restore it later.';

  @override
  String get helpSettingsStep5Title => 'Defaults';

  @override
  String get helpSettingsStep5Body =>
      'Base currency, chart range, widget refresh and language.';

  @override
  String get helpBackupTitle => 'Backup & restore';

  @override
  String get helpBackupSummary =>
      'Qima has no account, so a backup file is how you keep your data if this phone is lost or reset.';

  @override
  String get helpBackupStep1Title => 'Full backup';

  @override
  String get helpBackupStep1Body =>
      'Saves your watchlist, holdings, custom tickers and settings as a .json file.';

  @override
  String get helpBackupStep2Title => 'Add a password';

  @override
  String get helpBackupStep2Body =>
      'Optional. You\'ll need it to restore, and it can\'t be recovered.';

  @override
  String get helpBackupStep3Title => 'Save or share';

  @override
  String get helpBackupStep3Body =>
      'Keep the file in Files or iCloud Drive, or send it to yourself.';

  @override
  String get helpBackupStep4Title => 'Restore';

  @override
  String get helpBackupStep4Body =>
      'Import a .json backup. Merge adds what\'s missing and deletes nothing; Replace swaps everything for the file.';

  @override
  String get helpBackupStep5Title => 'Spreadsheets';

  @override
  String get helpBackupStep5Body =>
      'Export every transaction as a .csv, or import one — from Qima, a spreadsheet or a broker. It adds transactions; it doesn’t restore settings.';

  @override
  String get helpWidgetsTitle => 'Widgets';

  @override
  String get helpWidgetsSummary =>
      'Put live prices and your portfolio on the Home Screen and Lock Screen.';

  @override
  String get helpWidgetsStep1Title => 'Touch and hold the Home Screen';

  @override
  String get helpWidgetsStep1Body =>
      'When the apps jiggle, tap Edit, then Add Widget.';

  @override
  String get helpWidgetsStep2Title => 'Find Qima';

  @override
  String get helpWidgetsStep2Body =>
      'Search for Qima, choose Price or Portfolio, pick a size and tap Add Widget.';

  @override
  String get helpWidgetsStep3Title => 'Choose what it shows';

  @override
  String get helpWidgetsStep3Body =>
      'Touch and hold the widget, tap Edit Widget, then pick asset, unit, karat, currency and chart range.';

  @override
  String get helpWidgetsStep4Title => 'Lock Screen';

  @override
  String get helpWidgetsStep4Body =>
      'Touch and hold the Lock Screen, tap Customize, then add a Qima widget.';

  @override
  String get helpWidgetsNote =>
      'Widgets refresh every 15 minutes by default. Change it in Settings under Widget refresh interval.';

  @override
  String get helpHoldingsTitle => 'Holdings';

  @override
  String get helpHoldingsSummary =>
      'Every transaction for this asset — buys, sells, transfers and fees — and what they add up to.';

  @override
  String get helpHoldingsStep1Title => 'Read the totals';

  @override
  String get helpHoldingsStep1Body =>
      'What you hold, your average cost, its value and gain, plus what sales have realised.';

  @override
  String get helpHoldingsStep2Title => 'Add a transaction';

  @override
  String get helpHoldingsStep2Body =>
      'Tap Add to record a buy, a sell, a transfer or a fee.';

  @override
  String get helpHoldingsStep3Title => 'Edit or delete one';

  @override
  String get helpHoldingsStep3Body =>
      'Tap a row to change it, or swipe to delete. Qima won’t let a change leave a sale selling more than you held.';

  @override
  String get helpCardConfigTitle => 'Asset settings';

  @override
  String get helpCardConfigSummary =>
      'Choose the currency, unit and karat this card shows before adding it.';

  @override
  String get helpCardConfigStep1Title => 'Currency';

  @override
  String get helpCardConfigStep1Body =>
      'Prices show in this currency on the card and its chart.';

  @override
  String get helpCardConfigStep2Title => 'Unit';

  @override
  String get helpCardConfigStep2Body =>
      'For metals, pick troy ounce, gram or kilogram.';

  @override
  String get helpCardConfigStep3Title => 'Karat';

  @override
  String get helpCardConfigStep3Body =>
      'For gold by weight, pick the purity you want priced.';

  @override
  String get helpCardConfigStep4Title => 'Add it';

  @override
  String get helpCardConfigStep4Body =>
      'You can change any of these later from the asset detail screen.';

  @override
  String get helpCustomTickerTitle => 'Custom ticker';

  @override
  String get helpCustomTickerSummary =>
      'Track a stock, ETF or index that isn\'t in Qima\'s catalog by its symbol.';

  @override
  String get helpCustomTickerStep1Title => 'Enter the symbol';

  @override
  String get helpCustomTickerStep1Body =>
      'Type the exact ticker symbol, like TSLA or VOO.';

  @override
  String get helpCustomTickerStep2Title => 'Qima checks it';

  @override
  String get helpCustomTickerStep2Body =>
      'It\'s looked up with the price provider first, so a typo is caught before it\'s added.';

  @override
  String get helpCustomTickerStep3Title => 'Add it';

  @override
  String get helpCustomTickerStep3Body =>
      'It\'s added to your watchlist with its real name and price.';

  @override
  String get helpCurrencyPickerTitle => 'Currency picker';

  @override
  String get helpCurrencyPickerSummary =>
      'Pick the currency prices and totals should show in.';

  @override
  String get helpCurrencyPickerStep1Title => 'Search';

  @override
  String get helpCurrencyPickerStep1Body =>
      'Type an ISO code or a currency name, like EUR or dirham.';

  @override
  String get helpCurrencyPickerStep2Title => 'Pick one';

  @override
  String get helpCurrencyPickerStep2Body =>
      'Tap a currency to use it immediately.';

  @override
  String get helpImportPreviewTitle => 'Restore preview';

  @override
  String get helpImportPreviewSummary =>
      'See what\'s in a backup file before it changes anything on this phone.';

  @override
  String get helpImportPreviewStep1Title => 'Check the contents';

  @override
  String get helpImportPreviewStep1Body =>
      'See how many cards, transactions and alerts the file contains before restoring.';

  @override
  String get helpImportPreviewStep2Title => 'Merge or Replace';

  @override
  String get helpImportPreviewStep2Body =>
      'Merge adds what\'s missing and deletes nothing. Replace swaps everything for the file.';

  @override
  String get helpImportPreviewStep3Title => 'Confirm';

  @override
  String get helpImportPreviewStep3Body =>
      'A password-protected file asks for its password first.';

  @override
  String get settingsHelpGroup => 'Help';

  @override
  String get settingsHelpReplayTour => 'Replay the tour';

  @override
  String get settingsHelpReplayTourSubtitle =>
      'See the five-step introduction again';

  @override
  String get settingsHelpHowQimaWorks => 'How Qima works';

  @override
  String get settingsHelpHowQimaWorksSubtitle => 'A short guide to every page';

  @override
  String get settingsHelpAddWidget => 'Add a widget';

  @override
  String get settingsHelpAddWidgetSubtitle => 'Home Screen and Lock Screen';

  @override
  String get commonDone => 'Done';

  @override
  String get zakatTitle => 'Zakat';

  @override
  String get zakatSettingsTitle => 'Zakat settings';

  @override
  String get settingsZakatSubtitle =>
      'Nisab basis, what counts, hawl date and reminder';

  @override
  String get zakatEmptyTitle => 'Nothing to assess yet';

  @override
  String get zakatEmptyMessage =>
      'Zakat is worked out from your holdings. Add a buy to any asset and it appears here, with what counts toward nisab.';

  @override
  String get zakatNisabSection => 'Nisab';

  @override
  String get zakatWhatCountsSection => 'What counts';

  @override
  String get zakatStatusAbove => 'Above nisab';

  @override
  String get zakatStatusBelow => 'Below nisab';

  @override
  String get zakatStatusUnknown => 'Nisab not priced yet';

  @override
  String zakatDueLabel(String rate) {
    return 'Zakat due · $rate';
  }

  @override
  String zakatExplainAboveNoHawl(String base) {
    return 'On a zakatable base of $base. Set your hawl date to know when it falls due.';
  }

  @override
  String zakatExplainAboveToday(String base) {
    return 'On a zakatable base of $base. Your hawl completes today.';
  }

  @override
  String zakatExplainAboveUpcoming(String base, String date, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'in $days days',
      one: 'in 1 day',
    );
    return 'On a zakatable base of $base. Due when your hawl completes on $date ($_temp0), if your wealth is still above nisab then.';
  }

  @override
  String zakatExplainBelow(String base, String threshold) {
    return 'Your zakatable base of $base is below today’s nisab of $threshold, so no zakat is due.';
  }

  @override
  String zakatExplainUnknown(String metal) {
    return 'Today’s $metal price hasn’t loaded, so the nisab threshold can’t be checked yet.';
  }

  @override
  String get zakatRetry => 'Try again';

  @override
  String get zakatUnpricedNote =>
      'Some assets have no price yet and aren’t counted. They count as soon as their price loads.';

  @override
  String get zakatBasisRow => 'Basis';

  @override
  String zakatBasisValue(String metal, String grams) {
    return '$metal · $grams g';
  }

  @override
  String zakatOtherBasisLine(String metal, String amount) {
    return '$metal basis would be $amount';
  }

  @override
  String get zakatThresholdToday => 'Threshold today';

  @override
  String get zakatYourBase => 'Your zakatable base';

  @override
  String get zakatHawlStart => 'Hawl start';

  @override
  String get zakatHawlSet => 'Set date';

  @override
  String get zakatHawlNotSetSubtitle =>
      'The day your wealth first reached nisab';

  @override
  String get zakatHawlCompletesToday => 'completes today';

  @override
  String zakatHawlNext(String date) {
    return 'next completes $date';
  }

  @override
  String get zakatWhatCountsFooter =>
      'Switch an asset off to leave it out — for example jewelry worn every day, if you follow the view that it is exempt.';

  @override
  String zakatExcludedClass(String cls) {
    return '$cls switched off';
  }

  @override
  String get zakatExcludedHolding => 'left out';

  @override
  String get zakatExcludedNoPrice => 'no price yet';

  @override
  String zakatLineTitle(String name, String quantity) {
    return '$name · $quantity';
  }

  @override
  String get zakatDisclaimer =>
      'Qima computes; it does not rule. The basis and what counts are yours to set — ask a scholar you trust when unsure.';

  @override
  String get assetGroupMetals => 'Metals';

  @override
  String get assetGroupCrypto => 'Crypto';

  @override
  String get assetGroupEquities => 'Equities';

  @override
  String get assetGroupCash => 'Cash & currencies';

  @override
  String get zakatClassMetalsSubtitle => 'Gold, silver, platinum, palladium';

  @override
  String get zakatClassCryptoSubtitle => 'Treated as a tradeable asset';

  @override
  String get zakatClassEquitiesSubtitle =>
      'Off by default — views on long-term shareholdings differ';

  @override
  String get zakatClassCashSubtitle => 'Currencies you hold';

  @override
  String zakatOverridesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count assets set individually',
      one: '1 asset set individually',
    );
    return '$_temp0';
  }

  @override
  String get zakatOverridesSubtitle =>
      'Chosen on the zakat screen, overriding their class';

  @override
  String get zakatOverridesReset => 'Reset';

  @override
  String get zakatNisabBasisSection => 'Nisab basis';

  @override
  String get zakatClassesSection => 'Zakatable classes';

  @override
  String get zakatHawlSection => 'Hawl';

  @override
  String get zakatBasisPriceMissing => 'Price not loaded yet';

  @override
  String zakatBasisToday(String amount) {
    return '$amount today';
  }

  @override
  String zakatBasisHigher(String amount) {
    return 'Higher threshold · $amount today';
  }

  @override
  String zakatBasisLower(String amount) {
    return 'Lower threshold · $amount today · more people owe';
  }

  @override
  String get zakatCalendar => 'Calendar';

  @override
  String get zakatCalendarHijri => 'Hijri';

  @override
  String get zakatCalendarGregorian => 'Gregorian';

  @override
  String zakatGregorianNote(String solarRate, String rate) {
    return 'A Gregorian year is about 11 days longer than a lunar one. Some scholars raise the rate to $solarRate to account for it; Qima keeps $rate.';
  }

  @override
  String get zakatHawlClear => 'Clear hawl date';

  @override
  String get zakatRemind => 'Remind me';

  @override
  String get zakatRemindSubtitle =>
      'A notification on the day your hawl completes';

  @override
  String get zakatRemindNeedsStart => 'Set a hawl start date first';

  @override
  String get zakatRemindNotificationsOff =>
      'Notifications are off for Qima — turn them on in system settings to get this reminder';

  @override
  String get zakatHawlPickerTitle => 'Hawl start';

  @override
  String get zakatHawlPickerDay => 'Day';

  @override
  String get zakatHawlPickerMonth => 'Month';

  @override
  String get zakatHawlPickerYear => 'Year';

  @override
  String get zakatHawlPickerFuture => 'A hawl can’t start in the future';

  @override
  String zakatHawlPickerGregorian(String date) {
    return 'Gregorian: $date';
  }

  @override
  String zakatEntryDue(String amount) {
    return '$amount due · above nisab';
  }

  @override
  String get zakatEntryCalculate => 'See what’s due';

  @override
  String get zakatReminderNotificationTitle => 'Your hawl is complete';

  @override
  String get zakatReminderNotificationBody =>
      'Your zakat year completed today. Open Qima to see what’s due.';

  @override
  String get hijriMonth1 => 'Muharram';

  @override
  String get hijriMonth2 => 'Safar';

  @override
  String get hijriMonth3 => 'Rabi al-Awwal';

  @override
  String get hijriMonth4 => 'Rabi al-Thani';

  @override
  String get hijriMonth5 => 'Jumada al-Ula';

  @override
  String get hijriMonth6 => 'Jumada al-Akhirah';

  @override
  String get hijriMonth7 => 'Rajab';

  @override
  String get hijriMonth8 => 'Shaban';

  @override
  String get hijriMonth9 => 'Ramadan';

  @override
  String get hijriMonth10 => 'Shawwal';

  @override
  String get hijriMonth11 => 'Dhu al-Qadah';

  @override
  String get hijriMonth12 => 'Dhu al-Hijjah';

  @override
  String hijriDate(int day, String month, int year) {
    return '$day $month $year AH';
  }

  @override
  String get helpZakatTitle => 'Zakat';

  @override
  String get helpZakatSummary =>
      'Qima works out zakat from your holdings at today’s prices. It calculates; the choices behind the calculation are yours.';

  @override
  String get helpZakatStep1Title => 'Nisab';

  @override
  String get helpZakatStep1Body =>
      'The threshold is 85 g of fine gold or 595 g of silver, priced live. Pick the basis in Zakat settings; silver is lower, so more people owe.';

  @override
  String get helpZakatStep2Title => 'What counts';

  @override
  String get helpZakatStep2Body =>
      'Metals, crypto and cash count by default; equities don’t. Karat gold counts by its gold content. Switch any single asset off on the zakat screen.';

  @override
  String get helpZakatStep3Title => 'Hawl';

  @override
  String get helpZakatStep3Body =>
      'Set the day your wealth first reached nisab. Zakat falls due each lunar year after it, and Qima can remind you on the day.';

  @override
  String get helpZakatStep4Title => 'A calculator, not a fatwa';

  @override
  String get helpZakatStep4Body =>
      'Scholars differ on the basis, on equities and on jewelry. Every default here can be changed — when unsure, ask a scholar you trust.';

  @override
  String get allocationTitle => 'Allocation';

  @override
  String get allocationDetails => 'Details';

  @override
  String get allocationByGroup => 'By group';

  @override
  String get allocationMetalsByForm => 'Metals · by karat and form';

  @override
  String allocationMetalForm(String metal, String karat) {
    return '$metal $karat';
  }

  @override
  String get allocationDriftTitle => 'Drift';

  @override
  String allocationDriftSince(String date) {
    return 'Drift · since $date';
  }

  @override
  String allocationDriftChange(String from, String to) {
    return '$from → $to';
  }

  @override
  String get allocationDriftPendingTitle => 'Before there is history';

  @override
  String allocationDriftPending(String date) {
    return 'How your split moves over time appears once your holdings are 14 days old, on $date. Until then, this is today’s allocation — no trend is invented.';
  }

  @override
  String get allocationDriftNoHistory =>
      'There aren’t enough stored prices yet to know how your allocation looked back then. It fills in as price history loads.';

  @override
  String allocationSingleGroup(String group) {
    return 'All in $group';
  }

  @override
  String get backupImportCountTransactions => 'Transactions';

  @override
  String portfolioTransactionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transactions',
      one: '1 transaction',
    );
    return '$_temp0';
  }

  @override
  String get portfolioClosedPositions => 'Closed positions';

  @override
  String ledgerTitleWithKarat(String name, String karat) {
    return '$name · $karat';
  }

  @override
  String get ledgerAdd => 'Add';

  @override
  String get ledgerAddFirst => 'Add a transaction';

  @override
  String get ledgerHolding => 'Holding';

  @override
  String get ledgerNothingHeld => 'Nothing held now';

  @override
  String ledgerPerUnit(String amount, String unit) {
    return '$amount / $unit';
  }

  @override
  String get ledgerMarketValue => 'Market value';

  @override
  String get ledgerUnrealised => 'Unrealised';

  @override
  String get ledgerRealised => 'Realised';

  @override
  String ledgerGainWithPercent(String amount, String percent) {
    return '$amount ($percent)';
  }

  @override
  String ledgerDetail(String date, String detail) {
    return '$date · $detail';
  }

  @override
  String ledgerDetailWithFee(String date, String price, String fee) {
    return '$date · $price · fee $fee';
  }

  @override
  String get ledgerNoCostBasis => 'no cost basis';

  @override
  String get ledgerCostCarried => 'cost carried over';

  @override
  String get ledgerFootnote =>
      'Cost basis is worked out from this ledger, not stored. Editing any row re-derives the holding.';

  @override
  String get ledgerOverdrawnBanner =>
      'A sale here sells more than was held on its date — usually from editing on two devices at once. It counts as selling what was left; edit or delete it to fix the totals.';

  @override
  String ledgerClosedLine(String amount) {
    return 'Nothing held now · realised $amount';
  }

  @override
  String get ledgerConflictSaveTitle => 'That would oversell';

  @override
  String get ledgerConflictDeleteTitle => 'Can’t delete this yet';

  @override
  String ledgerConflictMessage(String kind, String date) {
    return 'The $kind on $date would then sell more than was held. Edit or delete that one first.';
  }

  @override
  String get confirmDeleteTransactionTitle => 'Delete this transaction?';

  @override
  String confirmDeleteTransactionMessage(String details) {
    return '$details. The holding is worked out again without it. This can’t be undone.';
  }

  @override
  String get transactionNewTitle => 'New transaction';

  @override
  String get transactionEditTitle => 'Edit transaction';

  @override
  String get transactionKindBuy => 'Buy';

  @override
  String get transactionKindSell => 'Sell';

  @override
  String get transactionKindTransfer => 'Transfer';

  @override
  String get transactionKindTransferIn => 'Transfer in';

  @override
  String get transactionKindTransferOut => 'Transfer out';

  @override
  String get transactionKindFee => 'Fee';

  @override
  String get transactionTransferInLabel => 'In';

  @override
  String get transactionTransferOutLabel => 'Out';

  @override
  String transactionFineHint(String quantity) {
    return '= $quantity of fine gold';
  }

  @override
  String transactionPerUnitKarat(String unit, String karat) {
    return '$unit · $karat';
  }

  @override
  String transactionBuyPrice(String unit) {
    return 'Price paid (per $unit)';
  }

  @override
  String transactionSalePrice(String unit) {
    return 'Sale price (per $unit)';
  }

  @override
  String transactionCarriedCost(String unit) {
    return 'Original cost (per $unit, optional)';
  }

  @override
  String get transactionTotalProceeds => 'Total sale amount';

  @override
  String get transactionTotalCarriedCost => 'Original total cost (optional)';

  @override
  String get transactionTransferCostHelper =>
      'What it originally cost, if you know it. Left empty, it joins with no cost basis.';

  @override
  String get transactionFee => 'Fee (optional)';

  @override
  String get transactionFeeAmount => 'Fee amount';

  @override
  String get transactionFeeLabel => 'What it was for (optional)';

  @override
  String get transactionNote => 'Note (optional)';

  @override
  String get transactionNeedsQuantity => 'Enter a quantity.';

  @override
  String get transactionNeedsPrice => 'Enter a price.';

  @override
  String get transactionNeedsFee => 'Enter the fee amount.';

  @override
  String transactionMoreThanHeld(String held) {
    return 'That’s more than you held on that date ($held).';
  }

  @override
  String get transactionPreviewTitle => 'Realised gain preview';

  @override
  String get transactionProceeds => 'Proceeds';

  @override
  String get transactionBasisReleased => 'Cost basis released';

  @override
  String get transactionRealisedGain => 'Realised gain';

  @override
  String transactionPreviewRemaining(String quantity, String average) {
    return 'Weighted average basis. Still held after this: $quantity at $average.';
  }

  @override
  String get transactionPreviewClosesPosition =>
      'Weighted average basis. This sells everything you hold.';

  @override
  String get backupCsvHeaderType => 'Type';

  @override
  String get backupCsvHeaderFee => 'Fee';

  @override
  String get backupCsvHeaderNote => 'Note';

  @override
  String get csvImportTitle => 'Import from a spreadsheet';

  @override
  String get csvImportEntryTitle => 'Import transactions from CSV';

  @override
  String get csvImportEntrySubtitle =>
      'From a spreadsheet, a broker export or another app';

  @override
  String get csvImportFromBackupError => 'Import these as transactions';

  @override
  String csvImportRowCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rows',
      one: '1 row',
    );
    return '$_temp0';
  }

  @override
  String get csvImportEmptyFile =>
      'This file has a header row but no data under it.';

  @override
  String get csvImportColumnsSection => 'Columns';

  @override
  String get csvImportColumnsFooter =>
      'Matched from the header row where Qima could. A price or a total will do; the asset can be a symbol or a name. * needed.';

  @override
  String get csvImportNotInFile => 'Not in file';

  @override
  String get csvImportOptionsSection => 'Reading the file';

  @override
  String get csvImportFallbackCurrency => 'Currency';

  @override
  String get csvImportFallbackCurrencySubtitle =>
      'For rows that don’t name one';

  @override
  String get csvImportDateOrder => 'Dates like 03/04/2026 mean';

  @override
  String get csvImportDayFirst => '3 April';

  @override
  String get csvImportMonthFirst => 'March 4';

  @override
  String get csvImportDecimalComma => 'Comma is the decimal mark';

  @override
  String get csvImportDecimalCommaSubtitle =>
      'Read 1.234,56 as one thousand two hundred…';

  @override
  String get csvImportNeedsColumns =>
      'Choose at least the asset, the date and the quantity.';

  @override
  String get csvImportReview => 'Review rows';

  @override
  String get csvImportReadyCount => 'Ready';

  @override
  String get csvImportDuplicateCount => 'Already in Qima';

  @override
  String get csvImportProblemCount => 'Can’t import';

  @override
  String get csvImportSkipNote =>
      'Rows that can’t be read, or are already in Qima, are skipped. Nothing is guessed.';

  @override
  String get csvImportShowAll => 'All rows';

  @override
  String get csvImportShowProblems => 'Skipped only';

  @override
  String get csvImportSkipped => 'Skipped';

  @override
  String get csvImportDuplicate => 'Duplicate';

  @override
  String get csvImportBackToColumns => 'Columns';

  @override
  String csvImportConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Import $count transactions',
      one: 'Import 1 transaction',
      zero: 'Nothing to import',
    );
    return '$_temp0';
  }

  @override
  String csvImportDoneTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transactions imported',
      one: '1 transaction imported',
    );
    return '$_temp0';
  }

  @override
  String get csvImportDoneMessage =>
      'They’re in each asset’s ledger now. If something looks off, undo removes exactly what this import added.';

  @override
  String get csvImportUndo => 'Undo this import';

  @override
  String csvImportUndone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Removed $count imported transactions',
      one: 'Removed 1 imported transaction',
    );
    return '$_temp0';
  }

  @override
  String get csvFieldType => 'Type';

  @override
  String get csvFieldAsset => 'Asset name';

  @override
  String get csvFieldSymbol => 'Symbol';

  @override
  String get csvFieldQuantity => 'Quantity';

  @override
  String get csvFieldUnit => 'Unit';

  @override
  String get csvFieldKarat => 'Karat';

  @override
  String get csvFieldUnitPrice => 'Price per unit';

  @override
  String get csvFieldTotal => 'Total';

  @override
  String get csvFieldFee => 'Fee';

  @override
  String get csvFieldCurrency => 'Currency';

  @override
  String get csvFieldDate => 'Date';

  @override
  String get csvFieldNote => 'Note';

  @override
  String get csvProblemUnknownAsset => 'unknown asset';

  @override
  String get csvProblemMissingQuantity => 'no quantity';

  @override
  String get csvProblemBadNumber => 'a number can’t be read';

  @override
  String get csvProblemMissingPrice => 'no price';

  @override
  String get csvProblemMissingDate => 'no date';

  @override
  String get csvProblemBadDate => 'date can’t be read';

  @override
  String get csvProblemFutureDate => 'date in the future';

  @override
  String get csvProblemUnknownType => 'unknown type';

  @override
  String get csvProblemUnknownCurrency => 'unknown currency';

  @override
  String get csvProblemUnsupportedUnit => 'unit doesn’t fit this asset';

  @override
  String get csvProblemUnsupportedKarat => 'karat doesn’t fit this asset';

  @override
  String get csvProblemOversell => 'sells more than was held';

  @override
  String get csvProblemDuplicate => 'already in Qima';

  @override
  String get transactionBuyPricePlain => 'Price paid';

  @override
  String get transactionSalePricePlain => 'Sale price';

  @override
  String get transactionCarriedCostPlain => 'Original cost (optional)';

  @override
  String settingsVersion(String version, String build) {
    return 'Version $version ($build)';
  }

  @override
  String get watchlistEditOrder => 'Edit order';

  @override
  String get watchlistSortBy => 'Sort by';

  @override
  String get watchlistSortName => 'Name';

  @override
  String get watchlistSortChange => 'Top performers';

  @override
  String get watchlistSortAssetClass => 'Asset class';

  @override
  String watchlistDragHandle(String name) {
    return 'Move $name';
  }

  @override
  String get watchlistEditOrderHint =>
      'Drag the handles to reorder. A sort sets a new order you can keep adjusting.';

  @override
  String get shareAction => 'Share';

  @override
  String shareTitle(String name) {
    return 'Share $name';
  }

  @override
  String get shareToWhatsappMessage => 'WhatsApp message';

  @override
  String get shareToWhatsappStatus => 'WhatsApp status';

  @override
  String get shareToInstagramPost => 'Instagram post';

  @override
  String get shareToInstagramStory => 'Instagram story';

  @override
  String get shareToFacebookPost => 'Facebook post';

  @override
  String get shareToFacebookStory => 'Facebook story';

  @override
  String get shareToLinkedinPost => 'LinkedIn post';

  @override
  String shareCaption(String name, String price) {
    return '$name is at $price.';
  }

  @override
  String shareCaptionWithChange(
    String name,
    String price,
    String change,
    String range,
  ) {
    return '$name is at $price ($change, $range).';
  }

  @override
  String shareCaptionFooter(String url) {
    return 'Tracked with Qima: $url';
  }

  @override
  String get shareCaptionCopied =>
      'Caption copied. Paste it if the app leaves it out.';

  @override
  String get shareFailed => 'Couldn\'t create the image. Try again.';

  @override
  String get helpWatchlistStep6Title => 'Change the order';

  @override
  String get helpWatchlistStep6Body =>
      'Tap the arrows at the top to drag cards by their handles, or sort by name, performance or asset class. You can also press and hold a card to drag it.';

  @override
  String get helpAssetDetailStep6Title => 'Share it';

  @override
  String get helpAssetDetailStep6Body =>
      'Tap share to post the price and chart as an image sized for WhatsApp, Instagram, Facebook or LinkedIn, with a ready caption.';

  @override
  String get captureRecordThis => 'Record this';

  @override
  String get captureCheckTitle => 'Check this';

  @override
  String get captureYouWrote => 'You wrote';

  @override
  String get captureRead => 'Read as';

  @override
  String get captureFieldType => 'Type';

  @override
  String get captureFieldAsset => 'Asset';

  @override
  String get captureFieldQuantity => 'Quantity';

  @override
  String get captureFieldPrice => 'Price';

  @override
  String get captureFieldFee => 'Fee';

  @override
  String get captureFieldDate => 'Date';

  @override
  String captureFrom(String words) {
    return 'from “$words”';
  }

  @override
  String get captureBaseCurrency => 'your base currency';

  @override
  String get captureTotalDivided => 'total ÷ quantity';

  @override
  String get captureAssumed => 'assumed';

  @override
  String get captureToday => 'today';

  @override
  String get captureCheck => 'check';

  @override
  String get captureConfirm => 'Confirm';

  @override
  String get captureEditFields => 'Edit fields';

  @override
  String get captureFootnote =>
      'Every field says where it came from, and nothing is saved until you confirm.';

  @override
  String get captureOnDevice => 'On device';

  @override
  String get captureNothingSent =>
      'Read on this device. Nothing is sent anywhere.';

  @override
  String get captureNeedsPrice => 'No price found. Edit the fields to add one.';

  @override
  String captureRecorded(String summary) {
    return 'Recorded: $summary';
  }

  @override
  String get settingsSummaries => 'Summaries';

  @override
  String get settingsPlainSummaries => 'Month in a sentence';

  @override
  String get settingsPlainSummariesFooter =>
      'Shows what moved your holdings over the past month as one sentence on Portfolio. Written on this device from your own numbers.';

  @override
  String get summaryTitle => 'Past month';

  @override
  String summaryUp(String amount, String percent) {
    return 'Over the past month your holdings gained $amount ($percent).';
  }

  @override
  String summaryDown(String amount, String percent) {
    return 'Over the past month your holdings lost $amount ($percent).';
  }

  @override
  String get summaryFlat => 'Your holdings barely moved over the past month.';

  @override
  String summaryTopMover(String asset, String amount) {
    return '$asset moved them most, $amount.';
  }

  @override
  String summaryTransactions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'You recorded $count transactions.',
      one: 'You recorded 1 transaction.',
    );
    return '$_temp0';
  }

  @override
  String chartDescription(
    String from,
    String to,
    String start,
    String end,
    String change,
    String high,
    String highDate,
    String low,
    String lowDate,
  ) {
    return '$from to $to: $start to $end, $change. High $high on $highDate, low $low on $lowDate.';
  }

  @override
  String chartDescriptionHidden(String from, String to, String change) {
    return '$from to $to: $change.';
  }

  @override
  String get dictationStart => 'Speak a purchase';

  @override
  String get dictationStop => 'Stop listening';

  @override
  String get dictationUnsupported =>
      'Voice input in this language isn\'t available on this device. Qima only listens on the device, never through a server.';

  @override
  String get dictationDenied =>
      'Microphone or speech recognition is off for Qima. Turn them on in Settings to speak a purchase.';
}
