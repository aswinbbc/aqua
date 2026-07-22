# Aqua Bottle (aqua_bottle) 🌊🐟

A **60fps reactive water wave ripple physics & aquatic simulation background package** for Flutter applications.

Features 12 hyper-realistic fish species (_Koi, Betta, Discus, Clownfish, Angelfish, Guppy, Blue Tang, Neon Tetra, Black Moor_), 6 non-fish marine creatures (_Bioluminescent Jellyfish, Green Sea Turtle, Manta Ray, Seahorse, Starfish, Hermit Crab_), physical optical water wave refraction, splash particles, and dynamic sunlight caustics.

---

## Interactive Feature Actions Demo

![Aqua Live Reactive Aquarium Demo](https://raw.githubusercontent.com/aswinbbc/aqua/main/doc/demo.gif)

---

## Features

- 💧 **Interactive Water Wave Physics**: Touch & drag gesture detection spawning spreading liquid wave trains with convex lens optical refraction & splash droplet particles.
- 🐟 **12 Realistic Fish Species**: Procedural 10-joint serpentine skeleton wave animation, operculum gill respiration, rotational torque physics, and $z$-depth water column parallax shading.
- 🪼 **6 Marine Creature Types**: Bioluminescent jellyfish bell pulsation, green sea turtle paddling, manta ray wing undulation, seahorse coronet crown, starfish, and hermit crabs.
- 🎨 **Aquatic Presets**: _Crystal Lagoon_, _Deep Ocean_, _Sunset Pond_, and _Emerald Reef_.
- 🎮 **Programmatic Control**: Use `AquariumController` to trigger water wave ripples, drop food pellets, add/remove fish, or switch water themes from your own app buttons!

---

## Installation

Add `aqua_bottle` to your `pubspec.yaml`:

```yaml
dependencies:
  aqua_bottle: ^1.2.2
```

Or reference via Git:

```yaml
dependencies:
  aqua_bottle:
    git:
      url: https://github.com/aswinbbc/aqua.git
      ref: main
```

Run:

```bash
flutter pub get
```

---

## Usage

### 1. Basic Background Usage

Wrap your screen or dashboard UI with `AquariumBackground`:

```dart
import 'package:flutter/material.dart';
import 'package:aqua_bottle/aqua.dart';

class MyScreen extends StatelessWidget {
  const MyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AquariumBackground(
      populations: const {
        Aquatic.koiSanke: 2,
        Aquatic.guppy: 4,
        Aquatic.goldfish: 2,
        Aquatic.jellyfish: 2,
        Aquatic.turtle: 1,
        Aquatic.manta: 1,
      },
      themePreset: AquariumThemePreset.crystalLagoon,
      enableTouchRipples: true, // Listens to touch/drag and generates water ripples
      child: Scaffold(
        backgroundColor: Colors.transparent, // Allows live aquarium background to show through!
        appBar: AppBar(
          title: const Text('My App Screen'),
          backgroundColor: Colors.black26,
        ),
        body: const Center(
          child: Text(
            'Live Interactive Water Background!',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      ),
    );
  }
}
```

---

### 2. Programmatic Control (`AquariumController`)

Control water ripples, food drops, themes, and fish population programmatically from your app UI:

```dart
final AquariumController _aquariumController = AquariumController();

// Pass controller to AquariumBackground:
AquariumBackground(
  controller: _aquariumController,
  child: MyUI(),
);

// Trigger water wave ripples from your button click:
_aquariumController.addRipple(const Offset(200, 300), amplitude: 1.5);

// Drop food pellet to feed fish:
_aquariumController.dropFood();

// Change water theme:
_aquariumController.setTheme(AquariumThemePreset.deepOcean);

// Update fish population count:
_aquariumController.setFishCount(15);

// Put aquarium into loading state (fishes school into a central circle vortex):
_aquariumController.startLoading();

// Stop loading state (fishes disperse back to normal):
_aquariumController.stopLoading();
```

---

## Available Presets & Models

- **`AquariumThemePreset`**: `crystalLagoon`, `deepOcean`, `sunsetPond`, `emeraldReef`.
- **`FishSpecies`**: `koiSanke`, `koiKohaku`, `koiTancho`, `goldfish`, `blackMoor`, `bettaSplendens`, `blueTang`, `neonTetra`, `discusFish`, `angelFish`, `clownfish`, `fancyGuppy`.
- **`CreatureType`**: `jellyfish`, `seaTurtle`, `mantaRay`, `seahorse`, `starfish`, `hermitCrab`.

---

## License

MIT License. Free for personal and commercial Flutter projects.
