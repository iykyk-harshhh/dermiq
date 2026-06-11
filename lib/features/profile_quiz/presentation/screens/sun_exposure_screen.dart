import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../providers/quiz_provider.dart';
import '_quiz_scaffold.dart';

class SunExposureScreen extends ConsumerStatefulWidget {
  const SunExposureScreen({super.key});

  @override
  ConsumerState<SunExposureScreen> createState() => _SunExposureScreenState();
}

class _SunExposureScreenState extends ConsumerState<SunExposureScreen> {
  String? _selected;

  static const _options = [
    _FitzOption(
      type: 'I',
      romanLabel: 'I',
      skinName: 'Very Fair',
      desc: 'Ivory or pale skin, often with freckles. Red or blonde hair, light eyes.',
      spf: 'SPF 50+',
      burnText: 'Always burns severely',
      tanText: 'Never tans',
      burnSevere: true,
      insight:
          'Your skin has the least natural UV protection — daily SPF 50+ is non-negotiable, even on cloudy days.',
      skinTone: Color(0xFFFFDBC8),
      accentColor: Color(0xFFDC2626),
      gradientEnd: Color(0xFFB91C1C),
    ),
    _FitzOption(
      type: 'II',
      romanLabel: 'II',
      skinName: 'Fair',
      desc: 'Light skin, often with blue or green eyes and light to medium hair.',
      spf: 'SPF 50+',
      burnText: 'Burns easily',
      tanText: 'Rarely tans',
      burnSevere: true,
      insight:
          'Reapply SPF every 90 minutes outdoors. Antioxidant serums (Vitamin C) help neutralise UV damage.',
      skinTone: Color(0xFFEBBFA0),
      accentColor: Color(0xFFEA580C),
      gradientEnd: Color(0xFFC2410C),
    ),
    _FitzOption(
      type: 'III',
      romanLabel: 'III',
      skinName: 'Medium',
      desc: 'Light to beige skin. Sometimes burns first, then gradually tans.',
      spf: 'SPF 30-50',
      burnText: 'Sometimes burns',
      tanText: 'Tans gradually',
      burnSevere: false,
      insight:
          'Post-sun niacinamide helps fade tan lines. Keep SPF 30 as your daily minimum year-round.',
      skinTone: Color(0xFFD4956A),
      accentColor: Color(0xFFD97706),
      gradientEnd: Color(0xFFB45309),
    ),
    _FitzOption(
      type: 'IV',
      romanLabel: 'IV',
      skinName: 'Olive',
      desc: 'Light-to-moderate brown skin. Mediterranean, Latino or Middle Eastern origin.',
      spf: 'SPF 30',
      burnText: 'Rarely burns',
      tanText: 'Tans easily',
      burnSevere: false,
      insight:
          'Higher melanin helps but does not block UV-A rays — dark spots and hyperpigmentation are your main risk.',
      skinTone: Color(0xFFC08040),
      accentColor: Color(0xFF16A34A),
      gradientEnd: Color(0xFF15803D),
    ),
    _FitzOption(
      type: 'V',
      romanLabel: 'V',
      skinName: 'Brown',
      desc: 'Dark brown skin. Middle Eastern, South Asian or Latin origin.',
      spf: 'SPF 15-30',
      burnText: 'Very rarely burns',
      tanText: 'Tans profusely',
      burnSevere: false,
      insight:
          'UV-A still degrades collagen — SPF + brightening actives (tranexamic acid) keep post-inflammatory marks at bay.',
      skinTone: Color(0xFF8D5524),
      accentColor: Color(0xFF2563EB),
      gradientEnd: Color(0xFF1D4ED8),
    ),
    _FitzOption(
      type: 'VI',
      romanLabel: 'VI',
      skinName: 'Deep',
      desc: 'Deeply pigmented dark brown or black skin. Never burns in normal exposure.',
      spf: 'SPF 15+',
      burnText: 'Never burns',
      tanText: 'Always deeply tanned',
      burnSevere: false,
      insight:
          'Melanin is protective but not absolute. A light SPF 15-30 guards against photo-ageing and evens tone.',
      skinTone: Color(0xFF4A2912),
      accentColor: Color(0xFF7C3AED),
      gradientEnd: Color(0xFF6D28D9),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selected = ref.read(quizProvider).fitzpatrick;
  }

  @override
  Widget build(BuildContext context) {
    return QuizScaffold(
      step: 4,
      totalSteps: 10,
      category: 'Skin Profile',
      title: 'How does your\nskin react to sun?',
      subtitle: "We'll personalise your UV protection and SPF recommendations.",
      onBack: () => context.pop(),
      onNext: _selected != null
          ? () {
              ref.read(quizProvider.notifier).setFitzpatrick(_selected!);
              context.push('/quiz/skin-profile-complete');
            }
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _UVBanner()
              .animate()
              .fadeIn(duration: 350.ms)
              .slideY(begin: 0.1, curve: Curves.easeOutCubic),

          const SizedBox(height: 10),

          _ToneScale(
            options: _options,
            selectedType: _selected,
            onTap: (t) => setState(() => _selected = t),
          )
              .animate()
              .fadeIn(duration: 400.ms, delay: 80.ms)
              .slideY(begin: 0.08, curve: Curves.easeOutCubic),

          const SizedBox(height: 14),

          ...List.generate(_options.length, (i) {
            final opt = _options[i];
            return _FitzCard(
              option: opt,
              selected: _selected == opt.type,
              onTap: () => setState(() => _selected = opt.type),
            )
                .animate()
                .fadeIn(
                  duration: 330.ms,
                  delay: Duration(milliseconds: 50 * i + 160),
                )
                .scale(
                  begin: const Offset(0.92, 0.92),
                  end: const Offset(1.0, 1.0),
                  duration: 330.ms,
                  delay: Duration(milliseconds: 50 * i + 160),
                  curve: Curves.easeOutBack,
                );
          }),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _FitzOption {
  final String type;
  final String romanLabel;
  final String skinName;
  final String desc;
  final String spf;
  final String burnText;
  final String tanText;
  final bool burnSevere;
  final String insight;
  final Color skinTone;
  final Color accentColor;
  final Color gradientEnd;

  const _FitzOption({
    required this.type,
    required this.romanLabel,
    required this.skinName,
    required this.desc,
    required this.spf,
    required this.burnText,
    required this.tanText,
    required this.burnSevere,
    required this.insight,
    required this.skinTone,
    required this.accentColor,
    required this.gradientEnd,
  });
}

class _UVBanner extends StatelessWidget {
  const _UVBanner();

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
              Icons.wb_sunny_rounded,
              size: 18,
              color: Color(0xFFB45309),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fitzpatrick Scale',
                  style: AppTypography.labelSmall.copyWith(
                    color: const Color(0xFF92400E),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'A dermatology standard classifying how skin responds to UV. Used to personalise your SPF and treatment recommendations.',
                  style: AppTypography.caption.copyWith(
                    color: const Color(0xFF92400E).withValues(alpha: 0.80),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ToneScale extends StatelessWidget {
  final List<_FitzOption> options;
  final String? selectedType;
  final ValueChanged<String> onTap;

  const _ToneScale({
    required this.options,
    required this.selectedType,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
        border: Border.all(color: const Color(0xFFE8DEFF), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Tap the swatch closest to your skin tone',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween(
                      begin: const Offset(0.2, 0),
                      end: Offset.zero,
                    ).animate(anim),
                    child: child,
                  ),
                ),
                child: selectedType != null
                    ? Container(
                        key: ValueKey('badge_$selectedType'),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: AppColors.gradientPrimary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Type $selectedType',
                          style: AppTypography.overline.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 10,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(key: ValueKey('badge_none')),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: options.map((opt) {
              final sel = opt.type == selectedType;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(opt.type),
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        width: sel ? 42 : 34,
                        height: sel ? 42 : 34,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: opt.skinTone,
                          border: Border.all(
                            color: sel ? opt.accentColor : Colors.white,
                            width: sel ? 3 : 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: sel
                                  ? opt.accentColor.withValues(alpha: 0.40)
                                  : opt.skinTone.withValues(alpha: 0.35),
                              blurRadius: sel ? 12 : 4,
                              spreadRadius: sel ? 1 : 0,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: AppTypography.overline.copyWith(
                          color: sel ? opt.accentColor : AppColors.textTertiary,
                          fontWeight: sel ? FontWeight.w800 : FontWeight.w500,
                          fontSize: 9.5,
                        ),
                        child: Text(opt.romanLabel, textAlign: TextAlign.center),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _FitzCard extends StatelessWidget {
  final _FitzOption option;
  final bool selected;
  final VoidCallback onTap;

  const _FitzCard({
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
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: option.accentColor.withValues(alpha: 0.26),
                    blurRadius: 20,
                    offset: const Offset(0, 7),
                  ),
                ]
              : AppColors.cardShadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Positioned.fill(
                child: AnimatedOpacity(
                  opacity: selected ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 260),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.90),
                      border: Border.all(
                        color: const Color(0xFFE8DEFF),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: AnimatedOpacity(
                  opacity: selected ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 260),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [option.accentColor, option.gradientEnd],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SkinSwatch(option: option, selected: selected),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Text(
                                      option.skinName,
                                      style: AppTypography.labelLarge.copyWith(
                                        color: selected
                                            ? Colors.white
                                            : const Color(0xFF1E1B4B),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  _SpfBadge(
                                    spf: option.spf,
                                    color: option.accentColor,
                                    selected: selected,
                                  ),
                                  const SizedBox(width: 8),
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 240),
                                    width: 22,
                                    height: 22,
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
                                            color: option.accentColor, size: 13)
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
                              _BurnTanRow(
                                burnText: option.burnText,
                                tanText: option.tanText,
                                burnSevere: option.burnSevere,
                                selected: selected,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
                                Icons.wb_sunny_rounded,
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

class _SkinSwatch extends StatelessWidget {
  final _FitzOption option;
  final bool selected;

  const _SkinSwatch({required this.option, required this.selected});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 54,
      height: 54,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: option.skinTone,
              border: Border.all(
                color: selected
                    ? Colors.white.withValues(alpha: 0.5)
                    : Colors.white,
                width: 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: option.skinTone.withValues(alpha: 0.45),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: -2,
            right: -4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withValues(alpha: 0.90)
                    : option.accentColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: selected ? Colors.transparent : Colors.white,
                  width: 1,
                ),
              ),
              child: Text(
                option.romanLabel,
                style: AppTypography.overline.copyWith(
                  color: selected ? option.accentColor : Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 9,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpfBadge extends StatelessWidget {
  final String spf;
  final Color color;
  final bool selected;

  const _SpfBadge({
    required this.spf,
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
      child: Text(
        spf,
        style: AppTypography.overline.copyWith(
          color: selected ? Colors.white : color,
          fontWeight: FontWeight.w700,
          fontSize: 9.5,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _BurnTanRow extends StatelessWidget {
  final String burnText;
  final String tanText;
  final bool burnSevere;
  final bool selected;

  const _BurnTanRow({
    required this.burnText,
    required this.tanText,
    required this.burnSevere,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final sepColor =
        selected ? Colors.white.withValues(alpha: 0.55) : AppColors.textTertiary;
    final burnColor = selected
        ? Colors.white.withValues(alpha: 0.90)
        : (burnSevere ? const Color(0xFFEF4444) : const Color(0xFF22C55E));
    final tanColor =
        selected ? Colors.white.withValues(alpha: 0.85) : AppColors.textTertiary;

    return Row(
      children: [
        Text(
          'Burns: ',
          style: AppTypography.caption.copyWith(
            color: sepColor,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        Flexible(
          child: Text(
            burnText,
            style: AppTypography.caption.copyWith(
              color: burnColor,
              fontWeight: FontWeight.w600,
              fontSize: 10.5,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text('  ·  ',
            style: AppTypography.caption.copyWith(color: sepColor)),
        Flexible(
          child: Text(
            tanText,
            style: AppTypography.caption.copyWith(
              color: tanColor,
              fontSize: 10.5,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
