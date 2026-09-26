import 'package:flutter/material.dart';

import 'preferences.dart';

/// Pure grace-period state machine for the app-lock feature (spec Phase 4
/// "Lifecycle rule"), factored out of [LockGate] so it can be unit tested
/// with an injected clock instead of real wall-clock time and real
/// `AppLifecycleState` transitions.
///
/// Rule: only `paused`/`hidden` start the grace timer; NEVER `inactive` —
/// the Face ID/Touch ID system sheet itself briefly makes the app
/// `inactive`, so counting that transition would re-lock the app
/// immediately after a successful unlock. On `resumed`, the app locks if the
/// elapsed time since the background transition is >= the configured grace
/// (`LockGrace.immediately` locks on every single backgrounding, with no
/// grace at all). A cold start always locks when app lock is enabled.
class LockStateMachine {
  final bool Function() isEnabled;
  final LockGrace Function() grace;
  final DateTime Function() now;

  bool _locked;
  DateTime? _backgroundedAt;

  LockStateMachine({
    required this.isEnabled,
    required this.grace,
    DateTime Function()? now,
    bool startLocked = true,
  })  : now = now ?? DateTime.now,
        _locked = startLocked && isEnabled();

  bool get isLocked => _locked;

  /// Call once at cold start, after the enabled/grace getters have real
  /// values available (e.g. once `Preferences` has loaded). Locks
  /// immediately if app lock is on.
  void primeColdStart() {
    _locked = isEnabled();
  }

  void handleLifecycleChange(AppLifecycleState state) {
    if (!isEnabled()) {
      _locked = false;
      _backgroundedAt = null;
      return;
    }
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        _backgroundedAt = now();
        break;
      case AppLifecycleState.inactive:
        // Deliberately ignored — see class doc. The Face ID sheet transits
        // through `inactive`, and starting/keeping a grace timer here would
        // undo a unlock that just happened, or start counting down for a
        // momentary distraction (e.g. a notification-center swipe) that
        // isn't really "leaving the app".
        break;
      case AppLifecycleState.resumed:
        final backgroundedAt = _backgroundedAt;
        _backgroundedAt = null;
        if (backgroundedAt == null) break;
        final elapsed = now().difference(backgroundedAt);
        if (elapsed >= grace().duration) {
          _locked = true;
        }
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  /// Called after a successful authentication from the lock screen.
  void unlock() {
    _locked = false;
    _backgroundedAt = null;
  }

  /// Whether the privacy cover (app icon on background, no amounts) should
  /// show right now — whenever locked, OR the app is momentarily
  /// inactive/paused/hidden (so the app-switcher snapshot / the frame just
  /// before the Face ID sheet appears never shows amounts).
  bool shouldCoverFor(AppLifecycleState? lifecycleState) {
    if (_locked) return true;
    return lifecycleState == AppLifecycleState.inactive ||
        lifecycleState == AppLifecycleState.paused ||
        lifecycleState == AppLifecycleState.hidden;
  }
}
