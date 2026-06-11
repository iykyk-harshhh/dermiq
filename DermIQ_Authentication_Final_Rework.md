# DermIQ Authentication System Final Rework

## Important
- Do NOT redesign any existing screen.
- Do NOT modify themes.
- Do NOT modify navigation.
- Do NOT modify animations.
- Maintain current premium UI.
- Only update authentication flow.

## Remove Completely
- Setup Profile Screen
- Skin Profile Setup Screen
- Hair Profile Setup Screen
- Skin Quiz
- Hair Quiz
- Profile Completion Screen

## App Flow

### First Time User
Splash → Onboarding 1 → Onboarding 2 → Onboarding 3 → Sign In

### Returning User
Splash → Home Dashboard

Skip:
- Onboarding
- Sign In
- Create Account

## Sign In Screen

Fields:
- Email Address
- Password

Buttons:
- Sign In
- Continue With Google
- Create Account

Links:
- Forgot Password

## Forgot Password Flow
Forgot Password → Email Entry → Verification Code → Reset Password → Success

## Create Account Screen

Fields:
- Full Name
- Gender
- Email Address
- Password
- Confirm Password

Gender Options:
- Male
- Female
- Other

Buttons:
- Create Account
- Continue With Google

## Google Authentication

Google Account Selection
→ Firebase Authentication
→ Create User Record
→ Home Dashboard

## User Session Management

If session exists:
- Open Home Dashboard directly.
- Skip authentication flow.

## Logout Flow

Profile
→ Settings
→ Logout
→ Sign In

## Firebase Authentication

Support:
- Email & Password Login
- Google Sign In
- Password Reset
- Email Verification
- Persistent Login Sessions

## User Database

users/
  userId/
  - fullName
  - gender
  - email
  - profileImage
  - createdAt
  - lastLogin

## Animations

Use existing DermIQ motion system:
- Fade
- Slide
- Scale

Keep premium feel.

## Final Requirement

Authentication Flow:

Splash
→ Onboarding
→ Sign In
→ Home Dashboard

Returning User:

Splash
→ Home Dashboard

Keep all existing DermIQ screens and UI unchanged.
Only implement authentication flow improvements.
