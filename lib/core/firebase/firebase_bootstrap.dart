import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';
import 'messaging_service.dart';

class FirebaseBootstrap {
  const FirebaseBootstrap._();

  static bool _available = false;

  static bool get isAvailable => _available;

  static Future<bool> init() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      _available = true;

      await _wireCrashlytics();

      FirebaseMessaging.onBackgroundMessage(
        firebaseMessagingBackgroundHandler,
      );

      return true;
    } catch (e, st) {
      _available = false;

      debugPrint(
        '[Firebase] init failed: $e\n$st',
      );

      return false;
    }
  }

  static Future<void> _wireCrashlytics() async {
    final crashlytics = FirebaseCrashlytics.instance;

    await crashlytics.setCrashlyticsCollectionEnabled(
      !kDebugMode,
    );

    final originalOnError = FlutterError.onError;

    FlutterError.onError = (
        FlutterErrorDetails details,
        ) {
      crashlytics.recordFlutterFatalError(details);

      originalOnError?.call(details);
    };

    PlatformDispatcher.instance.onError = (
        Object error,
        StackTrace stack,
        ) {
      crashlytics.recordError(
        error,
        stack,
        fatal: true,
      );

      return true;
    };
  }
}