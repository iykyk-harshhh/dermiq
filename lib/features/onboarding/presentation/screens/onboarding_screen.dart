import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/services/preferences_service.dart';
import '../../../../shared/widgets/diq_logo.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  ONBOARDING SCREEN  (3 pages, splash visual language)
// ─────────────────────────────────────────────────────────────────────────────

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with TickerProviderStateMixin {
  final _pageCtrl = PageController();
  int _page = 0;

  late final AnimationController _sphereCtrl;
  late final AnimationController _pulseCtrl;
  late final AnimationController _floatCtrl;
  late final AnimationController _fillCtrl;   // drives ring/bars on pages 2 & 3

  late final Animation<double> _sphere;
  late final Animation<double> _pulse;
  late final Animation<double> _float;
  late final Animation<double> _fill;

  static const _pages = [_Page1Data(), _Page2Data(), _Page3Data()];

  @override
  void initState() {
    super.initState();
    _sphereCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat(reverse: true);
    _pulseCtrl  = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _floatCtrl  = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);
    _fillCtrl   = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));

    _sphere = CurvedAnimation(parent: _sphereCtrl, curve: Curves.easeInOut);
    _pulse  = Tween<double>(begin: 0.85, end: 1.0).animate(
                CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _float  = Tween<double>(begin: -10, end: 10).animate(
                CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));
    _fill   = CurvedAnimation(parent: _fillCtrl, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _sphereCtrl.dispose();
    _pulseCtrl.dispose();
    _floatCtrl.dispose();
    _fillCtrl.dispose();
    super.dispose();
  }

  void _onPageChanged(int i) {
    setState(() => _page = i);
    // Replay fill animation whenever an animated page becomes active
    if (i == 1 || i == 2) _fillCtrl.forward(from: 0);
  }

  void _next() {
    if (_page < 2) {
      _pageCtrl.animateToPage(
        _page + 1,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
    } else {
      _finish();
    }
  }

  void _skip() => _finish();

  /// Mark onboarding seen (persisted) so it never shows again, then go to login.
  void _finish() {
    PreferencesService.setOnboardingSeen(true);
    ref.read(onboardingSeenProvider.notifier).state = true;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

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
          child: Column(
            children: [
              // ── Top bar ────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const DiqLogo(size: DiqLogoSize.small),
                    if (_page < 2)
                      GestureDetector(
                        onTap: _skip,
                        child: Text('Skip',
                            style: AppTypography.labelMedium.copyWith(
                              color: const Color(0xFF7C5CFF),
                            )),
                      ),
                  ],
                ),
              ),

              // ── Page view ──────────────────────────────────────────────────
              Expanded(
                child: PageView.builder(
                  controller: _pageCtrl,
                  onPageChanged: _onPageChanged,
                  itemCount: 3,
                  itemBuilder: (_, i) => _OnboardingPage(
                    data:   _pages[i],
                    sphere: _sphere,
                    pulse:  _pulse,
                    float:  _float,
                    fill:   _fill,
                    size:   size,
                  ),
                ),
              ),

              // ── Bottom controls ────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Progress dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (i) {
                        final active = i == _page;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: active ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: active
                                ? const Color(0xFF7C5CFF)
                                : const Color(0xFF7C5CFF).withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 24),
                    _GradientButton(
                      label: _page == 2 ? 'Get Started' : 'Next',
                      onTap: _next,
                    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2),
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
//  PAGE DATA
// ─────────────────────────────────────────────────────────────────────────────

abstract class _PageData {
  const _PageData();
  String get headline;
  String get subheadline;
  String get body;
  Color get accentColor;
}

class _Page1Data extends _PageData {
  const _Page1Data();
  @override String get headline    => 'Know\nYour Skin';
  @override String get subheadline => 'AI-Powered Analysis';
  @override String get body        =>
      'Scan your skin in seconds. Our AI maps every pore, texture, and concern to build your unique skin profile.';
  @override Color get accentColor  => const Color(0xFF8B6FE8);
}

class _Page2Data extends _PageData {
  const _Page2Data();
  @override String get headline    => 'Track Your\nProgress';
  @override String get subheadline => 'Smart Insights Daily';
  @override String get body        =>
      'Watch your skin score improve week over week. Real data, real results — not guesswork.';
  @override Color get accentColor  => const Color(0xFF7C5CFF);
}

class _Page3Data extends _PageData {
  const _Page3Data();
  @override String get headline    => 'Your Perfect\nRoutine';
  @override String get subheadline => 'Personalized For You';
  @override String get body        =>
      'Get a routine built around your skin and hair profile. No generic advice — just what works for you.';
  @override Color get accentColor  => const Color(0xFF6045CC);
}

// ─────────────────────────────────────────────────────────────────────────────
//  SINGLE ONBOARDING PAGE
// ─────────────────────────────────────────────────────────────────────────────

class _OnboardingPage extends StatelessWidget {
  final _PageData data;
  final Animation<double> sphere;
  final Animation<double> pulse;
  final Animation<double> float;
  final Animation<double> fill;
  final Size size;

  const _OnboardingPage({
    required this.data,
    required this.sphere,
    required this.pulse,
    required this.float,
    required this.fill,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Illustration zone
          Expanded(
            flex: 5,
            child: _Illustration(
              data:   data,
              sphere: sphere,
              pulse:  pulse,
              float:  float,
              fill:   fill,
              size:   size,
            ),
          ),

          // Text zone
          Expanded(
            flex: 4,
            child: SingleChildScrollView(
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  data.subheadline.toUpperCase(),
                  style: AppTypography.overline.copyWith(
                    color: data.accentColor,
                    letterSpacing: 2.0,
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
                const SizedBox(height: 12),
                Text(
                  data.headline,
                  style: AppTypography.display.copyWith(
                    color: const Color(0xFF1E1B4B),
                    height: 1.1,
                  ),
                  textAlign: TextAlign.center,
                ).animate()
                  .fadeIn(duration: 500.ms, delay: 160.ms)
                  .slideY(begin: 0.12, curve: Curves.easeOutCubic),
                const SizedBox(height: 16),
                Text(
                  data.body,
                  style: AppTypography.bodyMedium.copyWith(
                    color: const Color(0xFF6B7280),
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(duration: 500.ms, delay: 240.ms),
              ],
            ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  ILLUSTRATION dispatcher
// ─────────────────────────────────────────────────────────────────────────────

class _Illustration extends StatelessWidget {
  final _PageData data;
  final Animation<double> sphere;
  final Animation<double> pulse;
  final Animation<double> float;
  final Animation<double> fill;
  final Size size;

  const _Illustration({
    required this.data,
    required this.sphere,
    required this.pulse,
    required this.float,
    required this.fill,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    if (data is _Page1Data) {
      return _Page1Illustration(
        sphereT: sphere, pulse: pulse, float: float, size: size,
      );
    }
    if (data is _Page2Data) {
      return _Page2Illustration(float: float, pulse: pulse, ringFill: fill);
    }
    return _Page3Illustration(float: float, pulse: pulse, fill: fill);
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  PAGE 1 — AI face mesh
// ═════════════════════════════════════════════════════════════════════════════

class _Page1Illustration extends StatelessWidget {
  final Animation<double> sphereT;
  final Animation<double> pulse;
  final Animation<double> float;
  final Size size;

  const _Page1Illustration({
    required this.sphereT,
    required this.pulse,
    required this.float,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([sphereT, pulse, float]),
      builder: (_, child) => Stack(
        alignment: Alignment.center,
        children: [
          // Glow bloom
          Container(
            width: 240, height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                Colors.white.withValues(alpha: 0.65 * pulse.value),
                const Color(0xFFD4C0FF).withValues(alpha: 0.25 * pulse.value),
                Colors.transparent,
              ]),
            ),
          ),
          // Face mesh
          SizedBox(
            width: 260, height: 260,
            child: CustomPaint(
              painter: _MiniMeshPainter(float: float.value, pulse: pulse.value),
            ),
          ),
          // Sphere top-right
          Positioned(
            top: 12 + 8 * sin(sphereT.value * pi),
            right: 12 + 6 * cos(sphereT.value * pi),
            child: _Sphere(size: 40, color: const Color(0xFF9878E0)),
          ),
          // Sphere bottom-left
          Positioned(
            bottom: 24 + 10 * sin(sphereT.value * pi * 1.3),
            left: 4 + 7 * cos(sphereT.value * pi * 1.3),
            child: _Sphere(size: 58, color: const Color(0xFF7258BC)),
          ),
          // Score badge
          Positioned(
            bottom: 16, right: 16,
            child: Transform.translate(
              offset: Offset(0, float.value * 0.4),
              child: const _ScoreBadge(score: 82),
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  PAGE 2 — Progress analytics dashboard
// ═════════════════════════════════════════════════════════════════════════════

class _Page2Illustration extends StatelessWidget {
  final Animation<double> float;
  final Animation<double> pulse;
  final Animation<double> ringFill;

  const _Page2Illustration({
    required this.float,
    required this.pulse,
    required this.ringFill,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([float, pulse, ringFill]),
      builder: (_, child) => Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Ambient glow
          Container(
            width: 260, height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                Colors.white.withValues(alpha: 0.5 * pulse.value),
                const Color(0xFFD4C0FF).withValues(alpha: 0.18 * pulse.value),
                Colors.transparent,
              ]),
            ),
          ),
          // Left sphere
          Positioned(
            left: -8 + 6 * sin(float.value * 0.18),
            top:  40 + 8 * cos(float.value * 0.18),
            child: _Sphere(size: 46, color: const Color(0xFF8B6FE8)),
          ),
          // Right sphere
          Positioned(
            right:  -12 + 8 * cos(float.value * 0.14),
            bottom:  50 + 10 * sin(float.value * 0.14),
            child: _Sphere(size: 32, color: const Color(0xFF7258BC)),
          ),
          // Main column
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Score ring + side badges
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Transform.translate(
                    offset: Offset(0, float.value * 0.45),
                    child: SizedBox(
                      width: 168, height: 168,
                      child: CustomPaint(
                        painter: _ScoreRingPainter(
                          fill:  0.82 * ringFill.value,
                          pulse: pulse.value,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Transform.translate(
                    offset: Offset(0, float.value * -0.3),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ChangeBadge(delta: '+14', label: 'this week',  color: const Color(0xFF22C55E), icon: Icons.trending_up_rounded),
                        const SizedBox(height: 10),
                        _RankBadge(label: 'Top 12%', color: const Color(0xFF7C5CFF)),
                        const SizedBox(height: 10),
                        _ChangeBadge(delta: '82',   label: 'skin score', color: const Color(0xFF7C5CFF), icon: Icons.star_rounded),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Metric chips row
              Transform.translate(
                offset: Offset(0, float.value * 0.2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    _MetricChip(label: 'Hydration', value: 78, color: Color(0xFF60A5FA)),
                    SizedBox(width: 8),
                    _MetricChip(label: 'Clarity',   value: 85, color: Color(0xFF34D399)),
                    SizedBox(width: 8),
                    _MetricChip(label: 'Texture',   value: 72, color: Color(0xFFAA78E8)),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              // Week progress bars
              Transform.translate(
                offset: Offset(0, float.value * -0.2),
                child: _WeekProgressCard(ringFill: ringFill.value),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  PAGE 3 — Your Perfect Routine
// ═════════════════════════════════════════════════════════════════════════════

class _Page3Illustration extends StatelessWidget {
  final Animation<double> float;
  final Animation<double> pulse;
  final Animation<double> fill;  // drives step check-off + completion ring

  const _Page3Illustration({
    required this.float,
    required this.pulse,
    required this.fill,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([float, pulse, fill]),
      builder: (_, child) => Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // ── Ambient glow bloom ───────────────────────────────────────────
          Container(
            width: 280, height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                Colors.white.withValues(alpha: 0.45 * pulse.value),
                const Color(0xFFD4C0FF).withValues(alpha: 0.15 * pulse.value),
                Colors.transparent,
              ]),
            ),
          ),

          // ── Left sphere ──────────────────────────────────────────────────
          Positioned(
            left: -4 + 6 * sin(float.value * 0.16),
            top:  18 + 8 * cos(float.value * 0.16),
            child: _Sphere(size: 44, color: const Color(0xFF8B6FE8)),
          ),

          // ── Right sphere ─────────────────────────────────────────────────
          Positioned(
            right:  -8 + 7 * cos(float.value * 0.21),
            bottom: 40 + 9 * sin(float.value * 0.21),
            child: _Sphere(size: 30, color: const Color(0xFF7258BC)),
          ),

          // ── Main content column ──────────────────────────────────────────
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Routine hero card — floats gently
              Transform.translate(
                offset: Offset(0, float.value * 0.38),
                child: _RoutineHeroCard(fill: fill.value),
              ),

              const SizedBox(height: 12),

              // Personalization chips row — counter-float
              Transform.translate(
                offset: Offset(0, float.value * -0.22),
                child: const _PersonalizationRow(),
              ),

              const SizedBox(height: 10),

              // Stat badges row — slight float
              Transform.translate(
                offset: Offset(0, float.value * 0.14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _StatBadge(
                      emoji: '🔥',
                      label: '7 Day Streak',
                      color: const Color(0xFFFF8C6B),
                    ),
                    const SizedBox(width: 8),
                    _StatBadge(
                      emoji: '✦',
                      label: '18 Products Scanned',
                      color: const Color(0xFF7C5CFF),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  PAGE 3 — Routine Hero Card
// ─────────────────────────────────────────────────────────────────────────────

class _RoutineHeroCard extends StatelessWidget {
  final double fill; // 0.0 → 1.0

  static const _steps = [
    _StepItem('Cleanser',    'CeraVe Foaming',         Color(0xFF8B6FE8), Icons.water_drop_outlined),
    _StepItem('Serum',       'Ordinary Niacinamide',   Color(0xFF7C5CFF), Icons.science_outlined),
    _StepItem('Moisturizer', 'La Roche-Posay Toleriane',Color(0xFF6045CC), Icons.spa_outlined),
    _StepItem('SPF 50',      'Neutrogena Clear Face',  Color(0xFFFF8C6B), Icons.wb_sunny_outlined),
  ];

  const _RoutineHeroCard({required this.fill});

  @override
  Widget build(BuildContext context) {
    final completed = (_steps.length * fill).ceil().clamp(0, _steps.length);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C5CFF).withValues(alpha: 0.14),
            blurRadius: 24,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
          const BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Gradient header ──────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 13, 14, 13),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xFF6045CC), Color(0xFF8B68E8)],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
            ),
            child: Row(
              children: [
                const Text('☀️', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AM ROUTINE',
                        style: GoogleFonts.poppins(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withValues(alpha: 0.72),
                          letterSpacing: 1.6,
                        ),
                      ),
                      Text(
                        'Built just for you ✦',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                // Animated completion ring
                SizedBox(
                  width: 46, height: 46,
                  child: CustomPaint(
                    painter: _CompletionRingPainter(
                      fill:  fill,
                      total: _steps.length,
                    ),
                    child: Center(
                      child: Text(
                        '$completed/${_steps.length}',
                        style: GoogleFonts.poppins(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Step rows ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _steps.asMap().entries.map((e) {
                final i    = e.key;
                final step = e.value;
                final done = i < completed;
                return _StepRow(step: step, done: done);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepItem {
  final String name;
  final String product;
  final Color color;
  final IconData icon;
  const _StepItem(this.name, this.product, this.color, this.icon);
}

class _StepRow extends StatelessWidget {
  final _StepItem step;
  final bool done;
  const _StepRow({required this.step, required this.done});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: done ? 1.0 : 0.45,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            // Icon circle
            Container(
              width: 34, height: 34,
              decoration: BoxDecoration(
                color: step.color.withValues(alpha: done ? 0.14 : 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(step.icon, color: step.color, size: 16),
            ),
            const SizedBox(width: 10),
            // Labels
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(step.name,
                      style: AppTypography.labelSmall.copyWith(
                        color: const Color(0xFF1E1B4B),
                        fontWeight: FontWeight.w600,
                      )),
                  Text(step.product,
                      style: AppTypography.caption.copyWith(
                        color: const Color(0xFF9CA3AF),
                        fontSize: 10,
                      ),
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            // Check / pending indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              width: 22, height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done ? const Color(0xFF22C55E) : Colors.transparent,
                border: done
                    ? null
                    : Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
              ),
              child: done
                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 13)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  PAGE 3 — Personalization chips row
// ─────────────────────────────────────────────────────────────────────────────

class _PersonalizationRow extends StatelessWidget {
  const _PersonalizationRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _PersonalChip(
          label: 'Oily Skin',
          emoji: '🌿',
          color: const Color(0xFF34D399),
        ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideX(begin: -0.1),
        const SizedBox(width: 8),
        _PersonalChip(
          label: 'Wavy Hair',
          emoji: '💧',
          color: const Color(0xFF60A5FA),
        ).animate().fadeIn(duration: 400.ms, delay: 280.ms),
        const SizedBox(width: 8),
        _PersonalChip(
          label: 'Fragrance-Free',
          emoji: '✓',
          color: const Color(0xFF7C5CFF),
        ).animate().fadeIn(duration: 400.ms, delay: 360.ms).slideX(begin: 0.1),
      ],
    );
  }
}

class _PersonalChip extends StatelessWidget {
  final String label;
  final String emoji;
  final Color color;
  const _PersonalChip({required this.label, required this.emoji, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1.2),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 11)),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  PAGE 3 — Stat badges (streak / products)
// ─────────────────────────────────────────────────────────────────────────────

class _StatBadge extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;
  const _StatBadge({required this.emoji, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.22), width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  PAGE 2 — Metric chip
// ─────────────────────────────────────────────────────────────────────────────

class _MetricChip extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _MetricChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$value%',
            style: GoogleFonts.poppins(
              fontSize: 14, fontWeight: FontWeight.w700, color: color,
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 48, height: 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: value / 100,
                backgroundColor: color.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 8.5, fontWeight: FontWeight.w500, color: const Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  PAGE 2 — Change badge + Rank badge + Week progress card
// ─────────────────────────────────────────────────────────────────────────────

class _ChangeBadge extends StatelessWidget {
  final String delta;
  final String label;
  final Color color;
  final IconData icon;
  const _ChangeBadge({required this.delta, required this.label, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(delta, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: color, height: 1.1)),
              Text(label, style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w500, color: const Color(0xFF9CA3AF), height: 1.1)),
            ],
          ),
        ],
      ),
    );
  }
}

class _RankBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _RankBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, Color.lerp(color, const Color(0xFF8B68E8), 0.6)!],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 11),
          const SizedBox(width: 4),
          Text(label, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
        ],
      ),
    );
  }
}

class _WeekProgressCard extends StatelessWidget {
  final double ringFill;

  static const _weeks = [
    ('Wk 1', 0.52),
    ('Wk 2', 0.63),
    ('Wk 3', 0.74),
    ('Now',  0.82),
  ];

  const _WeekProgressCard({required this.ringFill});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ..._weeks.asMap().entries.map((e) {
            final i     = e.key;
            final week  = e.value;
            final isNow = i == _weeks.length - 1;
            final barH  = 44.0 * week.$2 * ringFill;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    width: 22,
                    height: barH.clamp(4.0, 44.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: isNow
                            ? [const Color(0xFF6045CC), const Color(0xFF8B68E8)]
                            : [
                                const Color(0xFF7C5CFF).withValues(alpha: 0.30),
                                const Color(0xFF7C5CFF).withValues(alpha: 0.14),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: isNow
                          ? [BoxShadow(color: const Color(0xFF7C5CFF).withValues(alpha: 0.35), blurRadius: 8, offset: const Offset(0, 3))]
                          : null,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    week.$1,
                    style: GoogleFonts.poppins(
                      fontSize: 8,
                      fontWeight: isNow ? FontWeight.w700 : FontWeight.w500,
                      color: isNow ? const Color(0xFF7C5CFF) : const Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            );
          }),
          // Score label
          Padding(
            padding: const EdgeInsets.only(left: 6, bottom: 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${(82 * ringFill).round()}',
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF1E1B4B)),
                ),
                Text(
                  'score',
                  style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w500, color: const Color(0xFF9CA3AF)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  SHARED SUB-WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _Sphere extends StatelessWidget {
  final double size;
  final Color color;
  const _Sphere({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    final hi = Color.lerp(color, Colors.white, 0.52)!;
    final lo = Color.lerp(color, const Color(0xFF2A1A60), 0.26)!;
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.35, -0.38),
          radius: 0.75,
          colors: [hi, color, lo],
          stops: const [0.0, 0.55, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.38),
            blurRadius: size * 0.45,
            offset: Offset(size * 0.06, size * 0.12),
          ),
        ],
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  final int score;
  const _ScoreBadge({required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8, height: 8,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF22C55E)),
          ),
          const SizedBox(width: 8),
          Text(
            'Skin Score: $score',
            style: AppTypography.labelSmall.copyWith(
              color: const Color(0xFF1E1B4B), fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  CUSTOM PAINTERS
// ─────────────────────────────────────────────────────────────────────────────

class _MiniMeshPainter extends CustomPainter {
  final double float;
  final double pulse;
  const _MiniMeshPainter({required this.float, required this.pulse});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width  * 0.52;
    final cy = size.height * 0.48 + float * 0.35;
    final fw = size.width  * 0.52;
    final fh = size.height * 0.72;

    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy), width: fw, height: fh),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.72 * pulse)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke,
    );
    final mesh = Paint()
      ..color = const Color(0xFFBBA8EE).withValues(alpha: 0.32)
      ..strokeWidth = 0.6
      ..style = PaintingStyle.stroke;

    for (int i = -8; i <= 8; i++) {
      final t  = i / 8.0;
      final y  = cy + t * (fh / 2);
      final hw = (fw / 2) * sqrt(max(0.0, 1 - t * t));
      if (hw < 2) continue;
      canvas.drawLine(Offset(cx - hw, y), Offset(cx + hw, y), mesh);
    }
    for (int i = -6; i <= 6; i++) {
      final t  = i / 6.0;
      final x  = cx + t * (fw / 2);
      final hh = (fh / 2) * sqrt(max(0.0, 1 - t * t));
      if (hh < 2) continue;
      canvas.drawLine(Offset(x, cy - hh), Offset(x, cy + hh), mesh);
    }
    const dots = [
      [-0.2, -0.15], [0.2, -0.15], [0.0, 0.05],
      [-0.08, 0.22], [0.08, 0.22], [0.0, 0.42],
      [0.0, -0.38],  [-0.38, 0.0], [0.32, 0.0],
    ];
    for (final d in dots) {
      final ox = cx + fw * d[0];
      final oy = cy + fh * d[1];
      canvas.drawCircle(Offset(ox, oy), 3.5, Paint()..color = Colors.white.withValues(alpha: 0.18 * pulse));
      canvas.drawCircle(Offset(ox, oy), 2.2, Paint()..color = const Color(0xFFD4C0FF).withValues(alpha: 0.4 * pulse));
      canvas.drawCircle(Offset(ox, oy), 1.4, Paint()..color = Colors.white.withValues(alpha: 0.85 * pulse));
    }
    final hair = Paint()
      ..color = const Color(0xFFD4C0FF).withValues(alpha: 0.28)
      ..strokeWidth = 0.7
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    for (int s = 0; s < 4; s++) {
      final oy = s * 10.0;
      canvas.drawPath(
        Path()
          ..moveTo(cx - fw * 0.08 + s * 4, cy - fh * 0.42 + oy)
          ..cubicTo(
            cx - fw * 0.4,  cy - fh * 0.55 + oy,
            cx - fw * 0.8,  cy - fh * 0.4  + oy,
            cx - fw * 1.2,  cy - fh * 0.2  + oy,
          ),
        hair,
      );
    }
  }

  @override
  bool shouldRepaint(_MiniMeshPainter old) => old.float != float || old.pulse != pulse;
}

/// Page 2 — animated score fill ring
class _ScoreRingPainter extends CustomPainter {
  final double fill;
  final double pulse;
  const _ScoreRingPainter({required this.fill, required this.pulse});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = (size.width - 16) / 2;

    // Outer glow
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r + 6),
      -pi / 2, 2 * pi * fill, false,
      Paint()
        ..color = const Color(0xFF7C5CFF).withValues(alpha: 0.12 * pulse)
        ..strokeWidth = 14
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
    // Track
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r), -pi / 2, 2 * pi, false,
      Paint()
        ..color = const Color(0xFF7C5CFF).withValues(alpha: 0.10)
        ..strokeWidth = 10
        ..style = PaintingStyle.stroke,
    );
    // Fill
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      -pi / 2, 2 * pi * fill, false,
      Paint()
        ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF8B68E8), Color(0xFF6045CC)],
          ).createShader(Rect.fromCircle(center: c, radius: r))
        ..strokeWidth = 10
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
    // Score number
    final score = (82 * fill).round();
    final tp = TextPainter(
      text: TextSpan(text: '$score', style: GoogleFonts.poppins(
        fontSize: 38, fontWeight: FontWeight.w800, color: const Color(0xFF1E1B4B), height: 1,
      )),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, c - Offset(tp.width / 2, tp.height / 2 + 6));

    final sub = TextPainter(
      text: TextSpan(text: '/100', style: GoogleFonts.poppins(
        fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF9CA3AF),
      )),
      textDirection: TextDirection.ltr,
    )..layout();
    sub.paint(canvas, Offset(c.dx - sub.width / 2, c.dy + 18));

    final over = TextPainter(
      text: TextSpan(text: 'SKIN SCORE', style: GoogleFonts.poppins(
        fontSize: 7.5, fontWeight: FontWeight.w600,
        color: const Color(0xFF7C5CFF).withValues(alpha: 0.70), letterSpacing: 1.4,
      )),
      textDirection: TextDirection.ltr,
    )..layout();
    over.paint(canvas, Offset(c.dx - over.width / 2, c.dy - tp.height / 2 - 16));
  }

  @override
  bool shouldRepaint(_ScoreRingPainter old) => old.fill != fill || old.pulse != pulse;
}

/// Page 3 — completion ring around the 4/4 fraction
class _CompletionRingPainter extends CustomPainter {
  final double fill;   // 0.0 → 1.0
  final int total;
  const _CompletionRingPainter({required this.fill, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = (size.width - 6) / 2;

    // Track
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r), -pi / 2, 2 * pi, false,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.25)
        ..strokeWidth = 3.5
        ..style = PaintingStyle.stroke,
    );
    // Fill — steps complete fraction
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      -pi / 2, 2 * pi * fill, false,
      Paint()
        ..color = const Color(0xFF22C55E)
        ..strokeWidth = 3.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_CompletionRingPainter old) => old.fill != fill;
}

// ─────────────────────────────────────────────────────────────────────────────
//  GRADIENT BUTTON
// ─────────────────────────────────────────────────────────────────────────────

class _GradientButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _GradientButton({required this.label, required this.onTap});

  @override
  State<_GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<_GradientButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 80));
    _scale = Tween<double>(begin: 1.0, end: 0.965)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown:   (_) => _ctrl.forward(),
      onTapUp:     (_) { _ctrl.reverse(); widget.onTap(); },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
        child: Container(
          width: double.infinity,
          height: 58,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFF6045CC), Color(0xFF8B68E8)],
            ),
            borderRadius: BorderRadius.circular(29),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7C5CFF).withValues(alpha: 0.38),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.label,
                style: GoogleFonts.poppins(
                  fontSize: 15, fontWeight: FontWeight.w600,
                  color: Colors.white, letterSpacing: 0.2,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
