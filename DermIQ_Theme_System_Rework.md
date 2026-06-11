# DERMIQ THEME SYSTEM REWORK

## Remove Accent System

Delete:

- Accent Picker
- Accent Selection
- Accent Preview
- Accent Reset
- Accent Storage
- Accent Database Fields

Use Theme Selection Only.

---

## Theme Behaviour

When user changes theme:

- Text colors update automatically.
- Icon colors update automatically.
- Button colors update automatically.
- Card colors update automatically.
- Navigation colors update automatically.

Theme changes should apply instantly.

Persist selection after restart.

Store selected theme in Firebase and local storage.

---

## Text Updates

Apply theme colors to:

- Headers
- Sub Headers
- Body Text
- Card Text
- Buttons
- Profile
- Shop
- Routine
- Analysis
- Settings
- Notifications

---

## Icon Updates

Apply theme colors to:

- Home
- Routine
- Analyze
- Shop
- Profile
- Notification
- Cart
- Filter
- Search
- Settings
- Calendar

---

## Bottom Navigation

Home
Routine
Analyze
Shop
Profile

Active State:
Theme Primary Color

Inactive State:
Theme Secondary Color

---

## Button System

Theme-controlled buttons:

- Primary Buttons
- Secondary Buttons
- Outline Buttons
- CTA Buttons

---

## Card System

Theme-controlled cards:

- Home Cards
- Product Cards
- Routine Cards
- Analysis Cards
- Appointment Cards
- Profile Cards
- Reward Cards

---

## Fixed Health Colors

Never change:

Safe = Green

Caution = Yellow

Danger = Red

These remain constant across all themes.

---

## Settings Screen

Keep:

- Theme Selection
- Theme Preview
- Apply Theme

Remove:

- Accent Settings
- Accent Preview
- Accent Reset

---

## Animations

Theme transitions:

- Fade
- Scale
- Color Transition

No page reloads.

---

## State Management

Create ThemeProvider.

Responsibilities:

- Store selected theme
- Apply globally
- Persist selection
- Instant updates

---

## Firebase

users/
 userId/
   settings/
      selectedTheme

Only store selected theme.

---

## Final Requirement

No Accent System.

Theme Selection Only.

All icons, text, cards and buttons must adapt automatically to the selected theme.

Keep existing DermIQ UI unchanged.
