import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/services/preferences_service.dart';
import '../../providers/auth_provider.dart';
import '../widgets/animated_mesh.dart';
import '../widgets/floating_spheres.dart';
import '../widgets/glowing_button.dart';
import '../widgets/particle_face_painter.dart';

// Splash palette (per the motion-graphics spec).
//   Background #F5F1FF · Primary Purple #6C4BFF · Dark Purple #2F216F · White #FFFFFF
const _kBackground = Color(0xFFF5F1FF);
const _kInk = Color(0xFF2F216F); // dark purple (logo)
const _kPrimary = Color(0xFF6C4BFF); // primary purple
const _kSparkle = _kPrimary;
const _kDivider = Color(0xFFB084FF);
const _kSubtitle = _kPrimary;

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _flowCtrl; // particle flow + breathing
  late final AnimationController _entryCtrl; // text fade-up
  late final List<FaceParticle> _particles;

  @override
  void initState() {
    super.initState();
    _particles = buildFaceParticles();
    _flowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();
  }

  /// SplashController — every flow funnels through the Get Started CTA:
  ///   signed in           → Home
  ///   onboarding pending   → Onboarding
  ///   onboarding done      → Login
  void _onGetStarted() {
    final loggedIn = ref.read(authStateProvider) != null;
    if (loggedIn) {
      context.go('/home');
    } else if (!PreferencesService.onboardingSeen) {
      context.go('/onboarding');
    } else {
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _flowCtrl.dispose();
    _entryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final faceHeight = size.height * 0.42;

    final fade = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    final slide = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic));

    return Scaffold(
      backgroundColor: _kBackground,
      body: Stack(
        children: [
          // ── Subtly shifting background gradient ─────────────────────────────
          AnimatedBuilder(
            animation: _flowCtrl,
            builder: (_, _) {
              final t = _flowCtrl.value;
              return DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(-1 + t * 0.4, -1),
                    end: Alignment(1, 1 - t * 0.4),
                    colors: const [
                      Color(0xFFF8F5FF),
                      _kBackground,
                      Color(0xFFEFE7FF),
                    ],
                  ),
                ),
                child: const SizedBox.expand(),
              );
            },
          ),

          // ── Bottom glow mesh (bottom 25%) ───────────────────────────────────
          Positioned(
            left: 0, right: 0, bottom: 0,
            height: size.height * 0.25,
            child: const AnimatedMesh(),
          ),

          // ── AI face particle artwork (top, 85% × 42%) ───────────────────────
          Positioned(
            top: 0,
            left: size.width * 0.075,
            width: size.width * 0.85,
            height: faceHeight + size.height * 0.06,
            child: AnimatedBuilder(
              animation: _flowCtrl,
              builder: (_, _) => CustomPaint(
                painter: ParticleFacePainter(
                  particles: _particles,
                  t: _flowCtrl.value,
                  breath: 0.5 + 0.5 *
                      (1 - (2 * _flowCtrl.value - 1).abs()), // triangle 0→1→0
                ),
              ),
            ),
          ),

          // ── Floating spheres (over the face region) ─────────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            height: faceHeight + size.height * 0.06,
            child: const FloatingSpheres(),
          ),

          // ── Foreground content ──────────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  SizedBox(height: faceHeight),
                  Expanded(
                    child: FadeTransition(
                      opacity: fade,
                      child: SlideTransition(
                        position: slide,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const _Wordmark(),
                            const SizedBox(height: 16),
                            // Frosted-glass card softening the moving particle
                            // layers behind the tagline (Apple-glass polish).
                            ClipRRect(
                              borderRadius: BorderRadius.circular(28),
                              child: BackdropFilter(
                                filter:
                                    ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 22),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.30),
                                    borderRadius: BorderRadius.circular(28),
                                    border: Border.all(
                                      color:
                                          Colors.white.withValues(alpha: 0.55),
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Smart skincare, just for you.',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.inter(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                          color: _kInk,
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                      Container(
                                        width: 48,
                                        height: 3,
                                        decoration: BoxDecoration(
                                          color: _kDivider,
                                          borderRadius:
                                              BorderRadius.circular(3),
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                      Text(
                                        'AI-powered skin insights\nfor healthier, happier skin.',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.inter(
                                          fontSize: 16,
                                          height: 1.6,
                                          fontWeight: FontWeight.w400,
                                          color: _kSubtitle.withValues(
                                              alpha: 0.70),
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
                    ),
                  ),
                  // Get Started CTA (85% width) — routes per SplashController.
                  FadeTransition(
                    opacity: fade,
                    child: FractionallySizedBox(
                      widthFactor: 0.85,
                      child: GlowingButton(onTap: _onGetStarted),
                    ),
                  ),
                  SizedBox(height: size.height * 0.05),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Wordmark: "dermiq" with a sparkle above the "i" ──────────────────────────

class _Wordmark extends StatelessWidget {
  const _Wordmark();

  @override
  Widget build(BuildContext context) {
    final base = GoogleFonts.playfairDisplay(
      fontSize: 72,
      fontWeight: FontWeight.bold,
      color: Colors.white, // overwritten by the ShaderMask gradient
      letterSpacing: -1,
      height: 1.0,
    );
    // Luxury serif logo painted with a dark-purple → primary-purple gradient.
    return ShaderMask(
      shaderCallback: (rect) => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [_kInk, _kPrimary],
      ).createShader(rect),
      blendMode: BlendMode.srcIn,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('derm', style: base),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Text('i', style: base),
              const Positioned(
                top: 6,
                right: -10,
                child: Icon(Icons.auto_awesome, size: 12, color: _kSparkle),
              ),
            ],
          ),
          Text('q', style: base),
        ],
      ),
    );
  }
}
