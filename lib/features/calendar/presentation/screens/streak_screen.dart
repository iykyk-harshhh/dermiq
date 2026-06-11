import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/dermiq_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/calendar_models.dart';

class StreakScreen extends StatefulWidget {
  const StreakScreen({super.key});

  @override
  State<StreakScreen> createState() => _StreakScreenState();
}

class _StreakScreenState extends State<StreakScreen>
    with SingleTickerProviderStateMixin {
  late List<CalendarDay> _days;
  late int _current;
  late int _best;
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  // Milestones to celebrate
  static const _milestones = [7, 30, 50, 100, 150, 200, 365];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _days = calGenerateMonth(DateTime(now.year, now.month));
    _current = calCurrentStreak(_days);
    _best = calBestStreak(_days);
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..forward();
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  int get _nextMilestone =>
      _milestones.firstWhere((m) => m > _current, orElse: () => _current + 30);

  int get _prevMilestone {
    final passed = _milestones.where((m) => m <= _current).toList();
    return passed.isEmpty ? 0 : passed.last;
  }

  @override
  Widget build(BuildContext context) {
    final next = _nextMilestone;
    final prev = _prevMilestone;
    final span = (next - prev).clamp(1, 999);
    final progress = ((_current - prev) / span).clamp(0.0, 1.0);
    final last14 = _days.where((d) => !d.isFuture).toList();
    final tail = last14.length > 14 ? last14.sublist(last14.length - 14) : last14;

    return Scaffold(
      backgroundColor: context.dColors.background,
      appBar: AppBar(
        backgroundColor: context.dColors.background,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: context.dColors.surfaceDim, borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.arrow_back_rounded,
                size: 20, color: context.dColors.textPrimary),
          ),
        ),
        title: Text('Streak Tracking', style: AppTypography.h4),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 50),
        children: [
          // ── Flame hero ──────────────────────────────────────────────────
          _FlameHero(streak: _current, anim: _anim)
              .animate().fadeIn(duration: 350.ms).slideY(begin: 0.05),

          const SizedBox(height: 16),

          // ── Current / Best ──────────────────────────────────────────────
          Row(
            children: [
              Expanded(child: _MiniStat(
                  value: '$_current', label: 'Current Streak',
                  icon: Icons.local_fire_department_rounded,
                  color: const Color(0xFFFF6B7A))),
              const SizedBox(width: 12),
              Expanded(child: _MiniStat(
                  value: '$_best', label: 'Best Streak',
                  icon: Icons.emoji_events_rounded,
                  color: const Color(0xFFF59E0B))),
            ],
          ).animate().fadeIn(delay: 100.ms, duration: 300.ms),

          const SizedBox(height: 20),

          // ── Next milestone ──────────────────────────────────────────────
          _MilestoneCard(
            current: _current,
            next: next,
            progress: progress,
            anim: _anim,
          ).animate().fadeIn(delay: 160.ms, duration: 350.ms).slideY(begin: 0.04),

          const SizedBox(height: 20),

          // ── Last 14 days ────────────────────────────────────────────────
          Text('Last 14 Days', style: AppTypography.labelLarge)
              .animate().fadeIn(delay: 210.ms, duration: 300.ms),
          const SizedBox(height: 4),
          Text('Each flame is a day you showed up',
              style: AppTypography.caption.copyWith(color: context.dColors.textSecondary))
              .animate().fadeIn(delay: 230.ms, duration: 300.ms),
          const SizedBox(height: 14),
          _DayStrip(days: tail)
              .animate().fadeIn(delay: 260.ms, duration: 350.ms),

          const SizedBox(height: 20),

          // ── Milestones list ─────────────────────────────────────────────
          Text('Milestones', style: AppTypography.labelLarge)
              .animate().fadeIn(delay: 310.ms, duration: 300.ms),
          const SizedBox(height: 12),
          ..._milestones.asMap().entries.map((e) {
            final m = e.value;
            return _MilestoneRow(
              days: m,
              reached: _best >= m,
              isNext: m == next,
            ).animate().fadeIn(delay: (340 + e.key * 50).ms, duration: 300.ms)
                .slideY(begin: 0.04);
          }),

          const SizedBox(height: 16),

          // ── Motivation ──────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.dColors.surfaceDim,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: context.dColors.borderLight),
            ),
            child: Row(
              children: [
                const Text('💪', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _current >= 7
                        ? 'A full week strong! Consistency is the #1 driver of healthy skin.'
                        : 'Missing a day resets your streak — but showing up tomorrow restarts it. Keep going!',
                    style: AppTypography.bodySmall.copyWith(height: 1.5),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 650.ms, duration: 350.ms),
        ],
      ),
    );
  }
}

// ── _FlameHero ────────────────────────────────────────────────────────────────

class _FlameHero extends StatelessWidget {
  final int streak;
  final Animation<double> anim;
  const _FlameHero({required this.streak, required this.anim});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF6B7A), Color(0xFFFF8C6B), Color(0xFFF59E0B)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B7A).withValues(alpha: 0.35),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: anim,
            builder: (_, _) => Transform.scale(
              scale: 0.7 + 0.3 * anim.value,
              child: const Text('🔥', style: TextStyle(fontSize: 64)),
            ),
          ),
          const SizedBox(height: 8),
          AnimatedBuilder(
            animation: anim,
            builder: (_, _) => Text(
              '${(streak * anim.value).round()}',
              style: AppTypography.metricLarge.copyWith(color: Colors.white),
            ),
          ),
          Text('day streak',
              style: AppTypography.labelLarge.copyWith(
                  color: Colors.white.withValues(alpha: 0.85))),
          const SizedBox(height: 4),
          Text(
            streak == 0
                ? 'Start your streak today!'
                : 'You\'re on fire — don\'t break the chain!',
            style: AppTypography.caption.copyWith(
                color: Colors.white.withValues(alpha: 0.7)),
          ),
        ],
      ),
    );
  }
}

// ── _MiniStat ─────────────────────────────────────────────────────────────────

class _MiniStat extends StatelessWidget {
  final String value, label;
  final IconData icon;
  final Color color;
  const _MiniStat({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.dColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: context.dColors.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(value, style: AppTypography.metricSmall),
                    const SizedBox(width: 3),
                    Text('d',
                        style: AppTypography.caption.copyWith(
                            color: context.dColors.textTertiary)),
                  ],
                ),
                Text(label,
                    style: AppTypography.caption.copyWith(
                        color: context.dColors.textSecondary, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── _MilestoneCard ────────────────────────────────────────────────────────────

class _MilestoneCard extends StatelessWidget {
  final int current, next;
  final double progress;
  final Animation<double> anim;
  const _MilestoneCard({
    required this.current,
    required this.next,
    required this.progress,
    required this.anim,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = next - current;
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
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(Icons.flag_rounded,
                    color: AppColors.primary, size: 19),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Next Milestone', style: AppTypography.labelMedium),
                    Text('$remaining day${remaining == 1 ? '' : 's'} to go',
                        style: AppTypography.caption.copyWith(
                            color: context.dColors.textSecondary)),
                  ],
                ),
              ),
              Text('$next',
                  style: AppTypography.metricSmall.copyWith(color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: anim,
            builder: (_, _) => ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress * anim.value,
                minHeight: 12,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text('${(progress * 100).round()}% of the way there',
              style: AppTypography.caption.copyWith(color: context.dColors.textTertiary)),
        ],
      ),
    );
  }
}

// ── _DayStrip ─────────────────────────────────────────────────────────────────

class _DayStrip extends StatelessWidget {
  final List<CalendarDay> days;
  const _DayStrip({required this.days});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.dColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: context.dColors.cardShadow,
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 10,
        alignment: WrapAlignment.center,
        children: days.map((d) {
          final active = d.anyDone;
          return Column(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: active
                      ? const Color(0xFFFF6B7A).withValues(alpha: 0.12)
                      : context.dColors.surfaceDim,
                  borderRadius: BorderRadius.circular(11),
                ),
                alignment: Alignment.center,
                child: active
                    ? const Text('🔥', style: TextStyle(fontSize: 18))
                    : Icon(Icons.remove_rounded,
                        size: 16, color: context.dColors.textTertiary),
              ),
              const SizedBox(height: 4),
              Text('${d.date.day}',
                  style: AppTypography.caption.copyWith(
                      fontSize: 9, color: context.dColors.textTertiary)),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ── _MilestoneRow ─────────────────────────────────────────────────────────────

class _MilestoneRow extends StatelessWidget {
  final int days;
  final bool reached, isNext;
  const _MilestoneRow({required this.days, required this.reached, required this.isNext});

  String get _title {
    switch (days) {
      case 7:   return 'One Week Warrior';
      case 30:  return 'Monthly Master';
      case 50:  return 'Fifty Day Force';
      case 100: return 'Century Champion';
      case 150: return 'Glow Legend';
      case 200: return 'Skin Immortal';
      case 365: return 'Year of Radiance';
      default:  return '$days Day Streak';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = reached
        ? AppColors.success
        : isNext
            ? AppColors.primary
            : context.dColors.textTertiary;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.dColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isNext
              ? AppColors.primary.withValues(alpha: 0.3)
              : context.dColors.borderLight,
          width: isNext ? 1.5 : 1,
        ),
        boxShadow: context.dColors.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: reached ? 0.12 : 0.08),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              reached ? Icons.check_circle_rounded : Icons.lock_outline_rounded,
              color: color, size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_title, style: AppTypography.labelMedium),
                Text('$days day streak',
                    style: AppTypography.caption.copyWith(
                        color: context.dColors.textSecondary)),
              ],
            ),
          ),
          if (reached)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('Unlocked',
                  style: AppTypography.caption.copyWith(
                      color: AppColors.success, fontWeight: FontWeight.w700)),
            )
          else if (isNext)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('Next',
                  style: AppTypography.caption.copyWith(
                      color: AppColors.primary, fontWeight: FontWeight.w700)),
            ),
        ],
      ),
    );
  }
}
