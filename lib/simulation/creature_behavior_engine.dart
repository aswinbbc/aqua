import 'dart:math';
import 'package:flutter/material.dart';
import '../models/aquatic_creature.dart';

class CreatureBehaviorEngine {
  final Random _random = Random();

  void update({
    required List<AquaticCreature> creatures,
    required Size bounds,
    required double dt,
  }) {
    if (bounds.width <= 0 || bounds.height <= 0) return;

    for (var creature in creatures) {
      switch (creature.type) {
        case CreatureType.jellyfish:
          _updateJellyfishPhysics(creature, bounds, dt);
          break;
        case CreatureType.seaTurtle:
          _updateSeaTurtlePhysics(creature, bounds, dt);
          break;
        case CreatureType.mantaRay:
          _updateMantaRayPhysics(creature, bounds, dt);
          break;
        case CreatureType.seahorse:
          _updateSeahorsePhysics(creature, bounds, dt);
          break;
        case CreatureType.starfish:
          _updateStarfishPhysics(creature, bounds, dt);
          break;
        case CreatureType.hermitCrab:
          _updateHermitCrabPhysics(creature, bounds, dt);
          break;
      }
    }
  }

  void _updateJellyfishPhysics(AquaticCreature c, Size bounds, double dt) {
    c.pulsePhase += dt * 2.2;
    double pulse = sin(c.pulsePhase);

    // Thrust when bell contracts (pulse > 0.5)
    double thrust = (pulse > 0.4) ? (pulse - 0.4) * 45.0 : -6.0; // Slow sink when relaxing
    Offset thrustDir = Offset(cos(c.angle), sin(c.angle));

    c.velocity = thrustDir * (c.config.maxSpeed + thrust);

    // Boundary check
    if (c.position.dy < 70) c.angle = pi / 2;
    if (c.position.dy > bounds.height - 120) c.angle = -pi / 2;
    if (c.position.dx < 50 || c.position.dx > bounds.width - 50) {
      c.angle = pi - c.angle;
    }

    c.position += c.velocity * dt;
  }

  void _updateSeaTurtlePhysics(AquaticCreature c, Size bounds, double dt) {
    c.flipperPhase += dt * 3.0;

    if (_random.nextDouble() < 0.02) {
      c.targetAngle += (_random.nextDouble() - 0.5) * 0.6;
    }

    c.angle += (c.targetAngle - c.angle) * (1.5 * dt).clamp(0.0, 1.0);

    double padding = 80.0;
    if (c.position.dx < padding || c.position.dx > bounds.width - padding) {
      c.targetAngle = pi - c.angle;
    }
    if (c.position.dy < padding || c.position.dy > bounds.height - 140) {
      c.targetAngle = -c.angle;
    }

    Offset forward = Offset(cos(c.angle), sin(c.angle));
    c.velocity = forward * c.config.maxSpeed;
    c.position += c.velocity * dt;
  }

  void _updateMantaRayPhysics(AquaticCreature c, Size bounds, double dt) {
    c.flipperPhase += dt * 2.5;

    if (_random.nextDouble() < 0.025) {
      c.targetAngle += (_random.nextDouble() - 0.5) * 0.7;
    }

    c.angle += (c.targetAngle - c.angle) * (1.8 * dt).clamp(0.0, 1.0);

    double padding = 90.0;
    if (c.position.dx < padding || c.position.dx > bounds.width - padding) {
      c.targetAngle = pi - c.angle;
    }
    if (c.position.dy < padding || c.position.dy > bounds.height - 150) {
      c.targetAngle = -c.angle;
    }

    Offset forward = Offset(cos(c.angle), sin(c.angle));
    c.velocity = forward * c.config.maxSpeed;
    c.position += c.velocity * dt;
  }

  void _updateSeahorsePhysics(AquaticCreature c, Size bounds, double dt) {
    c.flipperPhase += dt * 12.0; // Rapid dorsal fin flutter
    c.pulsePhase += dt * 1.5; // Vertical bobbing

    c.angle = -pi / 2; // Upright orientation

    // Gentle vertical bobbing & slow drift
    double bobbing = sin(c.pulsePhase) * 12.0;
    c.velocity = Offset(sin(c.pulsePhase * 0.7) * 8.0, bobbing);

    if (c.position.dx < 60) c.position = Offset(60, c.position.dy);
    if (c.position.dx > bounds.width - 60) c.position = Offset(bounds.width - 60, c.position.dy);
    if (c.position.dy < 90) c.position = Offset(c.position.dx, 90);
    if (c.position.dy > bounds.height - 130) c.position = Offset(c.position.dx, bounds.height - 130);

    c.position += c.velocity * dt;
  }

  void _updateStarfishPhysics(AquaticCreature c, Size bounds, double dt) {
    // Starfish rests on the seabed sand
    double seabedY = bounds.height - 35.0;
    c.position = Offset(c.position.dx, seabedY);
    c.pulsePhase += dt * 0.8; // Gentle arm flex
  }

  void _updateHermitCrabPhysics(AquaticCreature c, Size bounds, double dt) {
    double seabedY = bounds.height - 32.0;
    c.flipperPhase += dt * 5.0; // Scuttling legs

    if (_random.nextDouble() < 0.02) {
      c.targetAngle = (_random.nextBool()) ? 0 : pi; // Left or Right
    }

    double speed = (c.targetAngle == 0) ? c.config.maxSpeed : -c.config.maxSpeed;
    c.position += Offset(speed * dt, 0);

    // Keep on sand bed within screen width
    c.position = Offset(
      c.position.dx.clamp(40.0, bounds.width - 40.0),
      seabedY,
    );
  }
}
