import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';
import 'messaging_service.dart';

/// Initializes Firebase and wires global error reporting.
///
/// Designed to never crash the app: if Firebase config is missing (no
/// `flutterfire configure` yet) initialization is skipped and [isAvailable]
/// stays `false`, so the app falls back to its offline/mock providers.
class FirebaseBootstrap {
  const FirebaseBootstrap._();

  static bool _available = false;

  /// `true` once Firebase has initialized successfully on this device.
  static bool get isAvailable => _available;

  /// Call once, very early in `main()`. Returns whether Firebase came up.
  static Future<bool> init() async {
    if (!DefaultFirebaseOptions.isConfigured) {
      debugPrint('[Firebase] Not configured — running in offline/mock mode. '
          'Run `flutterfire configure` to enable.');
      return false;
    }

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _available = true;
      await _wireCrashlytics();
      // Register the FCM background handler (must be a top-level function).
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      return true;
    } catch (e, st) {
      _available = false;
      debugPrint('[Firebase] init failed: $e\n$st');
      return false;
    }
  }

  /// Route Flutter framework + platform errors into Crashlytics.
  static Future<void> _wireCrashlytics() async {
    final crashlytics = FirebaseCrashlytics.instance;

    // Disable collection in debug to keep the dashboard clean.
    await crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);

    final originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      crashlytics.recordFlutterFatalError(details);
      originalOnError?.call(details);
    };

    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      crashlytics.recordError(error, stack, fatal: true);
      return true;
    };
  }
}
