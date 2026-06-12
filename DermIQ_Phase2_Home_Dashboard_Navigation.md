# DermIQ Phase 2 - Home Dashboard, Navigation & Interactive Elements

## Objective
Make the Home Dashboard fully functional and eliminate all dead interactions without changing the UI design.

## Dynamic Greeting

Display:

Good Morning, {User Name}

Rules:

05:00–11:59 → Good Morning

12:00–16:59 → Good Afternoon

17:00–20:59 → Good Evening

21:00–04:59 → Good Night

Load username from profile data.

## Sticky Header

Keep visible while scrolling:

- Profile Image
- DermIQ Logo/App Name
- Notification Icon
- Cart Icon

Use pinned header behavior.

## Health Score

Use one combined Health Score.

Starting value:
0

Increase score based on:

- AM Routine completion
- PM Routine completion
- Weekly consistency
- Routine adherence

Persist score locally and in Firestore.

## Profile Cards

Skin Profile Card
→ Edit Skin Profile

Hair Profile Card
→ Edit Hair Profile

Allow editing and saving.

## Appointment Widget

Add:

Get Your Appointment

Options:

- Dermatologist
- Trichologist

Display:

- Doctor Name
- Hospital/Clinic
- Address
- Rating
- Reviews
- Available Slots

Actions:

- Book Appointment
- View Details
- Cancel Appointment
- Reschedule Appointment

## Notification Actions

Morning Routine
→ Routine Screen

Night Routine
→ Routine Screen

Product Expiry
→ Shelf Screen

Appointment Reminder
→ Appointment Details

Reward Notification
→ Rewards Screen

## Bottom Navigation

Verify:

- Home
- Routine
- Analyze
- Shop
- Profile

Requirements:

- Correct navigation
- Active state
- State persistence
- No broken routes

## Rewards Entry Point

Display:

- Current Streak
- Next Reward
- Reward Progress
- Reward Milestone

Open Rewards Screen.

Rewards Screen:

- Available Rewards
- Claimed Rewards
- Expiry Date
- Status

## Dead Interaction Audit

Fix:

- Dead buttons
- Dead cards
- Dead rows
- Dead icons
- Dead chips

Every tappable element must perform a meaningful action.

## Cart Icon

Open Cart Screen.

Show:

- Products
- Quantity
- Total Price
- Checkout

## Notification Icon

Open Notifications Screen.

Show:

- Routine Notifications
- Appointment Notifications
- Reward Notifications
- Shelf Notifications

## Validation

Ensure:

- No Flutter overflow
- No RenderFlex errors
- No yellow/black stripes
- No broken navigation

## Final Goal

Fully functional Home Dashboard.

Working navigation.

Working appointment entry point.

Working rewards entry point.

Working profile editing.

Working health score.

No dead interactions.

Maintain existing DermIQ UI exactly.
