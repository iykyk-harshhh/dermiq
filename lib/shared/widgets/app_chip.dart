import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/dermiq_colors.dart';

/// Selectable filter / tag chip.
class AppChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? selectedColor;

  const AppChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
    this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = selectedColor ?? AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : context.dColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? color : context.dColors.borderLight,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: isSelected ? color : context.dColors.textSecondary,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: isSelected ? color : context.dColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Wrap of AppChip items with multi/single select.
class AppChipGroup extends StatelessWidget {
  final List<String> options;
  final List<String> selected;
  final ValueChanged<String> onToggle;
  final bool singleSelect;
  final List<IconData>? icons;
  final Color? selectedColor;

  const AppChipGroup({
    super.key,
    required this.options,
    required this.selected,
    required this.onToggle,
    this.singleSelect = false,
    this.icons,
    this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(options.length, (i) {
        final opt = options[i];
        return AppChip(
          label: opt,
          isSelected: selected.contains(opt),
          icon: icons != null && i < icons!.length ? icons![i] : null,
          selectedColor: selectedColor,
          onTap: () => onToggle(opt),
        );
      }),
    );
  }
}
