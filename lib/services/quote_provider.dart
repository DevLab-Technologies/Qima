import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/asset.dart';
import '../models/money.dart';

/// Errors surfaced by a [QuoteProvider].
class PriceError implements Exception {
  final String kind; // 'unsupportedInstrument' | 'invalidResponse' | 'decodingFailed'
  final String? detail;

  const PriceError.unsupportedInstrument(String symbol)
      : kind = 'unsupportedInstrument',
        detail = symbol;

  const PriceError.invalidResponse()
      : kind = 'invalidResponse',
        detail = null;

  const PriceError.decodingFailed()
      : kind = 'decodingFailed',
        detail = null;

  @override
  String toString() => detail == null ? 'PriceError.$kind' : 'PriceError.$kind($detail)';
}

/// Fetches a live spot price for an instrument, expressed in canonical USD.
abstract class QuoteProvider {
  bool supports(AssetClass assetClass);

  Future<double> canonicalUSDPrice(Instrument instrument);
}

const _userAgentHeader = {'User-Agent': 'Mozilla/5.0'};

/// GBp/GBX (London pence quoting) quirk: treat as GBP at 1/100 scale.
({String code, double scale}) _normalizeCurrency(String currency) {
  if (currency == 'GBp' || currency == 'GBX') {
    return (code: 'GBP', scale: 0.01);
  }
  return (code: currency.toUpperCase(), scale: 1);
}

double _toUSD(double price, String currency, FXRates rates) {
  final normalized = _normalizeCurrency(currency);
  if (normalized.code == 'USD') return price * normalized.scale;
  final rate = rates.rate(normalized.code);
  if (rate == null || rate == 0) {
    throw PriceError.unsupportedInstrument(normalized.code);
  }
  return (price * normalized.scale) / rate;
}

/// Metal/crypto spot prices via gold-api.com (keyless).
class GoldAPIProvider implements QuoteProvider {
  final http.Client client;
  final String baseUrl;

  GoldAPIProvider({http.Client? client, this.baseUrl = 'https://api.gold-api.com'})
      : client = client ?? http.Client();

  @override
  bool supports(AssetClass assetClass) => assetClass == AssetClass.metal || assetClass == AssetClass.crypto;

  @override
  Future<double> canonicalUSDPrice(Instrument instrument) async {
    final uri = Uri.parse('$baseUrl/price/${instrument.sourceSymbol}');
    final response = await client.get(uri);
    if (response.statusCode != 200) throw const PriceError.invalidResponse();
    try {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final price = json['price'];
      if (price is num) return price.toDouble();
      throw const PriceError.decodingFailed();
    } on FormatException {
      throw const PriceError.decodingFailed();
    }
  }
}

/// Fiat-to-fiat "quotes": expresses 1 unit of the instrument's currency in
/// USD via the live rate table.
class FiatQuoteProvider implements QuoteProvider {
  final FXRates rates;

  const FiatQuoteProvider(this.rates);

  @override
  bool supports(AssetClass assetClass) => assetClass == AssetClass.fiat;

  @override
  Future<double> canonicalUSDPrice(Instrument instrument) async {
    final rate = rates.rate(instrument.symbol);
    if (rate == null || rate == 0) {
      throw PriceError.unsupportedInstrument(instrument.symbol);
    }
    return 1 / rate;
  }
}

/// Equity/index spot prices via Yahoo Finance's unofficial chart endpoint.
class YahooQuoteProvider implements QuoteProvider {
  final FXRates rates;
  final http.Client client;
  final String baseUrl;

  YahooQuoteProvider(
    this.rates, {
    http.Client? client,
    this.baseUrl = 'https://query1.finance.yahoo.com/v8/finance/chart',
  }) : client = client ?? http.Client();

  @override
  bool supports(AssetClass assetClass) => assetClass == AssetClass.stock || assetClass == AssetClass.indices;

  @override
  Future<double> canonicalUSDPrice(Instrument instrument) async {
    final uri = Uri.parse('$baseUrl/${Uri.encodeComponent(instrument.sourceSymbol)}');
    final response = await client.get(uri, headers: _userAgentHeader);
    if (response.statusCode != 200) throw const PriceError.invalidResponse();
    try {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final result = ((json['chart'] as Map<String, dynamic>)['result'] as List<dynamic>);
      if (result.isEmpty) throw const PriceError.decodingFailed();
      final meta = (result.first as Map<String, dynamic>)['meta'] as Map<String, dynamic>;
      final price = (meta['regularMarketPrice'] as num).toDouble();
      final currency = meta['currency'] as String;
      return _toUSD(price, currency, rates);
    } on PriceError {
      rethrow;
    } catch (_) {
      throw const PriceError.decodingFailed();
    }
  }
}

/// A single historical price bar.
class Bar {
  final DateTime date;
  final double close;
  final String currency;

  const Bar({required this.date, required this.close, required this.currency});
}

/// Historical bars via Yahoo Finance's unofficial chart endpoint. Never
/// throws — returns an empty list on any failure so a bad symbol never
/// blocks a batch backfill.
class YahooHistoryProvider {
  final http.Client client;
  final String baseUrl;

  YahooHistoryProvider({http.Client? client, this.baseUrl = 'https://query1.finance.yahoo.com/v8/finance/chart'})
      : client = client ?? http.Client();

  Future<List<Bar>> bars(String symbol, {String range = '5y', String interval = '1d'}) async {
    try {
      final uri = Uri.parse('$baseUrl/${Uri.encodeComponent(symbol)}?range=$range&interval=$interval');
      final response = await client.get(uri, headers: _userAgentHeader);
      if (response.statusCode != 200) return const [];
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final results = (json['chart'] as Map<String, dynamic>)['result'] as List<dynamic>?;
      if (results == null || results.isEmpty) return const [];
      final result = results.first as Map<String, dynamic>;
      final meta = result['meta'] as Map<String, dynamic>;
      final currency = meta['currency'] as String? ?? 'USD';
      final timestamps = (result['timestamp'] as List<dynamic>?)?.cast<num>() ?? const [];
      final quoteList = (result['indicators'] as Map<String, dynamic>)['quote'] as List<dynamic>;
      final closes = (quoteList.first as Map<String, dynamic>)['close'] as List<dynamic>;

      final out = <Bar>[];
      for (var i = 0; i < timestamps.length && i < closes.length; i++) {
        final close = closes[i];
        if (close == null) continue;
        final date = DateTime.fromMillisecondsSinceEpoch(timestamps[i].toInt() * 1000, isUtc: true);
        out.add(Bar(date: date, close: (close as num).toDouble(), currency: currency));
      }
      return out;
    } catch (_) {
      return const [];
    }
  }
}

/// Live FX rates via open.er-api.com (keyless).
class ExchangeRateAPIProvider {
  final http.Client client;
  final String baseUrl;

  ExchangeRateAPIProvider({http.Client? client, this.baseUrl = 'https://open.er-api.com/v6/latest/USD'})
      : client = client ?? http.Client();

  Future<FXRates> latestRates() async {
    final response = await client.get(Uri.parse(baseUrl));
    if (response.statusCode != 200) throw const PriceError.invalidResponse();
    try {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      if (json['result'] != 'success') throw const PriceError.decodingFailed();
      final rawRates = json['rates'] as Map<String, dynamic>;
      final rates = rawRates.map((k, v) => MapEntry(k, (v as num).toDouble()));
      return FXRates(base: 'USD', rates: rates, updatedAt: DateTime.now());
    } on PriceError {
      rethrow;
    } catch (_) {
      throw const PriceError.decodingFailed();
    }
  }
}

/// USD-to-external conversion helper shared by history backfill (handles the
/// GBp/GBX pence quirk identically to the live quote providers).
double usdFromPrice(double price, String currency, FXRates rates) => _toUSD(price, currency, rates);
