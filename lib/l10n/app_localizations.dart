import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
  ];

  /// App name shown in the OS and the root navigation bar.
  ///
  /// In en, this message translates to:
  /// **'Qima'**
  String get appTitle;

  /// Bottom navigation / navigation rail label for the watchlist tab.
  ///
  /// In en, this message translates to:
  /// **'Watchlist'**
  String get navWatchlist;

  /// No description provided for @watchlistAdd.
  ///
  /// In en, this message translates to:
  /// **'Add instrument'**
  String get watchlistAdd;

  /// No description provided for @watchlistEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your watchlist is empty'**
  String get watchlistEmptyTitle;

  /// No description provided for @watchlistEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Add metals, crypto, stocks, or currencies to start tracking prices.'**
  String get watchlistEmptyMessage;

  /// No description provided for @watchlistFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get watchlistFilterAll;

  /// No description provided for @addTitle.
  ///
  /// In en, this message translates to:
  /// **'Add instrument'**
  String get addTitle;

  /// No description provided for @addSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search instruments'**
  String get addSearchHint;

  /// No description provided for @addSearchCustomTickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Add “{query}” as a custom ticker'**
  String addSearchCustomTickerTitle(String query);

  /// No description provided for @addSearchCustomTickerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'For stocks, ETFs or indices not listed here'**
  String get addSearchCustomTickerSubtitle;

  /// No description provided for @addSearchNoResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'No matches for “{query}”'**
  String addSearchNoResultsTitle(String query);

  /// No description provided for @addSearchNoResultsMessage.
  ///
  /// In en, this message translates to:
  /// **'Nothing in the catalog matches that. You can still add it as a custom ticker.'**
  String get addSearchNoResultsMessage;

  /// No description provided for @addSearchNoResultsButton.
  ///
  /// In en, this message translates to:
  /// **'Add {query} as custom ticker'**
  String addSearchNoResultsButton(String query);

  /// No description provided for @addedToWatchlist.
  ///
  /// In en, this message translates to:
  /// **'{name} added to watchlist'**
  String addedToWatchlist(String name);

  /// No description provided for @alreadyInWatchlist.
  ///
  /// In en, this message translates to:
  /// **'{name} is already in your watchlist'**
  String alreadyInWatchlist(String name);

  /// No description provided for @addCustomTickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Add custom ticker'**
  String get addCustomTickerTitle;

  /// No description provided for @addCustomTickerSymbol.
  ///
  /// In en, this message translates to:
  /// **'Ticker symbol'**
  String get addCustomTickerSymbol;

  /// No description provided for @addCustomTickerName.
  ///
  /// In en, this message translates to:
  /// **'Display name (optional)'**
  String get addCustomTickerName;

  /// No description provided for @addCustomTickerHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. AAPL, TSLA, VOO'**
  String get addCustomTickerHint;

  /// No description provided for @addCustomTickerSymbolRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a ticker symbol.'**
  String get addCustomTickerSymbolRequired;

  /// No description provided for @addCustomTickerError.
  ///
  /// In en, this message translates to:
  /// **'Could not verify this ticker. Check the symbol and try again.'**
  String get addCustomTickerError;

  /// No description provided for @addCustomTickerSubmit.
  ///
  /// In en, this message translates to:
  /// **'Add ticker'**
  String get addCustomTickerSubmit;

  /// No description provided for @cardConfigAddToWatchlist.
  ///
  /// In en, this message translates to:
  /// **'Add to watchlist'**
  String get cardConfigAddToWatchlist;

  /// No description provided for @commonCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get commonCurrency;

  /// No description provided for @currencyPickerSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search currency'**
  String get currencyPickerSearchHint;

  /// No description provided for @detailHoldings.
  ///
  /// In en, this message translates to:
  /// **'Holdings'**
  String get detailHoldings;

  /// No description provided for @detailHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get detailHistory;

  /// No description provided for @detailLoadHistory.
  ///
  /// In en, this message translates to:
  /// **'Load history'**
  String get detailLoadHistory;

  /// No description provided for @detailNoHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'No history yet'**
  String get detailNoHistoryTitle;

  /// No description provided for @detailNoHistoryMessage.
  ///
  /// In en, this message translates to:
  /// **'Load history to see the full price chart.'**
  String get detailNoHistoryMessage;

  /// No description provided for @detailKeyStats.
  ///
  /// In en, this message translates to:
  /// **'Key stats'**
  String get detailKeyStats;

  /// No description provided for @detailPricePerUnit.
  ///
  /// In en, this message translates to:
  /// **'Price per unit'**
  String get detailPricePerUnit;

  /// No description provided for @detailUpdatedAt.
  ///
  /// In en, this message translates to:
  /// **'Updated {time}'**
  String detailUpdatedAt(String time);

  /// No description provided for @errorRefreshFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t refresh prices. Check your connection and try again.'**
  String get errorRefreshFailed;

  /// No description provided for @detailChangeCurrency.
  ///
  /// In en, this message translates to:
  /// **'Change currency'**
  String get detailChangeCurrency;

  /// No description provided for @detailShowPerUnit.
  ///
  /// In en, this message translates to:
  /// **'Show per {unit}'**
  String detailShowPerUnit(String unit);

  /// No description provided for @holdingsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Add your first lot to start tracking this holding.'**
  String get holdingsEmpty;

  /// No description provided for @holdingsValue.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get holdingsValue;

  /// No description provided for @holdingsCost.
  ///
  /// In en, this message translates to:
  /// **'Cost'**
  String get holdingsCost;

  /// No description provided for @holdingsGain.
  ///
  /// In en, this message translates to:
  /// **'Gain'**
  String get holdingsGain;

  /// No description provided for @holdingsGainPercent.
  ///
  /// In en, this message translates to:
  /// **'Gain %'**
  String get holdingsGainPercent;

  /// No description provided for @holdingsNew.
  ///
  /// In en, this message translates to:
  /// **'New lot'**
  String get holdingsNew;

  /// No description provided for @holdingsEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit lot'**
  String get holdingsEdit;

  /// No description provided for @holdingsQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get holdingsQuantity;

  /// No description provided for @holdingsCostModePerUnit.
  ///
  /// In en, this message translates to:
  /// **'Per unit'**
  String get holdingsCostModePerUnit;

  /// No description provided for @holdingsCostModeTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get holdingsCostModeTotal;

  /// No description provided for @holdingsUnitCost.
  ///
  /// In en, this message translates to:
  /// **'Unit cost'**
  String get holdingsUnitCost;

  /// No description provided for @holdingsUnitCostWithUnit.
  ///
  /// In en, this message translates to:
  /// **'Unit cost (per {unit})'**
  String holdingsUnitCostWithUnit(String unit);

  /// No description provided for @holdingsUnitCostWithKarat.
  ///
  /// In en, this message translates to:
  /// **'Unit cost (per {unit} · {karat})'**
  String holdingsUnitCostWithKarat(String unit, String karat);

  /// No description provided for @holdingsUnitCostPreview.
  ///
  /// In en, this message translates to:
  /// **'Per unit: {value}'**
  String holdingsUnitCostPreview(String value);

  /// No description provided for @holdingsTotalCost.
  ///
  /// In en, this message translates to:
  /// **'Total cost'**
  String get holdingsTotalCost;

  /// No description provided for @holdingsTotalCostPreview.
  ///
  /// In en, this message translates to:
  /// **'Total: {value}'**
  String holdingsTotalCostPreview(String value);

  /// No description provided for @holdingsDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get holdingsDate;

  /// No description provided for @holdingsSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get holdingsSave;

  /// No description provided for @holdingsTotalHeld.
  ///
  /// In en, this message translates to:
  /// **'Total held'**
  String get holdingsTotalHeld;

  /// No description provided for @holdingsAverageCost.
  ///
  /// In en, this message translates to:
  /// **'Average cost'**
  String get holdingsAverageCost;

  /// No description provided for @holdingsAverageCostPerUnit.
  ///
  /// In en, this message translates to:
  /// **'{value} per {unit}'**
  String holdingsAverageCostPerUnit(String value, String unit);

  /// No description provided for @holdingsAverageCostPerUnitKarat.
  ///
  /// In en, this message translates to:
  /// **'{value} per {unit} · {karat}'**
  String holdingsAverageCostPerUnitKarat(
    String value,
    String unit,
    String karat,
  );

  /// No description provided for @holdingsMixedNote.
  ///
  /// In en, this message translates to:
  /// **'Mixed karats counted by gold content, shown as {karat}.'**
  String holdingsMixedNote(String karat);

  /// No description provided for @holdingsMixedUnitsNote.
  ///
  /// In en, this message translates to:
  /// **'Mixed units counted by gold content.'**
  String get holdingsMixedUnitsNote;

  /// No description provided for @holdingsHeldLine.
  ///
  /// In en, this message translates to:
  /// **'Held {quantity} · avg {average}'**
  String holdingsHeldLine(String quantity, String average);

  /// No description provided for @portfolioTitle.
  ///
  /// In en, this message translates to:
  /// **'Portfolio'**
  String get portfolioTitle;

  /// No description provided for @portfolioValue.
  ///
  /// In en, this message translates to:
  /// **'Total value'**
  String get portfolioValue;

  /// No description provided for @portfolioEmpty.
  ///
  /// In en, this message translates to:
  /// **'No portfolio value yet — add a holding lot to get started.'**
  String get portfolioEmpty;

  /// No description provided for @portfolioNoChange.
  ///
  /// In en, this message translates to:
  /// **'Not enough history for this range yet'**
  String get portfolioNoChange;

  /// No description provided for @portfolioNoHistory.
  ///
  /// In en, this message translates to:
  /// **'Add a holding lot to see your portfolio chart'**
  String get portfolioNoHistory;

  /// No description provided for @portfolioLotCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 lot} other{{count} lots}}'**
  String portfolioLotCount(num count);

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsAppearanceSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsAppearanceSystem;

  /// No description provided for @settingsAppearanceLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsAppearanceLight;

  /// No description provided for @settingsAppearanceDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsAppearanceDark;

  /// No description provided for @settingsBaseCurrency.
  ///
  /// In en, this message translates to:
  /// **'Base currency'**
  String get settingsBaseCurrency;

  /// No description provided for @settingsPortfolioCurrency.
  ///
  /// In en, this message translates to:
  /// **'Portfolio currency'**
  String get settingsPortfolioCurrency;

  /// No description provided for @settingsUnit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get settingsUnit;

  /// No description provided for @settingsKarat.
  ///
  /// In en, this message translates to:
  /// **'Karat'**
  String get settingsKarat;

  /// No description provided for @settingsBaseCurrencyFooter.
  ///
  /// In en, this message translates to:
  /// **'Used to total your portfolio value.'**
  String get settingsBaseCurrencyFooter;

  /// No description provided for @settingsDefaultRange.
  ///
  /// In en, this message translates to:
  /// **'Default chart range'**
  String get settingsDefaultRange;

  /// No description provided for @settingsDefaultRangeFooter.
  ///
  /// In en, this message translates to:
  /// **'Used when opening an instrument for the first time.'**
  String get settingsDefaultRangeFooter;

  /// No description provided for @settingsWidgetRefresh.
  ///
  /// In en, this message translates to:
  /// **'Widget refresh interval'**
  String get settingsWidgetRefresh;

  /// No description provided for @settingsWidgetRefreshFooter.
  ///
  /// In en, this message translates to:
  /// **'How often background widgets fetch new prices.'**
  String get settingsWidgetRefreshFooter;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @settingsLanguageSystem.
  ///
  /// In en, this message translates to:
  /// **'Follow system'**
  String get settingsLanguageSystem;

  /// No description provided for @settingsDataSource.
  ///
  /// In en, this message translates to:
  /// **'finance.yahoo.com · gold-api.com · er-api.com'**
  String get settingsDataSource;

  /// No description provided for @settingsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy & security'**
  String get settingsPrivacy;

  /// No description provided for @settingsHideBalances.
  ///
  /// In en, this message translates to:
  /// **'Hide balances'**
  String get settingsHideBalances;

  /// No description provided for @settingsHideBalancesFooter.
  ///
  /// In en, this message translates to:
  /// **'Mask portfolio, holdings and lot amounts throughout the app.'**
  String get settingsHideBalancesFooter;

  /// No description provided for @settingsAppLock.
  ///
  /// In en, this message translates to:
  /// **'App lock'**
  String get settingsAppLock;

  /// No description provided for @settingsAppLockFooter.
  ///
  /// In en, this message translates to:
  /// **'Require Face ID, Touch ID or your device passcode to open Qima.'**
  String get settingsAppLockFooter;

  /// No description provided for @settingsAppLockUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Set up Face ID, Touch ID or a device passcode first.'**
  String get settingsAppLockUnavailable;

  /// No description provided for @settingsAppLockFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t verify it\'s you — app lock stays off.'**
  String get settingsAppLockFailed;

  /// No description provided for @settingsLockAfter.
  ///
  /// In en, this message translates to:
  /// **'Lock after'**
  String get settingsLockAfter;

  /// No description provided for @lockGraceImmediately.
  ///
  /// In en, this message translates to:
  /// **'Immediately'**
  String get lockGraceImmediately;

  /// No description provided for @lockGrace1m.
  ///
  /// In en, this message translates to:
  /// **'1 minute'**
  String get lockGrace1m;

  /// No description provided for @lockGrace5m.
  ///
  /// In en, this message translates to:
  /// **'5 minutes'**
  String get lockGrace5m;

  /// No description provided for @lockGrace15m.
  ///
  /// In en, this message translates to:
  /// **'15 minutes'**
  String get lockGrace15m;

  /// No description provided for @privacyHideBalances.
  ///
  /// In en, this message translates to:
  /// **'Hide balances'**
  String get privacyHideBalances;

  /// No description provided for @privacyShowBalances.
  ///
  /// In en, this message translates to:
  /// **'Show balances'**
  String get privacyShowBalances;

  /// No description provided for @appLockAuthReason.
  ///
  /// In en, this message translates to:
  /// **'Unlock Qima to see your portfolio'**
  String get appLockAuthReason;

  /// No description provided for @appLockLockedTitle.
  ///
  /// In en, this message translates to:
  /// **'Qima is locked'**
  String get appLockLockedTitle;

  /// No description provided for @appLockLockedMessage.
  ///
  /// In en, this message translates to:
  /// **'Unlock to see your portfolio and holdings.'**
  String get appLockLockedMessage;

  /// No description provided for @appLockUnlockFaceID.
  ///
  /// In en, this message translates to:
  /// **'Unlock with Face ID'**
  String get appLockUnlockFaceID;

  /// No description provided for @appLockUnlockTouchID.
  ///
  /// In en, this message translates to:
  /// **'Unlock with Touch ID'**
  String get appLockUnlockTouchID;

  /// No description provided for @appLockUnlockGeneric.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get appLockUnlockGeneric;

  /// No description provided for @appLockUseDevicePasscode.
  ///
  /// In en, this message translates to:
  /// **'Use device passcode'**
  String get appLockUseDevicePasscode;

  /// No description provided for @statChange.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get statChange;

  /// No description provided for @statHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get statHigh;

  /// No description provided for @statLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get statLow;

  /// No description provided for @statPoints.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get statPoints;

  /// No description provided for @pricePullToRefresh.
  ///
  /// In en, this message translates to:
  /// **'Pull to refresh'**
  String get pricePullToRefresh;

  /// No description provided for @assetClassMetal.
  ///
  /// In en, this message translates to:
  /// **'Metals'**
  String get assetClassMetal;

  /// No description provided for @assetClassCrypto.
  ///
  /// In en, this message translates to:
  /// **'Crypto'**
  String get assetClassCrypto;

  /// No description provided for @assetClassStock.
  ///
  /// In en, this message translates to:
  /// **'Stocks'**
  String get assetClassStock;

  /// No description provided for @assetClassIndex.
  ///
  /// In en, this message translates to:
  /// **'Indices'**
  String get assetClassIndex;

  /// No description provided for @assetClassFiat.
  ///
  /// In en, this message translates to:
  /// **'Currencies'**
  String get assetClassFiat;

  /// No description provided for @assetGold.
  ///
  /// In en, this message translates to:
  /// **'Gold'**
  String get assetGold;

  /// No description provided for @assetSilver.
  ///
  /// In en, this message translates to:
  /// **'Silver'**
  String get assetSilver;

  /// No description provided for @assetPlatinum.
  ///
  /// In en, this message translates to:
  /// **'Platinum'**
  String get assetPlatinum;

  /// No description provided for @assetPalladium.
  ///
  /// In en, this message translates to:
  /// **'Palladium'**
  String get assetPalladium;

  /// No description provided for @assetBitcoin.
  ///
  /// In en, this message translates to:
  /// **'Bitcoin'**
  String get assetBitcoin;

  /// No description provided for @assetEthereum.
  ///
  /// In en, this message translates to:
  /// **'Ethereum'**
  String get assetEthereum;

  /// No description provided for @assetApple.
  ///
  /// In en, this message translates to:
  /// **'Apple'**
  String get assetApple;

  /// No description provided for @assetMicrosoft.
  ///
  /// In en, this message translates to:
  /// **'Microsoft'**
  String get assetMicrosoft;

  /// No description provided for @assetNvidia.
  ///
  /// In en, this message translates to:
  /// **'Nvidia'**
  String get assetNvidia;

  /// No description provided for @assetAmazon.
  ///
  /// In en, this message translates to:
  /// **'Amazon'**
  String get assetAmazon;

  /// No description provided for @assetTesla.
  ///
  /// In en, this message translates to:
  /// **'Tesla'**
  String get assetTesla;

  /// No description provided for @assetAlphabet.
  ///
  /// In en, this message translates to:
  /// **'Alphabet'**
  String get assetAlphabet;

  /// No description provided for @assetSp500.
  ///
  /// In en, this message translates to:
  /// **'S&P 500'**
  String get assetSp500;

  /// No description provided for @assetDowJones.
  ///
  /// In en, this message translates to:
  /// **'Dow Jones'**
  String get assetDowJones;

  /// No description provided for @assetNasdaq.
  ///
  /// In en, this message translates to:
  /// **'Nasdaq'**
  String get assetNasdaq;

  /// No description provided for @assetRussell2000.
  ///
  /// In en, this message translates to:
  /// **'Russell 2000'**
  String get assetRussell2000;

  /// No description provided for @assetFtse100.
  ///
  /// In en, this message translates to:
  /// **'FTSE 100'**
  String get assetFtse100;

  /// No description provided for @assetNikkei225.
  ///
  /// In en, this message translates to:
  /// **'Nikkei 225'**
  String get assetNikkei225;

  /// No description provided for @assetDax.
  ///
  /// In en, this message translates to:
  /// **'DAX'**
  String get assetDax;

  /// No description provided for @assetUsDollar.
  ///
  /// In en, this message translates to:
  /// **'US Dollar'**
  String get assetUsDollar;

  /// No description provided for @assetEuro.
  ///
  /// In en, this message translates to:
  /// **'Euro'**
  String get assetEuro;

  /// No description provided for @assetBritishPound.
  ///
  /// In en, this message translates to:
  /// **'British Pound'**
  String get assetBritishPound;

  /// No description provided for @assetEgyptianPound.
  ///
  /// In en, this message translates to:
  /// **'Egyptian Pound'**
  String get assetEgyptianPound;

  /// No description provided for @assetSaudiRiyal.
  ///
  /// In en, this message translates to:
  /// **'Saudi Riyal'**
  String get assetSaudiRiyal;

  /// No description provided for @assetEmiratiDirham.
  ///
  /// In en, this message translates to:
  /// **'Emirati Dirham'**
  String get assetEmiratiDirham;

  /// No description provided for @assetQatariRiyal.
  ///
  /// In en, this message translates to:
  /// **'Qatari Riyal'**
  String get assetQatariRiyal;

  /// No description provided for @assetKuwaitiDinar.
  ///
  /// In en, this message translates to:
  /// **'Kuwaiti Dinar'**
  String get assetKuwaitiDinar;

  /// No description provided for @assetOmaniRial.
  ///
  /// In en, this message translates to:
  /// **'Omani Rial'**
  String get assetOmaniRial;

  /// No description provided for @assetBahrainiDinar.
  ///
  /// In en, this message translates to:
  /// **'Bahraini Dinar'**
  String get assetBahrainiDinar;

  /// No description provided for @assetJordanianDinar.
  ///
  /// In en, this message translates to:
  /// **'Jordanian Dinar'**
  String get assetJordanianDinar;

  /// No description provided for @unitTroyOunce.
  ///
  /// In en, this message translates to:
  /// **'Troy ounce'**
  String get unitTroyOunce;

  /// No description provided for @unitGram.
  ///
  /// In en, this message translates to:
  /// **'Gram'**
  String get unitGram;

  /// No description provided for @unitKilogram.
  ///
  /// In en, this message translates to:
  /// **'Kilogram'**
  String get unitKilogram;

  /// No description provided for @unitEach.
  ///
  /// In en, this message translates to:
  /// **'Each'**
  String get unitEach;

  /// No description provided for @unitAbbrTroyOunce.
  ///
  /// In en, this message translates to:
  /// **'oz t'**
  String get unitAbbrTroyOunce;

  /// No description provided for @unitAbbrGram.
  ///
  /// In en, this message translates to:
  /// **'g'**
  String get unitAbbrGram;

  /// No description provided for @unitAbbrKilogram.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get unitAbbrKilogram;

  /// No description provided for @karatShort24.
  ///
  /// In en, this message translates to:
  /// **'24K'**
  String get karatShort24;

  /// No description provided for @karatShort22.
  ///
  /// In en, this message translates to:
  /// **'22K'**
  String get karatShort22;

  /// No description provided for @karatShort21.
  ///
  /// In en, this message translates to:
  /// **'21K'**
  String get karatShort21;

  /// No description provided for @karatShort18.
  ///
  /// In en, this message translates to:
  /// **'18K'**
  String get karatShort18;

  /// No description provided for @range1D.
  ///
  /// In en, this message translates to:
  /// **'1D'**
  String get range1D;

  /// No description provided for @range3D.
  ///
  /// In en, this message translates to:
  /// **'3D'**
  String get range3D;

  /// No description provided for @range7D.
  ///
  /// In en, this message translates to:
  /// **'7D'**
  String get range7D;

  /// No description provided for @range1W.
  ///
  /// In en, this message translates to:
  /// **'1W'**
  String get range1W;

  /// No description provided for @range1M.
  ///
  /// In en, this message translates to:
  /// **'1M'**
  String get range1M;

  /// No description provided for @range3M.
  ///
  /// In en, this message translates to:
  /// **'3M'**
  String get range3M;

  /// No description provided for @range6M.
  ///
  /// In en, this message translates to:
  /// **'6M'**
  String get range6M;

  /// No description provided for @rangeYtd.
  ///
  /// In en, this message translates to:
  /// **'YTD'**
  String get rangeYtd;

  /// No description provided for @range1Y.
  ///
  /// In en, this message translates to:
  /// **'1Y'**
  String get range1Y;

  /// No description provided for @range5Y.
  ///
  /// In en, this message translates to:
  /// **'5Y'**
  String get range5Y;

  /// No description provided for @rangeAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get rangeAll;

  /// No description provided for @refresh15m.
  ///
  /// In en, this message translates to:
  /// **'15 minutes'**
  String get refresh15m;

  /// No description provided for @refresh30m.
  ///
  /// In en, this message translates to:
  /// **'30 minutes'**
  String get refresh30m;

  /// No description provided for @refresh1h.
  ///
  /// In en, this message translates to:
  /// **'1 hour'**
  String get refresh1h;

  /// No description provided for @refresh3h.
  ///
  /// In en, this message translates to:
  /// **'3 hours'**
  String get refresh3h;

  /// No description provided for @refresh6h.
  ///
  /// In en, this message translates to:
  /// **'6 hours'**
  String get refresh6h;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get commonRemove;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get commonUndo;

  /// No description provided for @confirmRemoveCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove {name} from your watchlist?'**
  String confirmRemoveCardTitle(String name);

  /// No description provided for @confirmRemoveCardMessage.
  ///
  /// In en, this message translates to:
  /// **'Your holdings for this instrument are kept.'**
  String get confirmRemoveCardMessage;

  /// No description provided for @confirmDeleteLotTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this lot?'**
  String get confirmDeleteLotTitle;

  /// No description provided for @confirmDeleteLotMessage.
  ///
  /// In en, this message translates to:
  /// **'{details}. This can\'t be undone.'**
  String confirmDeleteLotMessage(String details);

  /// No description provided for @confirmRemoveTickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove custom ticker {symbol}?'**
  String confirmRemoveTickerTitle(String symbol);

  /// No description provided for @confirmRemoveTickerMessage.
  ///
  /// In en, this message translates to:
  /// **'Any watchlist cards for it are removed too.'**
  String get confirmRemoveTickerMessage;

  /// No description provided for @alertKindAbove.
  ///
  /// In en, this message translates to:
  /// **'Goes above'**
  String get alertKindAbove;

  /// No description provided for @alertKindBelow.
  ///
  /// In en, this message translates to:
  /// **'Goes below'**
  String get alertKindBelow;

  /// No description provided for @alertKindPercentMove.
  ///
  /// In en, this message translates to:
  /// **'% move'**
  String get alertKindPercentMove;

  /// No description provided for @alertDirectionUp.
  ///
  /// In en, this message translates to:
  /// **'Up'**
  String get alertDirectionUp;

  /// No description provided for @alertDirectionDown.
  ///
  /// In en, this message translates to:
  /// **'Down'**
  String get alertDirectionDown;

  /// No description provided for @alertDirectionEither.
  ///
  /// In en, this message translates to:
  /// **'Either'**
  String get alertDirectionEither;

  /// No description provided for @alertWindowWithin24h.
  ///
  /// In en, this message translates to:
  /// **'Within 24 hours'**
  String get alertWindowWithin24h;

  /// No description provided for @alertWindowWithin7d.
  ///
  /// In en, this message translates to:
  /// **'Within 7 days'**
  String get alertWindowWithin7d;

  /// No description provided for @alertWindow24h.
  ///
  /// In en, this message translates to:
  /// **'24 hours'**
  String get alertWindow24h;

  /// No description provided for @alertWindow7d.
  ///
  /// In en, this message translates to:
  /// **'7 days'**
  String get alertWindow7d;

  /// No description provided for @alertBellTooltip.
  ///
  /// In en, this message translates to:
  /// **'Price alerts'**
  String get alertBellTooltip;

  /// No description provided for @alertsCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get alertsCardTitle;

  /// No description provided for @alertsCardEmpty.
  ///
  /// In en, this message translates to:
  /// **'No alerts yet for this instrument.'**
  String get alertsCardEmpty;

  /// No description provided for @alertsCardAdd.
  ///
  /// In en, this message translates to:
  /// **'Add alert'**
  String get alertsCardAdd;

  /// No description provided for @alertEditorNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New alert'**
  String get alertEditorNewTitle;

  /// No description provided for @alertEditorEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit alert'**
  String get alertEditorEditTitle;

  /// No description provided for @alertEditorTypePrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get alertEditorTypePrice;

  /// No description provided for @alertEditorTypePercent.
  ///
  /// In en, this message translates to:
  /// **'% move'**
  String get alertEditorTypePercent;

  /// No description provided for @alertEditorGoesAbove.
  ///
  /// In en, this message translates to:
  /// **'Goes above'**
  String get alertEditorGoesAbove;

  /// No description provided for @alertEditorGoesBelow.
  ///
  /// In en, this message translates to:
  /// **'Goes below'**
  String get alertEditorGoesBelow;

  /// No description provided for @alertEditorTargetLabel.
  ///
  /// In en, this message translates to:
  /// **'Target price'**
  String get alertEditorTargetLabel;

  /// No description provided for @alertEditorTargetRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a target price above zero.'**
  String get alertEditorTargetRequired;

  /// No description provided for @alertEditorHelperAbove.
  ///
  /// In en, this message translates to:
  /// **'+{delta} · {percent}% above the current price'**
  String alertEditorHelperAbove(String delta, String percent);

  /// No description provided for @alertEditorHelperBelow.
  ///
  /// In en, this message translates to:
  /// **'−{delta} · {percent}% below the current price'**
  String alertEditorHelperBelow(String delta, String percent);

  /// No description provided for @alertEditorDirection.
  ///
  /// In en, this message translates to:
  /// **'Direction'**
  String get alertEditorDirection;

  /// No description provided for @alertEditorWindow.
  ///
  /// In en, this message translates to:
  /// **'Window'**
  String get alertEditorWindow;

  /// No description provided for @alertEditorPercentSummary.
  ///
  /// In en, this message translates to:
  /// **'Fires below {low} or above {high}'**
  String alertEditorPercentSummary(String low, String high);

  /// No description provided for @alertEditorPercentSummaryUp.
  ///
  /// In en, this message translates to:
  /// **'Fires above {high}'**
  String alertEditorPercentSummaryUp(String high);

  /// No description provided for @alertEditorPercentSummaryDown.
  ///
  /// In en, this message translates to:
  /// **'Fires below {low}'**
  String alertEditorPercentSummaryDown(String low);

  /// No description provided for @alertEditorRepeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get alertEditorRepeat;

  /// No description provided for @alertEditorRepeatFooter.
  ///
  /// In en, this message translates to:
  /// **'Keep watching after it fires, instead of turning off.'**
  String get alertEditorRepeatFooter;

  /// No description provided for @alertEditorCreate.
  ///
  /// In en, this message translates to:
  /// **'Create alert'**
  String get alertEditorCreate;

  /// No description provided for @alertEditorSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get alertEditorSave;

  /// No description provided for @alertEditorDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get alertEditorDelete;

  /// No description provided for @alertsScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get alertsScreenTitle;

  /// No description provided for @alertsScreenInfo.
  ///
  /// In en, this message translates to:
  /// **'Alerts are checked roughly every 15 minutes in the background, and live while Qima is open.'**
  String get alertsScreenInfo;

  /// No description provided for @alertsScreenEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No alerts yet'**
  String get alertsScreenEmptyTitle;

  /// No description provided for @alertsScreenEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Open an instrument and tap the bell to set a price alert.'**
  String get alertsScreenEmptyMessage;

  /// No description provided for @alertsScreenFiredToday.
  ///
  /// In en, this message translates to:
  /// **'Fired today {time} · switched off'**
  String alertsScreenFiredToday(String time);

  /// No description provided for @alertsScreenNotificationsOff.
  ///
  /// In en, this message translates to:
  /// **'Notifications are off'**
  String get alertsScreenNotificationsOff;

  /// No description provided for @alertsScreenNotificationsOffMessage.
  ///
  /// In en, this message translates to:
  /// **'Turn on notifications for Qima to be alerted when a price target is hit.'**
  String get alertsScreenNotificationsOffMessage;

  /// No description provided for @alertsScreenOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get alertsScreenOpenSettings;

  /// No description provided for @confirmDeleteAlertTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this alert?'**
  String get confirmDeleteAlertTitle;

  /// No description provided for @confirmDeleteAlertMessage.
  ///
  /// In en, this message translates to:
  /// **'You won\'t be notified for it again.'**
  String get confirmDeleteAlertMessage;

  /// No description provided for @settingsAlerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get settingsAlerts;

  /// No description provided for @settingsAlertsPriceAlerts.
  ///
  /// In en, this message translates to:
  /// **'Price alerts'**
  String get settingsAlertsPriceAlerts;

  /// No description provided for @settingsAlertsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No alerts} =1{1 alert} other{{count} alerts}}'**
  String settingsAlertsCount(int count);

  /// No description provided for @settingsAlertsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsAlertsNotifications;

  /// No description provided for @settingsAlertsNotificationsOn.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get settingsAlertsNotificationsOn;

  /// No description provided for @settingsAlertsNotificationsOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get settingsAlertsNotificationsOff;

  /// No description provided for @settingsAlertsDeliverOnDevice.
  ///
  /// In en, this message translates to:
  /// **'Deliver alerts on this device'**
  String get settingsAlertsDeliverOnDevice;

  /// No description provided for @settingsAlertsDeliverOnDeviceFooter.
  ///
  /// In en, this message translates to:
  /// **'Turn off if you don\'t want this device to notify you when an alert fires.'**
  String get settingsAlertsDeliverOnDeviceFooter;

  /// No description provided for @alertNotificationTitleAbove.
  ///
  /// In en, this message translates to:
  /// **'{name} is above {target}'**
  String alertNotificationTitleAbove(String name, String target);

  /// No description provided for @alertNotificationTitleBelow.
  ///
  /// In en, this message translates to:
  /// **'{name} is below {target}'**
  String alertNotificationTitleBelow(String name, String target);

  /// No description provided for @alertNotificationTitlePercent.
  ///
  /// In en, this message translates to:
  /// **'{name} moved {percent}% in {window}'**
  String alertNotificationTitlePercent(
    String name,
    String percent,
    String window,
  );

  /// No description provided for @alertNotificationBodyOneOff.
  ///
  /// In en, this message translates to:
  /// **'Now {price} per {unit}. This alert is now off.'**
  String alertNotificationBodyOneOff(String price, String unit);

  /// No description provided for @alertNotificationBodyRepeat.
  ///
  /// In en, this message translates to:
  /// **'Now {price} per {unit}. You\'ll be told again the next time this happens.'**
  String alertNotificationBodyRepeat(String price, String unit);

  /// No description provided for @settingsBackup.
  ///
  /// In en, this message translates to:
  /// **'Backup & restore'**
  String get settingsBackup;

  /// No description provided for @settingsBackupSubtitleNever.
  ///
  /// In en, this message translates to:
  /// **'Never backed up'**
  String get settingsBackupSubtitleNever;

  /// No description provided for @settingsBackupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Last backup {date} · {instruments} instruments, {lots} lots'**
  String settingsBackupSubtitle(String date, int instruments, int lots);

  /// No description provided for @settingsICloudSync.
  ///
  /// In en, this message translates to:
  /// **'iCloud sync'**
  String get settingsICloudSync;

  /// No description provided for @settingsICloudSyncSwitch.
  ///
  /// In en, this message translates to:
  /// **'Sync with iCloud'**
  String get settingsICloudSyncSwitch;

  /// No description provided for @settingsICloudSyncFooter.
  ///
  /// In en, this message translates to:
  /// **'Keeps your watchlist, holdings, custom tickers and price alerts up to date across your devices.'**
  String get settingsICloudSyncFooter;

  /// No description provided for @settingsICloudSyncStatusUpToDate.
  ///
  /// In en, this message translates to:
  /// **'Up to date · {time}'**
  String settingsICloudSyncStatusUpToDate(String time);

  /// No description provided for @settingsICloudSyncStatusSyncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing…'**
  String get settingsICloudSyncStatusSyncing;

  /// No description provided for @settingsICloudSyncStatusNotSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Not signed in to iCloud'**
  String get settingsICloudSyncStatusNotSignedIn;

  /// No description provided for @settingsICloudSyncStatusStorageFull.
  ///
  /// In en, this message translates to:
  /// **'iCloud storage for Qima is full'**
  String get settingsICloudSyncStatusStorageFull;

  /// No description provided for @backupTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup & restore'**
  String get backupTitle;

  /// No description provided for @backupStatusTitle.
  ///
  /// In en, this message translates to:
  /// **'Stored only on this phone'**
  String get backupStatusTitle;

  /// No description provided for @backupStatusMessage.
  ///
  /// In en, this message translates to:
  /// **'Your data lives on this device only. Back it up so you can restore it here or on another device.'**
  String get backupStatusMessage;

  /// No description provided for @backupLastBackup.
  ///
  /// In en, this message translates to:
  /// **'Last backup {date}'**
  String backupLastBackup(String date);

  /// No description provided for @backupLastBackupNever.
  ///
  /// In en, this message translates to:
  /// **'Never backed up'**
  String get backupLastBackupNever;

  /// No description provided for @backupReminderCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Time for a backup'**
  String get backupReminderCardTitle;

  /// No description provided for @backupReminderCardMessage.
  ///
  /// In en, this message translates to:
  /// **'It\'s been over 30 days since your last backup and your data has changed.'**
  String get backupReminderCardMessage;

  /// No description provided for @backupReminderCardAction.
  ///
  /// In en, this message translates to:
  /// **'Back up now'**
  String get backupReminderCardAction;

  /// No description provided for @backupReminderNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Time for a backup'**
  String get backupReminderNotificationTitle;

  /// No description provided for @backupReminderNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'It\'s been a while since your last Qima backup and your data has changed. Tap to back up now.'**
  String get backupReminderNotificationBody;

  /// No description provided for @backupExportSection.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get backupExportSection;

  /// No description provided for @backupExportFullTitle.
  ///
  /// In en, this message translates to:
  /// **'Full backup'**
  String get backupExportFullTitle;

  /// No description provided for @backupExportFullSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Watchlist, holdings, custom tickers, alerts and settings (.json)'**
  String get backupExportFullSubtitle;

  /// No description provided for @backupExportCsvTitle.
  ///
  /// In en, this message translates to:
  /// **'Holdings spreadsheet'**
  String get backupExportCsvTitle;

  /// No description provided for @backupExportCsvSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your lots as a spreadsheet, for your records (.csv)'**
  String get backupExportCsvSubtitle;

  /// No description provided for @backupRestoreSection.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get backupRestoreSection;

  /// No description provided for @backupRestoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Import a backup'**
  String get backupRestoreTitle;

  /// No description provided for @backupRestoreSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Restore from a full backup file (.json)'**
  String get backupRestoreSubtitle;

  /// No description provided for @backupReminderSection.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get backupReminderSection;

  /// No description provided for @backupReminderToggleTitle.
  ///
  /// In en, this message translates to:
  /// **'Remind me to back up'**
  String get backupReminderToggleTitle;

  /// No description provided for @backupReminderToggleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get a monthly reminder if you haven\'t backed up recently and your data has changed.'**
  String get backupReminderToggleSubtitle;

  /// No description provided for @backupExportSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Export backup'**
  String get backupExportSheetTitle;

  /// No description provided for @backupExportSheetFileName.
  ///
  /// In en, this message translates to:
  /// **'File name'**
  String get backupExportSheetFileName;

  /// No description provided for @backupExportSheetFileSize.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get backupExportSheetFileSize;

  /// No description provided for @backupExportSheetFileContents.
  ///
  /// In en, this message translates to:
  /// **'Contents'**
  String get backupExportSheetFileContents;

  /// No description provided for @backupExportSheetContentsSummary.
  ///
  /// In en, this message translates to:
  /// **'{cards} watchlist cards · {lots} lots · {customTickers} custom tickers'**
  String backupExportSheetContentsSummary(
    int cards,
    int lots,
    int customTickers,
  );

  /// No description provided for @backupExportSheetProtectTitle.
  ///
  /// In en, this message translates to:
  /// **'Protect with a password'**
  String get backupExportSheetProtectTitle;

  /// No description provided for @backupExportSheetProtectSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Encrypts the file with AES-256. If you forget this password, the backup can\'t be recovered.'**
  String get backupExportSheetProtectSubtitle;

  /// No description provided for @backupExportSheetPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get backupExportSheetPasswordLabel;

  /// No description provided for @backupExportSheetPasswordConfirmLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get backupExportSheetPasswordConfirmLabel;

  /// No description provided for @backupExportSheetPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Use at least 8 characters.'**
  String get backupExportSheetPasswordTooShort;

  /// No description provided for @backupExportSheetPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords don\'t match.'**
  String get backupExportSheetPasswordMismatch;

  /// No description provided for @backupExportSheetUnprotectedWarning.
  ///
  /// In en, this message translates to:
  /// **'Anyone with this file can read your data. Protect it with a password if you plan to store or send it somewhere less private.'**
  String get backupExportSheetUnprotectedWarning;

  /// No description provided for @backupExportSheetAction.
  ///
  /// In en, this message translates to:
  /// **'Save or share…'**
  String get backupExportSheetAction;

  /// No description provided for @backupExportSheetWorking.
  ///
  /// In en, this message translates to:
  /// **'Preparing your backup…'**
  String get backupExportSheetWorking;

  /// No description provided for @backupExportSheetFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t create the backup. Try again.'**
  String get backupExportSheetFailed;

  /// No description provided for @backupImportPreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore backup'**
  String get backupImportPreviewTitle;

  /// No description provided for @backupImportFileCreated.
  ///
  /// In en, this message translates to:
  /// **'Created {date}'**
  String backupImportFileCreated(String date);

  /// No description provided for @backupImportFileAppVersion.
  ///
  /// In en, this message translates to:
  /// **'Made with Qima {version}'**
  String backupImportFileAppVersion(String version);

  /// No description provided for @backupImportCountCards.
  ///
  /// In en, this message translates to:
  /// **'Watchlist cards'**
  String get backupImportCountCards;

  /// No description provided for @backupImportCountLots.
  ///
  /// In en, this message translates to:
  /// **'Lots'**
  String get backupImportCountLots;

  /// No description provided for @backupImportCountCustomTickers.
  ///
  /// In en, this message translates to:
  /// **'Custom tickers'**
  String get backupImportCountCustomTickers;

  /// No description provided for @backupImportCountSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings included'**
  String get backupImportCountSettings;

  /// No description provided for @backupImportPasswordPrompt.
  ///
  /// In en, this message translates to:
  /// **'This backup is protected. Enter the password to continue.'**
  String get backupImportPasswordPrompt;

  /// No description provided for @backupImportPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get backupImportPasswordLabel;

  /// No description provided for @backupImportPasswordIncorrect.
  ///
  /// In en, this message translates to:
  /// **'That password didn\'t work. Try again.'**
  String get backupImportPasswordIncorrect;

  /// No description provided for @backupImportUnlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get backupImportUnlock;

  /// No description provided for @backupImportModeMerge.
  ///
  /// In en, this message translates to:
  /// **'Merge'**
  String get backupImportModeMerge;

  /// No description provided for @backupImportModeReplace.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get backupImportModeReplace;

  /// No description provided for @backupImportModeMergeFooter.
  ///
  /// In en, this message translates to:
  /// **'Keeps what\'s on this phone and adds anything new or newer from the backup.'**
  String get backupImportModeMergeFooter;

  /// No description provided for @backupImportModeReplaceFooter.
  ///
  /// In en, this message translates to:
  /// **'Replaces everything on this phone with the backup\'s contents.'**
  String get backupImportModeReplaceFooter;

  /// No description provided for @backupImportDiff.
  ///
  /// In en, this message translates to:
  /// **'{added, plural, =0{} =1{+1 added} other{+{added} added}} · {updated} updated · {removed} removed'**
  String backupImportDiff(int added, int updated, int removed);

  /// No description provided for @backupImportRestoreButton.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get backupImportRestoreButton;

  /// No description provided for @backupImportReplaceConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Replace everything on this phone?'**
  String get backupImportReplaceConfirmTitle;

  /// No description provided for @backupImportReplaceConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Your current watchlist, holdings, custom tickers and alerts will be replaced with the backup\'s contents. This can\'t be undone.'**
  String get backupImportReplaceConfirmMessage;

  /// No description provided for @backupImportReplaceConfirmAction.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get backupImportReplaceConfirmAction;

  /// No description provided for @backupImportSuccessSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Backup restored'**
  String get backupImportSuccessSnackbar;

  /// No description provided for @backupImportFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t restore this backup'**
  String get backupImportFailedTitle;

  /// No description provided for @backupImportCsvErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'This is a spreadsheet, not a backup'**
  String get backupImportCsvErrorTitle;

  /// No description provided for @backupImportCsvErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'A holdings spreadsheet (.csv) only has your lots, and can\'t be restored. Choose a full backup file (.json) instead.'**
  String get backupImportCsvErrorMessage;

  /// No description provided for @backupErrorNotQimaFile.
  ///
  /// In en, this message translates to:
  /// **'This doesn\'t look like a Qima backup file.'**
  String get backupErrorNotQimaFile;

  /// No description provided for @backupErrorNewerVersion.
  ///
  /// In en, this message translates to:
  /// **'This backup was made with a newer version of Qima. Update the app to restore it.'**
  String get backupErrorNewerVersion;

  /// No description provided for @backupErrorWrongPassword.
  ///
  /// In en, this message translates to:
  /// **'That password didn\'t work.'**
  String get backupErrorWrongPassword;

  /// No description provided for @backupErrorCorrupted.
  ///
  /// In en, this message translates to:
  /// **'This backup file is damaged and can\'t be restored.'**
  String get backupErrorCorrupted;

  /// No description provided for @backupCsvHeaderInstrument.
  ///
  /// In en, this message translates to:
  /// **'Instrument'**
  String get backupCsvHeaderInstrument;

  /// No description provided for @backupCsvHeaderSymbol.
  ///
  /// In en, this message translates to:
  /// **'Symbol'**
  String get backupCsvHeaderSymbol;

  /// No description provided for @backupCsvHeaderQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get backupCsvHeaderQuantity;

  /// No description provided for @backupCsvHeaderUnit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get backupCsvHeaderUnit;

  /// No description provided for @backupCsvHeaderKarat.
  ///
  /// In en, this message translates to:
  /// **'Karat'**
  String get backupCsvHeaderKarat;

  /// No description provided for @backupCsvHeaderUnitCost.
  ///
  /// In en, this message translates to:
  /// **'Unit cost'**
  String get backupCsvHeaderUnitCost;

  /// No description provided for @backupCsvHeaderCostCurrency.
  ///
  /// In en, this message translates to:
  /// **'Cost currency'**
  String get backupCsvHeaderCostCurrency;

  /// No description provided for @backupCsvHeaderTotalCost.
  ///
  /// In en, this message translates to:
  /// **'Total cost'**
  String get backupCsvHeaderTotalCost;

  /// No description provided for @backupCsvHeaderDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get backupCsvHeaderDate;

  /// No description provided for @commonContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get commonContinue;

  /// Onboarding tour primary button, steps 1-4.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// Onboarding tour text button under Next, steps 1-4.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// Onboarding tour primary button, step 5 (final step).
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onboardingGetStarted;

  /// Onboarding step 1 (Welcome) title.
  ///
  /// In en, this message translates to:
  /// **'Everything you own, in one number'**
  String get onboardingStep1Title;

  /// Onboarding step 1 (Welcome) body.
  ///
  /// In en, this message translates to:
  /// **'Gold, silver, crypto, stocks, indices and currencies, added up in your currency.'**
  String get onboardingStep1Body;

  /// Onboarding step 2 (Watchlist) title.
  ///
  /// In en, this message translates to:
  /// **'Prices the way you buy'**
  String get onboardingStep2Title;

  /// Onboarding step 2 (Watchlist) body.
  ///
  /// In en, this message translates to:
  /// **'Live prices by gram, ounce or kilogram, 24K to 18K, in any currency. Tap + to add, tap a card for its chart.'**
  String get onboardingStep2Body;

  /// Onboarding step 3 (Holdings) title.
  ///
  /// In en, this message translates to:
  /// **'Know what you hold'**
  String get onboardingStep3Title;

  /// Onboarding step 3 (Holdings) body.
  ///
  /// In en, this message translates to:
  /// **'Record each purchase: quantity, unit, karat, cost and date. See what you hold, your average cost, value and gain.'**
  String get onboardingStep3Body;

  /// Onboarding step 4 (Alerts & widgets) title.
  ///
  /// In en, this message translates to:
  /// **'Never miss a move'**
  String get onboardingStep4Title;

  /// Onboarding step 4 (Alerts & widgets) title.
  ///
  /// In en, this message translates to:
  /// **'Get notified when a price crosses a level or moves by a percent. Put prices on your Home and Lock Screen.'**
  String get onboardingStep4Body;

  /// Onboarding step 5 (Private by design) title.
  ///
  /// In en, this message translates to:
  /// **'Private by design'**
  String get onboardingStep5Title;

  /// Onboarding step 5 (Private by design) title.
  ///
  /// In en, this message translates to:
  /// **'No account. Your data stays on this device, with optional iCloud sync, Face ID lock and file backups.'**
  String get onboardingStep5Body;

  /// Onboarding step 5 body, Android wording (no iCloud, fingerprint/face unlock instead of Face ID).
  ///
  /// In en, this message translates to:
  /// **'No account. Your data stays on this device, with fingerprint or face unlock and file backups.'**
  String get onboardingStep5BodyAndroid;

  /// Onboarding step 5 body on macOS (Touch ID instead of Face ID).
  ///
  /// In en, this message translates to:
  /// **'No account. Your data stays on this Mac, with optional iCloud sync, Touch ID lock and file backups.'**
  String get onboardingStep5BodyMac;

  /// Onboarding step 5 pill.
  ///
  /// In en, this message translates to:
  /// **'No account'**
  String get onboardingStep5PillNoAccount;

  /// Onboarding step 5 pill.
  ///
  /// In en, this message translates to:
  /// **'On this device'**
  String get onboardingStep5PillOnDevice;

  /// Onboarding step 5 illustration row title (iOS only).
  ///
  /// In en, this message translates to:
  /// **'iCloud sync'**
  String get onboardingStep5ICloudTitle;

  /// Onboarding step 5 illustration row subtitle (iOS only).
  ///
  /// In en, this message translates to:
  /// **'Optional · keeps devices in step'**
  String get onboardingStep5ICloudSubtitle;

  /// Onboarding step 5 illustration row title.
  ///
  /// In en, this message translates to:
  /// **'App lock'**
  String get onboardingStep5AppLockTitle;

  /// Onboarding step 5 App lock row subtitle, Apple platforms.
  ///
  /// In en, this message translates to:
  /// **'Face ID or fingerprint'**
  String get onboardingStep5AppLockSubtitleApple;

  /// Onboarding step 5 App lock row subtitle, non-Apple platforms.
  ///
  /// In en, this message translates to:
  /// **'Fingerprint or face unlock'**
  String get onboardingStep5AppLockSubtitleGeneric;

  /// Onboarding step 5 app lock row subtitle on macOS.
  ///
  /// In en, this message translates to:
  /// **'Touch ID or your Mac password'**
  String get onboardingStep5AppLockSubtitleMac;

  /// Onboarding step 5 illustration row title.
  ///
  /// In en, this message translates to:
  /// **'Hide balances'**
  String get onboardingStep5HideBalancesTitle;

  /// Onboarding step 5 illustration row subtitle.
  ///
  /// In en, this message translates to:
  /// **'Show •••• instead of amounts'**
  String get onboardingStep5HideBalancesSubtitle;

  /// Onboarding step 5 base-currency row title.
  ///
  /// In en, this message translates to:
  /// **'Base currency'**
  String get onboardingBaseCurrencyTitle;

  /// Onboarding step 5 base-currency row subtitle.
  ///
  /// In en, this message translates to:
  /// **'From your region · change in Settings'**
  String get onboardingBaseCurrencySubtitle;

  /// Accessibility label for the onboarding page dots / progress.
  ///
  /// In en, this message translates to:
  /// **'Step {step} of {total}'**
  String onboardingSemanticStepOf(int step, int total);

  /// Footer link on every help sheet, and a Settings row, that reopens the onboarding tour.
  ///
  /// In en, this message translates to:
  /// **'Replay the tour'**
  String get onboardingReplayTour;

  /// Tooltip/semantic label for the help (question mark) button in every app bar.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get helpButtonTooltip;

  /// Small-caps header above the page name in the help sheet.
  ///
  /// In en, this message translates to:
  /// **'ABOUT THIS PAGE'**
  String get helpSheetAboutHeader;

  /// Small-caps header above the numbered steps in the help sheet.
  ///
  /// In en, this message translates to:
  /// **'HOW TO USE IT'**
  String get helpSheetHowToHeader;

  /// Small-caps header for the "How Qima works" index sheet.
  ///
  /// In en, this message translates to:
  /// **'HELP'**
  String get helpSheetIndexHeader;

  /// Small-caps header for the Widgets help topic (opened from Settings).
  ///
  /// In en, this message translates to:
  /// **'HELP · SETTINGS'**
  String get helpSheetWidgetsHeader;

  /// Close button semantic label in the help sheet header.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get helpSheetCloseTooltip;

  /// "How Qima works" index sheet intro line.
  ///
  /// In en, this message translates to:
  /// **'Pick a page to see what it does and how to use it.'**
  String get helpIndexIntro;

  /// Watchlist help topic title (matches the page name).
  ///
  /// In en, this message translates to:
  /// **'Watchlist'**
  String get helpWatchlistTitle;

  /// Watchlist help topic summary line.
  ///
  /// In en, this message translates to:
  /// **'Live prices for everything you follow, with your portfolio total on top.'**
  String get helpWatchlistSummary;

  /// Watchlist help step 1 title.
  ///
  /// In en, this message translates to:
  /// **'Open a card'**
  String get helpWatchlistStep1Title;

  /// Watchlist help step 1 body.
  ///
  /// In en, this message translates to:
  /// **'Tap any card for its chart, key stats and your holdings.'**
  String get helpWatchlistStep1Body;

  /// Watchlist help step 2 title.
  ///
  /// In en, this message translates to:
  /// **'Add an asset'**
  String get helpWatchlistStep2Title;

  /// Watchlist help step 2 body.
  ///
  /// In en, this message translates to:
  /// **'Tap + and search by name or symbol.'**
  String get helpWatchlistStep2Body;

  /// Watchlist help step 3 title.
  ///
  /// In en, this message translates to:
  /// **'Filter the list'**
  String get helpWatchlistStep3Title;

  /// Watchlist help step 3 body.
  ///
  /// In en, this message translates to:
  /// **'Show only Metals, Crypto, Stocks, Indices or Currencies.'**
  String get helpWatchlistStep3Body;

  /// Watchlist help step 4 title.
  ///
  /// In en, this message translates to:
  /// **'Change the chart range'**
  String get helpWatchlistStep4Title;

  /// Watchlist help step 4 body.
  ///
  /// In en, this message translates to:
  /// **'Pick 1W to All under the portfolio chart.'**
  String get helpWatchlistStep4Body;

  /// Watchlist help step 5 title.
  ///
  /// In en, this message translates to:
  /// **'Refresh prices'**
  String get helpWatchlistStep5Title;

  /// Watchlist help step 5 body.
  ///
  /// In en, this message translates to:
  /// **'Tap refresh to fetch the latest prices now.'**
  String get helpWatchlistStep5Body;

  /// Asset detail help topic title.
  ///
  /// In en, this message translates to:
  /// **'Asset detail'**
  String get helpAssetDetailTitle;

  /// Asset detail help topic summary line.
  ///
  /// In en, this message translates to:
  /// **'One asset\'s price, chart and stats, plus what you hold of it.'**
  String get helpAssetDetailSummary;

  /// Asset detail help step 1 title.
  ///
  /// In en, this message translates to:
  /// **'Pick a range'**
  String get helpAssetDetailStep1Title;

  /// Asset detail help step 1 body.
  ///
  /// In en, this message translates to:
  /// **'Switch between 1D and All under the chart.'**
  String get helpAssetDetailStep1Body;

  /// Asset detail help step 2 title.
  ///
  /// In en, this message translates to:
  /// **'Change unit, karat or currency'**
  String get helpAssetDetailStep2Title;

  /// Asset detail help step 2 body.
  ///
  /// In en, this message translates to:
  /// **'Tap the sliders at the top of the page.'**
  String get helpAssetDetailStep2Body;

  /// Asset detail help step 3 title.
  ///
  /// In en, this message translates to:
  /// **'Compare units'**
  String get helpAssetDetailStep3Title;

  /// Asset detail help step 3 body.
  ///
  /// In en, this message translates to:
  /// **'Price per unit shows ounce, kilogram and each karat side by side.'**
  String get helpAssetDetailStep3Body;

  /// Asset detail help step 4 title.
  ///
  /// In en, this message translates to:
  /// **'Set an alert'**
  String get helpAssetDetailStep4Title;

  /// Asset detail help step 4 body.
  ///
  /// In en, this message translates to:
  /// **'Tap the bell to hear when the price crosses a level or moves by a percent.'**
  String get helpAssetDetailStep4Body;

  /// Asset detail help step 5 title.
  ///
  /// In en, this message translates to:
  /// **'Track what you own'**
  String get helpAssetDetailStep5Title;

  /// Asset detail help step 5 body.
  ///
  /// In en, this message translates to:
  /// **'Tap Holdings to see your lots or add a purchase.'**
  String get helpAssetDetailStep5Body;

  /// Portfolio help topic title.
  ///
  /// In en, this message translates to:
  /// **'Portfolio'**
  String get helpPortfolioTitle;

  /// Portfolio help topic summary line.
  ///
  /// In en, this message translates to:
  /// **'Everything you hold, added up in your base currency, with each asset\'s share and gain.'**
  String get helpPortfolioSummary;

  /// Portfolio help step 1 title.
  ///
  /// In en, this message translates to:
  /// **'Read the donut'**
  String get helpPortfolioStep1Title;

  /// Portfolio help step 1 body.
  ///
  /// In en, this message translates to:
  /// **'Each slice is one asset\'s share of your total value.'**
  String get helpPortfolioStep1Body;

  /// Portfolio help step 2 title.
  ///
  /// In en, this message translates to:
  /// **'Open an asset'**
  String get helpPortfolioStep2Title;

  /// Portfolio help step 2 body.
  ///
  /// In en, this message translates to:
  /// **'Tap a row to see its lots, average cost and gain.'**
  String get helpPortfolioStep2Body;

  /// Portfolio help step 3 title.
  ///
  /// In en, this message translates to:
  /// **'Add a purchase'**
  String get helpPortfolioStep3Title;

  /// Portfolio help step 3 body.
  ///
  /// In en, this message translates to:
  /// **'Open an asset, then tap +.'**
  String get helpPortfolioStep3Body;

  /// Portfolio help step 4 title.
  ///
  /// In en, this message translates to:
  /// **'Change the currency'**
  String get helpPortfolioStep4Title;

  /// Portfolio help step 4 body.
  ///
  /// In en, this message translates to:
  /// **'Totals use your base currency, set in Settings.'**
  String get helpPortfolioStep4Body;

  /// Portfolio help step 5 title.
  ///
  /// In en, this message translates to:
  /// **'Hide amounts'**
  String get helpPortfolioStep5Title;

  /// Portfolio help step 5 body.
  ///
  /// In en, this message translates to:
  /// **'Turn on Hide balances in Settings to mask every value.'**
  String get helpPortfolioStep5Body;

  /// Lot editor help topic title.
  ///
  /// In en, this message translates to:
  /// **'Lot editor'**
  String get helpLotEditorTitle;

  /// Lot editor help topic summary line.
  ///
  /// In en, this message translates to:
  /// **'Record one purchase so Qima can work out what you hold, your average cost and your gain.'**
  String get helpLotEditorSummary;

  /// Lot editor help step 1 title.
  ///
  /// In en, this message translates to:
  /// **'Quantity and unit'**
  String get helpLotEditorStep1Title;

  /// Lot editor help step 1 body.
  ///
  /// In en, this message translates to:
  /// **'Enter how much you bought, in troy ounces, grams or kilograms.'**
  String get helpLotEditorStep1Body;

  /// Lot editor help step 2 title.
  ///
  /// In en, this message translates to:
  /// **'Karat'**
  String get helpLotEditorStep2Title;

  /// Lot editor help step 2 body.
  ///
  /// In en, this message translates to:
  /// **'For gold by gram or kilogram, pick 24K, 22K, 21K or 18K. It starts at the card\'s karat.'**
  String get helpLotEditorStep2Body;

  /// Lot editor help step 3 title.
  ///
  /// In en, this message translates to:
  /// **'What you paid'**
  String get helpLotEditorStep3Title;

  /// Lot editor help step 3 body.
  ///
  /// In en, this message translates to:
  /// **'Enter the cost per unit or the total, in the currency you paid in.'**
  String get helpLotEditorStep3Body;

  /// Lot editor help step 4 title.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get helpLotEditorStep4Title;

  /// Lot editor help step 4 body.
  ///
  /// In en, this message translates to:
  /// **'The day you bought it.'**
  String get helpLotEditorStep4Body;

  /// Lot editor help step 5 title.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get helpLotEditorStep5Title;

  /// Lot editor help step 5 body.
  ///
  /// In en, this message translates to:
  /// **'Edit or delete a lot any time from Holdings.'**
  String get helpLotEditorStep5Body;

  /// Add asset help topic title.
  ///
  /// In en, this message translates to:
  /// **'Add asset'**
  String get helpAddAssetTitle;

  /// Add asset help topic summary line.
  ///
  /// In en, this message translates to:
  /// **'Find something to follow and add it to your watchlist.'**
  String get helpAddAssetSummary;

  /// Add asset help step 1 title.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get helpAddAssetStep1Title;

  /// Add asset help step 1 body.
  ///
  /// In en, this message translates to:
  /// **'Type a name or symbol, like gold, BTC or AAPL.'**
  String get helpAddAssetStep1Body;

  /// Add asset help step 2 title.
  ///
  /// In en, this message translates to:
  /// **'Pick a result'**
  String get helpAddAssetStep2Title;

  /// Add asset help step 2 body.
  ///
  /// In en, this message translates to:
  /// **'It\'s added to your watchlist and its page opens.'**
  String get helpAddAssetStep2Body;

  /// Add asset help step 3 title.
  ///
  /// In en, this message translates to:
  /// **'Not in the list?'**
  String get helpAddAssetStep3Title;

  /// Add asset help step 3 body.
  ///
  /// In en, this message translates to:
  /// **'Add the symbol as a custom ticker. Qima checks it with the price provider first.'**
  String get helpAddAssetStep3Body;

  /// Add asset help step 4 title.
  ///
  /// In en, this message translates to:
  /// **'Changed your mind?'**
  String get helpAddAssetStep4Title;

  /// Add asset help step 4 body.
  ///
  /// In en, this message translates to:
  /// **'Tap Undo on the confirmation at the bottom.'**
  String get helpAddAssetStep4Body;

  /// Price alerts help topic title.
  ///
  /// In en, this message translates to:
  /// **'Price alerts'**
  String get helpPriceAlertsTitle;

  /// Price alerts help topic summary line.
  ///
  /// In en, this message translates to:
  /// **'Every alert you\'ve set, grouped by asset.'**
  String get helpPriceAlertsSummary;

  /// Price alerts help step 1 title.
  ///
  /// In en, this message translates to:
  /// **'New alert'**
  String get helpPriceAlertsStep1Title;

  /// Price alerts help step 1 body.
  ///
  /// In en, this message translates to:
  /// **'Tap +, or open an asset and tap the bell.'**
  String get helpPriceAlertsStep1Body;

  /// Price alerts help step 2 title.
  ///
  /// In en, this message translates to:
  /// **'Pause or resume'**
  String get helpPriceAlertsStep2Title;

  /// Price alerts help step 2 body.
  ///
  /// In en, this message translates to:
  /// **'Use the switch. One-off alerts switch themselves off after they fire.'**
  String get helpPriceAlertsStep2Body;

  /// Price alerts help step 3 title.
  ///
  /// In en, this message translates to:
  /// **'Change or delete'**
  String get helpPriceAlertsStep3Title;

  /// Price alerts help step 3 body.
  ///
  /// In en, this message translates to:
  /// **'Tap an alert to edit or remove it.'**
  String get helpPriceAlertsStep3Body;

  /// Price alerts help step 4 title.
  ///
  /// In en, this message translates to:
  /// **'When alerts arrive'**
  String get helpPriceAlertsStep4Title;

  /// Price alerts help step 4 body.
  ///
  /// In en, this message translates to:
  /// **'Prices are checked about every 15 minutes in the background, so an alert can arrive a few minutes late.'**
  String get helpPriceAlertsStep4Body;

  /// Price alerts help step 5 title.
  ///
  /// In en, this message translates to:
  /// **'No notifications?'**
  String get helpPriceAlertsStep5Title;

  /// Price alerts help step 5 body.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications for Qima in system settings, or alerts can\'t reach you.'**
  String get helpPriceAlertsStep5Body;

  /// Alert editor help topic title.
  ///
  /// In en, this message translates to:
  /// **'Alert editor'**
  String get helpAlertEditorTitle;

  /// Alert editor help topic summary line.
  ///
  /// In en, this message translates to:
  /// **'Choose when Qima should notify you about this asset.'**
  String get helpAlertEditorSummary;

  /// Alert editor help step 1 title.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get helpAlertEditorStep1Title;

  /// Alert editor help step 1 body.
  ///
  /// In en, this message translates to:
  /// **'Notify when the price goes above or below your target.'**
  String get helpAlertEditorStep1Body;

  /// Alert editor help step 2 title.
  ///
  /// In en, this message translates to:
  /// **'% move'**
  String get helpAlertEditorStep2Title;

  /// Alert editor help step 2 body.
  ///
  /// In en, this message translates to:
  /// **'Notify when it moves up, down or either way by 1-10% within 24 hours or 7 days.'**
  String get helpAlertEditorStep2Body;

  /// Alert editor help step 3 title.
  ///
  /// In en, this message translates to:
  /// **'Check the trigger'**
  String get helpAlertEditorStep3Title;

  /// Alert editor help step 3 body.
  ///
  /// In en, this message translates to:
  /// **'The line under your choice shows exactly which prices will fire it.'**
  String get helpAlertEditorStep3Body;

  /// Alert editor help step 4 title.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get helpAlertEditorStep4Title;

  /// Alert editor help step 4 body.
  ///
  /// In en, this message translates to:
  /// **'Off: the alert fires once, then switches off. On: it fires every time.'**
  String get helpAlertEditorStep4Body;

  /// Settings help topic title.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get helpSettingsTitle;

  /// Settings help topic summary line.
  ///
  /// In en, this message translates to:
  /// **'Choices that apply across the whole app.'**
  String get helpSettingsSummary;

  /// Settings help step 1 title.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get helpSettingsStep1Title;

  /// Settings help step 1 body.
  ///
  /// In en, this message translates to:
  /// **'System, Light or Dark.'**
  String get helpSettingsStep1Body;

  /// Settings help step 2 title.
  ///
  /// In en, this message translates to:
  /// **'Privacy & security'**
  String get helpSettingsStep2Title;

  /// Settings help step 2 body.
  ///
  /// In en, this message translates to:
  /// **'Hide balances, and lock Qima with Face ID or fingerprint.'**
  String get helpSettingsStep2Body;

  /// Settings help step 3 title.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get helpSettingsStep3Title;

  /// Settings help step 3 body.
  ///
  /// In en, this message translates to:
  /// **'See every price alert and check that notifications are allowed.'**
  String get helpSettingsStep3Body;

  /// Settings help step 4 title.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get helpSettingsStep4Title;

  /// Settings help step 4 body.
  ///
  /// In en, this message translates to:
  /// **'Save everything to a file and restore it later.'**
  String get helpSettingsStep4Body;

  /// Settings help step 5 title.
  ///
  /// In en, this message translates to:
  /// **'Defaults'**
  String get helpSettingsStep5Title;

  /// Settings help step 5 body.
  ///
  /// In en, this message translates to:
  /// **'Base currency, chart range, widget refresh and language.'**
  String get helpSettingsStep5Body;

  /// Backup & restore help topic title.
  ///
  /// In en, this message translates to:
  /// **'Backup & restore'**
  String get helpBackupTitle;

  /// Backup & restore help topic summary line.
  ///
  /// In en, this message translates to:
  /// **'Qima has no account, so a backup file is how you keep your data if this phone is lost or reset.'**
  String get helpBackupSummary;

  /// Backup & restore help step 1 title.
  ///
  /// In en, this message translates to:
  /// **'Full backup'**
  String get helpBackupStep1Title;

  /// Backup & restore help step 1 body.
  ///
  /// In en, this message translates to:
  /// **'Saves your watchlist, holdings, custom tickers and settings as a .json file.'**
  String get helpBackupStep1Body;

  /// Backup & restore help step 2 title.
  ///
  /// In en, this message translates to:
  /// **'Add a password'**
  String get helpBackupStep2Title;

  /// Backup & restore help step 2 body.
  ///
  /// In en, this message translates to:
  /// **'Optional. You\'ll need it to restore, and it can\'t be recovered.'**
  String get helpBackupStep2Body;

  /// Backup & restore help step 3 title.
  ///
  /// In en, this message translates to:
  /// **'Save or share'**
  String get helpBackupStep3Title;

  /// Backup & restore help step 3 body.
  ///
  /// In en, this message translates to:
  /// **'Keep the file in Files or iCloud Drive, or send it to yourself.'**
  String get helpBackupStep3Body;

  /// Backup & restore help step 4 title.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get helpBackupStep4Title;

  /// Backup & restore help step 4 body.
  ///
  /// In en, this message translates to:
  /// **'Import a .json backup. Merge adds what\'s missing and deletes nothing; Replace swaps everything for the file.'**
  String get helpBackupStep4Body;

  /// Backup & restore help step 5 title.
  ///
  /// In en, this message translates to:
  /// **'Holdings spreadsheet'**
  String get helpBackupStep5Title;

  /// Backup & restore help step 5 body.
  ///
  /// In en, this message translates to:
  /// **'A .csv for accounting. It can\'t be restored.'**
  String get helpBackupStep5Body;

  /// Widgets help topic title (iOS only).
  ///
  /// In en, this message translates to:
  /// **'Widgets'**
  String get helpWidgetsTitle;

  /// Widgets help topic summary line.
  ///
  /// In en, this message translates to:
  /// **'Put live prices and your portfolio on the Home Screen and Lock Screen.'**
  String get helpWidgetsSummary;

  /// Widgets help step 1 title.
  ///
  /// In en, this message translates to:
  /// **'Touch and hold the Home Screen'**
  String get helpWidgetsStep1Title;

  /// Widgets help step 1 body.
  ///
  /// In en, this message translates to:
  /// **'When the apps jiggle, tap Edit, then Add Widget.'**
  String get helpWidgetsStep1Body;

  /// Widgets help step 2 title.
  ///
  /// In en, this message translates to:
  /// **'Find Qima'**
  String get helpWidgetsStep2Title;

  /// Widgets help step 2 body.
  ///
  /// In en, this message translates to:
  /// **'Search for Qima, choose Price or Portfolio, pick a size and tap Add Widget.'**
  String get helpWidgetsStep2Body;

  /// Widgets help step 3 title.
  ///
  /// In en, this message translates to:
  /// **'Choose what it shows'**
  String get helpWidgetsStep3Title;

  /// Widgets help step 3 body.
  ///
  /// In en, this message translates to:
  /// **'Touch and hold the widget, tap Edit Widget, then pick asset, unit, karat, currency and chart range.'**
  String get helpWidgetsStep3Body;

  /// Widgets help step 4 title.
  ///
  /// In en, this message translates to:
  /// **'Lock Screen'**
  String get helpWidgetsStep4Title;

  /// Widgets help step 4 body.
  ///
  /// In en, this message translates to:
  /// **'Touch and hold the Lock Screen, tap Customize, then add a Qima widget.'**
  String get helpWidgetsStep4Body;

  /// Widgets help topic footnote.
  ///
  /// In en, this message translates to:
  /// **'Widgets refresh every 15 minutes by default. Change it in Settings under Widget refresh interval.'**
  String get helpWidgetsNote;

  /// Holdings list help topic title.
  ///
  /// In en, this message translates to:
  /// **'Holdings'**
  String get helpHoldingsTitle;

  /// Holdings list help topic summary line.
  ///
  /// In en, this message translates to:
  /// **'Every lot you bought of this asset, and what they add up to.'**
  String get helpHoldingsSummary;

  /// Holdings list help step 1 title.
  ///
  /// In en, this message translates to:
  /// **'Read the totals'**
  String get helpHoldingsStep1Title;

  /// Holdings list help step 1 body.
  ///
  /// In en, this message translates to:
  /// **'Quantity, average cost, current value and gain across every lot.'**
  String get helpHoldingsStep1Body;

  /// Holdings list help step 2 title.
  ///
  /// In en, this message translates to:
  /// **'Add a lot'**
  String get helpHoldingsStep2Title;

  /// Holdings list help step 2 body.
  ///
  /// In en, this message translates to:
  /// **'Tap + to record another purchase.'**
  String get helpHoldingsStep2Body;

  /// Holdings list help step 3 title.
  ///
  /// In en, this message translates to:
  /// **'Edit or delete a lot'**
  String get helpHoldingsStep3Title;

  /// Holdings list help step 3 body.
  ///
  /// In en, this message translates to:
  /// **'Tap a lot to change it, or swipe to delete.'**
  String get helpHoldingsStep3Body;

  /// Card config help topic title.
  ///
  /// In en, this message translates to:
  /// **'Asset settings'**
  String get helpCardConfigTitle;

  /// Card config help topic summary line.
  ///
  /// In en, this message translates to:
  /// **'Choose the currency, unit and karat this card shows before adding it.'**
  String get helpCardConfigSummary;

  /// Card config help step 1 title.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get helpCardConfigStep1Title;

  /// Card config help step 1 body.
  ///
  /// In en, this message translates to:
  /// **'Prices show in this currency on the card and its chart.'**
  String get helpCardConfigStep1Body;

  /// Card config help step 2 title.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get helpCardConfigStep2Title;

  /// Card config help step 2 body.
  ///
  /// In en, this message translates to:
  /// **'For metals, pick troy ounce, gram or kilogram.'**
  String get helpCardConfigStep2Body;

  /// Card config help step 3 title.
  ///
  /// In en, this message translates to:
  /// **'Karat'**
  String get helpCardConfigStep3Title;

  /// Card config help step 3 body.
  ///
  /// In en, this message translates to:
  /// **'For gold by weight, pick the purity you want priced.'**
  String get helpCardConfigStep3Body;

  /// Card config help step 4 title.
  ///
  /// In en, this message translates to:
  /// **'Add it'**
  String get helpCardConfigStep4Title;

  /// Card config help step 4 body.
  ///
  /// In en, this message translates to:
  /// **'You can change any of these later from the asset detail screen.'**
  String get helpCardConfigStep4Body;

  /// Custom ticker help topic title.
  ///
  /// In en, this message translates to:
  /// **'Custom ticker'**
  String get helpCustomTickerTitle;

  /// Custom ticker help topic summary line.
  ///
  /// In en, this message translates to:
  /// **'Track a stock, ETF or index that isn\'t in Qima\'s catalog by its symbol.'**
  String get helpCustomTickerSummary;

  /// Custom ticker help step 1 title.
  ///
  /// In en, this message translates to:
  /// **'Enter the symbol'**
  String get helpCustomTickerStep1Title;

  /// Custom ticker help step 1 body.
  ///
  /// In en, this message translates to:
  /// **'Type the exact ticker symbol, like TSLA or VOO.'**
  String get helpCustomTickerStep1Body;

  /// Custom ticker help step 2 title.
  ///
  /// In en, this message translates to:
  /// **'Qima checks it'**
  String get helpCustomTickerStep2Title;

  /// Custom ticker help step 2 body.
  ///
  /// In en, this message translates to:
  /// **'It\'s looked up with the price provider first, so a typo is caught before it\'s added.'**
  String get helpCustomTickerStep2Body;

  /// Custom ticker help step 3 title.
  ///
  /// In en, this message translates to:
  /// **'Add it'**
  String get helpCustomTickerStep3Title;

  /// Custom ticker help step 3 body.
  ///
  /// In en, this message translates to:
  /// **'It\'s added to your watchlist with its real name and price.'**
  String get helpCustomTickerStep3Body;

  /// Currency picker help topic title.
  ///
  /// In en, this message translates to:
  /// **'Currency picker'**
  String get helpCurrencyPickerTitle;

  /// Currency picker help topic summary line.
  ///
  /// In en, this message translates to:
  /// **'Pick the currency prices and totals should show in.'**
  String get helpCurrencyPickerSummary;

  /// Currency picker help step 1 title.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get helpCurrencyPickerStep1Title;

  /// Currency picker help step 1 body.
  ///
  /// In en, this message translates to:
  /// **'Type an ISO code or a currency name, like EUR or dirham.'**
  String get helpCurrencyPickerStep1Body;

  /// Currency picker help step 2 title.
  ///
  /// In en, this message translates to:
  /// **'Pick one'**
  String get helpCurrencyPickerStep2Title;

  /// Currency picker help step 2 body.
  ///
  /// In en, this message translates to:
  /// **'Tap a currency to use it immediately.'**
  String get helpCurrencyPickerStep2Body;

  /// Import preview help topic title.
  ///
  /// In en, this message translates to:
  /// **'Restore preview'**
  String get helpImportPreviewTitle;

  /// Import preview help topic summary line.
  ///
  /// In en, this message translates to:
  /// **'See what\'s in a backup file before it changes anything on this phone.'**
  String get helpImportPreviewSummary;

  /// Import preview help step 1 title.
  ///
  /// In en, this message translates to:
  /// **'Check the contents'**
  String get helpImportPreviewStep1Title;

  /// Import preview help step 1 body.
  ///
  /// In en, this message translates to:
  /// **'See how many cards, lots and alerts the file contains before restoring.'**
  String get helpImportPreviewStep1Body;

  /// Import preview help step 2 title.
  ///
  /// In en, this message translates to:
  /// **'Merge or Replace'**
  String get helpImportPreviewStep2Title;

  /// Import preview help step 2 body.
  ///
  /// In en, this message translates to:
  /// **'Merge adds what\'s missing and deletes nothing. Replace swaps everything for the file.'**
  String get helpImportPreviewStep2Body;

  /// Import preview help step 3 title.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get helpImportPreviewStep3Title;

  /// Import preview help step 3 body.
  ///
  /// In en, this message translates to:
  /// **'A password-protected file asks for its password first.'**
  String get helpImportPreviewStep3Body;

  /// Settings "Help" group section header (last group).
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get settingsHelpGroup;

  /// Settings Help group row title.
  ///
  /// In en, this message translates to:
  /// **'Replay the tour'**
  String get settingsHelpReplayTour;

  /// Settings Help group row subtitle.
  ///
  /// In en, this message translates to:
  /// **'See the five-step introduction again'**
  String get settingsHelpReplayTourSubtitle;

  /// Settings Help group row title.
  ///
  /// In en, this message translates to:
  /// **'How Qima works'**
  String get settingsHelpHowQimaWorks;

  /// Settings Help group row subtitle.
  ///
  /// In en, this message translates to:
  /// **'A short guide to every page'**
  String get settingsHelpHowQimaWorksSubtitle;

  /// Settings Help group row title (iOS only).
  ///
  /// In en, this message translates to:
  /// **'Add a widget'**
  String get settingsHelpAddWidget;

  /// Settings Help group row subtitle (iOS only).
  ///
  /// In en, this message translates to:
  /// **'Home Screen and Lock Screen'**
  String get settingsHelpAddWidgetSubtitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'es', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
