import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/dermiq_colors.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../shop/providers/cart_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scoreCtrl;
  late final Animation<double> _scoreAnim;

  static const _score = 82;

  @override
  void initState() {
    super.initState();
    _scoreCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();
    _scoreAnim = Tween<double>(begin: 0, end: _score / 100.0).animate(
      CurvedAnimation(parent: _scoreCtrl, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _scoreCtrl.dispose();
    super.dispose();
  }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    if (h < 21) return 'Good evening';
    return 'Good night';
  }

  static String _scoreLevel(int s) {
    if (s <= 20) return 'Needs Attention';
    if (s <= 40) return 'Getting Started';
    if (s <= 60) return 'Improving';
    if (s <= 80) return 'Healthy';
    return 'Excellent';
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider);
    final firstName = user?.displayName?.split(' ').first ?? 'Sarah';

    return Scaffold(
      backgroundColor: context.dColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Sticky glassmorphism header ───────────────────────────────────
          SliverAppBar(
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            pinned: true,
            floating: false,
            toolbarHeight: 60,
            flexibleSpace: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  color: context.dColors.background.withValues(alpha: 0.90),
                  height: double.infinity,
                ),
              ),
            ),
            leading: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: _AvatarButton(
                initial: firstName.substring(0, 1).toUpperCase(),
              ),
            ),
            title: const _WordmarkLogo(),
            centerTitle: true,
            actions: [
              _CartButton(onTap: () => context.push('/cart')),
              const SizedBox(width: 4),
              _NotificationButton(
                hasUnread: true,
                onTap: () => context.push('/notifications'),
              ),
              const SizedBox(width: 12),
            ],
          ),

          // ── Content ───────────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.screenPaddingH,
              12,
              AppConstants.screenPaddingH,
              100,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // 1 — Greeting
                _GreetingRow(greeting: _greeting, name: firstName)
                    .animate()
                    .fadeIn(duration: 380.ms)
                    .slideY(begin: 0.08, curve: Curves.easeOutCubic),

                const SizedBox(height: AppConstants.sp20),

                // 2 — DermIQ Health Score
                AnimatedBuilder(
                  animation: _scoreAnim,
                  builder: (_, _) {
                    final currentScore = (_score * _scoreAnim.value).round();
                    return _HealthScoreHeroCard(
                      progress: _scoreAnim.value,
                      score: currentScore,
                      level: _scoreLevel(currentScore),
                      onViewAnalysis: () => context.push('/analysis'),
                    );
                  },
                )
                    .animate()
                    .fadeIn(duration: 460.ms, delay: 60.ms)
                    .slideY(begin: 0.08, curve: Curves.easeOutCubic),

                const SizedBox(height: AppConstants.sp20),

                // 3 — Appointment Card
                _AppointmentSection(
                  onDermatologist: () =>
                      context.push('/specialist', extra: 'Dermatologist'),
                  onTrichologist: () =>
                      context.push('/specialist', extra: 'Trichologist'),
                )
                    .animate()
                    .fadeIn(duration: 380.ms, delay: 90.ms)
                    .slideY(begin: 0.08, curve: Curves.easeOutCubic),

                const SizedBox(height: AppConstants.sp20),

                // 4 — Today's Routine
                _SectionHeader(
                  title: "Today's Routine",
                  action: 'View all',
                  onAction: () => context.go('/routine'),
                ).animate().fadeIn(duration: 340.ms, delay: 140.ms),

                const SizedBox(height: AppConstants.sp12),

                _TodaysRoutineRow(onViewAll: () => context.go('/routine'))
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 180.ms)
                    .slideX(begin: 0.04, curve: Curves.easeOutCubic),

                const SizedBox(height: AppConstants.sp20),

                // 5 — Analyze
                _AnalyzeCTACard(onTap: () => context.go('/analyze'))
                    .animate()
                    .fadeIn(duration: 380.ms, delay: 220.ms)
                    .slideY(begin: 0.06, curve: Curves.easeOutCubic),

                const SizedBox(height: AppConstants.sp12),

                // 6 — Shop
                _ShopCTACard(onTap: () => context.go('/shelf'))
                    .animate()
                    .fadeIn(duration: 380.ms, delay: 260.ms)
                    .slideY(begin: 0.06, curve: Curves.easeOutCubic),

                const SizedBox(height: AppConstants.sp20),

                // 7 — Insights
                _AiInsightCard(onTap: () => context.push('/chat'))
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 300.ms)
                    .slideY(begin: 0.06, curve: Curves.easeOutCubic),

                const SizedBox(height: AppConstants.sp20),

                // 8 — Recommendations
                _SectionHeader(
                  title: 'Recommendations',
                  action: 'See all',
                  onAction: () => context.push('/chat'),
                ).animate().fadeIn(duration: 340.ms, delay: 340.ms),

                const SizedBox(height: AppConstants.sp12),

                const _RecommendationsRow()
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 380.ms)
                    .slideX(begin: 0.04, curve: Curves.easeOutCubic),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// App bar widgets
// ─────────────────────────────────────────────────────────────────────────────

class _WordmarkLogo extends StatelessWidget {
  const _WordmarkLogo();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text('derm',
            style: AppTypography.h4.copyWith(
              color: context.dColors.textPrimary,
              fontWeight: FontWeight.w700,
            )),
        Stack(
          clipBehavior: Clip.none,
          children: [
            Text('i',
                style: AppTypography.h4.copyWith(
                  color: context.dColors.textPrimary,
                  fontWeight: FontWeight.w700,
                )),
            Positioned(
              top: -6,
              left: 0,
              child: Text(
                AppConstants.brandStar,
                style: AppTypography.caption
                    .copyWith(color: AppColors.primary, fontSize: 9),
              ),
            ),
          ],
        ),
        Text('q',
            style: AppTypography.h4.copyWith(
              color: context.dColors.textPrimary,
              fontWeight: FontWeight.w700,
            )),
      ],
    );
  }
}

class _AvatarButton extends StatelessWidget {
  final String initial;
  const _AvatarButton({required this.initial});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/profile'),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          gradient: AppColors.gradientPrimary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.32),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            initial,
            style: AppTypography.labelMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  final bool hasUnread;
  final VoidCallback onTap;

  const _NotificationButton({
    required this.hasUnread,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: context.dColors.cardShadow,
            ),
            child: Icon(
              Icons.notifications_outlined,
              size: 20,
              color: context.dColors.textPrimary,
            ),
          ),
          if (hasUnread)
            Positioned(
              top: 1,
              right: 1,
              child: Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444),
                  shape: BoxShape.circle,
                  border: Border.all(color: context.dColors.background, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Cart button
// ─────────────────────────────────────────────────────────────────────────────

class _CartButton extends ConsumerWidget {
  final VoidCallback onTap;
  const _CartButton({required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(cartProvider).itemCount;
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: context.dColors.cardShadow,
            ),
            child: Icon(
              Icons.shopping_bag_outlined,
              size: 20,
              color: context.dColors.textPrimary,
            ),
          ),
          if (count > 0)
            Positioned(
              top: 0, right: 0,
              child: Container(
                width: 16, height: 16,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    count > 9 ? '9+' : '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Greeting
// ─────────────────────────────────────────────────────────────────────────────

class _GreetingRow extends StatelessWidget {
  final String greeting;
  final String name;

  const _GreetingRow({required this.greeting, required this.name});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                '$greeting, $name',
                style: AppTypography.h3.copyWith(color: context.dColors.textPrimary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            const Text('✨', style: TextStyle(fontSize: 20)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          "Let's check in on your skin today.",
          style: AppTypography.bodyMedium
              .copyWith(color: context.dColors.textSecondary),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DermIQ Health Score hero card
// ─────────────────────────────────────────────────────────────────────────────

class _HealthScoreHeroCard extends StatelessWidget {
  final double progress;
  final int score;
  final String level;
  final VoidCallback onViewAnalysis;

  const _HealthScoreHeroCard({
    required this.progress,
    required this.score,
    required this.level,
    required this.onViewAnalysis,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.radiusCard),
        boxShadow: AppColors.elevatedShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.radiusCard),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1E1B4B),
                Color(0xFF3B2D9F),
                Color(0xFF5E3FFF),
              ],
              stops: [0.0, 0.45, 1.0],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -28,
                top: -28,
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
              Positioned(
                right: 18,
                bottom: -22,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.04),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'DermIQ Health Score',
                          style: AppTypography.labelMedium.copyWith(
                            color: Colors.white.withValues(alpha: 0.72),
                          ),
                        ),
                        const Spacer(),
                        const _TodayBadge(),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '$score',
                                    style: AppTypography.metricMedium.copyWith(
                                      color: Colors.white,
                                      fontSize: 54,
                                      height: 1.0,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Text(
                                      '/100',
                                      style: AppTypography.bodyMedium.copyWith(
                                        color: Colors.white
                                            .withValues(alpha: 0.50),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFF4ADE80),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      level,
                                      style: AppTypography.labelSmall.copyWith(
                                        color: const Color(0xFF4ADE80),
                                        fontWeight: FontWeight.w700,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Icon(
                                    Icons.trending_up_rounded,
                                    size: 13,
                                    color: Color(0xFF4ADE80),
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    '+5 pts',
                                    style: AppTypography.caption.copyWith(
                                      color: Colors.white
                                          .withValues(alpha: 0.55),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 96,
                          height: 96,
                          child: CustomPaint(
                            painter: _DarkRingPainter(progress: progress),
                            child: Center(
                              child: Text(
                                '${(progress * 100).round()}%',
                                style: AppTypography.labelMedium.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Container(
                      height: 1,
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Expanded(
                            child: _MiniMetric(
                                'Hydration', 0.72, Icons.water_drop_rounded)),
                        Container(
                            width: 1,
                            height: 36,
                            color: Colors.white.withValues(alpha: 0.12)),
                        const Expanded(
                            child: _MiniMetric(
                                'Oil Balance', 0.65, Icons.opacity_rounded)),
                        Container(
                            width: 1,
                            height: 36,
                            color: Colors.white.withValues(alpha: 0.12)),
                        const Expanded(
                            child: _MiniMetric(
                                'UV Shield', 0.88, Icons.wb_sunny_rounded)),
                      ],
                    ),
                    const SizedBox(height: 18),
                    GestureDetector(
                      onTap: onViewAnalysis,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.18),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'View Full Analysis',
                              style: AppTypography.labelSmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.arrow_forward_rounded,
                                size: 14, color: Colors.white),
                          ],
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

class _TodayBadge extends StatelessWidget {
  const _TodayBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Text(
        'Updated today',
        style: AppTypography.overline.copyWith(
          color: Colors.white.withValues(alpha: 0.88),
          fontSize: 10,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  final String label;
  final double value;
  final IconData icon;

  const _MiniMetric(this.label, this.value, this.icon);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 15, color: Colors.white.withValues(alpha: 0.72)),
        const SizedBox(height: 5),
        Text(
          '${(value * 100).round()}%',
          style: AppTypography.labelSmall.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: Colors.white.withValues(alpha: 0.50),
            fontSize: 9.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _DarkRingPainter extends CustomPainter {
  final double progress;
  const _DarkRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 14) / 2;
    const sw = 8.0;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi,
      false,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.15)
        ..strokeWidth = sw
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        2 * pi * progress,
        false,
        Paint()
          ..shader = const LinearGradient(
            colors: [Colors.white, Color(0xFFC4B5FD)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(Rect.fromCircle(center: center, radius: radius))
          ..strokeWidth = sw
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_DarkRingPainter old) => old.progress != progress;
}

// ─────────────────────────────────────────────────────────────────────────────
// Appointment section
// ─────────────────────────────────────────────────────────────────────────────

class _AppointmentSection extends StatelessWidget {
  final VoidCallback onDermatologist;
  final VoidCallback onTrichologist;

  const _AppointmentSection({
    required this.onDermatologist,
    required this.onTrichologist,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusCard),
        boxShadow: context.dColors.cardShadow,
        border: Border.all(color: const Color(0xFFF0EDFF), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: AppColors.gradientPrimary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.calendar_today_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Book Appointment',
                      style: AppTypography.labelMedium.copyWith(
                        color: context.dColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Consult a specialist near you',
                      style: AppTypography.caption.copyWith(
                        color: context.dColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _CategoryButton(
                  label: 'Dermatologist',
                  icon: Icons.face_retouching_natural_rounded,
                  color: AppColors.primary,
                  onTap: onDermatologist,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _CategoryButton(
                  label: 'Trichologist',
                  icon: Icons.self_improvement_rounded,
                  color: const Color(0xFF7C5CFF),
                  onTap: onTrichologist,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CategoryButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          border: Border.all(color: color.withValues(alpha: 0.20)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 11.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: color.withValues(alpha: 0.6), size: 16),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section header
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final String action;
  final VoidCallback onAction;

  const _SectionHeader({
    required this.title,
    required this.action,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTypography.h4,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onAction,
          child: Row(
            children: [
              Text(action,
                  style: AppTypography.labelSmall
                      .copyWith(color: AppColors.primary)),
              const SizedBox(width: 2),
              const Icon(Icons.chevron_right_rounded,
                  size: 16, color: AppColors.primary),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Today's routine
// ─────────────────────────────────────────────────────────────────────────────

class _RoutineStep {
  final int step;
  final String name;
  final String brand;
  final String time;
  final IconData icon;
  final Color color;

  const _RoutineStep(
      this.step, this.name, this.brand, this.time, this.icon, this.color);
}

class _TodaysRoutineRow extends StatelessWidget {
  final VoidCallback onViewAll;

  const _TodaysRoutineRow({required this.onViewAll});

  static const _steps = [
    _RoutineStep(1, 'Hydrating Cleanser', 'CeraVe', 'AM',
        Icons.water_drop_rounded, Color(0xFF7C5CFF)),
    _RoutineStep(2, 'Vitamin C Serum', 'The Ordinary', 'AM',
        Icons.auto_awesome_rounded, Color(0xFFF59E0B)),
    _RoutineStep(3, 'SPF Moisturizer', 'Neutrogena', 'AM',
        Icons.wb_sunny_rounded, Color(0xFF0EA5E9)),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 158,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _steps.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          if (i == _steps.length) {
            return GestureDetector(
              onTap: onViewAll,
              child: Container(
                width: 72,
                decoration: BoxDecoration(
                  color: context.dColors.surfaceDim,
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusCard),
                  border:
                      Border.all(color: const Color(0xFFE8DEFF), width: 1),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.10),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_forward_rounded,
                          color: AppColors.primary, size: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'View all',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 10.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }
          return _RoutineStepCard(step: _steps[i]);
        },
      ),
    );
  }
}

class _RoutineStepCard extends StatelessWidget {
  final _RoutineStep step;
  const _RoutineStepCard({required this.step});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 134,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusCard),
        boxShadow: context.dColors.cardShadow,
        border: Border.all(color: const Color(0xFFF0EDFF), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  gradient: AppColors.gradientPrimary,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Center(
                  child: Text(
                    '${step.step}',
                    style: AppTypography.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: step.color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  step.time,
                  style: AppTypography.caption.copyWith(
                    color: step.color,
                    fontWeight: FontWeight.w700,
                    fontSize: 9.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: step.color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(step.icon, color: step.color, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            step.name,
            style: AppTypography.labelSmall.copyWith(
              color: context.dColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 11.5,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            step.brand,
            style: AppTypography.caption.copyWith(
              color: context.dColors.textTertiary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Analyze CTA card
// ─────────────────────────────────────────────────────────────────────────────

class _AnalyzeCTACard extends StatelessWidget {
  final VoidCallback onTap;
  const _AnalyzeCTACard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF5F3FF), Color(0xFFEDE9FE)],
          ),
          borderRadius: BorderRadius.circular(AppConstants.radiusCard),
          border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.18), width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: AppColors.gradientPrimary,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.28),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.camera_alt_rounded,
                  color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Analyze Your Skin',
                    style: AppTypography.labelMedium.copyWith(
                      color: context.dColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Scan your face or ingredients for an instant AI analysis',
                    style: AppTypography.caption.copyWith(
                      color: context.dColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                gradient: AppColors.gradientPrimary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Scan',
                style: AppTypography.buttonSmall.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shop CTA card
// ─────────────────────────────────────────────────────────────────────────────

class _ShopCTACard extends StatelessWidget {
  final VoidCallback onTap;
  const _ShopCTACard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF0FFFE), Color(0xFFCCFBF1)],
          ),
          borderRadius: BorderRadius.circular(AppConstants.radiusCard),
          border: Border.all(
              color: const Color(0xFF10B981).withValues(alpha: 0.22), width: 1),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF10B981).withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFF10B981),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10B981).withValues(alpha: 0.28),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.shopping_bag_rounded,
                  color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Shop Skincare',
                    style: AppTypography.labelMedium.copyWith(
                      color: context.dColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Browse products matched to your skin and hair profile',
                    style: AppTypography.caption.copyWith(
                      color: context.dColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Shop',
                style: AppTypography.buttonSmall.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AI insight card
// ─────────────────────────────────────────────────────────────────────────────

class _AiInsightCard extends StatelessWidget {
  final VoidCallback onTap;
  const _AiInsightCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
          ),
          borderRadius: BorderRadius.circular(AppConstants.radiusCard),
          border: Border.all(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.28),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.10),
              blurRadius: 18,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Color(0xFFB45309),
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DermIQ Insight',
                    style: AppTypography.labelSmall.copyWith(
                      color: const Color(0xFF92400E),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Your skin barrier shows stress markers today — reach for a ceramide-rich moisturiser.',
                    style: AppTypography.caption.copyWith(
                      color: const Color(0xFF78350F),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 13,
              color: Color(0xFFB45309),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Recommendations
// ─────────────────────────────────────────────────────────────────────────────

class _RecommendationItem {
  final String name;
  final String brand;
  final String tag;
  final Color color;
  final IconData icon;

  const _RecommendationItem({
    required this.name,
    required this.brand,
    required this.tag,
    required this.color,
    required this.icon,
  });
}

class _RecommendationsRow extends StatelessWidget {
  const _RecommendationsRow();

  static const _items = [
    _RecommendationItem(
      name: 'Ceramide Moisturiser',
      brand: 'CeraVe',
      tag: 'For your barrier',
      color: Color(0xFF8B6FE8),
      icon: Icons.water_drop_rounded,
    ),
    _RecommendationItem(
      name: 'Niacinamide 10%',
      brand: 'The Ordinary',
      tag: 'Pores & redness',
      color: Color(0xFF0EA5E9),
      icon: Icons.science_rounded,
    ),
    _RecommendationItem(
      name: 'SPF 50+ Sunscreen',
      brand: 'La Roche-Posay',
      tag: 'UV protection',
      color: Color(0xFFF59E0B),
      icon: Icons.wb_sunny_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, i) => _RecommendationCard(item: _items[i]),
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final _RecommendationItem item;
  const _RecommendationCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusCard),
        boxShadow: context.dColors.cardShadow,
        border: Border.all(color: const Color(0xFFF0EDFF), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, color: item.color, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            item.name,
            style: AppTypography.labelSmall.copyWith(
              color: context.dColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 11.5,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            item.brand,
            style: AppTypography.caption.copyWith(
              color: context.dColors.textTertiary,
              fontSize: 10,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: item.color.withValues(alpha: 0.22)),
            ),
            child: Text(
              item.tag,
              style: AppTypography.caption.copyWith(
                color: item.color,
                fontWeight: FontWeight.w600,
                fontSize: 9.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
