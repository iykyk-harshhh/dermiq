import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/dermiq_colors.dart';

/// Animated circular score ring.
/// Animates from 0 to [score] on first build.
class ScoreRing extends StatefulWidget {
  final int score;
  final double size;
  final double strokeWidth;
  final bool onDark;
  final Widget? centerChild;

  const ScoreRing({
    super.key,
    required this.score,
    this.size = 120,
    this.strokeWidth = 8,
    this.onDark = false,
    this.centerChild,
  });

  @override
  State<ScoreRing> createState() => _ScoreRingState();
}

class _ScoreRingState extends State<ScoreRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
    _progress = Tween<double>(begin: 0, end: widget.score / 100).animate(
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
    final textColor = widget.onDark ? Colors.white : context.dColors.textPrimary;
    final trackColor = widget.onDark
        ? Colors.white.withValues(alpha: 0.15)
        : context.dColors.borderLight;

    return AnimatedBuilder(
      animation: _progress,
      builder: (_, _) => SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(
          painter: _RingPainter(
            progress: _progress.value,
            trackColor: trackColor,
            strokeWidth: widget.strokeWidth,
          ),
          child: Center(
            child: widget.centerChild ??
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${(widget.score * _progress.value).round()}',
                      style: AppTypography.metricSmall.copyWith(
                        color: textColor,
                        fontSize: widget.size * 0.22,
                      ),
                    ),
                    Text(
                      'score',
                      style: AppTypography.caption.copyWith(
                        color: textColor.withValues(alpha: 0.7),
                        fontSize: widget.size * 0.09,
                      ),
                    ),
                  ],
                ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: 100.ms)
        .scaleXY(begin: 0.85, curve: Curves.easeOutBack);
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final double strokeWidth;

  const _RingPainter({
    required this.progress,
    required this.trackColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (min(size.width, size.height) - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Track
    canvas.drawArc(
      rect, -pi / 2, 2 * pi, false,
      Paint()
        ..color = trackColor
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Progress arc
    if (progress > 0) {
      final shader = const LinearGradient(
        colors: [AppColors.primary, AppColors.lavender],
      ).createShader(rect);

      canvas.drawArc(
        rect, -pi / 2, 2 * pi * progress, false,
        Paint()
          ..shader = shader
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}
