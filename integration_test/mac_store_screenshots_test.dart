// Renders the Mac App Store screenshots from the real app with a seeded demo
// portfolio. Run it through `tool/mac_store_media.sh screenshots`, which builds under
// a separate bundle ID so the seed never touches a real Qima install, then
// copies the PNGs out of that build's sandbox container.
//
// The app lays out at 1440x900 points and each frame is rasterized straight
// from the layer tree at 2x, giving 2880x1800 PNGs — one of the sizes App
// Store Connect accepts for Mac — without needing screen-recording access.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:qima/blocs/app_cubit.dart';
import 'package:qima/main.dart';
import 'package:qima/screens/home_shell.dart';
import 'package:qima/services/preferences.dart';
import 'package:qima/widgets/instrument_row.dart';

import 'store_demo_seed.dart';

/// `en` or `ar`; selects the in-app language for the run.
const _language = String.fromEnvironment('SCREENSHOT_LANG', defaultValue: 'en');

/// The sandbox only lets the app write inside its own container, so frames
/// go to its temp folder; the host script copies them out afterwards.
final _outputDir = Directory('${Directory.systemTemp.path}/qima-store-screenshots');

const _logicalSize = Size(1440, 900);
const _pixelRatio = 2.0;

Future<void> _wait(Duration duration) => Future<void>.delayed(duration);

Future<Finder> _waitFor(Finder finder, {Duration timeout = const Duration(seconds: 30)}) async {
  final deadline = DateTime.now().add(timeout);
  while (finder.evaluate().isEmpty) {
    if (DateTime.now().isAfter(deadline)) throw TestFailure('Timed out waiting for $finder');
    await _wait(const Duration(milliseconds: 250));
  }
  return finder;
}

Future<void> _shot(WidgetTester tester, String name) async {
  // Let charts animate in and live prices settle before rasterizing.
  await _wait(const Duration(seconds: 3));
  final renderView = tester.binding.renderViews.first;
  final layer = renderView.debugLayer! as OffsetLayer;
  final physical = Offset.zero & (_logicalSize * _pixelRatio);
  final image = await layer.toImage(physical);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  final file = File('${_outputDir.path}/$name.png');
  await file.writeAsBytes(bytes!.buffer.asUint8List());
  // ignore: avoid_print
  print('QIMA_SCREENSHOT ${file.path} ${image.width}x${image.height}');
}

/// Closes whatever the root navigator last pushed (detail page or add flow).
void _popRoute(WidgetTester tester) => tester.state<NavigatorState>(find.byType(Navigator).first).pop();

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('Mac store screenshots ($_language)', (tester) async {
    if (_outputDir.existsSync()) _outputDir.deleteSync(recursive: true);
    _outputDir.createSync(recursive: true);
    tester.view.physicalSize = _logicalSize * _pixelRatio;
    tester.view.devicePixelRatio = _pixelRatio;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const QimaApp());
    final cubit = tester.element(find.byType(MaterialApp)).read<AppCubit>();
    final ready = DateTime.now().add(const Duration(seconds: 30));
    while (!cubit.state.initialized && DateTime.now().isBefore(ready)) {
      await _wait(const Duration(milliseconds: 250));
    }
    await seedStoreDemo(cubit, language: _language == 'ar' ? AppLanguage.ar : AppLanguage.en);
    await _waitFor(find.byType(HomeShell, skipOffstage: false));
    await _shot(tester, '1_watchlist');

    await tester.tap((await _waitFor(find.byType(InstrumentRow))).first);
    await _shot(tester, '2_gold_detail');

    _popRoute(tester);
    await _wait(const Duration(seconds: 1));
    await tester.tap(find.byIcon(Icons.pie_chart_outline));
    await _shot(tester, '3_portfolio');

    await tester.tap(find.byIcon(Icons.list_alt_outlined));
    await _wait(const Duration(seconds: 1));
    await tester.tap(find.byIcon(Icons.add).first);
    // No Settings frame: this throwaway build has no iCloud entitlement, so
    // its Settings would show "Not signed in to iCloud".
    await _shot(tester, '4_add_asset');
  });
}
