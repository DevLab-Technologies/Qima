import 'asset.dart';
import 'metal_breakdown.dart';

/// Full registry of built-in instruments plus any user-added custom ones.
///
/// Mirrors `InstrumentCatalog.swift`. Custom instruments are supplied by the
/// caller (typically loaded from `CustomInstrumentStore`) via [reloadCustom];
/// built-ins always win on id clash.
class InstrumentCatalog {
  InstrumentCatalog._();

  static const List<Instrument> metals = [
    Instrument(
      id: 'metal.XAU',
      symbol: 'XAU',
      assetClass: AssetClass.metal,
      nameKey: 'asset.gold',
      supportedKarats: [GoldKarat.k24, GoldKarat.k22, GoldKarat.k21, GoldKarat.k18],
    ),
    Instrument(id: 'metal.XAG', symbol: 'XAG', assetClass: AssetClass.metal, nameKey: 'asset.silver'),
    Instrument(id: 'metal.XPT', symbol: 'XPT', assetClass: AssetClass.metal, nameKey: 'asset.platinum'),
    Instrument(id: 'metal.XPD', symbol: 'XPD', assetClass: AssetClass.metal, nameKey: 'asset.palladium'),
  ];

  static const List<Instrument> crypto = [
    Instrument(id: 'crypto.BTC', symbol: 'BTC', assetClass: AssetClass.crypto, nameKey: 'asset.bitcoin'),
    Instrument(id: 'crypto.ETH', symbol: 'ETH', assetClass: AssetClass.crypto, nameKey: 'asset.ethereum'),
  ];

  static const List<Instrument> stocks = [
    Instrument(id: 'stock.AAPL', symbol: 'AAPL', assetClass: AssetClass.stock, nameKey: 'asset.apple'),
    Instrument(id: 'stock.MSFT', symbol: 'MSFT', assetClass: AssetClass.stock, nameKey: 'asset.microsoft'),
    Instrument(id: 'stock.NVDA', symbol: 'NVDA', assetClass: AssetClass.stock, nameKey: 'asset.nvidia'),
    Instrument(id: 'stock.AMZN', symbol: 'AMZN', assetClass: AssetClass.stock, nameKey: 'asset.amazon'),
    Instrument(id: 'stock.TSLA', symbol: 'TSLA', assetClass: AssetClass.stock, nameKey: 'asset.tesla'),
    Instrument(id: 'stock.GOOGL', symbol: 'GOOGL', assetClass: AssetClass.stock, nameKey: 'asset.alphabet'),
  ];

  static const List<Instrument> indices = [
    Instrument(
      id: 'index.GSPC',
      symbol: 'S&P 500',
      assetClass: AssetClass.indices,
      nameKey: 'asset.sp500',
      sourceSymbol: '^GSPC',
    ),
    Instrument(
      id: 'index.DJI',
      symbol: 'Dow Jones',
      assetClass: AssetClass.indices,
      nameKey: 'asset.dowJones',
      sourceSymbol: '^DJI',
    ),
    Instrument(
      id: 'index.IXIC',
      symbol: 'Nasdaq',
      assetClass: AssetClass.indices,
      nameKey: 'asset.nasdaq',
      sourceSymbol: '^IXIC',
    ),
    Instrument(
      id: 'index.RUT',
      symbol: 'Russell 2000',
      assetClass: AssetClass.indices,
      nameKey: 'asset.russell2000',
      sourceSymbol: '^RUT',
    ),
    Instrument(
      id: 'index.FTSE',
      symbol: 'FTSE 100',
      assetClass: AssetClass.indices,
      nameKey: 'asset.ftse100',
      sourceSymbol: '^FTSE',
    ),
    Instrument(
      id: 'index.N225',
      symbol: 'Nikkei 225',
      assetClass: AssetClass.indices,
      nameKey: 'asset.nikkei225',
      sourceSymbol: '^N225',
    ),
    Instrument(
      id: 'index.GDAXI',
      symbol: 'DAX',
      assetClass: AssetClass.indices,
      nameKey: 'asset.dax',
      sourceSymbol: '^GDAXI',
    ),
  ];

  static const List<Instrument> fiat = [
    Instrument(id: 'fx.USD', symbol: 'USD', assetClass: AssetClass.fiat, nameKey: 'asset.usDollar'),
    Instrument(id: 'fx.EUR', symbol: 'EUR', assetClass: AssetClass.fiat, nameKey: 'asset.euro'),
    Instrument(id: 'fx.GBP', symbol: 'GBP', assetClass: AssetClass.fiat, nameKey: 'asset.britishPound'),
    Instrument(id: 'fx.EGP', symbol: 'EGP', assetClass: AssetClass.fiat, nameKey: 'asset.egyptianPound'),
    Instrument(id: 'fx.SAR', symbol: 'SAR', assetClass: AssetClass.fiat, nameKey: 'asset.saudiRiyal'),
    Instrument(id: 'fx.AED', symbol: 'AED', assetClass: AssetClass.fiat, nameKey: 'asset.emiratiDirham'),
    Instrument(id: 'fx.QAR', symbol: 'QAR', assetClass: AssetClass.fiat, nameKey: 'asset.qatariRiyal'),
    Instrument(id: 'fx.KWD', symbol: 'KWD', assetClass: AssetClass.fiat, nameKey: 'asset.kuwaitiDinar'),
    Instrument(id: 'fx.OMR', symbol: 'OMR', assetClass: AssetClass.fiat, nameKey: 'asset.omaniRial'),
    Instrument(id: 'fx.BHD', symbol: 'BHD', assetClass: AssetClass.fiat, nameKey: 'asset.bahrainiDinar'),
    Instrument(id: 'fx.JOD', symbol: 'JOD', assetClass: AssetClass.fiat, nameKey: 'asset.jordanianDinar'),
  ];

  static List<Instrument> get builtIn => [...metals, ...crypto, ...stocks, ...indices, ...fiat];

  static const List<String> defaultWatchlist = ['metal.XAU', 'metal.XAG', 'crypto.BTC'];

  static List<Instrument> _custom = const [];

  /// Replaces the cached custom-instrument list (e.g. after loading from
  /// `CustomInstrumentStore`).
  static void reloadCustom(List<Instrument> custom) {
    _custom = custom;
  }

  static List<Instrument> get custom => _custom;

  /// Built-ins plus any custom instruments not already present by id
  /// (built-ins win on clash).
  static List<Instrument> get all {
    final builtInIds = builtIn.map((i) => i.id).toSet();
    return [...builtIn, ..._custom.where((i) => !builtInIds.contains(i.id))];
  }

  static Instrument? instrument(String id) {
    for (final instrument in all) {
      if (instrument.id == id) return instrument;
    }
    return null;
  }

  /// Resolves each id, silently dropping unresolvable ones while preserving
  /// order (TC-I4).
  static List<Instrument> instruments(List<String> ids) {
    final result = <Instrument>[];
    for (final id in ids) {
      final instrument = InstrumentCatalog.instrument(id);
      if (instrument != null) result.add(instrument);
    }
    return result;
  }
}
