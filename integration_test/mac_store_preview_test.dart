// Records the Mac App Store app preview from the real app with a seeded demo
// portfolio. Run it through `tool/mac_store_media.sh preview`, which builds under a
// throwaway bundle ID (so the demo data never reaches a real install) and
// without the sandbox (so the app can hand frames to ffmpeg).
//
// The app lays out at 1440x810 points; frames are rasterized from the layer
// tree at 1920x1080 and streamed to ffmpeg as a constant 30 fps — the Mac app
// preview format — without needing screen-recording access. The walkthrough
// stays under App Store Connect's 30 second limit.
import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:qima/blocs/app_cubit.dart';
import 'package:qima/main.dart';
import 'package:qima/models/asset.dart';
import 'package:qima/models/chart_range.dart';
import 'package:qima/models/holding.dart';
import 'package:qima/models/metal_breakdown.dart';
import 'package:qima/models/watch_card.dart';
import 'package:qima/screens/home_shell.dart';
import 'package:qima/screens/instrument_detail_screen.dart';
import 'package:qima/screens/watchlist_screen.dart';
import 'package:qima/services/preferences.dart';
import 'package:qima/widgets/instrument_row.dart';

/// Absolute path of the .mp4 to write.
const _output = String.fromEnvironment('PREVIEW_OUTPUT');

const _logicalSize = Size(1440, 810);
const _pixelSize = Size(1920, 1080);
const _fps = 30;

Future<void> _wait(Duration duration) => Future<void>.delayed(duration);
Future<void> _beat([int ms = 1800]) => _wait(Duration(milliseconds: ms));

Future<Finder> _waitFor(Finder finder, {Duration timeout = const Duration(seconds: 30)}) async {
  final deadline = DateTime.now().add(timeout);
  while (finder.evaluate().isEmpty) {
    if (DateTime.now().isAfter(deadline)) throw TestFailure('Timed out waiting for $finder');
    await _wait(const Duration(milliseconds: 250));
  }
  return finder;
}

/// Waits for [text] inside the screen of type [screen] (its last match when
/// [last]): the home tabs share an IndexedStack, so a bare text finder can
/// match a hidden tab's widget.
Future<Finder> _textIn(Type screen, String text, {bool last = false}) async {
  final matches = await _waitFor(find.descendant(of: find.byType(screen), matching: find.text(text)));
  return last ? matches.last : matches.first;
}

/// Streams the live layer tree to ffmpeg. Rasterizing is slower than 30 fps,
/// so each captured frame is repeated until the wall clock catches up; the
/// result keeps real-time pacing.
class _Recorder {
  _Recorder(this._tester);

  final WidgetTester _tester;
  late final Process _ffmpeg;
  final _stopwatch = Stopwatch();
  var _written = 0;
  var _captured = 0;
  var _recording = false;
  late final Future<void> _loop;

  Future<void> start() async {
    _ffmpeg = await Process.start('/opt/homebrew/bin/ffmpeg', [
      '-y',
      '-loglevel',
      'error',
      '-f',
      'rawvideo',
      '-pix_fmt',
      'rgba',
      '-s',
      '${_pixelSize.width.toInt()}x${_pixelSize.height.toInt()}',
      '-r',
      '$_fps',
      '-i',
      '-',
      // Lossless and fast so encoding never throttles capture; the host
      // script makes the final App Store encode afterwards.
      '-c:v',
      'libx264',
      '-preset',
      'ultrafast',
      '-qp',
      '0',
      _output,
    ]);
    unawaited(_ffmpeg.stderr.pipe(stderr));
    _recording = true;
    _stopwatch.start();
    _loop = _run();
  }

  Future<void> _run() async {
    final layer = _tester.binding.renderViews.first.debugLayer! as OffsetLayer;
    while (_recording) {
      // One capture per rendered frame; also leaves the event loop free for
      // the walkthrough's taps and the app's own work.
      await SchedulerBinding.instance.endOfFrame;
      final image = await layer.toImage(Offset.zero & _pixelSize);
      final bytes = (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!.buffer.asUint8List();
      image.dispose();
      _captured++;
      final due = (_stopwatch.elapsedMilliseconds * _fps / 1000).floor() + 1;
      while (_written < due) {
        _ffmpeg.stdin.add(bytes);
        _written++;
      }
      await _ffmpeg.stdin.flush();
    }
  }

  Future<void> stop() async {
    _recording = false;
    await _loop;
    await _ffmpeg.stdin.close();
    final code = await _ffmpeg.exitCode;
    if (code != 0) throw TestFailure('ffmpeg exited with $code');
    // ignore: avoid_print
    print('QIMA_PREVIEW $_output ${_written / _fps}s, $_captured distinct frames');
  }
}

Future<void> _seed(AppCubit cubit) async {
  await cubit.completeOnboarding();
  await cubit.setAppLanguage(AppLanguage.en);
  await cubit.setAppearance(Appearance.dark);
  await cubit.setBaseCurrency('USD');
  // Start every run from the same ranges: the walkthrough taps different
  // ones, and tapping an already-selected chip does nothing.
  await cubit.setPreferredPortfolioRange(ChartRange.all);
  await cubit.setPreferredChartRange(ChartRange.month3);
  const cards = [
    WatchCard(id: 'shot-xau', instrumentID: 'metal.XAU', currency: 'USD', unit: PriceUnit.troyOunce),
    WatchCard(id: 'shot-xau21', instrumentID: 'metal.XAU', currency: 'SAR', unit: PriceUnit.gram, karat: GoldKarat.k21),
    WatchCard(id: 'shot-xag', instrumentID: 'metal.XAG', currency: 'USD', unit: PriceUnit.troyOunce),
    WatchCard(id: 'shot-btc', instrumentID: 'crypto.BTC', currency: 'USD', unit: PriceUnit.each),
    WatchCard(id: 'shot-aapl', instrumentID: 'stock.AAPL', currency: 'USD', unit: PriceUnit.each),
    WatchCard(id: 'shot-spx', instrumentID: 'index.GSPC', currency: 'USD', unit: PriceUnit.each),
    WatchCard(id: 'shot-eur', instrumentID: 'fx.EUR', currency: 'USD', unit: PriceUnit.each),
  ];
  final wanted = {for (final card in cards) card.id};
  for (final card in List.of(cubit.state.cards)) {
    if (!wanted.contains(card.id)) await cubit.removeCard(card.id);
  }
  final existing = {for (final card in cubit.state.cards) card.id};
  for (final card in cards) {
    if (!existing.contains(card.id)) await cubit.addCard(card);
  }
  final lots = [
    HoldingLot(
      id: 'shot-lot-1',
      instrumentID: 'metal.XAU',
      quantity: 5,
      unit: PriceUnit.troyOunce,
      unitCost: 2380,
      costCurrency: 'USD',
      date: DateTime(2024, 3, 14),
    ),
    HoldingLot(
      id: 'shot-lot-2',
      instrumentID: 'metal.XAU',
      quantity: 100,
      unit: PriceUnit.gram,
      unitCost: 88.5,
      costCurrency: 'USD',
      date: DateTime(2025, 1, 8),
    ),
    HoldingLot(
      id: 'shot-lot-3',
      instrumentID: 'metal.XAG',
      quantity: 50,
      unit: PriceUnit.troyOunce,
      unitCost: 29.4,
      costCurrency: 'USD',
      date: DateTime(2024, 9, 2),
    ),
    HoldingLot(
      id: 'shot-lot-4',
      instrumentID: 'crypto.BTC',
      quantity: 0.12,
      unit: PriceUnit.each,
      unitCost: 61200,
      costCurrency: 'USD',
      date: DateTime(2024, 6, 20),
    ),
    HoldingLot(
      id: 'shot-lot-5',
      instrumentID: 'stock.AAPL',
      quantity: 15,
      unit: PriceUnit.each,
      unitCost: 182.3,
      costCurrency: 'USD',
      date: DateTime(2024, 11, 5),
    ),
  ];
  for (final lot in lots) {
    await cubit.saveLot(lot);
  }
  await cubit.refreshAll();
  await cubit.backfillHistoryIfNeeded();
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('Mac app preview', (tester) async {
    if (_output.isEmpty) throw TestFailure('Pass --dart-define=PREVIEW_OUTPUT=<absolute .mp4 path>.');
    tester.view.physicalSize = _pixelSize;
    tester.view.devicePixelRatio = _pixelSize.width / _logicalSize.width;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const QimaApp());
    final cubit = tester.element(find.byType(MaterialApp)).read<AppCubit>();
    final ready = DateTime.now().add(const Duration(seconds: 30));
    while (!cubit.state.initialized && DateTime.now().isBefore(ready)) {
      await _wait(const Duration(milliseconds: 250));
    }
    await _seed(cubit);
    await _waitFor(find.byType(HomeShell, skipOffstage: false));
    await _beat(3000);

    final recorder = _Recorder(tester);
    await recorder.start();

    // Watchlist: portfolio chart across ranges, then an asset-class filter.
    await _beat(2500);
    await tester.tap(await _textIn(WatchlistScreen, '1Y'));
    await _beat();
    await tester.tap(await _textIn(WatchlistScreen, 'Metals'));
    await _beat();
    await tester.tap(await _textIn(WatchlistScreen, 'All', last: true));
    await _beat(1200);

    // Asset detail: chart ranges.
    await tester.tap(await _waitFor(find.byType(InstrumentRow).first));
    await _beat(2200);
    await tester.tap(await _textIn(InstrumentDetailScreen, '1Y'));
    await _beat();
    await tester.tap(await _textIn(InstrumentDetailScreen, '1M'));
    await _beat();
    tester.state<NavigatorState>(find.byType(Navigator).first).pop();
    await _beat(1200);

    // Portfolio breakdown.
    await tester.tap(find.byIcon(Icons.pie_chart_outline));
    await _beat(3000);

    // Adding an asset: search.
    await tester.tap(find.byIcon(Icons.list_alt_outlined));
    await _beat(900);
    await tester.tap(find.byIcon(Icons.add).first);
    await _beat(1200);
    for (final prefix in ['E', 'Et', 'Eth']) {
      await tester.enterText(find.byType(TextField).first, prefix);
      await _beat(350);
    }
    await _beat(1800);

    await recorder.stop();
  });
}
