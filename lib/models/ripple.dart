import 'dart:math';
import 'package:flutter/material.dart';

class SplashParticle {
  Offset position;
  Offset velocity;
  double radius;
  double life; // 1.0 down to 0.0
  final double maxLife;

  SplashParticle({
    required this.position,
    required this.velocity,
    required this.radius,
    this.life = 1.0,
    this.maxLife = 0.6,
  });

  void update(double dt) {
    life -= dt / maxLife;
    position += velocity * dt;
    velocity += const Offset(0, 180.0) * dt; // Gravity pulling splash droplet back down
  }
}

class Ripple {
  final Offset position;
  double radius;
  final double maxRadius;
  double amplitude;
  final double speed;
  double age;
  final double maxAge;
  final List<SplashParticle> particles;

  Ripple({
    required this.position,
    this.radius = 2.0,
    this.maxRadius = 180.0,
    this.amplitude = 1.0,
    this.speed = 150.0,
    this.age = 0.0,
    this.maxAge = 2.4,
  }) : particles = _generateSplashParticles(position, amplitude);

  static List<SplashParticle> _generateSplashParticles(Offset center, double amp) {
    if (amp < 0.8) return [];
    final Random random = Random();
    int count = (8 * amp).toInt();
    return List.generate(count, (i) {
      double angle = random.nextDouble() * 2 * pi;
      double speed = 40.0 + random.nextDouble() * 90.0 * amp;
      return SplashParticle(
        position: center,
        velocity: Offset(cos(angle) * speed, sin(angle) * speed - 60.0),
        radius: 1.5 + random.nextDouble() * 2.5,
        maxLife: 0.4 + random.nextDouble() * 0.3,
      );
    });
  }

  bool get isExpired => age >= maxAge || amplitude <= 0.01;

  void update(double dt) {
    age += dt;
    radius += speed * dt;
    double progress = (age / maxAge).clamp(0.0, 1.0);
    amplitude = (1.0 - progress) * (1.0 - progress);

    for (var p in particles) {
      p.update(dt);
    }
    particles.removeWhere((p) => p.life <= 0);
  }

  /// Calculates wave displacement & optical refraction offset at distance [d]
  double getElevationAt(double d) {
    double dr = d - radius;
    if (dr.abs() > 32.0) return 0.0;

    double wavelength = 20.0;
    double waveEnvelope = exp(-(dr * dr) / (wavelength * wavelength));
    return amplitude * waveEnvelope * cos(dr * (2 * pi / wavelength));
  }
}
