import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qima/blocs/app_cubit.dart';
import 'package:qima/blocs/app_state.dart';
import 'package:qima/l10n/app_localizations.dart';
import 'package:qima/models/asset.dart';
import 'package:qima/models/instrument_catalog.dart';
import 'package:qima/models/quote.dart';
import 'package:qima/services/price_repository.dart';
import 'package:qima/theme/strings.dart';

class _FailingRepository extends PriceRepository {
  @override
  Future<QuoteSeries> refresh(Instrument instrument, {DateTime? now}) async =>
      throw Exception('SocketException: Failed host lookup');
}

void main() {
  test('a failed refresh stores a localization key, not exception text', () async {
    final cubit = AppCubit(repository: _FailingRepository());
    await cubit.refresh(InstrumentCatalog.all.first);
    expect(cubit.state.phase, RefreshPhase.failed);
    expect(cubit.state.errorMessage, 'error.refreshFailed');
  });

  testWidgets('the refresh-failed key resolves to translated text', (tester) async {
    for (final (locale, expected) in [
      (const Locale('en'), "Couldn't refresh prices. Check your connection and try again."),
      (const Locale('ar'), 'تعذّر تحديث الأسعار. تحقّق من اتصالك وحاول مرة أخرى.'),
    ]) {
      late BuildContext context;
      await tester.pumpWidget(MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(builder: (c) {
          context = c;
          return const SizedBox();
        }),
      ));
      expect(displayLabel(context, 'error.refreshFailed'), expected);
    }
  });
}
