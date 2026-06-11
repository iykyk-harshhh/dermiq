import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/dermiq_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/calendar_models.dart';

class MonthlyProgressScreen extends StatefulWidget {
  const MonthlyProgressScreen({super.key});

  @override
  State<MonthlyProgressScreen> createState() => _MonthlyProgressScreenState();
}

class _MonthlyProgressScreenState extends State<MonthlyProgressScreen>
    with SingleTickerProviderStateMixin {
  late DateTime _month;
  late List<CalendarDay> _days;
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
    _days = calGenerateMonth(_month);
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1300))
      ..forward();
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _changeMonth(int delta) {
    setState(() {
      _month = DateTime(_month.year, _month.month + delta);
      _days = calGenerateMonth(_month);
      _ctrl
        ..reset()
        ..forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    final rate = calCompletionRate(_days);
    final perfect = calPerfectDays(_days);
    final missed = calMissedDays(_days);
    final avgCheckIn = calAvgCheckIn(_days);
    final amDone = _days.where((d) => d.amDone).length;
    final pmDone = _days.where((d) => d.pmDone).length;
    final trackedDays = _days.where((d) => !d.isFuture).length;

    return Scaffold(
      backgroundColor: context.dColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Hero ───────────────────────────────────────────────────────
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
                child: const Icon(Icons.arrow_back_rounded,
                    color: Colors.white, size: 20),
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
                      const SizedBox(height: 16),
                      Text('Monthly Progress',
                          style: AppTypography.labelLarge.copyWith(
                              color: Colors.white.withValues(alpha: 0.75))),
                      const SizedBox(height: 16),
                      AnimatedBuilder(
                        animation: _anim,
                        builder: (_, _) => SizedBox(
                          width: 130, height: 130,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox.expand(
                                child: CircularProgressIndicator(
                                  value: rate * _anim.value,
                                  strokeWidth: 10,
                                  backgroundColor: Colors.white.withValues(alpha: 0.15),
                                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                                  strokeCap: StrokeCap.round,
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('${(rate * 100 * _anim.value).round()}%',
                                      style: AppTypography.metricMedium
                                          .copyWith(color: Colors.white, height: 1)),
                                  Text('complete',
                                      style: AppTypography.caption.copyWith(
                                          color: Colors.white.withValues(alpha: 0.6))),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text('$trackedDays days tracked in ${calMonthNames[_month.month - 1]}',
                          style: AppTypography.caption.copyWith(
                              color: Colors.white.withValues(alpha: 0.5))),
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
                // Month switcher
                Row(
                  children: [
                    Text(calMonthLabel(_month), style: AppTypography.h4),
                    const Spacer(),
                    _NavBtn(icon: Icons.chevron_left_rounded, onTap: () => _changeMonth(-1)),
                    const SizedBox(width: 8),
                    _NavBtn(icon: Icons.chevron_right_rounded, onTap: () => _changeMonth(1)),
                  ],
                ).animate().fadeIn(duration: 300.ms),

                const SizedBox(height: 16),

                // Stat grid
                Row(
                  children: [
                    Expanded(child: _StatCard(
                        value: '$perfect', label: 'Perfect Days',
                        icon: Icons.star_rounded, color: const Color(0xFFF59E0B))),
                    const SizedBox(width: 12),
                    Expanded(child: _StatCard(
                        value: '$missed', label: 'Missed Days',
                        icon: Icons.cancel_rounded, color: AppColors.error)),
                  ],
                ).animate().fadeIn(delay: 80.ms, duration: 300.ms),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _StatCard(
                        value: avgCheckIn == 0 ? '—' : '$avgCheckIn',
                        label: 'Avg Check-In',
                        icon: Icons.favorite_rounded, color: AppColors.success)),
                    const SizedBox(width: 12),
                    Expanded(child: _StatCard(
                        value: '$trackedDays', label: 'Days Tracked',
                        icon: Icons.calendar_today_rounded, color: AppColors.primary)),
                  ],
                ).animate().fadeIn(delay: 130.ms, duration: 300.ms),

                const SizedBox(height: 22),

                // AM vs PM breakdown
                _BreakdownCard(
                  amDone: amDone,
                  pmDone: pmDone,
                  trackedDays: trackedDays,
                  anim: _anim,
                ).animate().fadeIn(delay: 180.ms, duration: 350.ms).slideY(begin: 0.04),

                const SizedBox(height: 16),

                // Weekly consistency bars
                _WeeklyCard(days: _days, month: _month, anim: _anim)
                    .animate().fadeIn(delay: 240.ms, duration: 350.ms).slideY(begin: 0.04),

                const SizedBox(height: 16),

                // Insight banner
                _InsightBanner(rate: rate, perfect: perfect, missed: missed)
                    .animate().fadeIn(delay: 300.ms, duration: 350.ms),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── _NavBtn ───────────────────────────────────────────────────────────────────

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _NavBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
              color: context.dColors.surfaceDim, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 20, color: context.dColors.textPrimary),
        ),
      );
}

// ── _StatCard ─────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String value, label;
  final IconData icon;
  final Color color;
  const _StatCard({
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
                Text(value, style: AppTypography.metricSmall),
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

// ── _BreakdownCard ────────────────────────────────────────────────────────────

class _BreakdownCard extends StatelessWidget {
  final int amDone, pmDone, trackedDays;
  final Animation<double> anim;
  const _BreakdownCard({
    required this.amDone,
    required this.pmDone,
    required this.trackedDays,
    required this.anim,
  });

  @override
  Widget build(BuildContext context) {
    final amRate = trackedDays == 0 ? 0.0 : amDone / trackedDays;
    final pmRate = trackedDays == 0 ? 0.0 : pmDone / trackedDays;

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
          Text('AM vs PM Consistency', style: AppTypography.labelLarge),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: anim,
            builder: (_, _) => Column(
              children: [
                _Bar(
                  label: 'Morning',
                  count: amDone,
                  total: trackedDays,
                  value: amRate * anim.value,
                  color: const Color(0xFFF59E0B),
                  icon: Icons.wb_sunny_rounded,
                ),
                const SizedBox(height: 14),
                _Bar(
                  label: 'Evening',
                  count: pmDone,
                  total: trackedDays,
                  value: pmRate * anim.value,
                  color: AppColors.primary,
                  icon: Icons.nightlight_rounded,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final String label;
  final int count, total;
  final double value;
  final Color color;
  final IconData icon;
  const _Bar({
    required this.label,
    required this.count,
    required this.total,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 6),
            Text(label, style: AppTypography.bodySmall),
            const Spacer(),
            Text('$count / $total days',
                style: AppTypography.caption.copyWith(
                    color: color, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 10,
            backgroundColor: color.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

// ── _WeeklyCard ───────────────────────────────────────────────────────────────

class _WeeklyCard extends StatelessWidget {
  final List<CalendarDay> days;
  final DateTime month;
  final Animation<double> anim;
  const _WeeklyCard({required this.days, required this.month, required this.anim});

  List<double> _weeklyRates() {
    // Group days into weeks of 7 by day-of-month
    final weeks = <List<CalendarDay>>[];
    for (var i = 0; i < days.length; i += 7) {
      weeks.add(days.sublist(i, (i + 7).clamp(0, days.length)));
    }
    return weeks.map((w) {
      final past = w.where((d) => !d.isFuture).toList();
      if (past.isEmpty) return 0.0;
      final full = past.where((d) => d.bothDone).length;
      return full / past.length;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final rates = _weeklyRates();
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
          Text('Weekly Consistency', style: AppTypography.labelLarge),
          const SizedBox(height: 4),
          Text('Completion rate per week',
              style: AppTypography.caption.copyWith(color: context.dColors.textSecondary)),
          const SizedBox(height: 18),
          AnimatedBuilder(
            animation: anim,
            builder: (_, _) => SizedBox(
              height: 120,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(rates.length, (i) {
                  final r = rates[i];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('${(r * 100).round()}%',
                          style: AppTypography.caption.copyWith(
                              fontSize: 10, color: context.dColors.textTertiary)),
                      const SizedBox(height: 4),
                      Container(
                        width: 30,
                        height: (80 * r * anim.value).clamp(4.0, 80.0),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withValues(alpha: 0.6),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text('W${i + 1}',
                          style: AppTypography.caption.copyWith(
                              fontSize: 10, color: context.dColors.textSecondary)),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── _InsightBanner ────────────────────────────────────────────────────────────

class _InsightBanner extends StatelessWidget {
  final double rate;
  final int perfect, missed;
  const _InsightBanner({required this.rate, required this.perfect, required this.missed});

  @override
  Widget build(BuildContext context) {
    final good = rate >= 0.7;
    final color = good ? AppColors.success : AppColors.warning;
    final bg = good ? AppColors.success.withValues(alpha: 0.07) : const Color(0xFFFFFBEB);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(good ? Icons.trending_up_rounded : Icons.tips_and_updates_rounded,
                color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(good ? 'Great consistency!' : 'Room to improve',
                    style: AppTypography.labelMedium),
                const SizedBox(height: 4),
                Text(
                  good
                      ? 'You completed $perfect perfect days this month. Keep this rhythm going to protect your skin barrier.'
                      : 'You missed $missed days this month. Try setting an evening reminder to stay on track.',
                  style: AppTypography.bodySmall.copyWith(height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
