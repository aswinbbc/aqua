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
import 'aquarium_controller.dart';

/// A 60fps reactive water wave ripple and fish simulation background widget.
///
/// Use as a standalone screen or wrap your app content:
/// ```dart
/// AquariumBackground(
///   initialFishCount: 10,
///   themePreset: AquariumThemePreset.crystalLagoon,
///   child: MyScreenContent(),
/// )
/// ```
class AquariumBackground extends StatefulWidget {
  final Widget? child;
  final AquariumController? controller;
  final int initialFishCount;
  final AquariumThemePreset themePreset;
  final bool enableCreatures;
  final bool enableCaustics;
  final bool enableControls;
  final bool enableTouchRipples;
  final ValueChanged<Offset>? onTap;

  const AquariumBackground({
    super.key,
    this.child,
    this.controller,
    this.initialFishCount = 8,
    this.themePreset = AquariumThemePreset.crystalLagoon,
    this.enableCreatures = true,
    this.enableCaustics = true,
    this.enableControls = false,
    this.enableTouchRipples = true,
    this.onTap,
  });

  @override
  State<AquariumBackground> createState() => _AquariumBackgroundState();
}

class _AquariumBackgroundState extends State<AquariumBackground> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final FishBehaviorEngine _fishEngine = FishBehaviorEngine();
  final CreatureBehaviorEngine _creatureEngine = CreatureBehaviorEngine();
  final Random _random = Random();

  List<Fish> _fishes = [];
  List<AquaticCreature> _creatures = [];
  final List<Ripple> _ripples = [];
  final List<FoodPellet> _foodPellets = [];

  late AquariumThemePreset _currentThemePreset;
  late bool _enableCaustics;
  late bool _isControlsVisible;
  double _animationTime = 0.0;
  DateTime _lastFrameTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _currentThemePreset = widget.themePreset;
    _enableCaustics = widget.enableCaustics;
    _isControlsVisible = widget.enableControls;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _animationController.addListener(_onFrame);

    _attachController();
  }

  @override
  void didUpdateWidget(covariant AquariumBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.detach();
      _attachController();
    }
  }

  void _attachController() {
    widget.controller?.attach(
      onAddRipple: _addRipple,
      onDropFood: _dropFood,
      onSetFishCount: _setFishCount,
      onSetTheme: (preset) => setState(() => _currentThemePreset = preset),
      onToggleCaustics: (enabled) => setState(() => _enableCaustics = enabled),
      onToggleControls: (visible) => setState(() => _isControlsVisible = visible),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_fishes.isEmpty) {
      _initAquarium(widget.initialFishCount);
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

    if (widget.enableCreatures) {
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
    } else {
      _creatures.clear();
    }
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

      if (widget.enableCreatures) {
        _creatureEngine.update(
          creatures: _creatures,
          bounds: screenSize,
          dt: dt,
        );
      }
    });
  }

  void _addRipple(Offset position, [double amplitude = 1.0, double maxRadius = 160.0]) {
    if (_ripples.length > 25) {
      _ripples.removeAt(0);
    }
    _ripples.add(Ripple(
      position: position,
      amplitude: amplitude,
      maxRadius: maxRadius,
    ));
    widget.onTap?.call(position);
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
      _addRipple(pos, 1.2, 100.0);
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
      _initAquarium(widget.initialFishCount);
    });
  }

  @override
  void dispose() {
    widget.controller?.detach();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final AquariumThemeData currentTheme = AquariumThemeData.getPreset(_currentThemePreset);

    Widget backgroundContent = Stack(
      children: [
        // 1. Seabed & Environment Background Layer
        CustomPaint(
          size: size,
          painter: EnvironmentPainter(
            theme: currentTheme,
            animationTime: _animationTime,
            screenSize: size,
          ),
        ),

        // 2. Non-fish Aquatic Creatures Layer
        if (widget.enableCreatures)
          CustomPaint(
            size: size,
            painter: CreaturePainter(
              creatures: _creatures,
              animationTime: _animationTime,
            ),
          ),

        // 3. Fish Swimming Layer
        CustomPaint(
          size: size,
          painter: FishPainter(
            fishes: _fishes,
            animationTime: _animationTime,
          ),
        ),

        // 4. Water Caustics, Surface Waves & Food Layer
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

        // 5. Child UI Content Layer
        if (widget.child != null) Positioned.fill(child: widget.child!),

        // 6. Reactive Touch & Drag Listener (placed ON TOP of child so it intercepts touches, translucent)
        if (widget.enableTouchRipples)
          Positioned.fill(
            child: Listener(
              behavior: HitTestBehavior.translucent,
              onPointerDown: (event) {
                _addRipple(event.localPosition, 1.0, 160.0);
              },
              onPointerMove: (event) {
                if (_random.nextDouble() < 0.35) {
                  _addRipple(event.localPosition, 0.6, 100.0);
                }
              },
            ),
          ),

        // 7. GestureDetector strictly for double-tap-to-feed (translucent, only overrides onDoubleTapDown)
        if (widget.enableTouchRipples)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onDoubleTapDown: (details) {
                _dropFood(details.localPosition);
              },
            ),
          ),

        // 8. Optional Glassmorphism Controls Overlay (placed on top of the touch interceptors to prevent overlay clicks from triggering ripples/feeding)
        if (widget.enableControls || _isControlsVisible)
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
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: backgroundContent,
    );
  }
}
