import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/dermiq_colors.dart';

/// Primary gradient CTA button.
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final Widget? icon;
  final double? width;
  final double height;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.width,
    this.height = 56,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;

    Widget child = isLoading
        ? SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: isOutlined ? AppColors.primary : Colors.white,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[icon!, const SizedBox(width: 10)],
              Text(label, style: AppTypography.button),
            ],
          );

    if (isOutlined) {
      return SizedBox(
        width: width ?? double.infinity,
        height: height,
        child: OutlinedButton(onPressed: enabled ? onPressed : null, child: child),
      ).animate().fadeIn(duration: 200.ms).scaleXY(begin: 0.96, curve: Curves.easeOut);
    }

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: _GradientButton(
        width: width,
        height: height,
        enabled: enabled,
        onPressed: onPressed,
        child: child,
      ),
    ).animate().fadeIn(duration: 200.ms);
  }
}

class _GradientButton extends StatefulWidget {
  final Widget child;
  final double? width;
  final double height;
  final bool enabled;
  final VoidCallback? onPressed;

  const _GradientButton({
    required this.child,
    required this.height,
    required this.enabled,
    this.width,
    this.onPressed,
  });

  @override
  State<_GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<_GradientButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _press, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.enabled ? (_) => _press.forward() : null,
      onTapUp: widget.enabled
          ? (_) {
              _press.reverse();
              widget.onPressed?.call();
            }
          : null,
      onTapCancel: () => _press.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) => Transform.scale(
          scale: _scale.value,
          child: child,
        ),
        child: Container(
          width: widget.width ?? double.infinity,
          height: widget.height,
          decoration: BoxDecoration(
            gradient: widget.enabled
                ? AppColors.gradientPrimary
                : const LinearGradient(
                    colors: [Color(0xFFCBC4F0), Color(0xFFD8D0F8)],
                  ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: widget.enabled ? AppColors.elevatedShadow : [],
          ),
          child: Center(child: widget.child),
        ),
      ),
    );
  }
}

/// Social sign-in button (Google / Apple).
class AppSocialButton extends StatelessWidget {
  final String label;
  final Widget icon;
  final VoidCallback? onPressed;
  final bool isLoading;

  const AppSocialButton({
    super.key,
    required this.label,
    required this.icon,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          side: BorderSide(color: context.dColors.borderLight, width: 1.5),
          backgroundColor: context.dColors.surface,
          foregroundColor: context.dColors.textPrimary,
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  icon,
                  const SizedBox(width: 12),
                  Text(label, style: AppTypography.labelMedium),
                ],
              ),
      ),
    );
  }
}

/// Small text link button.
class AppTextButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? color;

  const AppTextButton({
    super.key,
    required this.label,
    this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        label,
        style: AppTypography.labelMedium.copyWith(
          color: color ?? AppColors.primary,
        ),
      ),
    );
  }
}

/// Icon-only circular button.
class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;

  /// Spoken label for screen readers (required for icon-only buttons).
  final String? semanticLabel;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size = 44,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: backgroundColor ?? context.dColors.surfaceDim,
            boxShadow: context.dColors.cardShadow,
          ),
          child: Icon(icon, color: iconColor ?? context.dColors.textPrimary, size: size * 0.45),
        ),
      ),
    );
  }
}
