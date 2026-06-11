import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/diq_logo.dart';
import '../../../../shared/widgets/app_button.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  WELCOME SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _sphereCtrl;
  late final AnimationController _pulseCtrl;
  late final AnimationController _floatCtrl;
  late final AnimationController _entranceCtrl;

  late final Animation<double> _sphere;
  late final Animation<double> _pulse;
  late final Animation<double> _float;
  late final Animation<double> _entrance;

  @override
  void initState() {
    super.initState();
    _sphereCtrl  = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat(reverse: true);
    _pulseCtrl   = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _floatCtrl   = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);
    _entranceCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();

    _sphere   = CurvedAnimation(parent: _sphereCtrl,  curve: Curves.easeInOut);
    _pulse    = Tween<double>(begin: 0.72, end: 1.0).animate(
                  CurvedAnimation(parent: _pulseCtrl,  curve: Curves.easeInOut));
    _float    = Tween<double>(begin: -10, end: 10).animate(
                  CurvedAnimation(parent: _floatCtrl,  curve: Curves.easeInOut));
    _entrance = CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _sphereCtrl.dispose();
    _pulseCtrl.dispose();
    _floatCtrl.dispose();
    _entranceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
              // ── Logo bar ──────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 20, 28, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const DiqLogo(size: DiqLogoSize.medium)
                        .animate().fadeIn(duration: 500.ms),
                    // "AI-Powered" badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.22),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6, height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary,
                              boxShadow: [
                                BoxShadow(color: AppColors.primary.withValues(alpha: 0.5), blurRadius: 5),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'AI-Powered',
                            style: GoogleFonts.poppins(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 500.ms, delay: 100.ms),
                  ],
                ),
              ),

              // ── Hero illustration ─────────────────────────────────────────
              Expanded(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: size.width * 0.78),
                  child: AnimatedBuilder(
                  animation: Listenable.merge([_sphere, _pulse, _float]),
                  builder: (_, child) => Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      // Glow bloom
                      Container(
                        width: size.width * 0.72,
                        height: size.width * 0.72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.62 * _pulse.value),
                              const Color(0xFFD4C0FF).withValues(alpha: 0.28 * _pulse.value),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),

                      // Face mesh painter
                      SizedBox(
                        width: size.width * 0.74,
                        height: size.width * 0.74,
                        child: CustomPaint(
                          painter: _WelcomeFacePainter(
                            pulse: _pulse.value,
                            float: _float.value,
                          ),
                        ),
                      ),

                      // Large sphere — bottom left (partially off-screen)
                      Positioned(
                        left: -size.width * 0.08 + 12 * sin(_sphere.value * pi * 0.7),
                        bottom: size.height * 0.04 + 16 * cos(_sphere.value * pi * 0.7),
                        child: _Sphere(size: 88, color: const Color(0xFF7258BC)),
                      ),

                      // Medium sphere — top right
                      Positioned(
                        right: size.width * 0.04 + 8 * cos(_sphere.value * pi),
                        top: size.height * 0.06 + 10 * sin(_sphere.value * pi),
                        child: _Sphere(size: 52, color: const Color(0xFF8B6FE8)),
                      ),

                      // Small sphere — mid left
                      Positioned(
                        left: size.width * 0.06 + 6 * sin(_sphere.value * pi * 1.4),
                        top: size.height * 0.38 + 8 * cos(_sphere.value * pi * 1.4),
                        child: _Sphere(size: 28, color: const Color(0xFF9878E0)),
                      ),

                      // ── Floating feature chips ─────────────────────────
                      // Top-left: AI Analysis
                      Positioned(
                        top: size.height * 0.05 + _float.value * 0.35,
                        left: 8,
                        child: _FeatureChip(
                          emoji: '🔬',
                          label: 'AI Analysis',
                        ),
                      ),

                      // Top-right: Skin Score
                      Positioned(
                        top: size.height * 0.12 + _float.value * -0.28,
                        right: 8,
                        child: _FeatureChip(
                          emoji: '✦',
                          label: 'Skin Score',
                          accent: AppColors.primary,
                        ),
                      ),

                      // Bottom-left: Hair Profile
                      Positioned(
                        bottom: size.height * 0.14 + _float.value * -0.22,
                        left: 8,
                        child: _FeatureChip(
                          emoji: '💧',
                          label: 'Hair Profile',
                          accent: const Color(0xFF60A5FA),
                        ),
                      ),

                      // Bottom-right: Safe Ingredients
                      Positioned(
                        bottom: size.height * 0.05 + _float.value * 0.3,
                        right: 8,
                        child: _FeatureChip(
                          emoji: '🛡️',
                          label: 'Safe Ingredients',
                          accent: const Color(0xFF34D399),
                        ),
                      ),

                      // Floating score ring badge (centre-right of face)
                      Positioned(
                        right: size.width * 0.12 + _float.value * 0.15,
                        top: size.height * 0.30 + _float.value * -0.18,
                        child: _ScoreRingBadge(pulse: _pulse.value),
                      ),
                    ],
                  ),
                ),
                ),
              ),

              // ── CTA section ───────────────────────────────────────────────
              FadeTransition(
                opacity: _entrance,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Overline
                      Text(
                        'TRUSTED BY 50,000+ USERS',
                        style: AppTypography.overline.copyWith(
                          color: AppColors.primary,
                          letterSpacing: 1.8,
                        ),
                      ).animate().fadeIn(duration: 400.ms, delay: 200.ms),

                      const SizedBox(height: 10),

                      // Headline
                      Text(
                        'Smart Skincare,\nScience-Backed.',
                        style: AppTypography.h2.copyWith(
                          color: const Color(0xFF1E1B4B),
                          height: 1.18,
                        ),
                        textAlign: TextAlign.center,
                      ).animate()
                        .fadeIn(duration: 500.ms, delay: 280.ms)
                        .slideY(begin: 0.14, curve: Curves.easeOutCubic),

                      const SizedBox(height: 10),

                      // Body
                      Text(
                        'Build your personalized skin & hair routine\nin minutes — free forever.',
                        style: AppTypography.bodyMedium.copyWith(
                          color: const Color(0xFF6B7280),
                          height: 1.55,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(duration: 500.ms, delay: 350.ms),

                      const SizedBox(height: 20),

                      // Trust strip
                      const _TrustStrip()
                          .animate().fadeIn(duration: 400.ms, delay: 420.ms),

                      const SizedBox(height: 24),

                      // Primary CTA
                      AppButton(
                        label: 'Create Account — It\'s Free',
                        onPressed: () => context.push('/register'),
                        icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                      ).animate()
                        .fadeIn(duration: 500.ms, delay: 480.ms)
                        .slideY(begin: 0.18),

                      const SizedBox(height: 12),

                      // Sign in outline
                      AppButton(
                        label: 'I already have an account',
                        onPressed: () => context.push('/login'),
                        isOutlined: true,
                      ).animate().fadeIn(duration: 500.ms, delay: 540.ms),

                      const SizedBox(height: 20),

                      // Guest link
                      GestureDetector(
                        onTap: () => context.go('/home'),
                        child: Text(
                          'Continue as Guest',
                          style: AppTypography.caption.copyWith(
                            color: const Color(0xFF9CA3AF),
                            decoration: TextDecoration.underline,
                            decorationColor: const Color(0xFF9CA3AF),
                          ),
                        ),
                      ).animate().fadeIn(duration: 400.ms, delay: 620.ms),
                    ],
                  ),
                ),
              ),
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
//  TRUST STRIP  — three social proof stats in a row
// ─────────────────────────────────────────────────────────────────────────────

class _TrustStrip extends StatelessWidget {
  const _TrustStrip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.70),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF7C5CFF).withValues(alpha: 0.10),
          width: 1,
        ),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _TrustStat(value: '50K+',  label: 'Users'),
          _Divider(),
          _TrustStat(value: '4.9 ★', label: 'Rating',  valueColor: const Color(0xFFF59E0B)),
          _Divider(),
          _TrustStat(value: '100%',  label: 'AI-Powered', valueColor: AppColors.primary),
        ],
      ),
    );
  }
}

class _TrustStat extends StatelessWidget {
  final String value;
  final String label;
  final Color? valueColor;
  const _TrustStat({required this.value, required this.label, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: valueColor ?? const Color(0xFF1E1B4B),
            height: 1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 9.5,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF9CA3AF),
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      color: const Color(0xFFEDE9FE),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  FLOATING FEATURE CHIP
// ─────────────────────────────────────────────────────────────────────────────

class _FeatureChip extends StatelessWidget {
  final String emoji;
  final String label;
  final Color? accent;
  const _FeatureChip({required this.emoji, required this.label, this.accent});

  @override
  Widget build(BuildContext context) {
    final color = accent ?? const Color(0xFF8B6FE8);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: color.withValues(alpha: 0.18),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.10),
            blurRadius: 16,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
          const BoxShadow(
            color: Color(0x18000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E1B4B),
            ),
          ),
        ],
      ),
    )
    .animate(delay: _chipDelay(label))
    .fadeIn(duration: 500.ms)
    .slideY(begin: 0.15, curve: Curves.easeOutCubic);
  }

  Duration _chipDelay(String l) {
    if (l.contains('Analysis'))    return 380.ms;
    if (l.contains('Score'))       return 460.ms;
    if (l.contains('Hair'))        return 540.ms;
    return 620.ms;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  FLOATING SCORE RING BADGE
// ─────────────────────────────────────────────────────────────────────────────

class _ScoreRingBadge extends StatelessWidget {
  final double pulse;
  const _ScoreRingBadge({required this.pulse});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.22 * pulse),
            blurRadius: 18,
            spreadRadius: 0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: CustomPaint(
        painter: _MiniScoreRingPainter(pulse: pulse),
        child: Center(
          child: Text(
            '82',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E1B4B),
              height: 1,
            ),
          ),
        ),
      ),
    )
    .animate(delay: 700.ms)
    .fadeIn(duration: 600.ms)
    .scale(begin: const Offset(0.7, 0.7), curve: Curves.easeOutBack);
  }
}

class _MiniScoreRingPainter extends CustomPainter {
  final double pulse;
  const _MiniScoreRingPainter({required this.pulse});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = (size.width - 6) / 2;

    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r), -pi / 2, 2 * pi, false,
      Paint()
        ..color = AppColors.primary.withValues(alpha: 0.10)
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke,
    );
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r), -pi / 2, 2 * pi * 0.82, false,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF6045CC), Color(0xFF8B68E8)],
        ).createShader(Rect.fromCircle(center: c, radius: r))
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_MiniScoreRingPainter old) => old.pulse != pulse;
}

// ─────────────────────────────────────────────────────────────────────────────
//  3-D SPHERE
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

// ─────────────────────────────────────────────────────────────────────────────
//  FACE MESH PAINTER
// ─────────────────────────────────────────────────────────────────────────────

class _WelcomeFacePainter extends CustomPainter {
  final double pulse;
  final double float;
  const _WelcomeFacePainter({required this.pulse, required this.float});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width  * 0.52;
    final cy = size.height * 0.50 + float * 0.3;
    final fw = size.width  * 0.52;
    final fh = size.height * 0.72;

    // Outer glow
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy), width: fw * 1.30, height: fh * 1.20),
      Paint()
        ..shader = RadialGradient(colors: [
          Colors.white.withValues(alpha: 0.16 * pulse),
          const Color(0xFFD4C0FF).withValues(alpha: 0.06 * pulse),
          Colors.transparent,
        ]).createShader(Rect.fromCenter(
          center: Offset(cx, cy), width: fw * 1.30, height: fh * 1.20,
        )),
    );

    // Face oval
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy), width: fw, height: fh),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.72 * pulse)
        ..strokeWidth = 1.6
        ..style = PaintingStyle.stroke,
    );

    // Mesh — horizontal
    final meshH = Paint()
      ..color = const Color(0xFFBBA8EE).withValues(alpha: 0.28)
      ..strokeWidth = 0.6
      ..style = PaintingStyle.stroke;

    for (int i = -9; i <= 9; i++) {
      final t  = i / 9.0;
      final y  = cy + t * (fh / 2);
      final hw = (fw / 2) * sqrt(max(0.0, 1 - t * t));
      if (hw < 3) continue;
      canvas.drawLine(Offset(cx - hw, y), Offset(cx + hw, y), meshH);
    }

    // Mesh — vertical
    final meshV = Paint()
      ..color = const Color(0xFFBBA8EE).withValues(alpha: 0.24)
      ..strokeWidth = 0.6
      ..style = PaintingStyle.stroke;

    for (int i = -7; i <= 7; i++) {
      final t  = i / 7.0;
      final x  = cx + t * (fw / 2);
      final hh = (fh / 2) * sqrt(max(0.0, 1 - t * t));
      if (hh < 3) continue;
      canvas.drawLine(Offset(x, cy - hh), Offset(x, cy + hh), meshV);
    }

    // Landmark dots with 3-layer glow
    const landmarks = [
      // Eyes
      [-0.23, -0.14, 3.8],
      [ 0.17, -0.14, 3.8],
      // Brows
      [-0.28, -0.22, 2.6],
      [ 0.20, -0.22, 2.6],
      [-0.14, -0.26, 2.3],
      [ 0.09, -0.26, 2.3],
      // Nose
      [ 0.00,  0.05, 3.2],
      [-0.05,  0.14, 2.0],
      [ 0.05,  0.14, 2.0],
      // Lips
      [-0.09,  0.24, 2.6],
      [ 0.09,  0.24, 2.6],
      [ 0.00,  0.29, 2.0],
      // Cheeks
      [-0.34,  0.06, 2.6],
      [ 0.28,  0.06, 2.6],
      // Chin
      [ 0.00,  0.44, 3.2],
      // Forehead
      [ 0.00, -0.40, 3.2],
      [-0.16, -0.34, 2.2],
      [ 0.12, -0.34, 2.2],
      // Temple
      [-0.40, -0.14, 2.2],
      [ 0.34, -0.14, 2.2],
      // Jaw
      [-0.36,  0.22, 2.2],
      [ 0.30,  0.22, 2.2],
    ];

    for (final pt in landmarks) {
      final ox  = cx + fw * pt[0];
      final oy  = cy + fh * pt[1];
      final rad = pt[2];

      canvas.drawCircle(Offset(ox, oy), rad * 2.8,
        Paint()..color = Colors.white.withValues(alpha: 0.16 * pulse));
      canvas.drawCircle(Offset(ox, oy), rad * 1.65,
        Paint()..color = const Color(0xFFD4C0FF).withValues(alpha: 0.38 * pulse));
      canvas.drawCircle(Offset(ox, oy), rad,
        Paint()..color = Colors.white.withValues(alpha: 0.90 * pulse));
    }

    // Hair streams — 5 bezier curves sweeping left
    final hairPaint = Paint()
      ..color = const Color(0xFFD4C0FF).withValues(alpha: 0.30)
      ..strokeWidth = 0.72
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final streams = [
      [-0.08,  -0.44,  -0.52, -0.58,  -0.95, -0.44,  -1.48, -0.18],
      [-0.04,  -0.40,  -0.44, -0.56,  -0.88, -0.36,  -1.35, -0.05],
      [ 0.00,  -0.45,  -0.38, -0.70,  -0.82, -0.52,  -1.26, -0.26],
      [ 0.06,  -0.41,  -0.32, -0.66,  -0.76, -0.46,  -1.14, -0.12],
      [-0.14,  -0.38,  -0.58, -0.48,  -1.02, -0.28,  -1.56,  0.08],
    ];

    for (int si = 0; si < streams.length; si++) {
      final s  = streams[si];
      final dy = float * 5 * (si % 2 == 0 ? 1 : -1);
      final path = Path()
        ..moveTo(cx + fw * s[0], cy + fh * s[1] + dy)
        ..cubicTo(
          cx + fw * s[2], cy + fh * s[3] + dy * 0.65,
          cx + fw * s[4], cy + fh * s[5] + dy * 0.35,
          cx + fw * s[6], cy + fh * s[7],
        );
      canvas.drawPath(path, hairPaint);
    }

    // Neck suggestion
    final neckPaint = Paint()
      ..color = const Color(0xFFD4C0FF).withValues(alpha: 0.20)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(cx - fw * 0.11, cy + fh * 0.48),
      Offset(cx - fw * 0.09, cy + fh * 0.60),
      neckPaint,
    );
    canvas.drawLine(
      Offset(cx + fw * 0.11, cy + fh * 0.48),
      Offset(cx + fw * 0.09, cy + fh * 0.60),
      neckPaint,
    );
  }

  @override
  bool shouldRepaint(_WelcomeFacePainter old) =>
      old.pulse != pulse || old.float != float;
}
