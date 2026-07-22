import 'package:flutter/material.dart';
import 'aquarium_background.dart';
import '../models/aquatic.dart';

class AquariumView extends StatelessWidget {
  const AquariumView({super.key});

  @override
  Widget build(BuildContext context) {
    return const AquariumBackground(
      enableControls: true,
      populations: {
        Aquatic.goldfish: 2,
        Aquatic.guppy: 2,
        Aquatic.clownfish: 2,
        Aquatic.neonTetra: 2,
        Aquatic.jellyfish: 2,
        Aquatic.turtle: 1,
        Aquatic.manta: 1,
        Aquatic.seahorse: 1,
        Aquatic.starfish: 1,
        Aquatic.crab: 1,
      },
    );
  }
}
