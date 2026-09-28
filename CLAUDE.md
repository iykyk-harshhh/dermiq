# DermIQ

## Stack
- Flutter (Dart) — feature-first folder structure under `lib/features/`
- Riverpod — `StateProvider`, `StateNotifierProvider`, `AsyncNotifier`
- GoRouter — `StatefulShellRoute` for bottom nav, top-level routes for modals/detail screens
- Firebase — Auth, Firestore, Storage, FCM, Analytics, Crashlytics (wired in `core/firebase/` with graceful mock fallback until `flutterfire configure`)
- Google Fonts — **Playfair Display** for display/headings + **Poppins** for body/UI, defined in `AppTypography`; `AppTheme` applies `GoogleFonts.poppinsTextTheme()` as the base
- fl_chart — Line, Radar charts in Analysis and Progress screens

## Design System
- Colors: `AppColors` in `lib/core/theme/app_colors.dart` (+ theme-aware `dermiq_colors.dart` via `context.dColors`)
- Text: `AppTypography` (getters, not const) in `lib/core/theme/app_typography.dart` — headings Playfair, body Poppins. (`app_text_styles.dart` is a legacy re-export shim; prefer `AppTypography`.)
- Theme: `AppTheme.light` applied in `main.dart`
- Spacing constants: `AppConstants.sp4` … `AppConstants.sp48`
- Border radius: cards=24, buttons=28, inputs=20
- Shadows: soft only — `AppColors.primary.withValues(0.06)` pattern
- Gradients: `AppColors.gradientPrimary`, `gradientSurface`, `gradientHero`

## Splash Screen (video motion-graphic)
The routed splash (`/splash` → `features/auth/presentation/screens/splash_screen.dart`)
plays a pre-rendered motion graphic via `video_player` (`VideoPlayerController.asset('assets/videos/splash.mp4')`). `FlutterNativeSplash.preserve` holds the OS launch screen until the video is decoded (with a safety timeout) so there's no static-frame flash. Every flow funnels through one **Get Started** CTA (shown to all users); tapping it routes via the SplashController — see Auth & Startup Flow.
- The earlier hand-built `CustomPainter` particle version was replaced by the video. Its widgets still live in `features/auth/presentation/widgets/` (`particle_face_painter.dart`, `floating_spheres.dart`, `animated_mesh.dart`, `glowing_button.dart`) but are **no longer wired into the splash** — treat them as legacy/unused unless re-adopted.
- Editing the splash? It's now a video asset — replace `assets/videos/splash.mp4` (keep the same path) rather than editing painter code.

## Rules
- No placeholder code — every screen is real and navigable
- No direct `Card` or `Material` widgets in feature code — use `AppCard` or `GlassCard`
- No `withValues` on new code — use `.withValues(alpha:)` instead
- Firebase IS configured (`google-services.json` + `firebase_options.dart` present) — real Auth/Firestore/Storage/FCM are live, with graceful mock fallback when unavailable. (The old "no Firebase until committed" rule is superseded.)
- Text styles come from `AppTypography`, not inline `TextStyle(fontFamily: ...)`
- All async navigation after `await` must guard with `if (context.mounted)`
- Riverpod: read providers with `ref.watch` in build, `ref.read` in callbacks
- Routes: named constants not hardcoded strings — add to `AppConstants` if reused

## Folder Layout
```
lib/
  core/
    constants/    app_constants.dart
    router/       app_router.dart
    theme/        app_colors.dart  app_text_styles.dart  app_theme.dart
  features/
    auth/         providers/  presentation/screens/  presentation/widgets/
    onboarding/   providers/  presentation/screens/
    home/         providers/  presentation/screens/  presentation/widgets/
    scan/         presentation/screens/
    analysis/     presentation/screens/
    routine/      presentation/screens/
    shelf/        presentation/screens/
    profile/      presentation/screens/
    settings/     presentation/screens/
    chat/         presentation/screens/  presentation/widgets/
    ingredients/  presentation/screens/  presentation/widgets/
    calendar/     (to build)
    progress/     (to build)
  shared/
    models/       user_model  routine_model  product_model  analysis_model
    widgets/      app_button.dart  app_card.dart
  main.dart
```

## Auth & Startup Flow
- `authStateProvider` → `StateProvider<AppUser?>` (mirrors FirebaseAuth when configured; `MockUser` is a typedef of `AppUser`).
- `authProvider` → `AuthService` (Firebase impl when available, else mock): email, Google, anonymous, `signOut`, **`deleteAccount`**.
- First-launch flags persisted via `PreferencesService` (SharedPreferences) → `onboardingSeenProvider` / `profileCompleteProvider` (`profileComplete` == "quizzes done", set at the end of the hair quiz / on skin-quiz skip; survives logout, cleared only on delete).
- The startup **guard** (`resolveStartupRedirect()` in `app_router.dart`, pure + unit-tested) gates on only two things — onboarding + auth:
  - onboarding not seen → Onboarding · seen + logged-out → Login · seen + logged-in → Home (auth screens redirect to Home when signed in).
  - Quizzes are **not** a startup gate — they're reached imperatively after sign-up/first Google login and shown once (guarded by `profileComplete`).
- Splash acts as a SplashController: it **always** shows the Get Started CTA; tapping it checks state — signed in → Home · onboarding not seen → Onboarding · else → Login. (No Welcome screen — single Get Started entry; `welcome_screen.dart` removed.)
- Firebase is initialized in `main.dart` via `FirebaseBootstrap.init()` (safe no-op until `firebase_options.dart`/`google-services.json` exist → mock mode). Login persistence rides on `FirebaseAuth.currentUser` once configured.
- Flows:
  - First-time: Splash → Get Started → Onboarding (once) → Login/Sign Up → Skin Quiz → Hair Quiz → Home. Email **Sign In** (returning) → Home; **Create Account** → quizzes. Google: new → quizzes, existing → Home.
  - Returning logged-in → Splash → Get Started → Home. Logged-out → Splash → Get Started → Login.
  - Login is the auth root (**no back button**).
- Settings → Logout → `/login` (auth session only; keeps onboarding + quiz flags). Privacy → Delete Account wipes Firestore + Firebase user + all local flags, then restarts at `/splash` (→ Onboarding → … → quizzes again).
- `/profile-setup` (legacy) collects **Full Name → Gender → Email → Age → Skin Type → Hair Type**; gender persists to `users/{uid}`. Not in the active flow (sign-up collects name+gender inline).

## Current Mock Data Locations
- Skin score, concerns: `home/presentation/widgets/`
- Routine steps: `routine/presentation/screens/routine_screen.dart`
- Products: `features/catalog/data/catalog_seed.dart` (seeds `ProductRepository`; `ShelfProduct` is now a typedef of catalog `Product`)
- Analysis metrics: `analysis/presentation/screens/analysis_results_screen.dart`
- Chat responses: `chat/presentation/screens/chat_screen.dart` → `_getAIResponse()`
