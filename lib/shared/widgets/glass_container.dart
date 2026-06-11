import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Glassmorphism container — white frosted glass over dark backgrounds.
/// For light-background uses, prefer [AppCard].
class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final double borderRadius;
  final double opacity;
  final Color? borderColor;
  final List<BoxShadow>? shadows;

  const GlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.width,
    this.height,
    this.borderRadius = 24,
    this.opacity = 0.12,
    this.borderColor,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor ?? Colors.white.withValues(alpha: opacity * 2.5),
          width: 1,
        ),
        boxShadow: shadows ?? [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Pill-shaped glass badge — for labels on dark backgrounds.
class GlassBadge extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const GlassBadge({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: child,
    );
  }
}
