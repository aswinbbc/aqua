import 'package:flutter/material.dart';

enum AquariumThemePreset {
  crystalLagoon,
  deepOcean,
  sunsetPond,
  emeraldReef,
}

class AquariumThemeData {
  final String name;
  final Color deepWaterColor;
  final Color shallowWaterColor;
  final Color sandColor;
  final Color causticsColor;
  final List<Color> seaweedColors;
  final Color lightBeamColor;
  final Color rippleHighlight;

  const AquariumThemeData({
    required this.name,
    required this.deepWaterColor,
    required this.shallowWaterColor,
    required this.sandColor,
    required this.causticsColor,
    required this.seaweedColors,
    required this.lightBeamColor,
    required this.rippleHighlight,
  });

  static const AquariumThemeData crystalLagoon = AquariumThemeData(
    name: 'Crystal Lagoon',
    deepWaterColor: Color(0xFF003855),
    shallowWaterColor: Color(0xFF008BAA),
    sandColor: Color(0xFFC2B280),
    causticsColor: Color(0x33B2F5FF),
    seaweedColors: [Color(0xFF1B4D3E), Color(0xFF2E8B57), Color(0xFF3CB371)],
    lightBeamColor: Color(0x1AEEF9FF),
    rippleHighlight: Color(0x99FFFFFF),
  );

  static const AquariumThemeData deepOcean = AquariumThemeData(
    name: 'Deep Ocean',
    deepWaterColor: Color(0xFF050E28),
    shallowWaterColor: Color(0xFF0E3060),
    sandColor: Color(0xFF304058),
    causticsColor: Color(0x2B40A0FF),
    seaweedColors: [Color(0xFF0F3B43), Color(0xFF1E5B68), Color(0xFF2D7A88)],
    lightBeamColor: Color(0x1880C0FF),
    rippleHighlight: Color(0x8090C8FF),
  );

  static const AquariumThemeData sunsetPond = AquariumThemeData(
    name: 'Sunset Pond',
    deepWaterColor: Color(0xFF2D0922),
    shallowWaterColor: Color(0xFF7A2048),
    sandColor: Color(0xFF4A3525),
    causticsColor: Color(0x33FFB370),
    seaweedColors: [Color(0xFF4E2A18), Color(0xFF6B3E26), Color(0xFF8B4513)],
    lightBeamColor: Color(0x22FFE0B2),
    rippleHighlight: Color(0x99FFE0B2),
  );

  static const AquariumThemeData emeraldReef = AquariumThemeData(
    name: 'Emerald Reef',
    deepWaterColor: Color(0xFF042920),
    shallowWaterColor: Color(0xFF0B6651),
    sandColor: Color(0xFF556B2F),
    causticsColor: Color(0x3066FFB3),
    seaweedColors: [Color(0xFF0D3B2E), Color(0xFF155E4A), Color(0xFF208A6E)],
    lightBeamColor: Color(0x1AE0FFE8),
    rippleHighlight: Color(0x99A3FFD6),
  );

  static AquariumThemeData getPreset(AquariumThemePreset preset) {
    switch (preset) {
      case AquariumThemePreset.crystalLagoon:
        return crystalLagoon;
      case AquariumThemePreset.deepOcean:
        return deepOcean;
      case AquariumThemePreset.sunsetPond:
        return sunsetPond;
      case AquariumThemePreset.emeraldReef:
        return emeraldReef;
    }
  }
}
