import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/diq_logo.dart';
import '../../../../core/services/preferences_service.dart';
import '../../providers/quiz_provider.dart';

class SkinProfileCompleteScreen extends ConsumerStatefulWidget {
  const SkinProfileCompleteScreen({super.key});

  @override
  ConsumerState<SkinProfileCompleteScreen> createState() =>
      _SkinProfileCompleteScreenState();
}

class _SkinProfileCompleteScreenState
    extends ConsumerState<SkinProfileCompleteScreen>
    with TickerProviderStateMixin {
  late final AnimationController _ringCtrl;
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _ringCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ringCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quiz = ref.watch(quizProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF2EDFF),
              Color(0xFFE8DEFF),
              Color(0xFFD8C8FF),
              Color(0xFFCCB8F5),
            ],
            stops: [0.0, 0.3, 0.65, 1.0],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
            children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const DiqLogo(size: DiqLogoSize.small),
                  ],
                ),
              ),

              const Spacer(flex: 1),

              // Animated hero
              AnimatedBuilder(
                animation: Listenable.merge([_ringCtrl, _pulseCtrl]),
                builder: (_, _) => _CelebrationHero(
                  ringValue: _ringCtrl.value,
                  pulseValue: _pulseCtrl.value,
                ),
              ),

              const SizedBox(height: 28),

              // Title
              Text(
                'Skin Profile\nComplete!',
                style: AppTypography.display.copyWith(
                  color: const Color(0xFF1E1B4B),
                  height: 1.1,
                ),
                textAlign: TextAlign.center,
              )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 280.ms)
                  .slideY(begin: 0.12, curve: Curves.easeOutCubic),

              const SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  "Your skin persona is ready. Now let's map your hair profile to complete your DermIQ experience.",
                  style: AppTypography.bodyMedium.copyWith(
                    color: const Color(0xFF6B7280),
                    height: 1.55,
                  ),
                  textAlign: TextAlign.center,
                ),
              ).animate().fadeIn(duration: 500.ms, delay: 380.ms),

              const SizedBox(height: 18),

              // Progress chip
              const _ProgressChip()
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 460.ms)
                  .scale(
                    begin: const Offset(0.86, 0.86),
                    curve: Curves.easeOutBack,
                  ),

              const SizedBox(height: 20),

              // Summary card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _ProfileSummaryCard(quiz: quiz),
              )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 540.ms)
                  .slideY(begin: 0.10, curve: Curves.easeOutCubic),

              const Spacer(flex: 2),

              // Buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                child: Column(
                  children: [
                    AppButton(
                      label: 'Continue: Hair Profile',
                      onPressed: () => context.go('/quiz/hair-type'),
                      icon: const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ).animate().fadeIn(duration: 400.ms, delay: 660.ms),
                    const SizedBox(height: 12),
                    AppButton(
                      label: 'Skip for now',
                      onPressed: () {
                        // Skipping still counts as "quizzes shown" — never reshow.
                        PreferencesService.setProfileComplete(true);
                        ref.read(profileCompleteProvider.notifier).state = true;
                        context.go('/home');
                      },
                      isOutlined: true,
                    ).animate().fadeIn(duration: 400.ms, delay: 720.ms),
                  ],
                ),
              ),

              const SizedBox(height: 28),
            ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Animated celebration hero
// ─────────────────────────────────────────────────────────────────────────────

class _CelebrationHero extends StatelessWidget {
  final double ringValue;
  final double pulseValue;

  const _CelebrationHero({
    required this.ringValue,
    required this.pulseValue,
  });

  static double _ringScale(double v, double start) {
    final t = ((v - start) / (1.0 - start)).clamp(0.0, 1.0);
    return Curves.elasticOut.transform(t);
  }

  @override
  Widget build(BuildContext context) {
    final s1 = _ringScale(ringValue, 0.0);
    final s2 = _ringScale(ringValue, 0.10);
    final s3 = _ringScale(ringValue, 0.20);
    final badgeScale = Curves.elasticOut.transform(ringValue.clamp(0.0, 1.0));
    final glowAlpha = 0.20 + pulseValue * 0.18;
    final glowBlur = 20.0 + pulseValue * 16.0;

    return SizedBox(
      width: 176,
      height: 176,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer ring
          Transform.scale(
            scale: s3,
            child: Container(
              width: 172,
              height: 172,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.09),
                  width: 1.0,
                ),
              ),
            ),
          ),
          // Middle ring
          Transform.scale(
            scale: s2,
            child: Container(
              width: 136,
              height: 136,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.16),
                  width: 1.5,
                ),
              ),
            ),
          ),
          // Inner ring
          Transform.scale(
            scale: s1,
            child: Container(
              width: 106,
              height: 106,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.28),
                  width: 2.0,
                ),
              ),
            ),
          ),
          // Center badge
          Transform.scale(
            scale: badgeScale,
            child: Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                gradient: AppColors.gradientPrimary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: glowAlpha),
                    blurRadius: glowBlur,
                    spreadRadius: 3,
                  ),
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.face_retouching_natural_rounded,
                color: Colors.white,
                size: 42,
              ),
            ),
          ),
          // Accent dot — top right of outer ring
          _CornerDot(
            left: 148,
            top: 10,
            delay: 0.52,
            ringValue: ringValue,
            color: const Color(0xFFA78BFA),
          ),
          // Accent dot — bottom left
          _CornerDot(
            left: 8,
            top: 148,
            delay: 0.60,
            ringValue: ringValue,
            color: const Color(0xFF7C5CFF),
          ),
          // Accent dot — top left
          _CornerDot(
            left: 12,
            top: 18,
            delay: 0.56,
            ringValue: ringValue,
            color: AppColors.lavender,
          ),
        ],
      ),
    );
  }
}

class _CornerDot extends StatelessWidget {
  final double left;
  final double top;
  final double delay;
  final double ringValue;
  final Color color;

  const _CornerDot({
    required this.left,
    required this.top,
    required this.delay,
    required this.ringValue,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final t = ((ringValue - delay) / (1.0 - delay)).clamp(0.0, 1.0);
    final scale = Curves.easeOutBack.transform(t);

    return Positioned(
      left: left,
      top: top,
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: 11,
          height: 11,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.40),
                blurRadius: 6,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Progress chip
// ─────────────────────────────────────────────────────────────────────────────

class _ProgressChip extends StatelessWidget {
  const _ProgressChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              gradient: AppColors.gradientPrimary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded, size: 11, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Text(
            'Step 4 of 10  ·  Skin Profile Done',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Profile summary card
// ─────────────────────────────────────────────────────────────────────────────

class _ProfileSummaryCard extends StatelessWidget {
  final QuizState quiz;
  const _ProfileSummaryCard({required this.quiz});

  static Color _skinTypeColor(String? type) => switch (type) {
    'Oily'        => const Color(0xFF3B82F6),
    'Dry'         => const Color(0xFFF97316),
    'Combination' => const Color(0xFF8B6FEA),
    'Normal'      => const Color(0xFF22C55E),
    'Sensitive'   => const Color(0xFFEC4899),
    _             => AppColors.primary,
  };

  @override
  Widget build(BuildContext context) {
    final skinColor = _skinTypeColor(quiz.skinType);

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.cardShadow,
        border: Border.all(color: const Color(0xFFE8DEFF), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  gradient: AppColors.gradientPrimary,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.assignment_turned_in_rounded,
                  size: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Your Skin Profile',
                style: AppTypography.labelMedium.copyWith(
                  color: const Color(0xFF1E1B4B),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Complete',
                  style: AppTypography.overline.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(color: Color(0xFFF0EDFF), height: 1),
          const SizedBox(height: 14),

          // Skin type
          _SummarySection(
            icon: Icons.water_drop_rounded,
            iconColor: skinColor,
            label: 'Skin Type',
            child: quiz.skinType != null
                ? _SingleChip(label: quiz.skinType!, color: skinColor)
                : const _EmptyChip(),
          ),

          const SizedBox(height: 12),

          // Concerns
          _SummarySection(
            icon: Icons.manage_search_rounded,
            iconColor: AppColors.primary,
            label: 'Concerns',
            child: quiz.skinConcerns.isEmpty
                ? const _EmptyChip()
                : _ChipRow(
                    items: quiz.skinConcerns,
                    color: AppColors.primary,
                  ),
          ),

          const SizedBox(height: 12),

          // Allergies
          _SummarySection(
            icon: Icons.shield_rounded,
            iconColor: const Color(0xFFF59E0B),
            label: 'Allergies',
            child: (quiz.skinAllergies.isEmpty ||
                    (quiz.skinAllergies.length == 1 &&
                        quiz.skinAllergies.first == 'None'))
                ? _SingleChip(label: 'None', color: AppColors.success)
                : _ChipRow(
                    items: quiz.skinAllergies,
                    color: const Color(0xFFF59E0B),
                  ),
          ),

          const SizedBox(height: 12),

          // Fitzpatrick / UV Type
          _SummarySection(
            icon: Icons.wb_sunny_rounded,
            iconColor: const Color(0xFFD97706),
            label: 'UV Type',
            child: quiz.fitzpatrick != null
                ? _FitzChip(type: quiz.fitzpatrick!)
                : const _EmptyChip(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Summary section row
// ─────────────────────────────────────────────────────────────────────────────

class _SummarySection extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final Widget child;

  const _SummarySection({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.textTertiary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Chip variants
// ─────────────────────────────────────────────────────────────────────────────

class _ChipRow extends StatelessWidget {
  final List<String> items;
  final Color color;

  const _ChipRow({required this.items, required this.color});

  @override
  Widget build(BuildContext context) {
    final show = items.take(2).toList();
    final overflow = items.length - show.length;

    return Wrap(
      spacing: 5,
      runSpacing: 4,
      children: [
        ...show.map((item) => _MiniChip(label: item, color: color)),
        if (overflow > 0)
          _MiniChip(label: '+$overflow', color: color, faint: true),
      ],
    );
  }
}

class _SingleChip extends StatelessWidget {
  final String label;
  final Color color;

  const _SingleChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool faint;

  const _MiniChip({required this.label, required this.color, this.faint = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: faint
            ? color.withValues(alpha: 0.05)
            : color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: faint ? 0.12 : 0.20),
        ),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: faint ? AppColors.textTertiary : color,
          fontWeight: FontWeight.w600,
          fontSize: 10.5,
        ),
      ),
    );
  }
}

class _EmptyChip extends StatelessWidget {
  const _EmptyChip();

  @override
  Widget build(BuildContext context) {
    return Text(
      '—',
      style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Fitzpatrick chip — skin tone swatch + type label
// ─────────────────────────────────────────────────────────────────────────────

class _FitzChip extends StatelessWidget {
  final String type;
  const _FitzChip({required this.type});

  static (Color, Color, String)? _info(String t) => switch (t) {
    'I'   => (const Color(0xFFFFDBC8), const Color(0xFFDC2626), 'Very Fair'),
    'II'  => (const Color(0xFFEBBFA0), const Color(0xFFEA580C), 'Fair'),
    'III' => (const Color(0xFFD4956A), const Color(0xFFD97706), 'Medium'),
    'IV'  => (const Color(0xFFC08040), const Color(0xFF16A34A), 'Olive'),
    'V'   => (const Color(0xFF8D5524), const Color(0xFF2563EB), 'Brown'),
    'VI'  => (const Color(0xFF4A2912), const Color(0xFF7C3AED), 'Deep'),
    _     => null,
  };

  @override
  Widget build(BuildContext context) {
    final info = _info(type);
    if (info == null) return const _EmptyChip();
    final (skinTone, accent, skinName) = info;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: skinTone,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: skinTone.withValues(alpha: 0.50),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        const SizedBox(width: 7),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: accent.withValues(alpha: 0.22)),
          ),
          child: Text(
            'Type $type  $skinName',
            style: AppTypography.caption.copyWith(
              color: accent,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }
}
