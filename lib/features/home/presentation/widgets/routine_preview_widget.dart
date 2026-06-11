import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class RoutinePreviewWidget extends StatelessWidget {
  const RoutinePreviewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.surfaceDim,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.water_drop_outlined, color: AppColors.primary, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hydrating Cleanser',
                    style: AppTypography.labelMedium.copyWith(color: AppColors.textPrimary)),
                const SizedBox(height: 3),
                Text('Gentle & soothing',
                    style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _Tag('AM'),
                    const SizedBox(width: 6),
                    _Tag('PM'),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
            color: AppColors.textTertiary,
            onPressed: () => context.push('/routine'),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  const _Tag(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label,
          style: AppTypography.caption
              .copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
    );
  }
}
