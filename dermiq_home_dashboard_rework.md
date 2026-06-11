# DERMIQ HOME DASHBOARD REWORK (CRITICAL FIX)

## IMPORTANT
Do NOT redesign the UI.
Do NOT modify Splash Screen.
Do NOT change colors or typography.

## BOTTOM NAVIGATION

Use exactly 5 tabs:

1. Home
2. Routine
3. Analyze
4. Shop
5. Profile

Icons:

- HomeRounded
- AutoAwesomeRounded
- CameraAltRounded
- ShoppingBagRounded
- PersonRounded

Selected tab:
- Purple gradient
- Glow effect
- Scale animation

Unselected:
- Grey icon

Persistent navigation across app.

---

## STICKY HEADER

Header must remain fixed while content scrolls.

Layout:

[Profile Image]    DermIQ    [Notification]

Use:
- SliverAppBar
- pinned = true

Glassmorphism:
- Blur 20
- Opacity 90%

Notification icon:
- Unread badge
- Opens notifications

---

## HOME PAGE OVERFLOW FIXES

Fix all:

- RenderFlex overflow
- Yellow/black striped errors
- Unbounded height issues
- Nested scroll issues
- Expanded/Flexible misuse

Verify:
- No overflow warnings
- No render exceptions
- No debug errors

---

## HOME CONTENT ORDER

1. Greeting
2. DermIQ Health Score
3. Appointment Card
4. Today's Routine
5. Analyze
6. Shop
7. Insights
8. Recommendations

Content scrolls below sticky header.

---

## PERFORMANCE

Target:
- 60 FPS
- Smooth scrolling
- No rebuild loops

Use:
- const widgets
- Riverpod
- Cached images
- Lazy loading

---

## DELIVERABLE

Update:
- Home Dashboard
- Sticky Header
- Bottom Navigation
- Overflow Fixes
- Scroll System

Keep existing DermIQ design unchanged.
