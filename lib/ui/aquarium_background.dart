import 'dart:math';
import 'package:flutter/material.dart';
import '../models/fish.dart';
import '../models/aquatic_creature.dart';
import '../models/aquatic.dart';
import '../models/bubble.dart';
import '../models/ripple.dart';
import '../models/food_pellet.dart';
import '../models/theme.dart';
import '../simulation/fish_behavior_engine.dart';
import '../simulation/creature_behavior_engine.dart';
import '../renderers/environment_painter.dart';
import '../renderers/fish_painter.dart';
import '../renderers/creature_painter.dart';
import '../renderers/bubble_painter.dart';
import '../renderers/water_surface_painter.dart';
import 'controls_overlay.dart';
import 'aquarium_controller.dart';

/// A 60fps reactive water wave ripple and fish simulation background widget.
///
/// Use as a standalone screen or wrap your app content:
/// ```dart
/// AquariumBackground(
///   populations: const {
///     Aquatic.guppy: 2,
///     Aquatic.goldfish: 3,
///     Aquatic.jellyfish: 1,
///   },
///   themePreset: AquariumThemePreset.crystalLagoon,
///   enableBubbles: true,
///   child: MyScreenContent(),
/// )
/// ```
class AquariumBackground extends StatefulWidget {
  final Widget? child;
  final AquariumController? controller;
  final Map<Aquatic, int>? populations;
  final AquariumThemePreset themePreset;
  final bool enableCaustics;
  final bool enableControls;
  final bool enableTouchRipples;
  final bool enableSwipeRipples;
  final bool enableBubbles;
  final ValueChanged<Offset>? onTap;

  const AquariumBackground({
    key,
    this.child,
    this.controller,
    this.populations,
    this.themePreset = AquariumThemePreset.crystalLagoon,
    this.enableCaustics = true,
    this.enableControls = false,
    this.enableTouchRipples = true,
    this.enableSwipeRipples = true,
    this.enableBubbles = true,
    this.onTap,
  }) : super(key: key);

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
  final List<Bubble> _bubbles = [];

  // Track position of each pointer to throttle swipe ripples by distance
  final Map<int, Offset> _lastPointerPositions = {};

  late AquariumThemePreset _currentThemePreset;
  late bool _enableCaustics;
  late bool _isControlsVisible;
  bool _isLoading = false;
  double _timeSinceAligned = 0.0;
  bool _allAligned = false;
  double _orbitBaseAngle = 0.0;
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
      onStartLoading: () => setState(() => _isLoading = true),
      onStopLoading: () => setState(() => _isLoading = false),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_fishes.isEmpty && _creatures.isEmpty) {
      _initAquarium();
    }
  }

  void _initAquarium() {
    final Size size = MediaQuery.of(context).size;
    _fishes.clear();
    _creatures.clear();

    if (widget.populations != null && widget.populations!.isNotEmpty) {
      int fishIndex = 0;
      int creatureIndex = 0;

      widget.populations!.forEach((aquatic, count) {
        if (count <= 0) return;

        if (aquatic.isFish) {
          final FishSpecies? fishSpecies = aquatic.fishSpecies;
          if (fishSpecies != null) {
            for (int i = 0; i < count; i++) {
              double angle = _random.nextDouble() * 2 * pi;
              double scale = 0.85 + _random.nextDouble() * 0.45;
              double x = 60.0 + _random.nextDouble() * (size.width - 120.0);
              double y = 60.0 + _random.nextDouble() * (size.height - 120.0);

              _fishes.add(Fish(
                id: fishIndex++,
                position: Offset(x, y),
                angle: angle,
                species: fishSpecies,
                scale: scale,
              ));
            }
          }
        } else {
          final CreatureType? creatureType = aquatic.creatureType;
          if (creatureType != null) {
            for (int i = 0; i < count; i++) {
              double x = 80.0 + _random.nextDouble() * (size.width - 160.0);
              double y = (CreatureConfig.getConfig(creatureType).isSeabedDweller)
                  ? size.height - 35.0
                  : 90.0 + _random.nextDouble() * (size.height - 220.0);

              _creatures.add(AquaticCreature(
                id: creatureIndex++,
                position: Offset(x, y),
                angle: (creatureType == CreatureType.seahorse) ? -pi / 2 : _random.nextDouble() * 2 * pi,
                type: creatureType,
                scale: 0.9 + _random.nextDouble() * 0.35,
              ));
            }
          }
        }
      });
    } else {
      final List<FishSpecies> speciesList = FishSpecies.values;
      _fishes = List.generate(8, (i) {
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

      // Update bubbles
      if (widget.enableBubbles) {
        _bubbles.removeWhere((b) => b.isExpired);
        for (var bubble in _bubbles) {
          bubble.update(dt);
        }

        // Spawn bubbles from bottom of screen randomly
        if (_bubbles.length < 35 && _random.nextDouble() < 0.12) {
          final double bubbleX = _random.nextDouble() * screenSize.width;
          final double bubbleRadius = 3.0 + _random.nextDouble() * 8.0;
          _bubbles.add(Bubble(
            position: Offset(bubbleX, screenSize.height + bubbleRadius + 5.0),
            speed: 40.0 + _random.nextDouble() * 55.0,
            radius: bubbleRadius,
            driftFrequency: 1.0 + _random.nextDouble() * 2.0,
            driftAmplitude: 0.5 + _random.nextDouble() * 1.5,
          ));
        }
      } else {
        _bubbles.clear();
      }

      if (_isLoading) {
        _updateLoadingPhysics(dt, screenSize);
      } else {
        _allAligned = false;
        _timeSinceAligned = 0.0;

        _fishEngine.update(
          fishes: _fishes,
          ripples: _ripples,
          foodPellets: _foodPellets,
          bounds: screenSize,
          dt: dt,
          isLoading: false,
        );

        if (_creatures.isNotEmpty) {
          _creatureEngine.update(
            creatures: _creatures,
            bounds: screenSize,
            dt: dt,
          );
        }
      }
    });
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

  void _updateLoadingPhysics(double dt, Size bounds) {
    final List<dynamic> allObjects = [..._fishes, ..._creatures];
    if (allObjects.isEmpty) return;

    allObjects.sort((a, b) {
      final aIsFish = a is Fish;
      final bIsFish = b is Fish;
      if (aIsFish != bIsFish) return aIsFish ? -1 : 1;
      return a.id.compareTo(b.id);
    });

    double targetY = bounds.height / 2;
    double padding = 65.0;
    double availableWidth = bounds.width - padding * 2;
    double step = (allObjects.length > 1) ? (availableWidth / (allObjects.length - 1)) : 0.0;

    // Start the loading circle early as soon as any 3 objects are aligned on the horizontal line
    int alignedCount = 0;
    for (int i = 0; i < allObjects.length; i++) {
      final obj = allObjects[i];
      final double targetX = padding + i * step;
      final Offset targetPos = Offset(targetX, targetY);
      final double dist = (obj.position - targetPos).distance;
      if (dist < 28.0) {
        alignedCount++;
      }
    }

    if (!_allAligned && alignedCount >= 3) {
      _allAligned = true;
      _timeSinceAligned = 0.0;
    }

    if (_allAligned) {
      _timeSinceAligned += dt;
    } else {
      _timeSinceAligned = 0.0;
    }

    // Flawlessly rotate the circular spinner base angle always
    _orbitBaseAngle += dt * 0.98;

    final double circleRadius = 120.0;
    final Offset center = Offset(bounds.width / 2, bounds.height / 2);

    for (int i = 0; i < allObjects.length; i++) {
      final obj = allObjects[i];
      final double targetX = padding + i * step;
      final Offset lineTarget = Offset(targetX, targetY);

      // Perfect equal spacing along the shared circle perimeter:
      double angle = _orbitBaseAngle + i * (2 * pi / allObjects.length);
      Offset circleTarget = Offset(center.dx + cos(angle) * circleRadius, center.dy + sin(angle) * circleRadius);
      double tangentAngle = _normalizeAngle(angle + pi / 2);

      bool isOrbiting = false;
      bool isLocked = false;

      if (obj is Fish) {
        if (obj.loadingPhase == FishLoadingPhase.orbitingCircle) {
          isOrbiting = true;
          isLocked = true;
        } else if (_allAligned && _timeSinceAligned >= i * 0.36) {
          isOrbiting = true;
          // Transition to locked orbit once arrived near the target spot
          if ((obj.position - circleTarget).distance < 15.0) {
            isLocked = true;
            obj.loadingPhase = FishLoadingPhase.orbitingCircle;
          }
        }
      } else if (obj is AquaticCreature) {
        if (obj.loadingPhase == FishLoadingPhase.orbitingCircle) {
          isOrbiting = true;
          // Transition to locked orbit once arrived near the target spot
          if ((obj.position - circleTarget).distance < 15.0) {
            isLocked = true;
          }
        } else {
          final double distToLine = (obj.position - lineTarget).distance;
          if (distToLine < 25.0) {
            obj.loadingPhase = FishLoadingPhase.orbitingCircle;
            isOrbiting = true;
          }
        }
      }

      if (isLocked) {
        obj.position = circleTarget;
        obj.angle = tangentAngle;
        obj.velocity = Offset(cos(tangentAngle), sin(tangentAngle)) * (circleRadius * 0.98);
      } else {
        Offset target = isOrbiting ? circleTarget : lineTarget;
        final double distToTarget = (obj.position - target).distance;

        // If in align stage and arrived at slot, idle and wait
        if (!isOrbiting && distToTarget < 15.0) {
          obj.velocity = Offset.zero;
          // Turn smoothly to face right (military horizontal line format)
          double angleDiff = _normalizeAngle(0.0 - obj.angle);
          obj.angle += angleDiff * (8.5 * dt).clamp(0.0, 1.0);
        } else {
          // Active steering towards destination
          Offset dir = target - obj.position;
          double dist = dir.distance;
          if (dist > 0.1) {
            dir = dir / dist;
          }

          // Fast movement during loading ("all creatures and fishes come fast")
          double maxSpeed = (obj is Fish) ? obj.config.maxSpeed : (obj as AquaticCreature).config.maxSpeed;
          double speed = max(maxSpeed * 1.6, 125.0);

          double desiredAngle = dir.direction;
          double angleDiff = _normalizeAngle(desiredAngle - obj.angle);
          obj.angle += angleDiff * (9.5 * dt).clamp(0.0, 1.0);
          obj.angle = _normalizeAngle(obj.angle);

          obj.velocity = Offset(cos(obj.angle), sin(obj.angle)) * speed;
          obj.position += obj.velocity * dt;
        }
      }

      // Update models and animations wiggles/fins
      if (obj is Fish) {
        obj.state = FishState.loading;
        _fishEngine.updateSpineSkeleton(obj, dt);
      } else if (obj is AquaticCreature) {
        obj.state = FishState.loading;
        obj.flipperPhase += dt * 3.5;
        obj.pulsePhase += dt * 2.5;
      }
    }
  }

  void _popBubblesAt(Offset position) {
    if (_bubbles.isEmpty) return;
    _bubbles.removeWhere((bubble) {
      final double dist = (bubble.position - position).distance;
      return dist < (bubble.radius + 22.0);
    });
  }

  void _addRipple(Offset position, [double amplitude = 1.0, double maxRadius = 160.0]) {
    _popBubblesAt(position);
    if (_ripples.length > 5) {
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
      _initAquarium();
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
        if (_creatures.isNotEmpty)
          CustomPaint(
            size: size,
            painter: CreaturePainter(
              creatures: _creatures,
              animationTime: _animationTime,
            ),
          ),

        // 2.5. Rising Water Bubbles Layer
        if (widget.enableBubbles && _bubbles.isNotEmpty)
          CustomPaint(
            size: size,
            painter: BubblePainter(bubbles: _bubbles),
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
                _lastPointerPositions[event.pointer] = event.localPosition;
              },
              onPointerMove: (event) {
                if (!widget.enableSwipeRipples) return;
                final Offset? lastPos = _lastPointerPositions[event.pointer];
                if (lastPos != null) {
                  final double distance = (event.localPosition - lastPos).distance;
                  // Only spawn a move ripple if the finger has moved at least 55 pixels to throttle calculation cost
                  if (distance > 55.0) {
                    _addRipple(event.localPosition, 0.6, 110.0);
                    _lastPointerPositions[event.pointer] = event.localPosition;
                  }
                }
              },
              onPointerUp: (event) {
                _lastPointerPositions.remove(event.pointer);
              },
              onPointerCancel: (event) {
                _lastPointerPositions.remove(event.pointer);
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
            isLoading: _isLoading,
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
            onToggleLoading: () {
              setState(() {
                _isLoading = !_isLoading;
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
