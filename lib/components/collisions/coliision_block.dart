import 'package:flame/components.dart';

class CollisionBlock extends PositionComponent {
  CollisionBlock({
    super.position,
    super.size,
    this.isPlatform = false,
  }) {
    debugMode = true;
  }

  bool isPlatform;
}
