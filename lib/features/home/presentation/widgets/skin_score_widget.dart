import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class SkinScoreWidget extends StatefulWidget {
  const SkinScoreWidget({super.key});

  @override
  State<SkinScoreWidget> createState() => _SkinScoreWidgetState();
}

class _SkinScoreWidgetState extends State<SkinScoreWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _progress;

  static const _score = 82;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..forward();
    _progress = Tween<double>(begin: 0, end: _score / 100.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Skin Health Score',
                  style: AppTypography.labelMedium.copyWith(color: AppColors.textSecondary)),
              const SizedBox(width: 4),
              Icon(Icons.info_outline_rounded, size: 14, color: AppColors.textTertiary),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedBuilder(
                      animation: _progress,
                      builder: (_, _) => Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${(_score * _progress.value).round()}',
                            style: AppTypography.metricMedium.copyWith(
                                color: AppColors.textPrimary, fontSize: 44),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text(' /100',
                                style: AppTypography.bodyMedium
                                    .copyWith(color: AppColors.textSecondary)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle, color: Color(0xFF22C55E)),
                        ),
                        const SizedBox(width: 6),
                        Text('Great',
                            style: AppTypography.labelSmall
                                .copyWith(color: const Color(0xFF22C55E))),
                      ],
                    ),
                  ],
                ),
              ),
              AnimatedBuilder(
                animation: _progress,
                builder: (_, _) => SizedBox(
                  width: 90,
                  height: 90,
                  child: CustomPaint(
                      painter: _ScoreRingPainter(progress: _progress.value)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => context.push('/analysis'),
            child: Row(
              children: [
                Text('View Full Analysis',
                    style: AppTypography.labelSmall.copyWith(color: AppColors.primary)),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.primary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreRingPainter extends CustomPainter {
  final double progress;
  const _ScoreRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 12) / 2;
    const sw = 8.0;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2, 2 * pi, false,
      Paint()
        ..color = AppColors.borderLight
        ..strokeWidth = sw
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2, 2 * pi * progress, false,
        Paint()
          ..shader = const LinearGradient(colors: [AppColors.primary, AppColors.lavender])
              .createShader(Rect.fromCircle(center: center, radius: radius))
          ..strokeWidth = sw
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_ScoreRingPainter old) => old.progress != progress;
}
