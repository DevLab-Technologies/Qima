import 'package:flutter/widgets.dart';

import '../l10n/app_localizations.dart';

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

    default:
      return null;
  }
}
