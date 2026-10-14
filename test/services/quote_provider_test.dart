import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:qima/models/asset.dart';
import 'package:qima/services/quote_provider.dart';

void main() {
  const gold = Instrument(id: 'metal.XAU', symbol: 'XAU', assetClass: AssetClass.metal, nameKey: 'asset.gold');

  group('GoldAPIProvider', () {
    test('sends a browser User-Agent, since gold-api.com rate-limits the Dart default', () async {
      String? userAgent;
      final client = MockClient((request) async {
        userAgent = request.headers['User-Agent'];
        return http.Response('{"price": 4153.0}', 200);
      });

      final price = await GoldAPIProvider(client: client).canonicalUSDPrice(gold);

      expect(price, 4153.0);
      expect(userAgent, isNotNull);
      expect(userAgent, isNot(startsWith('Dart/')));
    });

    test('throws on a 429 so the refresh records no stale price', () async {
      final client = MockClient((_) async => http.Response('Too Many Requests', 429));

      expect(
        GoldAPIProvider(client: client).canonicalUSDPrice(gold),
        throwsA(isA<PriceError>().having((e) => e.kind, 'kind', 'invalidResponse')),
      );
    });
  });
}
