import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/dermiq_colors.dart';

/// Standard rounded-square back button (surfaceDim).
///
/// Replaces the ~30 inline `GestureDetector(Container(arrow_back))` copies.
/// Pops the navigation stack by default; pass [onTap] to override.
class AppBackButton extends StatelessWidget {
  final VoidCallback? onTap;
  final IconData icon;

  const AppBackButton({super.key, this.onTap, this.icon = Icons.arrow_back_rounded});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Back',
      child: GestureDetector(
        onTap: onTap ?? () => context.canPop() ? context.pop() : null,
        child: Container(
          width: 40, height: 40,
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: context.dColors.surfaceDim,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: context.dColors.textPrimary),
        ),
      ),
    );
  }
}

/// Translucent circular back button for use on dark / hero backgrounds.
class AppCircleBackButton extends StatelessWidget {
  final VoidCallback? onTap;
  final IconData icon;

  const AppCircleBackButton({super.key, this.onTap, this.icon = Icons.arrow_back_rounded});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Back',
      child: GestureDetector(
        onTap: onTap ?? () => context.canPop() ? context.pop() : null,
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

/// App bar with the standard [AppBackButton] leading, centred title, and
/// optional actions. Implements [PreferredSizeWidget] so it drops straight
/// into `Scaffold(appBar: ...)`.
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? subtitle;
  final List<Widget>? actions;
  final VoidCallback? onBack;
  final bool showBack;
  final Color? backgroundColor;
  final PreferredSizeWidget? bottom;

  const AppTopBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.onBack,
    this.showBack = true,
    this.backgroundColor,
    this.bottom,
  });

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? context.dColors.background,
      elevation: 0,
      centerTitle: true,
      leading: showBack ? AppBackButton(onTap: onBack) : null,
      title: subtitle == null
          ? Text(title, style: AppTypography.h4)
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: AppTypography.h4),
                subtitle!,
              ],
            ),
      actions: actions,
      bottom: bottom,
    );
  }
}
