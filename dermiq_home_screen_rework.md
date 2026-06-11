# DermIQ Home Screen & Health Score Rework

## Important
Do NOT redesign the UI.

Maintain the existing DermIQ visual design system:
- Light lavender background
- White glassmorphism cards
- Purple gradients
- Soft shadows
- Premium spacing
- Motion animations
- Existing typography

Only apply the following logic and feature updates.

## Home Greeting System
Display dynamic greeting based on local device time:
- Good Morning
- Good Afternoon
- Good Evening
- Good Night

Use logged-in user's name from Firebase/Auth profile.

## DermIQ Health Score
Remove separate Skin and Hair scores.
Use a single unified DermIQ Health Score.

- Start: 0
- Min: 0
- Max: 100

Routine completion:
- Morning step: +2
- Night step: +2
- Max daily gain: +10
- Missed day: -1

Levels:
- 0–20 Needs Attention
- 21–40 Getting Started
- 41–60 Improving
- 61–80 Healthy
- 81–100 Excellent

## Appointment Section
Place below DermIQ Health Score card.

Button:
Book Appointment

Categories:
- Dermatologist
- Trichologist

Doctor listing should include:
- Name
- Hospital
- Address
- Rating
- Reviews
- Fee
- Distance
- Available slots

Filters:
- Nearest
- Highest Rated
- Lowest Fee
- Available Today
- Online
- In-Person

Booking Flow:
Category → Doctor → Date → Time → Confirmation

Keep all existing DermIQ UI intact.
Do not modify Splash Screen.
