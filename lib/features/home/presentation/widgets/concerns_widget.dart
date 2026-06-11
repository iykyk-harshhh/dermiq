import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class ConcernsWidget extends StatelessWidget {
  const ConcernsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    const concerns = [
      _Concern('Pores', 'Moderate', Color(0xFFFF8C6B)),
      _Concern('Redness', 'Mild', Color(0xFFFF6B7A)),
      _Concern('Dark Spots', 'Mild', Color(0xFF8B7355)),
    ];
    return Row(
      children: List.generate(concerns.length, (i) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < concerns.length - 1 ? 10 : 0),
            child: _ConcernCard(concern: concerns[i]),
          ),
        );
      }),
    );
  }
}

class _Concern {
  final String name;
  final String severity;
  final Color color;
  const _Concern(this.name, this.severity, this.color);
}

class _ConcernCard extends StatelessWidget {
  final _Concern concern;
  const _ConcernCard({required this.concern});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: concern.color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.circle, color: concern.color, size: 14),
          ),
          const SizedBox(height: 10),
          Text(concern.name,
              style: AppTypography.labelSmall
                  .copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(concern.severity,
              style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
