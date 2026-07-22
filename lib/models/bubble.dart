import 'dart:math';
import 'package:flutter/material.dart';

/// Represents an animated water bubble rising upwards in the aquarium.
class Bubble {
  Offset position;
  final double speed;
  final double radius;
  final double driftFrequency;
  final double driftAmplitude;
  double wobbleTime;

  Bubble({
    required this.position,
    required this.speed,
    required this.radius,
    required this.driftFrequency,
    required this.driftAmplitude,
    this.wobbleTime = 0.0,
  });

  /// Marks when the bubble rises past the top boundary of the screen.
  bool get isExpired => position.dy < -radius - 10.0;

  /// Updates position of the bubble rising upwards with subtle sine wave horizontal wobble.
  void update(double dt) {
    wobbleTime += dt * driftFrequency;
    final double driftX = sin(wobbleTime) * driftAmplitude * dt * 35.0;
    position = Offset(
      position.dx + driftX,
      position.dy - speed * dt,
    );
  }
}
