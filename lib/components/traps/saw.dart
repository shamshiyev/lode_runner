import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:lode_runner/lode_runner.dart';

class Saw extends SpriteAnimationComponent with HasGameRef<LodeRunner> {
  Saw({
    super.position,
    super.size,
    this.isVertical = false,
    this.offNeg = 0,
    this.offPos = 0,
  });

  static const moveSpeed = 80;
  static const double stepTime = 0.02;
  static const tileSize = 16;

  final bool isVertical;
  final double offNeg;
  final double offPos;

  double moveDirection = 1;
  double rangeNeg = 0;
  double rangePos = 0;

  @override
  Future<void> onLoad() async {
    priority = -1;
    // debugMode = true;
    add(
      CircleHitbox(),
    );
    // Движение по вертикали
    if (isVertical) {
      rangeNeg = position.y - offNeg * tileSize;
      rangePos = position.y + offPos * tileSize;
    }
    // Движение по горизонтали
    else {
      rangeNeg = position.x - offNeg * tileSize;
      rangePos = position.x + offPos * tileSize;
    }
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('Traps/Saw/On (38x38).png'),
      SpriteAnimationData.sequenced(
        amount: 8,
        textureSize: Vector2(38, 38),
        stepTime: stepTime,
      ),
    );
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (isVertical) {
      _moveVertical(dt);
    } else {
      _moveHorizontal(dt);
    }
    super.update(dt);
  }

  void _moveVertical(double dt) {
    // При превышении ограничений rangePos или rangeNeg меняем направление движения
    if (position.y >= rangePos) {
      moveDirection = -1;
    } else if (position.y <= rangeNeg) {
      moveDirection = 1;
    }
    position.y += moveDirection * moveSpeed * dt;
  }

  void _moveHorizontal(double dt) {
    // При превышении ограничений rangePos или rangeNeg меняем направление движения
    if (position.x >= rangePos) {
      moveDirection = -1;
    } else if (position.x <= rangeNeg) {
      moveDirection = 1;
    }
    position.x += moveDirection * moveSpeed * dt;
  }
}
