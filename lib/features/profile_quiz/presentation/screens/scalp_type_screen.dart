import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../providers/quiz_provider.dart';
import '_quiz_scaffold.dart';

class ScalpTypeScreen extends ConsumerStatefulWidget {
  const ScalpTypeScreen({super.key});

  @override
  ConsumerState<ScalpTypeScreen> createState() => _ScalpTypeScreenState();
}

class _ScalpTypeScreenState extends ConsumerState<ScalpTypeScreen> {
  String? _selected;

  static const _options = [
    _ScalpOption(
      label: 'Oily',
      desc: 'Roots feel greasy within 24 hours of washing. Hair appears flat and limp at the scalp.',
      tag: 'Most common scalp issue',
      washFreq: 'Daily',
      insight:
          'Clarifying shampoos with salicylic acid or zinc PCA reduce excess sebum without stripping. Wash every 1–2 days and avoid heavy conditioners near the roots.',
      icon: Icons.water_drop_rounded,
      color: Color(0xFF3B82F6),
      colorDark: Color(0xFF2563EB),
    ),
    _ScalpOption(
      label: 'Dry',
      desc: 'Scalp feels tight, itchy, or rough. May have fine flaking caused by lack of moisture.',
      tag: 'Moisture-first approach',
      washFreq: 'Weekly',
      insight:
          'Hydrating shampoos with hyaluronic acid and scalp oils like jojoba or argan restore the moisture barrier. Avoid sulfates and hot water.',
      icon: Icons.dry_rounded,
      color: Color(0xFFF59E0B),
      colorDark: Color(0xFFD97706),
    ),
    _ScalpOption(
      label: 'Balanced',
      desc: 'Scalp stays comfortable between washes — neither greasy nor tight. Minimal irritation.',
      tag: 'Lucky You!',
      washFreq: 'Every 2-3 days',
      insight:
          'A gentle maintenance routine is all you need. Use a mild sulphate-free shampoo and focus on protecting hair from heat and UV damage.',
      icon: Icons.balance_rounded,
      color: Color(0xFF22C55E),
      colorDark: Color(0xFF16A34A),
    ),
    _ScalpOption(
      label: 'Sensitive',
      desc: 'Prone to redness, stinging, or burning — especially after product changes or stress.',
      tag: 'Gentle formulas only',
      washFreq: 'Every 3-4 days',
      insight:
          'Fragrance-free, hypoallergenic formulas with aloe vera or colloidal oat calm reactivity. Always patch-test new haircare products.',
      icon: Icons.favorite_border_rounded,
      color: Color(0xFFF43F5E),
      colorDark: Color(0xFFE11D48),
    ),
    _ScalpOption(
      label: 'Flaky',
      desc: 'Visible flakes due to dandruff or seborrheic dermatitis. Often accompanied by itching.',
      tag: 'Targeted treatment needed',
      washFreq: '2x per week',
      insight:
          'Antifungal actives like ketoconazole or piroctone olamine address the root cause. Rotate between a medicated shampoo and a hydrating one.',
      icon: Icons.grain_rounded,
      color: Color(0xFF8B5CF6),
      colorDark: Color(0xFF7C3AED),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selected = ref.read(quizProvider).scalpType;
  }

  @override
  Widget build(BuildContext context) {
    return QuizScaffold(
      step: 7,
      totalSteps: 10,
      category: 'Hair Profile',
      title: 'How is your\nscalp?',
      subtitle: 'Your scalp type determines the right shampoo, treatments, and wash frequency.',
      onBack: () => context.pop(),
      onNext: _selected != null
          ? () {
              ref.read(quizProvider.notifier).setScalpType(_selected!);
              context.push('/quiz/hair-concerns');
            }
          : null,
      child: Column(
        children: [
          const SizedBox(height: 4),
          ...List.generate(_options.length, (i) {
            final opt = _options[i];
            return _ScalpTypeCard(
              option: opt,
              selected: _selected == opt.label,
              onTap: () => setState(() => _selected = opt.label),
            )
                .animate()
                .fadeIn(
                  duration: 350.ms,
                  delay: Duration(milliseconds: 55 * i),
                )
                .slideY(begin: 0.14, curve: Curves.easeOutCubic);
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Data
// ─────────────────────────────────────────────────────────────────────────────

class _ScalpOption {
  final String label;
  final String desc;
  final String tag;
  final String washFreq;
  final String insight;
  final IconData icon;
  final Color color;
  final Color colorDark;

  const _ScalpOption({
    required this.label,
    required this.desc,
    required this.tag,
    required this.washFreq,
    required this.insight,
    required this.icon,
    required this.color,
    required this.colorDark,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Card
// ─────────────────────────────────────────────────────────────────────────────

class _ScalpTypeCard extends StatelessWidget {
  final _ScalpOption option;
  final bool selected;
  final VoidCallback onTap;

  const _ScalpTypeCard({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: option.color.withValues(alpha: 0.30),
                    blurRadius: 22,
                    offset: const Offset(0, 7),
                  ),
                ]
              : AppColors.cardShadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // White background (unselected)
              Positioned.fill(
                child: AnimatedOpacity(
                  opacity: selected ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 260),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      border: Border.all(
                        color: const Color(0xFFE8DEFF),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              // Gradient background (selected)
              Positioned.fill(
                child: AnimatedOpacity(
                  opacity: selected ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 260),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [option.color, option.colorDark],
                      ),
                    ),
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon circle
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 260),
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: selected
                                ? Colors.white.withValues(alpha: 0.22)
                                : option.color.withValues(alpha: 0.10),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            option.icon,
                            size: 24,
                            color: selected ? Colors.white : option.color,
                          ),
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Label row: name + wash badge + radio
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Text(
                                      option.label,
                                      style: AppTypography.labelLarge.copyWith(
                                        color: selected
                                            ? Colors.white
                                            : const Color(0xFF1E1B4B),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  _WashBadge(
                                    freq: option.washFreq,
                                    color: option.color,
                                    selected: selected,
                                  ),
                                  const SizedBox(width: 8),
                                  // Circle radio indicator
                                  AnimatedContainer(
                                    duration:
                                        const Duration(milliseconds: 240),
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: selected
                                          ? Colors.white
                                          : Colors.transparent,
                                      border: Border.all(
                                        color: selected
                                            ? Colors.transparent
                                            : const Color(0xFFD8C8FF),
                                        width: 2,
                                      ),
                                    ),
                                    child: selected
                                        ? Icon(Icons.check_rounded,
                                            color: option.colorDark,
                                            size: 14)
                                        : null,
                                  ),
                                ],
                              ),

                              const SizedBox(height: 4),

                              Text(
                                option.desc,
                                style: AppTypography.caption.copyWith(
                                  color: selected
                                      ? Colors.white.withValues(alpha: 0.82)
                                      : AppColors.textSecondary,
                                  height: 1.4,
                                ),
                              ),

                              const SizedBox(height: 8),

                              // Tag chip
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 240),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 9, vertical: 4),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? Colors.white.withValues(alpha: 0.20)
                                      : option.color.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  option.tag,
                                  style: AppTypography.overline.copyWith(
                                    color: selected
                                        ? Colors.white
                                        : option.color,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 10,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Insight reveal (accordion)
                    AnimatedCrossFade(
                      duration: const Duration(milliseconds: 280),
                      crossFadeState: selected
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      sizeCurve: Curves.easeInOut,
                      firstChild: const SizedBox(width: double.infinity),
                      secondChild: Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.auto_awesome_rounded,
                                color: Colors.white,
                                size: 13,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  option.insight,
                                  style: AppTypography.caption.copyWith(
                                    color: Colors.white
                                        .withValues(alpha: 0.92),
                                    height: 1.45,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Wash frequency badge
// ─────────────────────────────────────────────────────────────────────────────

class _WashBadge extends StatelessWidget {
  final String freq;
  final Color color;
  final bool selected;

  const _WashBadge({
    required this.freq,
    required this.color,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: selected
            ? Colors.white.withValues(alpha: 0.22)
            : color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.water_drop_rounded,
            size: 9,
            color: selected ? Colors.white : color,
          ),
          const SizedBox(width: 3),
          Text(
            freq,
            style: AppTypography.overline.copyWith(
              color: selected ? Colors.white : color,
              fontWeight: FontWeight.w700,
              fontSize: 9.5,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
