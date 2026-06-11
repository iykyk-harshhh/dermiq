import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/dermiq_colors.dart';

/// Section title with optional trailing action.
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool showStar;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.showStar = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (showStar) ...[
                    Text(
                      '✦ ',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.primary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                  Flexible(
                    child: Text(title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.h4),
                  ),
                ],
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(subtitle!, style: AppTypography.bodySmall),
              ],
            ],
          ),
        ),
        if (actionLabel != null && onAction != null)
          TextButton(
            onPressed: onAction,
            child: Text(
              actionLabel!,
              style: AppTypography.labelSmall.copyWith(color: AppColors.primary),
            ),
          ),
      ],
    );
  }
}

/// Overline category label — e.g. "ROUTINE" above a section.
class OverlineLabel extends StatelessWidget {
  final String label;
  final Color? color;

  const OverlineLabel(this.label, {super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: AppTypography.overline.copyWith(color: color ?? AppColors.primary),
    );
  }
}

/// Bottom sheet drag handle.
class SheetHandle extends StatelessWidget {
  const SheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 12, bottom: 8),
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: context.dColors.borderMedium,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
