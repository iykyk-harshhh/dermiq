import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// A single floating particle used in the hero face background.
class Particle {
  final double x;        // 0–1 normalised position
  final double y;
  final double radius;
  final double speed;
  final double phase;    // phase offset for sin drift

  const Particle({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.phase,
  });
}

/// Generates a fixed set of particles (deterministic — same seed every build).
List<Particle> buildParticles(int count) {
  final rng = Random(42);
  return List.generate(count, (_) => Particle(
        x: rng.nextDouble(),
        y: rng.nextDouble(),
        radius: 1.5 + rng.nextDouble() * 3.0,
        speed: 0.3 + rng.nextDouble() * 0.7,
        phase: rng.nextDouble() * 2 * pi,
      ));
}

/// Paints floating glowing particles for the AI-face background.
///
/// [tick]   0→1 looping animation value (from a repeating controller)
/// [onDark] true for hero/splash, false for light screens
class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double tick;
  final bool onDark;
  final double opacity;

  const ParticlePainter({
    required this.particles,
    required this.tick,
    this.onDark = true,
    this.opacity = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final t = (tick * p.speed + p.phase) % (2 * pi);
      final px = p.x * size.width  + sin(t) * 12;
      final py = p.y * size.height + cos(t * 0.7) * 8;

      final baseColor = onDark ? AppColors.lavender : AppColors.primary;
      final alpha = (0.3 + 0.4 * sin(t + p.phase)) * opacity;

      // Glow halo
      canvas.drawCircle(
        Offset(px, py),
        p.radius * 3,
        Paint()
          ..color = baseColor.withValues(alpha: alpha * 0.2)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
      // Core dot
      canvas.drawCircle(
        Offset(px, py),
        p.radius,
        Paint()..color = baseColor.withValues(alpha: alpha),
      );
    }
  }

  @override
  bool shouldRepaint(ParticlePainter old) =>
      old.tick != tick || old.opacity != opacity;
}
