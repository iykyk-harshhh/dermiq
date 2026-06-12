# DermIQ Phase 1 - Authentication, Startup Flow & Firebase Rework

## Objective
Fix startup flow, authentication flow, onboarding flow, Get Started flow, Firebase initialization, and navigation logic without changing the UI.

## First Time User Flow

Splash Screen
→ Get Started
→ Onboarding 1
→ Onboarding 2
→ Onboarding 3
→ Login / Sign Up / Google
→ Skin Quiz
→ Hair Quiz
→ Home Dashboard

## Returning Logged-In User

Splash Screen
→ Get Started
→ Home Dashboard

Do not show:
- Onboarding
- Login
- Quizzes

## Signed-Out User

Splash Screen
→ Get Started
→ Login / Sign Up / Google

## Deleted Account

Splash Screen
→ Get Started
→ Onboarding
→ Login / Sign Up / Google
→ Skin Quiz
→ Hair Quiz
→ Home Dashboard

## Welcome Screen Rework

Remove conflicting Welcome Screen behavior.

Use a single Get Started entry flow.

## Get Started Logic

When Get Started is tapped:

Check FirebaseAuth.currentUser

If user exists:
→ Home Dashboard

If user does not exist:
→ Check onboarding status

If onboarding incomplete:
→ Onboarding

If onboarding complete:
→ Login / Sign Up / Google

## Firebase Initialization

Enable Firebase initialization.

Verify:
- Firebase Auth
- Firestore
- Google Sign-In
- FCM (if configured)

## Login Persistence

Use FirebaseAuth.currentUser.

Logged-in users must remain logged in after app restart.

## Google Sign-In

Existing User:
→ Home Dashboard

New User:
→ Skin Quiz
→ Hair Quiz
→ Home Dashboard

Store:
- uid
- name
- email
- profile image
- provider

## Quiz Rules

Show Skin Quiz only once.
Show Hair Quiz only once.

Store completion state.

## Logout Flow

Profile
→ Settings
→ Logout

Sign out Firebase.

Return to Login / Sign Up / Google.

## Delete Account Flow

Delete:
- Firebase User
- Firestore Data
- Routine Data
- Rewards Data
- Shelf Data
- Quiz Data
- Profile Data
- Local Storage

Restart onboarding journey.

## Protected Routes

Require authentication:

- Home
- Routine
- Scanner
- Analyze
- Shop
- Profile
- Appointments

Redirect unauthenticated users to Login.

## Required Services

- AuthService
- GoogleAuthService
- SessionManager
- OnboardingManager
- QuizManager
- SplashController
- AuthGuard

## Validation

Test:
- Fresh Install
- Email Login
- Google Login
- Logout
- Delete Account
- App Restart
- Session Persistence

Maintain the existing DermIQ UI exactly.
