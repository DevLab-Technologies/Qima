import 'package:flutter_test/flutter_test.dart';
import 'package:qima/blocs/app_cubit.dart';
import 'package:qima/services/app_lock_service.dart';
import 'package:qima/services/preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Fake [AppLockService] whose `authenticate` result is scripted per test,
/// so `AppCubit.setAppLockEnabled` can be exercised without touching real
/// biometric hardware.
class _FakeAppLockService extends AppLockService {
  bool nextAuthResult = true;
  int authenticateCallCount = 0;

  @override
  Future<bool> authenticate({required String reason}) async {
    authenticateCallCount++;
    if (!nextAuthResult) lastFailureReason = AppLockFailureReason.cancelled;
    return nextAuthResult;
  }
}

void main() {
  group('AppCubit privacy settings', () {
    testWidgets('toggleHideBalances flips hideBalances and persists it', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final cubit = AppCubit();
      cubit.preferences = await Preferences.create();
      expect(cubit.state.hideBalances, isFalse);

      await cubit.toggleHideBalances();
      expect(cubit.state.hideBalances, isTrue);
      expect(cubit.preferences.hideBalances, isTrue);

      await cubit.toggleHideBalances();
      expect(cubit.state.hideBalances, isFalse);
      expect(cubit.preferences.hideBalances, isFalse);
    });

    testWidgets('enabling app lock requires a successful authentication first', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final lockService = _FakeAppLockService()..nextAuthResult = true;
      final cubit = AppCubit(appLockService: lockService);
      cubit.preferences = await Preferences.create();

      final result = await cubit.setAppLockEnabled(true);

      expect(result, isTrue);
      expect(cubit.state.appLockEnabled, isTrue);
      expect(lockService.authenticateCallCount, 1);
      expect(cubit.preferences.appLockEnabled, isTrue);
    });

    testWidgets('a failed/cancelled authentication leaves app lock off', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final lockService = _FakeAppLockService()..nextAuthResult = false;
      final cubit = AppCubit(appLockService: lockService);
      cubit.preferences = await Preferences.create();

      final result = await cubit.setAppLockEnabled(true);

      expect(result, isFalse);
      expect(cubit.state.appLockEnabled, isFalse);
      expect(cubit.preferences.appLockEnabled, isFalse);
    });

    testWidgets('disabling app lock never prompts for authentication', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final lockService = _FakeAppLockService()..nextAuthResult = true;
      final cubit = AppCubit(appLockService: lockService);
      cubit.preferences = await Preferences.create();
      await cubit.setAppLockEnabled(true);
      expect(lockService.authenticateCallCount, 1);

      final result = await cubit.setAppLockEnabled(false);

      expect(result, isTrue);
      expect(cubit.state.appLockEnabled, isFalse);
      // Still 1 — disabling must not have triggered another auth prompt.
      expect(lockService.authenticateCallCount, 1);
    });

    testWidgets('setLockGrace persists the chosen grace period', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final cubit = AppCubit();
      cubit.preferences = await Preferences.create();
      expect(cubit.state.lockGrace, LockGrace.oneMinute);

      await cubit.setLockGrace(LockGrace.fifteenMinutes);

      expect(cubit.state.lockGrace, LockGrace.fifteenMinutes);
      expect(cubit.preferences.lockGrace, LockGrace.fifteenMinutes);
    });
  });
}
