import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:qima/blocs/app_cubit.dart';
import 'package:qima/l10n/app_localizations.dart';
import 'package:qima/models/asset.dart';
import 'package:qima/models/chart_range.dart';
import 'package:qima/models/fx_history.dart';
import 'package:qima/models/instrument_catalog.dart';
import 'package:qima/models/money.dart';
import 'package:qima/models/quote.dart';
import 'package:qima/models/share_format.dart';
import 'package:qima/models/watch_card.dart';
import 'package:qima/screens/settings_screen.dart';
import 'package:qima/screens/share_asset_sheet.dart';
import 'package:qima/screens/watchlist_screen.dart';
import 'package:qima/theme/app_theme.dart';
import 'package:qima/widgets/asset_share_card.dart';

void main() {
  final gold = InstrumentCatalog.instrument('metal.XAU')!;
  final btc = InstrumentCatalog.instrument('crypto.BTC')!;
  final goldCard = WatchCard(id: 'c1', instrumentID: gold.id, currency: 'USD', unit: PriceUnit.troyOunce);
  final btcCard = WatchCard(id: 'c2', instrumentID: btc.id, currency: 'USD', unit: PriceUnit.each);

  AppCubit populatedCubit() {
    final cubit = AppCubit();
    final now = DateTime.now();
    QuoteSeries series(String id, double from, double to) => QuoteSeries(instrumentID: id, quotes: [
          for (var day = 60; day >= 0; day--)
            Quote(
              instrumentID: id,
              timestamp: now.subtract(Duration(days: day)),
              canonicalUSD: from + (to - from) * (60 - day) / 60,
            ),
        ]);
    cubit.emit(cubit.state.copyWith(
      initialized: true,
      cards: [goldCard, btcCard],
      seriesByID: {gold.id: series(gold.id, 1900, 2000), btc.id: series(btc.id, 70000, 65000)},
      rates: FXRates(base: 'USD', rates: const {'USD': 1}, updatedAt: now),
      fxHistory: FXHistory.empty,
      baseCurrency: 'USD',
    ));
    return cubit;
  }

  Widget harness(Widget home, {AppCubit? cubit, Locale locale = const Locale('en')}) {
    return BlocProvider<AppCubit>(
      create: (_) => cubit ?? populatedCubit(),
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: buildTheme(Brightness.light),
        home: home,
      ),
    );
  }

  group('Edit order', () {
    testWidgets('the watchlist opens Edit order with a handle per card, and Done closes it', (tester) async {
      await tester.pumpWidget(harness(const WatchlistScreen(manageRefreshLifecycle: false)));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.swap_vert));
      await tester.pumpAndSettle();

      expect(find.text('Edit order'), findsOneWidget);
      expect(find.byIcon(Icons.drag_handle), findsNWidgets(2));
      expect(find.text('Top performers'), findsOneWidget);

      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.drag_handle), findsNothing);
      expect(find.byIcon(Icons.swap_vert), findsOneWidget);
    });

    testWidgets('system back closes Edit order instead of leaving the screen', (tester) async {
      await tester.pumpWidget(harness(const WatchlistScreen(manageRefreshLifecycle: false)));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.swap_vert));
      await tester.pumpAndSettle();

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.drag_handle), findsNothing);
      expect(find.byType(WatchlistScreen), findsOneWidget);
    });

    testWidgets('Edit order is not offered for a single card', (tester) async {
      final cubit = populatedCubit();
      cubit.emit(cubit.state.copyWith(cards: [goldCard]));
      await tester.pumpWidget(harness(const WatchlistScreen(manageRefreshLifecycle: false), cubit: cubit));
      await tester.pump();
      expect(find.byIcon(Icons.swap_vert), findsNothing);
    });
  });

  group('Share', () {
    for (final locale in const [Locale('en'), Locale('ar')]) {
      for (final destination in ShareDestination.values) {
        testWidgets('${destination.name} lays out its ${destination.format.ratioLabel} card cleanly (${locale.languageCode})',
            (tester) async {
          await tester.binding.setSurfaceSize(const Size(430, 1400));
          addTearDown(() => tester.binding.setSurfaceSize(null));
          await tester.pumpWidget(
            harness(Scaffold(body: ShareAssetSheet(card: goldCard, range: ChartRange.month1)), locale: locale),
          );
          await tester.pump();

          final chip = find.byWidgetPredicate(
            (w) => w is ChoiceChip && (w.label as Text).data == _label(tester, destination),
          );
          await tester.tap(chip);
          await tester.pump();

          final card = tester.widget<AssetShareCard>(find.byType(AssetShareCard));
          expect(card.format, destination.format);
          expect(tester.getSize(find.byType(AssetShareCard)), AssetShareCard.logicalSize(destination.format));
          expect(tester.takeException(), isNull);
        });
      }
    }

    testWidgets('the captured image is the format\'s full pixel size', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(harness(Scaffold(body: ShareAssetSheet(card: goldCard, range: ChartRange.month1))));
      await tester.pump();

      for (final format in [ShareFormat.square, ShareFormat.landscape]) {
        if (format == ShareFormat.landscape) {
          await tester.tap(find.text('LinkedIn post'));
          await tester.pump();
        }
        final boundary = tester.renderObject<RenderRepaintBoundary>(
          find.ancestor(of: find.byType(AssetShareCard), matching: find.byType(RepaintBoundary)).first,
        );
        final image = await tester.runAsync(() => boundary.toImage(
              pixelRatio: format.widthPx / AssetShareCard.logicalSize(format).width,
            ));
        expect(image!.width, format.widthPx);
        expect(image.height, closeTo(format.heightPx, 1));
        image.dispose();
      }
    });

    testWidgets('the caption carries the price, the change and the site', (tester) async {
      await tester.pumpWidget(harness(Scaffold(body: ShareAssetSheet(card: goldCard, range: ChartRange.month1))));
      await tester.pump();

      final caption = tester.widget<SelectableText>(find.byType(SelectableText)).data!;
      expect(caption, contains('Gold'));
      expect(caption, contains('2,000.00'));
      expect(caption, contains(', 1M).'));
      expect(caption, contains('https://qima.devlabtechnologies.com/'));
    });
  });

  test('only apps that keep the caption get it with the image, so stories stay photos on iOS', () {
    expect(
      [for (final d in ShareDestination.values) if (d.sendsCaption) d],
      [ShareDestination.whatsappMessage, ShareDestination.linkedinPost],
    );
  });

  test('the Arabic caption keeps the price and change left-to-right', () {
    final data = AssetShareData(
      instrument: gold,
      name: 'الذهب',
      detailLine: '',
      price: r'$4,041.10',
      changeLabel: '\u2066+0.12%\u2069',
      isUp: true,
      rangeLabel: '3 أشهر',
      dateLabel: '',
      points: const [],
    );
    final caption = assetShareCaption(lookupAppLocalizations(const Locale('ar')), data);
    expect(caption, contains('\u2066\$4,041.10\u2069'));
    expect(caption, contains('\u2066+0.12%\u2069'));
  });

  testWidgets('Settings shows the app version and build', (tester) async {
    PackageInfo.setMockInitialValues(
      appName: 'Qima',
      packageName: 'com.devlabtechnologies.qima',
      version: '3.1.0',
      buildNumber: '4',
      buildSignature: '',
    );
    await tester.pumpWidget(harness(const SettingsScreen()));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Version 3.1.0 (4)'), 300);
    expect(find.text('Version 3.1.0 (4)'), findsOneWidget);
  });
}

String _label(WidgetTester tester, ShareDestination destination) {
  final l10n = AppLocalizations.of(tester.element(find.byType(ShareAssetSheet)))!;
  return switch (destination) {
    ShareDestination.whatsappMessage => l10n.shareToWhatsappMessage,
    ShareDestination.whatsappStatus => l10n.shareToWhatsappStatus,
    ShareDestination.instagramPost => l10n.shareToInstagramPost,
    ShareDestination.instagramStory => l10n.shareToInstagramStory,
    ShareDestination.facebookPost => l10n.shareToFacebookPost,
    ShareDestination.facebookStory => l10n.shareToFacebookStory,
    ShareDestination.linkedinPost => l10n.shareToLinkedinPost,
  };
}
