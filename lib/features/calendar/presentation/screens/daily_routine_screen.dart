import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/dermiq_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../routine/data/routine_log.dart';
import '../../../routine/data/routine_models.dart';
import '../../../routine/providers/routine_provider.dart';
import '../../providers/calendar_log_provider.dart';

class DailyRoutineScreen extends ConsumerStatefulWidget {
  const DailyRoutineScreen({super.key});

  @override
  ConsumerState<DailyRoutineScreen> createState() => _DailyRoutineScreenState();
}

class _DailyRoutineScreenState extends ConsumerState<DailyRoutineScreen> {
  void _toggle(bool isAm, String id) {
    ref.read(routineProvider.notifier).toggleStep(isAm, id);
  }

  /// Persist the skin check-in (mood 1–5 → score 20–100) to the calendar log.
  void _rateCheckIn(int mood) {
    ref.read(calendarLogProvider.notifier).setCheckIn(DateTime.now(), mood * 20);
  }

  String _todayLabel() {
    final d = DateTime.now();
    const wd = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    const mo = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${wd[d.weekday - 1]}, ${mo[d.month - 1]} ${d.day}';
  }

  /// Maps a provider [RoutineStep] to the local display model.
  _Step _display(RoutineStep s) =>
      _Step(s.id, s.stepType, s.productName, s.icon, s.color);

  @override
  Widget build(BuildContext context) {
    final routine = ref.watch(routineProvider);
    final amSteps = [for (final s in routine.amSteps) _display(s)];
    final pmSteps = [for (final s in routine.pmSteps) _display(s)];
    final amDone = routine.amDoneIds;
    final pmDone = routine.pmDoneIds;

    bool isDone(_Step s, bool isAm) =>
        (isAm ? amDone : pmDone).contains(s.id);

    final total = amSteps.length + pmSteps.length;
    final doneCount = amSteps.where((s) => isDone(s, true)).length +
        pmSteps.where((s) => isDone(s, false)).length;
    final pct = total == 0 ? 0.0 : doneCount / total;

    // Real check-in score for today (0–100 → mood 1–5), 0 when not rated.
    final todayKey = routineDayKey(DateTime.now());
    final savedScore = ref.watch(calendarLogProvider).checkIns[todayKey] ?? 0;
    final checkInScore = savedScore > 0 ? (savedScore / 20).round().clamp(1, 5) : 0;

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
        title: Column(
          children: [
            Text("Daily View", style: AppTypography.h4),
            Text(_todayLabel(),
                style: AppTypography.caption.copyWith(color: context.dColors.textSecondary)),
          ],
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 60),
        children: [
          // ── Progress hero ────────────────────────────────────────────────
          Container(
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
            child: Row(
              children: [
                SizedBox(
                  width: 64, height: 64,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox.expand(
                        child: CircularProgressIndicator(
                          value: pct,
                          strokeWidth: 6,
                          backgroundColor: Colors.white.withValues(alpha: 0.15),
                          valueColor: const AlwaysStoppedAnimation(Colors.white),
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Text('${(pct * 100).round()}%',
                          style: AppTypography.labelMedium.copyWith(color: Colors.white)),
                    ],
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Today's Progress",
                          style: AppTypography.labelLarge.copyWith(color: Colors.white)),
                      const SizedBox(height: 4),
                      Text('$doneCount of $total steps completed',
                          style: AppTypography.bodySmall.copyWith(
                              color: Colors.white.withValues(alpha: 0.7))),
                      const SizedBox(height: 4),
                      Text(
                        pct == 1.0
                            ? 'Perfect day — well done! 🎉'
                            : 'Keep going, you\'re almost there!',
                        style: AppTypography.caption.copyWith(
                            color: Colors.white.withValues(alpha: 0.55)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.05),

          const SizedBox(height: 24),

          // ── AM section ───────────────────────────────────────────────────
          _SectionHeader(
            icon: Icons.wb_sunny_rounded,
            title: 'Morning Routine',
            color: const Color(0xFFF59E0B),
            done: amSteps.where((s) => isDone(s, true)).length,
            total: amSteps.length,
          ).animate().fadeIn(delay: 100.ms, duration: 300.ms),
          const SizedBox(height: 12),
          ...amSteps.asMap().entries.map((e) {
            final s = e.value;
            return _StepTile(
              step: s,
              index: e.key + 1,
              done: isDone(s, true),
              onToggle: () => _toggle(true, s.id),
            ).animate().fadeIn(delay: (120 + e.key * 60).ms, duration: 300.ms)
                .slideY(begin: 0.06);
          }),

          const SizedBox(height: 24),

          // ── PM section ───────────────────────────────────────────────────
          _SectionHeader(
            icon: Icons.nightlight_rounded,
            title: 'Evening Routine',
            color: AppColors.primary,
            done: pmSteps.where((s) => isDone(s, false)).length,
            total: pmSteps.length,
          ).animate().fadeIn(delay: 200.ms, duration: 300.ms),
          const SizedBox(height: 12),
          ...pmSteps.asMap().entries.map((e) {
            final s = e.value;
            return _StepTile(
              step: s,
              index: e.key + 1,
              done: isDone(s, false),
              onToggle: () => _toggle(false, s.id),
            ).animate().fadeIn(delay: (220 + e.key * 60).ms, duration: 300.ms)
                .slideY(begin: 0.06);
          }),

          const SizedBox(height: 24),

          // ── Skin check-in ────────────────────────────────────────────────
          _CheckInCard(
            score: checkInScore,
            onRate: _rateCheckIn,
          ).animate().fadeIn(delay: 320.ms, duration: 350.ms).slideY(begin: 0.05),
        ],
      ),
    );
  }
}

// ── _Step model ───────────────────────────────────────────────────────────────

class _Step {
  final String id, name, time;
  final IconData icon;
  final Color color;
  const _Step(this.id, this.name, this.time, this.icon, this.color);
}

// ── _SectionHeader ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final int done, total;
  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.color,
    required this.done,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 10),
        Text(title, style: AppTypography.labelLarge),
        const Spacer(),
        Text('$done/$total',
            style: AppTypography.labelMedium.copyWith(color: color)),
      ],
    );
  }
}

// ── _StepTile ─────────────────────────────────────────────────────────────────

class _StepTile extends StatelessWidget {
  final _Step step;
  final int index;
  final bool done;
  final VoidCallback onToggle;
  const _StepTile({
    required this.step,
    required this.index,
    required this.done,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: done ? AppColors.success.withValues(alpha: 0.06) : context.dColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: done
                ? AppColors.success.withValues(alpha: 0.3)
                : context.dColors.borderLight,
          ),
          boxShadow: done ? [] : context.dColors.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: done
                    ? AppColors.success.withValues(alpha: 0.1)
                    : step.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                done ? Icons.check_rounded : step.icon,
                color: done ? AppColors.success : step.color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$index. ${step.name}',
                      style: AppTypography.labelMedium.copyWith(
                        color: done ? context.dColors.textSecondary : context.dColors.textPrimary,
                        decoration: done ? TextDecoration.lineThrough : null,
                        decorationColor: context.dColors.textSecondary,
                      )),
                  Text(step.time, style: AppTypography.caption),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24, height: 24,
              decoration: BoxDecoration(
                color: done ? AppColors.success : Colors.transparent,
                shape: BoxShape.circle,
                border: done
                    ? null
                    : Border.all(color: context.dColors.borderMedium, width: 1.5),
              ),
              child: done
                  ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ── _CheckInCard ──────────────────────────────────────────────────────────────

class _CheckInCard extends StatelessWidget {
  final int score; // 0 = not rated, else 1..5
  final ValueChanged<int> onRate;
  const _CheckInCard({required this.score, required this.onRate});

  static const _moods = ['😣', '🙁', '😐', '🙂', '😍'];
  static const _labels = ['Rough', 'Meh', 'Okay', 'Good', 'Glowing'];

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
                  color: AppColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.favorite_rounded,
                    color: AppColors.success, size: 17),
              ),
              const SizedBox(width: 10),
              Text('Skin Check-In', style: AppTypography.labelLarge),
            ],
          ),
          const SizedBox(height: 6),
          Text('How does your skin feel today?',
              style: AppTypography.bodySmall),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (i) {
              final v = i + 1;
              final selected = score == v;
              return GestureDetector(
                onTap: () => onRate(v),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 56,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary.withValues(alpha: 0.12)
                        : context.dColors.surfaceDim,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selected ? AppColors.primary : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(_moods[i], style: const TextStyle(fontSize: 22)),
                      const SizedBox(height: 4),
                      Text(_labels[i],
                          style: AppTypography.caption.copyWith(
                            fontSize: 9,
                            color: selected ? AppColors.primary : context.dColors.textTertiary,
                            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                          )),
                    ],
                  ),
                ),
              );
            }),
          ),
          if (score > 0) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Text('Check-in saved — see you tomorrow!',
                  style: AppTypography.caption.copyWith(
                      color: AppColors.success, fontWeight: FontWeight.w600)),
            ),
          ],
        ],
      ),
    );
  }
}
