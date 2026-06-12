# DermIQ Phase 2 Add-On - Routine, Shelf, Calendar & Streak System

## Objective
Transform the Routine screen into the user's daily skincare and haircare hub.

## Routine Screen Structure

- Today's Progress
- Health Score
- Current Streak
- Reward Progress
- Calendar
- My Shelf
- AM Routine
- PM Routine

## My Shelf Inside Routine

Display:
- Product Image
- Product Name
- Product Type
- Expiry Date
- Days Remaining

Sources:
1. Manually added products
2. Products delivered from DermIQ Shop

Flow:
Order Delivered → Auto Add Product To Shelf

Actions:
- View Product
- Edit Product
- Mark As Empty
- Remove Product

Button:
View Full Shelf → Shelf Screen

## Calendar System

Green Day:
AM Complete + PM Complete

Yellow Day:
AM Complete + PM Skipped
OR
AM Skipped + PM Complete

Red Day:
AM Skipped + PM Skipped

Colors:
Green / Yellow / Red

## Streak System

Green:
Streak Continues

Yellow:
Streak Continues
Does NOT count toward rewards

Red:
Streak Breaks
Reset to Day 1

## Reward Progress

Only Green Days count.

Milestones:
50
100
150
200
250
300
365

Choose 1 reward from 2–4 options.

## Claimed Rewards

Profile → Gifts

Display:
- Reward Name
- Claim Date
- Expiry Date
- Status

## Health Score

Increase via:
- AM completion
- PM completion
- Consistency
- Weekly adherence

Persist locally and in Firestore.

## Data Storage

Store:
- Routine Completion
- Calendar History
- Streak Data
- Reward Progress
- Reward Claims
- Shelf Data
- Health Score

## Final Validation

- Shelf auto-populates from delivered orders
- Calendar updates correctly
- Green counts toward rewards
- Yellow keeps streak
- Red resets streak
- Rewards appear in Profile → Gifts

Maintain existing DermIQ UI exactly.
