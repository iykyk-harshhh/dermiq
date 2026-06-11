import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_bootstrap.dart';

/// Thin wrapper over FirebaseAnalytics. All calls are no-ops when Firebase
/// isn't available, so screens can log freely without guarding.
class AnalyticsService {
  AnalyticsService(this._analytics);

  final FirebaseAnalytics? _analytics;

  bool get _on => _analytics != null;

  Future<void> logScreenView(String screenName) async {
    if (!_on) return;
    await _analytics!.logScreenView(screenName: screenName);
  }

  Future<void> logEvent(String name, [Map<String, Object>? params]) async {
    if (!_on) return;
    await _analytics!.logEvent(name: name, parameters: params);
  }

  Future<void> logLogin(String method) async {
    if (!_on) return;
    await _analytics!.logLogin(loginMethod: method);
  }

  Future<void> logSignUp(String method) async {
    if (!_on) return;
    await _analytics!.logSignUp(signUpMethod: method);
  }

  Future<void> setUserId(String? id) async {
    if (!_on) return;
    await _analytics!.setUserId(id: id);
  }

  /// A [NavigatorObserver] you can hand to GoRouter for automatic screen
  /// tracking. Returns null when analytics is off.
  FirebaseAnalyticsObserver? get observer =>
      _on ? FirebaseAnalyticsObserver(analytics: _analytics!) : null;
}

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  if (!FirebaseBootstrap.isAvailable) return AnalyticsService(null);
  try {
    return AnalyticsService(FirebaseAnalytics.instance);
  } catch (e) {
    debugPrint('[Analytics] unavailable: $e');
    return AnalyticsService(null);
  }
});
