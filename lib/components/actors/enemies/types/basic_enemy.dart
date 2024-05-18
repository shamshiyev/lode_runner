import 'dart:ui';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:lode_runner/components/actors/enemies/enemy.dart';
import 'package:lode_runner/components/actors/player/player.dart';

import '../../../../utilities/animations.dart';

enum EnemyAnimationState { idle, run, hit, aware }

// Will be replaced with some specific type of enemy
class BasicEnemy extends Enemy {
  BasicEnemy({
    super.position,
    super.size,
    super.offNeg,
    super.offPos,
  });

  final textureSize = Vector2(32, 32);

  @override
  final double moveSpeed = 180;

  Vector2 velocity = Vector2.zero();
  double rangeNeg = 0;
  double rangePos = 0;

  double moveDirection = 1;
  double targetDirection = -1;

  bool gotHit = false;

  late final Player player;
  late final SpriteAnimation enemyIdle;
  late final SpriteAnimation enemyRun;
  late final SpriteAnimation enemyHit;
  late final SpriteAnimation enemyAware;

  @override
  Future<void> onLoad() async {
    player = gameRef.playerBloc.state.player;
    add(
      RectangleHitbox(
        position: Vector2.all(4),
        size: Vector2(24, 28),
      ),
    );
    loadAllAnimations();
    _calculateRange();
    await super.onLoad();
  }

  @override
  void update(double dt) {
    if (!gotHit) {
      updateAnimation();
      move(dt);
    }
    super.update(dt);
  }

  @override
  void loadAllAnimations() {
    enemyIdle = _spriteAnimation(ActorAnimations.idleEnemy, 11);
    enemyRun = _spriteAnimation(ActorAnimations.runEnemy, 12);
    enemyHit = _spriteAnimation(ActorAnimations.hitEnemy, 7)..loop = false;
    enemyAware = _spriteAnimation(ActorAnimations.awareEnemy, 5)..loop = false;

    animations = {
      EnemyAnimationState.idle: enemyIdle,
      EnemyAnimationState.run: enemyRun,
      EnemyAnimationState.hit: enemyHit,
      EnemyAnimationState.aware: enemyAware,
    };

    current = EnemyAnimationState.idle;
  }

  @override
  void updateAnimation() {
    current =
        (velocity.x == 0) ? EnemyAnimationState.idle : EnemyAnimationState.run;
    if (moveDirection > 0 && scale.x < 0 || moveDirection < 0 && scale.x > 0) {
      flipHorizontallyAroundCenter();
    }
  }

  @override
  void move(double dt) {
    velocity.x = 0;
    double playerOffset = (player.scale.x > 0) ? 0 : -player.width;
    double enemyOffset = (scale.x > 0) ? 0 : -width;
    final playerInRange = checkRange();
    if (playerInRange) {
      targetDirection =
          (player.x + playerOffset > position.x + enemyOffset) ? 1 : -1;
      velocity.x = targetDirection * moveSpeed;
    }
    moveDirection = lerpDouble(moveDirection, targetDirection, 0.1) ?? 1;
    position.x += velocity.x * dt;
  }

  @override
  void collidedWithPlayer() async {
    if (player.velocity.y > 0 && player.y + player.height > position.y) {
      if (game.playSounds) {
        FlameAudio.play('bounce.wav', volume: game.soundVolume);
      }
      gotHit = true;
      current = EnemyAnimationState.hit;
      player.velocity = Vector2(0, -260);
      await animationTicker?.completed;
      removeFromParent();
    } else {
      player.collidedWithEnemy();
    }
  }

  SpriteAnimation _spriteAnimation(String src, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache(
        src,
      ),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: Enemy.stepTime,
        textureSize: textureSize,
      ),
    );
  }

  void _calculateRange() {
    rangeNeg = position.x - offNeg! * Enemy.tileSize;
    rangePos = position.x + offPos! * Enemy.tileSize;
  }

  bool checkRange() {
    // Проверяем, находится ли игрок в поле зрения врага
    double playerOffset = (player.scale.x > 0) ? 0 : -player.width;

    return player.x + playerOffset >= rangeNeg &&
        player.x + playerOffset <= rangePos &&
        player.y + player.height > position.y &&
        player.y < position.y + height;
  }
}
