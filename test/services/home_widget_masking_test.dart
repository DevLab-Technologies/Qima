import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qima/blocs/app_state.dart';
import 'package:qima/models/asset.dart';
import 'package:qima/models/fx_history.dart';
import 'package:qima/models/holding.dart';
import 'package:qima/models/instrument_catalog.dart';
import 'package:qima/models/money.dart';
import 'package:qima/models/quote.dart';
import 'package:qima/services/home_widget_service.dart';
import 'package:qima/services/widget_snapshot.dart';

/// Phase 4 "Hide balances": [HomeWidgetService] publishes the ONE widget
/// snapshot (iOS, macOS and Android all read it — see the class doc), and
/// it always carries [AppState.hideBalances] verbatim (`widget_snapshot_test.dart`
/// covers that in detail). Each native widget masks the amount itself from
/// that flag; there's no Dart-side masked payload left to test here, so
/// this file only guards that publishing still writes the snapshot with the
/// flag intact and reloads every widget kind.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('home_widget');
  final gold = InstrumentCatalog.instrument('metal.XAU')!;

  Map<String, dynamic>? lastSnapshotPayload;
  final updatedWidgetNames = <String?>[];

  setUp(() {
    lastSnapshotPayload = null;
    updatedWidgetNames.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (call) async {
      switch (call.method) {
        case 'saveWidgetData':
          final args = Map<String, dynamic>.from(call.arguments as Map);
          if (args['id'] == WidgetSnapshot.storageKey) {
            lastSnapshotPayload = jsonDecode(args['data'] as String) as Map<String, dynamic>;
          }
          return true;
        case 'updateWidget':
          final args = Map<String, dynamic>.from(call.arguments as Map);
          updatedWidgetNames.add(args['qualifiedAndroidName'] as String? ?? args['ios'] as String?);
          return null;
        default:
          return null;
      }
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  AppState stateWithLot({required bool hideBalances}) {
    final now = DateTime(2024, 6, 10);
    final lots = [
      HoldingLot(
        id: 'l1',
        instrumentID: gold.id,
        quantity: 2,
        unit: PriceUnit.troyOunce,
        unitCost: 1900,
        costCurrency: 'USD',
        date: DateTime(2024, 5, 1),
      ),
    ];
    final seriesByID = {
      gold.id: QuoteSeries(instrumentID: gold.id, quotes: [
        Quote(instrumentID: gold.id, timestamp: now, canonicalUSD: 2000),
      ]),
    };
    return AppState(
      initialized: true,
      lots: lots,
      seriesByID: seriesByID,
      rates: FXRates(base: 'USD', rates: const {'USD': 1}, updatedAt: now),
      fxHistory: FXHistory.empty,
      baseCurrency: 'USD',
      hideBalances: hideBalances,
    );
  }

  test('publishes the snapshot with hideBalances off', () async {
    await HomeWidgetService.publish(stateWithLot(hideBalances: false));

    expect(lastSnapshotPayload, isNotNull);
    expect(lastSnapshotPayload!['hideBalances'], isFalse);
    expect(lastSnapshotPayload!['portfolio']['available'], isTrue);
  });

  test('publishes the snapshot with hideBalances on, and reloads every Android widget kind', () async {
    // The test host's default `defaultTargetPlatform` is `android`, so this
    // also exercises the platform switch in `publish` (the iOS-only
    // Watchlist reload is skipped, same as on a real Android device).
    await HomeWidgetService.publish(stateWithLot(hideBalances: true));

    expect(lastSnapshotPayload, isNotNull);
    expect(lastSnapshotPayload!['hideBalances'], isTrue);
    expect(
      updatedWidgetNames,
      containsAll(<String>[
        'com.devlabtechnologies.qima.widget.PriceGlanceReceiver',
        'com.devlabtechnologies.qima.widget.PortfolioGlanceReceiver',
      ]),
    );
  });
}
