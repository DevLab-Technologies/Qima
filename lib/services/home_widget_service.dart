import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

import '../blocs/app_state.dart';
import '../models/holding.dart';
import '../models/instrument_presentation.dart';
import '../models/quote.dart';
import '../models/watch_card.dart';
import '../services/price_converter.dart';
import '../theme/instrument_theme.dart';

/// Bridges [AppState] to the native home-screen widgets via the
/// `home_widget` plugin.
///
/// ## Data contract
///
/// This app does not yet have OS-level per-widget-instance configuration
/// wired up (that requires an Android "Configuration Activity" and an iOS
/// `AppIntentConfiguration`, both of which are native-only surfaces a
/// Flutter app cannot define without a platform extension — see
/// `WIDGETS_IOS_SETUP.md` at the project root). Until that lands, every
/// placed widget shows the SAME snapshot:
///
/// - **Price widget** mirrors the FIRST card in the user's watchlist
///   (`AppState.cards.first`), in that card's own configured
///   currency/unit/karat. There is no per-widget instrument picker yet.
/// - **Portfolio widget** mirrors the user's base currency
///   (`AppState.baseCurrency`).
///
/// Both are written as a single JSON blob per widget kind under one string
/// key each (`price_widget_data` / `portfolio_widget_data`), because
/// `home_widget`'s underlying storage (`SharedPreferences` on Android,
/// `UserDefaults`/app-group container on iOS/macOS) is a flat string/number
/// key-value store — a small JSON envelope keeps the two platforms'
/// widget code reading one shape instead of several ad hoc keys that could
/// drift out of sync with each other.
///
/// Precomputing everything to plain strings/numbers here (rather than
/// letting native code recompute money formatting, trend arrows, etc.)
/// keeps ALL business logic — magnitude-band formatting, RangeChange
/// guard rules, sparkline windowing — inside the already-tested Dart
/// layer. Native widget code is a pure renderer.
class HomeWidgetService {
  HomeWidgetService._();

  static const priceWidgetDataKey = 'price_widget_data';
  static const portfolioWidgetDataKey = 'portfolio_widget_data';

  /// Android Glance receiver class names, used by [HomeWidget.updateWidget]
  /// to target the right provider. iOS/macOS widgets are identified by
  /// their WidgetKit kind string instead (see `iOSName`).
  static const _androidPricePackage = 'com.devlabtechnologies.qima';
  static const _priceReceiverClass = '$_androidPricePackage.widget.PriceGlanceReceiver';
  static const _portfolioReceiverClass = '$_androidPricePackage.widget.PortfolioGlanceReceiver';

  /// Recomputes both widget payloads from the latest [AppState] and pushes
  /// them to native storage, then asks the OS to redraw any placed
  /// instances. Called from [AppCubit] after every successful refresh.
  ///
  /// Every step is best-effort: a widget write failing (e.g. the platform
  /// channel is unavailable in a unit test, or a platform simply doesn't
  /// support home_widget) must never surface as an app-visible error, since
  /// this is a background side effect of an otherwise-successful refresh.
  static Future<void> publish(AppState state) async {
    try {
      await _publishPrice(state);
    } catch (e, st) {
      debugPrint('HomeWidgetService: price widget publish failed: $e\n$st');
    }
    try {
      await _publishPortfolio(state);
    } catch (e, st) {
      debugPrint('HomeWidgetService: portfolio widget publish failed: $e\n$st');
    }
  }

  static Future<void> _publishPrice(AppState state) async {
    if (state.cards.isEmpty) {
      await HomeWidget.saveWidgetData<String>(priceWidgetDataKey, jsonEncode({'available': false}));
    } else {
      final card = state.cards.first;
      final payload = _priceSnapshot(card, state);
      await HomeWidget.saveWidgetData<String>(priceWidgetDataKey, jsonEncode(payload));
    }
    await HomeWidget.updateWidget(
      name: 'PriceGlanceReceiver',
      androidName: _priceReceiverClass,
      qualifiedAndroidName: _priceReceiverClass,
      iOSName: 'PriceWidget',
    );
  }

  static Future<void> _publishPortfolio(AppState state) async {
    final valuation = HoldingValuation.aggregate(
      lots: state.lots,
      rates: state.rates,
      displayCurrency: state.baseCurrency,
      latestUSD: (id) => state.seriesByID[id]?.latest?.canonicalUSD,
    );
    if (valuation == null) {
      await HomeWidget.saveWidgetData<String>(portfolioWidgetDataKey, jsonEncode({'available': false}));
    } else {
      final payload = {
        'available': true,
        'currency': state.baseCurrency,
        'value': valuation.value.formatted(),
        'cost': valuation.cost.formatted(),
        'gain': valuation.gain.formatted(),
        'percent': (valuation.gainFraction * 100),
        'isUp': valuation.isUp,
        'updatedAtMillis': DateTime.now().millisecondsSinceEpoch,
      };
      await HomeWidget.saveWidgetData<String>(portfolioWidgetDataKey, jsonEncode(payload));
    }
    await HomeWidget.updateWidget(
      name: 'PortfolioGlanceReceiver',
      androidName: _portfolioReceiverClass,
      qualifiedAndroidName: _portfolioReceiverClass,
      iOSName: 'PortfolioWidget',
    );
  }

  static Map<String, dynamic> _priceSnapshot(WatchCard card, AppState state) {
    final instrument = card.instrument;
    if (instrument == null) return {'available': false};

    // Mirrors `AppCubit.presentation` exactly (kept independent of AppCubit
    // itself so this service can be unit tested against a bare AppState).
    final converter = PriceConverter(
      rates: state.rates,
      currencyCode: card.currency,
      unit: card.unit,
      karat: card.karat,
      history: state.fxHistory,
    );
    final series = state.seriesByID[instrument.id] ?? QuoteSeries.empty(instrument.id);
    final presentation = InstrumentPresentation(
      instrument: instrument,
      series: series,
      converter: converter,
    );

    if (!presentation.isAvailable) {
      return {'available': false, 'symbol': instrument.symbol};
    }

    final now = DateTime.now();
    final sparkline = presentation.sparklinePoints(now);
    final change = presentation.sparklineChange(now);
    final accent = InstrumentTheme.accentColor(instrument);

    return {
      'available': true,
      'symbol': instrument.symbol,
      'currency': card.currency,
      'price': presentation.latestPrice,
      'compactPrice': presentation.compactPrice,
      'unitSuffix': presentation.unitSuffix ?? '',
      'karatLabel': presentation.karatLabel ?? '',
      'changePercent': change == null ? null : (change.percentValue * 100),
      'isUp': change?.isUp ?? presentation.isTrendingUp,
      'hasChange': change != null,
      'sparkline': sparkline.map((p) => p.value).toList(),
      'accentColor': accent.toARGB32(),
      'updatedAtMillis': now.millisecondsSinceEpoch,
    };
  }

}
