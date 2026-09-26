import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform;
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/app_lock_service.dart';
import '../theme/design_system.dart';
import '../theme/qima_colors.dart';

/// Full-screen lock shown by [LockGate] whenever the app is locked (spec
/// Phase 4 "App lock"): app icon, "Qima is locked", an explanatory line, an
/// "Unlock with Face ID/Touch ID/Unlock" primary button (label resolved from
/// the device's strongest enrolled biometric) and a "Use device passcode"
/// text button. Authentication is auto-prompted once when this screen first
/// appears (see [LockGate]) — the buttons here are for retrying after a
/// cancel/failure.
class LockScreen extends StatelessWidget {
  final AppLockService lockService;
  final VoidCallback onUnlockTapped;
  final bool isAuthenticating;

  const LockScreen({
    super.key,
    required this.lockService,
    required this.onUnlockTapped,
    this.isAuthenticating = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return Material(
      color: colors.bg0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(DS.spaceLG),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(DS.radiusCard),
                child: Image.asset(
                  'assets/icon/app_icon.png',
                  width: 88,
                  height: 88,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: DS.spaceLG),
              Text(
                l10n.appLockLockedTitle,
                style: TextStyle(color: colors.textPrimary, fontSize: 22, fontWeight: FontWeight.w800),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: DS.spaceXS),
              Text(
                l10n.appLockLockedMessage,
                style: TextStyle(color: colors.textTertiary, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              // Biometrics can be removed (or a passcode cleared) on this
              // device after app lock was enabled — e.g. the user turned off
              // Face ID in system settings. When the last attempt failed for
              // that reason, say so explicitly rather than silently retrying
              // a prompt that can never succeed.
              if (lockService.lastFailureReason == AppLockFailureReason.notAvailable) ...[
                const SizedBox(height: DS.spaceSM),
                Text(
                  l10n.settingsAppLockUnavailable,
                  style: TextStyle(color: colors.down, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: DS.spaceXL),
              FutureBuilder<BiometricKind>(
                future: lockService.availableBiometric(),
                builder: (context, snapshot) {
                  final kind = snapshot.data ?? BiometricKind.none;
                  return SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: isAuthenticating ? null : onUnlockTapped,
                      child: isAuthenticating
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(_unlockLabel(l10n, kind)),
                    ),
                  );
                },
              ),
              const SizedBox(height: DS.spaceSM),
              TextButton(
                onPressed: isAuthenticating ? null : onUnlockTapped,
                child: Text(l10n.appLockUseDevicePasscode),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _unlockLabel(AppLocalizations l10n, BiometricKind kind) {
    if (kind == BiometricKind.face && _isApplePlatform) return l10n.appLockUnlockFaceID;
    if (kind == BiometricKind.fingerprint && _isApplePlatform) return l10n.appLockUnlockTouchID;
    if (kind == BiometricKind.face || kind == BiometricKind.fingerprint) return l10n.appLockUnlockGeneric;
    return l10n.appLockUnlockGeneric;
  }

  bool get _isApplePlatform =>
      defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS;
}
