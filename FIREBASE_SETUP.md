# Firebase Setup — DermIQ

All integration code is already written and compiles. The app currently runs in
**offline / mock mode** because no Firebase project is attached yet. Follow these
steps to activate the real backend. Nothing in the app breaks until you do — the
service layer detects the missing config and falls back to mock providers.

## 1. Create the Firebase project
1. Go to <https://console.firebase.google.com> and create a project.
2. Enable the products: **Authentication**, **Firestore**, **Storage**,
   **Cloud Messaging**, **Analytics**, **Crashlytics**.
3. In Authentication → Sign-in method, enable **Email/Password**, **Google**, and
   **Anonymous**.

## 2. Attach the apps & generate config
Install the CLIs once:
```bash
dart pub global activate flutterfire_cli
npm install -g firebase-tools && firebase login
```
Then from the project root:
```bash
flutterfire configure
```
This generates/overwrites:
- `lib/firebase_options.dart` (real values; `isConfigured` becomes effectively true)
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

> The stub `lib/firebase_options.dart` throws until this runs — that's intentional.

## 3. Android
Already wired in this repo:
- `android/settings.gradle.kts` — `com.google.gms.google-services` + `com.google.firebase.crashlytics` plugins.
- `android/app/build.gradle.kts` — both plugins applied; `minSdk` raised to 23 (firebase_auth requirement).
- `AndroidManifest.xml` — `POST_NOTIFICATIONS` permission + default FCM channel.

For **Google Sign-In**, add your debug & release SHA-1/SHA-256 fingerprints in the
Firebase console (Project settings → Your apps → Android), then re-download
`google-services.json`.

## 4. iOS
- Add `GoogleService-Info.plist` to `ios/Runner` via Xcode (so it's bundled).
- Enable **Push Notifications** and **Background Modes → Remote notifications**
  capabilities in Xcode.
- For Crashlytics dSYM upload, add a run-script build phase per the Firebase docs.

## 5. Deploy security rules
Production-ready rules are in `firestore.rules` and `storage.rules` (each user can
only access their own `users/{uid}` tree).
```bash
firebase deploy --only firestore:rules,storage
```

## 6. Run
```bash
flutter pub get
flutter run
```
On a configured project you'll see real auth, Firestore persistence, Storage
uploads, FCM token registration, Analytics screen tracking, and Crashlytics
reports. To test a crash: `FirebaseCrashlytics.instance.crash()`.

---

## Architecture map
| Concern | File |
| --- | --- |
| Init + global error handlers | `lib/core/firebase/firebase_bootstrap.dart` |
| Generated options (stub) | `lib/firebase_options.dart` |
| Auth (Firebase + mock fallback) | `lib/features/auth/providers/auth_provider.dart` |
| Firestore refs + instance | `lib/core/firebase/firestore_service.dart` |
| Repositories | `lib/core/firebase/repositories/*.dart` |
| Storage | `lib/core/firebase/storage_service.dart` |
| Messaging (FCM) | `lib/core/firebase/messaging_service.dart` |
| Analytics | `lib/core/firebase/analytics_service.dart` |
| Crashlytics | `lib/core/firebase/crashlytics_service.dart` |

Every service exposes a Riverpod provider and **no-ops gracefully** when Firebase
isn't available, so screens can call them unconditionally.
