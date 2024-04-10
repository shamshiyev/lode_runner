import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:lode_runner/components/actors/hitbox.dart';
import 'package:lode_runner/lode_runner.dart';

class Collectable extends SpriteAnimationComponent with HasGameRef<LodeRunner> {
  final String type;
  Collectable({
    required this.type,
    super.position,
    super.size,
  });

  final hitBox = CustomHitbox(
    offsetX: 10,
    offsetY: 10,
    width: 12,
    height: 12,
  );

  bool _isCollected = false;

  @override
  Future<void> onLoad() async {
    priority = -1;

    add(
      RectangleHitbox(
        position: type == 'Coin'
            ? Vector2.zero()
            : Vector2(
                hitBox.offsetX,
                hitBox.offsetY,
              ),
        size: type == 'Coin'
            ? Vector2.all(16)
            : Vector2(
                hitBox.width,
                hitBox.height,
              ),
        collisionType: CollisionType.passive,
      ),
    );
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('Items/Collectables/$type.png'),
      SpriteAnimationData.sequenced(
        amount: type == 'Coin' ? 6 : 17,
        stepTime: type == 'Coin' ? 0.1 : 0.05,
        textureSize: size,
      ),
    );
    return super.onLoad();
  }

  void collidingWithPlayer() {
    if (!_isCollected) {
      animation = SpriteAnimation.fromFrameData(
        game.images.fromCache('Items/Collectables/Collected.png'),
        SpriteAnimationData.sequenced(
          amount: 6,
          stepTime: 0.1,
          textureSize: Vector2.all(64),
          loop: false,
        ),
      );
      _isCollected = true;
    }
    // Удаление монетки после подбора
    Future.delayed(
      const Duration(milliseconds: 300),
      () {
        removeFromParent();
      },
    );
  }
}
