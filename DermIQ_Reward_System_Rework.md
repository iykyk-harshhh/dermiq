# DERMIQ STREAK REWARD SYSTEM REWORK

IMPORTANT:

- Do NOT redesign the UI.
- Do NOT change colors.
- Do NOT change typography.
- Do NOT change navigation.
- Keep every existing DermIQ screen exactly as it is.
- Only implement the reward system below.

## STREAK SYSTEM

FULL DAY:
- User completes both AM Routine and PM Routine.

PARTIAL DAY:
- User completes only AM or only PM.

MISSED DAY:
- User completes neither.

Rules:
- Full Day → streak continues.
- Partial Day → streak continues.
- Missed Day → streak breaks.
- After a missed day, streak resets to Day 1.

## ROUTINE SCREEN CHANGES

Add:
- Current Streak Card
- Next Reward Card
- Animated Progress Bar

Example:
43 Days
43 / 50 Progress

## REWARD MILESTONES

7 Days
30 Days
50 Days
100 Days
150 Days
200 Days
365 Days

User chooses ONE reward at each milestone.

## PROFILE PAGE

Add:
🎁 Gifts

Store:
- Reward Name
- Reward Type
- Claimed Date
- Expiry Date
- Status

Statuses:
- ACTIVE
- REDEEMED
- EXPIRED

## CALENDAR

Green = Full Day
Yellow = Partial Day
Red = Missed Day

Persist data.

## FIREBASE MODEL

users/
  userId/
    streakData/
    rewards/

## NOTIFICATIONS

- Reward Unlocked
- Reward Expiring
- Reward Expired
- Streak Broken

Maintain current DermIQ UI.
