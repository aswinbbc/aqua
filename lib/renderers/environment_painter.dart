import 'dart:math';
import 'package:flutter/material.dart';
import '../models/theme.dart';

class EnvironmentPainter extends CustomPainter {
  final AquariumThemeData theme;
  final double animationTime;
  final Size screenSize;

  EnvironmentPainter({
    required this.theme,
    required this.animationTime,
    required this.screenSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    // 1. Draw Seabed Sand & Water Depth Background Gradient
    final Rect rect = Offset.zero & size;
    final Paint bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          theme.shallowWaterColor,
          theme.deepWaterColor.withValues(alpha: 0.95),
          theme.sandColor.withValues(alpha: 0.85),
        ],
        stops: const [0.0, 0.7, 1.0],
      ).createShader(rect);

    canvas.drawRect(rect, bgPaint);

    // 2. Draw Submerged Gravel & Pebbles at bottom
    _drawPebbles(canvas, size);

    // 3. Draw Swaying Seaweed Plants
    _drawSeaweedCluster(canvas, size, theme.seaweedColors);

    // 4. Draw Atmospheric Sunbeams / Light Shafts
    _drawSunbeams(canvas, size);
  }

  void _drawPebbles(Canvas canvas, Size size) {
    final Random random = Random(42); // Fixed seed for consistent pebble placement
    final double bottomY = size.height;

    for (int i = 0; i < 45; i++) {
      double x = random.nextDouble() * size.width;
      double y = bottomY - (random.nextDouble() * 70.0);
      double radiusX = 6.0 + random.nextDouble() * 12.0;
      double radiusY = 4.0 + random.nextDouble() * 8.0;

      final Path pebblePath = Path()
        ..addOval(Rect.fromCenter(
          center: Offset(x, y),
          width: radiusX * 2,
          height: radiusY * 2,
        ));

      Color pebbleColor = Color.lerp(
        theme.sandColor,
        Colors.brown.shade900,
        random.nextDouble() * 0.5 + 0.2,
      )!;

      final Paint pebblePaint = Paint()
        ..color = pebbleColor.withValues(alpha: 0.7)
        ..style = PaintingStyle.fill;

      canvas.drawPath(pebblePath, pebblePaint);

      // Highlight on pebble top
      final Paint highlightPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(x, y),
          width: radiusX * 1.8,
          height: radiusY * 1.8,
        ),
        pi * 1.2,
        pi * 0.6,
        false,
        highlightPaint,
      );
    }
  }

  void _drawSeaweedCluster(Canvas canvas, Size size, List<Color> seaweedColors) {
    final double bottomY = size.height + 10;
    final List<double> plantXPositions = [
      size.width * 0.08,
      size.width * 0.15,
      size.width * 0.82,
      size.width * 0.90,
    ];

    for (int p = 0; p < plantXPositions.length; p++) {
      double baseX = plantXPositions[p];
      Color plantColor = seaweedColors[p % seaweedColors.length];

      int numLeaves = 5;
      for (int i = 0; i < numLeaves; i++) {
        double leafHeight = 140.0 + (i * 25.0);
        double leafBaseX = baseX + ((i - 2) * 12.0);

        Path leafPath = Path();
        leafPath.moveTo(leafBaseX, bottomY);

        double segments = 6;
        double segHeight = leafHeight / segments;

        double currentX = leafBaseX;
        double currentY = bottomY;

        List<Offset> leftPoints = [Offset(currentX - 6, currentY)];
        List<Offset> rightPoints = [Offset(currentX + 6, currentY)];

        for (int s = 1; s <= segments; s++) {
          currentY -= segHeight;
          // Sway formula based on height and animation time
          double wave = sin(animationTime * 1.8 + (s * 0.5) + (p * 1.2)) * (s * 4.5);
          currentX = leafBaseX + wave;

          double leafWidth = (1.0 - (s / segments)) * 8.0 + 2.0;
          leftPoints.add(Offset(currentX - leafWidth, currentY));
          rightPoints.add(Offset(currentX + leafWidth, currentY));
        }

        // Connect left edge up to tip
        for (int k = 1; k < leftPoints.length; k++) {
          leafPath.lineTo(leftPoints[k].dx, leftPoints[k].dy);
        }
        // Tip
        leafPath.lineTo(currentX, currentY - 5);
        // Connect right edge down to base
        for (int k = rightPoints.length - 1; k >= 0; k--) {
          leafPath.lineTo(rightPoints[k].dx, rightPoints[k].dy);
        }
        leafPath.close();

        final Paint plantPaint = Paint()
          ..color = plantColor.withValues(alpha: 0.85)
          ..style = PaintingStyle.fill;

        canvas.drawPath(leafPath, plantPaint);
      }
    }
  }

  void _drawSunbeams(Canvas canvas, Size size) {
    final Paint beamPaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 3; i++) {
      double startX = size.width * (0.2 + (i * 0.25));
      double sway = sin(animationTime * 0.5 + i) * 30.0;

      Path beamPath = Path()
        ..moveTo(startX + sway, 0)
        ..lineTo(startX + 60.0 + sway, 0)
        ..lineTo(startX + 220.0 + sway, size.height)
        ..lineTo(startX + 80.0 + sway, size.height)
        ..close();

      beamPaint.shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          theme.lightBeamColor,
          theme.lightBeamColor.withValues(alpha: 0.0),
        ],
      ).createShader(Offset.zero & size);

      canvas.drawPath(beamPath, beamPaint);
    }
  }

  @override
  bool shouldRepaint(covariant EnvironmentPainter oldDelegate) {
    return oldDelegate.animationTime != animationTime || oldDelegate.theme != theme;
  }
}
