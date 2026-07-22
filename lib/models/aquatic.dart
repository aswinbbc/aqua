import 'fish.dart';
import 'aquatic_creature.dart';

/// A unified species/type representing any fish or marine creature in the aquarium.
enum Aquatic {
  koiSanke,
  koiKohaku,
  koiTancho,
  goldfish,
  blackMoor,
  betta,
  blueTang,
  neonTetra,
  discus,
  angel,
  clownfish,
  guppy,
  jellyfish,
  turtle,
  manta,
  seahorse,
  starfish,
  crab,
}

extension AquaticMapper on Aquatic {
  /// Whether this species is a fish.
  bool get isFish {
    switch (this) {
      case Aquatic.koiSanke:
      case Aquatic.koiKohaku:
      case Aquatic.koiTancho:
      case Aquatic.goldfish:
      case Aquatic.blackMoor:
      case Aquatic.betta:
      case Aquatic.blueTang:
      case Aquatic.neonTetra:
      case Aquatic.discus:
      case Aquatic.angel:
      case Aquatic.clownfish:
      case Aquatic.guppy:
        return true;
      default:
        return false;
    }
  }

  /// Maps the unified species type to its internal [FishSpecies] model.
  FishSpecies? get fishSpecies {
    switch (this) {
      case Aquatic.koiSanke:
        return FishSpecies.koiSanke;
      case Aquatic.koiKohaku:
        return FishSpecies.koiKohaku;
      case Aquatic.koiTancho:
        return FishSpecies.koiTancho;
      case Aquatic.goldfish:
        return FishSpecies.goldfish;
      case Aquatic.blackMoor:
        return FishSpecies.blackMoor;
      case Aquatic.betta:
        return FishSpecies.bettaSplendens;
      case Aquatic.blueTang:
        return FishSpecies.blueTang;
      case Aquatic.neonTetra:
        return FishSpecies.neonTetra;
      case Aquatic.discus:
        return FishSpecies.discusFish;
      case Aquatic.angel:
        return FishSpecies.angelFish;
      case Aquatic.clownfish:
        return FishSpecies.clownfish;
      case Aquatic.guppy:
        return FishSpecies.fancyGuppy;
      default:
        return null;
    }
  }

  /// Maps the unified species type to its internal [CreatureType] model.
  CreatureType? get creatureType {
    switch (this) {
      case Aquatic.jellyfish:
        return CreatureType.jellyfish;
      case Aquatic.turtle:
        return CreatureType.seaTurtle;
      case Aquatic.manta:
        return CreatureType.mantaRay;
      case Aquatic.seahorse:
        return CreatureType.seahorse;
      case Aquatic.starfish:
        return CreatureType.starfish;
      case Aquatic.crab:
        return CreatureType.hermitCrab;
      default:
        return null;
    }
  }
}
