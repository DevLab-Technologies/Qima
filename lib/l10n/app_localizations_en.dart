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
}
