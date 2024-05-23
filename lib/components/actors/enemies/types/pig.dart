import 'dart:ui';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:lode_runner/components/actors/enemies/enemy.dart';
import 'package:lode_runner/components/actors/player/bloc/player_bloc.dart';
import 'package:lode_runner/helpers/constants.dart';

import '../../../../utilities/animations.dart';

enum PigAnimationState { walk, run, hit, aware, idle }

// Will be replaced with some specific type of enemy
class Pig extends Enemy {
  Pig({
    super.position,
    super.size,
    super.offNeg,
    super.offPos,
  });
  @override
  final textureSize = Vector2(36, 30);
  @override
  final double stepTime = 0.05;

  @override
  double moveSpeed = 30;

  Vector2 velocity = Vector2.zero();
  late double rangeNeg;
  late double rangePos;

  double moveDirection = 1;
  double targetDirection = -1;

  bool gotHit = false;

  late final SpriteAnimation pigIdle;
  late final SpriteAnimation pigRun;
  late final SpriteAnimation pigHit;
  late final SpriteAnimation pigWalk;

  @override
  void onLoad() async {
    // debugMode = true;
    player = gameRef.playerBloc.state.player;
    add(
      RectangleHitbox(
        position: Vector2.all(4),
        size: Vector2(24, 28),
      ),
    );
    loadAllAnimations();
    rangeNeg = position.x - offNeg! * 16;
    rangePos = position.x + offPos! * 16;
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
    pigIdle = spriteAnimation(ActorAnimations.pigIdle, 9);
    pigRun = spriteAnimation(ActorAnimations.pigRun, 12);
    pigWalk = spriteAnimation(ActorAnimations.pigWalk, 16);
    pigHit = spriteAnimation(ActorAnimations.pigHit, 5)..loop = false;

    animations = {
      PigAnimationState.idle: pigIdle,
      PigAnimationState.walk: pigWalk,
      PigAnimationState.run: pigRun,
      PigAnimationState.hit: pigHit,
      PigAnimationState.aware: pigWalk,
    };

    current = PigAnimationState.walk;
  }

  @override
  void updateAnimation() {
    if (gotHit) {
      current = PigAnimationState.hit;
    } else if (velocity.x == 0) {
      current = PigAnimationState.idle;
    } else {
      current = checkRange() ? PigAnimationState.run : PigAnimationState.walk;
    }
    if (moveDirection < 0 && scale.x < 0 || moveDirection > 0 && scale.x > 0) {
      flipHorizontallyAroundCenter();
    }
  }

  @override
  void updateEnemyState(double dt) {
    // Шобы гулял туда-сюда
    if (position.x < rangeNeg) {
      targetDirection = 1;
    } else if (position.x > rangePos) {
      targetDirection = -1;
    }

    double playerOffset =
        (player.scale.x > 0) ? player.hitbox.width : -player.hitbox.width;
    double enemyOffset = (scale.x > 0) ? 0 : -width;

    if (checkRange()) {
      targetDirection =
          (player.x + playerOffset > position.x + enemyOffset) ? 1 : -1;
      moveSpeed = Constants.moveSpeed;
    } else {
      moveSpeed = 30;
    }
    velocity.x = targetDirection * moveSpeed;
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
      player.velocity = Vector2(0, -260);
    } else {
      if (!gotHit) {
        player.bloc.add(const PlayerHitEvent());
      }
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

  // Проверяем, находится ли игрок в поле зрения врага
  bool checkRange() {
    final playerX = player.position.x + player.hitbox.offsetX;
    final fixedX = player.scale.x < 0
        ? playerX - (player.hitbox.width / 2) - player.width
        : playerX + player.hitbox.width;
    return fixedX >= rangeNeg &&
        fixedX <= rangePos &&
        player.y + player.height > position.y &&
        player.y < position.y + height;
  }
}
