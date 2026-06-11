import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/dermiq_colors.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen>
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
    _ring = Tween<double>(begin: 0, end: 0.82).animate(
      CurvedAnimation(parent: _ringCtrl, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _ringCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  _ScoreCard(ringAnimation: _ring)
                      .animate().fadeIn(duration: 400.ms, delay: 80.ms).slideY(begin: 0.08),

                  const SizedBox(height: 20),

                  // Chart
                  _ChartCard()
                      .animate().fadeIn(duration: 400.ms, delay: 140.ms).slideY(begin: 0.08),

                  const SizedBox(height: 20),

                  Text('Metrics', style: AppTypography.h4)
                      .animate().fadeIn(duration: 300.ms, delay: 200.ms),

                  const SizedBox(height: 12),

                  // Metrics grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.45,
                    children: const [
                      _MetricCard(label: 'Spots', value: '-21%', positive: true, color: Color(0xFFFF8C6B)),
                      _MetricCard(label: 'Wrinkles', value: '-12%', positive: true, color: Color(0xFF9B82D4)),
                      _MetricCard(label: 'Texture', value: '+8%', positive: false, color: Color(0xFFFF9B6B)),
                      _MetricCard(label: 'Redness', value: '-15%', positive: true, color: Color(0xFFFF6B7A)),
                    ],
                  ).animate().fadeIn(duration: 400.ms, delay: 240.ms),

                  const SizedBox(height: 16),

                  // View Full Progress button
                  GestureDetector(
                    onTap: () {},
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
  const _ScoreCard({required this.ringAnimation});

  @override
  Widget build(BuildContext context) {
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
                      Text('${(82 * ringAnimation.value).round()}',
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
                        decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF22C55E))),
                    const SizedBox(width: 6),
                    Text('Great', style: AppTypography.caption.copyWith(color: const Color(0xFF22C55E))),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF22C55E).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text('+18% vs last month',
                            style: AppTypography.caption.copyWith(color: const Color(0xFF22C55E)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ),
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
                      progress: ringAnimation.value,
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
  @override
  Widget build(BuildContext context) {
    final spots = [
      FlSpot(0, 65), FlSpot(1, 68), FlSpot(2, 66), FlSpot(3, 72),
      FlSpot(4, 70), FlSpot(5, 76), FlSpot(6, 79), FlSpot(7, 82),
    ];
    final labels = ['Apr 15', 'Apr 22', 'Apr 29', 'May 6', 'May 13'];

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
                      interval: 2,
                      getTitlesWidget: (v, _) {
                        final i = v.toInt() ~/ 2;
                        if (i < 0 || i >= labels.length) return const SizedBox.shrink();
                        return Text(labels[i],
                            style: AppTypography.caption.copyWith(
                                color: context.dColors.textTertiary, fontSize: 10));
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 7,
                minY: 55,
                maxY: 95,
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
                        radius: s.x == 7 ? 5 : 0,
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
  final bool positive;
  final Color color;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.positive,
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
          Text(label, style: AppTypography.caption.copyWith(color: context.dColors.textSecondary)),
          const SizedBox(height: 2),
          Text(value,
              style: AppTypography.labelLarge.copyWith(
                color: positive ? const Color(0xFF22C55E) : AppColors.error,
                fontWeight: FontWeight.w700,
              )),
        ],
      ),
    );
  }
}
