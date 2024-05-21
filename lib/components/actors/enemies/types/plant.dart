import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:lode_runner/components/actors/enemies/enemy.dart';
import 'package:lode_runner/utilities/animations.dart';

enum PlantAnimationState { shoot, hit, idle }

class Plant extends Enemy {
  Plant({required super.position, required super.size});
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
    debugMode = true;
    debugColor = Color(0xFFFF0000).withOpacity(0.0);
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
  void collidedWithPlayer() {
    // TODO: implement collidedWithPlayer
  }

  @override
  void loadAllAnimations() {
    plantIdle = spriteAnimation(
      ActorAnimations.plantIdle,
      11,
    );
    plantHit = spriteAnimation(ActorAnimations.plantHit, 5);
    plantShoot = spriteAnimation(ActorAnimations.plantShoot, 8);

    animations = {
      PlantAnimationState.idle: plantIdle,
      PlantAnimationState.hit: plantHit,
      PlantAnimationState.shoot: plantShoot,
    };
    current = PlantAnimationState.idle;
  }

  @override
  void move(double dt) {
    // TODO: implement move
  }

  @override
  void removeOffScreen() {
    // TODO: implement removeOffScreen
  }

  @override
  void updateAnimation() {
    // TODO: implement updateAnimation
  }
}
