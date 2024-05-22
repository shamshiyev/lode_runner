import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:lode_runner/components/actors/enemies/enemy.dart';
import 'package:lode_runner/utilities/animations.dart';

import '../../player/bloc/player_bloc.dart';

enum PlantAnimationState { shoot, hit, idle }

class Plant extends Enemy {
  Plant({
    required super.position,
    required super.size,
    this.reversed = false,
  });

  final bool reversed;

  @override
  final textureSize = Vector2(44, 42);
  @override
  final double moveSpeed = 140;

  bool gotHit = false;

  late final SpriteAnimation plantIdle;
  late final SpriteAnimation plantHit;
  late final SpriteAnimation plantShoot;

  @override
  FutureOr<void> onLoad() {
    if (reversed) {
      flipHorizontallyAroundCenter();
    }
    player = gameRef.playerBloc.state.player;
    add(
      RectangleHitbox(
        position: Vector2.all(6),
        size: Vector2.all(36),
      ),
    );
    loadAllAnimations();
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (!gotHit) {
      updateAnimation();
    } else {
      removeOffScreen();
    }
    super.update(dt);
  }

  @override
  void collidedWithPlayer() {
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
  void loadAllAnimations() {
    plantIdle = spriteAnimation(ActorAnimations.plantIdle, 11);
    plantHit = spriteAnimation(ActorAnimations.plantHit, 5)..loop = false;
    plantShoot = spriteAnimation(ActorAnimations.plantShoot, 8);
    animations = {
      PlantAnimationState.idle: plantIdle,
      PlantAnimationState.hit: plantHit,
      PlantAnimationState.shoot: plantShoot,
    };
    current = PlantAnimationState.idle;
  }

  @override
  void updateEnemyState(double dt) {
    if (checkRange()) {
      // TODO: Implement shooting
    }
  }

  @override
  void updateAnimation() {
    current =
        checkRange() ? PlantAnimationState.shoot : PlantAnimationState.idle;
  }

  @override
  void removeOffScreen() {
    current = PlantAnimationState.hit;
    angle += 0.04;
    position.y += 6;
    position.x += 2;
    if (position.y > gameRef.size.y + 10) {
      removeFromParent();
    }
  }

  bool checkRange() {
    double range = game.size.x / 3;
    return player.x > position.x - range &&
        player.x < position.x + range &&
        player.y + player.height > position.y &&
        player.y < position.y + height;
  }
}
