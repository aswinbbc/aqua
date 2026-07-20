import 'dart:math';
import 'package:flutter/material.dart';
import '../models/fish.dart';

class FishPainter extends CustomPainter {
  final List<Fish> fishes;
  final double animationTime;

  FishPainter({
    required this.fishes,
    required this.animationTime,
  });

  @override
  void paint(Canvas canvas, Size size) {
    List<Fish> sortedFishes = List.from(fishes)..sort((a, b) => a.depth.compareTo(b.depth));

    for (var fish in sortedFishes) {
      _drawFishShadow(canvas, fish);
      _drawFishBody(canvas, fish);
    }
  }

  void _drawFishShadow(Canvas canvas, Fish fish) {
    if (fish.spineJoints.length < 2) return;

    canvas.save();
    double shadowDist = 14.0 + (1.2 - fish.depth.clamp(0.4, 1.2)) * 30.0;
    Offset shadowOffset = Offset(shadowDist * 0.7, shadowDist);
    canvas.translate(shadowOffset.dx, shadowOffset.dy);

    double shadowBlur = 6.0 + (1.2 - fish.depth.clamp(0.4, 1.2)) * 10.0;
    double shadowAlpha = (0.26 * fish.depth.clamp(0.4, 1.0)).clamp(0.08, 0.3);

    final List<Offset> shadowJoints = fish.spineJoints.map((j) => j + shadowOffset * 0.05).toList();
    Path shadowPath = _buildSmoothBodyOutline(shadowJoints, fish.config.bodyWidth * fish.scale * fish.depth * 0.85);

    final Paint shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: shadowAlpha)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadowBlur)
      ..style = PaintingStyle.fill;

    canvas.drawPath(shadowPath, shadowPaint);
    canvas.restore();
  }

  void _drawFishBody(Canvas canvas, Fish fish) {
    if (fish.spineJoints.length < 3) return;

    double depthScale = fish.scale * (0.7 + 0.3 * fish.depth.clamp(0.4, 1.2));

    // 1. Pectoral Side Fins
    _drawPectoralFins(canvas, fish, depthScale);

    // 2. High-Realism Multi-Ray Caudal Tail Fin
    _drawFlowingTailFin(canvas, fish, depthScale);

    // 3. Smooth Body Outline Path
    Path bodyPath = _buildSmoothBodyOutline(fish.spineJoints, fish.config.bodyWidth * depthScale);

    // 4. Base Body Gradient & Water Column Depth Tinting
    Offset head = fish.spineJoints.first;
    Offset tail = fish.spineJoints.last;

    double depthFactor = (fish.depth - 0.4).clamp(0.0, 0.85) / 0.85;
    Color primaryColor = Color.lerp(const Color(0xFF06324D), fish.config.primaryColor, 0.25 + 0.75 * depthFactor)!;
    Color secondaryColor = Color.lerp(const Color(0xFF042033), fish.config.secondaryColor, 0.25 + 0.75 * depthFactor)!;

    final Paint bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment(head.dx, head.dy),
        end: Alignment(tail.dx, tail.dy),
        colors: [
          primaryColor,
          secondaryColor,
        ],
      ).createShader(Rect.fromPoints(head, tail));

    canvas.drawPath(bodyPath, bodyPaint);

    // 5. Species Specific Patterns, Stripes & Markings
    _drawSpeciesMarkings(canvas, fish, bodyPath, depthScale);

    // 6. Scale Texture Grid & 3D Volumetric Specular Highlight
    _draw3DScaleHighlight(canvas, fish, bodyPath, depthScale);

    // 7. Dorsal & Anal Spine Fins
    _drawDorsalAndAnalFins(canvas, fish, depthScale);

    // 8. Respiration Gill Flap & Realistic Eyes
    _drawGillsAndEyes(canvas, fish, depthScale);
  }

  Path _buildSmoothBodyOutline(List<Offset> joints, double maxWidth) {
    int n = joints.length;
    if (n < 3) return Path();

    List<Offset> dorsalEdge = [];
    List<Offset> ventralEdge = [];

    for (int i = 0; i < n; i++) {
      Offset current = joints[i];
      Offset prev = i > 0 ? joints[i - 1] : joints[i];
      Offset next = i < n - 1 ? joints[i + 1] : joints[i];

      Offset forward = (prev - next);
      if (forward.distance < 0.001) {
        forward = const Offset(1, 0);
      } else {
        forward = forward / forward.distance;
      }

      Offset dorsalNormal = Offset(forward.dy, -forward.dx);
      Offset ventralNormal = Offset(-forward.dy, forward.dx);

      double t = i / (n - 1);
      double widthFactor = sin(t * pi);
      if (t < 0.22) {
        widthFactor = 0.5 + sin((t / 0.22) * (pi / 2)) * 0.5;
      }

      double halfWidth = (maxWidth * 0.5) * widthFactor;
      dorsalEdge.add(current + dorsalNormal * halfWidth);
      ventralEdge.add(current + ventralNormal * halfWidth);
    }

    Path path = Path();
    path.moveTo(dorsalEdge[0].dx, dorsalEdge[0].dy);

    _addCatmullRomSpline(path, dorsalEdge);
    path.lineTo(joints.last.dx, joints.last.dy);

    List<Offset> reversedVentral = ventralEdge.reversed.toList();
    _addCatmullRomSpline(path, reversedVentral);

    path.close();
    return path;
  }

  void _addCatmullRomSpline(Path path, List<Offset> points) {
    int n = points.length;
    if (n < 2) return;

    for (int i = 0; i < n - 1; i++) {
      Offset p0 = i > 0 ? points[i - 1] : points[i];
      Offset p1 = points[i];
      Offset p2 = points[i + 1];
      Offset p3 = i < n - 2 ? points[i + 2] : points[i + 1];

      Offset c1 = p1 + (p2 - p0) * (1.0 / 6.0);
      Offset c2 = p2 - (p3 - p1) * (1.0 / 6.0);

      path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p2.dx, p2.dy);
    }
  }

  void _drawPectoralFins(Canvas canvas, Fish fish, double scale) {
    if (fish.spineJoints.length < 3) return;

    Offset joint = fish.spineJoints[1];
    Offset forward = fish.spineJoints[0] - fish.spineJoints[2];
    if (forward.distance < 0.001) return;
    forward = forward / forward.distance;

    Offset dorsalNormal = Offset(forward.dy, -forward.dx);
    Offset ventralNormal = Offset(-forward.dy, forward.dx);

    double finLen = 24.0 * scale;
    double flap = sin(fish.wigglePhase * 1.3) * 0.35;

    final Paint finPaint = Paint()
      ..color = fish.config.finColor.withValues(alpha: 0.82)
      ..style = PaintingStyle.fill;

    // Dorsal Side Fin
    Path dorsalFin = Path()
      ..moveTo(joint.dx + dorsalNormal.dx * 6, joint.dy + dorsalNormal.dy * 6)
      ..quadraticBezierTo(
        joint.dx + (dorsalNormal.dx - forward.dx * (0.8 + flap)) * finLen,
        joint.dy + (dorsalNormal.dy - forward.dy * (0.8 + flap)) * finLen,
        joint.dx + (dorsalNormal.dx * 0.3 - forward.dx * 1.1) * finLen,
        joint.dy + (dorsalNormal.dy * 0.3 - forward.dy * 1.1) * finLen,
      )
      ..close();
    canvas.drawPath(dorsalFin, finPaint);

    // Ventral Side Fin
    Path ventralFin = Path()
      ..moveTo(joint.dx + ventralNormal.dx * 6, joint.dy + ventralNormal.dy * 6)
      ..quadraticBezierTo(
        joint.dx + (ventralNormal.dx - forward.dx * (0.8 + flap)) * finLen,
        joint.dy + (ventralNormal.dy - forward.dy * (0.8 + flap)) * finLen,
        joint.dx + (ventralNormal.dx * 0.3 - forward.dx * 1.1) * finLen,
        joint.dy + (ventralNormal.dy * 0.3 - forward.dy * 1.1) * finLen,
      )
      ..close();
    canvas.drawPath(ventralFin, finPaint);
  }

  void _drawFlowingTailFin(Canvas canvas, Fish fish, double scale) {
    int n = fish.spineJoints.length;
    if (n < 3) return;

    Offset lastJoint = fish.spineJoints.last;
    Offset prevJoint = fish.spineJoints[n - 2];
    Offset forward = prevJoint - lastJoint;
    if (forward.distance < 0.001) return;
    forward = forward / forward.distance;

    Offset dorsalNormal = Offset(forward.dy, -forward.dx);
    Offset ventralNormal = Offset(-forward.dy, forward.dx);

    // Connect seamlessly to muscular tail peduncle width
    double peduncleHalfWidth = (fish.config.bodyWidth * scale * 0.22);
    Offset peduncleDorsal = lastJoint + (dorsalNormal * peduncleHalfWidth);
    Offset peduncleVentral = lastJoint + (ventralNormal * peduncleHalfWidth);

    int numRays = 9;
    List<Offset> rayBases = [];
    List<Offset> rayTips = [];

    bool isVeiltail = fish.species == FishSpecies.fancyGuppy ||
        fish.species == FishSpecies.blackMoor ||
        fish.species == FishSpecies.bettaSplendens;

    for (int i = 0; i < numRays; i++) {
      double t = i / (numRays - 1); // 0.0 to 1.0
      Offset basePt = peduncleDorsal + (peduncleVentral - peduncleDorsal) * t;
      rayBases.add(basePt);

      // Angle spread relative to backward direction
      double spreadAngle = (t - 0.5) * (isVeiltail ? 1.4 : 1.0);
      Offset rayDir = Offset(
        -forward.dx * cos(spreadAngle) - forward.dy * sin(spreadAngle),
        -forward.dy * cos(spreadAngle) + forward.dx * sin(spreadAngle),
      );

      // Caudal fin shape profile (Forked vs Veiltail vs Lunate)
      double rayLength = 34.0 * scale;
      if (isVeiltail) {
        rayLength *= 1.55;
      } else {
        // Forked tail notch (deep V-cut in center rays)
        double centerNotch = (t - 0.5).abs() * 2.0; // 0.0 at center, 1.0 at tips
        rayLength *= (0.55 + 0.45 * centerNotch);
      }

      // Wave phase delay along each fin ray
      double phaseLag = fish.wigglePhase - 1.1 - (t - 0.5).abs() * 0.4;
      double raySway = sin(phaseLag) * (14.0 * scale);

      Offset tipPt = basePt + (rayDir * rayLength) + (dorsalNormal * raySway);
      rayTips.add(tipPt);
    }

    // Build Tail Membrane Path
    Path tailMesh = Path();
    tailMesh.moveTo(peduncleDorsal.dx, peduncleDorsal.dy);

    // Smooth spline along outer fin ray tips
    _addCatmullRomSpline(tailMesh, rayTips);

    // Connect down to peduncle ventral and back to dorsal
    tailMesh.lineTo(peduncleVentral.dx, peduncleVentral.dy);
    tailMesh.close();

    // Multi-gradient Translucent Tail Fin Paint
    final Paint tailPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment(lastJoint.dx, lastJoint.dy),
        end: Alignment(rayTips[numRays ~/ 2].dx, rayTips[numRays ~/ 2].dy),
        colors: [
          fish.config.finColor.withValues(alpha: 0.90),
          fish.config.secondaryColor.withValues(alpha: 0.75),
          fish.config.finColor.withValues(alpha: 0.45),
        ],
      ).createShader(Rect.fromPoints(lastJoint, rayTips[numRays ~/ 2]));

    canvas.drawPath(tailMesh, tailPaint);

    // Draw Delicate Bending Fin Rays (Flexible Ray Lines)
    final Paint rayPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.45)
      ..strokeWidth = 1.3
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < numRays; i++) {
      Path rayPath = Path()
        ..moveTo(rayBases[i].dx, rayBases[i].dy)
        ..quadraticBezierTo(
          (rayBases[i].dx + rayTips[i].dx) * 0.5,
          (rayBases[i].dy + rayTips[i].dy) * 0.5,
          rayTips[i].dx,
          rayTips[i].dy,
        );
      canvas.drawPath(rayPath, rayPaint);
    }
  }

  void _drawDorsalAndAnalFins(Canvas canvas, Fish fish, double scale) {
    if (fish.spineJoints.length < 7) return;
    Offset startSpine = fish.spineJoints[2];
    Offset midSpine = fish.spineJoints[4];
    Offset endSpine = fish.spineJoints[6];

    Offset forward = startSpine - endSpine;
    if (forward.distance < 0.001) return;
    forward = forward / forward.distance;

    Offset dorsalNormal = Offset(forward.dy, -forward.dx);
    Offset ventralNormal = Offset(-forward.dy, forward.dx);

    double finHeight = 16.0 * scale;
    if (fish.species == FishSpecies.angelFish || fish.species == FishSpecies.bettaSplendens) {
      finHeight *= 1.6;
    }

    Path dorsal = Path()
      ..moveTo(startSpine.dx, startSpine.dy)
      ..quadraticBezierTo(
        midSpine.dx + dorsalNormal.dx * finHeight,
        midSpine.dy + dorsalNormal.dy * finHeight,
        endSpine.dx,
        endSpine.dy,
      )
      ..close();

    final Paint finPaint = Paint()
      ..color = fish.config.finColor.withValues(alpha: 0.78)
      ..style = PaintingStyle.fill;

    canvas.drawPath(dorsal, finPaint);

    Path anal = Path()
      ..moveTo(startSpine.dx, startSpine.dy)
      ..quadraticBezierTo(
        midSpine.dx + ventralNormal.dx * (finHeight * 0.8),
        midSpine.dy + ventralNormal.dy * (finHeight * 0.8),
        endSpine.dx,
        endSpine.dy,
      )
      ..close();

    canvas.drawPath(anal, finPaint);
  }

  void _draw3DScaleHighlight(Canvas canvas, Fish fish, Path bodyPath, double scale) {
    canvas.save();
    canvas.clipPath(bodyPath);

    Path ridgePath = Path();
    ridgePath.moveTo(fish.spineJoints[0].dx, fish.spineJoints[0].dy);
    for (int i = 1; i < fish.spineJoints.length - 2; i++) {
      ridgePath.lineTo(fish.spineJoints[i].dx, fish.spineJoints[i].dy);
    }

    final Paint ridgePaint = Paint()
      ..color = Colors.white.withValues(alpha: (0.42 * fish.depth).clamp(0.1, 0.5))
      ..strokeWidth = 2.8 * scale
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 2.0);

    canvas.drawPath(ridgePath, ridgePaint);
    canvas.restore();
  }

  void _drawSpeciesMarkings(Canvas canvas, Fish fish, Path bodyPath, double scale) {
    canvas.save();
    canvas.clipPath(bodyPath);

    final Paint patternPaint = Paint()..style = PaintingStyle.fill;

    switch (fish.species) {
      case FishSpecies.koiTancho:
        patternPaint.color = fish.config.secondaryColor;
        Offset headSpot = fish.spineJoints[1];
        canvas.drawCircle(headSpot, 6.5 * scale, patternPaint);
        break;

      case FishSpecies.clownfish:
        final Paint whitePaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;
        final Paint blackEdgePaint = Paint()
          ..color = Colors.black
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke;

        List<int> stripeJoints = [1, 3, 5];
        for (int jIdx in stripeJoints) {
          if (jIdx < fish.spineJoints.length) {
            Offset pt = fish.spineJoints[jIdx];
            canvas.drawCircle(pt, (fish.config.bodyWidth * 0.45) * scale, whitePaint);
            canvas.drawCircle(pt, (fish.config.bodyWidth * 0.45) * scale, blackEdgePaint);
          }
        }
        break;

      case FishSpecies.discusFish:
        patternPaint.color = fish.config.secondaryColor;
        for (int i = 1; i < fish.spineJoints.length - 1; i += 2) {
          canvas.drawCircle(fish.spineJoints[i], (fish.config.bodyWidth * 0.5) * scale, patternPaint);
        }
        break;

      case FishSpecies.angelFish:
        patternPaint.color = fish.config.secondaryColor;
        for (int i = 1; i < fish.spineJoints.length - 2; i += 2) {
          canvas.drawRect(
            Rect.fromCenter(
              center: fish.spineJoints[i],
              width: 5.0 * scale,
              height: fish.config.bodyWidth * scale,
            ),
            patternPaint,
          );
        }
        break;

      case FishSpecies.koiSanke:
      case FishSpecies.koiKohaku:
        patternPaint.color = fish.config.secondaryColor;
        for (int i = 1; i < fish.spineJoints.length - 2; i += 2) {
          canvas.drawCircle(fish.spineJoints[i], (fish.config.bodyWidth * 0.45) * scale, patternPaint);
        }
        if (fish.species == FishSpecies.koiSanke) {
          patternPaint.color = fish.config.accentColor;
          for (int i = 2; i < fish.spineJoints.length - 1; i += 3) {
            canvas.drawCircle(fish.spineJoints[i] + const Offset(2, -2), (fish.config.bodyWidth * 0.28) * scale, patternPaint);
          }
        }
        break;

      case FishSpecies.neonTetra:
        final Paint glowPaint = Paint()
          ..color = fish.config.primaryColor
          ..strokeWidth = 4.5 * scale
          ..style = PaintingStyle.stroke
          ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 3.5);

        Path stripe = Path()..moveTo(fish.spineJoints.first.dx, fish.spineJoints.first.dy);
        for (var joint in fish.spineJoints) {
          stripe.lineTo(joint.dx, joint.dy);
        }
        canvas.drawPath(stripe, glowPaint);
        break;

      case FishSpecies.blueTang:
        patternPaint.color = fish.config.secondaryColor;
        if (fish.spineJoints.length >= 5) {
          canvas.drawCircle(fish.spineJoints[3], (fish.config.bodyWidth * 0.42) * scale, patternPaint);
        }
        break;

      case FishSpecies.goldfish:
      case FishSpecies.blackMoor:
      case FishSpecies.bettaSplendens:
      case FishSpecies.fancyGuppy:
        final Paint shimmerPaint = Paint()
          ..color = fish.config.accentColor.withValues(alpha: 0.38)
          ..style = PaintingStyle.fill;
        if (fish.spineJoints.length >= 3) {
          canvas.drawCircle(fish.spineJoints[2], (fish.config.bodyWidth * 0.35) * scale, shimmerPaint);
        }
        break;
    }

    canvas.restore();
  }

  void _drawGillsAndEyes(Canvas canvas, Fish fish, double scale) {
    if (fish.spineJoints.length < 2) return;

    Offset head = fish.spineJoints[0];
    Offset neck = fish.spineJoints[1];

    Offset forward = head - neck;
    if (forward.distance < 0.001) return;
    forward = forward / forward.distance;

    Offset dorsalNormal = Offset(forward.dy, -forward.dx);
    Offset ventralNormal = Offset(-forward.dy, forward.dx);

    double gillOpening = sin(fish.gillPhase) * (1.8 * scale);
    final Paint gillPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.25)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    Offset gillPt = head - (forward * 5.0);
    canvas.drawArc(
      Rect.fromCenter(center: gillPt, width: 8.0 * scale + gillOpening, height: 12.0 * scale),
      pi * 0.4,
      pi * 0.8,
      false,
      gillPaint,
    );

    double eyeOffset = 5.5 * scale;
    double eyeRadius = 2.8 * scale;

    if (fish.species == FishSpecies.blackMoor) {
      eyeOffset *= 1.35;
      eyeRadius *= 1.4;
    }

    final Paint corneaPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.fill;

    final Paint irisPaint = Paint()
      ..color = fish.config.eyeColor
      ..style = PaintingStyle.fill;

    final Paint pupilPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final Paint specularPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    Offset dorsalEye = head + (dorsalNormal * eyeOffset) + (forward * 2.5);
    canvas.drawCircle(dorsalEye, eyeRadius, corneaPaint);
    canvas.drawCircle(dorsalEye, eyeRadius * 0.75, irisPaint);
    canvas.drawCircle(dorsalEye, eyeRadius * 0.45, pupilPaint);
    canvas.drawCircle(dorsalEye + (forward * 0.6) + (dorsalNormal * 0.5), eyeRadius * 0.25, specularPaint);

    Offset ventralEye = head + (ventralNormal * eyeOffset) + (forward * 2.5);
    canvas.drawCircle(ventralEye, eyeRadius, corneaPaint);
    canvas.drawCircle(ventralEye, eyeRadius * 0.75, irisPaint);
    canvas.drawCircle(ventralEye, eyeRadius * 0.45, pupilPaint);
    canvas.drawCircle(ventralEye + (forward * 0.6) + (ventralNormal * 0.5), eyeRadius * 0.25, specularPaint);
  }

  @override
  bool shouldRepaint(covariant FishPainter oldDelegate) {
    return true;
  }
}
