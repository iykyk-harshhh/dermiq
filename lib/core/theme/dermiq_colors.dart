import 'package:flutter/material.dart';
import 'app_colors.dart';

/// DermIQ theme extension — context-aware color tokens that adapt between
/// light and dark themes. Registered in both [AppTheme.light] and
/// [AppTheme.dark] via `ThemeData.extensions`.
///
/// Access via [BuildContext.dColors]:
///   final bg = context.dColors.background;
class DermIQColors extends ThemeExtension<DermIQColors> {
  final Color background;
  final Color surface;
  final Color surfaceDim;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color borderLight;
  final Color borderMedium;
  final Color divider;
  final Color navBackground;
  final List<BoxShadow> cardShadow;
  final List<BoxShadow> bottomNavShadow;

  const DermIQColors({
    required this.background,
    required this.surface,
    required this.surfaceDim,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.borderLight,
    required this.borderMedium,
    required this.divider,
    required this.navBackground,
    required this.cardShadow,
    required this.bottomNavShadow,
  });

  // ── Light theme — mirrors AppColors static consts exactly ─────────────────

  static final light = DermIQColors(
    background:    const Color(0xFFF8F6FF),
    surface:       const Color(0xFFFFFFFF),
    surfaceDim:    const Color(0xFFF0EDFF),
    textPrimary:   const Color(0xFF1E1B4B),
    textSecondary: const Color(0xFF6B7280),
    textTertiary:  const Color(0xFF9CA3AF),
    borderLight:   const Color(0x1A7C5CFF),
    borderMedium:  const Color(0x337C5CFF),
    divider:       const Color(0xFFEDE9FE),
    navBackground: const Color(0xFFFFFFFF),
    cardShadow: AppColors.cardShadow,
    bottomNavShadow: AppColors.bottomNavShadow,
  );

  // ── Dark theme ─────────────────────────────────────────────────────────────

  static final dark = DermIQColors(
    background:    const Color(0xFF0F0D1A),
    surface:       const Color(0xFF1A1730),
    surfaceDim:    const Color(0xFF261F3D),
    textPrimary:   const Color(0xFFF1EEFA),
    textSecondary: const Color(0xFFB0A8D0),
    textTertiary:  const Color(0xFF6B6285),
    borderLight:   const Color(0x1A7C5CFF),
    borderMedium:  const Color(0x337C5CFF),
    divider:       const Color(0xFF2A2245),
    navBackground: const Color(0xFF1A1730),
    cardShadow: [
      BoxShadow(
        color: AppColors.primary.withValues(alpha: 0.12),
        blurRadius: 24,
        offset: const Offset(0, 6),
      ),
      BoxShadow(
        color: AppColors.primary.withValues(alpha: 0.06),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
    bottomNavShadow: [
      BoxShadow(
        color: AppColors.primary.withValues(alpha: 0.16),
        blurRadius: 20,
        offset: const Offset(0, -4),
      ),
    ],
  );

  // ── Fixed semantic colors — NEVER change across themes (spec requirement) ─

  static const success = AppColors.success; // #22C55E
  static const warning = AppColors.warning; // #F59E0B
  static const error   = AppColors.error;   // #EF4444

  // ── ThemeExtension interface ───────────────────────────────────────────────

  @override
  DermIQColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceDim,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? borderLight,
    Color? borderMedium,
    Color? divider,
    Color? navBackground,
    List<BoxShadow>? cardShadow,
    List<BoxShadow>? bottomNavShadow,
  }) =>
      DermIQColors(
        background:      background      ?? this.background,
        surface:         surface         ?? this.surface,
        surfaceDim:      surfaceDim      ?? this.surfaceDim,
        textPrimary:     textPrimary     ?? this.textPrimary,
        textSecondary:   textSecondary   ?? this.textSecondary,
        textTertiary:    textTertiary    ?? this.textTertiary,
        borderLight:     borderLight     ?? this.borderLight,
        borderMedium:    borderMedium    ?? this.borderMedium,
        divider:         divider         ?? this.divider,
        navBackground:   navBackground   ?? this.navBackground,
        cardShadow:      cardShadow      ?? this.cardShadow,
        bottomNavShadow: bottomNavShadow ?? this.bottomNavShadow,
      );

  @override
  DermIQColors lerp(DermIQColors? other, double t) {
    if (other == null) return this;
    return DermIQColors(
      background:      Color.lerp(background,      other.background,      t)!,
      surface:         Color.lerp(surface,         other.surface,         t)!,
      surfaceDim:      Color.lerp(surfaceDim,      other.surfaceDim,      t)!,
      textPrimary:     Color.lerp(textPrimary,     other.textPrimary,     t)!,
      textSecondary:   Color.lerp(textSecondary,   other.textSecondary,   t)!,
      textTertiary:    Color.lerp(textTertiary,    other.textTertiary,    t)!,
      borderLight:     Color.lerp(borderLight,     other.borderLight,     t)!,
      borderMedium:    Color.lerp(borderMedium,    other.borderMedium,    t)!,
      divider:         Color.lerp(divider,         other.divider,         t)!,
      navBackground:   Color.lerp(navBackground,   other.navBackground,   t)!,
      cardShadow:      t < 0.5 ? cardShadow : other.cardShadow,
      bottomNavShadow: t < 0.5 ? bottomNavShadow : other.bottomNavShadow,
    );
  }
}

/// Convenience accessor — avoids `Theme.of(context).extension<DermIQColors>()`.
extension DermIQColorsX on BuildContext {
  DermIQColors get dColors =>
      Theme.of(this).extension<DermIQColors>() ?? DermIQColors.light;
}
