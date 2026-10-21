import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../models/asset_group.dart';
import '../models/hijri_date.dart';

/// Resolves the model layer's dotted localization keys (e.g. `asset.gold`,
/// `unit.troyOunce`) to real translated text via the generated
/// [AppLocalizations] class.
///
/// Custom-ticker instruments store their literal display name directly as
/// `nameKey` (not a lookup key, per spec §1.8) — unresolved keys fall back
/// to the key text itself, which is exactly right for that case.
///
/// A handful of call sites (the metal-breakdown card) build a *compound*
/// label out of two dotted keys joined by a space (e.g.
/// `'karat.short.24 unit.abbr.gram'`). When the whole string doesn't match a
/// known key, we also try resolving it as space-joined sub-keys so those
/// still translate correctly, while genuinely-unknown text (a custom
/// instrument's freeform name) still falls through untouched.
String displayLabel(BuildContext context, String key) {
  final loc = AppLocalizations.of(context)!;
  return displayLabelFor(loc, key);
}

/// [displayLabel] without a [BuildContext] — used where a real widget tree
/// isn't available, such as a background isolate's notification text (spec
/// Phase 5 `RefreshPipeline`/`NotificationService`), which resolves an
/// [AppLocalizations] instance directly via
/// `AppLocalizations.delegate.load(locale)` instead.
String displayLabelFor(AppLocalizations loc, String key) {
  final resolved = _resolve(loc, key);
  if (resolved != null) return resolved;

  if (key.contains(' ')) {
    return key.split(' ').map((part) => _resolve(loc, part) ?? part).join(' ');
  }

  return key;
}

String? _resolve(AppLocalizations loc, String key) {
  switch (key) {
    // Asset classes
    case 'assetClass.metal':
      return loc.assetClassMetal;
    case 'assetClass.crypto':
      return loc.assetClassCrypto;
    case 'assetClass.stock':
      return loc.assetClassStock;
    case 'assetClass.index':
      return loc.assetClassIndex;
    case 'assetClass.fiat':
      return loc.assetClassFiat;

    // Assets
    case 'asset.gold':
      return loc.assetGold;
    case 'asset.silver':
      return loc.assetSilver;
    case 'asset.platinum':
      return loc.assetPlatinum;
    case 'asset.palladium':
      return loc.assetPalladium;
    case 'asset.bitcoin':
      return loc.assetBitcoin;
    case 'asset.ethereum':
      return loc.assetEthereum;
    case 'asset.apple':
      return loc.assetApple;
    case 'asset.microsoft':
      return loc.assetMicrosoft;
    case 'asset.nvidia':
      return loc.assetNvidia;
    case 'asset.amazon':
      return loc.assetAmazon;
    case 'asset.tesla':
      return loc.assetTesla;
    case 'asset.alphabet':
      return loc.assetAlphabet;
    case 'asset.sp500':
      return loc.assetSp500;
    case 'asset.dowJones':
      return loc.assetDowJones;
    case 'asset.nasdaq':
      return loc.assetNasdaq;
    case 'asset.russell2000':
      return loc.assetRussell2000;
    case 'asset.ftse100':
      return loc.assetFtse100;
    case 'asset.nikkei225':
      return loc.assetNikkei225;
    case 'asset.dax':
      return loc.assetDax;
    case 'asset.usDollar':
      return loc.assetUsDollar;
    case 'asset.euro':
      return loc.assetEuro;
    case 'asset.britishPound':
      return loc.assetBritishPound;
    case 'asset.egyptianPound':
      return loc.assetEgyptianPound;
    case 'asset.saudiRiyal':
      return loc.assetSaudiRiyal;
    case 'asset.emiratiDirham':
      return loc.assetEmiratiDirham;
    case 'asset.qatariRiyal':
      return loc.assetQatariRiyal;
    case 'asset.kuwaitiDinar':
      return loc.assetKuwaitiDinar;
    case 'asset.omaniRial':
      return loc.assetOmaniRial;
    case 'asset.bahrainiDinar':
      return loc.assetBahrainiDinar;
    case 'asset.jordanianDinar':
      return loc.assetJordanianDinar;

    // Units
    case 'unit.troyOunce':
      return loc.unitTroyOunce;
    case 'unit.gram':
      return loc.unitGram;
    case 'unit.kilogram':
      return loc.unitKilogram;
    case 'unit.each':
      return loc.unitEach;
    case 'unit.abbr.troyOunce':
      return loc.unitAbbrTroyOunce;
    case 'unit.abbr.gram':
      return loc.unitAbbrGram;
    case 'unit.abbr.kilogram':
      return loc.unitAbbrKilogram;

    // Karats
    case 'karat.short.24':
      return loc.karatShort24;
    case 'karat.short.22':
      return loc.karatShort22;
    case 'karat.short.21':
      return loc.karatShort21;
    case 'karat.short.18':
      return loc.karatShort18;

    // Chart ranges
    case 'range.1D':
      return loc.range1D;
    case 'range.3D':
      return loc.range3D;
    case 'range.7D':
      return loc.range7D;
    case 'range.1W':
      return loc.range1W;
    case 'range.1M':
      return loc.range1M;
    case 'range.3M':
      return loc.range3M;
    case 'range.6M':
      return loc.range6M;
    case 'range.ytd':
      return loc.rangeYtd;
    case 'range.1Y':
      return loc.range1Y;
    case 'range.5Y':
      return loc.range5Y;
    case 'range.all':
      return loc.rangeAll;

    // Widget refresh intervals
    case 'refresh.15m':
      return loc.refresh15m;
    case 'refresh.30m':
      return loc.refresh30m;
    case 'refresh.1h':
      return loc.refresh1h;
    case 'refresh.3h':
      return loc.refresh3h;
    case 'refresh.6h':
      return loc.refresh6h;

    case 'error.refreshFailed':
      return loc.errorRefreshFailed;

    // App lock grace periods
    case 'lockGrace.immediately':
      return loc.lockGraceImmediately;
    case 'lockGrace.1m':
      return loc.lockGrace1m;
    case 'lockGrace.5m':
      return loc.lockGrace5m;
    case 'lockGrace.15m':
      return loc.lockGrace15m;

    // Price alerts
    case 'alertKind.above':
      return loc.alertKindAbove;
    case 'alertKind.below':
      return loc.alertKindBelow;
    case 'alertKind.percentMove':
      return loc.alertKindPercentMove;
    case 'alertDirection.up':
      return loc.alertDirectionUp;
    case 'alertDirection.down':
      return loc.alertDirectionDown;
    case 'alertDirection.either':
      return loc.alertDirectionEither;
    case 'alertWindow.h24':
      return loc.alertWindowWithin24h;
    case 'alertWindow.d7':
      return loc.alertWindowWithin7d;

    default:
      return null;
  }
}

/// A signed figure (gain, change %) for display: prefixes "+" when [isUp]
/// (negatives already carry "-" from formatting) and isolates the result as
/// left-to-right, so in Arabic the sign stays attached to the number instead
/// of drifting to the far side ("67.05%+").
String signedFigure(String value, {required bool isUp}) => '\u2066${isUp ? '+' : ''}$value\u2069';

/// Localized name of Hijri [month] (1 = Muharram … 12 = Dhu al-Hijjah).
String hijriMonthName(AppLocalizations loc, int month) {
  switch (month) {
    case 1:
      return loc.hijriMonth1;
    case 2:
      return loc.hijriMonth2;
    case 3:
      return loc.hijriMonth3;
    case 4:
      return loc.hijriMonth4;
    case 5:
      return loc.hijriMonth5;
    case 6:
      return loc.hijriMonth6;
    case 7:
      return loc.hijriMonth7;
    case 8:
      return loc.hijriMonth8;
    case 9:
      return loc.hijriMonth9;
    case 10:
      return loc.hijriMonth10;
    case 11:
      return loc.hijriMonth11;
    default:
      return loc.hijriMonth12;
  }
}

/// "12 Ramadan 1446 AH" in the app's own month names.
String hijriDateLabel(AppLocalizations loc, HijriDate date) =>
    loc.hijriDate(date.day, hijriMonthName(loc, date.month), date.year);

/// A percentage such as 2.5 as "2.5%" in the app's locale (comma decimal in
/// French and Spanish), isolated left-to-right so Arabic doesn't render it
/// as "%2.5".
String percentLabel(BuildContext context, double percent) {
  final locale = Localizations.localeOf(context).toString();
  final number = (NumberFormat.decimalPattern(locale)..maximumFractionDigits = 3).format(percent);
  return '\u2066$number%\u2069';
}

/// "27 Feb 2026" in the app's locale. Unlike Material's `formatMediumDate`
/// this always shows the year, which a hawl date one year out needs. Digits
/// stay Western in Arabic, matching the amounts and Hijri dates beside it.
String dateWithYear(BuildContext context, DateTime date) =>
    (DateFormat.yMMMd(Localizations.localeOf(context).toString())..useNativeDigits = false).format(date);

/// "Metals", "Cash & currencies" — the label for an [AssetGroup].
String assetGroupLabel(AppLocalizations l10n, AssetGroup assetGroup) {
  switch (assetGroup) {
    case AssetGroup.metals:
      return l10n.assetGroupMetals;
    case AssetGroup.crypto:
      return l10n.assetGroupCrypto;
    case AssetGroup.equities:
      return l10n.assetGroupEquities;
    case AssetGroup.cash:
      return l10n.assetGroupCash;
  }
}
