import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qima/blocs/app_cubit.dart';
import 'package:qima/blocs/money_cubit.dart';
import 'package:qima/models/money_settings.dart';

/// Provides a [MoneyCubit] over [app]'s own book store, as `main.dart` does,
/// for widget tests that pump screens reading Money. The What's new sheet
/// counts as seen unless [showWhatsNew], so it never covers the screen a
/// test is driving.
BlocProvider<MoneyCubit> testMoneyProvider(AppCubit app, {bool showWhatsNew = false}) => BlocProvider<MoneyCubit>(
      create: (_) {
        final money = MoneyCubit(
          store: app.bookStore,
          baseCurrency: () => app.state.baseCurrency,
          rates: () => app.state.rates,
        );
        if (showWhatsNew) {
          money.load();
        } else {
          app.bookStore.settings.upsert(const MoneySettings(seenWhatsNew: true)).then((_) => money.load());
        }
        return money;
      },
    );
