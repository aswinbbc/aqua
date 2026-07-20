import 'dart:math';
import 'dart:ui';

class FoodPellet {
  Offset position;
  double radius;
  double opacity;
  bool isEaten;
  double wobblePhase;

  FoodPellet({
    required this.position,
    this.radius = 4.5,
    this.opacity = 1.0,
    this.isEaten = false,
    this.wobblePhase = 0.0,
  });

  void update(double dt) {
    if (isEaten) return;
    wobblePhase += dt * 3.0;
    // Gently float down slightly and sway side to side
    position += Offset(
      sin(wobblePhase) * 0.3,
      0.15,
    );
  }
}
