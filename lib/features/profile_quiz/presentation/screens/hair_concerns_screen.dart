import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../providers/quiz_provider.dart';
import '_quiz_scaffold.dart';

class HairConcernsScreen extends ConsumerStatefulWidget {
  const HairConcernsScreen({super.key});

  @override
  ConsumerState<HairConcernsScreen> createState() => _HairConcernsScreenState();
}

class _HairConcernsScreenState extends ConsumerState<HairConcernsScreen> {
  late List<String> _selected;

  static const _options = [
    _HairConcernOption(
      label: 'Hair Fall',
      shortDesc: 'Excessive shedding',
      icon: Icons.arrow_downward_rounded,
      color: Color(0xFFF43F5E),
    ),
    _HairConcernOption(
      label: 'Dandruff',
      shortDesc: 'Flakes & itch',
      icon: Icons.grain_rounded,
      color: Color(0xFFF59E0B),
    ),
    _HairConcernOption(
      label: 'Frizz',
      shortDesc: 'Poofy texture',
      icon: Icons.air_rounded,
      color: Color(0xFF8B5CF6),
    ),
    _HairConcernOption(
      label: 'Thinning',
      shortDesc: 'Low density',
      icon: Icons.unfold_less_rounded,
      color: Color(0xFF3B82F6),
    ),
    _HairConcernOption(
      label: 'Damage',
      shortDesc: 'Breakage & splits',
      icon: Icons.bolt_rounded,
      color: Color(0xFFF97316),
    ),
    _HairConcernOption(
      label: 'Dryness',
      shortDesc: 'Brittle, thirsty',
      icon: Icons.opacity_rounded,
      color: Color(0xFF0EA5E9),
    ),
    _HairConcernOption(
      label: 'Oiliness',
      shortDesc: 'Greasy roots fast',
      icon: Icons.water_drop_rounded,
      color: Color(0xFF06B6D4),
    ),
    _HairConcernOption(
      label: 'Slow Growth',
      shortDesc: 'Growth plateau',
      icon: Icons.show_chart_rounded,
      color: Color(0xFF10B981),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selected = List.from(ref.read(quizProvider).hairConcerns);
  }

  void _toggle(String v) => setState(() {
        _selected.contains(v) ? _selected.remove(v) : _selected.add(v);
      });

  void _clearAll() => setState(() => _selected.clear());

  @override
  Widget build(BuildContext context) {
    return QuizScaffold(
      step: 8,
      totalSteps: 10,
      category: 'Hair Profile',
      title: 'Any hair\nconcerns?',
      subtitle: "Select all that apply — we'll target each one in your hair routine.",
      onBack: () => context.pop(),
      onNext: _selected.isNotEmpty
          ? () {
              ref.read(quizProvider.notifier).setHairConcerns(_selected);
              context.push('/quiz/hair-treatments');
            }
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selection status bar
          _SelectionHeader(
            count: _selected.length,
            onClear: _selected.isNotEmpty ? _clearAll : null,
          ).animate().fadeIn(duration: 300.ms),

          const SizedBox(height: 14),

          // 2-column concern grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              mainAxisExtent: 148,
            ),
            itemCount: _options.length,
            itemBuilder: (_, i) {
              final opt = _options[i];
              return _HairConcernCard(
                option: opt,
                selected: _selected.contains(opt.label),
                onTap: () => _toggle(opt.label),
              )
                  .animate()
                  .fadeIn(
                    duration: 350.ms,
                    delay: Duration(milliseconds: 45 * i),
                  )
                  .scale(
                    begin: const Offset(0.88, 0.88),
                    end: const Offset(1.0, 1.0),
                    duration: 350.ms,
                    delay: Duration(milliseconds: 45 * i),
                    curve: Curves.easeOutBack,
                  );
            },
          ),

          const SizedBox(height: 16),

          // Tip card — appears at >= 3 selections
          _TipCard(
            visible: _selected.length >= 3,
          ).animate().fadeIn(duration: 400.ms, delay: 400.ms),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Data
// ─────────────────────────────────────────────────────────────────────────────

class _HairConcernOption {
  final String label;
  final String shortDesc;
  final IconData icon;
  final Color color;

  const _HairConcernOption({
    required this.label,
    required this.shortDesc,
    required this.icon,
    required this.color,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Selection status header
// ─────────────────────────────────────────────────────────────────────────────

class _SelectionHeader extends StatelessWidget {
  final int count;
  final VoidCallback? onClear;

  const _SelectionHeader({required this.count, this.onClear});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween(
                begin: const Offset(0, 0.3),
                end: Offset.zero,
              ).animate(anim),
              child: child,
            ),
          ),
          child: count == 0
              ? Row(
                  key: const ValueKey('hint'),
                  children: [
                    Icon(Icons.info_outline_rounded,
                        size: 14, color: AppColors.textTertiary),
                    const SizedBox(width: 6),
                    Text(
                      'Select all that apply',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                )
              : Row(
                  key: ValueKey('count_$count'),
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        gradient: AppColors.gradientPrimary,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_rounded,
                              size: 12, color: Colors.white),
                          const SizedBox(width: 5),
                          Text(
                            '$count concern${count == 1 ? '' : 's'} selected',
                            style: AppTypography.labelSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
        const Spacer(),
        if (onClear != null)
          GestureDetector(
            onTap: onClear,
            child: Text(
              'Clear all',
              style: AppTypography.caption.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ).animate().fadeIn(duration: 200.ms),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tip card — appears after >= 3 selections
// ─────────────────────────────────────────────────────────────────────────────

class _TipCard extends StatelessWidget {
  final bool visible;
  const _TipCard({required this.visible});

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 320),
      sizeCurve: Curves.easeInOut,
      crossFadeState:
          visible ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      firstChild: const SizedBox(width: double.infinity),
      secondChild: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.14),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.auto_awesome_rounded,
                size: 15, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Great! Multiple concerns help us build a multi-step hair routine that actually works.',
                style: AppTypography.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Concern grid card
// ─────────────────────────────────────────────────────────────────────────────

class _HairConcernCard extends StatelessWidget {
  final _HairConcernOption option;
  final bool selected;
  final VoidCallback onTap;

  const _HairConcernCard({
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
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: selected
              ? option.color.withValues(alpha: 0.09)
              : Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? option.color : const Color(0xFFE8DEFF),
            width: selected ? 2.0 : 1.5,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: option.color.withValues(alpha: 0.22),
                    blurRadius: 16,
                    offset: const Offset(0, 5),
                  ),
                ]
              : AppColors.cardShadow,
        ),
        child: Stack(
          children: [
            // Square checkbox — top right
            Positioned(
              top: 10,
              right: 10,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
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
            ),

            // Centered content
            Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 16, 10, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon circle
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 240),
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: selected
                            ? option.color.withValues(alpha: 0.20)
                            : option.color.withValues(alpha: 0.09),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        option.icon,
                        size: 24,
                        color: option.color,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Label
                    Text(
                      option.label,
                      textAlign: TextAlign.center,
                      style: AppTypography.labelMedium.copyWith(
                        color: selected
                            ? option.color
                            : const Color(0xFF1E1B4B),
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 3),

                    // Short description
                    Text(
                      option.shortDesc,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textTertiary,
                        fontSize: 10.5,
                        height: 1.3,
                      ),
                    ),
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
