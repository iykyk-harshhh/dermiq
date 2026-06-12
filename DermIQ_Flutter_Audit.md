# DermIQ Flutter — Full Audit Report

> Source: `dermiq-main` (uploaded June 12, 2026)
> Analyzer: `flutter analyze` — **124 issues found**
> Audit covers: real bugs, dead UI interactions, analyzer warnings, and architecture notes.

---

## 🔴 Real Bugs — Fix These First

### 1. Router collision: `/shelf` opens the Shop, not the Shelf
**File:** `lib/core/router/app_router.dart:278`

The bottom-nav branch registered at `AppRoutes.shelf` (`/shelf`) uses `ShopScreen()` as its builder. The actual `ShelfScreen()` lives at `/my-shelf` as a separate top-level route. Any code that pushes `/shelf` expecting the personal shelf gets the shop instead. The route constant name `shelf` is misleading and will cause silent bugs as the codebase grows.

**Fix:** Either rename the constant to `shop` throughout, or swap the builder to the correct screen. Both paths are already registered — they just need to be consistent.

---

### 2. Async `BuildContext` use after `await` in sign-out
**File:** `lib/features/settings/presentation/screens/settings_screen.dart:189`
**Analyzer:** `use_build_context_synchronously`

The `_signOut` method is async and uses `context` after an `await`. The `if (!context.mounted) return` guard is present on line 24, but the analyzer still flags line 189 specifically, which means there is a context access after an await that is not guarded. Using `BuildContext` after an async gap without a mounted check can cause crashes when the widget is no longer in the tree.

**Fix:** Add `if (!context.mounted) return;` before every `context.` call that follows an `await`.

---

### 3. `_shellNavigatorKey` declared but never used
**File:** `lib/core/router/app_router.dart:21`
**Analyzer:** `unused_element`

A `GlobalKey<NavigatorState>` is declared but never referenced anywhere in the router. Unused navigator keys in `go_router` apps can silently cause scoped navigation to fail if the key was intended to scope a nested navigator that no longer exists.

**Fix:** Remove the declaration, or wire it to the sub-navigator it was intended for.

---

## 🟡 Dead UI Interactions

### 4. Recommendation cards have no `onTap`
**File:** `lib/features/home/presentation/screens/home_screen.dart` — `_RecommendationCard`

The three recommendation cards (Ceramide Moisturiser, Niacinamide 10%, SPF 50+) are styled with borders, shadows, and rounded corners that signal interactivity, but they wrap a plain `Container` with no `GestureDetector`. Users will tap these and nothing happens.

**Fix:** Wrap each card in a `GestureDetector` and navigate to the relevant shop product detail or search result.

---

### 5. Routine step cards have no `onTap`
**File:** `lib/features/home/presentation/screens/home_screen.dart` — `_RoutineStepCard`

The three today's-routine cards (CeraVe, The Ordinary, Neutrogena) look tappable but are plain `Container`s. Tapping them does nothing.

**Fix:** Add a `GestureDetector` navigating to the routine screen or the product detail for that step.

---

## 🟠 Hardcoded Data Showing as Real

### 6. Today's routine never reads from the routine provider
**File:** `lib/features/home/presentation/screens/home_screen.dart` — `_TodaysRoutineRow`

The three routine steps are declared as `static const _steps` — they never change regardless of what the user has saved. The routine provider exists in the codebase but this widget doesn't read it.

**Fix:** Replace the static list with a `ConsumerWidget` that reads from `routineProvider` (or equivalent) and renders the user's actual saved AM routine steps.

---

### 7. Health score mini-metrics and delta are hardcoded
**File:** `lib/features/home/presentation/screens/home_screen.dart` — `_MiniMetric`, `_HealthScoreHeroCard`

Hydration (72%), Oil Balance (65%), UV Shield (88%), and the "+5 pts" delta are all literal constants. They look like live personalised data but never change for any user.

**Fix:** Either compute these from real data (routine consistency, product analysis history), or add a visible label making clear they are illustrative until real data is available. Showing fabricated health metrics to users without labelling them is a trust issue in a health-adjacent app.

---

## 🔵 Analyzer Warnings — Clean Up

### 8. Unused `key` parameters on six widgets
**Analyzer:** `unused_element_parameter`

The following widgets declare an optional `key` parameter that is never passed anywhere in the app. Dead API surface — remove them.

| File | Line |
|------|------|
| `lib/features/analysis/presentation/screens/analysis_results_screen.dart` | 229 |
| `lib/features/chat/presentation/screens/chat_screen.dart` | 255 |
| `lib/features/home/presentation/widgets/quick_actions_widget.dart` | 43 |
| `lib/features/home/presentation/widgets/routine_preview_widget.dart` | 98 |
| `lib/features/ingredients/presentation/screens/ingredient_analyzer_screen.dart` | 180 |
| `lib/features/shelf/presentation/screens/shelf_screen.dart` | 129 |

**Fix:** Remove the `Key? key` parameter from each widget's constructor.

---

### 9. Unused import in `chat_screen.dart`
**File:** `lib/features/chat/presentation/screens/chat_screen.dart:5`
**Analyzer:** `unused_import`

`app_card.dart` is imported but nothing from it is used in this file.

**Fix:** Delete the import line.

---

### 10. Unused `photoURL` parameter in `auth_provider.dart`
**File:** `lib/features/auth/providers/auth_provider.dart:13`
**Analyzer:** `unused_element_parameter`

The `photoURL` parameter is declared on the `AppUser` constructor alias but is never passed at any call site.

**Fix:** Remove the parameter, or pass it from `AppUser.fromFirebase` where `u.photoURL` is already available.

---

### 11. `withValues(alpha:)` deprecation — 80+ instances across every file
**Analyzer:** `deprecated_member_use`

Every `.withValues(alpha: x)` call in the codebase is flagged. This is the Flutter `Color.withOpacity()` → `Color.withValues()` API migration. The specific overload being used here (`withValues(alpha:)`) is the deprecated form.

**Fix:** Global find-and-replace. Replace `.withValues(alpha: x)` with `.withAlpha((x * 255).round())` for values in the 0.0–1.0 range. This is 80+ instances — do it as a single sweep, not file by file. It won't crash the app today but becomes an error in a future Flutter version.

```dart
// Before (deprecated)
color.withValues(alpha: 0.32)

// After (correct)
color.withAlpha((0.32 * 255).round())  // = 82
```

---

### 12. Unnecessary underscores in router and screen files
**Analyzer:** `unnecessary_underscores`

Multiple `(_, _)` patterns in GoRoute builders and `AnimatedBuilder` should use `_` (single underscore) per the analyzer's recommendation. This is a lint style issue, not a bug, but it's quick to fix globally.

**Files:** `app_router.dart` (13 instances), `analysis_results_screen.dart` (3), `splash_screen.dart` (3), `chat_screen.dart` (1), `scan_screen.dart` (1)

**Fix:** Replace `(_, _)` with `(_)` or use `(context, _)` where context is needed.

---

## 🔵 Architecture Notes

### 13. `FirebaseBootstrap.isAvailable` silently falls through to mock auth in production
**File:** `lib/features/auth/providers/auth_provider.dart`

The app auto-detects Firebase configuration and falls back to `MockAuthService` when `google-services.json` is absent. This is useful for development but dangerous in production: a build shipped without the config file will let users log in successfully (mock) and lose all data on reinstall.

**Action:** Before store submission, verify `FirebaseBootstrap.isAvailable` returns `true` in your release build. Add a runtime assertion or build-time check so a misconfigured production build fails loudly rather than silently degrading to mock auth.

---

### 14. `myAppointmentsMock` used as live fallback in the router
**File:** `lib/core/router/app_router.dart` — `appointmentDetail` route

The appointment detail route falls back to `myAppointmentsMock.first` when no matching appointment ID is found, instead of showing a proper error state.

**Fix:** Replace the mock fallback with a `RouteErrorScreen` push or a null-safe check that shows an empty/error state. Mock data wired into the live router will surface to real users.

---

### 15. Null-aware spread `[?analyticsObserver]` requires Dart 3.7+
**File:** `lib/core/router/app_router.dart`

The `observers: [?analyticsObserver]` syntax (null-aware spread) is a Dart 3.7+ feature. Your `pubspec.yaml` has `sdk: ^3.7.0` which is correct, but if anyone runs this on an older stable SDK channel they'll get a parse error. Verify your CI and all developer machines are on Dart 3.7+.

---

## Summary Table

| # | Severity | File / Area | Issue | Fix effort |
|---|----------|-------------|-------|------------|
| 1 | 🔴 Bug | `app_router.dart:278` | `/shelf` route opens ShopScreen | Quick rename/swap |
| 2 | 🔴 Bug | `settings_screen.dart:189` | Async context use without mounted check | Add guard |
| 3 | 🔴 Bug | `app_router.dart:21` | `_shellNavigatorKey` unused | Delete |
| 4 | 🟡 Dead UI | `home_screen.dart` | Recommendation cards not tappable | Add GestureDetector |
| 5 | 🟡 Dead UI | `home_screen.dart` | Routine step cards not tappable | Add GestureDetector |
| 6 | 🟠 Data | `home_screen.dart` | Today's routine hardcoded, ignores provider | Read from routineProvider |
| 7 | 🟠 Data | `home_screen.dart` | Health score metrics hardcoded | Compute or label as demo |
| 8 | 🔵 Warning | 6 files | Unused `key` parameters | Remove parameters |
| 9 | 🔵 Warning | `chat_screen.dart:5` | Unused import | Delete import |
| 10 | 🔵 Warning | `auth_provider.dart:13` | Unused `photoURL` parameter | Remove or wire up |
| 11 | 🔵 Warning | Every screen | 80+ `withValues(alpha:)` deprecated calls | Global find-and-replace |
| 12 | 🔵 Lint | Router + screens | Unnecessary double underscores | Global replace `(_, _)` → `(_)` |
| 13 | 🔵 Arch | `auth_provider.dart` | Mock auth silently used if Firebase missing | Assert in release build |
| 14 | 🔵 Arch | `app_router.dart` | `myAppointmentsMock` in live router fallback | Replace with error route |
| 15 | 🔵 Arch | `app_router.dart` | Null-aware spread requires Dart 3.7+ | Verify SDK across team |

---

*Generated from static analysis of `dermiq-main` — June 12, 2026*
