# DermIQ — Release Checklist (Pitch-First Plan)

Last updated: 2026-06-15. Readiness ~96%.
Legend: 🔴 blocker · 🟡 important · 🟢 nice-to-have · 👤 manual step · 🤖 code work · 💰 **needs money — deferred until after the investor pitch**

> **Strategy:** Get a polished, fully-demoable build for the investor pitch using
> only the **free** Firebase Spark tier (Auth + Firestore + Storage all work free)
> and the **free** Gemini AI tier (AI chat, called directly — no Blaze).
> Anything that costs money — the Razorpay merchant account, the Play Console
> account, and the Apple Developer account — is parked in **§ Post-investment**
> below. The app already degrades gracefully without them (COD checkout works),
> so none of them block the pitch demo.

---

## 🎯 Do NOW — pitch-ready build (all free)

These make a clean, end-to-end demo APK that runs on a real phone. No paid accounts.

- [x] **Firestore security rules** deployed (free) — per-user `users/{uid}/**` locked to owner; `products` read-only; reviews own-write. This also created the Firestore database (didn't exist before).
- [x] **Crash-proofed the demo** — scanner model hardened against malformed OBF payloads; splash/routine/product-detail were already guarded (verified).
- [x] **Killed placeholder buttons** — Help & Support Email/Call/Live-Chat → real `mailto:`/`tel:` (`url_launcher`); Analysis Share → real share sheet (`share_plus`); appointment Directions → Google Maps; "Rate the App" tile removed (not on store yet); Add-to-Calendar removed; Edit-Profile photo badge hidden. Android `<queries>` added for intent resolution.
- [x] **Settings + Quiz persist** — toggles and skin/hair answers survive restart (`PreferencesService` JSON).
- [x] **Build the demo** — `flutter build apk --release` → signed `app-release.apk` (~110 MB).
- Catalog seed to Firestore **not needed** for the demo — `ProductRepository` falls back to the local `catalogProducts` seed when the cloud collection is empty.
- [x] `concerns_widget.dart` — now reads top concerns from `analysisProvider` (no more hardcoded Pores/Redness/Dark Spots)
- [x] `progress_screen.dart` — score card uses live `healthScoreProvider` + band; trend chart from real routine-history scores; metrics from `analysisProvider` concerns (removed fake "82 / +18% / fixed chart / fixed deltas")
- Reviews & calendar **left as deterministic** — reviews are already curated per-product (read as real); calendar has no real date-keyed routine log to draw from (mock is demo-plausible). True versions are post-MVP (need a review backend / dated completion store).
- [x] Specialist booking → `AppointmentRepository` + `appointmentProvider`; booking persists to `users/{uid}/appointments` and streams into My Appointments (cancel persists too). Falls back to sample list when signed out/offline.
- [ ] **Scanner → analysis wiring** (🤖, free) — call `analysisProvider.setFromScan(...)` so a real scan populates the analysis screen
- [ ] **`scan_provider.dart`** (🤖, free) — persist recent scans
- [ ] **`edit_profile_screen.dart`** real photo upload → Firebase Storage (Spark tier OK) — *deferred; badge hidden for now*
- [ ] **Smoke-test on a device** — sign up, quizzes, scan, shelf, routine, cart, COD checkout.

---

## 💰 Post-investment — paid accounts & deploys (parked)

Do these only after funding. Code is already written and waits behind a graceful fallback.

- [ ] 💰 **Firebase Blaze plan** — required for Cloud Functions (pay-as-you-go, has a free tier but needs a card on file).
- [ ] 💰 **Deploy payments backend** — Razorpay merchant account → `firebase functions:secrets:set RAZORPAY_KEY_ID` + `RAZORPAY_KEY_SECRET` → `cd functions && npm install && firebase deploy --only functions`. Until then, **COD works** and online pay shows "Payment Unavailable".
- [x] **AI chat — LIVE on Gemini free tier (no Blaze).** The app calls the Gemini REST API directly (`gemini-2.5-flash`); key injected at build time via `--dart-define=GEMINI_API_KEY=...` (never committed). Falls back to the built-in keyword KB if the key is absent or a call fails. *(The old Claude Cloud Function in `functions/index.js` is now unused/parked.)*
  - [ ] 🟡 **Pre-launch security** — a client-side key is extractable from the APK. Before public release, move the Gemini call behind a server/proxy (or add an API-key application restriction + App Check). Fine as-is for the demo.
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
- [x] Chat — **Gemini `gemini-2.5-flash` (free tier, direct REST call)** + keyword fallback + medical-advice disclaimer. Key via `--dart-define=GEMINI_API_KEY`.
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
