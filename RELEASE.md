# DermIQ — Release Checklist (Play Store + App Store)

Status of the things this review wired up, and what still needs a human.

## ✅ Done in code
- **Android build no longer broken** — the Crashlytics Gradle plugin was applied
  without `google-services`, which fails the build. Both Firebase plugins are now
  disabled together (re-enable both after `flutterfire configure`).
- **Real applicationId** — `com.dermiq.app` (was the `com.example.dermiq`
  placeholder, which the Play Store rejects). Confirm this is the id you want.
- **Release signing** — `android/app/build.gradle.kts` reads `android/key.properties`
  (git-ignored) and falls back to debug keys when absent. See `key.properties.example`.
- **R8 / shrinking** — `isMinifyEnabled` + `isShrinkResources` on release, with keep
  rules in `android/app/proguard-rules.pro` (ML Kit, Firebase, mobile_scanner).
- **iOS permission strings** — `NSCameraUsageDescription` + `NSPhotoLibraryUsageDescription`
  already present in `ios/Runner/Info.plist`.
- **Icon / splash config** — `flutter_launcher_icons` + `flutter_native_splash`
  configured in `pubspec.yaml`.
- **Accessibility** — shared buttons/back-buttons/tiles now expose `Semantics`
  (button role + labels); icon-only `AppIconButton` takes a `semanticLabel`.

## ▢ You must do
1. **Create the signing keystore** and `android/key.properties` (see example file).
2. **Provide store art**: `assets/images/app_icon.png` (1024²),
   `app_icon_foreground.png`, `splash_logo.png`, then run:
   ```
   dart run flutter_launcher_icons
   dart run flutter_native_splash:create
   ```
3. **Firebase** (if shipping with backend): `flutterfire configure`, then un-comment
   the two Firebase plugins in `android/app/build.gradle.kts`, the init in
   `lib/main.dart`, and deploy `firestore.rules` / `storage.rules`.
4. **Test a release build** (R8 can surface missing keep rules):
   `flutter build appbundle --release` and smoke-test the APK.
5. **iOS**: set the bundle id + team in Xcode, bump build number, add Push +
   Background-Modes capabilities if using FCM, archive via Xcode.
6. **Store listings**: privacy policy URL, Play **Data safety** form + App Store
   **App Privacy** (camera, account, analytics), screenshots, content rating.
7. **Version**: bump `version:` in `pubspec.yaml` per release (`x.y.z+build`).

## Known follow-up tech debt (not release-blocking)
- Consolidate ~16 inline icon-button widgets (`_HeaderBtn`, `_NavBtn`, `_CircleBtn`,
  …) onto `AppBackButton` / `AppIconButton`; add `semanticLabel`s at each call site.
- Responsiveness: many fixed-px sizes; adopt `MediaQuery`/`LayoutBuilder` for small
  screens and respect text scaling on the fixed-`fontSize` styles.
- Raise test coverage on screens (logic is well-covered; UI is ~1%).
