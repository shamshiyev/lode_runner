import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:lode_runner/utilities/hitbox.dart';
import 'package:lode_runner/lode_runner.dart';

class Collectable extends SpriteAnimationComponent with HasGameRef<LodeRunner> {
  Collectable({
    this.type,
    super.position,
    super.size,
  });

  static int collectableCount = 0;

  bool collected = false;
  final hitBox = CustomHitbox(
    offsetX: 10,
    offsetY: 10,
    width: 12,
    height: 12,
  );

  final String? type;

  @override
  Future<void> onLoad() async {
    collectableCount++;
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

  void collidingWithPlayer() async {
    if (!collected) {
      collected = true;
      if (game.playSounds) {
        FlameAudio.play('pickup.wav', volume: game.soundVolume);
      }
      animation = SpriteAnimation.fromFrameData(
        game.images.fromCache('Items/Collectables/Collected.png'),
        SpriteAnimationData.sequenced(
          amount: 6,
          stepTime: 0.05,
          textureSize: Vector2.all(32),
          loop: false,
        ),
      );
      collectableCount--;
      // Удаление монетки после подбора
      await animationTicker?.completed;
      removeFromParent();
    }
  }
}
