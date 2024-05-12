import 'dart:ui';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:lode_runner/components/actors/player/bloc/player_bloc.dart';
import 'package:lode_runner/components/actors/player/player.dart';

import '../../utilities/animations.dart';
import '../../lode_runner.dart';

enum EnemyState { idle, run, hit, aware }

class Enemy extends SpriteAnimationGroupComponent
    with
        HasGameRef<LodeRunner>,
        CollisionCallbacks,
        FlameBlocListenable<PlayerBloc, StatePlayerBloc> {
  Enemy({
    super.position,
    super.size,
    this.offNeg = 0,
    this.offPos = 0,
  });
  final double offNeg;
  final double offPos;

  static const double stepTime = 0.05;
  final textureSize = Vector2(32, 32);
  static const double tileSize = 16;
  static const double speed = 180;

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
    _loadAllAnimations();
    _calculateRange();
    await super.onLoad();
  }

  @override
  void update(double dt) {
    if (!gotHit) {
      _updateAnimation();
      _movement(dt);
    }
    super.update(dt);
  }

  void _loadAllAnimations() {
    enemyIdle = _spriteAnimation(ActorAnimations.idleEnemy, 11);
    enemyRun = _spriteAnimation(ActorAnimations.runEnemy, 12);
    enemyHit = _spriteAnimation(ActorAnimations.hitEnemy, 7)..loop = false;
    enemyAware = _spriteAnimation(ActorAnimations.awareEnemy, 5)..loop = false;

    animations = {
      EnemyState.idle: enemyIdle,
      EnemyState.run: enemyRun,
      EnemyState.hit: enemyHit,
      EnemyState.aware: enemyAware,
    };

    current = EnemyState.idle;
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

  void _calculateRange() {
    rangeNeg = position.x - offNeg * tileSize;
    rangePos = position.x + offPos * tileSize;
  }

  void _movement(double dt) {
    velocity.x = 0;
    double playerOffset = (player.scale.x > 0) ? 0 : -player.width;
    double enemyOffset = (scale.x > 0) ? 0 : -width;
    final playerInRange = checkRange();
    if (playerInRange) {
      targetDirection =
          (player.x + playerOffset > position.x + enemyOffset) ? 1 : -1;
      velocity.x = targetDirection * speed;
    }
    moveDirection = lerpDouble(moveDirection, targetDirection, 0.1) ?? 1;
    position.x += velocity.x * dt;
  }

  bool checkRange() {
    // Проверяем, находится ли игрок в поле зрения врага
    double playerOffset = (player.scale.x > 0) ? 0 : -player.width;

    return player.x + playerOffset >= rangeNeg &&
        player.x + playerOffset <= rangePos &&
        player.y + player.height > position.y &&
        player.y < position.y + height;
  }

  void _updateAnimation() {
    current = (velocity.x == 0) ? EnemyState.idle : EnemyState.run;
    if (moveDirection > 0 && scale.x < 0 || moveDirection < 0 && scale.x > 0) {
      flipHorizontallyAroundCenter();
    }
  }

  void collidedWithPlayer() async {
    // Make sure the player is jumping on top of the enemy
    if (player.velocity.y > 0 && player.y + player.height > position.y) {
      if (game.playSounds) {
        FlameAudio.play('bounce.wav', volume: game.soundVolume);
      }
      gotHit = true;
      current = EnemyState.hit;
      player.velocity = Vector2(0, -260);
      await animationTicker?.completed;
      removeFromParent();
    } else {
      player.collidedWithEnemy();
    }
  }
}
