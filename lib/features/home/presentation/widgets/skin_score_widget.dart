import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../providers/health_score_provider.dart';

class SkinScoreWidget extends ConsumerStatefulWidget {
  const SkinScoreWidget({super.key});

  @override
  ConsumerState<SkinScoreWidget> createState() => _SkinScoreWidgetState();
}

class _SkinScoreWidgetState extends ConsumerState<SkinScoreWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..forward();
    // 0→1 reveal; the live score is multiplied in during build so the card
    // always animates to whatever the provider currently holds.
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final score = ref.watch(healthScoreProvider);
    final band = scoreBand(score);
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
                      animation: _anim,
                      builder: (_, _) => Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${(score * _anim.value).round()}',
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
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, color: Color(band.color)),
                        ),
                        const SizedBox(width: 6),
                        Text(band.label,
                            style: AppTypography.labelSmall
                                .copyWith(color: Color(band.color))),
                      ],
                    ),
                  ],
                ),
              ),
              AnimatedBuilder(
                animation: _anim,
                builder: (_, _) => SizedBox(
                  width: 90,
                  height: 90,
                  child: CustomPaint(
                      painter: _ScoreRingPainter(
                          progress: (score / 100.0) * _anim.value)),
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
