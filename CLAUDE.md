# DermIQ

## Stack
- Flutter (Dart) — feature-first folder structure under `lib/features/`
- Riverpod — `StateProvider`, `StateNotifierProvider`, `AsyncNotifier`
- GoRouter — `StatefulShellRoute` for bottom nav, top-level routes for modals/detail screens
- Firebase — Auth, Firestore, Storage, FCM, Analytics, Crashlytics (wired in `core/firebase/` with graceful mock fallback until `flutterfire configure`)
- Google Fonts — Poppins (app UI) via `GoogleFonts.poppinsTextTheme()`; the splash uses **Inter** (tagline/body/button) + **Playfair Display** (logo) per its motion-graphics spec
- fl_chart — Line, Radar charts in Analysis and Progress screens

## Design System
- Colors: `AppColors` in `lib/core/theme/app_colors.dart`
- Text: `AppTextStyles` (getters, not const) in `lib/core/theme/app_text_styles.dart`
- Theme: `AppTheme.light` applied in `main.dart`
- Spacing constants: `AppConstants.sp4` … `AppConstants.sp48`
- Border radius: cards=24, buttons=28, inputs=20
- Shadows: soft only — `AppColors.primary.withValues(0.06)` pattern
- Gradients: `AppColors.gradientPrimary`, `gradientSurface`, `gradientHero`

## Splash Screen (motion-graphics build)
The routed splash (`/splash` → `features/auth/presentation/screens/splash_screen.dart`)
is a hand-built particle-motion screen — no Lottie/Rive, all `CustomPainter` +
`AnimationController`. First run ends with a **Get Started** CTA → `/onboarding`; a returning user auto-advances past it (→ Home/Login) — see the SplashController note in Auth & Startup Flow.
- Background `#F5F1FF`; logo ink `#2F216F` (dark purple, painted via `ShaderMask` gradient → primary); primary/sparkle/subtitle `#6C4BFF`; divider `#B084FF`. Tagline sits in a frosted-glass `BackdropFilter` card.
- Components in `features/auth/presentation/widgets/`:
  - `particle_face_painter.dart` — right-facing AI face from ~900 particles + flowing hair (generated once, animated per-frame).
  - `floating_spheres.dart` — 3 gradient spheres, 6s float loop.
  - `animated_mesh.dart` — bottom-25% purple wave-glow mesh.
  - `glowing_button.dart` — pill CTA, breathing scale 1.0→1.03 (2.5s), pulsing glow.
- Editing the splash? Keep it visually identical to the spec; don't simplify the painter.

## Rules
- No placeholder code — every screen is real and navigable
- No direct `Card` or `Material` widgets in feature code — use `AppCard` or `GlassCard`
- No `withValues` on new code — use `.withValues(alpha:)` instead
- No Firebase calls until `google-services.json` is committed
- Text styles come from `AppTextStyles`, not inline `TextStyle(fontFamily: ...)`
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
- Splash acts as a SplashController: **first run** shows the Get Started CTA → Onboarding; a **returning** user auto-advances (logged-in → Home, logged-out → Login).
- Flows:
  - First-time: Splash → Get Started → Onboarding (once) → Login/Sign Up → Skin Quiz → Hair Quiz → Home. Email **Sign In** (returning) → Home; **Create Account** → quizzes. Google: new → quizzes, existing → Home.
  - Returning logged-in → Splash → Home. Logged-out → Splash → Login.
  - Login is the auth root (**no back button**).
- Settings → Logout → `/login` (auth session only; keeps onboarding + quiz flags). Privacy → Delete Account wipes Firestore + Firebase user + all local flags, then restarts at `/splash` (→ Onboarding → … → quizzes again).
- `/profile-setup` (legacy) collects **Full Name → Gender → Email → Age → Skin Type → Hair Type**; gender persists to `users/{uid}`. Not in the active flow (sign-up collects name+gender inline).

## Current Mock Data Locations
- Skin score, concerns: `home/presentation/widgets/`
- Routine steps: `routine/presentation/screens/routine_screen.dart`
- Products: `features/catalog/data/catalog_seed.dart` (seeds `ProductRepository`; `ShelfProduct` is now a typedef of catalog `Product`)
- Analysis metrics: `analysis/presentation/screens/analysis_results_screen.dart`
- Chat responses: `chat/presentation/screens/chat_screen.dart` → `_getAIResponse()`
