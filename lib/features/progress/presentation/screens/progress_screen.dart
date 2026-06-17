import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/dermiq_colors.dart';
import '../../../analysis/providers/analysis_provider.dart';
import '../../../home/providers/health_score_provider.dart';
import '../../../routine/providers/routine_provider.dart';

class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen>
    with SingleTickerProviderStateMixin {
  int _viewIndex = 1; // Week/Month/Year
  final _views = ['Week', 'Month', 'Year'];

  late final AnimationController _ringCtrl;
  late final Animation<double> _ring;

  @override
  void initState() {
    super.initState();
    _ringCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..forward();
    // 0→1 reveal; the live score scales it in during build.
    _ring = CurvedAnimation(parent: _ringCtrl, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _ringCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final score = ref.watch(healthScoreProvider);
    final band = scoreBand(score);
    // Score trend from the rolling routine history (oldest → newest).
    final trend = ref
        .watch(routineProvider)
        .history
        .reversed
        .map((d) => d.score)
        .where((s) => s > 0)
        .toList();
    final concerns = ref.watch(analysisProvider).concerns;
    return Scaffold(
      backgroundColor: context.dColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            backgroundColor: context.dColors.background,
            elevation: 0,
            pinned: true,
            title: Text('Progress', style: AppTypography.h4),
            centerTitle: true,
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // View toggle
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: context.dColors.surfaceDim,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: List.generate(_views.length, (i) {
                        final active = i == _viewIndex;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _viewIndex = i),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: active ? context.dColors.surface : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: active ? context.dColors.cardShadow : null,
                              ),
                              child: Text(_views[i],
                                  style: AppTypography.labelSmall.copyWith(
                                    color: active ? context.dColors.textPrimary : context.dColors.textTertiary,
                                    fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                                  ),
                                  textAlign: TextAlign.center),
                            ),
                          ),
                        );
                      }),
                    ),
                  ).animate().fadeIn(duration: 300.ms),

                  const SizedBox(height: 20),

                  // Score card
                  _ScoreCard(ringAnimation: _ring, score: score, band: band)
                      .animate().fadeIn(duration: 400.ms, delay: 80.ms).slideY(begin: 0.08),

                  const SizedBox(height: 20),

                  // Chart
                  _ChartCard(scores: trend)
                      .animate().fadeIn(duration: 400.ms, delay: 140.ms).slideY(begin: 0.08),

                  const SizedBox(height: 20),

                  Text('Metrics', style: AppTypography.h4)
                      .animate().fadeIn(duration: 300.ms, delay: 200.ms),

                  const SizedBox(height: 12),

                  // Metrics grid — current concern levels from the latest analysis.
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.45,
                    children: [
                      for (final c in concerns.take(4))
                        _MetricCard(
                          label: c.name,
                          value: '${c.percent}%',
                          severity: c.severity,
                          color: c.color,
                        ),
                    ],
                  ).animate().fadeIn(duration: 400.ms, delay: 240.ms),

                  const SizedBox(height: 16),

                  // View Full Progress button
                  GestureDetector(
                    onTap: () => context.push('/calendar/monthly'),
                    child: Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        color: context.dColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: context.dColors.borderMedium),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('View Full Progress',
                              style: AppTypography.labelMedium.copyWith(color: AppColors.primary)),
                          const SizedBox(width: 6),
                          const Icon(Icons.arrow_forward_rounded,
                              color: AppColors.primary, size: 16),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(duration: 350.ms, delay: 300.ms),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  final Animation<double> ringAnimation;
  final int score;
  final ({String label, int color}) band;
  const _ScoreCard({
    required this.ringAnimation,
    required this.score,
    required this.band,
  });

  @override
  Widget build(BuildContext context) {
    final bandColor = Color(band.color);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.dColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: context.dColors.cardShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Skin Health Score',
                    style: AppTypography.labelSmall.copyWith(color: context.dColors.textSecondary)),
                const SizedBox(height: 6),
                AnimatedBuilder(
                  animation: ringAnimation,
                  builder: (_, _) => Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('${(score * ringAnimation.value).round()}',
                          style: AppTypography.metricMedium
                              .copyWith(color: context.dColors.textPrimary, fontSize: 40)),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(' /100',
                            style: AppTypography.bodySmall.copyWith(color: context.dColors.textSecondary)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                        width: 8, height: 8,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: bandColor)),
                    const SizedBox(width: 6),
                    Text(band.label, style: AppTypography.caption.copyWith(color: bandColor)),
                  ],
                ),
              ],
            ),
          ),
          // Ring
          AnimatedBuilder(
            animation: ringAnimation,
            builder: (_, _) => SizedBox(
              width: 80,
              height: 80,
              child: CustomPaint(
                  painter: _RingPainter(
                      progress: (score / 100.0) * ringAnimation.value,
                      trackColor: context.dColors.borderLight)),
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  const _RingPainter({required this.progress, required this.trackColor});

  @override
  void paint(Canvas canvas, Size size) {
    const pi = 3.14159265358979;
    final c = Offset(size.width / 2, size.height / 2);
    final r = (size.width - 10) / 2;
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      -pi / 2, 2 * pi, false,
      Paint()..color = trackColor..strokeWidth = 7..style = PaintingStyle.stroke,
    );
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        -pi / 2, 2 * pi * progress, false,
        Paint()
          ..shader = const LinearGradient(colors: [AppColors.primary, AppColors.lavender])
              .createShader(Rect.fromCircle(center: c, radius: r))
          ..strokeWidth = 7
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.trackColor != trackColor;
}

class _ChartCard extends StatelessWidget {
  final List<int> scores;
  const _ChartCard({required this.scores});

  @override
  Widget build(BuildContext context) {
    // Use the real score trend; fall back to a gentle placeholder if there's
    // no routine history yet so the chart is never empty.
    final data = scores.length >= 2
        ? scores
        : const [62, 66, 64, 70, 72, 75, 78, 82];
    final spots = [
      for (var i = 0; i < data.length; i++) FlSpot(i.toDouble(), data[i].toDouble()),
    ];
    final lastX = (data.length - 1).toDouble();
    final loY = (data.reduce((a, b) => a < b ? a : b) - 8).clamp(0, 100).toDouble();
    final hiY = (data.reduce((a, b) => a > b ? a : b) + 8).clamp(0, 100).toDouble();
    final labels = ['Older', 'Recent'];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      decoration: BoxDecoration(
        color: context.dColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: context.dColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Score Trend',
              style: AppTypography.labelMedium.copyWith(color: context.dColors.textPrimary)),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 10,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: context.dColors.divider,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: lastX,
                      getTitlesWidget: (v, _) {
                        final label = v == 0
                            ? labels.first
                            : (v == lastX ? labels.last : '');
                        if (label.isEmpty) return const SizedBox.shrink();
                        return Text(label,
                            style: AppTypography.caption.copyWith(
                                color: context.dColors.textTertiary, fontSize: 10));
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: lastX,
                minY: loY,
                maxY: hiY,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.lavender],
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (s, _, _, _) => FlDotCirclePainter(
                        radius: s.x == lastX ? 5 : 0,
                        color: AppColors.primary,
                        strokeColor: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primary.withValues(alpha: 0.18),
                          AppColors.primary.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String severity;
  final Color color;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.severity,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.dColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: context.dColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.circle, color: color, size: 12),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(label,
                    style: AppTypography.caption
                        .copyWith(color: context.dColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
              Text(severity,
                  style: AppTypography.caption.copyWith(color: color)),
            ],
          ),
          const SizedBox(height: 2),
          Text(value,
              style: AppTypography.labelLarge.copyWith(
                color: context.dColors.textPrimary,
                fontWeight: FontWeight.w700,
              )),
        ],
      ),
    );
  }
}
