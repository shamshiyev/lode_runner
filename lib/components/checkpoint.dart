import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:lode_runner/components/actors/player/player.dart';
import 'package:lode_runner/lode_runner.dart';

class Checkpoint extends SpriteAnimationComponent
    with HasGameRef<LodeRunner>, CollisionCallbacks {
  Checkpoint({
    required super.position,
    required super.size,
  });

  @override
  Future<void> onLoad() async {
    add(
      RectangleHitbox(
        position: Vector2(18, 56),
        size: Vector2(12, 8),
        collisionType: CollisionType.passive,
      ),
    );
    animation = SpriteAnimation.fromFrameData(
      game.images
          .fromCache('Items/Checkpoints/Checkpoint/Checkpoint (No Flag).png'),
      SpriteAnimationData.sequenced(
        amount: 1,
        stepTime: 1,
        textureSize: Vector2.all(64),
      ),
    );
    return super.onLoad();
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    if (other is Player) {
      _reachedCheckPoint();
      super.onCollision(intersectionPoints, other);
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  void _reachedCheckPoint() async {
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache(
          'Items/Checkpoints/Checkpoint/Checkpoint (Flag Out) (64x64).png'),
      SpriteAnimationData.sequenced(
        amount: 26,
        stepTime: 0.05,
        textureSize: Vector2.all(64),
        loop: false,
      ),
    );
    await animationTicker?.completed;
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache(
          'Items/Checkpoints/Checkpoint/Checkpoint (Flag Idle)(64x64).png'),
      SpriteAnimationData.sequenced(
        amount: 10,
        stepTime: 0.05,
        textureSize: Vector2.all(64),
      ),
    );
  }
}
