import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_bootstrap.dart';

/// Wrapper over FirebaseCrashlytics. No-ops when Firebase is unavailable.
/// Global Flutter/platform error handlers are wired in [FirebaseBootstrap];
/// use this for manual, non-fatal reports and breadcrumbs.
class CrashlyticsService {
  CrashlyticsService(this._crashlytics);

  final FirebaseCrashlytics? _crashlytics;

  bool get _on => _crashlytics != null;

  /// Record a caught (non-fatal) error.
  Future<void> recordError(
    Object error,
    StackTrace? stack, {
    String? reason,
    bool fatal = false,
  }) async {
    if (!_on) return;
    await _crashlytics!.recordError(error, stack, reason: reason, fatal: fatal);
  }

  /// Add a breadcrumb shown alongside the next crash report.
  Future<void> log(String message) async {
    if (!_on) return;
    await _crashlytics!.log(message);
  }

  Future<void> setUserId(String id) async {
    if (!_on) return;
    await _crashlytics!.setUserIdentifier(id);
  }

  Future<void> setCustomKey(String key, Object value) async {
    if (!_on) return;
    await _crashlytics!.setCustomKey(key, value);
  }
}

final crashlyticsServiceProvider = Provider<CrashlyticsService>((ref) {
  if (!FirebaseBootstrap.isAvailable) return CrashlyticsService(null);
  return CrashlyticsService(FirebaseCrashlytics.instance);
});
