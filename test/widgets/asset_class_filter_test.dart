import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qima/blocs/app_cubit.dart';
import 'package:qima/l10n/app_localizations.dart';
import 'package:qima/models/asset.dart';
import 'package:qima/theme/app_theme.dart';
import 'package:qima/widgets/asset_class_filter.dart';

void main() {
  Widget harness({required Set<AssetClass> classes, AssetClass? selected, ValueChanged<AssetClass?>? onSelected}) {
    return BlocProvider<AppCubit>(
      create: (_) => AppCubit(),
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: buildTheme(Brightness.dark),
        home: Scaffold(
          body: AssetClassFilter(
            availableClasses: classes,
            selected: selected,
            onSelected: onSelected ?? (_) {},
          ),
        ),
      ),
    );
  }

  testWidgets('renders nothing when at most one asset class is present', (tester) async {
    await tester.pumpWidget(harness(classes: {AssetClass.metal}));
    await tester.pump();
    expect(find.byType(ChoiceChip), findsNothing);
  });

  testWidgets('shows one chip per available class plus "All", and none for absent classes', (tester) async {
    await tester.pumpWidget(harness(classes: {AssetClass.metal, AssetClass.crypto}));
    await tester.pump();

    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.text(l10n.watchlistFilterAll), findsOneWidget);
    expect(find.text(l10n.assetClassMetal), findsOneWidget);
    expect(find.text(l10n.assetClassCrypto), findsOneWidget);
    // Stocks/indices/fiat aren't in the watchlist, so they get no chip.
    expect(find.text(l10n.assetClassStock), findsNothing);
    expect(find.text(l10n.assetClassIndex), findsNothing);
    expect(find.text(l10n.assetClassFiat), findsNothing);
  });

  testWidgets('tapping a class chip reports that class; tapping All reports null', (tester) async {
    AssetClass? received = AssetClass.metal;
    await tester.pumpWidget(harness(
      classes: {AssetClass.metal, AssetClass.crypto},
      selected: null,
      onSelected: (value) => received = value,
    ));
    await tester.pump();

    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    await tester.tap(find.text(l10n.assetClassCrypto));
    await tester.pump();
    expect(received, AssetClass.crypto);

    await tester.tap(find.text(l10n.watchlistFilterAll));
    await tester.pump();
    expect(received, isNull);
  });
}
