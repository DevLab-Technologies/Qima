/// Everyday names for built-in instruments that their catalog labels don't
/// cover: spelling variants, colloquial names and the words people type at a
/// dealer's counter ("دهب", "dollar", "footsie"), in any of the four app
/// languages.
///
/// Search adds the catalog label in every app language to these, so "Oro"
/// finds gold from an English UI. The transaction parser reads these as
/// written, so a word here must not be an ordinary word in another language
/// (French "or" is left to the French label for that reason). Currency
/// words are for search only: the parser resolves those by family against
/// the base currency.
class InstrumentAliases {
  InstrumentAliases._();

  static const Map<String, List<String>> everyday = {
    'metal.XAU': ['gold', 'ذهب', 'دهب', 'oro'],
    'metal.XAG': ['silver', 'فضة', 'فضه', 'plata', 'argent'],
    'metal.XPT': ['platinum', 'بلاتين', 'بلاتينيوم', 'platino', 'platine'],
    'metal.XPD': ['palladium', 'بلاديوم', 'paladio'],
    'crypto.BTC': ['bitcoin', 'bitcoins', 'بيتكوين', 'بتكوين'],
    'crypto.ETH': ['ethereum', 'ether', 'إيثريوم', 'ايثريوم', 'إيثيريوم', 'ايثيريوم', 'إيثر', 'ايثر'],
    'stock.AAPL': ['apple', 'أبل', 'ابل', 'آبل'],
    'stock.MSFT': ['microsoft', 'مايكروسوفت', 'ميكروسوفت'],
    'stock.NVDA': ['nvidia', 'إنفيديا', 'انفيديا', 'نفيديا'],
    'stock.AMZN': ['amazon', 'أمازون', 'امازون'],
    'stock.TSLA': ['tesla', 'تسلا', 'تيسلا'],
    'stock.GOOGL': ['google', 'alphabet', 'جوجل', 'غوغل', 'ألفابت', 'الفابت'],
    'index.GSPC': ['s&p', 'sp500', 'spx', 'standard & poor', 'اس اند بي', 'ستاندرد آند بورز'],
    'index.DJI': ['dow', 'djia', 'داو'],
    'index.IXIC': ['nasdaq composite', 'ناسداك', 'نازداك'],
    'index.RUT': ['russell', 'راسل'],
    'index.FTSE': ['footsie', 'فوتسي'],
    'index.N225': ['nikkei', 'نيكاي', 'نيكي'],
    'index.GDAXI': ['داكس'],
    'fx.USD': ['dollar', 'dollars', 'greenback', 'دولار', 'dólar', 'dólares'],
    'fx.EUR': ['euro', 'euros', 'يورو'],
    'fx.GBP': ['pound sterling', 'sterling', 'إسترليني', 'استرليني', 'libra esterlina', 'livre sterling'],
    'fx.EGP': ['egyptian pound', 'جنيه', 'جنيه مصري', 'جنية'],
    'fx.SAR': ['saudi riyal', 'ريال', 'ريال سعودي'],
    'fx.AED': ['dirham', 'درهم', 'درهم إماراتي'],
    'fx.QAR': ['qatari riyal', 'ريال', 'ريال قطري'],
    'fx.KWD': ['kuwaiti dinar', 'دينار', 'دينار كويتي'],
    'fx.OMR': ['omani rial', 'ريال', 'ريال عماني'],
    'fx.BHD': ['bahraini dinar', 'دينار', 'دينار بحريني'],
    'fx.JOD': ['jordanian dinar', 'دينار', 'دينار أردني'],
  };

  static List<String> of(String instrumentId) => everyday[instrumentId] ?? const [];
}
