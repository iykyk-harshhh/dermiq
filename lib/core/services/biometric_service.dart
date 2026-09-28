import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

/// Thin wrapper around [LocalAuthentication] for the app's biometric lock.
///
/// Every method is defensive: platform channels can throw on unconfigured
/// devices, emulators or unsupported OS versions, so failures resolve to a
/// safe `false` instead of crashing the app. FREE — no backend, purely
/// on-device authentication (biometrics or the device PIN/pattern/password).
class BiometricService {
  BiometricService({LocalAuthentication? auth})
      : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  /// Whether the device can perform biometric / device-credential auth.
  ///
  /// True when the device is supported AND at least one credential
  /// (biometric or device PIN/pattern/password) can be checked.
  Future<bool> isAvailable() async {
    try {
      final supported = await _auth.isDeviceSupported();
      if (!supported) return false;
      final canCheck = await _auth.canCheckBiometrics;
      // `canCheckBiometrics` is false when only a device PIN exists, but
      // `isDeviceSupported` already guarantees a device credential is set,
      // so either signal is enough to allow the PIN-fallback prompt.
      return canCheck || supported;
    } on PlatformException {
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Prompts the user to authenticate. Allows device-credential fallback
  /// (PIN/pattern/password) so users without enrolled biometrics can still
  /// unlock. Returns `true` on success; never throws.
  Future<bool> authenticate({
    String reason = 'Authenticate to unlock DermIQ',
  }) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: false, // allow device PIN / pattern fallback
          stickyAuth: true, // survive app backgrounding during the prompt
          useErrorDialogs: true,
        ),
      );
    } on PlatformException {
      return false;
    } catch (_) {
      return false;
    }
  }
}
