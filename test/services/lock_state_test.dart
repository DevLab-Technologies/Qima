import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qima/services/lock_state.dart';
import 'package:qima/services/preferences.dart';

void main() {
  group('LockStateMachine — grace-period state machine', () {
    test('cold start locks when app lock is enabled', () {
      final machine = LockStateMachine(isEnabled: () => true, grace: () => LockGrace.oneMinute);
      machine.primeColdStart();
      expect(machine.isLocked, isTrue);
    });

    test('cold start does not lock when app lock is disabled', () {
      final machine = LockStateMachine(isEnabled: () => false, grace: () => LockGrace.oneMinute);
      machine.primeColdStart();
      expect(machine.isLocked, isFalse);
    });

    test('resume within the grace period does not lock', () {
      var now = DateTime(2026, 1, 1, 12, 0, 0);
      final machine = LockStateMachine(
        isEnabled: () => true,
        grace: () => LockGrace.fiveMinutes,
        now: () => now,
        startLocked: false,
      );
      machine.unlock();

      machine.handleLifecycleChange(AppLifecycleState.paused);
      now = now.add(const Duration(minutes: 2));
      machine.handleLifecycleChange(AppLifecycleState.resumed);

      expect(machine.isLocked, isFalse);
    });

    test('resume after the grace period elapses locks the app', () {
      var now = DateTime(2026, 1, 1, 12, 0, 0);
      final machine = LockStateMachine(
        isEnabled: () => true,
        grace: () => LockGrace.fiveMinutes,
        now: () => now,
        startLocked: false,
      );
      machine.unlock();

      machine.handleLifecycleChange(AppLifecycleState.paused);
      now = now.add(const Duration(minutes: 6));
      machine.handleLifecycleChange(AppLifecycleState.resumed);

      expect(machine.isLocked, isTrue);
    });

    test('LockGrace.immediately locks on every single backgrounding', () {
      var now = DateTime(2026, 1, 1, 12, 0, 0);
      final machine = LockStateMachine(
        isEnabled: () => true,
        grace: () => LockGrace.immediately,
        now: () => now,
        startLocked: false,
      );
      machine.unlock();

      machine.handleLifecycleChange(AppLifecycleState.paused);
      now = now.add(const Duration(milliseconds: 1));
      machine.handleLifecycleChange(AppLifecycleState.resumed);

      expect(machine.isLocked, isTrue);
    });

    test('hidden also starts the grace timer, same as paused', () {
      var now = DateTime(2026, 1, 1, 12, 0, 0);
      final machine = LockStateMachine(
        isEnabled: () => true,
        grace: () => LockGrace.oneMinute,
        now: () => now,
        startLocked: false,
      );
      machine.unlock();

      machine.handleLifecycleChange(AppLifecycleState.hidden);
      now = now.add(const Duration(minutes: 2));
      machine.handleLifecycleChange(AppLifecycleState.resumed);

      expect(machine.isLocked, isTrue);
    });

    test('inactive does NOT start the grace timer — the Face ID sheet must not re-lock on its own', () {
      var now = DateTime(2026, 1, 1, 12, 0, 0);
      final machine = LockStateMachine(
        isEnabled: () => true,
        grace: () => LockGrace.immediately,
        now: () => now,
        startLocked: false,
      );
      machine.unlock();

      // Simulates the Face ID sheet: the app briefly goes inactive, then
      // resumes without ever having paused.
      machine.handleLifecycleChange(AppLifecycleState.inactive);
      now = now.add(const Duration(seconds: 5));
      machine.handleLifecycleChange(AppLifecycleState.resumed);

      expect(machine.isLocked, isFalse);
    });

    test('inactive alone between paused and resumed does not add extra grace time', () {
      var now = DateTime(2026, 1, 1, 12, 0, 0);
      final machine = LockStateMachine(
        isEnabled: () => true,
        grace: () => LockGrace.fiveMinutes,
        now: () => now,
        startLocked: false,
      );
      machine.unlock();

      machine.handleLifecycleChange(AppLifecycleState.paused);
      now = now.add(const Duration(minutes: 2));
      machine.handleLifecycleChange(AppLifecycleState.inactive);
      now = now.add(const Duration(minutes: 2));
      machine.handleLifecycleChange(AppLifecycleState.resumed);

      // Total elapsed since `paused` is 4 minutes, still under the 5 minute
      // grace — `inactive` must not have reset or extended the timer.
      expect(machine.isLocked, isFalse);
    });

    test('unlock clears the locked state and any pending background timer', () {
      var now = DateTime(2026, 1, 1, 12, 0, 0);
      final machine = LockStateMachine(
        isEnabled: () => true,
        grace: () => LockGrace.immediately,
        now: () => now,
      );
      machine.primeColdStart();
      expect(machine.isLocked, isTrue);

      machine.unlock();
      expect(machine.isLocked, isFalse);
    });

    test('disabling app lock mid-background clears the lock on resume', () {
      var now = DateTime(2026, 1, 1, 12, 0, 0);
      var enabled = true;
      final machine = LockStateMachine(
        isEnabled: () => enabled,
        grace: () => LockGrace.immediately,
        now: () => now,
        startLocked: false,
      );
      machine.unlock();

      machine.handleLifecycleChange(AppLifecycleState.paused);
      enabled = false;
      now = now.add(const Duration(minutes: 10));
      machine.handleLifecycleChange(AppLifecycleState.resumed);

      expect(machine.isLocked, isFalse);
    });

    test('shouldCoverFor is true while locked regardless of lifecycle state', () {
      final machine = LockStateMachine(isEnabled: () => true, grace: () => LockGrace.oneMinute);
      machine.primeColdStart();
      expect(machine.shouldCoverFor(AppLifecycleState.resumed), isTrue);
    });

    test('shouldCoverFor is true while inactive/paused/hidden even when unlocked', () {
      final machine = LockStateMachine(isEnabled: () => false, grace: () => LockGrace.oneMinute, startLocked: false);
      expect(machine.shouldCoverFor(AppLifecycleState.inactive), isTrue);
      expect(machine.shouldCoverFor(AppLifecycleState.paused), isTrue);
      expect(machine.shouldCoverFor(AppLifecycleState.hidden), isTrue);
      expect(machine.shouldCoverFor(AppLifecycleState.resumed), isFalse);
    });
  });
}
