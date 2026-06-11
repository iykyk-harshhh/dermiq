import 'dart:math' as math;
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  AI FACE PARTICLE ARTWORK
//
//  A right-facing female side-profile built from ~900 glowing particles plus
//  leftward-flowing hair streams. Particles are generated ONCE in normalized
//  (0–1) space; the painter only applies cheap per-frame wave + twinkle
//  transforms, so it holds 60fps.
// ─────────────────────────────────────────────────────────────────────────────

const _white = Color(0xFFFFFFFF);
const _lavender = Color(0xFFC9B8FF);
const _softLavender = Color(0xFFE3D9FF);
const _glowPurple = Color(0xFF6C4BFF);

/// Right-facing head + neck silhouette (normalized, x→right, y→down).
const List<Offset> _silhouette = [
  Offset(0.46, 0.05), // crown top
  Offset(0.66, 0.10), // forehead
  Offset(0.74, 0.20), // brow ridge
  Offset(0.72, 0.28), // brow
  Offset(0.78, 0.36), // nose bridge
  Offset(0.83, 0.41), // nose top
  Offset(0.92, 0.47), // nose tip (rightmost)
  Offset(0.83, 0.50), // nostril base
  Offset(0.85, 0.53), // philtrum
  Offset(0.87, 0.55), // upper lip
  Offset(0.86, 0.575), // mouth
  Offset(0.84, 0.60), // lower lip
  Offset(0.85, 0.63), // chin crease
  Offset(0.81, 0.68), // chin
  Offset(0.70, 0.74), // jaw
  Offset(0.60, 0.77), // jaw back
  Offset(0.585, 0.84), // neck front
  Offset(0.55, 0.95), // neck front bottom
  Offset(0.40, 0.95), // neck back bottom
  Offset(0.40, 0.78), // nape
  Offset(0.36, 0.68), // neck back
  Offset(0.26, 0.56), // back lower head
  Offset(0.18, 0.42), // back head
  Offset(0.18, 0.28), // back upper
  Offset(0.26, 0.14), // crown back
];

/// Hair streams: cubic beziers sweeping LEFT off the crown / upper back.
const List<List<Offset>> _hairStreams = [
  [Offset(0.55, 0.10), Offset(0.30, 0.02), Offset(0.05, 0.10), Offset(-0.18, 0.06)],
  [Offset(0.60, 0.14), Offset(0.32, 0.06), Offset(0.02, 0.16), Offset(-0.20, 0.14)],
  [Offset(0.50, 0.07), Offset(0.25, 0.00), Offset(-0.02, 0.06), Offset(-0.22, 0.00)],
  [Offset(0.62, 0.20), Offset(0.34, 0.14), Offset(0.04, 0.24), Offset(-0.18, 0.24)],
  [Offset(0.45, 0.10), Offset(0.20, 0.08), Offset(-0.05, 0.18), Offset(-0.25, 0.20)],
  [Offset(0.58, 0.24), Offset(0.30, 0.22), Offset(0.00, 0.32), Offset(-0.20, 0.34)],
  [Offset(0.40, 0.16), Offset(0.18, 0.18), Offset(-0.06, 0.30), Offset(-0.26, 0.34)],
];

enum ParticleKind { contour, fill, hair }

class FaceParticle {
  final Offset base; // normalized 0–1
  final double size;
  final double brightness; // 0–1
  final double phase; // animation offset
  final ParticleKind kind;
  final int stream; // hair stream index (-1 otherwise)

  const FaceParticle(
    this.base,
    this.size,
    this.brightness,
    this.phase,
    this.kind, [
    this.stream = -1,
  ]);
}

Offset _bezier(List<Offset> p, double t) {
  final mt = 1 - t;
  final a = mt * mt * mt;
  final b = 3 * mt * mt * t;
  final c = 3 * mt * t * t;
  final d = t * t * t;
  return Offset(
    a * p[0].dx + b * p[1].dx + c * p[2].dx + d * p[3].dx,
    a * p[0].dy + b * p[1].dy + c * p[2].dy + d * p[3].dy,
  );
}

bool _pointInPolygon(Offset pt, List<Offset> poly) {
  var inside = false;
  for (var i = 0, j = poly.length - 1; i < poly.length; j = i++) {
    final pi = poly[i], pj = poly[j];
    if (((pi.dy > pt.dy) != (pj.dy > pt.dy)) &&
        (pt.dx <
            (pj.dx - pi.dx) * (pt.dy - pi.dy) / (pj.dy - pi.dy) + pi.dx)) {
      inside = !inside;
    }
  }
  return inside;
}

double _distToPolygon(Offset pt, List<Offset> poly) {
  var best = double.infinity;
  for (var i = 0, j = poly.length - 1; i < poly.length; j = i++) {
    best = math.min(best, _distToSegment(pt, poly[j], poly[i]));
  }
  return best;
}

double _distToSegment(Offset p, Offset a, Offset b) {
  final dx = b.dx - a.dx, dy = b.dy - a.dy;
  final len2 = dx * dx + dy * dy;
  if (len2 == 0) return (p - a).distance;
  var t = ((p.dx - a.dx) * dx + (p.dy - a.dy) * dy) / len2;
  t = t.clamp(0.0, 1.0);
  return (p - Offset(a.dx + t * dx, a.dy + t * dy)).distance;
}

/// Builds the particle cloud once (seeded → deterministic).
List<FaceParticle> buildFaceParticles() {
  final rnd = math.Random(42);
  final out = <FaceParticle>[];

  // 1. Contour — bright white dots along the silhouette edge.
  for (var i = 0; i < _silhouette.length; i++) {
    final a = _silhouette[i];
    final b = _silhouette[(i + 1) % _silhouette.length];
    final segLen = (b - a).distance;
    final steps = math.max(2, (segLen / 0.012).round());
    for (var s = 0; s < steps; s++) {
      final t = s / steps;
      final p = Offset(a.dx + (b.dx - a.dx) * t, a.dy + (b.dy - a.dy) * t);
      final jitter = Offset(
        (rnd.nextDouble() - 0.5) * 0.008,
        (rnd.nextDouble() - 0.5) * 0.008,
      );
      out.add(FaceParticle(
        p + jitter,
        1.4 + rnd.nextDouble() * 0.9,
        0.85 + rnd.nextDouble() * 0.15,
        rnd.nextDouble() * math.pi * 2,
        ParticleKind.contour,
      ));
    }
  }

  // 2. Fill — interior particles, denser & brighter near the edge.
  var attempts = 0;
  var filled = 0;
  while (filled < 540 && attempts < 6000) {
    attempts++;
    final p = Offset(0.15 + rnd.nextDouble() * 0.80, 0.04 + rnd.nextDouble() * 0.92);
    if (!_pointInPolygon(p, _silhouette)) continue;
    final d = _distToPolygon(p, _silhouette); // ~0..0.4
    final edge = (1 - (d / 0.18)).clamp(0.0, 1.0);
    // Bias toward edges: skip some deep-interior points.
    if (edge < 0.25 && rnd.nextDouble() > 0.45) continue;
    out.add(FaceParticle(
      p,
      0.8 + rnd.nextDouble() * 1.3,
      0.25 + edge * 0.55,
      rnd.nextDouble() * math.pi * 2,
      ParticleKind.fill,
    ));
    filled++;
  }

  // 3. Hair — flowing dots along each stream, fading toward the tail.
  for (var si = 0; si < _hairStreams.length; si++) {
    final stream = _hairStreams[si];
    const count = 24;
    for (var i = 0; i < count; i++) {
      final t = i / (count - 1);
      final p = _bezier(stream, t);
      final jitter = Offset(
        (rnd.nextDouble() - 0.5) * 0.02,
        (rnd.nextDouble() - 0.5) * 0.02,
      );
      out.add(FaceParticle(
        p + jitter,
        1.0 + rnd.nextDouble() * 1.0,
        (0.6 - t * 0.45).clamp(0.12, 0.6),
        t * math.pi * 2 + si,
        ParticleKind.hair,
        si,
      ));
    }
  }

  return out;
}

class ParticleFacePainter extends CustomPainter {
  final List<FaceParticle> particles;
  final double t; // 0..1 animation time
  final double breath; // 0..1 breathing

  ParticleFacePainter({
    required this.particles,
    required this.t,
    required this.breath,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final twoPi = math.pi * 2;

    // ── Ambient glow bloom behind the face ──────────────────────────────────
    final glowPulse = 0.5 + 0.5 * math.sin(t * twoPi);
    canvas.drawCircle(
      Offset(w * 0.55, h * 0.42),
      w * 0.42,
      Paint()
        ..shader = RadialGradient(
          colors: [
            _white.withValues(alpha: 0.20 * (0.7 + 0.3 * glowPulse)),
            _glowPurple.withValues(alpha: 0.10 * (0.7 + 0.3 * glowPulse)),
            Colors.transparent,
          ],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(Rect.fromCircle(
          center: Offset(w * 0.55, h * 0.42),
          radius: w * 0.42,
        )),
    );

    // Breathing scale about the face centre.
    final scale = 1.0 + 0.012 * (breath - 0.5) * 2;
    final cx = w * 0.55, cy = h * 0.42;

    Offset place(Offset base, double phase, double amp) {
      // Slow wave: vertical drift varies with x; horizontal sway with y.
      final wave = math.sin(t * twoPi + phase + base.dx * 6) * amp;
      final sway = math.cos(t * twoPi + phase + base.dy * 5) * amp * 0.6;
      var x = base.dx * w + sway;
      var y = base.dy * h + wave;
      // apply breathing scale around centre
      x = cx + (x - cx) * scale;
      y = cy + (y - cy) * scale;
      return Offset(x, y);
    }

    // ── Hair flow lines (the "connected by flowing paths" look) ─────────────
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6
      ..strokeCap = StrokeCap.round;
    final byStream = <int, List<MapEntry<FaceParticle, Offset>>>{};
    for (final p in particles) {
      if (p.kind != ParticleKind.hair) continue;
      (byStream[p.stream] ??= []).add(MapEntry(p, place(p.base, p.phase, 4)));
    }
    for (final entry in byStream.values) {
      for (var i = 0; i < entry.length - 1; i++) {
        final a = entry[i], b = entry[i + 1];
        canvas.drawLine(
          a.value, b.value,
          linePaint
            ..color = _lavender.withValues(
                alpha: (a.key.brightness * 0.35).clamp(0.0, 0.4)),
        );
      }
    }

    // ── Particles ───────────────────────────────────────────────────────────
    for (final p in particles) {
      final amp = p.kind == ParticleKind.hair ? 4.0 : 2.2;
      final pos = place(p.base, p.phase, amp);
      final twinkle = 0.7 + 0.3 * math.sin(t * twoPi * 2 + p.phase);
      final alpha = (p.brightness * twinkle).clamp(0.0, 1.0);

      final color = switch (p.kind) {
        ParticleKind.contour => _white,
        ParticleKind.fill => p.brightness > 0.55 ? _white : _lavender,
        ParticleKind.hair => _softLavender,
      };

      // Soft glow halo for the brighter dots.
      if (p.brightness > 0.6) {
        canvas.drawCircle(
          pos, p.size * 2.4,
          Paint()
            ..color = color.withValues(alpha: alpha * 0.18)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5),
        );
      }
      canvas.drawCircle(
        pos, p.size,
        Paint()..color = color.withValues(alpha: alpha.clamp(0.0, 0.85)),
      );
    }
  }

  @override
  bool shouldRepaint(ParticleFacePainter old) =>
      old.t != t || old.breath != breath || old.particles != particles;
}
