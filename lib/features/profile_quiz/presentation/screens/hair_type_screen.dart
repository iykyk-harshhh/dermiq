import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../providers/quiz_provider.dart';
import '_quiz_scaffold.dart';

class HairTypeScreen extends ConsumerStatefulWidget {
  const HairTypeScreen({super.key});

  @override
  ConsumerState<HairTypeScreen> createState() => _HairTypeScreenState();
}

class _HairTypeScreenState extends ConsumerState<HairTypeScreen> {
  String? _selected;

  static const _options = [
    _HairOption(
      label: 'Straight',
      prefix: '1',
      desc: 'Lies flat with no natural curl or wave. Ranges from fine and silky (1A) to coarse and thick (1C).',
      tag: 'Most common globally',
      insight:
          'Lightweight formulas and volume-boosting ingredients are ideal. Heavy butters and oils weigh straight hair down quickly.',
      icon: Icons.horizontal_rule_rounded,
      color: Color(0xFFEAB308),
      colorDark: Color(0xFFCA8A04),
    ),
    _HairOption(
      label: 'Wavy',
      prefix: '2',
      desc: 'S-shaped wave pattern — loose beach waves (2A) to defined, frizz-prone waves (2C).',
      tag: 'Natural wave texture',
      insight:
          'Curl-enhancing creams and diffuse-drying define waves beautifully. Avoid touching hair while wet to prevent frizz.',
      icon: Icons.waves_rounded,
      color: Color(0xFF06B6D4),
      colorDark: Color(0xFF0891B2),
    ),
    _HairOption(
      label: 'Curly',
      prefix: '3',
      desc: 'Defined ringlets or spirals. Loose corkscrews (3A) to tight, densely packed spirals (3C).',
      tag: 'Defined curl pattern',
      insight:
          'The LOC method (Leave-in, Oil, Cream) seals moisture in layers and defines curl pattern without crunch or stiffness.',
      icon: Icons.refresh_rounded,
      color: Color(0xFFF43F5E),
      colorDark: Color(0xFFE11D48),
    ),
    _HairOption(
      label: 'Coily',
      prefix: '4',
      desc: 'Tight coils or Z-pattern kinks. Soft S-coils (4A) to densely packed, angular kinks (4C).',
      tag: 'Maximum volume',
      insight:
          'Pre-poo with penetrating oils before washing. Deep conditioning weekly preserves elasticity and prevents breakage.',
      icon: Icons.cyclone_rounded,
      color: Color(0xFF8B5CF6),
      colorDark: Color(0xFF7C3AED),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selected = ref.read(quizProvider).hairType;
  }

  @override
  Widget build(BuildContext context) {
    return QuizScaffold(
      step: 6,
      totalSteps: 10,
      category: 'Hair Profile',
      title: 'What is your\nhair type?',
      subtitle: 'Choose the pattern that best describes your natural, unmanipulated hair.',
      onBack: () => context.pop(),
      onNext: _selected != null
          ? () {
              ref.read(quizProvider.notifier).setHairType(_selected!);
              context.push('/quiz/scalp-type');
            }
          : null,
      child: Column(
        children: [
          const SizedBox(height: 4),
          ...List.generate(_options.length, (i) {
            final opt = _options[i];
            return _HairTypeCard(
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

class _HairOption {
  final String label;
  final String prefix;
  final String desc;
  final String tag;
  final String insight;
  final IconData icon;
  final Color color;
  final Color colorDark;

  const _HairOption({
    required this.label,
    required this.prefix,
    required this.desc,
    required this.tag,
    required this.insight,
    required this.icon,
    required this.color,
    required this.colorDark,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Card
// ─────────────────────────────────────────────────────────────────────────────

class _HairTypeCard extends StatelessWidget {
  final _HairOption option;
  final bool selected;
  final VoidCallback onTap;

  const _HairTypeCard({
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
                              // Label + radio
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
                                  const SizedBox(width: 8),
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

                              // Tag chip + sub-type pills
                              Row(
                                children: [
                                  AnimatedContainer(
                                    duration:
                                        const Duration(milliseconds: 240),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 9, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: selected
                                          ? Colors.white
                                              .withValues(alpha: 0.20)
                                          : option.color
                                              .withValues(alpha: 0.08),
                                      borderRadius:
                                          BorderRadius.circular(10),
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
                                  const Spacer(),
                                  _SubTypePills(
                                    prefix: option.prefix,
                                    color: option.color,
                                    selected: selected,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Insight reveal
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
// Sub-type pills — shows 1A / 1B / 1C range indicator
// ─────────────────────────────────────────────────────────────────────────────

class _SubTypePills extends StatelessWidget {
  final String prefix;
  final Color color;
  final bool selected;

  const _SubTypePills({
    required this.prefix,
    required this.color,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    const labels = ['A', 'B', 'C'];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(labels.length, (i) {
        final intensity = (i + 1) / 3.0;
        return Padding(
          padding: EdgeInsets.only(left: i == 0 ? 0 : 3),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: selected
                  ? Colors.white.withValues(alpha: 0.10 + 0.10 * intensity)
                  : color.withValues(alpha: 0.06 + 0.06 * intensity),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: selected
                    ? Colors.white.withValues(alpha: 0.18 + 0.16 * intensity)
                    : color.withValues(alpha: 0.12 + 0.10 * intensity),
              ),
            ),
            child: Text(
              '$prefix${labels[i]}',
              style: AppTypography.overline.copyWith(
                color: selected
                    ? Colors.white.withValues(alpha: 0.62 + 0.28 * intensity)
                    : color.withValues(alpha: 0.58 + 0.32 * intensity),
                fontWeight:
                    i == 1 ? FontWeight.w700 : FontWeight.w500,
                fontSize: 9,
                letterSpacing: 0.2,
              ),
            ),
          ),
        );
      }),
    );
  }
}
