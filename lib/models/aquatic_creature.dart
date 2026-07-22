import 'dart:math';
import 'package:flutter/material.dart';
import 'fish.dart';

enum CreatureType {
  jellyfish,
  seaTurtle,
  mantaRay,
  seahorse,
  starfish,
  hermitCrab,
}

class CreatureConfig {
  final String name;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final double size;
  final double maxSpeed;
  final bool isSeabedDweller;

  const CreatureConfig({
    required this.name,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.size,
    required this.maxSpeed,
    this.isSeabedDweller = false,
  });

  static const CreatureConfig jellyfish = CreatureConfig(
    name: 'Bioluminescent Jellyfish',
    primaryColor: Color(0xDD00E5FF),
    secondaryColor: Color(0xDD7B2CBF),
    accentColor: Color(0xFFE0F7FA),
    size: 42.0,
    maxSpeed: 35.0,
  );

  static const CreatureConfig seaTurtle = CreatureConfig(
    name: 'Green Sea Turtle',
    primaryColor: Color(0xFF2E7D32),
    secondaryColor: Color(0xFF8D6E63),
    accentColor: Color(0xFFFFD54F),
    size: 58.0,
    maxSpeed: 55.0,
  );

  static const CreatureConfig mantaRay = CreatureConfig(
    name: 'Ocean Manta Ray',
    primaryColor: Color(0xFF1A237E),
    secondaryColor: Color(0xFFE0E0E0),
    accentColor: Color(0xFF00B0FF),
    size: 68.0,
    maxSpeed: 60.0,
  );

  static const CreatureConfig seahorse = CreatureConfig(
    name: 'Golden Seahorse',
    primaryColor: Color(0xFFFF8F00),
    secondaryColor: Color(0xFFFFD54F),
    accentColor: Color(0xFFFF3D00),
    size: 34.0,
    maxSpeed: 25.0,
  );

  static const CreatureConfig starfish = CreatureConfig(
    name: 'Coral Starfish',
    primaryColor: Color(0xFFFF3D00),
    secondaryColor: Color(0xFFFF9100),
    accentColor: Color(0xFFFFFF00),
    size: 30.0,
    maxSpeed: 4.0,
    isSeabedDweller: true,
  );

  static const CreatureConfig hermitCrab = CreatureConfig(
    name: 'Red Hermit Crab',
    primaryColor: Color(0xFFD50000),
    secondaryColor: Color(0xFFFF6D00),
    accentColor: Color(0xFF4E342E),
    size: 32.0,
    maxSpeed: 18.0,
    isSeabedDweller: true,
  );

  static CreatureConfig getConfig(CreatureType type) {
    switch (type) {
      case CreatureType.jellyfish:
        return jellyfish;
      case CreatureType.seaTurtle:
        return seaTurtle;
      case CreatureType.mantaRay:
        return mantaRay;
      case CreatureType.seahorse:
        return seahorse;
      case CreatureType.starfish:
        return starfish;
      case CreatureType.hermitCrab:
        return hermitCrab;
    }
  }
}

class AquaticCreature {
  final int id;
  Offset position;
  Offset velocity;
  double angle;
  double targetAngle;
  final CreatureType type;
  final CreatureConfig config;
  final double scale;

  double pulsePhase;
  double flipperPhase;

  FishState state;
  FishLoadingPhase loadingPhase;

  AquaticCreature({
    required this.id,
    required this.position,
    required this.angle,
    required this.type,
    this.scale = 1.0,
  })  : config = CreatureConfig.getConfig(type),
        velocity = Offset(cos(angle), sin(angle)) * (CreatureConfig.getConfig(type).maxSpeed * 0.5),
        targetAngle = angle,
        pulsePhase = Random().nextDouble() * 2 * pi,
        flipperPhase = Random().nextDouble() * 2 * pi,
        state = FishState.wandering,
        loadingPhase = FishLoadingPhase.none;
}
