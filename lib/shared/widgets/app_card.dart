import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/dermiq_colors.dart';

/// Standard surface card with soft shadow.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final double? borderRadius;
  final Color? color;
  final Gradient? gradient;
  final bool animate;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.borderRadius,
    this.color,
    this.gradient,
    this.animate = false,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius ?? 24);
    Widget card = Material(
      color: Colors.transparent,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        splashColor: AppColors.primary.withValues(alpha: 0.05),
        highlightColor: AppColors.primary.withValues(alpha: 0.03),
        child: Container(
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: gradient == null ? (color ?? context.dColors.surface) : null,
            gradient: gradient,
            borderRadius: radius,
            boxShadow: context.dColors.cardShadow,
          ),
          child: child,
        ),
      ),
    );

    if (animate) {
      card = card
          .animate()
          .fadeIn(duration: 250.ms, curve: Curves.easeOut)
          .slideY(begin: 0.05, duration: 300.ms, curve: Curves.easeOutCubic);
    }

    return card;
  }
}

/// Glassmorphism card — for use on dark or gradient backgrounds.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final double opacity;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.opacity = 0.12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(borderRadius ?? 24),
        border: Border.all(
          color: Colors.white.withValues(alpha: opacity * 2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Gradient hero card (score, main metric).
class HeroCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Gradient? gradient;

  const HeroCard({
    super.key,
    required this.child,
    this.padding,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: gradient ?? AppColors.gradientPrimary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.heroShadow,
      ),
      child: child,
    );
  }
}

/// Selectable option tile — used in quiz, settings.
class SelectCard extends StatelessWidget {
  final Widget child;
  final bool isSelected;
  final VoidCallback onTap;
  final EdgeInsetsGeometry? padding;

  const SelectCard({
    super.key,
    required this.child,
    required this.isSelected,
    required this.onTap,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.08)
              : context.dColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : context.dColors.borderLight,
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected ? AppColors.elevatedShadow : context.dColors.cardShadow,
        ),
        child: child,
      ),
    );
  }
}
