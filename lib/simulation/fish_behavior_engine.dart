import 'dart:math';
import 'package:flutter/material.dart';
import '../models/fish.dart';
import '../models/ripple.dart';
import '../models/food_pellet.dart';

class FishBehaviorEngine {
  final Random _random = Random();

  void update({
    required List<Fish> fishes,
    required List<Ripple> ripples,
    required List<FoodPellet> foodPellets,
    required Size bounds,
    required double dt,
    bool isLoading = false,
  }) {
    if (bounds.width <= 0 || bounds.height <= 0) return;

    for (var fish in fishes) {
      _updateFishBehavior(fish, fishes, ripples, foodPellets, bounds, dt, isLoading);
      updateSpineSkeleton(fish, dt);
    }
  }

  void _updateFishBehavior(
    Fish fish,
    List<Fish> allFishes,
    List<Ripple> ripples,
    List<FoodPellet> foodPellets,
    Size bounds,
    double dt,
    bool isLoading,
  ) {
    fish.stateTimer += dt;
    Offset totalSteering = Offset.zero;

    // Loading vortex vortex vortex
    if (isLoading) {
      fish.state = FishState.loading;
      if (fish.loadingPhase == FishLoadingPhase.none) {
        fish.loadingPhase = FishLoadingPhase.aligningLine;
      }
    } else if (fish.state == FishState.loading) {
      fish.state = FishState.wandering;
      fish.loadingPhase = FishLoadingPhase.none;
      fish.stateTimer = 0.0;
    }

    // Special behavior override for circular vortex loading screen (Stage 1: Line, Stage 2: Circle)
    if (fish.state == FishState.loading) {
      final Offset center = Offset(bounds.width / 2, bounds.height / 2);

      // Stage 1: Swim towards horizontal center line alignment
      if (fish.loadingPhase == FishLoadingPhase.aligningLine) {
        double targetY = bounds.height / 2;
        double padding = 60.0;
        double availableWidth = bounds.width - padding * 2;
        int listIndex = allFishes.indexOf(fish);
        if (listIndex == -1) listIndex = fish.id;

        double step = (allFishes.length > 1)
            ? (availableWidth / (allFishes.length - 1))
            : 0.0;
        double targetX = padding + listIndex * step;
        Offset targetPos = Offset(targetX, targetY);

        double distToTarget = (fish.position - targetPos).distance;
        if (distToTarget < 25.0) {
          // Reached line target, transition to rotating circle stage
          fish.loadingPhase = FishLoadingPhase.orbitingCircle;
        } else {
          Offset toTarget = targetPos - fish.position;
          totalSteering += (toTarget / toTarget.distance) * 4.8;
        }
      }

      // Stage 2: Swim in a coordinated circle orbit around center
      if (fish.loadingPhase == FishLoadingPhase.orbitingCircle) {
        final double distToCenter = (fish.position - center).distance;

        // Group fishes into concentric ring orbits based on ID
        final double targetRadius = 60.0 + (fish.id % 4) * 15.0;
        final double angleFromCenter = atan2(fish.position.dy - center.dy, fish.position.dx - center.dx);

        // Desired steering vectors:
        // 1. Clockwise tangent orbiting vector
        final Offset tangent = Offset(-sin(angleFromCenter), cos(angleFromCenter));
        
        // 2. Correction vector to steer them towards their ring orbits
        final Offset radialDir = (center - fish.position) / (distToCenter.clamp(1.0, double.infinity));
        final double radialWeight = (distToCenter - targetRadius).clamp(-150.0, 150.0) / 45.0;

        final Offset desiredForce = tangent * 1.5 + radialDir * radialWeight * 2.8;
        if (desiredForce.distance > 0.01) {
          totalSteering += (desiredForce / desiredForce.distance) * 4.5;
        }
      }

      double desiredAngle = fish.angle;
      if (totalSteering.distance > 0.05) {
        desiredAngle = totalSteering.direction;
      }

      double angleDiff = _normalizeAngle(desiredAngle - fish.angle);
      fish.angularVelocity += angleDiff * 8.5 * dt;
      fish.angularVelocity *= 0.85;
      fish.angle += fish.angularVelocity * dt;
      fish.angle = _normalizeAngle(fish.angle);

      // Minor speed increase during loading (1.25x max speed vs standard 0.55x)
      double targetSpeed = fish.config.maxSpeed * 1.25;
      Offset forward = Offset(cos(fish.angle), sin(fish.angle));
      double currentSpeed = fish.velocity.distance;
      double newSpeed = currentSpeed + (targetSpeed - currentSpeed) * (4.5 * dt).clamp(0.0, 1.0);

      fish.velocity = forward * newSpeed;
      fish.position += fish.velocity * dt;
      return;
    }

    // 1. Boundary Avoidance (smooth screen padding)
    double padding = 75.0;
    Offset boundaryForce = Offset.zero;
    if (fish.position.dx < padding) {
      boundaryForce += Offset((padding - fish.position.dx) / padding, 0);
    } else if (fish.position.dx > bounds.width - padding) {
      boundaryForce += Offset((bounds.width - padding - fish.position.dx) / padding, 0);
    }
    if (fish.position.dy < padding) {
      boundaryForce += Offset(0, (padding - fish.position.dy) / padding);
    } else if (fish.position.dy > bounds.height - padding) {
      boundaryForce += Offset(0, (bounds.height - padding - fish.position.dy) / padding);
    }
    totalSteering += boundaryForce * 4.0;

    // 2. Ripple Flee Reaction (Startle physics)
    for (var ripple in ripples) {
      double dist = (fish.position - ripple.position).distance;
      if (dist < ripple.radius + 90.0 && dist > (ripple.radius - 50.0).clamp(0, double.infinity)) {
        Offset awayDir = (fish.position - ripple.position);
        if (awayDir.distance > 0.1) {
          awayDir = awayDir / awayDir.distance;
          totalSteering += awayDir * (ripple.amplitude * 5.0);
          fish.state = FishState.fleeing;
          fish.stateTimer = 0.0;
        }
      }
    }

    if (fish.state == FishState.fleeing && fish.stateTimer > 1.8) {
      fish.state = FishState.wandering;
    }

    // 3. Seeking Food Pellets
    FoodPellet? nearestFood;
    double nearestFoodDist = 320.0;
    for (var pellet in foodPellets) {
      if (pellet.isEaten) continue;
      double dist = (fish.position - pellet.position).distance;
      if (dist < nearestFoodDist) {
        nearestFoodDist = dist;
        nearestFood = pellet;
      }
    }

    if (nearestFood != null && fish.state != FishState.fleeing) {
      fish.state = FishState.seekingFood;
      Offset foodDir = (nearestFood.position - fish.position);
      if (foodDir.distance > 0.1) {
        totalSteering += (foodDir / foodDir.distance) * 2.5;
      }

      if (nearestFoodDist < 18.0) {
        nearestFood.isEaten = true;
        fish.state = FishState.wandering;
      }
    }

    // 4. Smooth Perlin-like Wandering
    if (fish.state == FishState.wandering) {
      if (_random.nextDouble() < 0.04) {
        fish.targetAngle += (_random.nextDouble() - 0.5) * 0.9;
      }
      Offset wanderDir = Offset(cos(fish.targetAngle), sin(fish.targetAngle));
      totalSteering += wanderDir * 0.9;
    }

    // 5. Schooling / Separation Force
    Offset separationForce = Offset.zero;
    int neighborCount = 0;
    for (var other in allFishes) {
      if (other.id == fish.id) continue;
      double dist = (fish.position - other.position).distance;
      if (dist < 60.0 && dist > 0.1) {
        separationForce += (fish.position - other.position) / dist;
        neighborCount++;
      }
    }
    if (neighborCount > 0) {
      totalSteering += (separationForce / neighborCount.toDouble()) * 1.8;
    }

    // Rotational Torque Physics (Inertial Smooth Turning)
    double desiredAngle = fish.angle;
    if (totalSteering.distance > 0.05) {
      desiredAngle = totalSteering.direction;
    }

    double angleDiff = _normalizeAngle(desiredAngle - fish.angle);
    double torqueSensitivity = (fish.state == FishState.fleeing) ? 14.0 : 7.0;

    // Acceleration & Rotational Damping
    fish.angularVelocity += angleDiff * torqueSensitivity * dt;
    fish.angularVelocity *= 0.86; // Angular damping
    fish.angle += fish.angularVelocity * dt;
    fish.angle = _normalizeAngle(fish.angle);

    // Linear Velocity & Speed Smooth Interpolation
    double targetSpeed = fish.config.maxSpeed;
    if (fish.state == FishState.fleeing) {
      targetSpeed *= 1.7;
    } else if (fish.state == FishState.seekingFood) {
      targetSpeed *= 1.25;
    } else {
      targetSpeed *= 0.55; // Gentle realistic gliding
    }

    Offset forward = Offset(cos(fish.angle), sin(fish.angle));
    double currentSpeed = fish.velocity.distance;
    double newSpeed = currentSpeed + (targetSpeed - currentSpeed) * (3.5 * dt).clamp(0.0, 1.0);

    fish.velocity = forward * newSpeed;
    fish.position += fish.velocity * dt;
  }

  void updateSpineSkeleton(Fish fish, double dt) {
    // 1. Update Wiggle Phase based on current speed
    double speedRatio = (fish.currentSpeed / fish.config.maxSpeed).clamp(0.1, 2.5);
    double wiggleSpeed = 8.5 * speedRatio * fish.config.tailWiggleMultiplier;
    fish.wigglePhase += dt * wiggleSpeed;

    double totalLength = fish.config.bodyLength * fish.scale;
    double segmentLength = totalLength / (Fish.numJoints - 1);

    // 2. Undulatory Traveling Wave Physics along Spine
    double headSwayAmp = 0.07 * (0.4 + 0.6 * speedRatio);
    fish.jointAngles[0] = fish.angle + sin(fish.wigglePhase) * headSwayAmp;
    fish.spineJoints[0] = fish.position;

    for (int i = 1; i < Fish.numJoints; i++) {
      double t = i / (Fish.numJoints - 1);

      // Amplitude increases towards tail with exponent curve
      double waveAmplitude = (0.03 + 0.36 * pow(t, 1.35)) * (0.5 + 0.5 * speedRatio);
      double phaseShift = t * 3.3; // Phase delay along body

      double waveOffset = sin(fish.wigglePhase - phaseShift) * waveAmplitude;
      double targetJointAngle = fish.angle + waveOffset;

      double prevAngle = fish.jointAngles[i - 1];
      double angleDiff = _normalizeAngle(targetJointAngle - prevAngle);

      fish.jointAngles[i] = prevAngle + angleDiff * 0.72;

      Offset dir = Offset(cos(fish.jointAngles[i]), sin(fish.jointAngles[i]));
      fish.spineJoints[i] = fish.spineJoints[i - 1] - (dir * segmentLength);
    }
  }

  double _normalizeAngle(double angle) {
    while (angle > pi) {
      angle -= 2 * pi;
    }
    while (angle < -pi) {
      angle += 2 * pi;
    }
    return angle;
  }
}
