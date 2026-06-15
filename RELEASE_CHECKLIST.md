# DermIQ — Master To-Do / Play Store Release Checklist

Complete, exhaustive list of pending work. Last updated: 2026-06-15. Readiness ~85%.
Legend: 🔴 blocker · 🟡 important · 🟢 nice-to-have · 👤 needs your account/manual step · 🤖 code work

---

## ✅ Done
- [x] Launcher icon + native splash assets (`tool/gen_brand_assets.py`)
- [x] Skin score / analysis / concerns wired to Riverpod providers
- [x] Splash screen finalized (text, purple logo, Get Started pill)
- [x] `applicationId` = `com.dermiq.app` · minSdk 23 · R8 + ProGuard · Android permissions
- [x] Test suite present (no skipped/TODO tests)
- [x] Firebase configured (project `dermiq-83cfd`) — `google-services.json` + `firebase_options.dart` in place, gms + crashlytics plugins enabled
- [x] Google Sign-In (Android) — debug SHA-1/SHA-256 registered, Google/Email/Anonymous providers enabled, `oauth_client` populated (Android + Web)
- [x] Firestore writes live — `healthScore` ([health_score_provider.dart](lib/features/home/providers/health_score_provider.dart)) + `selectedTheme` ([theme_provider.dart](lib/features/settings/providers/theme_provider.dart))

---

## 🔴 Critical blockers

### Firebase & accounts (👤)
- [x] Run `flutterfire configure` → real `firebase_options.dart` + `google-services.json`
- [x] Uncomment 2 plugins in `android/app/build.gradle.kts:11-12`
- [x] Create release keystore + `android/key.properties` — `C:\Users\harsh\dermiq-upload.jks` (alias `upload`), `key.properties` written + git-ignored. ⚠️ Back up the .jks + password offline; if lost you can't update the app.
- [x] Release SHA-1 + SHA-256 registered with Firebase; `google-services.json` re-downloaded (`oauth_client` = 3)
- [ ] **If enabling Play App Signing** — Google re-signs your app with *their* key, so also add the SHA-1 from Play Console → Setup → App signing to Firebase, or Google Sign-In fails (`ApiException: 10`) on Play-installed builds.

### iOS identity (🤖 + 👤)
- [ ] iOS bundle id is still `com.example.dermiq` — fix in `ios/Runner.xcodeproj/project.pbxproj` (multiple) and `lib/firebase_options.dart:67,76`
- [ ] Configure iOS signing team in Xcode

---

## 🟡 Code work — replace mocks / wire backends (🤖)

### Auth & account
- [ ] `forgot_password_screen.dart:34-159` — OTP is generated/verified locally (mock). Replace with `FirebaseAuth.sendPasswordResetEmail()`
- [x] `auth_provider.dart` — `FirebaseAuthService` now active (Firebase configured); `MockAuthService` remains as offline fallback only
- [ ] `profile_provider.dart:62` — hardcoded fallback name "Sarah Johnson"/email when user null
- [ ] `edit_profile_screen.dart:92` — photo upload shows "coming soon" snackbar; wire to Firebase Storage

### Data persistence (Firestore stubs commented out)
- [x] `health_score_provider.dart` — Firestore write live (`healthScore`)
- [x] `theme_provider.dart` — Firestore write live (`selectedTheme`)
- [ ] `routine_provider.dart` — state is in-memory only; persist AM/PM steps, completions, history
- [ ] `cart_provider.dart` — cart lost on restart; add persistence
- [ ] `scan_provider.dart` — recent scans in-memory only; persist
- [ ] `streak_provider.dart:39-47` — pre-seeded 43-day streak on first run (remove before launch)

### Feature backends
- [ ] `chat_screen.dart:72-84` — `_getAIResponse()` keyword matching → real LLM API
- [ ] `product_remote_data_source.dart:13-47` — `MockProductRemoteDataSource` (3 barcodes) → real product API (Open Beauty Facts ref at lines 54-68)
- [ ] Scanner → call `analysisProvider.setFromScan(...)` so real scans populate analysis
- [ ] `shop_product_detail_screen.dart:364-386` — `_mockReviews()` fake reviews → real reviews
- [ ] Order placement (`order_provider.dart`) — in-memory, auto-marks delivered → real backend + payment
- [ ] Specialist booking — detail screen exists, no booking backend
- [ ] FCM — wired in bootstrap but no push payload/topic handling; milestone notifications (`streak_provider.dart:103-110`)
- [ ] `catalog_seed.dart` — seed into Firestore on first launch (after Firebase live)

### Screens still on mock/hardcoded data
- [ ] `concerns_widget.dart:10-14` — hardcoded Pores/Redness/Dark Spots
- [ ] `calendar_models.dart:53-88` — `calGenerateMonth()` deterministic mock data
- [ ] `progress_screen.dart` — mock chart data, no data source wired
- [ ] `analysis_provider.dart` — currently seed data (scan-ready via `setFromScan`)

### Incomplete UI actions (snackbar placeholders)
- [ ] `analysis_results_screen.dart:65-73` — Share button shows snackbar, no real share intent

---

## 🟢 Assets & polish
- [ ] `assets/animations/` and `assets/lottie/` referenced in pubspec but empty (remove refs or add files)
- [ ] Replace placeholder app icon with final designer artwork
- [ ] No UI illustration assets yet (backgrounds, empty states)

---

## 🟢 Store submission prerequisites (👤)
- [ ] Privacy Policy URL (mandatory — camera + account data)
- [ ] Play Console Data Safety form + camera permission justification
- [ ] Store listing — screenshots, feature graphic (1024×500), descriptions
- [ ] `flutter build appbundle --release`
- [ ] Bump `version:` in `pubspec.yaml` per release
- [ ] Add tests for Firebase-dependent flows (auth, Firestore)
</content>
