import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../onboarding/providers/onboarding_provider.dart';

class QuizScreen extends ConsumerWidget {
  const QuizScreen({super.key});

  static const _steps = [
    'Skin Type',
    'Sensitivity',
    'Concerns',
    'Goals',
    'Lifestyle',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quiz = ref.watch(quizProvider);
    final notifier = ref.read(quizProvider.notifier);
    final step = quiz.currentStep;

    return Scaffold(
      body: Stack(
        children: [
          Container(decoration: const BoxDecoration(gradient: AppColors.gradientSurface)),
          SafeArea(
            child: Column(
              children: [
                // Progress header
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (step > 0)
                            IconButton(
                              icon: const Icon(Icons.arrow_back_rounded),
                              onPressed: notifier.prevStep,
                              color: AppColors.textPrimary,
                            ),
                          Expanded(
                            child: LinearProgressIndicator(
                              value: (step + 1) / _steps.length,
                              backgroundColor: AppColors.lavender.withValues(alpha: 0.2),
                              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                              borderRadius: BorderRadius.circular(4),
                              minHeight: 6,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${step + 1}/${_steps.length}',
                            style: AppTypography.caption,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        _steps[step],
                        style: AppTypography.h3,
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildStep(context, step, quiz, notifier),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(24),
                  child: AppButton(
                    label: step == _steps.length - 1 ? 'Complete' : 'Next',
                    onPressed: _canProceed(step, quiz)
                        ? () => _onNext(context, step, notifier, quiz)
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _canProceed(int step, QuizState quiz) {
    switch (step) {
      case 0:
        return quiz.skinType != null;
      case 1:
        return quiz.sensitivity != null;
      case 2:
        return quiz.concerns.isNotEmpty;
      case 3:
        return quiz.goals.isNotEmpty;
      case 4:
        return true;
      default:
        return false;
    }
  }

  void _onNext(
      BuildContext context, int step, QuizNotifier notifier, QuizState quiz) {
    if (step < _steps.length - 1) {
      notifier.nextStep();
    } else {
      context.go('/home');
    }
  }

  Widget _buildStep(
      BuildContext context, int step, QuizState quiz, QuizNotifier notifier) {
    switch (step) {
      case 0:
        return _buildSkinTypeStep(quiz, notifier);
      case 1:
        return _buildSensitivityStep(quiz, notifier);
      case 2:
        return _buildConcernsStep(quiz, notifier);
      case 3:
        return _buildGoalsStep(quiz, notifier);
      case 4:
        return _buildLifestyleStep(quiz, notifier);
      default:
        return const SizedBox();
    }
  }

  Widget _buildSkinTypeStep(QuizState quiz, QuizNotifier notifier) {
    final options = [
      _QuizOption('Dry', Icons.water_drop_outlined, 'Feels tight, flaky patches'),
      _QuizOption('Oily', Icons.opacity_outlined, 'Shiny, enlarged pores'),
      _QuizOption('Combination', Icons.balance_outlined, 'Oily T-zone, dry cheeks'),
      _QuizOption('Normal', Icons.check_circle_outline, 'Balanced, minimal issues'),
    ];
    return _OptionGrid(
      options: options,
      selected: quiz.skinType == null ? [] : [quiz.skinType!],
      onSelect: (v) => notifier.setSkinType(v),
      singleSelect: true,
    );
  }

  Widget _buildSensitivityStep(QuizState quiz, QuizNotifier notifier) {
    final options = [
      _QuizOption('Low', Icons.sentiment_satisfied_outlined, 'Rarely reacts to products'),
      _QuizOption('Medium', Icons.sentiment_neutral_outlined, 'Sometimes reacts'),
      _QuizOption('High', Icons.sentiment_dissatisfied_outlined, 'Reacts often, redness'),
    ];
    return _OptionGrid(
      options: options,
      selected: quiz.sensitivity == null ? [] : [quiz.sensitivity!],
      onSelect: (v) => notifier.setSensitivity(v),
      singleSelect: true,
    );
  }

  Widget _buildConcernsStep(QuizState quiz, QuizNotifier notifier) {
    final options = [
      _QuizOption('Acne', Icons.bubble_chart_outlined, 'Breakouts, blemishes'),
      _QuizOption('Dryness', Icons.water_drop_outlined, 'Flakiness, tightness'),
      _QuizOption('Oiliness', Icons.opacity_outlined, 'Excess shine'),
      _QuizOption('Pigmentation', Icons.format_color_fill_outlined, 'Dark spots'),
      _QuizOption('Redness', Icons.circle_outlined, 'Flushing, irritation'),
      _QuizOption('Pores', Icons.grid_on_outlined, 'Large pores'),
      _QuizOption('Texture', Icons.texture_outlined, 'Rough, uneven skin'),
      _QuizOption('Aging', Icons.timelapse_outlined, 'Fine lines, wrinkles'),
    ];
    return _OptionGrid(
      options: options,
      selected: quiz.concerns,
      onSelect: (v) => notifier.toggleConcern(v),
      singleSelect: false,
    );
  }

  Widget _buildGoalsStep(QuizState quiz, QuizNotifier notifier) {
    final options = [
      _QuizOption('Clear Acne', Icons.face_retouching_natural_outlined, ''),
      _QuizOption('Hydration', Icons.water_drop_outlined, ''),
      _QuizOption('Glow', Icons.wb_sunny_outlined, ''),
      _QuizOption('Texture', Icons.auto_fix_high_outlined, ''),
      _QuizOption('Anti Aging', Icons.timelapse_outlined, ''),
      _QuizOption('Even Tone', Icons.palette_outlined, ''),
    ];
    return _OptionGrid(
      options: options,
      selected: quiz.goals,
      onSelect: (v) => notifier.toggleGoal(v),
      singleSelect: false,
    );
  }

  Widget _buildLifestyleStep(QuizState quiz, QuizNotifier notifier) {
    return Column(
      children: [
        _LifestyleQuestion(
          question: 'How many hours do you sleep?',
          options: ['< 6 hrs', '6-7 hrs', '7-8 hrs', '8+ hrs'],
          selected: quiz.lifestyle['sleep'],
          onSelect: (v) => notifier.setLifestyle('sleep', v),
        ),
        const SizedBox(height: 24),
        _LifestyleQuestion(
          question: 'Daily water intake?',
          options: ['< 1L', '1-2L', '2-3L', '3L+'],
          selected: quiz.lifestyle['water'],
          onSelect: (v) => notifier.setLifestyle('water', v),
        ),
        const SizedBox(height: 24),
        _LifestyleQuestion(
          question: 'Stress level?',
          options: ['Low', 'Moderate', 'High', 'Very High'],
          selected: quiz.lifestyle['stress'],
          onSelect: (v) => notifier.setLifestyle('stress', v),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _QuizOption {
  final String label;
  final IconData icon;
  final String subtitle;
  const _QuizOption(this.label, this.icon, this.subtitle);
}

class _OptionGrid extends StatelessWidget {
  final List<_QuizOption> options;
  final List<String> selected;
  final ValueChanged<String> onSelect;
  final bool singleSelect;

  const _OptionGrid({
    required this.options,
    required this.selected,
    required this.onSelect,
    required this.singleSelect,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.3,
      ),
      itemCount: options.length,
      itemBuilder: (_, i) {
        final opt = options[i];
        final isSelected = selected.contains(opt.label);
        return GestureDetector(
          onTap: () => onSelect(opt.label),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(AppConstants.radiusCard),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.lavender.withValues(alpha: 0.2),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.15)
                      : AppColors.primary.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  opt.icon,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  size: 28,
                ),
                const SizedBox(height: 8),
                Text(
                  opt.label,
                  style: AppTypography.labelMedium.copyWith(
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (opt.subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    opt.subtitle,
                    style: AppTypography.caption,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LifestyleQuestion extends StatelessWidget {
  final String question;
  final List<String> options;
  final String? selected;
  final ValueChanged<String> onSelect;

  const _LifestyleQuestion({
    required this.question,
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(question, style: AppTypography.labelMedium),
        const SizedBox(height: 12),
        Row(
          children: options.map((opt) {
            final isSelected = selected == opt;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => onSelect(opt),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.lavender.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      opt,
                      style: AppTypography.caption.copyWith(
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
