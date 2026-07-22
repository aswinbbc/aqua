import 'dart:math';
import 'package:flutter/material.dart';
import '../models/aquatic_creature.dart';
import '../models/fish.dart';

class CreaturePainter extends CustomPainter {
  final List<AquaticCreature> creatures;
  final double animationTime;

  CreaturePainter({
    required this.creatures,
    required this.animationTime,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var creature in creatures) {
      canvas.save();
      canvas.translate(creature.position.dx, creature.position.dy);

      switch (creature.type) {
        case CreatureType.jellyfish:
          _drawJellyfish(canvas, creature);
          break;
        case CreatureType.seaTurtle:
          _drawSeaTurtle(canvas, creature);
          break;
        case CreatureType.mantaRay:
          _drawMantaRay(canvas, creature);
          break;
        case CreatureType.seahorse:
          _drawSeahorse(canvas, creature);
          break;
        case CreatureType.starfish:
          _drawStarfish(canvas, creature);
          break;
        case CreatureType.hermitCrab:
          _drawHermitCrab(canvas, creature);
          break;
      }

      canvas.restore();
    }
  }

  void _drawJellyfish(Canvas canvas, AquaticCreature c) {
    canvas.rotate(c.angle + pi / 2);

    double pulse = sin(c.pulsePhase);
    double bellWidth = (c.config.size * 0.95) * (1.0 - pulse * 0.16) * c.scale;
    double bellHeight = (c.config.size * 0.85) * (1.0 + pulse * 0.22) * c.scale;

    final Paint glowPaint = Paint()
      ..color = c.config.primaryColor.withValues(alpha: 0.38)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9.0);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: bellWidth * 1.25, height: bellHeight * 1.25), glowPaint);

    Path bellPath = Path()
      ..moveTo(-bellWidth * 0.5, 0)
      ..cubicTo(
        -bellWidth * 0.5, -bellHeight * 1.1,
        bellWidth * 0.5, -bellHeight * 1.1,
        bellWidth * 0.5, 0,
      )
      ..quadraticBezierTo(0, bellHeight * 0.22 * pulse, -bellWidth * 0.5, 0)
      ..close();

    final Paint bellPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          c.config.primaryColor.withValues(alpha: 0.88),
          c.config.secondaryColor.withValues(alpha: 0.62),
        ],
      ).createShader(Rect.fromCenter(center: Offset.zero, width: bellWidth, height: bellHeight));

    canvas.drawPath(bellPath, bellPaint);

    final Paint organPaint = Paint()
      ..color = c.config.accentColor.withValues(alpha: 0.75)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(0, -bellHeight * 0.42), 6.5 * c.scale, organPaint);

    final Paint tentaclePaint = Paint()
      ..color = c.config.primaryColor.withValues(alpha: 0.78)
      ..strokeWidth = 2.0 * c.scale
      ..style = PaintingStyle.stroke;

    int numTentacles = 8;
    for (int t = 0; t < numTentacles; t++) {
      double tx = (-bellWidth * 0.42) + (t * (bellWidth * 0.84 / (numTentacles - 1)));
      Path tPath = Path()..moveTo(tx, 0);

      double tLen = 54.0 * c.scale;
      double wave1 = sin(animationTime * 3.8 + t * 0.8) * 11.0;
      double wave2 = cos(animationTime * 2.9 + t * 0.6) * 13.0;

      tPath.cubicTo(
        tx + wave1, tLen * 0.33,
        tx - wave2, tLen * 0.66,
        tx + wave1 * 0.5, tLen,
      );

      canvas.drawPath(tPath, tentaclePaint);
    }
  }

  void _drawSeaTurtle(Canvas canvas, AquaticCreature c) {
    canvas.rotate(c.angle);

    double scale = c.scale;
    double flipperSweep = sin(c.flipperPhase) * 0.45;

    final Paint shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.22)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7.5);
    canvas.drawOval(Rect.fromCenter(center: const Offset(16, 22), width: 52 * scale, height: 40 * scale), shadowPaint);

    final Paint flipperPaint = Paint()
      ..color = c.config.primaryColor
      ..style = PaintingStyle.fill;

    Path leftFlipper = Path()
      ..moveTo(10 * scale, -10 * scale)
      ..quadraticBezierTo(
        (26 + flipperSweep * 16) * scale, (-36 - flipperSweep * 22) * scale,
        (6 + flipperSweep * 10) * scale, (-46 + flipperSweep * 16) * scale,
      )
      ..close();
    canvas.drawPath(leftFlipper, flipperPaint);

    Path rightFlipper = Path()
      ..moveTo(10 * scale, 10 * scale)
      ..quadraticBezierTo(
        (26 + flipperSweep * 16) * scale, (36 + flipperSweep * 22) * scale,
        (6 + flipperSweep * 10) * scale, (46 - flipperSweep * 16) * scale,
      )
      ..close();
    canvas.drawPath(rightFlipper, flipperPaint);

    canvas.drawOval(Rect.fromCenter(center: Offset(29 * scale, 0), width: 17 * scale, height: 14 * scale), flipperPaint);
    canvas.drawCircle(Offset(32 * scale, -4 * scale), 1.6 * scale, Paint()..color = Colors.black);
    canvas.drawCircle(Offset(32 * scale, 4 * scale), 1.6 * scale, Paint()..color = Colors.black);

    final Paint shellPaint = Paint()
      ..color = c.config.secondaryColor
      ..style = PaintingStyle.fill;

    Path carapace = Path()
      ..addOval(Rect.fromCenter(center: Offset.zero, width: 46 * scale, height: 34 * scale));
    canvas.drawPath(carapace, shellPaint);

    final Paint scutePaint = Paint()
      ..color = c.config.accentColor.withValues(alpha: 0.65)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset.zero, 11 * scale, scutePaint);
    canvas.drawCircle(Offset(-11 * scale, 0), 6.5 * scale, scutePaint);
    canvas.drawCircle(Offset(11 * scale, 0), 6.5 * scale, scutePaint);
  }

  void _drawMantaRay(Canvas canvas, AquaticCreature c) {
    canvas.rotate(c.angle);

    double scale = c.scale;
    double wingFlap = sin(c.flipperPhase) * 15.0 * scale;

    Path rayBody = Path()
      ..moveTo(32 * scale, 0)
      ..quadraticBezierTo(
        0, -36 * scale - wingFlap,
        -26 * scale, -42 * scale - wingFlap,
      )
      ..quadraticBezierTo(-22 * scale, -10 * scale, -32 * scale, 0)
      ..quadraticBezierTo(-22 * scale, 10 * scale, -26 * scale, 42 * scale + wingFlap)
      ..quadraticBezierTo(0, 36 * scale + wingFlap, 32 * scale, 0)
      ..close();

    final Paint bodyPaint = Paint()
      ..color = c.config.primaryColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(rayBody, bodyPaint);

    final Paint markPaint = Paint()
      ..color = c.config.secondaryColor.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(10 * scale, -13 * scale), 6.5 * scale, markPaint);
    canvas.drawCircle(Offset(10 * scale, 13 * scale), 6.5 * scale, markPaint);

    Path tailPath = Path()
      ..moveTo(-32 * scale, 0)
      ..quadraticBezierTo(-58 * scale, sin(animationTime * 4.2) * 9.0, -90 * scale, 0);

    final Paint tailPaint = Paint()
      ..color = c.config.primaryColor
      ..strokeWidth = 2.2 * scale
      ..style = PaintingStyle.stroke;
    canvas.drawPath(tailPath, tailPaint);
  }

  void _drawSeahorse(Canvas canvas, AquaticCreature c) {
    if (c.state == FishState.loading) {
      canvas.rotate(c.angle + pi / 2);
    }
    double scale = c.scale;

    // Head sway & tail curl phase
    double headTilt = sin(c.pulsePhase * 0.8) * 0.12;
    double tailFlex = sin(c.pulsePhase * 1.4) * (6.0 * scale);

    canvas.save();
    canvas.rotate(headTilt);

    // 1. Soft Drop Shadow
    final Paint shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.22)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0);
    canvas.drawOval(Rect.fromCenter(center: const Offset(10, 14), width: 22 * scale, height: 48 * scale), shadowPaint);

    final Paint bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          c.config.primaryColor,
          c.config.secondaryColor,
        ],
      ).createShader(Rect.fromCenter(center: Offset.zero, width: 30 * scale, height: 60 * scale));

    // 2. Ornate Coronet Crown Spikes on Head
    Path coronet = Path()
      ..moveTo(-2 * scale, -24 * scale)
      ..lineTo(-6 * scale, -32 * scale)
      ..lineTo(-1 * scale, -28 * scale)
      ..lineTo(3 * scale, -34 * scale)
      ..lineTo(6 * scale, -27 * scale)
      ..close();

    final Paint crownPaint = Paint()
      ..color = c.config.accentColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(coronet, crownPaint);

    // 3. Head, Cheek & Tubular Snout
    // Head Sphere
    canvas.drawCircle(Offset(0, -20 * scale), 8.5 * scale, bodyPaint);

    // Long Tubular Snout & Trumpet Mouth Tip
    Path snout = Path()
      ..moveTo(-5 * scale, -23 * scale)
      ..lineTo(-18 * scale, -20 * scale)
      ..lineTo(-20 * scale, -16 * scale)
      ..lineTo(-5 * scale, -15 * scale)
      ..close();
    canvas.drawPath(snout, bodyPaint);

    // Trumpet Mouth Tip Highlight
    canvas.drawCircle(Offset(-19 * scale, -18 * scale), 2.2 * scale, crownPaint);

    // Eye Socket & Realistic Eye
    Offset eyePt = Offset(-2 * scale, -21 * scale);
    canvas.drawCircle(eyePt, 3.2 * scale, Paint()..color = Colors.white.withValues(alpha: 0.9));
    canvas.drawCircle(eyePt, 2.4 * scale, Paint()..color = c.config.secondaryColor);
    canvas.drawCircle(eyePt, 1.4 * scale, Paint()..color = Colors.black);
    canvas.drawCircle(eyePt + const Offset(-0.6, -0.6), 0.6 * scale, Paint()..color = Colors.white);

    // Tiny Fluttering Pectoral Ear Fin
    Path pectoralFin = Path()
      ..moveTo(4 * scale, -21 * scale)
      ..quadraticBezierTo(
        9 * scale + sin(c.flipperPhase * 1.5) * 3,
        -25 * scale,
        6 * scale,
        -17 * scale,
      )
      ..close();
    canvas.drawPath(pectoralFin, Paint()..color = c.config.accentColor.withValues(alpha: 0.85));

    // 4. Segmented Torso Armor Rings with Ridges
    Path torsoPath = Path()
      ..moveTo(0, -15 * scale)
      ..cubicTo(
        13 * scale, -6 * scale,
        14 * scale, 10 * scale,
        2 * scale, 22 * scale,
      )
      ..cubicTo(
        -8 * scale + tailFlex, 30 * scale,
        -14 * scale + tailFlex, 38 * scale,
        -10 * scale + tailFlex, 44 * scale,
      )
      ..cubicTo(
        -4 * scale + tailFlex, 46 * scale,
        0 + tailFlex, 38 * scale,
        -2 * scale + tailFlex, 30 * scale,
      )
      ..cubicTo(
        6 * scale, 12 * scale,
        4 * scale, -4 * scale,
        0, -15 * scale,
      )
      ..close();

    canvas.drawPath(torsoPath, bodyPaint);

    // Torso Bony Armor Plate Ring Highlights
    final Paint ringLinePaint = Paint()
      ..color = c.config.accentColor.withValues(alpha: 0.7)
      ..strokeWidth = 1.5 * scale
      ..style = PaintingStyle.stroke;

    for (int i = 1; i <= 6; i++) {
      double ry = -12.0 * scale + (i * 5.2 * scale);
      canvas.drawLine(Offset(-2 * scale, ry), Offset(8 * scale, ry + 1.5), ringLinePaint);
      canvas.drawCircle(Offset(8 * scale, ry + 1.5), 1.2 * scale, crownPaint);
    }

    // 5. Prehensile Coiled Spiral Tail
    Path spiralTail = Path()
      ..moveTo(-10 * scale + tailFlex, 44 * scale)
      ..cubicTo(
        -16 * scale + tailFlex, 50 * scale,
        -8 * scale + tailFlex, 56 * scale,
        -2 * scale + tailFlex, 52 * scale,
      )
      ..cubicTo(
        4 * scale + tailFlex, 48 * scale,
        -2 * scale + tailFlex, 42 * scale,
        -6 * scale + tailFlex, 46 * scale,
      );

    canvas.drawPath(
      spiralTail,
      Paint()
        ..color = c.config.secondaryColor
        ..strokeWidth = 3.5 * scale
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // 6. Rapid Fluttering Dorsal Fin on Back
    double finFlutter = sin(c.flipperPhase) * 5.0 * scale;
    Path dorsalFin = Path()
      ..moveTo(8 * scale, -4 * scale)
      ..quadraticBezierTo(
        18 * scale + finFlutter,
        4 * scale,
        6 * scale,
        14 * scale,
      )
      ..close();

    final Paint finPaint = Paint()
      ..color = c.config.accentColor.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;
    canvas.drawPath(dorsalFin, finPaint);

    // Dorsal Fin Rays
    final Paint finRayPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..strokeWidth = 1.2;
    canvas.drawLine(Offset(8 * scale, -2 * scale), Offset(15 * scale + finFlutter * 0.7, 4 * scale), finRayPaint);
    canvas.drawLine(Offset(7 * scale, 6 * scale), Offset(14 * scale + finFlutter * 0.7, 9 * scale), finRayPaint);

    canvas.restore();
  }

  void _drawStarfish(Canvas canvas, AquaticCreature c) {
    if (c.state == FishState.loading) {
      canvas.rotate(c.angle);
    }
    double scale = c.scale;
    double flex = sin(c.pulsePhase) * 2.2;

    Path starPath = Path();
    int points = 5;
    double outerR = 16.0 * scale;
    double innerR = 6.5 * scale;

    for (int i = 0; i < points * 2; i++) {
      double r = (i % 2 == 0) ? outerR + flex : innerR;
      double a = (i * pi / points) - pi / 2;
      double x = cos(a) * r;
      double y = sin(a) * r;

      if (i == 0) {
        starPath.moveTo(x, y);
      } else {
        starPath.lineTo(x, y);
      }
    }
    starPath.close();

    final Paint starPaint = Paint()
      ..color = c.config.primaryColor
      ..style = PaintingStyle.fill;

    canvas.drawPath(starPath, starPaint);
    canvas.drawCircle(Offset.zero, 4.2 * scale, Paint()..color = c.config.accentColor);
  }

  void _drawHermitCrab(Canvas canvas, AquaticCreature c) {
    if (c.state == FishState.loading) {
      canvas.rotate(c.angle);
    } else {
      bool facingLeft = c.targetAngle == pi;
      if (facingLeft) canvas.scale(-1, 1);
    }
    double scale = c.scale;

    final Paint shellPaint = Paint()
      ..color = c.config.accentColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(-8 * scale, -6 * scale), 13 * scale, shellPaint);

    final Paint crabPaint = Paint()
      ..color = c.config.primaryColor
      ..style = PaintingStyle.fill;
    canvas.drawOval(Rect.fromCenter(center: Offset(6 * scale, 0), width: 15 * scale, height: 11 * scale), crabPaint);

    Path claw = Path()
      ..moveTo(10 * scale, -2 * scale)
      ..lineTo(19 * scale, -9 * scale)
      ..lineTo(23 * scale, -4 * scale)
      ..lineTo(15 * scale, 2 * scale)
      ..close();
    canvas.drawPath(claw, crabPaint);

    canvas.drawLine(Offset(8 * scale, -4 * scale), Offset(13 * scale, -11 * scale), Paint()..strokeWidth = 1.6..color = c.config.primaryColor);
    canvas.drawCircle(Offset(13 * scale, -11 * scale), 1.9 * scale, Paint()..color = Colors.black);
  }

  @override
  bool shouldRepaint(covariant CreaturePainter oldDelegate) {
    return true;
  }
}
