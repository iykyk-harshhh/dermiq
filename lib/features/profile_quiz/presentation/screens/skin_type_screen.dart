import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../providers/quiz_provider.dart';
import '_quiz_scaffold.dart';

class SkinTypeScreen extends ConsumerStatefulWidget {
  const SkinTypeScreen({super.key});

  @override
  ConsumerState<SkinTypeScreen> createState() => _SkinTypeScreenState();
}

class _SkinTypeScreenState extends ConsumerState<SkinTypeScreen> {
  String? _selected;

  static const _options = [
    _SkinOption(
      label: 'Oily',
      desc: 'Shiny complexion with visible pores, prone to breakouts.',
      tag: '💧 Most Common',
      insight: 'Oily skin tends to age slower — natural oils keep it plump & youthful!',
      icon: Icons.water_drop_rounded,
      color: Color(0xFF60A5FA),
      colorDark: Color(0xFF2563EB),
    ),
    _SkinOption(
      label: 'Dry',
      desc: 'Feels tight or rough, may flake — rarely shiny.',
      tag: '🌿 Moisture-Focused',
      insight: 'Rich ceramide and hyaluronic acid formulas work beautifully for your skin.',
      icon: Icons.dry_rounded,
      color: Color(0xFFF97316),
      colorDark: Color(0xFFEA580C),
    ),
    _SkinOption(
      label: 'Combination',
      desc: 'Oily T-zone (nose & forehead) with normal or dry cheeks.',
      tag: '⚖️ Zone-Based Care',
      insight: 'Zone-targeted routines let you tackle each area — the best of both worlds.',
      icon: Icons.balance_rounded,
      color: Color(0xFF8B6FEA),
      colorDark: Color(0xFF6B4FD8),
    ),
    _SkinOption(
      label: 'Normal',
      desc: 'Well-balanced, minimal imperfections, rarely oily or dry.',
      tag: '✨ Lucky You!',
      insight: 'A simple, consistent routine keeps your naturally balanced skin glowing.',
      icon: Icons.auto_awesome_rounded,
      color: Color(0xFF22C55E),
      colorDark: Color(0xFF16A34A),
    ),
    _SkinOption(
      label: 'Sensitive',
      desc: 'Easily irritated, reacts to products or environmental changes.',
      tag: '🌸 Gentle Care',
      insight: 'Fragrance-free, minimal-ingredient formulas will become your best friends.',
      icon: Icons.favorite_border_rounded,
      color: Color(0xFFEC4899),
      colorDark: Color(0xFFDB2777),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    _selected ??= ref.read(quizProvider).skinType;

    return QuizScaffold(
      step: 1,
      totalSteps: 10,
      category: 'Skin Profile',
      title: 'What is your\nskin type?',
      subtitle: 'Pick the one that best describes your skin on a typical day.',
      onBack: () => context.pop(),
      onNext: _selected != null
          ? () {
              ref.read(quizProvider.notifier).setSkinType(_selected!);
              context.push('/quiz/skin-concerns');
            }
          : null,
      child: Column(
        children: [
          const SizedBox(height: 4),
          ...List.generate(_options.length, (i) {
            final opt = _options[i];
            return _SkinTypeCard(
              option: opt,
              selected: _selected == opt.label,
              onTap: () => setState(() => _selected = opt.label),
            )
                .animate()
                .fadeIn(
                    duration: 350.ms,
                    delay: Duration(milliseconds: 55 * i))
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

class _SkinOption {
  final String label;
  final String desc;
  final String tag;
  final String insight;
  final IconData icon;
  final Color color;
  final Color colorDark;

  const _SkinOption({
    required this.label,
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

class _SkinTypeCard extends StatelessWidget {
  final _SkinOption option;
  final bool selected;
  final VoidCallback onTap;

  const _SkinTypeCard({
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
              // ── Unselected white background ─────────────────────────────
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

              // ── Selected gradient background ────────────────────────────
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

              // ── Content ─────────────────────────────────────────────────
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
                          width: 52, height: 52,
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

                        // Text block
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                                  // Check indicator
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 240),
                                    width: 24, height: 24,
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
                                            color: option.colorDark, size: 14)
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
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // ── Insight reveal (accordion) ───────────────────────────
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
                                    color: Colors.white.withValues(alpha: 0.92),
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
