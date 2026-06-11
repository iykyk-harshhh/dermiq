import 'package:flutter/animation.dart';

/// DermIQ motion tokens.
/// All durations and curves used across the app live here.
class AppAnimations {
  // ── Durations ─────────────────────────────────────────────────────────────

  /// Page transitions, hero reveals
  static const Duration page        = Duration(milliseconds: 350);
  /// Card entry, fade-in
  static const Duration medium      = Duration(milliseconds: 300);
  /// Micro interactions (button, toggle)
  static const Duration fast        = Duration(milliseconds: 200);
  /// Quick state changes
  static const Duration instant     = Duration(milliseconds: 150);

  /// Glow pulse cycle (full loop)
  static const Duration glowPulse   = Duration(seconds: 2);
  /// Floating sphere cycle
  static const Duration sphereFloat = Duration(seconds: 6);
  /// Mesh face breathing
  static const Duration meshBreath  = Duration(seconds: 4);
  /// Particle drift
  static const Duration particleDrift = Duration(seconds: 8);

  /// Splash total duration
  static const Duration splash      = Duration(milliseconds: 3200);

  // ── Curves ────────────────────────────────────────────────────────────────

  /// Primary curve — almost all page / card transitions
  static const Curve standard   = Curves.easeOutCubic;
  /// Entry (slide in)
  static const Curve enter      = Curves.easeOutQuart;
  /// Exit (slide out / fade out)
  static const Curve exit       = Curves.easeInCubic;
  /// Bouncy micro interactions
  static const Curve spring     = Curves.elasticOut;
  /// Smooth loops (breathing, floating)
  static const Curve breathe    = Curves.easeInOut;
  /// Snappy confirmation
  static const Curve snap       = Curves.easeOutBack;

  // ── Stagger offsets ───────────────────────────────────────────────────────
  /// Delay between items in a list entrance
  static const Duration staggerItem = Duration(milliseconds: 60);
}
