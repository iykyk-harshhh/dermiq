# DermIQ Forgot Password Flow

## Objective
Implement a complete Forgot Password workflow using Firebase Authentication without changing the existing DermIQ UI.

## User Flow

Login Screen
→ Forgot Password
→ Enter Email
→ Send Verification Code
→ Verify OTP
→ Create New Password
→ Confirm Password
→ Success Screen
→ Back to Login

## Forgot Password Screen

Fields:
- Email Address

Button:
- Send Verification Code

Validation:
- Email required
- Valid email format
- Must exist in Firebase Auth

## OTP Verification Screen

Fields:
- Email (read-only)
- OTP Code

Buttons:
- Verify OTP
- Resend Code

Rules:
- 60-second resend timer
- OTP expires after 5 minutes
- Maximum 5 attempts

## Create New Password Screen

Fields:
- New Password
- Confirm Password

Validation:
- Minimum 8 characters
- One uppercase letter
- One lowercase letter
- One number
- Passwords must match

Button:
- Set Password

## Success Screen

Title:
Password Updated Successfully

Button:
Back To Login

## Firebase Implementation

Preferred:
Firebase Authentication Password Reset

Alternative:
Custom OTP stored in Firestore

Store:
- email
- otp
- expiry_time

## Error Handling

Show:
- Email Not Found
- Invalid OTP
- OTP Expired
- Weak Password
- Passwords Do Not Match
- Network Error

## Navigation

Login
→ Forgot Password
→ Email
→ OTP Verification
→ New Password
→ Success
→ Login

## Final Goal

Users can securely reset passwords while maintaining the existing DermIQ design system and UI.
