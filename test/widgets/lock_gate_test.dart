import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qima/blocs/app_cubit.dart';
import 'package:qima/l10n/app_localizations.dart';
import 'package:qima/screens/lock_screen.dart';
import 'package:qima/services/app_lock_service.dart';
import 'package:qima/services/preferences.dart';
import 'package:qima/theme/app_theme.dart';
import 'package:qima/widgets/lock_gate.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Scriptable fake so these tests never touch real biometric hardware.
class _FakeAppLockService extends AppLockService {
  bool nextAuthResult = true;
  bool supported = true;
  int authenticateCalls = 0;

  @override
  Future<bool> get isSupported async => supported;

  @override
  Future<bool> authenticate({required String reason}) async {
    authenticateCalls++;
    lastFailureWasNoCredentials = !supported;
    return supported && nextAuthResult;
  }
}

void main() {
  Widget harness({required AppCubit cubit}) {
    return BlocProvider<AppCubit>.value(
      value: cubit,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: buildTheme(Brightness.dark),
        builder: (context, child) => LockGate(child: child!),
        home: const Scaffold(body: Center(child: Text('Real content'))),
      ),
    );
  }

  testWidgets('shows the lock screen on cold start when app lock is enabled', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final lockService = _FakeAppLockService()..nextAuthResult = false;
    final cubit = AppCubit(appLockService: lockService);
    cubit.preferences = await Preferences.create();
    cubit.emit(cubit.state.copyWith(initialized: true, appLockEnabled: true));

    await tester.pumpWidget(harness(cubit: cubit));
    await tester.pumpAndSettle();

    expect(find.byType(LockScreen), findsOneWidget);
    expect(find.text('Real content'), findsOneWidget);
  });

  testWidgets('does not show the lock screen when app lock is disabled', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final cubit = AppCubit(appLockService: _FakeAppLockService());
    cubit.preferences = await Preferences.create();
    cubit.emit(cubit.state.copyWith(initialized: true, appLockEnabled: false));

    await tester.pumpWidget(harness(cubit: cubit));
    await tester.pumpAndSettle();

    expect(find.byType(LockScreen), findsNothing);
  });

  testWidgets('a successful authentication unlocks and hides the lock screen', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final lockService = _FakeAppLockService()..nextAuthResult = false;
    final cubit = AppCubit(appLockService: lockService);
    cubit.preferences = await Preferences.create();
    cubit.emit(cubit.state.copyWith(initialized: true, appLockEnabled: true));

    await tester.pumpWidget(harness(cubit: cubit));
    await tester.pumpAndSettle();
    expect(find.byType(LockScreen), findsOneWidget);

    lockService.nextAuthResult = true;
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    await tester.tap(find.text(l10n.appLockUnlockGeneric));
    await tester.pumpAndSettle();

    expect(find.byType(LockScreen), findsNothing);
    expect(find.text('Real content'), findsOneWidget);
  });

  testWidgets('a failed authentication leaves the lock screen showing', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final lockService = _FakeAppLockService()..nextAuthResult = false;
    final cubit = AppCubit(appLockService: lockService);
    cubit.preferences = await Preferences.create();
    cubit.emit(cubit.state.copyWith(initialized: true, appLockEnabled: true));

    await tester.pumpWidget(harness(cubit: cubit));
    await tester.pumpAndSettle();

    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    await tester.tap(find.text(l10n.appLockUnlockGeneric));
    await tester.pumpAndSettle();

    expect(find.byType(LockScreen), findsOneWidget);
  });

  testWidgets('turns app lock off instead of locking out a device with no biometrics or passcode', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final lockService = _FakeAppLockService()
      ..supported = false
      ..nextAuthResult = false;
    final cubit = AppCubit(appLockService: lockService);
    cubit.preferences = await Preferences.create();
    await cubit.preferences.setAppLockEnabled(true);
    cubit.emit(cubit.state.copyWith(initialized: true, appLockEnabled: true));

    await tester.pumpWidget(harness(cubit: cubit));
    await tester.pumpAndSettle();

    expect(find.byType(LockScreen), findsNothing);
    expect(find.text('Real content'), findsOneWidget);
    expect(cubit.state.appLockEnabled, isFalse);
    expect(cubit.preferences.appLockEnabled, isFalse, reason: 'the switch-off is persisted');
  });

  testWidgets('a failure for any other reason keeps the app locked', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final lockService = _FakeAppLockService()..nextAuthResult = false;
    final cubit = AppCubit(appLockService: lockService);
    cubit.preferences = await Preferences.create();
    await cubit.preferences.setAppLockEnabled(true);
    cubit.emit(cubit.state.copyWith(initialized: true, appLockEnabled: true));

    await tester.pumpWidget(harness(cubit: cubit));
    await tester.pumpAndSettle();

    expect(lockService.authenticateCalls, greaterThan(0));
    expect(find.byType(LockScreen), findsOneWidget);
    expect(cubit.state.appLockEnabled, isTrue);
  });
}
