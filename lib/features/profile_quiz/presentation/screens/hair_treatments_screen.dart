import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../providers/quiz_provider.dart';
import '_quiz_scaffold.dart';

class HairTreatmentsScreen extends ConsumerStatefulWidget {
  const HairTreatmentsScreen({super.key});

  @override
  ConsumerState<HairTreatmentsScreen> createState() =>
      _HairTreatmentsScreenState();
}

class _HairTreatmentsScreenState extends ConsumerState<HairTreatmentsScreen> {
  late List<String> _selected;

  static const _treatments = [
    _TreatmentOption(
      label: 'Color / Dye',
      desc: 'Permanent, semi-permanent, or fashion coloring.',
      process: 'Deposits or lifts pigment inside the cortex',
      damageLevel: 'Moderate',
      icon: Icons.palette_rounded,
      color: Color(0xFFF43F5E),
    ),
    _TreatmentOption(
      label: 'Bleach',
      desc: 'Full lightening, highlights, balayage, or ombre.',
      process: 'Dissolves natural melanin — weakens protein bonds',
      damageLevel: 'High',
      icon: Icons.light_mode_rounded,
      color: Color(0xFFF59E0B),
    ),
    _TreatmentOption(
      label: 'Keratin',
      desc: 'Brazilian blowout or smoothing treatment.',
      process: 'Seals the cuticle with bonding proteins and heat',
      damageLevel: 'Low',
      icon: Icons.auto_awesome_rounded,
      color: Color(0xFF8B5CF6),
    ),
    _TreatmentOption(
      label: 'Relaxer',
      desc: 'Chemical straightening or lye-based relaxer.',
      process: 'Permanently breaks and reforms disulfide bonds',
      damageLevel: 'High',
      icon: Icons.horizontal_rule_rounded,
      color: Color(0xFF3B82F6),
    ),
    _TreatmentOption(
      label: 'Perm',
      desc: 'Chemical wave, curl restructuring, or body wave.',
      process: 'Rebuilds curl pattern through oxidation chemistry',
      damageLevel: 'Moderate',
      icon: Icons.refresh_rounded,
      color: Color(0xFFEC4899),
    ),
  ];

  bool get _noneSelected => _selected.contains('None');

  @override
  void initState() {
    super.initState();
    _selected = List.from(ref.read(quizProvider).hairTreatments);
  }

  void _toggle(String v) {
    setState(() {
      if (v == 'None') {
        _selected = _noneSelected ? [] : ['None'];
        return;
      }
      _selected.remove('None');
      _selected.contains(v) ? _selected.remove(v) : _selected.add(v);
    });
  }

  @override
  Widget build(BuildContext context) {
    return QuizScaffold(
      step: 9,
      totalSteps: 10,
      category: 'Hair Profile',
      title: 'Chemical\ntreatments?',
      subtitle: "Treated hair needs special care — we'll flag actives that could cause damage.",
      onBack: () => context.pop(),
      onNext: _selected.isNotEmpty
          ? () {
              ref.read(quizProvider.notifier).setHairTreatments(_selected);
              context.push('/quiz/hair-profile-complete');
            }
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Damage awareness banner
          const _DamageBanner()
              .animate()
              .fadeIn(duration: 350.ms)
              .slideY(begin: 0.1, curve: Curves.easeOutCubic),

          const SizedBox(height: 12),

          // None card
          _NoneCard(
            selected: _noneSelected,
            onTap: () => _toggle('None'),
          )
              .animate()
              .fadeIn(duration: 400.ms, delay: 80.ms)
              .scale(
                begin: const Offset(0.94, 0.94),
                duration: 400.ms,
                delay: 80.ms,
                curve: Curves.easeOutBack,
              ),

          // OR separator
          const _OrSeparator()
              .animate()
              .fadeIn(duration: 300.ms, delay: 160.ms),

          // Treatment cards — dimmed when None is selected
          AnimatedOpacity(
            opacity: _noneSelected ? 0.35 : 1.0,
            duration: const Duration(milliseconds: 280),
            child: IgnorePointer(
              ignoring: _noneSelected,
              child: Column(
                children: List.generate(_treatments.length, (i) {
                  final opt = _treatments[i];
                  return _TreatmentCard(
                    option: opt,
                    selected: _selected.contains(opt.label),
                    onTap: () => _toggle(opt.label),
                  )
                      .animate()
                      .fadeIn(
                        duration: 320.ms,
                        delay: Duration(milliseconds: 50 * i + 200),
                      )
                      .slideY(
                        begin: 0.10,
                        duration: 320.ms,
                        delay: Duration(milliseconds: 50 * i + 200),
                        curve: Curves.easeOutCubic,
                      );
                }),
              ),
            ),
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Data
// ─────────────────────────────────────────────────────────────────────────────

class _TreatmentOption {
  final String label;
  final String desc;
  final String process;
  final String damageLevel;
  final IconData icon;
  final Color color;

  const _TreatmentOption({
    required this.label,
    required this.desc,
    required this.process,
    required this.damageLevel,
    required this.icon,
    required this.color,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Damage awareness banner
// ─────────────────────────────────────────────────────────────────────────────

class _DamageBanner extends StatelessWidget {
  const _DamageBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF59E0B).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.science_rounded,
              size: 18,
              color: Color(0xFFB45309),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              'Treated hair appears as a damage flag in your routine — we recommend bond-repair and protein actives.',
              style: AppTypography.caption.copyWith(
                color: const Color(0xFF92400E),
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// None card — gradient takeover (same pattern as skin_allergies NoneCard)
// ─────────────────────────────────────────────────────────────────────────────

class _NoneCard extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;

  const _NoneCard({required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.success.withValues(alpha: 0.28),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ]
              : AppColors.cardShadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              // White bg
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
              // Gradient bg
              Positioned.fill(
                child: AnimatedOpacity(
                  opacity: selected ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 260),
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
                      ),
                    ),
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 260),
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: selected
                            ? Colors.white.withValues(alpha: 0.22)
                            : AppColors.success.withValues(alpha: 0.10),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.spa_rounded,
                        size: 22,
                        color: selected ? Colors.white : AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'None — Chemically Virgin',
                            style: AppTypography.labelLarge.copyWith(
                              color: selected
                                  ? Colors.white
                                  : const Color(0xFF1E1B4B),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'My hair has not been chemically treated.',
                            style: AppTypography.caption.copyWith(
                              color: selected
                                  ? Colors.white.withValues(alpha: 0.82)
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 240),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selected ? Colors.white : Colors.transparent,
                        border: Border.all(
                          color: selected
                              ? Colors.transparent
                              : const Color(0xFFD8C8FF),
                          width: 2,
                        ),
                      ),
                      child: selected
                          ? const Icon(Icons.check_rounded,
                              color: Color(0xFF16A34A), size: 14)
                          : null,
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
// OR separator
// ─────────────────────────────────────────────────────────────────────────────

class _OrSeparator extends StatelessWidget {
  const _OrSeparator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: const Color(0xFFE8DEFF),
              thickness: 1,
              endIndent: 12,
            ),
          ),
          Text(
            'or select what applies',
            style: AppTypography.caption.copyWith(
              color: AppColors.textTertiary,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Divider(
              color: const Color(0xFFE8DEFF),
              thickness: 1,
              indent: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Treatment card
// ─────────────────────────────────────────────────────────────────────────────

class _TreatmentCard extends StatelessWidget {
  final _TreatmentOption option;
  final bool selected;
  final VoidCallback onTap;

  const _TreatmentCard({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? option.color.withValues(alpha: 0.07)
              : Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? option.color : const Color(0xFFE8DEFF),
            width: selected ? 2.0 : 1.5,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: option.color.withValues(alpha: 0.18),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ]
              : AppColors.cardShadow,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon circle
            AnimatedContainer(
              duration: const Duration(milliseconds: 240),
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: selected
                    ? option.color.withValues(alpha: 0.16)
                    : option.color.withValues(alpha: 0.09),
                shape: BoxShape.circle,
              ),
              child: Icon(
                option.icon,
                size: 21,
                color: option.color,
              ),
            ),

            const SizedBox(width: 13),

            // Text block
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Label + damage badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          option.label,
                          style: AppTypography.labelMedium.copyWith(
                            color: selected
                                ? option.color
                                : const Color(0xFF1E1B4B),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      _DamageBadge(level: option.damageLevel),
                    ],
                  ),

                  const SizedBox(height: 3),

                  Text(
                    option.desc,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.35,
                    ),
                  ),

                  const SizedBox(height: 5),

                  // Process row — "science" detail line
                  Row(
                    children: [
                      Icon(
                        Icons.science_rounded,
                        size: 11,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          option.process,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textTertiary,
                            fontSize: 10.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Square checkbox
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7),
                color: selected ? option.color : Colors.transparent,
                border: Border.all(
                  color: selected ? option.color : const Color(0xFFD8C8FF),
                  width: 2,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 13)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Damage level badge
// ─────────────────────────────────────────────────────────────────────────────

class _DamageBadge extends StatelessWidget {
  final String level;
  const _DamageBadge({required this.level});

  static Color _color(String l) => switch (l) {
    'Low'      => const Color(0xFF22C55E),
    'Moderate' => const Color(0xFFF59E0B),
    'High'     => const Color(0xFFEF4444),
    _          => AppColors.textTertiary,
  };

  @override
  Widget build(BuildContext context) {
    final c = _color(level);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: c.withValues(alpha: 0.24)),
      ),
      child: Text(
        '$level damage',
        style: AppTypography.overline.copyWith(
          color: c,
          fontWeight: FontWeight.w700,
          fontSize: 9.5,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
