import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/dermiq_colors.dart';

class AnalysisResultsScreen extends StatefulWidget {
  const AnalysisResultsScreen({super.key});

  @override
  State<AnalysisResultsScreen> createState() => _AnalysisResultsScreenState();
}

class _AnalysisResultsScreenState extends State<AnalysisResultsScreen>
    with SingleTickerProviderStateMixin {
  int _tab = 0;
  late final AnimationController _ringCtrl;
  late final Animation<double> _ringProgress;

  final _tabs = ['Overview', 'Spots', 'Wrinkles', 'Texture', 'Pores'];

  @override
  void initState() {
    super.initState();
    _ringCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..forward();
    _ringProgress = Tween<double>(begin: 0, end: 0.82).animate(
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
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              color: context.dColors.textPrimary,
              onPressed: () => context.pop(),
            ),
            title: Text('Analysis Results', style: AppTypography.h4),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.ios_share_rounded),
                color: context.dColors.textPrimary,
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Sharing your skin analysis…',
                        style: AppTypography.bodySmall.copyWith(color: Colors.white)),
                    backgroundColor: AppColors.primary,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Score card
                  _ScoreCard(ringProgress: _ringProgress)
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.1),

                  const SizedBox(height: 20),

                  // Tab bar
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(_tabs.length, (i) {
                        final active = i == _tab;
                        return GestureDetector(
                          onTap: () => setState(() => _tab = i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: active ? AppColors.primary : context.dColors.surface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: active ? AppColors.primary : context.dColors.borderLight,
                              ),
                            ),
                            child: Text(_tabs[i],
                                style: AppTypography.labelSmall.copyWith(
                                  color: active ? Colors.white : context.dColors.textSecondary,
                                  fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                                )),
                          ),
                        );
                      }),
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 100.ms),

                  const SizedBox(height: 20),

                  // Results list
                  ..._buildResults().asMap().entries.map((e) => e.value
                      .animate()
                      .fadeIn(duration: 400.ms, delay: Duration(milliseconds: 150 + e.key * 60))
                      .slideY(begin: 0.1)),

                  const SizedBox(height: 24),

                  // View Recommendations button
                  GestureDetector(
                    onTap: () => context.push('/shelf'),
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6B4FD8), Color(0xFF8B6FEA)],
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('View Recommendations',
                              style: AppTypography.button.copyWith(color: Colors.white)),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded,
                              color: Colors.white, size: 18),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 400.ms),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildResults() {
    const results = [
      _ConcernResult('Spots', 'Mild', 25, Color(0xFFFF8C6B),
          'Some hyperpigmentation detected on your cheeks.'),
      _ConcernResult('Wrinkles', 'Fine', 20, Color(0xFF9B82D4),
          'Fine lines around the eye area.'),
      _ConcernResult('Texture', 'Moderate', 45, Color(0xFFFF9B6B),
          'Uneven texture on T-zone.'),
      _ConcernResult('Pores', 'Mild', 30, Color(0xFF7B62C4),
          'Slightly enlarged pores on nose.'),
    ];

    return results.map((r) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _ConcernCard(result: r),
    )).toList();
  }
}

class _ScoreCard extends StatelessWidget {
  final Animation<double> ringProgress;
  const _ScoreCard({required this.ringProgress});

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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    AnimatedBuilder(
                      animation: ringProgress,
                      builder: (_, _) => Text(
                        '${(82 * ringProgress.value).round()}',
                        style: AppTypography.metricMedium.copyWith(
                            color: context.dColors.textPrimary, fontSize: 40),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(' /100',
                          style: AppTypography.bodySmall
                              .copyWith(color: context.dColors.textSecondary)),
                    ),
                  ],
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
                        style: AppTypography.caption
                            .copyWith(color: const Color(0xFF22C55E))),
                  ],
                ),
              ],
            ),
          ),
          AnimatedBuilder(
            animation: ringProgress,
            builder: (_, _) => SizedBox(
              width: 80,
              height: 80,
              child: CustomPaint(
                  painter: _MiniRingPainter(
                      progress: ringProgress.value,
                      trackColor: context.dColors.borderLight)),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniRingPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  const _MiniRingPainter({required this.progress, required this.trackColor});

  @override
  void paint(Canvas canvas, Size size) {
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
  bool shouldRepaint(_MiniRingPainter old) =>
      old.progress != progress || old.trackColor != trackColor;
}

class _ConcernResult {
  final String name;
  final String severity;
  final int percent;
  final Color color;
  final String description;
  const _ConcernResult(this.name, this.severity, this.percent, this.color, this.description);
}

class _ConcernCard extends StatelessWidget {
  final _ConcernResult result;
  const _ConcernCard({required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.dColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: context.dColors.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: result.color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.circle, color: result.color, size: 16),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(result.name,
                          style: AppTypography.labelMedium
                              .copyWith(color: context.dColors.textPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: result.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(result.severity,
                          style: AppTypography.caption.copyWith(color: result.color)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(result.description,
                    style: AppTypography.bodySmall.copyWith(color: context.dColors.textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: result.percent / 100.0,
                    backgroundColor: context.dColors.borderLight,
                    valueColor: AlwaysStoppedAnimation(result.color),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text('${result.percent}%',
              style: AppTypography.labelSmall
                  .copyWith(color: context.dColors.textSecondary, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
