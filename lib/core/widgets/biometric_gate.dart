import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/settings/providers/settings_provider.dart';
import '../services/biometric_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/dermiq_colors.dart';

/// Wraps the app and enforces the "Biometric Lock" privacy toggle.
///
/// When the `biometricLock` setting is ON, the gate shows a lock screen and
/// requires a successful [BiometricService.authenticate] before revealing
/// [child]. It locks on cold start and re-locks whenever the app returns from
/// the background. When the setting is OFF it is a transparent pass-through.
///
/// Usage (in `main.dart`, wrapping the app's home / router output):
/// ```dart
/// MaterialApp.router(
///   builder: (context, child) => BiometricGate(child: child ?? const SizedBox()),
///   // ...
/// );
/// ```
/// or wrap the home widget directly: `BiometricGate(child: HomeShell())`.
/// The gate must sit BELOW `ProviderScope` (it reads Riverpod) and, if used in
/// `MaterialApp.builder`, it already has access to Directionality/Theme.
class BiometricGate extends ConsumerStatefulWidget {
  const BiometricGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<BiometricGate> createState() => _BiometricGateState();
}

class _BiometricGateState extends ConsumerState<BiometricGate>
    with WidgetsBindingObserver {
  final _biometrics = BiometricService();

  /// Whether the lock screen is currently covering [child].
  bool _locked = false;

  /// Guards against overlapping authenticate() prompts.
  bool _authenticating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Lock on cold start if the setting is enabled.
    final enabled = ref.read(settingsProvider).biometricLock;
    if (enabled) {
      _locked = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _promptUnlock());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final enabled = ref.read(settingsProvider).biometricLock;
    if (!enabled) return;

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      // Went to background — re-lock so the next resume requires auth.
      if (!_locked && mounted) setState(() => _locked = true);
    } else if (state == AppLifecycleState.resumed) {
      if (_locked) _promptUnlock();
    }
  }

  Future<void> _promptUnlock() async {
    if (_authenticating) return;
    _authenticating = true;
    final ok = await _biometrics.authenticate(
      reason: 'Unlock DermIQ to continue',
    );
    _authenticating = false;
    if (!mounted) return;
    if (ok) setState(() => _locked = false);
  }

  @override
  Widget build(BuildContext context) {
    // Pass-through the moment the setting is off (also unlocks live if the
    // user disables it from another surface).
    final enabled = ref.watch(
      settingsProvider.select((s) => s.biometricLock),
    );

    return Stack(
      children: [
        widget.child,
        if (enabled && _locked)
          _LockScreen(onUnlock: _promptUnlock),
      ],
    );
  }
}

class _LockScreen extends StatelessWidget {
  const _LockScreen({required this.onUnlock});

  final VoidCallback onUnlock;

  @override
  Widget build(BuildContext context) {
    final c = context.dColors;
    return Positioned.fill(
      child: Material(
        color: c.background,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.gradientPrimary,
                  ),
                  child: const Icon(
                    Icons.lock_rounded,
                    color: Colors.white,
                    size: 44,
                  ),
                ),
                const SizedBox(height: 28),
                Text('DermIQ is locked', style: AppTypography.h3),
                const SizedBox(height: 8),
                Text(
                  'Unlock with Face ID, Touch ID or your device passcode.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium.copyWith(
                    color: c.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: onUnlock,
                    icon: const Icon(Icons.fingerprint_rounded),
                    label: Text('Unlock', style: AppTypography.button),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
