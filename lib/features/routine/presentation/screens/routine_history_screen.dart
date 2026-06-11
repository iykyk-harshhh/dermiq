import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/dermiq_colors.dart';
import '../../data/routine_models.dart';

class RoutineHistoryScreen extends StatelessWidget {
  const RoutineHistoryScreen({super.key});

  static int _streak() {
    int s = 0;
    for (final d in routineHistory) {
      if (d.anyDone) {
        s++;
      } else {
        break;
      }
    }
    return s;
  }

  static double _completionPct() {
    final done = routineHistory.where((d) => d.fullDone).length;
    return done / routineHistory.length;
  }

  static int _avgScore() {
    final withScore = routineHistory.where((d) => d.anyDone);
    if (withScore.isEmpty) return 0;
    return (withScore.map((d) => d.score).reduce((a, b) => a + b) /
            withScore.length)
        .round();
  }

  static int _bestStreak() {
    int best = 0, cur = 0;
    for (final d in routineHistory) {
      if (d.anyDone) {
        cur++;
        if (cur > best) best = cur;
      } else {
        cur = 0;
      }
    }
    return best;
  }

  @override
  Widget build(BuildContext context) {
    final streak = _streak();
    final pct = _completionPct();
    final avg = _avgScore();
    final best = _bestStreak();
    final first7 = routineHistory.take(7).toList();
    final second7 = routineHistory.skip(7).take(7).toList();

    return Scaffold(
      backgroundColor: context.dColors.background,
      appBar: AppBar(
        backgroundColor: context.dColors.surface,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: context.dColors.surfaceDim, borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.arrow_back_rounded, size: 20, color: context.dColors.textPrimary),
          ),
        ),
        title: Text('Routine History', style: AppTypography.h4),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Streak card ───────────────────────────────────────────────
            _StreakCard(streak: streak)
                .animate().fadeIn(duration: 300.ms).slideY(begin: 0.05),

            const SizedBox(height: 16),

            // ── Stats row ─────────────────────────────────────────────────
            _StatsRow(pct: pct, avg: avg, best: best)
                .animate().fadeIn(delay: 80.ms, duration: 300.ms),

            const SizedBox(height: 20),

            Text('2-Week Heatmap', style: AppTypography.labelLarge)
                .animate().fadeIn(delay: 130.ms, duration: 300.ms),
            const SizedBox(height: 4),
            Text('Last 14 days at a glance',
                style: AppTypography.caption.copyWith(color: context.dColors.textSecondary))
                .animate().fadeIn(delay: 150.ms, duration: 300.ms),
            const SizedBox(height: 12),

            // ── Heatmap ───────────────────────────────────────────────────
            _HeatmapGrid(week1: first7, week2: second7)
                .animate().fadeIn(delay: 180.ms, duration: 350.ms).slideY(begin: 0.04),

            const SizedBox(height: 22),

            Text('Daily Log', style: AppTypography.labelLarge)
                .animate().fadeIn(delay: 250.ms, duration: 300.ms),
            const SizedBox(height: 12),

            // ── Day list ──────────────────────────────────────────────────
            ...routineHistory.asMap().entries.map((e) {
              final i = e.key;
              final day = e.value;
              return _DayCard(day: day)
                  .animate()
                  .fadeIn(delay: (280 + i * 50).ms, duration: 300.ms)
                  .slideY(begin: 0.04);
            }),
          ],
        ),
      ),
    );
  }
}

// ── _StreakCard ───────────────────────────────────────────────────────────────

class _StreakCard extends StatelessWidget {
  final int streak;
  const _StreakCard({required this.streak});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF6B7A), Color(0xFFFF8C6B)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B7A).withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 48)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Current Streak',
                    style: AppTypography.caption.copyWith(
                        color: Colors.white.withValues(alpha: 0.75))),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text('$streak',
                        style: AppTypography.metricMedium.copyWith(color: Colors.white)),
                    const SizedBox(width: 6),
                    Text('days',
                        style: AppTypography.bodySmall.copyWith(
                            color: Colors.white.withValues(alpha: 0.7))),
                  ],
                ),
                Text(
                  streak >= 7
                      ? 'You\'re on fire! Keep glowing!'
                      : 'Keep it up — every day counts!',
                  style: AppTypography.caption.copyWith(
                      color: Colors.white.withValues(alpha: 0.6)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── _StatsRow ─────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final double pct;
  final int avg, best;
  const _StatsRow({required this.pct, required this.avg, required this.best});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _Stat(value: '${(pct * 100).round()}%', label: 'Completion', icon: Icons.check_circle_rounded, color: AppColors.success)),
        const SizedBox(width: 10),
        Expanded(child: _Stat(value: '$avg', label: 'Avg Score', icon: Icons.star_rounded, color: const Color(0xFFF59E0B))),
        const SizedBox(width: 10),
        Expanded(child: _Stat(value: '$best days', label: 'Best Streak', icon: Icons.local_fire_department_rounded, color: AppColors.error)),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  final String value, label;
  final IconData icon;
  final Color color;
  const _Stat({required this.value, required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.dColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: context.dColors.cardShadow,
      ),
      child: Column(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 8),
          Text(value,
              style: AppTypography.labelLarge.copyWith(
                  fontSize: 16, color: context.dColors.textPrimary)),
          Text(label,
              style: AppTypography.caption.copyWith(
                  color: context.dColors.textSecondary, fontSize: 10),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ── _HeatmapGrid ──────────────────────────────────────────────────────────────

class _HeatmapGrid extends StatelessWidget {
  final List<RoutineDay> week1;
  final List<RoutineDay> week2;
  const _HeatmapGrid({required this.week1, required this.week2});

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
          _HeatRow(days: week1, label: 'This week'),
          const SizedBox(height: 12),
          _HeatRow(days: week2, label: 'Last week'),
          const SizedBox(height: 14),
          // Legend
          Row(
            children: [
              _HLeg(color: AppColors.primary, label: 'Both done'),
              const SizedBox(width: 12),
              _HLeg(color: AppColors.primary.withValues(alpha: 0.3), label: 'Partial'),
              const SizedBox(width: 12),
              _HLeg(color: context.dColors.surfaceDim, label: 'Skipped', fg: context.dColors.textTertiary),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeatRow extends StatelessWidget {
  final List<RoutineDay> days;
  final String label;
  const _HeatRow({required this.days, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTypography.caption.copyWith(color: context.dColors.textSecondary)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: days.reversed.toList().map((day) {
            final bg = day.fullDone
                ? AppColors.primary
                : day.anyDone
                    ? AppColors.primary.withValues(alpha: 0.28)
                    : context.dColors.surfaceDim;
            return Column(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _HeatMini(active: day.amDone, color: const Color(0xFFF59E0B)),
                      const SizedBox(height: 3),
                      _HeatMini(active: day.pmDone, color: Colors.white.withValues(alpha: 0.8)),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  day.label.length > 3 ? day.label.substring(0, 3) : day.label,
                  style: AppTypography.caption.copyWith(
                      color: context.dColors.textTertiary, fontSize: 9),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _HeatMini extends StatelessWidget {
  final bool active;
  final Color color;
  const _HeatMini({required this.active, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 14, height: 5,
      decoration: BoxDecoration(
        color: active ? color : Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

class _HLeg extends StatelessWidget {
  final Color color;
  final String label;
  final Color? fg;
  const _HLeg({required this.color, required this.label, this.fg});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
          width: 10, height: 10,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
      const SizedBox(width: 4),
      Text(label,
          style: AppTypography.caption.copyWith(
              color: fg ?? context.dColors.textSecondary, fontSize: 10)),
    ],
  );
}

// ── _DayCard ──────────────────────────────────────────────────────────────────

class _DayCard extends StatelessWidget {
  final RoutineDay day;
  const _DayCard({required this.day});

  Color get _scoreColor => day.score >= 85
      ? AppColors.success
      : day.score >= 70
          ? AppColors.warning
          : AppColors.error;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: context.dColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.dColors.borderLight),
        boxShadow: context.dColors.cardShadow,
      ),
      child: Row(
        children: [
          // Day dot
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: day.fullDone
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : day.anyDone
                      ? AppColors.warning.withValues(alpha: 0.1)
                      : context.dColors.surfaceDim,
              shape: BoxShape.circle,
            ),
            child: Icon(
              day.fullDone
                  ? Icons.check_rounded
                  : day.anyDone
                      ? Icons.remove_rounded
                      : Icons.close_rounded,
              size: 20,
              color: day.fullDone
                  ? AppColors.primary
                  : day.anyDone
                      ? AppColors.warning
                      : context.dColors.textTertiary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(day.label, style: AppTypography.labelMedium),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _Badge(label: 'AM', done: day.amDone, color: const Color(0xFFF59E0B)),
                    const SizedBox(width: 6),
                    _Badge(label: 'PM', done: day.pmDone, color: AppColors.primary),
                  ],
                ),
              ],
            ),
          ),
          // Score
          if (day.anyDone)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _scoreColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _scoreColor.withValues(alpha: 0.3)),
              ),
              child: Text(
                '${day.score}',
                style: AppTypography.labelMedium.copyWith(color: _scoreColor),
              ),
            ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final bool done;
  final Color color;
  const _Badge({required this.label, required this.done, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: done ? color.withValues(alpha: 0.1) : context.dColors.surfaceDim,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: done ? color.withValues(alpha: 0.3) : context.dColors.borderLight),
      ),
      child: Text(label,
          style: AppTypography.caption.copyWith(
              color: done ? color : context.dColors.textTertiary,
              fontWeight: done ? FontWeight.w700 : FontWeight.w400)),
    );
  }
}
