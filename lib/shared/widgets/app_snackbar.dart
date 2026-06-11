import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

enum AppSnackbarType { info, success, error }

/// Floating, rounded snackbar used app-wide. Replaces the repeated
/// `ScaffoldMessenger.of(context).showSnackBar(SnackBar(behavior: floating...))`
/// helpers scattered across screens.
class AppSnackbar {
  const AppSnackbar._();

  static void show(
    BuildContext context,
    String message, {
    AppSnackbarType type = AppSnackbarType.info,
  }) {
    final color = switch (type) {
      AppSnackbarType.success => AppColors.success,
      AppSnackbarType.error => AppColors.error,
      AppSnackbarType.info => AppColors.primary,
    };

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message,
              style: AppTypography.bodySmall.copyWith(color: Colors.white)),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
  }

  static void success(BuildContext context, String message) =>
      show(context, message, type: AppSnackbarType.success);

  static void error(BuildContext context, String message) =>
      show(context, message, type: AppSnackbarType.error);
}
