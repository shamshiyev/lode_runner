import 'dart:math';
import 'dart:async';
import 'package:flame_audio/flame_audio.dart';
import 'package:lode_runner/components/actors/enemies/enemy.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:lode_runner/utilities/animations.dart';

import '../../player/bloc/player_bloc.dart';

enum TurtleAnimationState {
  idle1,
  hit,
  spikesIn,
  spikesOut,
  idle2,
}

class Turtle extends Enemy {
  Turtle({
    required super.position,
    required super.size,
  });

  late final SpriteAnimation turtleIdle1;
  late final SpriteAnimation turtleIdle2;
  late final SpriteAnimation turtleHit;
  late final SpriteAnimation turtleSpikesOut;
  late final SpriteAnimation turtleSpikesIn;

  bool gotHit = false;
  Random random = Random();
  double timeAccumulator = 0.0;
  double switchThreshold = 2.0;

  @override
  double get moveSpeed => 0;

  @override
  double get stepTime => 0.1;

  @override
  Vector2 get textureSize => Vector2(44, 26);

  @override
  FutureOr<void> onLoad() {
    player = gameRef.playerBloc.state.player;
    add(
      RectangleHitbox(
        position: Vector2(4, 0),
        size: Vector2(36, 26),
      ),
    );
    loadAllAnimations();
    // rangeNeg = position.x - offNeg! * 16;
    // rangePos = position.x + offPos! * 16;
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
    super.update(dt);
  }

  @override
  void collidedWithPlayer() {
    if (player.velocity.y > 0 &&
        player.y + player.height > position.y &&
        current != TurtleAnimationState.idle1 &&
        current != TurtleAnimationState.spikesOut) {
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
  void loadAllAnimations() {
    turtleIdle1 = spriteAnimation(ActorAnimations.turtleIdle1, 14);
    turtleIdle2 = spriteAnimation(ActorAnimations.turtleIdle2, 14);
    turtleHit = spriteAnimation(ActorAnimations.turtleHit, 5)..loop = false;
    turtleSpikesIn = spriteAnimation(ActorAnimations.turtleSpikesIn, 8)
      ..loop = false;
    turtleSpikesOut = spriteAnimation(ActorAnimations.turtleSpikesOut, 8)
      ..loop = false;

    animations = {
      TurtleAnimationState.idle1: turtleIdle1,
      TurtleAnimationState.idle2: turtleIdle2,
      TurtleAnimationState.hit: turtleHit,
      TurtleAnimationState.spikesIn: turtleSpikesIn,
      TurtleAnimationState.spikesOut: turtleSpikesOut,
    };

    current = TurtleAnimationState.idle2;
  }

  @override
  void removeOffScreen() {
    angle += 0.04;
    position.y += 6;
    position.x += 2;
    if (position.y > gameRef.size.y + 10) {
      removeFromParent();
    }
  }

  @override
  void updateAnimation() async {
    if (current == TurtleAnimationState.spikesOut) {
      await animationTicker?.completed;
      current = TurtleAnimationState.idle1;
    } else if (current == TurtleAnimationState.spikesIn) {
      await animationTicker?.completed;
      current = TurtleAnimationState.idle2;
    }
  }

  @override
  void updateEnemyState(double dt) {
    timeAccumulator += dt;
    if (timeAccumulator >= switchThreshold) {
      final animationStates = [
        TurtleAnimationState.spikesIn,
        TurtleAnimationState.spikesOut,
      ];
      final randomIndex = random.nextInt(animationStates.length);
      final randomAnimationState = animationStates[randomIndex];
      current = randomAnimationState;
      timeAccumulator = 0.0;
    }
  }
}
