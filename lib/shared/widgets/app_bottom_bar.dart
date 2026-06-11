import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/dermiq_colors.dart';
import 'app_button.dart';

/// Pinned bottom action bar with a gradient CTA. Replaces the repeated
/// `_SaveBar` / `_ConfirmBar` / `_BookBar` / `_BottomBar` private classes.
///
/// Drops into `Scaffold(bottomNavigationBar: AppBottomBar(...))`.
class AppBottomBar extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;

  /// Optional content shown to the left of the button (e.g. a price column).
  final Widget? leading;

  /// Optional banner shown above the button (e.g. a celebration message).
  final Widget? banner;

  const AppBottomBar({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.icon,
    this.leading,
    this.banner,
  });

  @override
  Widget build(BuildContext context) {
    final button = AppButton(
      label: label,
      onPressed: onPressed,
      isLoading: loading,
      height: 52,
      icon: icon == null ? null : Icon(icon, color: Colors.white, size: 18),
    );

    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: context.dColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (banner != null) ...[banner!, const SizedBox(height: 10)],
          if (leading == null)
            button
          else
            Row(
              children: [
                leading!,
                const SizedBox(width: 16),
                Expanded(child: button),
              ],
            ),
        ],
      ),
    );
  }
}

/// Centred page / section loading spinner.
class AppLoader extends StatelessWidget {
  final String? message;
  final Color? color;

  const AppLoader({super.key, this.message, this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 32, height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: color ?? AppColors.primary,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 14),
            Text(message!,
                style: AppTypography.bodySmall.copyWith(color: context.dColors.textSecondary)),
          ],
        ],
      ),
    );
  }
}
