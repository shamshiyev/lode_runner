import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:lode_runner/components/actors/enemies/enemy.dart';
import 'package:lode_runner/components/actors/enemies/types/bullet.dart';
import 'package:lode_runner/utilities/animations.dart';

import '../../player/bloc/player_bloc.dart';

enum PlantAnimationState {
  shoot,
  hit,
  idle,
}

class Plant extends Enemy {
  Plant({
    required super.position,
    required super.size,
    this.reversed = false,
  });

  late final Sprite bulletSprite;
  bool gotHit = false;
  late final SpriteAnimation plantHit;
  late final SpriteAnimation plantIdle;
  late final SpriteAnimation plantShoot;
  final bool reversed;

  @override
  final double moveSpeed = 180;

  @override
  double get stepTime => 0.08;

  @override
  final textureSize = Vector2(44, 42);

  @override
  void collidedWithPlayer() {
    if (player.velocity.y > 0 && player.y + player.height > position.y) {
      if (game.playSounds) {
        FlameAudio.play(
          'bounce.wav',
          volume: game.soundVolume,
        );
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
  FutureOr<void> onLoad() async {
    bulletSprite = await Sprite.load('Enemies/Plant/Bullet.png');
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
  void removeOffScreen() {
    angle += 0.04;
    position.y += 6;
    position.x = reversed ? position.x - 1 : position.x + 1;
    if (position.y > gameRef.size.y + 10) {
      removeFromParent();
    }
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
  void updateAnimation() async {
    if (gotHit) {
      current = PlantAnimationState.hit;
      return;
    } else {
      current =
          checkRange() ? PlantAnimationState.shoot : PlantAnimationState.idle;
    }
  }

  @override
  void updateEnemyState(double dt) {
    if (checkRange()) {
      animationTicker!.onFrame = (spriteIndex) {
        if (spriteIndex == 3) {
          if (game.playSounds) {
            FlameAudio.play(
              'shoot.wav',
              volume: game.soundVolume,
            );
          }
          parent?.add(
            Bullet(
              speed: moveSpeed,
              bulletSprite: bulletSprite,
              position: Vector2(
                reversed ? position.x - 20 : position.x + 5,
                position.y + 10,
              ),
              directionRight: reversed,
              playerBloc: player.bloc,
            ),
          );
        }
      };
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
