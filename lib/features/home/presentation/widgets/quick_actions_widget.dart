import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class QuickActionsWidget extends StatelessWidget {
  const QuickActionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = [
      _Action('Scan', Icons.face_retouching_natural_outlined, AppColors.primary, '/scan'),
      _Action('AI Chat', Icons.chat_bubble_outline_rounded, const Color(0xFF0EA5E9), '/chat'),
      _Action('Ingredients', Icons.science_outlined, const Color(0xFF10B981), '/ingredients'),
      _Action('Calendar', Icons.calendar_today_outlined, AppColors.warning, '/home'),
    ];

    return Row(
      children: actions
          .map(
            (a) => Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _ActionTile(action: a),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _Action {
  final String label;
  final IconData icon;
  final Color color;
  final String route;
  const _Action(this.label, this.icon, this.color, this.route);
}

class _ActionTile extends StatelessWidget {
  final _Action action;
  const _ActionTile({required this.action});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16);
    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      child: Ink(
        decoration: BoxDecoration(
          color: action.color.withValues(alpha: 0.08),
          borderRadius: radius,
          border: Border.all(color: action.color.withValues(alpha: 0.15)),
        ),
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            context.push(action.route);
          },
          borderRadius: radius,
          splashColor: action.color.withValues(alpha: 0.14),
          highlightColor: action.color.withValues(alpha: 0.06),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
          children: [
            Icon(action.icon, color: action.color, size: 24),
            const SizedBox(height: 6),
            Text(
              action.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.caption.copyWith(
                color: action.color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
            ),
          ),
        ),
      ),
    );
  }
}
