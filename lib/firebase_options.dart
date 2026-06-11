// ─────────────────────────────────────────────────────────────────────────────
//  PLACEHOLDER — replace by running:  flutterfire configure
//
//  This file ships as a safe stub so the project compiles before a Firebase
//  project is attached. `currentPlatform` throws a clear error; the app's
//  bootstrap catches it and runs in offline/mock mode (see firebase_bootstrap).
//
//  Once you run `flutterfire configure`, the FlutterFire CLI overwrites this
//  file with the real, per-platform FirebaseOptions and everything activates.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  const DefaultFirebaseOptions._();

  /// Whether real Firebase config has been generated yet.
  /// Flip to `true` automatically once `flutterfire configure` replaces this.
  static const bool isConfigured = false;

  static FirebaseOptions get currentPlatform {
    if (!isConfigured) {
      throw UnsupportedError(
        'Firebase is not configured.\n'
        'Run `dart pub global activate flutterfire_cli` then `flutterfire configure` '
        'from the project root to generate real firebase_options.dart, '
        'google-services.json (android) and GoogleService-Info.plist (ios).',
      );
    }
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for $defaultTargetPlatform.',
        );
    }
  }

  // The FlutterFire CLI will fill these with real values.
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: 'REPLACE_ME',
    projectId: 'REPLACE_ME',
    authDomain: 'REPLACE_ME',
    storageBucket: 'REPLACE_ME',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: 'REPLACE_ME',
    projectId: 'REPLACE_ME',
    storageBucket: 'REPLACE_ME',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: 'REPLACE_ME',
    projectId: 'REPLACE_ME',
    storageBucket: 'REPLACE_ME',
    iosBundleId: 'com.example.dermiq',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: 'REPLACE_ME',
    projectId: 'REPLACE_ME',
    storageBucket: 'REPLACE_ME',
    iosBundleId: 'com.example.dermiq',
  );
}
