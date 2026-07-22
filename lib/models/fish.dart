import 'dart:math';
import 'package:flutter/material.dart';

enum FishSpecies {
  koiSanke,
  koiKohaku,
  koiTancho,
  goldfish,
  blackMoor,
  bettaSplendens,
  blueTang,
  neonTetra,
  discusFish,
  angelFish,
  clownfish,
  fancyGuppy,
}

class FishSpeciesConfig {
  final String name;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final Color finColor;
  final Color eyeColor;
  final double bodyLength;
  final double bodyWidth;
  final double maxSpeed;
  final double tailWiggleMultiplier;

  const FishSpeciesConfig({
    required this.name,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.finColor,
    required this.eyeColor,
    required this.bodyLength,
    required this.bodyWidth,
    required this.maxSpeed,
    required this.tailWiggleMultiplier,
  });

  static const FishSpeciesConfig koiSanke = FishSpeciesConfig(
    name: 'Sanke Koi',
    primaryColor: Color(0xFFF5F5F5),
    secondaryColor: Color(0xFFFF3300),
    accentColor: Color(0xFF1A1A1A),
    finColor: Color(0xDDFFFFFF),
    eyeColor: Color(0xFF111111),
    bodyLength: 54.0,
    bodyWidth: 19.0,
    maxSpeed: 85.0,
    tailWiggleMultiplier: 1.0,
  );

  static const FishSpeciesConfig koiKohaku = FishSpeciesConfig(
    name: 'Kohaku Koi',
    primaryColor: Color(0xFFFAFAFA),
    secondaryColor: Color(0xFFEE2C2C),
    accentColor: Color(0xFFEE2C2C),
    finColor: Color(0xDDF8F8F8),
    eyeColor: Color(0xFF111111),
    bodyLength: 50.0,
    bodyWidth: 17.5,
    maxSpeed: 90.0,
    tailWiggleMultiplier: 1.1,
  );

  static const FishSpeciesConfig koiTancho = FishSpeciesConfig(
    name: 'Tancho Koi',
    primaryColor: Color(0xFFFFFFFF),
    secondaryColor: Color(0xFFD50000), // Crimson Crown
    accentColor: Color(0xFFD50000),
    finColor: Color(0xEEFFFFFF),
    eyeColor: Color(0xFF111111),
    bodyLength: 52.0,
    bodyWidth: 18.0,
    maxSpeed: 88.0,
    tailWiggleMultiplier: 1.05,
  );

  static const FishSpeciesConfig goldfish = FishSpeciesConfig(
    name: 'Golden Comet',
    primaryColor: Color(0xFFFF7700),
    secondaryColor: Color(0xFFFFB300),
    accentColor: Color(0xFFFFFFFF),
    finColor: Color(0xCCFF8C00),
    eyeColor: Color(0xFF222222),
    bodyLength: 44.0,
    bodyWidth: 17.0,
    maxSpeed: 75.0,
    tailWiggleMultiplier: 1.2,
  );

  static const FishSpeciesConfig blackMoor = FishSpeciesConfig(
    name: 'Black Moor',
    primaryColor: Color(0xFF1C1C1E), // Velvet Black
    secondaryColor: Color(0xFF2C2C2E),
    accentColor: Color(0xFF3A3A3C),
    finColor: Color(0xCC111111),
    eyeColor: Color(0xFF000000),
    bodyLength: 42.0,
    bodyWidth: 20.0,
    maxSpeed: 68.0,
    tailWiggleMultiplier: 1.25,
  );

  static const FishSpeciesConfig bettaSplendens = FishSpeciesConfig(
    name: 'Royal Betta',
    primaryColor: Color(0xFF0033CC),
    secondaryColor: Color(0xFF9900FF),
    accentColor: Color(0xFFFF0066),
    finColor: Color(0xDD9900FF),
    eyeColor: Color(0xFF001A4D),
    bodyLength: 38.0,
    bodyWidth: 13.5,
    maxSpeed: 65.0,
    tailWiggleMultiplier: 1.4,
  );

  static const FishSpeciesConfig blueTang = FishSpeciesConfig(
    name: 'Pacific Blue Tang',
    primaryColor: Color(0xFF1A52EB),
    secondaryColor: Color(0xFF111827),
    accentColor: Color(0xFFFFD700),
    finColor: Color(0xDD0F3BB0),
    eyeColor: Color(0xFF000033),
    bodyLength: 42.0,
    bodyWidth: 18.0,
    maxSpeed: 100.0,
    tailWiggleMultiplier: 1.3,
  );

  static const FishSpeciesConfig neonTetra = FishSpeciesConfig(
    name: 'Neon Tetra',
    primaryColor: Color(0xFF00E5FF),
    secondaryColor: Color(0xFFFF1744),
    accentColor: Color(0xFFE0F7FA),
    finColor: Color(0x9900E5FF),
    eyeColor: Color(0xFF00B0FF),
    bodyLength: 30.0,
    bodyWidth: 9.5,
    maxSpeed: 115.0,
    tailWiggleMultiplier: 1.6,
  );

  static const FishSpeciesConfig discusFish = FishSpeciesConfig(
    name: 'Turquoise Discus',
    primaryColor: Color(0xFF00B4D8), // Turquoise Blue
    secondaryColor: Color(0xFFFF6B6B), // Tiger Coral Orange
    accentColor: Color(0xFFFFD166),
    finColor: Color(0xCC0096C7),
    eyeColor: Color(0xFFD00000), // Red Eye
    bodyLength: 46.0,
    bodyWidth: 26.0, // Tall Disk Shape
    maxSpeed: 70.0,
    tailWiggleMultiplier: 1.1,
  );

  static const FishSpeciesConfig angelFish = FishSpeciesConfig(
    name: 'Silver Angelfish',
    primaryColor: Color(0xFFE2E8F0), // Shimmering Silver
    secondaryColor: Color(0xFF1E293B), // Dark Vertical Bars
    accentColor: Color(0xFFF59E0B),
    finColor: Color(0xAAE2E8F0),
    eyeColor: Color(0xFFDC2626),
    bodyLength: 44.0,
    bodyWidth: 22.0,
    maxSpeed: 80.0,
    tailWiggleMultiplier: 1.15,
  );

  static const FishSpeciesConfig clownfish = FishSpeciesConfig(
    name: 'Ocellaris Clownfish',
    primaryColor: Color(0xFFFF5722), // Vibrant Orange
    secondaryColor: Color(0xFFFFFFFF), // Pure White Stripe
    accentColor: Color(0xFF111111), // Black Edges
    finColor: Color(0xDDFF7043),
    eyeColor: Color(0xFF212121),
    bodyLength: 36.0,
    bodyWidth: 15.0,
    maxSpeed: 82.0,
    tailWiggleMultiplier: 1.35,
  );

  static const FishSpeciesConfig fancyGuppy = FishSpeciesConfig(
    name: 'Fancy Guppy',
    primaryColor: Color(0xFF00F5D4), // Iridescent Mint Cyan
    secondaryColor: Color(0xFF7B2CBF), // Magenta Purple
    accentColor: Color(0xFFFF007F), // Hot Pink
    finColor: Color(0xEE7B2CBF),
    eyeColor: Color(0xFF0F051D),
    bodyLength: 32.0,
    bodyWidth: 10.0,
    maxSpeed: 105.0,
    tailWiggleMultiplier: 1.7,
  );

  static FishSpeciesConfig getConfig(FishSpecies species) {
    switch (species) {
      case FishSpecies.koiSanke:
        return koiSanke;
      case FishSpecies.koiKohaku:
        return koiKohaku;
      case FishSpecies.koiTancho:
        return koiTancho;
      case FishSpecies.goldfish:
        return goldfish;
      case FishSpecies.blackMoor:
        return blackMoor;
      case FishSpecies.bettaSplendens:
        return bettaSplendens;
      case FishSpecies.blueTang:
        return blueTang;
      case FishSpecies.neonTetra:
        return neonTetra;
      case FishSpecies.discusFish:
        return discusFish;
      case FishSpecies.angelFish:
        return angelFish;
      case FishSpecies.clownfish:
        return clownfish;
      case FishSpecies.fancyGuppy:
        return fancyGuppy;
    }
  }
}

enum FishState {
  wandering,
  fleeing,
  seekingFood,
  loading,
}

class Fish {
  final int id;
  Offset position;
  Offset velocity;
  double angle;
  double targetAngle;
  double angularVelocity;
  final FishSpecies species;
  final FishSpeciesConfig config;
  final double scale;
  final double depth; // 0.5 (deep underwater) to 1.25 (shallow surface)

  FishState state;
  double stateTimer;
  
  double wigglePhase;
  double gillPhase;
  
  List<Offset> spineJoints;
  List<double> jointAngles;
  static const int numJoints = 10;

  Fish({
    required this.id,
    required this.position,
    required this.angle,
    required this.species,
    this.scale = 1.0,
    double? depth,
  })  : config = FishSpeciesConfig.getConfig(species),
        depth = depth ?? (0.55 + Random().nextDouble() * 0.65),
        velocity = Offset(cos(angle), sin(angle)) * 40.0,
        targetAngle = angle,
        angularVelocity = 0.0,
        state = FishState.wandering,
        stateTimer = 0.0,
        wigglePhase = Random().nextDouble() * 2 * pi,
        gillPhase = Random().nextDouble() * 2 * pi,
        jointAngles = List.filled(numJoints, angle),
        spineJoints = List.generate(
          numJoints,
          (i) => position - Offset(cos(angle), sin(angle)) * (i * (FishSpeciesConfig.getConfig(species).bodyLength / numJoints)),
        );

  double get currentSpeed => velocity.distance;
}
