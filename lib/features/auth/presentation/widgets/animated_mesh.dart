import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Soft purple wave-mesh glow for the bottom ~25% of the splash. Blurred sine
/// bands + faint drifting particles at ~10% opacity, animated slowly.
class AnimatedMesh extends StatefulWidget {
  const AnimatedMesh({super.key});

  @override
  State<AnimatedMesh> createState() => _AnimatedMeshState();
}

class _AnimatedMeshState extends State<AnimatedMesh>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<_MeshDot> _dots;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
    final rnd = math.Random(7);
    _dots = List.generate(
      60,
      (_) => _MeshDot(
        rnd.nextDouble(),
        rnd.nextDouble(),
        0.6 + rnd.nextDouble() * 1.8,
        rnd.nextDouble() * math.pi * 2,
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) => CustomPaint(
        painter: _MeshPainter(t: _ctrl.value, dots: _dots),
      ),
    );
  }
}

class _MeshDot {
  final double x, y, size, phase;
  const _MeshDot(this.x, this.y, this.size, this.phase);
}

class _MeshPainter extends CustomPainter {
  final double t;
  final List<_MeshDot> dots;
  const _MeshPainter({required this.t, required this.dots});

  static const _purple = Color(0xFF6C4BFF);
  static const _violet = Color(0xFFB084FF);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final twoPi = math.pi * 2;

    // Blurred wave bands.
    final bandPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 22
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24);

    for (var b = 0; b < 3; b++) {
      final baseY = h * (0.45 + b * 0.20);
      final amp = 16.0 + b * 6;
      final speed = t * twoPi * (1 + b * 0.3);
      final path = Path()..moveTo(0, baseY);
      for (double x = 0; x <= w; x += 12) {
        final y = baseY + math.sin(x / w * twoPi * 1.4 + speed) * amp;
        path.lineTo(x, y);
      }
      canvas.drawPath(
        path,
        bandPaint
          ..color = (b.isEven ? _purple : _violet).withValues(alpha: 0.10),
      );
    }

    // Drifting particles.
    for (final d in dots) {
      final drift = math.sin(t * twoPi + d.phase) * 0.04;
      final pos = Offset((d.x + drift) % 1.0 * w, d.y * h);
      final alpha = 0.10 * (0.5 + 0.5 * math.sin(t * twoPi * 2 + d.phase));
      canvas.drawCircle(
        pos, d.size,
        Paint()..color = _violet.withValues(alpha: alpha.clamp(0.0, 0.12)),
      );
    }
  }

  @override
  bool shouldRepaint(_MeshPainter old) => old.t != t;
}
