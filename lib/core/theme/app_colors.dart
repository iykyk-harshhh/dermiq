import 'package:flutter/material.dart';

/// DermIQ colour tokens — single source of truth.
/// All values derived from the brand spec.
class AppColors {
  // ── Brand ──────────────────────────────────────────────────────────────────
  static const primary     = Color(0xFF7C5CFF);
  static const primaryDark = Color(0xFF5E3FFF);
  static const lavender    = Color(0xFFA78BFA);

  // ── Surfaces ───────────────────────────────────────────────────────────────
  static const background  = Color(0xFFF8F6FF);
  static const surface     = Color(0xFFFFFFFF);
  static const surfaceDim  = Color(0xFFF0EDFF);
  static const glass       = Color(0x1AFFFFFF);  // 10 % white — glassmorphism

  // ── Text ───────────────────────────────────────────────────────────────────
  static const textPrimary   = Color(0xFF1E1B4B);
  static const textSecondary = Color(0xFF6B7280);
  static const textTertiary  = Color(0xFF9CA3AF);
  static const textOnDark    = Color(0xFFFFFFFF);
  static const textOnDarkSub = Color(0xB3FFFFFF);  // 70 %

  // ── Semantic ───────────────────────────────────────────────────────────────
  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
  static const error   = Color(0xFFEF4444);
  static const info    = Color(0xFF0EA5E9);

  // ── Border / Divider ───────────────────────────────────────────────────────
  static const borderLight  = Color(0x1A7C5CFF);  // 10 % primary
  static const borderMedium = Color(0x337C5CFF);  // 20 % primary
  static const divider      = Color(0xFFEDE9FE);

  // ── Gradients ──────────────────────────────────────────────────────────────

  static const gradientPrimary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7C5CFF), Color(0xFFA78BFA)],
  );

  static const gradientPrimaryVertical = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF7C5CFF), Color(0xFF5E3FFF)],
  );

  static const gradientSurface = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF8F6FF), Color(0xFFEDE9FE)],
  );

  static const gradientHero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.5, 1.0],
    colors: [Color(0xFF0D0B2A), Color(0xFF3B1F8C), Color(0xFF7C5CFF)],
  );

  /// Dark indigo → violet hero used across hero cards & sliver headers.
  static const gradientHeroDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.5, 1.0],
    colors: [Color(0xFF1E1B4B), Color(0xFF3B2D9F), Color(0xFF5E3FFF)],
  );

  static const gradientCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFF5F3FF)],
  );

  static const gradientScorePurple = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7C5CFF), Color(0xFF5E3FFF)],
  );

  static const gradientGlass = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x26FFFFFF), Color(0x0DFFFFFF)],
  );

  // ── Shadows ────────────────────────────────────────────────────────────────
  // Allocated once (not per build) — these are read in almost every widget.
  static final List<BoxShadow> cardShadow = [
    BoxShadow(
      color: primary.withValues(alpha: 0.06),
      blurRadius: 24,
      offset: const Offset(0, 6),
    ),
    BoxShadow(
      color: primary.withValues(alpha: 0.03),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static final List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: primary.withValues(alpha: 0.16),
      blurRadius: 32,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: primary.withValues(alpha: 0.08),
      blurRadius: 12,
      offset: const Offset(0, 3),
    ),
  ];

  static final List<BoxShadow> heroShadow = [
    BoxShadow(
      color: primary.withValues(alpha: 0.32),
      blurRadius: 48,
      spreadRadius: 8,
      offset: const Offset(0, 12),
    ),
  ];

  static final List<BoxShadow> bottomNavShadow = [
    BoxShadow(
      color: primary.withValues(alpha: 0.08),
      blurRadius: 20,
      offset: const Offset(0, -4),
    ),
  ];
}
