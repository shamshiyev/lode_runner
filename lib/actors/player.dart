import 'dart:developer';

import 'package:flame/components.dart';
import 'package:lode_runner/helpers/animations.dart';
import 'package:lode_runner/lode_runner.dart';

enum PlayerState {
  idle,
  run,
  jump,
  fall,
  hit,
  doubleJump,
  wallJump,
}

class Player extends SpriteAnimationGroupComponent with HasGameRef<LodeRunner> {
  late final SpriteAnimation idle;
  late final SpriteAnimation run;
  late final SpriteAnimation jump;
  late final SpriteAnimation fall;
  late final SpriteAnimation hit;
  late final SpriteAnimation doubleJump;
  late final SpriteAnimation wallJump;

  final double stepTime = 0.05;

  @override
  Future<void> onLoad() async {
    _loadAllAnimations();
    log(position.toString());
    return super.onLoad();
  }

  void _loadAllAnimations() {
    // Позиция игрока
    idle = SpriteAnimation.fromFrameData(
      game.images.fromCache(
        PlayerAnimations.idle,
      ),
      SpriteAnimationData.sequenced(
        amount: 11,
        stepTime: stepTime,
        textureSize: Vector2.all(32),
      ),
    );
    run = SpriteAnimation.fromFrameData(
      game.images.fromCache(
        PlayerAnimations.run,
      ),
      SpriteAnimationData.sequenced(
        amount: 12,
        stepTime: stepTime,
        textureSize: Vector2.all(32),
      ),
    );
    jump = SpriteAnimation.fromFrameData(
      game.images.fromCache(
        PlayerAnimations.jump,
      ),
      SpriteAnimationData.sequenced(
        amount: 1,
        stepTime: stepTime,
        textureSize: Vector2.all(32),
      ),
    );
    fall = SpriteAnimation.fromFrameData(
      game.images.fromCache(
        PlayerAnimations.fall,
      ),
      SpriteAnimationData.sequenced(
        amount: 1,
        stepTime: stepTime,
        textureSize: Vector2.all(32),
      ),
    );
    hit = SpriteAnimation.fromFrameData(
      game.images.fromCache(
        PlayerAnimations.hit,
      ),
      SpriteAnimationData.sequenced(
        amount: 7,
        stepTime: stepTime,
        textureSize: Vector2.all(32),
      ),
    );
    doubleJump = SpriteAnimation.fromFrameData(
      game.images.fromCache(
        PlayerAnimations.doubleJump,
      ),
      SpriteAnimationData.sequenced(
        amount: 6,
        stepTime: stepTime,
        textureSize: Vector2.all(32),
      ),
    );
    wallJump = SpriteAnimation.fromFrameData(
      game.images.fromCache(
        PlayerAnimations.wallJump,
      ),
      SpriteAnimationData.sequenced(
        amount: 5,
        stepTime: stepTime,
        textureSize: Vector2.all(32),
      ),
    );

    animations = <PlayerState, SpriteAnimation>{
      PlayerState.idle: idle,
      PlayerState.run: run,
      PlayerState.jump: jump,
      PlayerState.fall: fall,
      PlayerState.hit: hit,
      PlayerState.doubleJump: doubleJump,
      PlayerState.wallJump: wallJump,
    };

    // Текущее значение анимации
    current = idle;
  }
}
