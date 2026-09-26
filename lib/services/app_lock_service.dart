import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

/// Why an authentication attempt did not result in the app unlocking —
/// mirrors the states the lock screen and settings toggle need to react to
/// distinctly (spec Phase 4 "App lock"). [AppLockService.authenticate]
/// returns `true`/`false` for the common case; callers that need to tell
/// "the user cancelled" from "biometrics are gone" use
/// [AppLockService.lastFailureReason] afterwards.
enum AppLockFailureReason {
  /// The user dismissed the system sheet (Face ID/Touch ID/passcode) or
  /// tapped Cancel.
  cancelled,

  /// The device no longer has biometrics AND no passcode/device credential
  /// set up — e.g. the user removed Face ID after enabling app lock.
  notAvailable,

  /// Any other platform failure (lockout, hardware error, etc).
  other,
}

/// Thin wrapper around `local_auth`, isolated behind an interface so
/// `LockGate`/`AppCubit` can be tested with a fake instead of touching real
/// biometric hardware. Biometrics are always tried with a device-passcode
/// fallback allowed (`biometricOnly: false`), matching the "Use device
/// passcode" text button on the lock screen.
class AppLockService {
  AppLockFailureReason? lastFailureReason;

  /// True when the last [authenticate] failed because the device has no
  /// biometric AND no passcode at all — the one failure that can never
  /// resolve itself while App lock stays on. Narrower than
  /// [AppLockFailureReason.notAvailable], which also covers hardware that is
  /// only temporarily unavailable.
  bool lastFailureWasNoCredentials = false;

  final LocalAuthentication _auth;

  AppLockService({LocalAuthentication? auth}) : _auth = auth ?? LocalAuthentication();

  /// Whether this device can plausibly gate the app behind biometrics or a
  /// passcode at all. Both must be false to disable the setting entirely —
  /// `canCheckBiometrics` alone can be true on hardware with no enrolled
  /// biometric, and `isDeviceSupported` alone can be true with biometrics
  /// unavailable but a passcode set.
  Future<bool> get isSupported async {
    try {
      final canCheckBiometrics = await _auth.canCheckBiometrics;
      final isDeviceSupported = await _auth.isDeviceSupported();
      return canCheckBiometrics || isDeviceSupported;
    } catch (e, st) {
      debugPrint('AppLockService: isSupported check failed: $e\n$st');
      return false;
    }
  }

  /// The strongest enrolled biometric kind, used to pick the unlock button's
  /// label ("Unlock with Face ID" / "Unlock with Touch ID" / "Unlock").
  Future<BiometricKind> availableBiometric() async {
    try {
      final types = await _auth.getAvailableBiometrics();
      if (types.contains(BiometricType.face)) return BiometricKind.face;
      if (types.contains(BiometricType.fingerprint) || types.contains(BiometricType.strong) || types.contains(BiometricType.weak)) {
        return BiometricKind.fingerprint;
      }
      return BiometricKind.none;
    } catch (e, st) {
      debugPrint('AppLockService: availableBiometric check failed: $e\n$st');
      return BiometricKind.none;
    }
  }

  /// Prompts biometric/passcode authentication. Returns `true` only on a
  /// genuine successful unlock. On any failure, [lastFailureReason] is set
  /// so the caller can distinguish "user cancelled" (say nothing, just stay
  /// locked) from "biometrics were removed" (show the explanatory copy).
  /// Biometrics are always tried with a device-passcode fallback allowed
  /// (`biometricOnly: false`), matching the "Use device passcode" text
  /// button on the lock screen.
  Future<bool> authenticate({required String reason}) async {
    lastFailureReason = null;
    lastFailureWasNoCredentials = false;
    try {
      final supported = await isSupported;
      if (!supported) {
        lastFailureReason = AppLockFailureReason.notAvailable;
        lastFailureWasNoCredentials = true;
        return false;
      }
      final result = await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );
      if (!result) lastFailureReason = AppLockFailureReason.cancelled;
      return result;
    } on LocalAuthException catch (e, st) {
      debugPrint('AppLockService: authenticate failed: ${e.code} $e\n$st');
      lastFailureReason = _reasonFor(e.code);
      lastFailureWasNoCredentials = e.code == LocalAuthExceptionCode.noCredentialsSet;
      return false;
    } catch (e, st) {
      debugPrint('AppLockService: authenticate failed: $e\n$st');
      lastFailureReason = AppLockFailureReason.other;
      return false;
    }
  }

  AppLockFailureReason _reasonFor(LocalAuthExceptionCode code) {
    switch (code) {
      case LocalAuthExceptionCode.noCredentialsSet:
      case LocalAuthExceptionCode.noBiometricsEnrolled:
      case LocalAuthExceptionCode.noBiometricHardware:
      case LocalAuthExceptionCode.biometricHardwareTemporarilyUnavailable:
        return AppLockFailureReason.notAvailable;
      case LocalAuthExceptionCode.authInProgress:
      case LocalAuthExceptionCode.userCanceled:
      case LocalAuthExceptionCode.systemCanceled:
      case LocalAuthExceptionCode.timeout:
      case LocalAuthExceptionCode.userRequestedFallback:
        return AppLockFailureReason.cancelled;
      // `LocalAuthExceptionCode` documents that new values may be added
      // without it counting as a breaking change, so this default also
      // covers temporaryLockout/biometricLockout/uiUnavailable/deviceError/
      // unknownError/anything future.
      default:
        return AppLockFailureReason.other;
    }
  }
}

enum BiometricKind { face, fingerprint, none }
