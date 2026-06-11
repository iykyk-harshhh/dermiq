import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/motion/app_animations.dart';
import '../painters/mesh_face_painter.dart';
import '../painters/particle_painter.dart';

/// The DermIQ AI hero face — animated mesh + floating particles.
///
/// Used on:
///  • Splash screen
///  • Onboarding hero
///  • Loading / empty states
///
/// [size]      Widget size (width = height)
/// [onDark]    true when placed on a dark/gradient background
/// [showParticles] whether to show the surrounding particle system
class AiMeshFace extends StatefulWidget {
  final double size;
  final bool onDark;
  final bool showParticles;
  final bool autoReveal;

  const AiMeshFace({
    super.key,
    this.size = 280,
    this.onDark = true,
    this.showParticles = true,
    this.autoReveal = true,
  });

  @override
  State<AiMeshFace> createState() => _AiMeshFaceState();
}

class _AiMeshFaceState extends State<AiMeshFace>
    with TickerProviderStateMixin {
  late final AnimationController _revealCtrl;
  late final AnimationController _pulseCtrl;
  late final AnimationController _driftCtrl;
  late final AnimationController _particleCtrl;

  late final Animation<double> _reveal;
  late final Animation<double> _pulse;
  late final Animation<double> _drift;

  final _particles = buildParticles(28);

  @override
  void initState() {
    super.initState();

    _revealCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: AppAnimations.glowPulse,
    )..repeat(reverse: true);
    _driftCtrl = AnimationController(
      vsync: this,
      duration: AppAnimations.meshBreath,
    )..repeat();
    _particleCtrl = AnimationController(
      vsync: this,
      duration: AppAnimations.particleDrift,
    )..repeat();

    _reveal = CurvedAnimation(
      parent: _revealCtrl,
      curve: Curves.easeOutCubic,
    );
    _pulse = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    _drift = Tween<double>(begin: 0, end: 1).animate(_driftCtrl);

    if (widget.autoReveal) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) _revealCtrl.forward();
      });
    } else {
      _revealCtrl.value = 1.0;
    }
  }

  @override
  void dispose() {
    _revealCtrl.dispose();
    _pulseCtrl.dispose();
    _driftCtrl.dispose();
    _particleCtrl.dispose();
    super.dispose();
  }

  void reveal() => _revealCtrl.forward(from: 0);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: Listenable.merge(
            [_reveal, _pulse, _drift, _particleCtrl]),
        builder: (_, _) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // ── Outer glow ring ─────────────────────────────────────────
              _GlowRing(
                size: widget.size,
                progress: _reveal.value,
                pulse: _pulse.value,
                onDark: widget.onDark,
              ),

              // ── Floating particles ──────────────────────────────────────
              if (widget.showParticles)
                Positioned.fill(
                  child: CustomPaint(
                    painter: ParticlePainter(
                      particles: _particles,
                      tick: _particleCtrl.value * 2 * pi,
                      onDark: widget.onDark,
                      opacity: _reveal.value,
                    ),
                  ),
                ),

              // ── Mesh face ───────────────────────────────────────────────
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: MeshFacePainter(
                  progress: _reveal.value,
                  pulse: _pulse.value,
                  drift: _drift.value,
                  onDark: widget.onDark,
                ),
              ),

              // ── Centre face icon (fallback until mesh is visible) ───────
              if (_reveal.value < 0.2)
                Icon(
                  Icons.face_retouching_natural_outlined,
                  size: widget.size * 0.3,
                  color: (widget.onDark ? Colors.white : AppColors.primary)
                      .withValues(alpha: 0.2),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _GlowRing extends StatelessWidget {
  final double size;
  final double progress;
  final double pulse;
  final bool onDark;

  const _GlowRing({
    required this.size,
    required this.progress,
    required this.pulse,
    required this.onDark,
  });

  @override
  Widget build(BuildContext context) {
    if (progress < 0.1) return const SizedBox.shrink();
    final color = onDark ? AppColors.lavender : AppColors.primary;
    final alpha = 0.08 + 0.12 * pulse * progress;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: alpha),
            color.withValues(alpha: 0),
          ],
          stops: const [0.3, 1.0],
        ),
      ),
    );
  }
}
