import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Three 3-D gradient spheres that float up/down on an infinite 6-second loop.
/// Positioned relative to the top face artwork (see the reference layout).
class FloatingSpheres extends StatefulWidget {
  const FloatingSpheres({super.key});

  @override
  State<FloatingSpheres> createState() => _FloatingSpheresState();
}

class _FloatingSpheresState extends State<FloatingSpheres>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth, h = c.maxHeight;
        return AnimatedBuilder(
          animation: _ctrl,
          builder: (_, _) {
            final t = _ctrl.value * math.pi * 2;
            return Stack(
              children: [
                // Sphere 1 — size 90, top center.
                _positioned(
                  left: w * 0.50, top: h * 0.10, phase: t,
                  child: const _Sphere(
                    size: 90, start: Color(0xFF6C4BFF), end: Color(0xFF9B7BFF)),
                ),
                // Sphere 2 — size 45, top right.
                _positioned(
                  left: w * 0.78, top: h * 0.14, phase: t + 2.1,
                  child: const _Sphere(
                    size: 45, start: Color(0xFFBFAAFF), end: Color(0xFFF5F0FF)),
                ),
                // Sphere 3 — size 110, left middle (partially off-screen).
                _positioned(
                  left: -w * 0.06, top: h * 0.30, phase: t + 4.0,
                  child: const _Sphere(
                    size: 110, start: Color(0xFF6C4BFF), end: Color(0xFFA48BFF)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _positioned({
    required double left,
    required double top,
    required double phase,
    required Widget child,
  }) {
    final dy = math.sin(phase) * 12; // float ±12px
    return Positioned(left: left, top: top + dy, child: child);
  }
}

class _Sphere extends StatelessWidget {
  final double size;
  final Color start;
  final Color end;

  const _Sphere({required this.size, required this.start, required this.end});

  @override
  Widget build(BuildContext context) {
    final highlight = Color.lerp(start, Colors.white, 0.6)!;
    final shadow = Color.lerp(end, const Color(0xFF2F216F), 0.25)!;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.4, -0.4),
          radius: 0.95,
          colors: [highlight, start, shadow],
          stops: const [0.0, 0.55, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: start.withValues(alpha: 0.40),
            blurRadius: size * 0.5,
            offset: Offset(size * 0.06, size * 0.12),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.25),
            blurRadius: size * 0.18,
            offset: Offset(-size * 0.08, -size * 0.08),
          ),
        ],
      ),
    );
  }
}
