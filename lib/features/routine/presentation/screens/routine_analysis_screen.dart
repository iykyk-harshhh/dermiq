import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/dermiq_colors.dart';
import '../../data/routine_models.dart';

class RoutineAnalysisScreen extends StatefulWidget {
  const RoutineAnalysisScreen({super.key});

  @override
  State<RoutineAnalysisScreen> createState() => _RoutineAnalysisScreenState();
}

class _RoutineAnalysisScreenState extends State<RoutineAnalysisScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  static const _score = 87;
  static const _amScore = 92;
  static const _pmScore = 81;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.dColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Hero ────────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            elevation: 0,
            backgroundColor: const Color(0xFF1E1B4B),
            leading: GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1E1B4B), Color(0xFF3B2D9F), Color(0xFF5E3FFF)],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Text('Routine Analysis',
                          style: AppTypography.labelLarge.copyWith(
                              color: Colors.white.withValues(alpha: 0.75))),
                      const SizedBox(height: 20),
                      // Score ring
                      AnimatedBuilder(
                        animation: _anim,
                        builder: (_, _) => SizedBox(
                          width: 130, height: 130,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox.expand(
                                child: CircularProgressIndicator(
                                  value: (_score / 100) * _anim.value,
                                  strokeWidth: 10,
                                  backgroundColor: Colors.white.withValues(alpha: 0.15),
                                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                  strokeCap: StrokeCap.round,
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${(_score * _anim.value).round()}',
                                    style: AppTypography.metricMedium.copyWith(
                                        color: Colors.white, height: 1),
                                  ),
                                  Text('/100',
                                      style: AppTypography.caption.copyWith(
                                          color: Colors.white.withValues(alpha: 0.6))),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _ScoreLabel(score: _score),
                      const SizedBox(height: 6),
                      Text(
                        '${amSteps.length + pmSteps.length} total steps analysed',
                        style: AppTypography.caption.copyWith(
                            color: Colors.white.withValues(alpha: 0.5)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Body ────────────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // AI Verdict
                _VertictBanner(score: _score)
                    .animate().fadeIn(delay: 200.ms, duration: 350.ms).slideY(begin: 0.05),

                const SizedBox(height: 18),

                // Score breakdown
                _SectionCard(
                  title: 'Score Breakdown',
                  icon: Icons.bar_chart_rounded,
                  child: AnimatedBuilder(
                    animation: _anim,
                    builder: (_, _) => Column(
                      children: [
                        _ScoreBar(label: 'AM Routine', score: _amScore, anim: _anim.value,
                            color: const Color(0xFFF59E0B)),
                        const SizedBox(height: 14),
                        _ScoreBar(label: 'PM Routine', score: _pmScore, anim: _anim.value,
                            color: AppColors.primary),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 300.ms, duration: 350.ms).slideY(begin: 0.04),

                const SizedBox(height: 14),

                // Conflicts
                _SectionCard(
                  title: 'Ingredient Conflicts',
                  icon: Icons.warning_amber_rounded,
                  iconColor: AppColors.warning,
                  child: Column(
                    children: [
                      _ConflictRow(
                        a: 'Retinol (PM Treat)',
                        b: 'Glycolic Acid (AM Tone)',
                        severity: 'Low',
                        note: 'Both are actives — separated AM/PM correctly. No concern.',
                      ),
                      const _Divider(),
                      _ConflictRow(
                        a: 'Niacinamide (AM Treat)',
                        b: 'Vitamin C (if added)',
                        severity: 'Watch',
                        note: 'Niacinamide + Vitamin C can reduce efficacy. Use hours apart.',
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 380.ms, duration: 350.ms).slideY(begin: 0.04),

                const SizedBox(height: 14),

                // Redundancies
                _SectionCard(
                  title: 'Redundancies',
                  icon: Icons.content_copy_rounded,
                  iconColor: context.dColors.textSecondary,
                  child: Column(
                    children: [
                      _FindingRow(
                        icon: Icons.check_circle_rounded,
                        iconColor: AppColors.success,
                        text: 'No duplicate actives found across AM and PM.',
                      ),
                      const _Divider(),
                      _FindingRow(
                        icon: Icons.info_outline_rounded,
                        iconColor: AppColors.primary,
                        text: 'Double-cleanse in PM is appropriate for daily SPF users.',
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 450.ms, duration: 350.ms).slideY(begin: 0.04),

                const SizedBox(height: 14),

                // Recommendations
                _SectionCard(
                  title: 'Recommendations',
                  icon: Icons.lightbulb_rounded,
                  iconColor: const Color(0xFFF59E0B),
                  child: Column(
                    children: [
                      _FindingRow(
                        icon: Icons.arrow_upward_rounded,
                        iconColor: AppColors.primary,
                        text: 'Add a Vitamin C serum (AM) to boost antioxidant protection.',
                      ),
                      const _Divider(),
                      _FindingRow(
                        icon: Icons.arrow_upward_rounded,
                        iconColor: AppColors.primary,
                        text: 'Consider an eye cream step in PM routine for targeted care.',
                      ),
                      const _Divider(),
                      _FindingRow(
                        icon: Icons.star_rounded,
                        iconColor: const Color(0xFFF59E0B),
                        text: 'Your SPF placement is perfect — keep it as the final AM step.',
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 520.ms, duration: 350.ms).slideY(begin: 0.04),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── _ScoreLabel ───────────────────────────────────────────────────────────────

class _ScoreLabel extends StatelessWidget {
  final int score;
  const _ScoreLabel({required this.score});

  @override
  Widget build(BuildContext context) {
    final label = score >= 85 ? 'Excellent' : score >= 70 ? 'Good' : 'Needs Work';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Text(label,
          style: AppTypography.labelMedium.copyWith(color: Colors.white)),
    );
  }
}

// ── _VertictBanner ────────────────────────────────────────────────────────────

class _VertictBanner extends StatelessWidget {
  final int score;
  const _VertictBanner({required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.auto_awesome_rounded,
                color: AppColors.warning, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI Verdict', style: AppTypography.labelMedium),
                const SizedBox(height: 4),
                Text(
                  score >= 85
                      ? 'Your routine is exceptionally well-structured. AM focuses on protection, PM on repair — exactly right. Minor tweaks could push you to 95+.'
                      : score >= 70
                          ? 'Solid routine with room to grow. Your step ordering is correct and conflicts are minimal.'
                          : 'Your routine needs restructuring. Key steps may be missing or in the wrong order.',
                  style: AppTypography.bodySmall.copyWith(
                      color: context.dColors.textSecondary, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── _SectionCard ──────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color? iconColor;
  final Widget child;
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.dColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: context.dColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                  color: (iconColor ?? AppColors.primary).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon,
                    color: iconColor ?? AppColors.primary, size: 17),
              ),
              const SizedBox(width: 10),
              Text(title, style: AppTypography.labelLarge),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

// ── _ScoreBar ─────────────────────────────────────────────────────────────────

class _ScoreBar extends StatelessWidget {
  final String label;
  final int score;
  final double anim;
  final Color color;
  const _ScoreBar({required this.label, required this.score,
      required this.anim, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTypography.bodySmall),
            Text('$score / 100',
                style: AppTypography.caption.copyWith(
                    color: color, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (score / 100) * anim,
            minHeight: 8,
            backgroundColor: color.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

// ── _ConflictRow ──────────────────────────────────────────────────────────────

class _ConflictRow extends StatelessWidget {
  final String a, b, severity, note;
  const _ConflictRow({required this.a, required this.b,
      required this.severity, required this.note});

  Color get _color => severity == 'High'
      ? AppColors.error
      : severity == 'Watch'
          ? AppColors.warning
          : AppColors.success;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(a,
                    style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Icon(Icons.compare_arrows_rounded, size: 14, color: context.dColors.textTertiary),
              ),
              Expanded(
                child: Text(b,
                    textAlign: TextAlign.right,
                    style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _color.withValues(alpha: 0.3)),
                ),
                child: Text(severity,
                    style: AppTypography.caption.copyWith(
                        color: _color, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(note,
              style: AppTypography.caption.copyWith(
                  color: context.dColors.textSecondary, height: 1.4)),
        ],
      ),
    );
  }
}

// ── _FindingRow ───────────────────────────────────────────────────────────────

class _FindingRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String text;
  const _FindingRow({required this.icon, required this.iconColor, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: AppTypography.bodySmall.copyWith(
                    color: context.dColors.textSecondary, height: 1.5)),
          ),
        ],
      ),
    );
  }
}

// ── _Divider ──────────────────────────────────────────────────────────────────

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) =>
      Divider(color: context.dColors.borderLight, height: 1, thickness: 1);
}
