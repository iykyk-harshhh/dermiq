import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/diq_logo.dart';
import '../../../../core/services/preferences_service.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _obscure  = true;
  bool _loading  = false;
  bool _remember = false;

  late final AnimationController _sphereCtrl;
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _sphereCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _sphereCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    await ref.read(authProvider).signInWithEmail(_emailCtrl.text, _passCtrl.text);
    if (!mounted) return;
    setState(() => _loading = false);
    context.go('/home');
  }

  /// Continue with Google: existing user (quizzes done) → Home; a first-time
  /// Google user is routed through the skin/hair quizzes.
  Future<void> _googleSignIn() async {
    setState(() => _loading = true);
    await ref.read(authProvider).signInWithGoogle();
    if (!mounted) return;
    setState(() => _loading = false);
    context.go(
      PreferencesService.profileComplete ? '/home' : '/quiz/skin-type',
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // ── top bar (login is the auth root — no back button) ────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    DiqLogo(size: DiqLogoSize.small),
                  ],
                ).animate().fadeIn(duration: 400.ms),

                // ── animated hero ─────────────────────────────────────────────
                AnimatedBuilder(
                  animation: Listenable.merge([_sphereCtrl, _pulseCtrl]),
                  builder: (_, _) => _LoginHero(
                    screenSize: size,
                    sphereValue: _sphereCtrl.value,
                    pulseValue: _pulseCtrl.value,
                  ),
                ),

                // ── headline ──────────────────────────────────────────────────
                Text(
                  'Welcome\nBack',
                  style: AppTypography.display.copyWith(
                    color: const Color(0xFF1E1B4B),
                    height: 1.1,
                  ),
                ).animate()
                    .fadeIn(duration: 500.ms, delay: 80.ms)
                    .slideY(begin: 0.12, curve: Curves.easeOutCubic),

                const SizedBox(height: 8),

                Text(
                  'Sign in to continue your skincare journey.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ).animate().fadeIn(duration: 500.ms, delay: 150.ms),

                const SizedBox(height: 32),

                // ── form ──────────────────────────────────────────────────────
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _InputCard(
                        child: AppTextField(
                          controller: _emailCtrl,
                          hintText: 'Email address',
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          prefixIcon: const Icon(Icons.mail_outline_rounded,
                              color: AppColors.primary, size: 20),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Email required';
                            if (!v.contains('@')) return 'Enter a valid email';
                            return null;
                          },
                        ),
                      ).animate()
                          .fadeIn(duration: 400.ms, delay: 220.ms)
                          .slideY(begin: 0.1, curve: Curves.easeOutCubic),

                      const SizedBox(height: 12),

                      _InputCard(
                        child: AppTextField(
                          controller: _passCtrl,
                          hintText: 'Password',
                          obscureText: _obscure,
                          textInputAction: TextInputAction.done,
                          prefixIcon: const Icon(Icons.lock_outline_rounded,
                              color: AppColors.primary, size: 20),
                          suffixIcon: GestureDetector(
                            onTap: () => setState(() => _obscure = !_obscure),
                            child: Icon(
                              _obscure
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.textTertiary,
                              size: 20,
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Password required';
                            if (v.length < 6) return 'Minimum 6 characters';
                            return null;
                          },
                          onSubmitted: (_) => _submit(),
                        ),
                      ).animate()
                          .fadeIn(duration: 400.ms, delay: 280.ms)
                          .slideY(begin: 0.1, curve: Curves.easeOutCubic),

                      const SizedBox(height: 10),

                      // ── remember me + forgot password ──────────────────────
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => setState(() => _remember = !_remember),
                            child: Row(
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 20, height: 20,
                                  decoration: BoxDecoration(
                                    color: _remember
                                        ? AppColors.primary
                                        : Colors.white.withValues(alpha: 0.8),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: _remember
                                          ? AppColors.primary
                                          : const Color(0xFFD8C8FF),
                                      width: 1.5,
                                    ),
                                    boxShadow: AppColors.cardShadow,
                                  ),
                                  child: _remember
                                      ? const Icon(Icons.check_rounded,
                                          size: 12, color: Colors.white)
                                      : null,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Remember me',
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () => context.push('/forgot-password'),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Forgot Password?',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ).animate().fadeIn(duration: 400.ms, delay: 340.ms),

                      const SizedBox(height: 20),

                      AppButton(
                        label: 'Sign In',
                        onPressed: _submit,
                        isLoading: _loading,
                      ).animate()
                          .fadeIn(duration: 400.ms, delay: 400.ms)
                          .slideY(begin: 0.12, curve: Curves.easeOutCubic),

                      const SizedBox(height: 20),

                      // ── divider ────────────────────────────────────────────
                      Row(children: [
                        const Expanded(child: Divider(color: Color(0xFFD8C8FF))),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text('or', style: AppTypography.caption),
                        ),
                        const Expanded(child: Divider(color: Color(0xFFD8C8FF))),
                      ]).animate().fadeIn(duration: 400.ms, delay: 460.ms),

                      const SizedBox(height: 16),

                      AppSocialButton(
                        label: 'Continue with Google',
                        icon: const _GoogleIcon(),
                        onPressed: _googleSignIn,
                      ).animate().fadeIn(duration: 400.ms, delay: 520.ms),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // ── register link ─────────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account? ",
                        style: AppTypography.bodySmall),
                    GestureDetector(
                      onTap: () => context.pushReplacement('/register'),
                      child: Text(
                        'Sign Up',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 400.ms, delay: 580.ms),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero Section
// ─────────────────────────────────────────────────────────────────────────────

class _LoginHero extends StatelessWidget {
  final Size screenSize;
  final double sphereValue;
  final double pulseValue;

  const _LoginHero({
    required this.screenSize,
    required this.sphereValue,
    required this.pulseValue,
  });

  @override
  Widget build(BuildContext context) {
    final float = math.sin(sphereValue * 2 * math.pi) * 8.0;

    return SizedBox(
      height: screenSize.height * 0.26,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Radial glow bloom
          Container(
            width: 210,
            height: 210,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.55),
                  const Color(0xFFE8DEFF).withValues(alpha: 0.28),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // Sphere — upper right, floats opposite to center
          Positioned(
            top: 10 - float * 0.4,
            right: 0,
            child: _Sphere(
              size: 40,
              color: const Color(0xFF9B7FEA),
              highlight: const Color(0xFFCDB0FF),
              shadow: const Color(0xFF5C3DB5),
            ),
          ),

          // Sphere — lower left, floats with center
          Positioned(
            bottom: 14 + float * 0.35,
            left: 0,
            child: _Sphere(
              size: 56,
              color: const Color(0xFF7258BC),
              highlight: const Color(0xFFAA88EE),
              shadow: const Color(0xFF412A8C),
            ),
          ),

          // Score ring badge — center, gentle float
          Transform.translate(
            offset: Offset(0, float * 0.55),
            child: _ScoreRingBadge(pulseValue: pulseValue),
          ),

          // Teaser chip — streak (left side)
          Positioned(
            top: screenSize.height * 0.065 + float * 0.4,
            left: 0,
            child: _TeaserChip(
              icon: '🔥',
              label: '7 Day Streak',
              accentColor: const Color(0xFFF59E0B),
            ).animate()
                .fadeIn(duration: 500.ms, delay: 200.ms)
                .slideX(begin: -0.25, curve: Curves.easeOutCubic),
          ),

          // Teaser chip — insights (right side)
          Positioned(
            bottom: screenSize.height * 0.045 - float * 0.3,
            right: 0,
            child: _TeaserChip(
              icon: '✨',
              label: '3 New Insights',
              accentColor: AppColors.primary,
            ).animate()
                .fadeIn(duration: 500.ms, delay: 380.ms)
                .slideX(begin: 0.25, curve: Curves.easeOutCubic),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ScoreRingBadge extends StatelessWidget {
  final double pulseValue;
  const _ScoreRingBadge({required this.pulseValue});

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 0.88 + pulseValue * 0.12,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.95),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.20),
              blurRadius: 28,
              spreadRadius: 5,
            ),
            ...AppColors.cardShadow,
          ],
        ),
        child: CustomPaint(
          painter: const _ScoreArcPainter(),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '82',
                  style: AppTypography.h3.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    height: 1.0,
                  ),
                ),
                Text(
                  'SCORE',
                  style: AppTypography.overline.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 7.5,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate()
        .scale(
          begin: const Offset(0.5, 0.5),
          end: const Offset(1.0, 1.0),
          duration: 600.ms,
          delay: 100.ms,
          curve: Curves.easeOutBack,
        )
        .fadeIn(duration: 400.ms, delay: 100.ms);
  }
}

class _ScoreArcPainter extends CustomPainter {
  const _ScoreArcPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 7;
    const startAngle = math.pi * 0.75;
    const sweepMax   = math.pi * 1.5;

    // Track
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle, sweepMax, false,
      Paint()
        ..color = const Color(0xFFEDE8FF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5.5
        ..strokeCap = StrokeCap.round,
    );

    // Fill — 82%
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle, sweepMax * 0.82, false,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF8B6FEA), Color(0xFF6B4FD8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5.5
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_ScoreArcPainter old) => false;
}

// ─────────────────────────────────────────────────────────────────────────────

class _TeaserChip extends StatelessWidget {
  final String icon;
  final String label;
  final Color accentColor;

  const _TeaserChip({
    required this.icon,
    required this.label,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.12),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
          ...AppColors.cardShadow,
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _Sphere extends StatelessWidget {
  final double size;
  final Color color;
  final Color highlight;
  final Color shadow;

  const _Sphere({
    required this.size,
    required this.color,
    required this.highlight,
    required this.shadow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.35, -0.38),
          radius: 0.75,
          colors: [highlight, color, shadow],
          stops: const [0.0, 0.45, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.35),
            blurRadius: size * 0.4,
            offset: Offset(0, size * 0.18),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _InputCard extends StatelessWidget {
  final Widget child;
  const _InputCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      child: child,
    );
  }
}

class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'G',
      style: TextStyle(
        fontFamily: 'serif',
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Color(0xFF4285F4),
      ),
    );
  }
}
