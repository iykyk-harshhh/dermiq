/// DermIQ design tokens — layout, radius, sizing.
class AppConstants {
  // ── Identity ───────────────────────────────────────────────────────────────
  static const appName = 'DermIQ';
  static const tagline = 'Smart Skincare, Just For You';
  static const brandStar = '✦';  // U+2736 — used above the "i" in dermiq

  // ── Spacing ────────────────────────────────────────────────────────────────
  static const double sp4  = 4;
  static const double sp8  = 8;
  static const double sp12 = 12;
  static const double sp16 = 16;
  static const double sp20 = 20;
  static const double sp24 = 24;
  static const double sp32 = 32;
  static const double sp40 = 40;
  static const double sp48 = 48;

  // ── Border Radius ──────────────────────────────────────────────────────────
  static const double radiusXS     = 8;
  static const double radiusSmall  = 12;
  static const double radiusMedium = 16;
  static const double radiusCard   = 24;
  static const double radiusButton = 28;
  static const double radiusInput  = 20;
  static const double radiusLarge  = 32;

  // ── Component Sizes ────────────────────────────────────────────────────────
  static const double buttonHeight      = 56;
  static const double buttonHeightSmall = 44;
  static const double inputHeight       = 56;
  static const double iconButtonSize    = 44;
  static const double bottomNavHeight   = 64;
  static const double appBarHeight      = 56;

  // ── Screen Padding ─────────────────────────────────────────────────────────
  static const double screenPaddingH = 24;
  static const double screenPaddingV = 16;

  // ── Firestore Collections ──────────────────────────────────────────────────
  static const String usersCollection    = 'users';
  static const String routinesCollection = 'routines';
  static const String productsCollection = 'products';
  static const String analysisCollection = 'analysis';
  static const String checkInsCollection = 'checkIns';
}
