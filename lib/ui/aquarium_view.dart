import 'dart:math';
import 'package:flutter/material.dart';
import '../models/fish.dart';
import '../models/aquatic_creature.dart';
import '../models/ripple.dart';
import '../models/food_pellet.dart';
import '../models/theme.dart';
import '../simulation/fish_behavior_engine.dart';
import '../simulation/creature_behavior_engine.dart';
import '../renderers/environment_painter.dart';
import '../renderers/fish_painter.dart';
import '../renderers/creature_painter.dart';
import '../renderers/water_surface_painter.dart';
import 'controls_overlay.dart';

class AquariumView extends StatefulWidget {
  const AquariumView({super.key});

  @override
  State<AquariumView> createState() => _AquariumViewState();
}

class _AquariumViewState extends State<AquariumView> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final FishBehaviorEngine _fishEngine = FishBehaviorEngine();
  final CreatureBehaviorEngine _creatureEngine = CreatureBehaviorEngine();
  final Random _random = Random();

  List<Fish> _fishes = [];
  List<AquaticCreature> _creatures = [];
  final List<Ripple> _ripples = [];
  final List<FoodPellet> _foodPellets = [];

  AquariumThemePreset _currentThemePreset = AquariumThemePreset.crystalLagoon;
  bool _enableCaustics = true;
  bool _isControlsVisible = true;
  double _animationTime = 0.0;
  DateTime _lastFrameTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _controller.addListener(_onFrame);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_fishes.isEmpty) {
      _initAquarium(8);
    }
  }

  void _initAquarium(int fishCount) {
    final Size size = MediaQuery.of(context).size;
    final List<FishSpecies> speciesList = FishSpecies.values;

    _fishes = List.generate(fishCount, (i) {
      FishSpecies species = speciesList[i % speciesList.length];
      double angle = _random.nextDouble() * 2 * pi;
      double scale = 0.85 + _random.nextDouble() * 0.45;

      double x = 60.0 + _random.nextDouble() * (size.width - 120.0);
      double y = 60.0 + _random.nextDouble() * (size.height - 120.0);

      return Fish(
        id: i,
        position: Offset(x, y),
        angle: angle,
        species: species,
        scale: scale,
      );
    });

    final List<CreatureType> creatureTypes = CreatureType.values;
    _creatures = List.generate(creatureTypes.length * 2, (i) {
      CreatureType type = creatureTypes[i % creatureTypes.length];
      double x = 80.0 + _random.nextDouble() * (size.width - 160.0);
      double y = (CreatureConfig.getConfig(type).isSeabedDweller)
          ? size.height - 35.0
          : 90.0 + _random.nextDouble() * (size.height - 220.0);

      return AquaticCreature(
        id: i,
        position: Offset(x, y),
        angle: (type == CreatureType.seahorse) ? -pi / 2 : _random.nextDouble() * 2 * pi,
        type: type,
        scale: 0.9 + _random.nextDouble() * 0.35,
      );
    });
  }

  void _onFrame() {
    final DateTime now = DateTime.now();
    final double dt = now.difference(_lastFrameTime).inMicroseconds / 1000000.0;
    _lastFrameTime = now;

    if (dt <= 0 || dt > 0.1) return;

    setState(() {
      _animationTime += dt;

      _ripples.removeWhere((r) => r.isExpired);
      for (var ripple in _ripples) {
        ripple.update(dt);
      }

      _foodPellets.removeWhere((p) => p.isEaten);
      for (var pellet in _foodPellets) {
        pellet.update(dt);
      }

      final Size screenSize = MediaQuery.of(context).size;
      _fishEngine.update(
        fishes: _fishes,
        ripples: _ripples,
        foodPellets: _foodPellets,
        bounds: screenSize,
        dt: dt,
      );

      _creatureEngine.update(
        creatures: _creatures,
        bounds: screenSize,
        dt: dt,
      );
    });
  }

  void _addRipple(Offset position, {double amplitude = 1.0, double maxRadius = 160.0}) {
    if (_ripples.length > 25) {
      _ripples.removeAt(0);
    }
    _ripples.add(Ripple(
      position: position,
      amplitude: amplitude,
      maxRadius: maxRadius,
    ));
  }

  void _dropFood([Offset? customPosition]) {
    final Size size = MediaQuery.of(context).size;
    Offset pos = customPosition ??
        Offset(
          100.0 + _random.nextDouble() * (size.width - 200.0),
          100.0 + _random.nextDouble() * (size.height - 200.0),
        );

    setState(() {
      _foodPellets.add(FoodPellet(position: pos));
      _addRipple(pos, amplitude: 1.2, maxRadius: 100.0);
    });
  }

  void _setFishCount(int count) {
    setState(() {
      if (count > _fishes.length) {
        final Size size = MediaQuery.of(context).size;
        final List<FishSpecies> speciesList = FishSpecies.values;
        int toAdd = count - _fishes.length;

        for (int i = 0; i < toAdd; i++) {
          int newId = _fishes.length + i;
          FishSpecies species = speciesList[newId % speciesList.length];
          double angle = _random.nextDouble() * 2 * pi;

          _fishes.add(Fish(
            id: newId,
            position: Offset(
              60.0 + _random.nextDouble() * (size.width - 120.0),
              60.0 + _random.nextDouble() * (size.height - 120.0),
            ),
            angle: angle,
            species: species,
            scale: 0.85 + _random.nextDouble() * 0.4,
          ));
        }
      } else if (count < _fishes.length) {
        _fishes = _fishes.sublist(0, count);
      }
    });
  }

  void _resetAquarium() {
    setState(() {
      _ripples.clear();
      _foodPellets.clear();
      _initAquarium(8);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final AquariumThemeData currentTheme = AquariumThemeData.getPreset(_currentThemePreset);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          CustomPaint(
            size: size,
            painter: EnvironmentPainter(
              theme: currentTheme,
              animationTime: _animationTime,
              screenSize: size,
            ),
          ),
          CustomPaint(
            size: size,
            painter: CreaturePainter(
              creatures: _creatures,
              animationTime: _animationTime,
            ),
          ),
          CustomPaint(
            size: size,
            painter: FishPainter(
              fishes: _fishes,
              animationTime: _animationTime,
            ),
          ),
          CustomPaint(
            size: size,
            painter: WaterSurfacePainter(
              ripples: _ripples,
              foodPellets: _foodPellets,
              theme: currentTheme,
              animationTime: _animationTime,
              enableCaustics: _enableCaustics,
            ),
          ),
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTapDown: (details) {
                _addRipple(details.localPosition, amplitude: 1.0);
              },
              onPanUpdate: (details) {
                if (_random.nextDouble() < 0.35) {
                  _addRipple(details.localPosition, amplitude: 0.6, maxRadius: 100.0);
                }
              },
              onDoubleTapDown: (details) {
                _dropFood(details.localPosition);
              },
            ),
          ),
          ControlsOverlay(
            fishCount: _fishes.length,
            activeRipplesCount: _ripples.length,
            activeFoodCount: _foodPellets.length,
            currentPreset: _currentThemePreset,
            enableCaustics: _enableCaustics,
            isControlsVisible: _isControlsVisible,
            onFishCountChanged: _setFishCount,
            onDropFood: () => _dropFood(),
            onThemeChanged: (preset) {
              setState(() {
                _currentThemePreset = preset;
              });
            },
            onToggleCaustics: (val) {
              setState(() {
                _enableCaustics = val;
              });
            },
            onResetAquarium: _resetAquarium,
            onToggleControlsVisibility: () {
              setState(() {
                _isControlsVisible = !_isControlsVisible;
              });
            },
          ),
        ],
      ),
    );
  }
}
