# DermIQ — TODO

Priority order follows the MVP launch sequence from the spec.

---

## Phase 1 — Firebase Foundation
These unlock everything else. Do these first.

- [ ] Add `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
- [ ] Uncomment `Firebase.initializeApp()` in `main.dart`
- [ ] Add Firebase packages back to `pubspec.yaml`: `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`, `firebase_analytics`, `firebase_crashlytics`, `firebase_messaging`
- [ ] Replace mock `auth_provider.dart` with real Firebase Auth + Google Sign-In
- [ ] Add router-level `redirect` guard: unauthenticated → `/auth`, authenticated + no onboarding → `/onboarding`
- [ ] Save quiz results to Firestore `users/{uid}` on quiz completion
- [ ] Persist `onboardingComplete: true` flag so splash skips onboarding on re-launch

---

## Phase 2 — Calendar Screen
File: `lib/features/calendar/presentation/screens/calendar_screen.dart`

- [ ] Build month/week toggle view (rule-based, no AI)
- [ ] Show routine check-in dots per day
- [ ] Tap a day → show that day's routine completion
- [ ] Wire to bottom nav tab (replace placeholder in `StatefulShellRoute`)
- [ ] Store check-ins in Firestore `checkIns/{uid}/{date}`
- [ ] Schedule local FCM notification for AM and PM routines

---

## Phase 3 — Progress Screen
File: `lib/features/progress/presentation/screens/progress_screen.dart`

- [ ] Consistency % card (completed days / total days)
- [ ] Current streak counter
- [ ] Monthly completion rate chart (`fl_chart` `LineChart`)
- [ ] Skin score trend chart (pulls from `analysis` collection)
- [ ] Monthly comparison bar chart
- [ ] Wire into `StatefulShellRoute` (currently a placeholder)

---

## Phase 4 — Real Data (Firestore Repositories)
Replace all mock data with live Firestore reads/writes.

- [ ] `RoutineRepository` — save/load AM+PM steps per user
- [ ] `ProductRepository` — CRUD for shelf products
- [ ] `AnalysisRepository` — save analysis results, query history
- [ ] `CheckInRepository` — write check-ins on step complete, read for calendar
- [ ] Wire `routine_screen.dart` step toggles to Firestore
- [ ] Wire `shelf_screen.dart` + `product_detail_screen.dart` to Firestore

---

## Phase 5 — Real AI Integrations
Replace mock response functions with Claude API calls.

- [ ] **AI Chat**: call `claude-sonnet-4-6` with user message + skin profile context
  - Endpoint: Anthropic API via Cloud Function (keep API key server-side)
  - Replace `_getAIResponse()` in `chat_screen.dart`
- [ ] **Ingredient Analyzer**: call Claude with ingredient name + user skin type
  - Replace `_analyze()` mock result in `ingredient_analyzer_screen.dart`
- [ ] **Skin Analysis**: upload image to Firebase Storage → Cloud Function → parse into `AnalysisModel`
  - Current flow: `ScanScreen` captures → `context.push('/analysis')` with hardcoded data
  - Replace with: upload → poll/stream result → navigate with real `analysisId`

---

## Phase 6 — Product Management
- [ ] Add product form (name, brand, category, expiry date picker, photo)
- [ ] Image upload to Firebase Storage
- [ ] Expiry notification (local notification 30 days before expiry)
- [ ] Add-to-routine from product detail screen (writes to `RoutineRepository`)
- [ ] Barcode scanner to pre-fill product fields

---

## Phase 7 — Profile & Onboarding Polish
- [ ] Edit skin profile (re-run quiz or edit individual fields)
- [ ] Profile photo upload to Firebase Storage
- [ ] Achievements: compute from Firestore data (streak, analysis count, etc.)
- [ ] Apple Sign-In (iOS only — required by App Store)

---

## Phase 8 — Settings & Push
- [ ] Save notification preferences to Firestore
- [ ] FCM token registration on login
- [ ] Morning/evening reminder scheduling with `flutter_local_notifications`
- [ ] Deep link from notification → correct routine tab

---

## Cleanup (anytime)
- [ ] Replace all `.withValues()` calls with `.withValues(alpha:)` — 120+ instances
- [ ] Add `analysis_options.yaml` rule to enforce `.withValues`
- [ ] Extract hardcoded mock data from widgets into a `mock_data.dart` file
- [ ] Add `freezed` + `json_serializable` for data models
- [ ] Add error boundary widgets around async screens
- [ ] Write widget tests for `AppCard`, `AppButton`, quiz flow
