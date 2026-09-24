import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/app_cubit.dart';
import '../blocs/app_state.dart';
import '../l10n/app_localizations.dart';
import '../screens/lock_screen.dart';
import '../services/lock_state.dart';
import '../services/secure_screen.dart';
import '../theme/design_system.dart';
import '../theme/qima_colors.dart';

/// Gates the whole app behind [LockScreen] when app lock is enabled and
/// locked, and shows a privacy cover (just the app icon, no content) while
/// the app is inactive/backgrounded and lock-or-hide is on, so the OS
/// app-switcher snapshot never shows amounts (spec Phase 4 "App lock").
///
/// Placed inside `MaterialApp.builder`, wrapping `child` (the app's real
/// content) — so it sits ABOVE the screens but the root `ScaffoldMessenger`
/// (attached to `MaterialApp` itself, outside `builder`) stays above this
/// gate, meaning in-app snackbars keep working normally once unlocked and
/// are never trapped behind a dismissed lock screen.
class LockGate extends StatefulWidget {
  final Widget child;

  const LockGate({super.key, required this.child});

  @override
  State<LockGate> createState() => _LockGateState();
}

class _LockGateState extends State<LockGate> with WidgetsBindingObserver {
  late LockStateMachine _machine;
  AppLifecycleState? _lifecycleState;
  bool _isAuthenticating = false;
  bool _primed = false;
  AppCubit? _cubit;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final cubit = context.read<AppCubit>();
    if (!identical(_cubit, cubit)) {
      _cubit = cubit;
      _machine = LockStateMachine(
        isEnabled: () => cubit.state.appLockEnabled,
        grace: () => cubit.state.lockGrace,
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _lifecycleState = state;
      _machine.handleLifecycleChange(state);
    });
    if (state == AppLifecycleState.resumed && _machine.isLocked) {
      _promptAuthentication();
    }
  }

  Future<void> _promptAuthentication() async {
    if (_isAuthenticating) return;
    final cubit = _cubit;
    if (cubit == null) return;
    setState(() => _isAuthenticating = true);
    final reason = AppLocalizations.of(context)?.appLockAuthReason ?? 'Unlock Qima to see your portfolio';
    final service = cubit.appLockService;
    final success = await service.authenticate(reason: reason);
    // If every biometric and the device passcode have been removed since
    // App lock was turned on, nothing can ever unlock Qima again — and the
    // device itself no longer protects anything. Turn App lock off instead
    // of locking the user out for good.
    if (!success && service.lastFailureWasNoCredentials) {
      await cubit.setAppLockEnabled(false);
      if (!mounted) return;
      setState(() {
        _isAuthenticating = false;
        _machine.unlock();
      });
      return;
    }
    if (!mounted) return;
    setState(() {
      _isAuthenticating = false;
      if (success) _machine.unlock();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      buildWhen: (previous, current) =>
          previous.initialized != current.initialized ||
          previous.appLockEnabled != current.appLockEnabled ||
          previous.lockGrace != current.lockGrace,
      builder: (context, state) {
        // Cold start: prime the machine to "locked" the first time
        // initialization completes and app lock is on. Waiting for
        // `initialized` avoids locking on the transient default
        // (`appLockEnabled: false`) `AppState` that exists before
        // `Preferences` has loaded.
        if (!_primed && state.initialized) {
          _primed = true;
          _machine.primeColdStart();
          if (_machine.isLocked) {
            WidgetsBinding.instance.addPostFrameCallback((_) => _promptAuthentication());
          }
        }

        final locked = state.initialized && _machine.isLocked;
        final covering = state.initialized && (locked || (state.hideBalances && _shouldCoverForHide()));

        // FLAG_SECURE (Android only, no-op elsewhere): on whenever app lock
        // or hide-balances is enabled at all, not just while actually
        // locked/covering — a screenshot taken a second after unlocking
        // should still be blocked while hide-balances is on, and recents
        // should never briefly flash real content on the way to the cover.
        unawaited(SecureScreen.setSecure(state.appLockEnabled || state.hideBalances));

        return Stack(
          children: [
            widget.child,
            if (locked)
              LockScreen(
                lockService: context.read<AppCubit>().appLockService,
                isAuthenticating: _isAuthenticating,
                onUnlockTapped: _promptAuthentication,
              )
            else if (covering)
              const _PrivacyCover(),
          ],
        );
      },
    );
  }

  /// The privacy cover also shows (independent of app lock) whenever hide
  /// balances is on AND the app is momentarily inactive/backgrounded — the
  /// same app-switcher-snapshot concern applies even if the user hasn't
  /// turned app lock on, since a masked amount is still better hidden
  /// entirely from a recents thumbnail than shown as "••••••" the OS then
  /// caches as an image.
  bool _shouldCoverForHide() {
    return _lifecycleState == AppLifecycleState.inactive ||
        _lifecycleState == AppLifecycleState.paused ||
        _lifecycleState == AppLifecycleState.hidden;
  }
}

/// App icon on a plain background — shown instead of real content while the
/// app is inactive/backgrounded and lock-or-hide is on, so nothing sensitive
/// ends up in the OS's app-switcher snapshot.
class _PrivacyCover extends StatelessWidget {
  const _PrivacyCover();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: colors.bg0,
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(DS.radiusCard),
          child: Image.asset('assets/icon/app_icon.png', width: 96, height: 96, fit: BoxFit.cover),
        ),
      ),
    );
  }
}
