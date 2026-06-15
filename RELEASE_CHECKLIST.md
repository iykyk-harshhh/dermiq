# DermIQ — Release Checklist (Pitch-First Plan)

Last updated: 2026-06-15. Readiness ~96%.
Legend: 🔴 blocker · 🟡 important · 🟢 nice-to-have · 👤 manual step · 🤖 code work · 💰 **needs money — deferred until after the investor pitch**

> **Strategy:** Get a polished, fully-demoable build for the investor pitch using
> only the **free** Firebase Spark tier (Auth + Firestore + Storage all work free).
> Anything that costs money — Firebase **Blaze** plan (Cloud Functions), the
> Razorpay merchant account, the Anthropic API key, the Play Console account, and
> the Apple Developer account — is parked in **§ Post-investment** below. The app
> already degrades gracefully without them (COD checkout works; chat falls back to
> built-in replies), so none of them block the pitch demo.

---

## 🎯 Do NOW — pitch-ready build (all free)

These make a clean, end-to-end demo APK that runs on a real phone. No paid accounts.

- [ ] **Firestore security rules** (🤖, free) — publish rules so signed-in users can read/write their own `users/{uid}/**`. Without rules, live reads/writes silently fail in the demo. *(I can write `firestore.rules` + `firebase deploy --only firestore:rules` — deploy is free on Spark.)*
- [ ] **Seed catalog to Firestore** (🤖, free) — `catalog_seed.dart` → `products` collection on first launch, so shop/scan show real data.
- [ ] **Remaining mock screens → real-ish data** (🤖, free, Firestore-backed):
  - [ ] `concerns_widget.dart` — wire to `analysisProvider` instead of hardcoded Pores/Redness/Dark Spots
  - [ ] `progress_screen.dart` — chart from routine history / health score instead of mock series
  - [ ] `calendar_models.dart` — derive from routine completion instead of `calGenerateMonth()` mock
  - [ ] `shop_product_detail_screen.dart` — `_mockReviews()` → Firestore `reviews` (or clearly-labelled seed)
  - [ ] Specialist booking → write to `users/{uid}/appointments` (Firestore, free)
- [ ] **Scanner → analysis wiring** (🤖, free) — call `analysisProvider.setFromScan(...)` so a real scan populates the analysis screen
- [ ] **`scan_provider.dart`** (🤖, free) — persist recent scans (local or Firestore)
- [ ] **`edit_profile_screen.dart`** photo upload (🤖, free) — wire to Firebase Storage (Spark tier OK) instead of "coming soon"
- [ ] **Share button** (🤖, free) — `analysis_results_screen.dart` real share intent (`share_plus`)
- [ ] **Build the demo**: `flutter build apk --release` (signs with the existing keystore) → installable APK to show on a phone at the pitch. *(No Play Console needed for a sideloaded demo.)*
- [ ] **Smoke-test on a device** — sign up, quizzes, scan, shelf, routine, cart, COD checkout, chat (fallback replies).

---

## 💰 Post-investment — paid accounts & deploys (parked)

Do these only after funding. Code is already written and waits behind a graceful fallback.

- [ ] 💰 **Firebase Blaze plan** — required for Cloud Functions (pay-as-you-go, has a free tier but needs a card on file).
- [ ] 💰 **Deploy payments backend** — Razorpay merchant account → `firebase functions:secrets:set RAZORPAY_KEY_ID` + `RAZORPAY_KEY_SECRET` → `cd functions && npm install && firebase deploy --only functions`. Until then, **COD works** and online pay shows "Payment Unavailable".
- [ ] 💰 **Deploy chat backend** — `firebase functions:secrets:set ANTHROPIC_API_KEY` → deploy. Until then chat uses the built-in keyword fallback.
- [ ] 💰 **Google Play Console** ($25 one-time) — create the app, Data Safety form, store listing, then `flutter build appbundle --release` and upload.
- [ ] 💰 **Play App Signing** — after enrolling, add Google's app-signing SHA-1 (Play Console → Setup → App signing) to Firebase, else Google Sign-In fails (`ApiException: 10`) on Play installs.
- [ ] 💰 **Apple Developer account** ($99/yr) + iOS signing — only if shipping iOS.
- [ ] **Privacy Policy URL** (👤, free to host e.g. GitHub Pages, but needed for Play submission — post-pitch).

---

## ✅ Done
- [x] Launcher icon + native splash assets (`tool/gen_brand_assets.py`)
- [x] Splash screen finalized (text, purple logo, Get Started pill)
- [x] `applicationId` = `com.dermiq.app` · minSdk 23 · R8 + ProGuard · Android permissions
- [x] Release keystore + `android/key.properties` (git-ignored; backed up to OneDrive). ⚠️ password saved offline.
- [x] Firebase configured (`dermiq-83cfd`) — config files + gms/crashlytics plugins
- [x] Google Sign-In (Android) — debug + release SHA-1/256 registered, Google/Email/Anonymous enabled, `oauth_client` populated
- [x] iOS identity — bundle id `com.dermiq.app`, iOS Firebase app + `GoogleService-Info.plist`, Info.plist URL scheme (Xcode target add still pending on a Mac)
- [x] Auth hardening — real `sendPasswordResetEmail` (OTP mock removed); release builds can't silently mock-auth; "Sarah Johnson" fallback removed
- [x] Firestore persistence live — `healthScore`, `selectedTheme`, shelf (`users/{uid}/shelf`), orders (`users/{uid}/orders`)
- [x] Routine completion + history persist locally (daily reset); cart persists locally
- [x] Pre-seeded 43-day streak removed (new users start at 0)
- [x] Scanner — live Open Beauty Facts lookup (free) + mock fallback
- [x] Chat — Claude (`claude-haiku-4-5`) via Cloud Function + keyword fallback + medical-advice disclaimer *(deploy is paid — see §Post-investment)*
- [x] Payments — secure Razorpay flow (server order + signature verify); COD works offline *(deploy is paid — see §Post-investment)*
- [x] Empty `assets/animations` / `assets/lottie` pubspec refs removed
- [x] Test suite green (93 tests; serialization + persistence + scanner covered)

---

## 🟢 Nice-to-have / later
- [ ] Replace placeholder app icon with final designer artwork (💰 if hiring a designer)
- [ ] UI illustration assets (backgrounds, empty states)
- [ ] FCM push payload/topic handling + streak-milestone notifications
- [ ] Custom-routine-step authoring persistence (needs `IconData` serialization + `--no-tree-shake-icons`)
- [ ] Tests for Firebase-dependent flows (auth, Firestore) once Blaze is live
- [ ] Delete old iOS Firebase app (`…fa4d2a6c…`, `com.example.dermiq`) — harmless to leave
