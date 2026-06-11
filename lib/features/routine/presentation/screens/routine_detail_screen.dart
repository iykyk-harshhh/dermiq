import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/dermiq_colors.dart';
import '../../data/routine_models.dart';
import '../../providers/routine_provider.dart';

class RoutineDetailScreen extends ConsumerStatefulWidget {
  final bool isAm;
  const RoutineDetailScreen({super.key, required this.isAm});

  @override
  ConsumerState<RoutineDetailScreen> createState() => _RoutineDetailScreenState();
}

class _RoutineDetailScreenState extends ConsumerState<RoutineDetailScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enterCtrl;
  late final Animation<double> _enterAnim;
  bool _completing = false;

  // Routine completion now lives in routineProvider (single source of truth).
  RoutineState get _routine => ref.read(routineProvider);
  List<RoutineStep> get _steps => _routine.stepsFor(widget.isAm);
  Set<String> get _done => _routine.doneIdsFor(widget.isAm);
  bool get _allDone => _routine.allDone(widget.isAm);
  double get _progress => _steps.isEmpty ? 0 : _done.length / _steps.length;
  int get _totalMin => _routine.minutesFor(widget.isAm);

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
    _enterAnim = CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    super.dispose();
  }

  void _toggle(String id) =>
      ref.read(routineProvider.notifier).toggleStep(widget.isAm, id);

  Future<void> _complete() async {
    setState(() => _completing = true);
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    ref.read(routineProvider.notifier).completeRoutine(widget.isAm);
    _showSuccessSheet();
  }

  void _showSuccessSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (_) => _SuccessSheet(
        isAm: widget.isAm,
        onDone: () {
          Navigator.pop(context);
          context.pop();
        },
      ),
    );
    setState(() => _completing = false);
  }

  // gradient colours
  List<Color> get _heroColors => widget.isAm
      ? const [Color(0xFF431407), Color(0xFF9A3412), Color(0xFFF59E0B)]
      : const [Color(0xFF1E1B4B), Color(0xFF3B2D9F), Color(0xFF5E3FFF)];

  Color get _accent =>
      widget.isAm ? const Color(0xFFF59E0B) : AppColors.primary;

  @override
  Widget build(BuildContext context) {
    // Establish the dependency so the screen rebuilds when completion changes.
    ref.watch(routineProvider);
    return Scaffold(
      backgroundColor: context.dColors.background,
      extendBodyBehindAppBar: true,
      bottomNavigationBar: _BottomBar(
        allDone: _allDone,
        completing: _completing,
        accent: _accent,
        isAm: widget.isAm,
        onComplete: _complete,
      ),
      body: CustomScrollView(
        slivers: [
          // ── Hero ────────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            elevation: 0,
            backgroundColor: _heroColors.last,
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
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _heroColors,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                widget.isAm ? Icons.wb_sunny_rounded : Icons.nightlight_rounded,
                                color: Colors.white, size: 13,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                widget.isAm ? 'Morning Routine' : 'Evening Routine',
                                style: AppTypography.caption.copyWith(
                                  color: Colors.white, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.isAm ? 'AM Routine' : 'PM Routine',
                          style: AppTypography.h3.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_steps.length} steps · ~$_totalMin min',
                          style: AppTypography.bodySmall.copyWith(
                              color: Colors.white.withValues(alpha: 0.7)),
                        ),
                        const SizedBox(height: 14),
                        // Progress bar
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${_done.length} / ${_steps.length} done',
                                  style: AppTypography.caption.copyWith(
                                      color: Colors.white.withValues(alpha: 0.75)),
                                ),
                                Text(
                                  '${(_progress * 100).round()}%',
                                  style: AppTypography.caption.copyWith(
                                    color: Colors.white, fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: _progress,
                                minHeight: 6,
                                backgroundColor: Colors.white.withValues(alpha: 0.2),
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white.withValues(alpha: 0.95)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Steps list ─────────────────────────────────────────────────
          AnimatedBuilder(
            animation: _enterAnim,
            builder: (_, _) => SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final step = _steps[i];
                    final isDone = _done.contains(step.id);
                    return Opacity(
                      opacity: (_enterAnim.value * 1.2 - i * 0.1).clamp(0.0, 1.0),
                      child: Transform.translate(
                        offset: Offset(
                            0, 20 * (1 - (_enterAnim.value).clamp(0.0, 1.0))),
                        child: _StepCard(
                          step: step,
                          index: i,
                          isDone: isDone,
                          onTap: () => _toggle(step.id),
                        ),
                      ),
                    );
                  },
                  childCount: _steps.length,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── _StepCard ─────────────────────────────────────────────────────────────────

class _StepCard extends StatelessWidget {
  final RoutineStep step;
  final int index;
  final bool isDone;
  final VoidCallback onTap;

  const _StepCard({
    required this.step,
    required this.index,
    required this.isDone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: isDone
              ? AppColors.success.withValues(alpha: 0.06)
              : context.dColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDone
                ? AppColors.success.withValues(alpha: 0.3)
                : context.dColors.borderLight,
          ),
          boxShadow: isDone ? [] : context.dColors.cardShadow,
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Step number + icon
                Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 280),
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: isDone
                            ? AppColors.success.withValues(alpha: 0.12)
                            : step.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(
                        isDone ? Icons.check_rounded : step.icon,
                        color: isDone ? AppColors.success : step.color,
                        size: 22,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: step.color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              step.stepType,
                              style: AppTypography.caption.copyWith(
                                  color: step.color, fontWeight: FontWeight.w700),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '~${step.durationMin} min',
                            style: AppTypography.caption.copyWith(color: context.dColors.textTertiary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        step.productName,
                        style: AppTypography.labelMedium.copyWith(
                          decoration: isDone ? TextDecoration.lineThrough : null,
                          decorationColor: context.dColors.textSecondary,
                          color: isDone ? context.dColors.textSecondary : context.dColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        step.description,
                        style: AppTypography.bodySmall.copyWith(color: context.dColors.textSecondary),
                      ),
                      if (!isDone) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: context.dColors.surfaceDim,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.lightbulb_outline_rounded,
                                  size: 13, color: AppColors.primary),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  step.tip,
                                  style: AppTypography.caption.copyWith(
                                      color: context.dColors.textSecondary, height: 1.4),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Checkbox
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 24, height: 24,
                  decoration: BoxDecoration(
                    color: isDone ? AppColors.success : Colors.transparent,
                    shape: BoxShape.circle,
                    border: isDone
                        ? null
                        : Border.all(color: context.dColors.borderMedium, width: 1.5),
                  ),
                  child: isDone
                      ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                      : null,
                ),
              ],
            ),
          ),
        ),
      ).animate(delay: (index * 60).ms).fadeIn(duration: 300.ms).slideY(begin: 0.05),
    );
  }
}

// ── _BottomBar ────────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final bool allDone, completing;
  final Color accent;
  final bool isAm;
  final VoidCallback onComplete;

  const _BottomBar({
    required this.allDone,
    required this.completing,
    required this.accent,
    required this.isAm,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: context.dColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (allDone) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.success.withValues(alpha: 0.25)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.celebration_rounded, color: AppColors.success, size: 16),
                  const SizedBox(width: 8),
                  Text('All steps completed! Great work!',
                      style: AppTypography.caption.copyWith(
                          color: AppColors.success, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
          GestureDetector(
            onTap: allDone && !completing ? onComplete : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              height: 52,
              decoration: BoxDecoration(
                gradient: allDone
                    ? LinearGradient(
                        colors: [accent, accent.withValues(alpha: 0.7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: allDone ? null : context.dColors.borderLight,
                borderRadius: BorderRadius.circular(28),
              ),
              alignment: Alignment.center,
              child: completing
                  ? SizedBox(
                      width: 22, height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white.withValues(alpha: 0.9))),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          allDone ? Icons.check_circle_rounded : Icons.lock_rounded,
                          size: 18,
                          color: allDone ? Colors.white : context.dColors.textTertiary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          allDone
                              ? 'Complete ${isAm ? 'AM' : 'PM'} Routine'
                              : 'Finish all steps to complete',
                          style: AppTypography.button.copyWith(
                            color: allDone ? Colors.white : context.dColors.textTertiary,
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

// ── _SuccessSheet ─────────────────────────────────────────────────────────────

class _SuccessSheet extends StatelessWidget {
  final bool isAm;
  final VoidCallback onDone;
  const _SuccessSheet({required this.isAm, required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          24, 28, 24, 28 + MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 70, height: 70,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_rounded,
                color: AppColors.success, size: 38),
          ),
          const SizedBox(height: 16),
          Text('Routine Complete!', style: AppTypography.h4),
          const SizedBox(height: 8),
          Text(
            isAm
                ? 'Your skin is ready for the day. SPF on and you\'re glowing!'
                : 'Amazing job! Your skin will thank you in the morning.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(color: context.dColors.textSecondary),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: onDone,
            child: Container(
              height: 52, width: double.infinity,
              decoration: BoxDecoration(
                gradient: AppColors.gradientPrimary,
                borderRadius: BorderRadius.circular(28),
              ),
              alignment: Alignment.center,
              child: Text('Done', style: AppTypography.button.copyWith(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
