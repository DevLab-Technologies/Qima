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

  /// No description provided for @addTitle.
  ///
  /// In en, this message translates to:
  /// **'Add instrument'**
  String get addTitle;

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
