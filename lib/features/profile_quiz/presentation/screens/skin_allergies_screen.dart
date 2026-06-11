import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../providers/quiz_provider.dart';
import '_quiz_scaffold.dart';

class SkinAllergiesScreen extends ConsumerStatefulWidget {
  const SkinAllergiesScreen({super.key});

  @override
  ConsumerState<SkinAllergiesScreen> createState() =>
      _SkinAllergiesScreenState();
}

class _SkinAllergiesScreenState extends ConsumerState<SkinAllergiesScreen> {
  late List<String> _selected;

  static const _allergens = [
    _AllergyOption(
      label: 'Fragrance',
      desc: 'Synthetic & natural scents, often hidden.',
      foundIn: 'Serums · Toners · Moisturizers',
      icon: Icons.local_florist_rounded,
      color: Color(0xFFF59E0B),
    ),
    _AllergyOption(
      label: 'Sulfates',
      desc: 'SLS/SLES — harsh foaming agents.',
      foundIn: 'Cleansers · Shampoos · Body Wash',
      icon: Icons.bubble_chart_rounded,
      color: Color(0xFF8B6FEA),
    ),
    _AllergyOption(
      label: 'Parabens',
      desc: 'Preservatives linked to skin sensitivity.',
      foundIn: 'Moisturizers · Makeup · Sunscreen',
      icon: Icons.warning_rounded,
      color: Color(0xFFEF4444),
    ),
    _AllergyOption(
      label: 'Alcohol',
      desc: 'Denatured alcohol — drying for some skin types.',
      foundIn: 'Toners · Serums · Exfoliants',
      icon: Icons.science_rounded,
      color: Color(0xFFF97316),
    ),
    _AllergyOption(
      label: 'Essential Oils',
      desc: 'Concentrated plant extracts (lavender, tea tree).',
      foundIn: 'Natural serums · Facial oils · Balms',
      icon: Icons.eco_rounded,
      color: Color(0xFF22C55E),
    ),
    _AllergyOption(
      label: 'Silicones',
      desc: 'May clog pores in acne-prone skin.',
      foundIn: 'Primers · Foundations · Serums',
      icon: Icons.layers_rounded,
      color: Color(0xFF60A5FA),
    ),
    _AllergyOption(
      label: 'AHA / BHA Acids',
      desc: 'Exfoliating acids — glycolic, salicylic.',
      foundIn: 'Toners · Exfoliants · Treatments',
      icon: Icons.bolt_rounded,
      color: Color(0xFFEC4899),
    ),
    _AllergyOption(
      label: 'Benzoyl Peroxide',
      desc: 'Strong acne treatment, irritating for some.',
      foundIn: 'Spot treatments · Acne cleansers',
      icon: Icons.flash_on_rounded,
      color: Color(0xFF7C3AED),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selected = List.from(ref.read(quizProvider).skinAllergies);
  }

  bool get _noneSelected => _selected.contains('None');

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
      step: 3,
      totalSteps: 10,
      category: 'Skin Profile',
      title: 'Any known\nallergies?',
      subtitle: "We'll flag these automatically whenever you scan a product.",
      onBack: () => context.pop(),
      onNext: _selected.isNotEmpty
          ? () {
              ref.read(quizProvider.notifier).setSkinAllergies(_selected);
              context.push('/quiz/sun-exposure');
            }
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Safety banner ───────────────────────────────────────────────
          _SafetyBanner()
              .animate()
              .fadeIn(duration: 350.ms)
              .slideY(begin: 0.1, curve: Curves.easeOutCubic),

          const SizedBox(height: 14),

          // ── "None Known" escape card ────────────────────────────────────
          _NoneCard(
            selected: _noneSelected,
            onTap: () => _toggle('None'),
          )
              .animate()
              .fadeIn(duration: 380.ms, delay: 80.ms)
              .slideY(begin: 0.12, curve: Curves.easeOutCubic),

          const SizedBox(height: 16),

          // ── "or" separator ──────────────────────────────────────────────
          _OrSeparator()
              .animate()
              .fadeIn(duration: 300.ms, delay: 150.ms),

          const SizedBox(height: 16),

          // ── Allergen cards (dimmed when None selected) ──────────────────
          AnimatedOpacity(
            opacity: _noneSelected ? 0.35 : 1.0,
            duration: const Duration(milliseconds: 280),
            child: IgnorePointer(
              ignoring: _noneSelected,
              child: Column(
                children: List.generate(_allergens.length, (i) {
                  final opt = _allergens[i];
                  return _AllergyCard(
                    option: opt,
                    selected: _selected.contains(opt.label),
                    onTap: () => _toggle(opt.label),
                  )
                      .animate()
                      .fadeIn(
                        duration: 350.ms,
                        delay: Duration(milliseconds: 55 * i + 180),
                      )
                      .slideY(
                        begin: 0.1,
                        duration: 350.ms,
                        delay: Duration(milliseconds: 55 * i + 180),
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
// Safety banner
// ─────────────────────────────────────────────────────────────────────────────

class _SafetyBanner extends StatelessWidget {
  const _SafetyBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFFF59E0B).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shield_rounded,
              size: 17,
              color: Color(0xFFB45309),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Flagged ingredients appear as warnings in every product scan.',
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
// "No Known Allergies" card
// ─────────────────────────────────────────────────────────────────────────────

class _NoneCard extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;

  const _NoneCard({required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF22C55E);
    const greenDark = Color(0xFF16A34A);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: green.withValues(alpha: 0.28),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ]
              : AppColors.cardShadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
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
                        color: green.withValues(alpha: 0.40),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(20),
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
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [green, greenDark],
                      ),
                      borderRadius: BorderRadius.circular(20),
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
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: selected
                            ? Colors.white.withValues(alpha: 0.22)
                            : green.withValues(alpha: 0.10),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.verified_rounded,
                        size: 26,
                        color: selected ? Colors.white : green,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'No Known Allergies',
                            style: AppTypography.labelLarge.copyWith(
                              color: selected
                                  ? Colors.white
                                  : const Color(0xFF1E1B4B),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            "I can use most skincare ingredients safely.",
                            style: AppTypography.caption.copyWith(
                              color: selected
                                  ? Colors.white.withValues(alpha: 0.82)
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
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
                              : green.withValues(alpha: 0.5),
                          width: 2,
                        ),
                      ),
                      child: selected
                          ? const Icon(Icons.check_rounded,
                              color: greenDark, size: 14)
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
// "or" divider
// ─────────────────────────────────────────────────────────────────────────────

class _OrSeparator extends StatelessWidget {
  const _OrSeparator();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: const Color(0xFFE8DEFF),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'or flag specific ingredients',
            style: AppTypography.caption.copyWith(
              color: AppColors.textTertiary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: const Color(0xFFE8DEFF),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Data
// ─────────────────────────────────────────────────────────────────────────────

class _AllergyOption {
  final String label;
  final String desc;
  final String foundIn;
  final IconData icon;
  final Color color;

  const _AllergyOption({
    required this.label,
    required this.desc,
    required this.foundIn,
    required this.icon,
    required this.color,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Allergen card
// ─────────────────────────────────────────────────────────────────────────────

class _AllergyCard extends StatelessWidget {
  final _AllergyOption option;
  final bool selected;
  final VoidCallback onTap;

  const _AllergyCard({
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? option.color.withValues(alpha: 0.08)
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
          children: [
            // Icon circle
            AnimatedContainer(
              duration: const Duration(milliseconds: 240),
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: selected
                    ? option.color.withValues(alpha: 0.18)
                    : option.color.withValues(alpha: 0.09),
                shape: BoxShape.circle,
              ),
              child: Icon(option.icon, size: 21, color: option.color),
            ),

            const SizedBox(width: 13),

            // Text block
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.label,
                    style: AppTypography.labelMedium.copyWith(
                      color: selected
                          ? option.color
                          : const Color(0xFF1E1B4B),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    option.desc,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 5),
                  // "Found in" row
                  Row(
                    children: [
                      Icon(
                        Icons.search_rounded,
                        size: 11,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          option.foundIn,
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

            const SizedBox(width: 10),

            // Checkbox (square for multi-select)
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
                      color: Colors.white, size: 14)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
