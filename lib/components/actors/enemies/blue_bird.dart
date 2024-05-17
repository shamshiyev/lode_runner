import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:lode_runner/lode_runner.dart';
import 'package:lode_runner/utilities/animations.dart';

import '../player/player.dart';

enum BlueBirdState { flying, hit }

class BlueBird extends SpriteAnimationGroupComponent
    with HasGameRef<LodeRunner>, CollisionCallbacks {
  BlueBird({
    super.position,
    super.size,
    this.offNeg = 0,
    this.offPos = 0,
  });

  static const moveSpeed = 50;
  static const double stepTime = 0.05;
  static const tileSize = 16;
  final textureSize = Vector2(32, 32);

  final double offNeg;
  final double offPos;

  double moveDirection = 1;
  double rangeNeg = 0;
  double rangePos = 0;

  bool gotHit = false;

  late final Player player;
  late final SpriteAnimation birdHit;
  late final SpriteAnimation birdFlying;

  @override
  Future<void> onLoad() async {
    player = gameRef.playerBloc.state.player;
    flipHorizontallyAroundCenter();
    add(
      RectangleHitbox(
        position: Vector2.all(4),
        size: Vector2(24, 28),
      ),
    );
    _loadAllAnimations();

    rangeNeg = position.x - offNeg * tileSize;
    rangePos = position.x + offPos * tileSize;

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (!gotHit) {
      _fly(dt);
    }

    super.update(dt);
  }

  void _loadAllAnimations() {
    birdFlying = _spriteAnimation(ActorAnimations.blueBirdFly, 9);
    birdHit = _spriteAnimation(ActorAnimations.blueBirdHit, 5)..loop = false;

    animations = {
      BlueBirdState.flying: birdFlying,
      BlueBirdState.hit: birdHit,
    };

    current = BlueBirdState.flying;
  }

  SpriteAnimation _spriteAnimation(String src, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache(
        src,
      ),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: textureSize,
      ),
    );
  }

  void _fly(double dt) {
    if (position.x >= rangePos) {
      moveDirection = -1;
      flipHorizontallyAroundCenter();
    } else if (position.x <= rangeNeg) {
      moveDirection = 1;
      flipHorizontallyAroundCenter();
    }
    position.x += moveDirection * moveSpeed * dt;
  }

  void collidedWithPlayer() async {
    if (player.velocity.y > 0 && player.y + player.height > position.y) {
      if (game.playSounds) {
        FlameAudio.play('bounce.wav', volume: game.soundVolume);
      }
      gotHit = true;
      current = BlueBirdState.hit;
      player.velocity = Vector2(0, -260);
      await animationTicker?.completed;
      removeFromParent();
    } else {
      player.collidedWithEnemy();
    }
  }
}
