import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/dermiq_colors.dart';

/// Standard rounded confirm dialog. Returns `true` when the confirm action is
/// tapped, `false`/`null` otherwise. Replaces the repeated
/// `showDialog(AlertDialog(shape: RoundedRectangleBorder(...)))` copies.
Future<bool?> showAppConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
  bool danger = false,
}) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(title, style: AppTypography.h4),
      content: Text(message, style: AppTypography.bodyMedium),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(cancelLabel,
              style: AppTypography.buttonSmall.copyWith(color: ctx.dColors.textSecondary)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(confirmLabel,
              style: AppTypography.buttonSmall.copyWith(
                  color: danger ? AppColors.error : AppColors.primary)),
        ),
      ],
    ),
  );
}
