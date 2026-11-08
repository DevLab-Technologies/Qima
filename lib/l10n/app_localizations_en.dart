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
  String get watchlistAdd => 'Add to watchlist';

  @override
  String get watchlistEmptyTitle => 'Your watchlist is empty';

  @override
  String get watchlistEmptyMessage =>
      'Add metals, crypto, stocks, or currencies to start tracking prices.';

  @override
  String get watchlistFilterAll => 'All';

  @override
  String get addTitle => 'Add to watchlist';

  @override
  String get addSearchHint => 'Search, or describe a purchase';

  @override
  String get addWatchSearchHint => 'Search gold, Bitcoin, AAPL…';

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
      'Gold, silver, crypto, stocks, indices and currencies, added up in your currency, with a plain summary of each month.';

  @override
  String get onboardingStep2Title => 'Prices the way you buy';

  @override
  String get onboardingStep2Body =>
      'Live prices by gram, ounce or kilogram, 24K to 18K, in any currency. Tap + to add to your watchlist, tap a card for its chart.';

  @override
  String get onboardingStep3Title => 'Know what you hold';

  @override
  String get onboardingStep3Body =>
      'Tap +, then Add holding, and type what you bought, or say it or scan a receipt. It is read on this device and saved only when you confirm. See what you hold, your average cost, value and gain.';

  @override
  String get onboardingStep4Title => 'Never miss a move';

  @override
  String get onboardingStep4Body =>
      'Get notified when a price crosses a level or moves by a percent. Put prices on your Home and Lock Screen.';

  @override
  String get onboardingStep4BodyApple =>
      'Get notified when a price crosses a level or moves by a percent. Put prices on your Home and Lock Screen, or ask Siri what your portfolio is worth.';

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
  String get helpHomeSummary =>
      'Your net worth: everything you own minus everything you owe, with the cards you use most.';

  @override
  String get helpHomeStep1Title => 'Net worth';

  @override
  String get helpHomeStep1Body =>
      'Tap it to open the balance sheet: what you own and what you owe, item by item.';

  @override
  String get helpHomeStep2Title => 'Your cards';

  @override
  String get helpHomeStep2Body =>
      'Accounts, Left to spend, Coming up and others appear as you use them. Tap a card to open it.';

  @override
  String get helpHomeStep3Title => 'Edit Home';

  @override
  String get helpHomeStep3Body =>
      'Move cards or hide the ones you don’t need. Qima never adds back a card you hid.';

  @override
  String get helpHomeStep4Title => 'Hide balances';

  @override
  String get helpHomeStep4Body =>
      'Tap the eye to mask every amount, for when someone is looking.';

  @override
  String get helpHomeStep5Title => 'Add anything';

  @override
  String get helpHomeStep5Body =>
      'Tap + for a transaction, a statement, a holding, or anything under More.';

  @override
  String get helpMoneySummary =>
      'Where this month’s money went, and what came in and went out.';

  @override
  String get helpMoneyStep1Title => 'Pick a month';

  @override
  String get helpMoneyStep1Body =>
      'Use the arrows at the top to see another month.';

  @override
  String get helpMoneyStep2Title => 'Spent and pace';

  @override
  String get helpMoneyStep2Body =>
      'What you’ve spent so far, and where you’ll be by the month’s end at this pace.';

  @override
  String get helpMoneyStep3Title => 'Where it went';

  @override
  String get helpMoneyStep3Body => 'Spending by category, biggest first.';

  @override
  String get helpMoneyStep4Title => 'Cash flow';

  @override
  String get helpMoneyStep4Body =>
      'Money in, money out and what’s left over. Moves between your own accounts don’t count.';

  @override
  String get helpMoneyStep5Title => 'Worth a look';

  @override
  String get helpMoneyStep5Body =>
      'Notes on budgets and entries to categorize, when there’s something to see.';

  @override
  String get helpNewTransactionSummary =>
      'Record money spent, earned or moved between your accounts.';

  @override
  String get helpNewTransactionStep1Title => 'Pick the kind';

  @override
  String get helpNewTransactionStep1Body =>
      'Spend, Income or Transfer. The amount and date stay when you switch.';

  @override
  String get helpNewTransactionStep2Title => 'Say it';

  @override
  String get helpNewTransactionStep2Body =>
      'Tap the mic and say, for example, “Spent 45 at Panda with Visa yesterday”. Qima fills in the form on this device; check it and tap Save.';

  @override
  String get helpNewTransactionStep3Title => 'Category';

  @override
  String get helpNewTransactionStep3Body =>
      'Spending and income go in a category. A move between your own accounts is never spending.';

  @override
  String get helpNewTransactionStep4Title => 'Declined';

  @override
  String get helpNewTransactionStep4Body =>
      'Turn on Declined for a payment that didn’t go through: it’s shown struck through and never counts.';

  @override
  String get helpTransactionsSummary =>
      'Every transaction, newest first, and what each one did to your accounts.';

  @override
  String get helpTransactionsStep1Title => 'Open one';

  @override
  String get helpTransactionsStep1Body =>
      'Tap a transaction to see each account it touched, and by how much.';

  @override
  String get helpTransactionsStep2Title => 'How it counts';

  @override
  String get helpTransactionsStep2Body =>
      'Each one says whether it’s spending, income, a move between your accounts or a change in value.';

  @override
  String get helpTransactionsStep3Title => 'Edit or delete';

  @override
  String get helpTransactionsStep3Body =>
      'Open it, then edit or delete it. Deleting puts every account back as it was.';

  @override
  String get helpAccountsSummary =>
      'Bank accounts, cash, cards and loans, with what’s in each one today.';

  @override
  String get helpAccountsStep1Title => 'Add an account';

  @override
  String get helpAccountsStep1Body =>
      'Give it a name, a type and its balance today. Qima starts from that figure.';

  @override
  String get helpAccountsStep2Title => 'Check the balance';

  @override
  String get helpAccountsStep2Body =>
      'Open an account and enter what your bank shows. For a difference, choose: add a transaction for it, or change the opening balance so nothing counts as spending.';

  @override
  String get helpAccountsStep3Title => 'Count cash';

  @override
  String get helpAccountsStep3Body =>
      'For cash, count what’s in your wallet and Qima sets the balance to it.';

  @override
  String get helpAccountsStep4Title => 'Pay a card or loan';

  @override
  String get helpAccountsStep4Body =>
      'Open the card or loan and tap Pay to record a payment from another account.';

  @override
  String get helpAccountsStep5Title => 'Remove one';

  @override
  String get helpAccountsStep5Body =>
      'An account with transactions is archived so its history still adds up. One never used is deleted.';

  @override
  String get helpBalanceSheetSummary =>
      'Everything you own and everything you owe, adding up to your net worth.';

  @override
  String get helpBalanceSheetStep1Title => 'What you own';

  @override
  String get helpBalanceSheetStep1Body =>
      'Accounts, holdings at live prices, and assets at the value you set.';

  @override
  String get helpBalanceSheetStep2Title => 'What you owe';

  @override
  String get helpBalanceSheetStep2Body =>
      'Cards, loans (principal only) and money you owe people.';

  @override
  String get helpBalanceSheetStep3Title => 'How the total is worked out';

  @override
  String get helpBalanceSheetStep3Body =>
      'Open it to see each rule, such as the live rate used for other currencies.';

  @override
  String get helpBalanceSheetStep4Title => 'Leave one out';

  @override
  String get helpBalanceSheetStep4Body =>
      'Turn off Count in net worth on an account or asset; its history still adds up.';

  @override
  String get helpAssetsSummary =>
      'A home, land, a car or a share in a business, at the value you set.';

  @override
  String get helpAssetsStep1Title => 'Add an asset';

  @override
  String get helpAssetsStep1Body =>
      'Pick a kind, then give it a value and a date. Gold and silver by weight are holdings instead.';

  @override
  String get helpAssetsStep2Title => 'Update the value';

  @override
  String get helpAssetsStep2Body =>
      'Every update is dated. The latest counts; older values stay as history.';

  @override
  String get helpAssetsStep3Title => 'A loan on it';

  @override
  String get helpAssetsStep3Body =>
      'Link the loan secured on it to see what’s still owed next to its value.';

  @override
  String get helpAssetsStep4Title => 'Sold it';

  @override
  String get helpAssetsStep4Body =>
      'Record the sale: the money goes into an account and the asset leaves your balance sheet.';

  @override
  String get helpImportStatementSummary =>
      'Bring in transactions from your bank’s PDF, Excel or CSV, screenshots, or a copied file.';

  @override
  String get helpImportStatementStep1Title => 'Pick the files';

  @override
  String get helpImportStatementStep1Body =>
      'From Files, Photos, the clipboard, or Share › Qima from any app. They’re read on this device.';

  @override
  String get helpImportStatementStep2Title => 'Check every row';

  @override
  String get helpImportStatementStep2Body =>
      'Pick the account, untick what you don’t want and fix any category. Rows already in Qima start unticked.';

  @override
  String get helpImportStatementStep3Title => 'Match the balance';

  @override
  String get helpImportStatementStep3Body =>
      'When the statement shows a balance, tick Bring the balance to it. Then choose how: change the opening balance, or add a transaction for the difference.';

  @override
  String get helpImportStatementStep4Title => 'Add them';

  @override
  String get helpImportStatementStep4Body =>
      'Tap Add. The files are deleted once imported.';

  @override
  String get helpBankMessagesSummary =>
      'Add purchases from the messages your bank sends you, after you check each one.';

  @override
  String get helpBankMessagesStep1Title => 'On Android';

  @override
  String get helpBankMessagesStep1Body =>
      'Turn on Read new bank messages and allow access. Bring in the last 60 days the first time.';

  @override
  String get helpBankMessagesStep2Title => 'On iPhone';

  @override
  String get helpBankMessagesStep2Body =>
      'Set up a Shortcuts automation once, so each bank message goes to Qima’s Add a bank message action.';

  @override
  String get helpBankMessagesStep3Title => 'Check before adding';

  @override
  String get helpBankMessagesStep3Body =>
      'Messages wait in the import review. Codes, offers and repeats are skipped.';

  @override
  String get helpBankMessagesStep4Title => 'Private';

  @override
  String get helpBankMessagesStep4Body =>
      'Messages are read on this device and never leave it.';

  @override
  String get helpCategoriesSummary =>
      'Sort spending into categories, and teach Qima where each name goes.';

  @override
  String get helpCategoriesStep1Title => 'To categorize';

  @override
  String get helpCategoriesStep1Body =>
      'Pick a category once for each name. Imports from that name use it from now on.';

  @override
  String get helpCategoriesStep2Title => 'Earlier entries';

  @override
  String get helpCategoriesStep2Body =>
      'Qima offers to move earlier entries from the same name too.';

  @override
  String get helpCategoriesStep3Title => 'Your categories';

  @override
  String get helpCategoriesStep3Body =>
      'Add, rename or remove categories. Transactions in a removed one keep it in their history.';

  @override
  String get helpCategoriesStep4Title => 'Forget a name';

  @override
  String get helpCategoriesStep4Body =>
      'Forget what Qima learned for a name, and its imports are sorted by hand again.';

  @override
  String get helpBudgetSummary =>
      'A monthly amount for each category you want to watch.';

  @override
  String get helpBudgetStep1Title => 'Set an amount';

  @override
  String get helpBudgetStep1Body =>
      'Tap a category and enter its amount per month. Zero removes it.';

  @override
  String get helpBudgetStep2Title => 'Left to spend';

  @override
  String get helpBudgetStep2Body =>
      'Home shows what’s left this month, and Money notes a category that’s ahead of its pace.';

  @override
  String get helpBudgetStep3Title => 'What counts';

  @override
  String get helpBudgetStep3Body =>
      'Card payments, transfers and loan principal never count.';

  @override
  String get helpRecurringSummary =>
      'Rent, bills and subscriptions, shown in Coming up before they’re due.';

  @override
  String get helpRecurringStep1Title => 'Add one';

  @override
  String get helpRecurringStep1Body =>
      'Give it a name, an amount, the account it’s paid from and its day of the month.';

  @override
  String get helpRecurringStep2Title => 'Coming up';

  @override
  String get helpRecurringStep2Body =>
      'Home lists the next ones due, so nothing takes you by surprise.';

  @override
  String get helpRecurringStep3Title => 'Change or remove';

  @override
  String get helpRecurringStep3Body => 'Tap one to change it or remove it.';

  @override
  String get helpPeopleSummary =>
      'Who owes you, whom you owe, and the repayments.';

  @override
  String get helpPeopleStep1Title => 'Lent or borrowed';

  @override
  String get helpPeopleStep1Body =>
      'Tap + › More › Lent or Borrowed, and type the person’s name.';

  @override
  String get helpPeopleStep2Title => 'Repayments';

  @override
  String get helpPeopleStep2Body =>
      'Record Repayment received or Repayment made, and what’s owed goes down.';

  @override
  String get helpPeopleStep3Title => 'Bill split';

  @override
  String get helpPeopleStep3Body =>
      'Pay a whole bill and split it: only your share is spending, the rest is owed to you.';

  @override
  String get helpFeaturesSummary =>
      'Turn parts of Qima on or off. Features also turn on by themselves the first time you use them.';

  @override
  String get helpFeaturesStep1Title => 'Turn one off';

  @override
  String get helpFeaturesStep1Body =>
      'Its screens hide, never your money: its amounts still count on the balance sheet.';

  @override
  String get helpFeaturesStep2Title => 'On when used';

  @override
  String get helpFeaturesStep2Body =>
      'Record your first loan payment and Loans turns on, with an Undo if you didn’t want it.';

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
  String get helpWatchlistTitle => 'Prices';

  @override
  String get helpWatchlistSummary => 'Live prices for everything you follow.';

  @override
  String get helpWatchlistStep1Title => 'Open a card';

  @override
  String get helpWatchlistStep1Body =>
      'Tap any card for its chart, key stats and your holdings.';

  @override
  String get helpWatchlistStep2Title => 'Add an asset';

  @override
  String get helpWatchlistStep2Body =>
      'Tap + at the bottom, then Add to watchlist.';

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
  String get helpPortfolioStep3Body =>
      'Tap + at the bottom, then Add holding. Or open an asset and tap Holdings.';

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
  String get helpPortfolioStep6Title => 'Past month';

  @override
  String get helpPortfolioStep6Body =>
      'A short summary of how your holdings moved, worked out from your own records. Turn it off in Settings.';

  @override
  String get helpPortfolioStep7Title => 'Ask Siri';

  @override
  String get helpPortfolioStep7Body =>
      'Ask Siri or use Shortcuts to hear what your portfolio is worth or check a price, without opening Qima.';

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
  String get helpAddAssetTitle => 'Add to watchlist or holding';

  @override
  String get helpAddAssetSummary =>
      'Follow a price on your watchlist, or record something you bought.';

  @override
  String get helpAddAssetStep1Title => 'Search';

  @override
  String get helpAddAssetStep1Body =>
      'Tap +, then Add to watchlist. Search by name or symbol in any app language, like gold, ذهب or BTC.';

  @override
  String get helpAddAssetStep2Title => 'Pick a result';

  @override
  String get helpAddAssetStep2Body =>
      'Choose the currency and unit its price shows in, then add it to your watchlist.';

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
  String get helpSettingsStep6Title => 'On-device intelligence';

  @override
  String get helpSettingsStep6Body =>
      'Optionally let this device\'s own language model help read purchases and word the summary. It runs only here, never gives advice and never supplies a number.';

  @override
  String get helpBackupTitle => 'Backup & restore';

  @override
  String get helpBackupSummary =>
      'Qima has no account, so a backup file is how you keep your data if this phone is lost or reset.';

  @override
  String get helpBackupStep1Title => 'Full backup';

  @override
  String get helpBackupStep1Body =>
      'Saves your accounts, transactions, assets, watchlist, holdings and settings as a .json file.';

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
  String get zakatGregorianNote =>
      'Dates show in the Gregorian calendar. The hawl is still a lunar year, so it completes about 11 days earlier each Gregorian year.';

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
      'Qima works out zakat from what you own at today’s prices. It calculates; the choices behind the calculation are yours.';

  @override
  String get helpZakatStep1Title => 'Nisab';

  @override
  String get helpZakatStep1Body =>
      'The threshold is 85 g of fine gold or 595 g of silver, priced live. Pick the basis in Zakat settings; silver is lower, so more people owe.';

  @override
  String get helpZakatStep2Title => 'What counts';

  @override
  String get helpZakatStep2Body =>
      'Cash, metals and crypto count by default, and assets held for sale at their value; equities don’t. Card balances and money you owe people are deducted. Switch any single item off.';

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
  String get dictationLanguage => 'Language you speak';

  @override
  String get dictationStop => 'Stop listening';

  @override
  String get dictationUnsupported =>
      'Voice input in this language isn\'t available on this device. Qima only listens on the device, never through a server.';

  @override
  String get dictationDenied =>
      'Microphone or speech recognition is off for Qima. Turn them on in Settings to speak a purchase.';

  @override
  String get settingsIntelligence => 'On-device intelligence';

  @override
  String get settingsUseModel => 'Use the on-device model';

  @override
  String get settingsUseModelFooter =>
      'Helps read purchases Qima can\'t place on its own, and words the month summary. It runs only on this device, never gives advice, and never supplies a number: every figure comes from your own records.';

  @override
  String get modelReady => 'Ready on this device';

  @override
  String get modelUnsupported => 'Not available on this device';

  @override
  String get modelTurnedOff =>
      'Turn on Apple Intelligence in system Settings to use it';

  @override
  String get modelNotReady => 'The model is still downloading';

  @override
  String get modelUnsupportedLanguage => 'Not available in this language yet';

  @override
  String get receiptScan => 'Scan a receipt';

  @override
  String get receiptTakePhoto => 'Take a photo';

  @override
  String get receiptChoosePhoto => 'Choose a photo';

  @override
  String get receiptNoText =>
      'No text found in that photo. Try again closer, with the receipt flat and well lit.';

  @override
  String get addButton => 'Add';

  @override
  String get addSheetWatch => 'Add to watchlist';

  @override
  String get addSheetWatchSubtitle => 'Track a price. No purchase needed.';

  @override
  String get addHoldingTitle => 'Add holding';

  @override
  String get addSheetHoldingSpeakScan => 'Speak, scan a receipt or type it.';

  @override
  String get addSheetHoldingSpeak => 'Speak or type what you bought.';

  @override
  String get addSheetHoldingScan => 'Scan a receipt or type it.';

  @override
  String get addSheetHoldingType => 'Type what you bought.';

  @override
  String get addSheetSiriTip => 'Ask Siri: “What\'s my Qima portfolio worth”';

  @override
  String get addTypeExample =>
      'For example: bought 20 g of 21K gold at 4,100 EGP';

  @override
  String get currencyFieldShowIn => 'Show prices in';

  @override
  String get currencyFieldTransaction => 'Transaction currency';

  @override
  String currencyFieldCount(int count) {
    return '$count currencies available';
  }

  @override
  String get currencyFieldMore => 'More';

  @override
  String get helpAddAssetStep5Title => 'Add a holding';

  @override
  String get helpAddAssetStep5Body =>
      'Tap +, then Add holding. Type what you bought, or speak it or scan a receipt where this device can. Check what was read, then confirm.';

  @override
  String get helpAddAssetStep6Title => 'Read on this device';

  @override
  String get helpAddAssetStep6Body =>
      'Speech and receipts are read on this device and never sent anywhere. Nothing is saved until you confirm, and every number comes from what you typed, said or scanned.';

  @override
  String get navHome => 'Home';

  @override
  String get navMoney => 'Money';

  @override
  String get navPrices => 'Prices';

  @override
  String get netWorth => 'Net worth';

  @override
  String get balanceSheet => 'Balance sheet';

  @override
  String get youOwn => 'You own';

  @override
  String get youOweSide => 'You owe';

  @override
  String ownOweLine(String own, String owe) {
    return 'You own $own · You owe $owe';
  }

  @override
  String get sheetHoldings => 'Holdings';

  @override
  String get sheetHoldingsLive => 'At live prices';

  @override
  String get sheetCash => 'Cash and bank';

  @override
  String get sheetOwedToYou => 'Money owed to you';

  @override
  String get sheetAssets => 'Property and more';

  @override
  String get sheetCards => 'Cards';

  @override
  String get sheetLoans => 'Loans';

  @override
  String get sheetYouOwe => 'Money you owe people';

  @override
  String get sheetNothingOwed =>
      'Nothing owed. Cards, loans and money you owe people appear here once added.';

  @override
  String sheetMissingRates(String codes) {
    return 'No exchange rate yet for $codes; those amounts are left out of the total.';
  }

  @override
  String get acctCash => 'Cash';

  @override
  String get acctDebit => 'Bank account';

  @override
  String get acctCredit => 'Card';

  @override
  String get acctLoan => 'Loan';

  @override
  String get acctReceivable => 'Owes you';

  @override
  String get acctPayable => 'You owe';

  @override
  String get acctAsset => 'Asset';

  @override
  String get acctCategory => 'Category';

  @override
  String get assetKindProperty => 'Property';

  @override
  String get assetKindVehicle => 'Vehicle';

  @override
  String get assetKindBusiness => 'Business';

  @override
  String get assetKindValuables => 'Valuables';

  @override
  String get assetKindOther => 'Other';

  @override
  String get assetKindPropertyHint => 'A home, land, a shop';

  @override
  String get assetKindVehicleHint => 'A car, a motorbike, a boat';

  @override
  String get assetKindBusinessHint => 'Your share in a business';

  @override
  String get assetKindValuablesHint => 'A watch, art, a collection';

  @override
  String get assetKindOtherHint => 'Anything else you own';

  @override
  String get tplOpening => 'Opening balance';

  @override
  String get tplSpend => 'Spend';

  @override
  String get tplIncome => 'Income';

  @override
  String get tplTransfer => 'Transfer';

  @override
  String get tplAtm => 'ATM withdrawal';

  @override
  String get tplSwap => 'Currency swap';

  @override
  String get tplCardPayment => 'Card payment';

  @override
  String get tplLoanPayment => 'Loan payment';

  @override
  String get tplLent => 'Lent';

  @override
  String get tplBorrowed => 'Borrowed';

  @override
  String get tplRepaymentIn => 'Repayment received';

  @override
  String get tplRepaymentOut => 'Repayment made';

  @override
  String get tplRefund => 'Refund';

  @override
  String get tplDeclined => 'Declined';

  @override
  String get tplCashCount => 'Cash count';

  @override
  String get tplBillSplit => 'Bill split';

  @override
  String get tplValuation => 'New value';

  @override
  String get tplAssetSale => 'Sold';

  @override
  String get tplAdjustment => 'Adjustment';

  @override
  String get catGroceries => 'Groceries';

  @override
  String get catDining => 'Dining';

  @override
  String get catTransport => 'Transport';

  @override
  String get catBills => 'Bills';

  @override
  String get catShopping => 'Shopping';

  @override
  String get catHealth => 'Health';

  @override
  String get catHome => 'Home';

  @override
  String get catOther => 'Other';

  @override
  String get catSalary => 'Salary';

  @override
  String get catOtherIncome => 'Other income';

  @override
  String get catInterestFees => 'Interest & fees';

  @override
  String get sysOpening => 'Opening balances';

  @override
  String get sysChange => 'Change in value';

  @override
  String get sysRounding => 'Rounding';

  @override
  String get featBudget => 'Budget';

  @override
  String get featRecurring => 'Recurring payments';

  @override
  String get featPeople => 'Lent and borrowed';

  @override
  String get featLoans => 'Loans';

  @override
  String get featBillSplit => 'Bill split';

  @override
  String get featZakat => 'Zakat';

  @override
  String get featBudgetDetail =>
      'A monthly amount per category, and what\'s left';

  @override
  String get featRecurringDetail =>
      'Bills and subscriptions, shown before they are due';

  @override
  String get featPeopleDetail => 'Who owes you, and whom you owe';

  @override
  String get featLoansDetail =>
      'What\'s left on a loan, and each payment\'s profit';

  @override
  String get featBillSplitDetail =>
      'Pay a bill and split it; only your share is spending';

  @override
  String get featZakatDetail => 'Zakat over your holdings, cash and debts';

  @override
  String featureTurnedOn(String feature) {
    return '$feature is on';
  }

  @override
  String get featuresTitle => 'Features';

  @override
  String get featuresSubtitle => 'Budget, recurring, loans and more';

  @override
  String get featuresIntro =>
      'Turning a feature off hides its screens, never your money: its amounts still count and still show on the balance sheet.';

  @override
  String get cardNeedsReview => 'Needs review';

  @override
  String get cardComingUp => 'Coming up';

  @override
  String get cardLeftToSpend => 'Left to spend';

  @override
  String get cardAccounts => 'Accounts';

  @override
  String get editHome => 'Edit Home';

  @override
  String get editHomeIntro =>
      'Move cards, or hide the ones you don\'t need. Qima never adds back a card you hid.';

  @override
  String get editHomeTotalFixed =>
      'Always first: the balance sheet opens from it';

  @override
  String get editHomeCantHide => 'Shows only when something needs you';

  @override
  String get moveUp => 'Move up';

  @override
  String get moveDown => 'Move down';

  @override
  String get moveToTop => 'Move to top';

  @override
  String get startTitle => 'Start with what you have';

  @override
  String get startMessage =>
      'Add a bank account, a holding or a property. Qima adds them up into your net worth.';

  @override
  String holdingsGainLine(String amount) {
    return 'Gain $amount';
  }

  @override
  String reviewValue(String name) {
    return 'Review the value of $name';
  }

  @override
  String get accountAdd => 'Add an account';

  @override
  String get accountEdit => 'Edit account';

  @override
  String get accountNameLabel => 'Name';

  @override
  String get accountCurrency => 'Currency';

  @override
  String get accountBalanceToday => 'Balance today';

  @override
  String get accountOwedToday => 'Owed on it today';

  @override
  String get accountLoanLeft => 'Left to pay (principal)';

  @override
  String get accountTheyOwe => 'They owe you';

  @override
  String get accountYouOwe => 'You owe them';

  @override
  String get accountBalanceHelp =>
      'Qima starts from this figure; leave it empty for zero.';

  @override
  String get accountSince => 'As of';

  @override
  String get accountLimit => 'Card limit';

  @override
  String get accountCounts => 'Count in net worth';

  @override
  String get accountCountsHelp =>
      'Off leaves it out of the total; its history still adds up.';

  @override
  String get accountErrorName => 'Give it a name.';

  @override
  String get accountLeftOut => 'Not counted in net worth';

  @override
  String accountAvailable(String amount) {
    return '$amount available';
  }

  @override
  String get accountCountCash => 'Count cash';

  @override
  String get accountCheckBalance => 'Check the balance';

  @override
  String get accountPayCard => 'Pay the card';

  @override
  String get accountPayLoan => 'Pay the loan';

  @override
  String get accountRemoveTitle => 'Remove account';

  @override
  String get accountRemoveMessage =>
      'An account with transactions is archived so its history still adds up. One never used is deleted.';

  @override
  String get accountsEmptyTitle => 'No accounts yet';

  @override
  String get accountsEmptyMessage =>
      'Add a bank account, cash, a card or a loan with what\'s in it today.';

  @override
  String reconcileTracked(String amount) {
    return 'Qima has $amount.';
  }

  @override
  String get reconcileCounted => 'What you counted';

  @override
  String get reconcileStatement => 'Balance on the statement or app';

  @override
  String get reconcileDone =>
      'The difference is recorded under Other, so the balance matches.';

  @override
  String get entryAmount => 'Amount';

  @override
  String get entryPrincipal => 'Principal';

  @override
  String get entryProfit => 'Profit or interest';

  @override
  String get entryProfitHelp =>
      'Counts as spending in Interest & fees; the principal never does.';

  @override
  String get entrySent => 'Sent';

  @override
  String get entryReceived => 'Received';

  @override
  String get entryPaidFrom => 'Paid from';

  @override
  String get entryFrom => 'From';

  @override
  String get entryTo => 'To';

  @override
  String get entryPerson => 'Person';

  @override
  String get entryCategory => 'Category';

  @override
  String get entryDate => 'Date';

  @override
  String get entryMerchant => 'Where';

  @override
  String get entryNote => 'Note';

  @override
  String get entryDeclined => 'Declined';

  @override
  String get entryDeclinedHelp => 'Shown struck through; never in a balance.';

  @override
  String get entryEditTitle => 'Edit transaction';

  @override
  String get entryDeleteTitle => 'Delete transaction?';

  @override
  String get entryDeleteMessage =>
      'Every account it touched goes back to what it was before.';

  @override
  String get entryErrorAmount => 'Enter an amount above zero.';

  @override
  String get entryErrorAccount => 'Choose the accounts.';

  @override
  String get entryErrorSameCurrency =>
      'Both accounts need the same currency. For different currencies, use Currency swap.';

  @override
  String get entryErrorSwap => 'Choose two accounts in different currencies.';

  @override
  String get entryErrorPerson => 'Enter who it is.';

  @override
  String get entryErrorRate =>
      'There\'s no exchange rate for this currency yet. Try again once prices refresh.';

  @override
  String get entryNeedsAccountTitle => 'Add an account first';

  @override
  String get entryNeedsAccountMessage =>
      'This needs an account to come from or go to. Add one in Accounts.';

  @override
  String get howItAddsUp => 'How it adds up';

  @override
  String hiuUp(String name, String amount) {
    return '$name up by $amount';
  }

  @override
  String hiuDown(String name, String amount) {
    return '$name down by $amount';
  }

  @override
  String get hiuSpending => 'Spending: it counts in your budget.';

  @override
  String get hiuIncome => 'Income: it counts in your cash flow.';

  @override
  String get hiuRefund => 'A refund lowers spending in its category.';

  @override
  String get hiuWorth =>
      'A change in value moves net worth only; it\'s never income or spending.';

  @override
  String get hiuMove =>
      'A move between your own accounts: not spending, and your net worth stays the same.';

  @override
  String get hiuDeclined => 'Declined: nothing moved.';

  @override
  String get allTransactions => 'All transactions';

  @override
  String get transactionsSearch => 'Search';

  @override
  String get transactionsEmptyTitle => 'No transactions';

  @override
  String get transactionsEmptyMessage => 'Add one with the + button.';

  @override
  String get moneySpent => 'Spent';

  @override
  String moneySpentOf(String spent, String budget) {
    return '$spent of $budget';
  }

  @override
  String moneySpentSoFar(String amount) {
    return 'Spent $amount this month';
  }

  @override
  String moneyPace(String amount) {
    return 'At this pace: $amount by the month\'s end';
  }

  @override
  String get moneyNothingSpent => 'Nothing spent this month.';

  @override
  String get moneyIn => 'Money in';

  @override
  String get moneyOut => 'Money out';

  @override
  String get moneyLeftOver => 'Left over';

  @override
  String get moneyShort => 'Short';

  @override
  String get moneyTrend => 'Spending by month';

  @override
  String get moneyTransactions => 'Transactions';

  @override
  String get moneyStartMessage =>
      'Add an account first, then record what you spend.';

  @override
  String get whereItWent => 'Where it went';

  @override
  String get cashFlow => 'Cash flow';

  @override
  String get worthALook => 'Worth a look';

  @override
  String aheadOfPace(String name) {
    return '$name is ahead of its budget';
  }

  @override
  String spareIn(String name, String amount) {
    return '$name has $amount to spare';
  }

  @override
  String get previousMonth => 'Previous month';

  @override
  String get nextMonth => 'Next month';

  @override
  String get ask => 'Ask';

  @override
  String get askSpentMonth => 'How much did I spend this month?';

  @override
  String askSpentMonthAnswer(String amount) {
    return '$amount';
  }

  @override
  String get askTopCategory => 'Where did most of it go?';

  @override
  String askTopCategoryAnswer(String name, String amount) {
    return '$name: $amount';
  }

  @override
  String get askVsLastMonth => 'Is it more than last month?';

  @override
  String askMore(String amount) {
    return '$amount more than last month';
  }

  @override
  String askLess(String amount) {
    return '$amount less than last month';
  }

  @override
  String get askSame => 'About the same as last month';

  @override
  String get askOwed => 'Who owes me money?';

  @override
  String get askNobodyOwes => 'Nobody owes you money.';

  @override
  String get assetAdd => 'Add an asset';

  @override
  String get assetEdit => 'Edit asset';

  @override
  String get assetGoldNote =>
      'Gold and silver by weight stay holdings, because Qima prices them. Add them with Add a holding.';

  @override
  String get assetValueToday => 'Value today';

  @override
  String get assetCost => 'Price paid';

  @override
  String get assetBought => 'Date bought';

  @override
  String get optional => 'Optional';

  @override
  String get assetLoan => 'Loan secured on it';

  @override
  String get assetNoLoan => 'None';

  @override
  String get assetForSale => 'Held for sale';

  @override
  String get assetForSaleHelp =>
      'Counts for zakat at its value. Off for things you use.';

  @override
  String get assetErrorValue => 'Enter today\'s value.';

  @override
  String get assetsTotal => 'Total value';

  @override
  String get assetsTotalHelp => 'Values you set yourself, each with its date';

  @override
  String get assetsEmptyTitle => 'No assets yet';

  @override
  String get assetsEmptyMessage =>
      'Add a home, land, a car or a share in a business. You set the value; Qima keeps its history.';

  @override
  String assetUpdated(String date) {
    return 'Updated $date';
  }

  @override
  String assetSinceBought(String amount) {
    return '$amount since bought';
  }

  @override
  String get assetUpdateValue => 'Update the value';

  @override
  String get assetUpdateHelp =>
      'Every update is dated. The latest counts; older values stay as history.';

  @override
  String get assetNewValue => 'New value';

  @override
  String get assetValueSource => 'Where the value comes from';

  @override
  String get assetSold => 'Sold it';

  @override
  String assetSellTitle(String name) {
    return 'Sell $name';
  }

  @override
  String assetLastValue(String amount) {
    return 'Last value: $amount';
  }

  @override
  String get assetSoldInto => 'Money went into';

  @override
  String get assetSoldFor => 'Sold for';

  @override
  String assetGain(String amount) {
    return 'Gain of $amount';
  }

  @override
  String assetLoss(String amount) {
    return 'Loss of $amount';
  }

  @override
  String get assetGainHelp =>
      'Compared with the last value. It\'s a change in value, never income.';

  @override
  String assetPayOff(String name) {
    return 'The sale paid off $name';
  }

  @override
  String assetPayOffHelp(String amount) {
    return '$amount still owed, paid from the same account';
  }

  @override
  String get assetYours => 'What is yours';

  @override
  String get assetValue => 'Value';

  @override
  String assetStillOwed(String name) {
    return 'Still owed on $name';
  }

  @override
  String get assetYoursTotal => 'Yours';

  @override
  String get assetYoursHelp =>
      'The balance sheet still lists the asset under what you own and the loan under what you owe.';

  @override
  String get assetHistory => 'History';

  @override
  String get assetRemoveTitle => 'Remove asset';

  @override
  String get assetRemoveMessage =>
      'To record a sale, use Sold it instead. Removing archives it with its history.';

  @override
  String get howTotalWorked => 'How the total is worked out';

  @override
  String get howTotalIntro => 'Net worth is what you own minus what you owe.';

  @override
  String get howTotalHoldings =>
      'Holdings use live prices, as on the watchlist.';

  @override
  String get howTotalAssets =>
      'Assets you value yourself use their latest value, with its date; each can be left out.';

  @override
  String get howTotalLoans =>
      'Loans count principal only; future profit isn\'t a debt until it falls due.';

  @override
  String get howTotalRates => 'Other currencies use the live rate.';

  @override
  String sheetAccountsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count accounts',
      one: '1 account',
      zero: 'No accounts',
    );
    return '$_temp0';
  }

  @override
  String budgetFor(String name) {
    return 'Budget for $name';
  }

  @override
  String get budgetIntro =>
      'Set a monthly amount for the categories you want to watch. Card payments, transfers and loan principal never count.';

  @override
  String get budgetMonthly => 'Each month';

  @override
  String get budgetZeroHelp => 'Zero removes it.';

  @override
  String get budgetNone => 'No budget';

  @override
  String budgetOf(String amount) {
    return 'Budget $amount';
  }

  @override
  String get budgetSet => 'Set a budget';

  @override
  String get budgetTotal => 'This month\'s budget';

  @override
  String get recurringAdd => 'Add a recurring payment';

  @override
  String get recurringDay => 'Day of the month';

  @override
  String get recurringEmptyTitle => 'No recurring payments';

  @override
  String get recurringEmptyMessage =>
      'Add rent, bills and subscriptions to see them in Coming up before they\'re due.';

  @override
  String recurringNext(String date) {
    return 'Next $date';
  }

  @override
  String recurringRecord(String name, String date) {
    return 'Record $name for $date';
  }

  @override
  String get peopleEmptyTitle => 'Nobody yet';

  @override
  String get peopleEmptyMessage =>
      'Record money you lend or borrow, and the repayments.';

  @override
  String get splitTotal => 'Bill total';

  @override
  String get splitWho => 'Who else shared it';

  @override
  String get splitShare => 'Share';

  @override
  String get splitAddPerson => 'Add a person';

  @override
  String get splitEvenly => 'Split evenly';

  @override
  String get splitMine => 'Your share (spending)';

  @override
  String get splitOwedToYou => 'Owed to you';

  @override
  String get splitHelp =>
      'The full amount leaves the account; only your share is spending, and each other share becomes money owed to you.';

  @override
  String get splitErrorPerson => 'Each person needs a name and a share.';

  @override
  String get splitErrorShares =>
      'Add at least one person, with shares no more than the total.';

  @override
  String get categoriesTitle => 'Categories';

  @override
  String get categoriesSpending => 'Spending';

  @override
  String get categoriesIncome => 'Income';

  @override
  String get categoryRename => 'Rename category';

  @override
  String get categoryRemove => 'Remove category';

  @override
  String get categoryRemoveMessage =>
      'Transactions in it keep it in their history.';

  @override
  String get categoryAddSpending => 'New spending category';

  @override
  String get categoryAddIncome => 'New income category';

  @override
  String get valueReview => 'Review asset values';

  @override
  String get valueReviewHelp => 'A reminder in Needs review';

  @override
  String get valueReviewOff => 'Off';

  @override
  String valueReviewMonths(int months) {
    String _temp0 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: 'Every $months months',
      one: 'Every month',
    );
    return '$_temp0';
  }

  @override
  String get addSheetTransaction => 'Transaction';

  @override
  String get addSheetTransactionSubtitle => 'Money spent, earned or moved';

  @override
  String get entryVoiceTitle => 'Say it instead of typing';

  @override
  String get entryVoiceListening => 'Listening… tap to stop';

  @override
  String get entryVoiceHint =>
      'Say what happened, like “Spent 45 at Panda with Visa yesterday”';

  @override
  String get entryVoiceNothing =>
      'Didn’t catch an amount or a name. Try again, or type it.';

  @override
  String get entryNewTitle => 'New transaction';

  @override
  String get addSheetMore => 'More';

  @override
  String get addSheetMoreSubtitle =>
      'Income, transfers, loans, lending, accounts, assets';

  @override
  String get whatsNewTitle => 'What\'s new in Qima';

  @override
  String get whatsNewTabs =>
      'Three tabs: Home for where you stand, Money for where it goes, Prices for the market.';

  @override
  String get whatsNewBalanceSheet =>
      'Your holdings, accounts, cards and loans add up on one balance sheet. Tap the total to see it.';

  @override
  String get whatsNewAssets =>
      'Add property, a car or a business and update its value yourself.';

  @override
  String get whatsNewPick => 'What would you like to use?';

  @override
  String get whatsNewLater =>
      'You can change these any time in Settings › Features.';

  @override
  String get zakatDueTitle => 'Zakat due';

  @override
  String zakatDueLine(String amount) {
    return '$amount due';
  }

  @override
  String get zakatBelowLine => 'Below the nisab';

  @override
  String zakatBaseLine(String amount) {
    return 'Counted: $amount';
  }

  @override
  String zakatAbove(String amount) {
    return 'Above the nisab of $amount';
  }

  @override
  String zakatBelow(String amount) {
    return 'Below the nisab of $amount';
  }

  @override
  String get zakatNoThreshold =>
      'The nisab is shown once gold and silver prices load.';

  @override
  String get zakatBase => 'Counted for zakat';

  @override
  String get zakatHeldForSale => 'Assets held for sale';

  @override
  String get zakatDebtsDue => 'Debts due now';

  @override
  String get zakatBookHelp =>
      'Holdings follow your zakat settings. Card balances and money you owe people are deducted; loans aren\'t, because only an instalment due now would be, and Qima doesn\'t know a loan\'s schedule.';

  @override
  String get zakatHoldingsDetail => 'Holdings in detail';

  @override
  String get importStatement => 'Import a statement';

  @override
  String get importStatementSubtitle =>
      'PDF, Excel, CSV or screenshots from your bank';

  @override
  String get importFromFiles => 'From Files';

  @override
  String get importFromFilesHint => 'Statements as PDF, Excel or CSV';

  @override
  String get importFromPhotos => 'Screenshots from Photos';

  @override
  String get importFromPhotosHint => 'Your banking app\'s transactions';

  @override
  String get importFromClipboard => 'From the clipboard';

  @override
  String get importFromClipboardHint =>
      'A copied statement, receipt, bank message or screenshot';

  @override
  String get importPastedName => 'Pasted';

  @override
  String get importShareTip => 'You can also share files to Qima from any app.';

  @override
  String importReadingFiles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Reading $count files…',
      one: 'Reading 1 file…',
    );
    return '$_temp0';
  }

  @override
  String importReadyRows(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transactions to review',
      one: '1 transaction to review',
      zero: 'Nothing found to add',
    );
    return '$_temp0';
  }

  @override
  String get importReadyBalance => 'A balance to check';

  @override
  String get bankMessagesTitle => 'Bank text messages';

  @override
  String get bankMessagesEntry => 'Bank text messages';

  @override
  String get bankMessagesEntryHint => 'Add purchases from your bank’s messages';

  @override
  String get bankMessagesIntro =>
      'Your bank texts you each purchase, transfer and salary. Qima can read those messages and suggest them as transactions. You check each one before it’s added.';

  @override
  String get bankMessagesRead => 'Read new bank messages';

  @override
  String get bankMessagesReadHint =>
      'Only messages with an amount. Codes and personal messages are skipped.';

  @override
  String get bankMessagesRecent => 'Bring in the last 60 days';

  @override
  String get bankMessagesRecentHint => 'Messages already in Qima are skipped';

  @override
  String get bankMessagesDenied =>
      'Qima needs permission to read messages. You can allow it in Settings.';

  @override
  String get bankMessagesSetUp => 'Set it up once in Shortcuts';

  @override
  String get bankMessagesStep1 =>
      'Open Shortcuts, go to Automation and tap +, then choose Message.';

  @override
  String get bankMessagesStep2 =>
      'Pick your bank as the sender, or a word its messages always have, such as SAR.';

  @override
  String get bankMessagesStep3 => 'Choose Run Immediately.';

  @override
  String get bankMessagesStep4 =>
      'Add Qima’s “Add a bank message” action and pass it the message.';

  @override
  String get bankMessagesOpenShortcuts => 'Open Shortcuts';

  @override
  String get bankMessagesUnavailable =>
      'Bank messages can be added on iPhone and Android.';

  @override
  String get bankMessagesPrivacy =>
      'Messages are read on this device and never leave it.';

  @override
  String bankMessagesFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bank messages to check',
      one: '1 bank message to check',
      zero: 'No bank messages found',
    );
    return '$_temp0';
  }

  @override
  String get importBannerTitle => 'Shared to Qima';

  @override
  String get importReviewTitle => 'Review import';

  @override
  String get importIntoAccount => 'Statement of';

  @override
  String get importNoAccountTitle => 'Add the account first';

  @override
  String get importNoAccountBody =>
      'Add the bank account or card this statement is from, then come back here.';

  @override
  String importAddCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Add $count transactions',
      one: 'Add 1 transaction',
      zero: 'Add',
    );
    return '$_temp0';
  }

  @override
  String importAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transactions added',
      one: '1 transaction added',
    );
    return '$_temp0';
  }

  @override
  String get importDiscardAll => 'Discard all';

  @override
  String get importApplyBalance => 'Apply the balance';

  @override
  String get importDiscardConfirm =>
      'Discard these files? Nothing from them is added.';

  @override
  String get importDiscard => 'Discard';

  @override
  String get importRemoveFile => 'Remove file';

  @override
  String get importFlagInBook => 'Already in Qima';

  @override
  String get importFlagRepeated => 'Also in another file';

  @override
  String importFlagCurrency(String currency) {
    return 'In $currency, not the account\'s currency';
  }

  @override
  String get importDateGuessed => 'No date found: set to the day it was shared';

  @override
  String get importSignGuessed => 'Check: in or out?';

  @override
  String get importFlagNotTransaction =>
      'Looks like the bank\'s own text, not a transaction';

  @override
  String importRefCard(String last4) {
    return 'Card •••• $last4';
  }

  @override
  String importRefAccount(String last4) {
    return 'Account •••• $last4';
  }

  @override
  String importRefIban(String last4) {
    return 'IBAN •••• $last4';
  }

  @override
  String importBalances(String opening, String closing) {
    return 'Opening $opening → closing $closing';
  }

  @override
  String get importAddsUp => 'Adds up: nothing missed';

  @override
  String importGap(String amount) {
    return '$amount not accounted for: check for a missed row';
  }

  @override
  String importOpeningBalance(String amount) {
    return 'Add the opening balance: $amount';
  }

  @override
  String importMatchBalance(String amount) {
    return 'Bring the balance to $amount';
  }

  @override
  String importBalanceDetail(String date, String tracked) {
    return 'As the statement shows on $date. Without it, Qima would have $tracked.';
  }

  @override
  String get importStatusReading => 'Reading…';

  @override
  String get importStatusWaiting => 'Waiting';

  @override
  String get importStatusAlready => 'Imported before';

  @override
  String get importStatusUnsupported => 'Qima can\'t read this kind of file';

  @override
  String get importStatusUnreadable => 'Couldn\'t read this file';

  @override
  String get importStatusNothing => 'No transactions found in this file';

  @override
  String importRowFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count found',
      one: '1 found',
    );
    return '$_temp0';
  }

  @override
  String get importEditRow => 'Transaction';

  @override
  String get importCategory => 'Category';

  @override
  String get importNothingSelected => 'Tick the transactions to add.';

  @override
  String get importReadOnDevice =>
      'Read on this device. Files are deleted once imported.';

  @override
  String get importEmpty => 'Nothing waiting';

  @override
  String get catUncategorized => 'Uncategorized';

  @override
  String get catUncategorizedIncome => 'Uncategorized income';

  @override
  String get toCategorizeTitle => 'To categorize';

  @override
  String toCategorizeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count to categorize',
      one: '1 to categorize',
    );
    return '$_temp0';
  }

  @override
  String get toCategorizeHint =>
      'Pick a category once for each name. Imports from that name use it from now on.';

  @override
  String get toCategorizeEmpty => 'Everything has a category.';

  @override
  String toCategorizeAlso(
    int count,
    String name,
    String category,
    String from,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Also put $count earlier entries from $name in $category? They are in $from now.',
      one:
          'Also put 1 earlier entry from $name in $category? It is in $from now.',
    );
    return '$_temp0';
  }

  @override
  String get toCategorizeAlsoYes => 'Move them';

  @override
  String get categoriesLearned => 'Learned from your choices';

  @override
  String get categoriesForgetTitle => 'Forget this choice?';

  @override
  String categoriesForgetMessage(String name, String category) {
    return 'Imports from $name will no longer go to $category on their own. Entries already there stay.';
  }

  @override
  String get categoriesForget => 'Forget';

  @override
  String get marketClosed => 'Closed';

  @override
  String marketClosedOpens(String time) {
    return 'Market closed · opens $time';
  }

  @override
  String marketOpenCloses(String time) {
    return 'Market open · closes $time';
  }

  @override
  String get marketClosedLong => 'Market closed';

  @override
  String holdingsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count holdings',
      one: '1 holding',
    );
    return '$_temp0';
  }

  @override
  String pricesAt(String time) {
    return 'prices $time';
  }

  @override
  String get balanceWayTransaction => 'Add a transaction';

  @override
  String balanceWayTransactionDetail(String other) {
    return 'The difference counts as spending or income in $other';
  }

  @override
  String get balanceWayOpening => 'Change the opening balance';

  @override
  String get balanceWayOpeningDetail =>
      'From its first day, not as spending or income';

  @override
  String get netLabel => 'Net';
}
