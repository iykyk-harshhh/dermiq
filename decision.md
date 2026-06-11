# DermIQ — Architecture & Design Decisions

## Auth Layer

**Decision: Mock auth provider, not Firebase.**
Firebase is not connected yet (no `google-services.json`). Auth lives in `auth_provider.dart` as a `StateProvider<_MockUser?>`. When Firebase is wired, replace the entire provider — the rest of the app only reads `authStateProvider` and `authProvider`, so the swap is isolated.

**Decision: No router-level redirect guard.**
The router does not redirect based on auth state. Navigation is handled imperatively after sign-in/sign-up (`context.go('/home')`). Reason: avoids a recursive redirect loop when Firebase is offline. Add a `redirect` callback once Firebase is live.

---

## State Management

**Decision: Riverpod `StateProvider` and `StateNotifierProvider`, no code gen.**
`riverpod_annotation` and `build_runner` were removed from pubspec to keep the initial setup simple. Add them back when the feature count grows and the boilerplate becomes painful.

**Decision: No global user state beyond auth.**
Skin profile, quiz results, and routine data are not yet persisted to Firestore. Each screen uses local mock data. Migration path: wrap each feature's data in an `AsyncNotifier` backed by a Firestore repository.

---

## Routing

**Decision: `StatefulShellRoute.indexedStack` for bottom nav.**
Preserves scroll/state per tab without rebuilding. The five branches are: Home, Scan, Routine, Shelf, Profile. Deep-link screens (Analysis, Product Detail, Chat, Ingredients, Settings) sit outside the shell as top-level `GoRoute` entries.

**Decision: `/splash` is always the `initialLocation`.**
Splash auto-navigates to `/auth` after 3 seconds. There is no persist-login check yet — add it inside `SplashScreen.initState` once Firebase auth is connected.

---

## Design System

**Decision: Google Fonts Poppins, not bundled font files.**
Avoids checking 4 TTF files into the repo. `GoogleFonts.poppinsTextTheme()` is set as the base `textTheme` in `AppTheme`. All text styles are getters on `AppTextStyles` — not `const` — because `GoogleFonts.*` returns a new instance each call.

**Decision: `withValues` left as-is (info-level deprecation, not an error).**
Flutter 3.x prefers `.withValues(alpha:)`. Will migrate in a cleanup pass. Does not affect rendering.

**Decision: `AppCard` + `GlassCard` as the only card primitives.**
No `Material` / `Card` widget used directly in features. All surfaces go through these two shared widgets. Keeps shadow, radius, and color consistent.

---

## AI Features

**Decision: AI Chat is a mock response engine, not a real LLM.**
`_getAIResponse()` in `chat_screen.dart` does keyword matching. Replace with a call to the Claude API (`claude-sonnet-4-6`) when ready. Keep the UI and message model unchanged — only the transport layer changes.

**Decision: Skin Analysis is a simulated flow.**
Scan captures an image, waits 2 seconds, then navigates to hardcoded metric results. Real integration path: upload image to Firebase Storage → call a Cloud Function → parse response into `AnalysisModel`.

**Decision: Ingredient Analyzer is client-side mock.**
Same pattern as AI Chat. Replace `_getAIResponse` with a Claude API call passing the ingredient name and the user's skin profile as context.

---

## What Is NOT Built Yet

| Feature | Status |
|---|---|
| Firebase Auth (real) | Stub only |
| Firestore persistence | Not started |
| Firebase Storage (images) | Not started |
| Calendar screen | Placeholder route only |
| Progress screen | Placeholder route only |
| FCM push notifications | Not started |
| Real camera (not image_picker) | Uses `image_picker` only |
| Crashlytics / Analytics | Not started |
