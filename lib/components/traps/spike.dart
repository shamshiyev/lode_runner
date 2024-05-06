import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class Spike extends SpriteComponent {
  Spike({
    super.position,
    super.size,
    this.direction,
  });

  final String? direction;

  @override
  Future<void> onLoad() async {
    priority = -10;
    add(RectangleHitbox(
      size: Vector2.all(16),
      position: Vector2(0, 8),
    ));
    sprite = await Sprite.load('Traps/Spikes/Idle.png');
    if (direction == 'down') {
      y += 16;
      x += 16;
      angle = 3.14;
    } else if (direction == 'left') {
      y += 16;
      angle = -1.57;
    } else if (direction == 'right') {
      x += 16;
      angle = 1.57;
    }
    return super.onLoad();
  }
}
