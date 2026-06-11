
# DermIQ Authentication & User Flow Rework

## Objective
Implement a production-grade authentication, onboarding, Google Sign-In, sign-out, and account deletion flow.

## First-Time User Flow

Splash
→ Get Started
→ Onboarding 1
→ Onboarding 2
→ Onboarding 3
→ Login / Sign Up
→ Skin Quiz
→ Hair Quiz
→ Home Dashboard

## Login Options

- Email + Password
- Continue with Google
- Create Account
- Forgot Password

## Google Sign-In

New Google User:
- Create Firebase account
- Save profile data
- Navigate to Skin Quiz

Existing Google User:
- Login directly

Store:
- uid
- name
- email
- profile image
- provider

## Quiz Rules

- Skin Quiz shown once
- Hair Quiz shown once
- Save completion state
- Never show again unless account deleted

## Returning Logged-In User

Splash
→ Home Dashboard

Do NOT show:
- Get Started
- Onboarding
- Login
- Quizzes

## Signed-Out User

Profile
→ Settings
→ Sign Out

Then:

Splash
→ Login Screen

Use existing Welcome Back login screen.

## Delete Account

Profile
→ Settings
→ Delete Account

Delete:
- Firebase user
- Firestore data
- Quiz data
- Routine data
- Rewards data
- Shelf data
- Profile data
- Local storage

Then:

Splash
→ Get Started
→ Onboarding
→ Login
→ Skin Quiz
→ Hair Quiz
→ Home

## Startup Logic

Check:
- onboarding_completed
- FirebaseAuth.currentUser

If onboarding not completed:
→ Get Started → Onboarding

If onboarding completed and user not logged in:
→ Login

If onboarding completed and user logged in:
→ Home

## Required Services

- AuthService
- GoogleAuthService
- SessionManager
- OnboardingManager
- QuizManager
- SplashController
- AuthGuard

## Protected Pages

Require authentication:
- Home
- Routine
- Analyze
- Shop
- Profile

## Final Goal

New User:
Splash → Get Started → Onboarding → Login → Quizzes → Home

Returning User:
Splash → Home

Signed-Out User:
Splash → Login

Deleted Account:
Splash → Get Started → Onboarding → Login → Quizzes → Home

Maintain existing DermIQ UI exactly.
