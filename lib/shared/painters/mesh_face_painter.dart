import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Draws the DermIQ AI face mesh.
///
/// [progress]   0→1 reveal animation
/// [pulse]      0→1 breathing / glow cycle
/// [drift]      0→1 subtle floating offset
/// [onDark]     true on hero/splash, false on light background
class MeshFacePainter extends CustomPainter {
  final double progress;
  final double pulse;
  final double drift;
  final bool onDark;

  const MeshFacePainter({
    required this.progress,
    required this.pulse,
    this.drift = 0,
    this.onDark = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress < 0.05) return;

    final cx = size.width / 2;
    final cy = size.height / 2 + sin(drift * pi) * 4;

    final faceW = size.width * 0.72 * progress;
    final faceH = size.height * 0.88 * progress;

    final baseAlpha = progress * (0.5 + 0.5 * pulse);
    final lineColor = onDark
        ? AppColors.lavender.withValues(alpha: 0.18 * baseAlpha)
        : AppColors.primary.withValues(alpha: 0.12 * baseAlpha);
    final accentColor = onDark
        ? AppColors.lavender.withValues(alpha: 0.7 * baseAlpha)
        : AppColors.primary.withValues(alpha: 0.55 * baseAlpha);
    final dotColor = onDark
        ? Colors.white.withValues(alpha: 0.6 * baseAlpha)
        : AppColors.primary.withValues(alpha: 0.8 * baseAlpha);

    final gridPaint = Paint()
      ..color = lineColor
      ..strokeWidth = 0.6
      ..style = PaintingStyle.stroke;

    final accentPaint = Paint()
      ..color = accentColor
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;

    // ── Face oval ────────────────────────────────────────────────────────────
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy),
        width: faceW,
        height: faceH,
      ),
      accentPaint,
    );

    // ── Horizontal grid lines ─────────────────────────────────────────────
    for (int i = -4; i <= 4; i++) {
      final t = i / 4.0;
      final y = cy + t * (faceH / 2);
      final halfW = (faceW / 2) * sqrt(max(0, 1 - t * t));
      if (halfW < 1) continue;
      canvas.drawLine(Offset(cx - halfW, y), Offset(cx + halfW, y), gridPaint);
    }

    // ── Vertical grid lines ───────────────────────────────────────────────
    for (int i = -4; i <= 4; i++) {
      final t = i / 4.0;
      final x = cx + t * (faceW / 2);
      final halfH = (faceH / 2) * sqrt(max(0, 1 - t * t));
      if (halfH < 1) continue;
      canvas.drawLine(Offset(x, cy - halfH), Offset(x, cy + halfH), gridPaint);
    }

    // ── Feature guides ────────────────────────────────────────────────────
    _drawEyeGuide(canvas, Offset(cx - faceW * 0.19, cy - faceH * 0.1),
        faceW * 0.12, faceH * 0.04, accentPaint);
    _drawEyeGuide(canvas, Offset(cx + faceW * 0.19, cy - faceH * 0.1),
        faceW * 0.12, faceH * 0.04, accentPaint);
    _drawNoseGuide(canvas, cx, cy, faceW, faceH, accentPaint);
    _drawLipsGuide(canvas, cx, cy, faceW, faceH, accentPaint);

    // ── Key-point dots ────────────────────────────────────────────────────
    final pts = _keyPoints(cx, cy, faceW, faceH);
    for (final pt in pts) {
      final r = 2.0 + 1.0 * pulse * progress;
      // glow halo
      canvas.drawCircle(
        pt,
        r * 2.5,
        Paint()..color = accentColor.withValues(alpha: 0.2),
      );
      canvas.drawCircle(pt, r, dotPaint);
    }
  }

  void _drawEyeGuide(Canvas canvas, Offset center, double w, double h,
      Paint paint) {
    canvas.drawOval(
      Rect.fromCenter(center: center, width: w, height: h),
      paint,
    );
    // pupil dot
    canvas.drawCircle(
      center,
      h * 0.4,
      paint..style = PaintingStyle.fill,
    );
    paint.style = PaintingStyle.stroke;
  }

  void _drawNoseGuide(Canvas canvas, double cx, double cy, double faceW,
      double faceH, Paint paint) {
    final path = Path();
    path.moveTo(cx, cy - faceH * 0.08);
    path.lineTo(cx - faceW * 0.06, cy + faceH * 0.1);
    path.arcToPoint(
      Offset(cx + faceW * 0.06, cy + faceH * 0.1),
      radius: Radius.circular(faceW * 0.06),
    );
    canvas.drawPath(path, paint);
  }

  void _drawLipsGuide(Canvas canvas, double cx, double cy, double faceW,
      double faceH, Paint paint) {
    final y = cy + faceH * 0.22;
    final path = Path();
    // upper lip
    path.moveTo(cx - faceW * 0.1, y);
    path.quadraticBezierTo(cx, y - faceH * 0.025, cx + faceW * 0.1, y);
    // lower lip
    path.moveTo(cx - faceW * 0.1, y);
    path.quadraticBezierTo(cx, y + faceH * 0.04, cx + faceW * 0.1, y);
    canvas.drawPath(path, paint);
  }

  List<Offset> _keyPoints(double cx, double cy, double faceW, double faceH) {
    return [
      Offset(cx - faceW * 0.19, cy - faceH * 0.10), // L eye
      Offset(cx + faceW * 0.19, cy - faceH * 0.10), // R eye
      Offset(cx, cy + faceH * 0.08),                  // nose tip
      Offset(cx - faceW * 0.10, cy + faceH * 0.22),  // lip L
      Offset(cx + faceW * 0.10, cy + faceH * 0.22),  // lip R
      Offset(cx, cy + faceH * 0.22),                  // lip center
      Offset(cx - faceW * 0.30, cy + faceH * 0.02),  // L cheek
      Offset(cx + faceW * 0.30, cy + faceH * 0.02),  // R cheek
      Offset(cx, cy - faceH * 0.38),                  // forehead top
      Offset(cx - faceW * 0.14, cy - faceH * 0.30),  // L temple
      Offset(cx + faceW * 0.14, cy - faceH * 0.30),  // R temple
      Offset(cx - faceW * 0.26, cy - faceH * 0.16),  // L jaw
      Offset(cx + faceW * 0.26, cy - faceH * 0.16),  // R jaw
      Offset(cx, cy + faceH * 0.42),                  // chin
    ];
  }

  @override
  bool shouldRepaint(MeshFacePainter old) =>
      old.progress != progress ||
      old.pulse != pulse ||
      old.drift != drift ||
      old.onDark != onDark;
}
