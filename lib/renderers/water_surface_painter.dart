import 'dart:math';
import 'package:flutter/material.dart';
import '../models/ripple.dart';
import '../models/food_pellet.dart';
import '../models/theme.dart';

class WaterSurfacePainter extends CustomPainter {
  final List<Ripple> ripples;
  final List<FoodPellet> foodPellets;
  final AquariumThemeData theme;
  final double animationTime;
  final bool enableCaustics;

  WaterSurfacePainter({
    required this.ripples,
    required this.foodPellets,
    required this.theme,
    required this.animationTime,
    this.enableCaustics = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    // 1. Dynamic Water Light Caustics Layer
    if (enableCaustics) {
      _drawWaterCaustics(canvas, size);
    }

    // 2. Interactive Water Wave Packets & Optical Refraction Highlights
    _drawRipplesAndSplash(canvas, size);

    // 3. Floating Food Pellets
    _drawFoodPellets(canvas);
  }

  void _drawWaterCaustics(Canvas canvas, Size size) {
    final Paint causticsPaint = Paint()
      ..color = theme.causticsColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0);

    Path causticsMesh = Path();
    int cols = 8;
    int rows = 10;
    double cellW = size.width / cols;
    double cellH = size.height / rows;

    for (int r = 0; r <= rows; r++) {
      for (int c = 0; c <= cols; c++) {
        double baseX = c * cellW;
        double baseY = r * cellH;

        // Wave refraction displacement
        double offsetX = sin(animationTime * 1.6 + (r * 0.75) + (c * 0.55)) * 16.0 +
            cos(animationTime * 2.2 - (r * 0.45)) * 9.0;
        double offsetY = cos(animationTime * 1.4 + (c * 0.85) - (r * 0.35)) * 16.0 +
            sin(animationTime * 1.9 + (c * 0.65)) * 9.0;

        // Add displacement from nearby active ripples
        Offset gridPt = Offset(baseX + offsetX, baseY + offsetY);
        for (var ripple in ripples) {
          double dist = (gridPt - ripple.position).distance;
          double elevation = ripple.getElevationAt(dist);
          if (elevation.abs() > 0.01) {
            Offset rippleDir = (gridPt - ripple.position);
            if (rippleDir.distance > 0.1) {
              gridPt += (rippleDir / rippleDir.distance) * (elevation * 12.0);
            }
          }
        }

        if (c == 0 && r == 0) {
          causticsMesh.moveTo(gridPt.dx, gridPt.dy);
        } else if (c == 0) {
          causticsMesh.moveTo(gridPt.dx, gridPt.dy);
        } else {
          causticsMesh.lineTo(gridPt.dx, gridPt.dy);
        }
      }
    }

    canvas.drawPath(causticsMesh, causticsPaint);
  }

  void _drawRipplesAndSplash(Canvas canvas, Size size) {
    for (var ripple in ripples) {
      if (ripple.amplitude <= 0.01) continue;

      // Outer Specular Highlight Wave Crest
      final Paint highlightPaint = Paint()
        ..color = theme.rippleHighlight.withValues(alpha: (0.85 * ripple.amplitude).clamp(0.0, 1.0))
        ..style = PaintingStyle.stroke
        ..strokeWidth = (3.5 * ripple.amplitude + 0.8).clamp(0.5, 6.0)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2);

      canvas.drawCircle(ripple.position, ripple.radius, highlightPaint);

      // Inner Trough Optical Refraction Shadow
      if (ripple.radius > 5.0) {
        final Paint refractionShadowPaint = Paint()
          ..color = Colors.black.withValues(alpha: (0.45 * ripple.amplitude).clamp(0.0, 1.0))
          ..style = PaintingStyle.stroke
          ..strokeWidth = (4.5 * ripple.amplitude).clamp(0.5, 8.0)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.5);

        canvas.drawCircle(
          ripple.position + const Offset(2.0, 3.0),
          ripple.radius - 4.0,
          refractionShadowPaint,
        );
      }

      // Secondary Echo Wave Packet Ring
      if (ripple.radius > 28.0) {
        final Paint echoPaint = Paint()
          ..color = theme.rippleHighlight.withValues(alpha: (0.42 * ripple.amplitude).clamp(0.0, 1.0))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;

        canvas.drawCircle(ripple.position, ripple.radius * 0.62, echoPaint);
      }

      // Splash Droplet Particles
      for (var p in ripple.particles) {
        if (p.life <= 0) continue;
        final Paint particlePaint = Paint()
          ..color = theme.rippleHighlight.withValues(alpha: (p.life * 0.9).clamp(0.0, 1.0))
          ..style = PaintingStyle.fill;

        canvas.drawCircle(p.position, p.radius * p.life, particlePaint);

        // Small drop shadow underneath particle
        final Paint particleShadow = Paint()
          ..color = Colors.black.withValues(alpha: (p.life * 0.3).clamp(0.0, 1.0))
          ..style = PaintingStyle.fill;
        canvas.drawCircle(p.position + const Offset(1, 2), (p.radius * p.life) * 0.8, particleShadow);
      }
    }
  }

  void _drawFoodPellets(Canvas canvas) {
    for (var pellet in foodPellets) {
      if (pellet.isEaten) continue;

      final Paint shadowPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.5);
      canvas.drawCircle(pellet.position + const Offset(3.5, 4.5), pellet.radius, shadowPaint);

      final Paint pelletPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.amber.shade200,
            Colors.brown.shade800,
          ],
        ).createShader(Rect.fromCircle(center: pellet.position, radius: pellet.radius));

      canvas.drawCircle(pellet.position, pellet.radius, pelletPaint);

      final Paint glowPaint = Paint()
        ..color = Colors.amber.withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(pellet.position, pellet.radius + 2.5, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant WaterSurfacePainter oldDelegate) {
    return true;
  }
}
