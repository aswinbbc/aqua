import 'package:flutter/material.dart';
import '../models/bubble.dart';

/// Renders realistic glass water bubbles with specular light highlights and refracting glow.
class BubblePainter extends CustomPainter {
  final List<Bubble> bubbles;

  BubblePainter({required this.bubbles});

  @override
  void paint(Canvas canvas, Size size) {
    for (var bubble in bubbles) {
      final Offset center = bubble.position;
      final double r = bubble.radius;

      // 1. Draw soft refraction inner glow
      final Paint innerGlowPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.cyanAccent.withValues(alpha: 0.0),
            Colors.cyanAccent.withValues(alpha: 0.08),
            Colors.white.withValues(alpha: 0.16),
          ],
          stops: const [0.0, 0.75, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: r))
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, r, innerGlowPaint);

      // 2. Draw outer glass rim
      final Paint rimPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.28)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawCircle(center, r, rimPaint);

      // 3. Specular reflection dot (offset slightly top-left)
      final Offset highlightCenter = Offset(center.dx - r * 0.38, center.dy - r * 0.38);
      final Paint highlightPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.6)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(highlightCenter, r * 0.18, highlightPaint);
    }
  }

  @override
  bool shouldRepaint(covariant BubblePainter oldDelegate) => true;
}
