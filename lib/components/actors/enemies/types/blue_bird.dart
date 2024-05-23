import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:lode_runner/components/actors/enemies/enemy.dart';
import 'package:lode_runner/components/actors/player/bloc/player_bloc.dart';
import 'package:lode_runner/utilities/animations.dart';

enum BirdAnimationState { flying, hit }

class BlueBird extends Enemy {
  BlueBird({
    super.position,
    super.size,
    super.offNeg,
    super.offPos,
  });

  @override
  final double moveSpeed = 50;
  @override
  final textureSize = Vector2(32, 32);

  @override
  final double stepTime = 0.05;

  double moveDirection = 1;
  double rangeNeg = 0;
  double rangePos = 0;

  bool gotHit = false;

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
    loadAllAnimations();
    rangeNeg = position.x - offNeg! * Enemy.tileSize;
    rangePos = position.x + offPos! * Enemy.tileSize;
    return super.onLoad();
  }

  @override
  void update(double dt) {
    updateAnimation();
    if (!gotHit) {
      updateEnemyState(dt);
    } else {
      removeOffScreen();
    }
    super.update(dt);
  }

  @override
  void loadAllAnimations() {
    birdFlying = _spriteAnimation(ActorAnimations.blueBirdFly, 9);
    birdHit = _spriteAnimation(ActorAnimations.blueBirdHit, 5)..loop = false;
    animations = {
      BirdAnimationState.flying: birdFlying,
      BirdAnimationState.hit: birdHit,
    };
    current = BirdAnimationState.flying;
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

  @override
  void updateEnemyState(double dt) {
    if (position.x >= rangePos) {
      moveDirection = -1;
      flipHorizontallyAroundCenter();
    } else if (position.x <= rangeNeg) {
      moveDirection = 1;
      flipHorizontallyAroundCenter();
    }
    position.x += moveDirection * moveSpeed * dt;
  }

  @override
  void collidedWithPlayer() async {
    if (player.velocity.y > 0 && player.y + player.height > position.y) {
      if (game.playSounds) {
        FlameAudio.play('bounce.wav', volume: game.soundVolume);
      }
      gotHit = true;
      player.velocity = Vector2(0, -260);
    } else {
      player.bloc.add(const PlayerHitEvent());
    }
  }

  @override
  void updateAnimation() {
    if (gotHit) {
      current = BirdAnimationState.hit;
    } else {
      current = BirdAnimationState.flying;
    }
  }

  @override
  void removeOffScreen() {
    angle += 0.04;
    position.y += 4;
    position.x -= moveDirection * 2;
    if (position.y > gameRef.size.y + 10) {
      removeFromParent();
    }
  }
}
