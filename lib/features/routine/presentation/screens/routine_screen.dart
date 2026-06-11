import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/dermiq_colors.dart';
import '../../data/routine_models.dart';
import '../../../streak/data/streak_models.dart';
import '../../../streak/providers/streak_provider.dart';

class RoutineScreen extends ConsumerWidget {
  const RoutineScreen({super.key});

  static int _computeStreak() {
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

  static String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  static String _todayLabel() {
    final d = DateTime.now();
    const mo = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    const dw = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    return '${dw[d.weekday - 1]}, ${mo[d.month - 1]} ${d.day}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streak = _computeStreak();
    final today = routineHistory.first;
    final last7 = routineHistory.take(7).toList();
    final amTotal = amSteps.fold(0, (s, e) => s + e.durationMin);
    final pmTotal = pmSteps.fold(0, (s, e) => s + e.durationMin);
    final streakAsync = ref.watch(streakProvider);

    // Show reward unlock sheet when a milestone is freshly hit.
    ref.listen<AsyncValue<StreakState>>(streakProvider, (_, next) {
      final s = next.valueOrNull;
      if (s?.pendingMilestone != null && context.mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => _RewardUnlockedSheet(
                milestone: s!.pendingMilestone!,
              ),
            );
          }
        });
      }
    });

    return Scaffold(
      backgroundColor: context.dColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Pinned header ──────────────────────────────────────────────
            Container(
              color: context.dColors.surface,
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('My Routine', style: AppTypography.h3),
                        Text(
                          '${amSteps.length} AM · ${pmSteps.length} PM steps',
                          style: AppTypography.caption.copyWith(color: context.dColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  _HBtn(icon: Icons.edit_note_rounded, onTap: () => context.push('/routine/builder')),
                  _HBtn(icon: Icons.bar_chart_rounded, onTap: () => context.push('/routine/analysis')),
                  _HBtn(icon: Icons.history_rounded, onTap: () => context.push('/routine/history')),
                ],
              ),
            ),

            // ── Scrollable body ────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Current Streak Card + Next Reward Card
                    streakAsync.when(
                      loading: () => const SizedBox.shrink(),
                      error: (_, _) => const SizedBox.shrink(),
                      data: (s) => Column(
                        children: [
                          _CurrentStreakCard(streakState: s)
                              .animate().fadeIn(duration: 380.ms).slideY(begin: 0.06),
                          const SizedBox(height: 12),
                          _NextRewardCard(streakState: s)
                              .animate().fadeIn(duration: 380.ms, delay: 60.ms).slideY(begin: 0.06),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),

                    // Streak card (existing)
                    _StreakCard(streak: streak, greeting: _greeting(), today: today)
                        .animate().fadeIn(duration: 350.ms, delay: 80.ms).slideY(begin: 0.06),

                    const SizedBox(height: 20),

                    // Today header
                    Row(
                      children: [
                        Text("Today's Routines", style: AppTypography.labelLarge),
                        const Spacer(),
                        Text(_todayLabel(), style: AppTypography.caption.copyWith(color: context.dColors.textTertiary)),
                      ],
                    ).animate().fadeIn(delay: 130.ms, duration: 300.ms),

                    const SizedBox(height: 12),

                    // AM + PM cards
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: _RoutineCard(
                              isAm: true, isDone: today.amDone,
                              stepCount: amSteps.length, totalMin: amTotal,
                              onTap: () => context.push('/routine/am'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _RoutineCard(
                              isAm: false, isDone: today.pmDone,
                              stepCount: pmSteps.length, totalMin: pmTotal,
                              onTap: () => context.push('/routine/pm'),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 180.ms, duration: 350.ms).slideY(begin: 0.05),

                    const SizedBox(height: 20),

                    // Week at a glance
                    _WeekCard(days: last7)
                        .animate().fadeIn(delay: 240.ms, duration: 300.ms),

                    const SizedBox(height: 20),

                    Text('Tools', style: AppTypography.labelLarge)
                        .animate().fadeIn(delay: 300.ms, duration: 300.ms),
                    const SizedBox(height: 12),

                    _ToolsRow()
                        .animate().fadeIn(delay: 340.ms, duration: 300.ms).slideY(begin: 0.04),

                    const SizedBox(height: 16),

                    _TipCard()
                        .animate().fadeIn(delay: 390.ms, duration: 300.ms),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── _HBtn ─────────────────────────────────────────────────────────────────────

class _HBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _HBtn({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 40, height: 40,
      margin: const EdgeInsets.only(left: 6),
      decoration: BoxDecoration(color: context.dColors.surfaceDim, borderRadius: BorderRadius.circular(12)),
      child: Icon(icon, size: 20, color: context.dColors.textPrimary),
    ),
  );
}

// ── _StreakCard ───────────────────────────────────────────────────────────────

class _StreakCard extends StatelessWidget {
  final int streak;
  final String greeting;
  final RoutineDay today;
  const _StreakCard({required this.streak, required this.greeting, required this.today});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E1B4B), Color(0xFF3B2D9F), Color(0xFF5E3FFF)],
          stops: [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.heroShadow,
      ),
      child: Stack(
        children: [
          // Decoration blob
          Positioned(
            top: -20, right: -20,
            child: Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(greeting,
                        style: AppTypography.caption.copyWith(color: Colors.white.withValues(alpha: 0.65))),
                    const SizedBox(height: 2),
                    Text('Skincare Streak',
                        style: AppTypography.labelLarge.copyWith(color: Colors.white)),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        const Text('🔥', style: TextStyle(fontSize: 26)),
                        const SizedBox(width: 8),
                        Text('$streak',
                            style: AppTypography.metricMedium.copyWith(color: Colors.white)),
                        const SizedBox(width: 6),
                        Text('days in a row',
                            style: AppTypography.bodySmall.copyWith(
                                color: Colors.white.withValues(alpha: 0.65))),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      streak >= 7
                          ? 'Amazing consistency — you\'re glowing!'
                          : streak >= 3
                              ? 'You\'re building a great habit!'
                              : 'Every step counts — keep going!',
                      style: AppTypography.caption.copyWith(color: Colors.white.withValues(alpha: 0.5)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Today', style: AppTypography.caption.copyWith(color: Colors.white.withValues(alpha: 0.55))),
                  const SizedBox(height: 8),
                  _StatusPill(label: 'AM', done: today.amDone),
                  const SizedBox(height: 6),
                  _StatusPill(label: 'PM', done: today.pmDone),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final bool done;
  const _StatusPill({required this.label, required this.done});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: done
            ? AppColors.success.withValues(alpha: 0.18)
            : Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: done
              ? AppColors.success.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            size: 12,
            color: done ? AppColors.success : Colors.white.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 4),
          Text(label,
              style: AppTypography.caption.copyWith(
                color: done ? AppColors.success : Colors.white.withValues(alpha: 0.6),
                fontWeight: FontWeight.w600,
              )),
        ],
      ),
    );
  }
}

// ── _RoutineCard ──────────────────────────────────────────────────────────────

class _RoutineCard extends StatelessWidget {
  final bool isAm, isDone;
  final int stepCount, totalMin;
  final VoidCallback onTap;

  const _RoutineCard({
    required this.isAm,
    required this.isDone,
    required this.stepCount,
    required this.totalMin,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = isAm ? const Color(0xFFF59E0B) : AppColors.primary;
    final bgColors = isAm
        ? [const Color(0xFFFFFBEB), const Color(0xFFFEF3C7)]
        : [const Color(0xFFF5F3FF), const Color(0xFFEDE9FE)];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: bgColors,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: accent.withValues(alpha: 0.25)),
          boxShadow: context.dColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isAm ? Icons.wb_sunny_rounded : Icons.nightlight_rounded,
                    color: accent, size: 18,
                  ),
                ),
                const Spacer(),
                if (isDone)
                  Container(
                    width: 22, height: 22,
                    decoration: const BoxDecoration(
                        color: AppColors.success, shape: BoxShape.circle),
                    child: const Icon(Icons.check_rounded, color: Colors.white, size: 13),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(isAm ? 'AM Routine' : 'PM Routine', style: AppTypography.labelLarge),
            Text('$stepCount steps · ~$totalMin min',
                style: AppTypography.caption.copyWith(color: context.dColors.textSecondary)),
            const SizedBox(height: 10),
            // Progress bar
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                widthFactor: isDone ? 1.0 : 0.0,
                child: Container(
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              isDone ? 'Completed ✓' : 'Tap to Start →',
              style: AppTypography.labelSmall.copyWith(
                color: isDone ? AppColors.success : accent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── _WeekCard ─────────────────────────────────────────────────────────────────

class _WeekCard extends StatelessWidget {
  final List<RoutineDay> days;
  const _WeekCard({required this.days});

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
              Text('Week at a Glance', style: AppTypography.labelLarge),
              const Spacer(),
              GestureDetector(
                onTap: () => context.push('/routine/history'),
                child: Text('View All',
                    style: AppTypography.caption.copyWith(
                        color: AppColors.primary, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: days.reversed.toList().asMap().entries.map((e) {
              final isToday = e.key == days.length - 1;
              return _DayDot(day: e.value, isToday: isToday);
            }).toList(),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _Leg(color: AppColors.primary, label: 'Both done'),
              const SizedBox(width: 14),
              _Leg(color: AppColors.primary.withValues(alpha: 0.3), label: 'Partial'),
              const SizedBox(width: 14),
              _Leg(color: context.dColors.surfaceDim, label: 'Skipped', fg: context.dColors.textTertiary),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayDot extends StatelessWidget {
  final RoutineDay day;
  final bool isToday;
  const _DayDot({required this.day, required this.isToday});

  @override
  Widget build(BuildContext context) {
    final bg = day.fullDone
        ? AppColors.primary
        : day.anyDone
            ? AppColors.primary.withValues(alpha: 0.28)
            : context.dColors.surfaceDim;
    final fg = day.fullDone
        ? Colors.white
        : day.anyDone
            ? AppColors.primary
            : context.dColors.textTertiary;

    return Column(
      children: [
        Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
            border: isToday
                ? Border.all(color: AppColors.primary, width: 2.5)
                : null,
          ),
          child: Icon(
            day.fullDone
                ? Icons.check_rounded
                : day.anyDone
                    ? Icons.remove_rounded
                    : Icons.close_rounded,
            size: 15, color: fg,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          day.label.length > 3 ? day.label.substring(0, 3) : day.label,
          style: AppTypography.caption.copyWith(
            color: isToday ? AppColors.primary : context.dColors.textTertiary,
            fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class _Leg extends StatelessWidget {
  final Color color;
  final String label;
  final Color? fg;
  const _Leg({required this.color, required this.label, this.fg});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
          width: 8, height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 4),
      Text(label,
          style: AppTypography.caption.copyWith(
              color: fg ?? context.dColors.textSecondary, fontSize: 10)),
    ],
  );
}

// ── _ToolsRow ─────────────────────────────────────────────────────────────────

class _ToolsRow extends StatelessWidget {
  const _ToolsRow();

  @override
  Widget build(BuildContext context) {
    final tools = [
      ('Builder', Icons.edit_note_rounded, '/routine/builder'),
      ('Analysis', Icons.insights_rounded, '/routine/analysis'),
      ('History',  Icons.history_rounded,  '/routine/history'),
    ];
    return Row(
      children: tools.asMap().entries.map((e) {
        final i = e.key;
        final (label, icon, route) = e.value;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < tools.length - 1 ? 10 : 0),
            child: GestureDetector(
              onTap: () => context.push(route),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: context.dColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: context.dColors.cardShadow,
                ),
                child: Column(
                  children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: context.dColors.surfaceDim,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(height: 8),
                    Text(label,
                        style: AppTypography.caption.copyWith(
                            color: context.dColors.textPrimary, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── _TipCard ──────────────────────────────────────────────────────────────────

class _TipCard extends StatelessWidget {
  const _TipCard();

  static const _tips = [
    'Apply serum while skin is slightly damp for 30% better absorption.',
    'SPF is the single most effective anti-aging step — never skip it.',
    'Patch test new actives on your inner arm for 24 hours first.',
    'Less is more — 4 well-chosen products beat 10 mediocre ones.',
    'Double cleansing is only needed when wearing SPF or makeup.',
  ];

  @override
  Widget build(BuildContext context) {
    final tip = _tips[DateTime.now().day % _tips.length];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.dColors.surfaceDim,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.dColors.borderLight),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.lightbulb_outline_rounded,
                color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tip of the Day',
                    style: AppTypography.labelMedium.copyWith(
                        color: context.dColors.textPrimary)),
                const SizedBox(height: 4),
                Text(tip,
                    style: AppTypography.bodySmall.copyWith(
                        color: context.dColors.textSecondary, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Streak widgets
// ─────────────────────────────────────────────────────────────────────────────

class _CurrentStreakCard extends StatelessWidget {
  final StreakState streakState;
  const _CurrentStreakCard({required this.streakState});

  @override
  Widget build(BuildContext context) {
    final s = streakState;
    final progress = s.progressToNext;
    final pct = (progress * 100).round();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E1B4B), Color(0xFF3B2D9F), Color(0xFF5E3FFF)],
          stops: [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.heroShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🔥', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Current Streak',
                        style: AppTypography.caption.copyWith(
                            color: Colors.white.withValues(alpha: 0.7))),
                    Text('${s.current} Days',
                        style: AppTypography.h3.copyWith(color: Colors.white)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text('Best',
                        style: AppTypography.caption.copyWith(
                            color: Colors.white.withValues(alpha: 0.7), fontSize: 10)),
                    Text('${s.best}',
                        style: AppTypography.labelMedium.copyWith(color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Progress to ${s.nextMilestone} days',
                  style: AppTypography.caption.copyWith(
                      color: Colors.white.withValues(alpha: 0.7))),
              Text('$pct%',
                  style: AppTypography.caption.copyWith(
                      color: Colors.white, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _NextRewardCard extends StatelessWidget {
  final StreakState streakState;
  const _NextRewardCard({required this.streakState});

  @override
  Widget build(BuildContext context) {
    final s = streakState;
    final daysLeft = s.nextMilestone - s.current;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.dColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: context.dColors.cardShadow,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(child: Text('🏆', style: TextStyle(fontSize: 24))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(milestoneName(s.nextMilestone),
                    style: AppTypography.labelMedium),
                const SizedBox(height: 2),
                Text('$daysLeft more day${daysLeft == 1 ? '' : 's'} to unlock',
                    style: AppTypography.caption.copyWith(
                        color: context.dColors.textSecondary)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              gradient: AppColors.gradientPrimary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('${s.nextMilestone}d',
                style: AppTypography.caption.copyWith(
                    color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _RewardUnlockedSheet extends ConsumerWidget {
  final int milestone;
  const _RewardUnlockedSheet({required this.milestone});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      decoration: BoxDecoration(
        color: context.dColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: context.dColors.borderLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          const Text('🎉', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(milestoneName(milestone),
              style: AppTypography.h3, textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text('You reached a $milestone-day streak!\nChoose your reward:',
              style: AppTypography.bodySmall.copyWith(
                  color: context.dColors.textSecondary, height: 1.5),
              textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ...rewardOptions.map((opt) => _RewardOptionTile(
                option: opt,
                onTap: () async {
                  await ref.read(streakProvider.notifier).claimReward(milestone, opt);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${opt.emoji} ${opt.name} reward claimed!'),
                        backgroundColor: AppColors.success,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  }
                },
              )),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              ref.read(streakProvider.notifier).dismissPendingMilestone();
              Navigator.of(context).pop();
            },
            child: Text('Skip for now',
                style: AppTypography.caption.copyWith(color: context.dColors.textTertiary)),
          ),
        ],
        ),
      ),
    );
  }
}

class _RewardOptionTile extends StatelessWidget {
  final RewardOption option;
  final VoidCallback onTap;
  const _RewardOptionTile({required this.option, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.dColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: context.dColors.cardShadow,
          border: Border.all(color: context.dColors.borderLight),
        ),
        child: Row(
          children: [
            Text(option.emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(option.name, style: AppTypography.labelMedium),
                  const SizedBox(height: 2),
                  Text(option.description,
                      style: AppTypography.caption.copyWith(
                          color: context.dColors.textSecondary, height: 1.4),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: context.dColors.textTertiary),
          ],
        ),
      ),
    );
  }
}
