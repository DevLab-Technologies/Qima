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
import '../theme/masking.dart';
import '../theme/qima_colors.dart';
import 'widget_snapshot.dart';

/// Bridges [AppState] to the native home-screen widgets via the
/// `home_widget` plugin.
///
/// ## Data contract
///
/// - **iOS (WidgetKit)** reads one [WidgetSnapshot] under
///   [WidgetSnapshot.storageKey] in the shared App Group
///   ([appGroupID]). Every placed widget is configured on its own (asset,
///   unit, karat, currency, chart range) with an App Intent, so the
///   snapshot carries raw canonical-USD series and FX data and the
///   extension prices each configuration itself — see [WidgetSnapshot].
/// - **Android (Glance)** has no per-widget configuration yet and reads two
///   precomputed JSON blobs: the price widget mirrors the FIRST watchlist
///   card in its own currency/unit/karat (`price_widget_data`), the
///   portfolio widget mirrors the base currency (`portfolio_widget_data`).
///   Everything is formatted here so Glance code stays a pure renderer.
///
/// The Android blobs use each currency's fallback symbol: Glance renders with
/// system fonts, which on older OS versions have no glyph for the Saudi Riyal
/// sign. The iOS extension bundles the app's fonts and gets the real symbol.
class HomeWidgetService {
  HomeWidgetService._();

  /// Must match the App Group on the Runner and widget extension
  /// entitlements.
  static const appGroupID = 'group.com.devlabtechnologies.qima';

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
    // home_widget only implements iOS and Android; elsewhere every call
    // would just throw MissingPluginException.
    if (kIsWeb || (defaultTargetPlatform != TargetPlatform.iOS && defaultTargetPlatform != TargetPlatform.android)) {
      return;
    }
    try {
      // Idempotent; set on every publish because background refreshes run
      // in a fresh isolate that never went through app start-up.
      await HomeWidget.setAppGroupId(appGroupID);
      await _publishSnapshot(state);
    } catch (e, st) {
      debugPrint('HomeWidgetService: widget snapshot publish failed: $e\n$st');
    }
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

  /// iOS kinds, matching `kind` in the widget extension.
  static const iOSPriceKind = 'PriceWidget';
  static const iOSPortfolioKind = 'PortfolioWidget';

  static Future<void> _publishSnapshot(AppState state) async {
    if (defaultTargetPlatform != TargetPlatform.iOS) return;
    final snapshot = WidgetSnapshot.build(state, now: DateTime.now());
    await HomeWidget.saveWidgetData<String>(WidgetSnapshot.storageKey, jsonEncode(snapshot));
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
      iOSName: iOSPriceKind,
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
      final hidden = state.hideBalances;
      final payload = {
        'available': true,
        'currency': state.baseCurrency,
        'value': Masking.amount(valuation.value, hidden: hidden, useFallbackSymbol: true),
        'cost': Masking.amount(valuation.cost, hidden: hidden, useFallbackSymbol: true),
        'gain': Masking.amount(valuation.gain, hidden: hidden, useFallbackSymbol: true),
        // Percentages stay visible even when hidden, per spec.
        'percent': (valuation.gainFraction * 100),
        'isUp': valuation.isUp,
        'hidden': hidden,
        'updatedAtMillis': DateTime.now().millisecondsSinceEpoch,
      };
      await HomeWidget.saveWidgetData<String>(portfolioWidgetDataKey, jsonEncode(payload));
    }
    await HomeWidget.updateWidget(
      name: 'PortfolioGlanceReceiver',
      androidName: _portfolioReceiverClass,
      qualifiedAndroidName: _portfolioReceiverClass,
      iOSName: iOSPortfolioKind,
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
    // The Android/iOS home-screen widgets follow the OS's own day/night
    // mode (there's no in-app UI hosting them to read the app's Appearance
    // setting from), so the accent is resolved from the platform's current
    // brightness rather than any in-app theme state.
    final widgetColors =
        PlatformDispatcher.instance.platformBrightness == Brightness.light ? QimaColors.light : QimaColors.dark;
    final accent = InstrumentTheme.accentColor(instrument, widgetColors);

    return {
      'available': true,
      'symbol': instrument.symbol,
      'currency': card.currency,
      'price': presentation.latestMoney?.formatted(useFallbackSymbol: true) ?? '—',
      'compactPrice': presentation.latestMoney?.compact(useFallbackSymbol: true) ?? '—',
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
