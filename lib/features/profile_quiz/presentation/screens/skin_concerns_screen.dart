import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../providers/quiz_provider.dart';
import '_quiz_scaffold.dart';

class SkinConcernsScreen extends ConsumerStatefulWidget {
  const SkinConcernsScreen({super.key});

  @override
  ConsumerState<SkinConcernsScreen> createState() => _SkinConcernsScreenState();
}

class _SkinConcernsScreenState extends ConsumerState<SkinConcernsScreen> {
  late List<String> _selected;

  static const _options = [
    _ConcernOption(
      label: 'Acne',
      shortDesc: 'Breakouts & pimples',
      icon: Icons.bubble_chart_rounded,
      color: Color(0xFFF43F5E),
    ),
    _ConcernOption(
      label: 'Dark Spots',
      shortDesc: 'Uneven skin tone',
      icon: Icons.blur_on_rounded,
      color: Color(0xFFB45309),
    ),
    _ConcernOption(
      label: 'Fine Lines',
      shortDesc: 'Wrinkles & aging',
      icon: Icons.linear_scale_rounded,
      color: Color(0xFF7C5CFF),
    ),
    _ConcernOption(
      label: 'Redness',
      shortDesc: 'Flushing & irritation',
      icon: Icons.favorite_rounded,
      color: Color(0xFFEF4444),
    ),
    _ConcernOption(
      label: 'Dullness',
      shortDesc: 'Lack of radiance',
      icon: Icons.nights_stay_rounded,
      color: Color(0xFFD97706),
    ),
    _ConcernOption(
      label: 'Large Pores',
      shortDesc: 'Visible pore size',
      icon: Icons.apps_rounded,
      color: Color(0xFF3B82F6),
    ),
    _ConcernOption(
      label: 'Dehydration',
      shortDesc: 'Thirsty, tight skin',
      icon: Icons.opacity_rounded,
      color: Color(0xFF0EA5E9),
    ),
    _ConcernOption(
      label: 'Texture',
      shortDesc: 'Rough or bumpy skin',
      icon: Icons.tune_rounded,
      color: Color(0xFF8B5CF6),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selected = List.from(ref.read(quizProvider).skinConcerns);
  }

  void _toggle(String v) => setState(() {
        _selected.contains(v) ? _selected.remove(v) : _selected.add(v);
      });

  void _clearAll() => setState(() => _selected.clear());

  @override
  Widget build(BuildContext context) {
    return QuizScaffold(
      step: 2,
      totalSteps: 10,
      category: 'Skin Profile',
      title: 'Any skin\nconcerns?',
      subtitle: 'Select all that apply — we\'ll target these in your routine.',
      onBack: () => context.pop(),
      onNext: _selected.isNotEmpty
          ? () {
              ref.read(quizProvider.notifier).setSkinConcerns(_selected);
              context.push('/quiz/skin-allergies');
            }
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Selection status bar ────────────────────────────────────────
          _SelectionHeader(
            count: _selected.length,
            onClear: _selected.isNotEmpty ? _clearAll : null,
          ).animate().fadeIn(duration: 300.ms),

          const SizedBox(height: 14),

          // ── 2-column concern grid ───────────────────────────────────────
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
              return _ConcernCard(
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

          // ── Tip card ─────────────────────────────────────────────────────
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
                        size: 14,
                        color: AppColors.textTertiary),
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
// Tip card — appears after ≥3 selections
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
                'Great! More concerns = more personalized your routine becomes.',
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
// Data
// ─────────────────────────────────────────────────────────────────────────────

class _ConcernOption {
  final String label;
  final String shortDesc;
  final IconData icon;
  final Color color;

  const _ConcernOption({
    required this.label,
    required this.shortDesc,
    required this.icon,
    required this.color,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Concern grid card
// ─────────────────────────────────────────────────────────────────────────────

class _ConcernCard extends StatelessWidget {
  final _ConcernOption option;
  final bool selected;
  final VoidCallback onTap;

  const _ConcernCard({
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
            // ── Checkbox — top right ──────────────────────────────────────
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
                    color:
                        selected ? option.color : const Color(0xFFD8C8FF),
                    width: 2,
                  ),
                ),
                child: selected
                    ? const Icon(Icons.check_rounded,
                        color: Colors.white, size: 13)
                    : null,
              ),
            ),

            // ── Centered content ──────────────────────────────────────────
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
