import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// DermIQ typography.
///
/// Headings  → Playfair Display (editorial, luxury)
/// Body/UI   → Poppins (clean, modern)
///
/// All styles are static getters so Google Fonts constructs them lazily.
class AppTypography {
  // ── Playfair Display — Display / Headings ─────────────────────────────────

  static TextStyle get display => GoogleFonts.playfairDisplay(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.15,
        letterSpacing: -0.5,
      );

  static TextStyle get h1 => GoogleFonts.playfairDisplay(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.2,
        letterSpacing: -0.3,
      );

  static TextStyle get h2 => GoogleFonts.playfairDisplay(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.25,
        letterSpacing: -0.2,
      );

  static TextStyle get h3 => GoogleFonts.playfairDisplay(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.3,
      );

  static TextStyle get h4 => GoogleFonts.playfairDisplay(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.3,
      );

  // ── Poppins — Body / UI ───────────────────────────────────────────────────

  static TextStyle get bodyLarge => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.6,
      );

  static TextStyle get bodyMedium => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.57,
      );

  static TextStyle get bodySmall => GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.5,
      );

  static TextStyle get labelLarge => GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: 0.1,
      );

  static TextStyle get labelMedium => GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
        letterSpacing: 0.1,
      );

  static TextStyle get labelSmall => GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        letterSpacing: 0.3,
      );

  static TextStyle get caption => GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.4,
      );

  static TextStyle get overline => GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        letterSpacing: 1.4,
      );

  static TextStyle get button => GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
        height: 1.0,
      );

  static TextStyle get buttonSmall => GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      );

  // ── Brand ─────────────────────────────────────────────────────────────────

  /// The "dermiq" wordmark in Playfair Display.
  static TextStyle get logoLarge => GoogleFonts.playfairDisplay(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
        letterSpacing: 2.0,
      );

  static TextStyle get logoMedium => GoogleFonts.playfairDisplay(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
        letterSpacing: 1.5,
      );

  static TextStyle get logoSmall => GoogleFonts.playfairDisplay(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
        letterSpacing: 1.0,
      );

  static TextStyle get logoOnDark => GoogleFonts.playfairDisplay(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: AppColors.textOnDark,
        letterSpacing: 2.0,
      );

  // ── Metric / Number ───────────────────────────────────────────────────────

  static TextStyle get metricLarge => GoogleFonts.poppins(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.0,
      );

  static TextStyle get metricMedium => GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.0,
      );

  static TextStyle get metricSmall => GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.1,
      );
}
