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
  String get watchlistAdd => 'Add instrument';

  @override
  String get watchlistEmptyTitle => 'Your watchlist is empty';

  @override
  String get watchlistEmptyMessage =>
      'Add metals, crypto, stocks, or currencies to start tracking prices.';

  @override
  String get watchlistFilterAll => 'All';

  @override
  String get addTitle => 'Add instrument';

  @override
  String get addSearchHint => 'Search instruments';

  @override
  String addSearchCustomTickerTitle(String query) {
    return 'Add “$query” as a custom ticker';
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
      'Add your first lot to start tracking this holding.';

  @override
  String get holdingsValue => 'Value';

  @override
  String get holdingsCost => 'Cost';

  @override
  String get holdingsGain => 'Gain';

  @override
  String get holdingsGainPercent => 'Gain %';

  @override
  String get holdingsNew => 'New lot';

  @override
  String get holdingsEdit => 'Edit lot';

  @override
  String get holdingsQuantity => 'Quantity';

  @override
  String get holdingsCostModePerUnit => 'Per unit';

  @override
  String get holdingsCostModeTotal => 'Total';

  @override
  String get holdingsUnitCost => 'Unit cost';

  @override
  String holdingsUnitCostWithUnit(String unit) {
    return 'Unit cost (per $unit)';
  }

  @override
  String holdingsUnitCostWithKarat(String unit, String karat) {
    return 'Unit cost (per $unit · $karat)';
  }

  @override
  String holdingsUnitCostPreview(String value) {
    return 'Per unit: $value';
  }

  @override
  String get holdingsTotalCost => 'Total cost';

  @override
  String holdingsTotalCostPreview(String value) {
    return 'Total: $value';
  }

  @override
  String get holdingsDate => 'Date';

  @override
  String get holdingsSave => 'Save';

  @override
  String get holdingsTotalHeld => 'Total held';

  @override
  String get holdingsAverageCost => 'Average cost';

  @override
  String holdingsAverageCostPerUnit(String value, String unit) {
    return '$value per $unit';
  }

  @override
  String holdingsAverageCostPerUnitKarat(
    String value,
    String unit,
    String karat,
  ) {
    return '$value per $unit · $karat';
  }

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
      'No portfolio value yet — add a holding lot to get started.';

  @override
  String get portfolioNoChange => 'Not enough history for this range yet';

  @override
  String get portfolioNoHistory =>
      'Add a holding lot to see your portfolio chart';

  @override
  String portfolioLotCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lots',
      one: '1 lot',
    );
    return '$_temp0';
  }

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
      'Used when opening an instrument for the first time.';

  @override
  String get settingsWidgetRefresh => 'Widget refresh interval';

  @override
  String get settingsWidgetRefreshFooter =>
      'How often background widgets fetch new prices.';

  @override
  String get settingsAbout => 'About';

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
      'Mask portfolio, holdings and lot amounts throughout the app.';

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
      'Your holdings for this instrument are kept.';

  @override
  String get confirmDeleteLotTitle => 'Delete this lot?';

  @override
  String confirmDeleteLotMessage(String details) {
    return '$details. This can\'t be undone.';
  }

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
  String get alertsCardEmpty => 'No alerts yet for this instrument.';

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
  String get alertsScreenInfo =>
      'Alerts are checked roughly every 15 minutes in the background, and live while Qima is open.';

  @override
  String get alertsScreenEmptyTitle => 'No alerts yet';

  @override
  String get alertsScreenEmptyMessage =>
      'Open an instrument and tap the bell to set a price alert.';

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
  String settingsBackupSubtitle(String date, int instruments, int lots) {
    return 'Last backup $date · $instruments instruments, $lots lots';
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
      'Your lots as a spreadsheet, for your records (.csv)';

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
    int lots,
    int customTickers,
  ) {
    return '$cards watchlist cards · $lots lots · $customTickers custom tickers';
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
  String get backupImportCountLots => 'Lots';

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
      'A holdings spreadsheet (.csv) only has your lots, and can\'t be restored. Choose a full backup file (.json) instead.';

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
  String get backupCsvHeaderInstrument => 'Instrument';

  @override
  String get backupCsvHeaderSymbol => 'Symbol';

  @override
  String get backupCsvHeaderQuantity => 'Quantity';

  @override
  String get backupCsvHeaderUnit => 'Unit';

  @override
  String get backupCsvHeaderKarat => 'Karat';

  @override
  String get backupCsvHeaderUnitCost => 'Unit cost';

  @override
  String get backupCsvHeaderCostCurrency => 'Cost currency';

  @override
  String get backupCsvHeaderTotalCost => 'Total cost';

  @override
  String get backupCsvHeaderDate => 'Date';

  @override
  String get commonContinue => 'Continue';
}
