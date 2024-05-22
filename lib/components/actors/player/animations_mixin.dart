import 'package:flame/components.dart';
import '../../../lode_runner.dart';
import '../../../utilities/animations.dart';

enum PlayerAnimationState {
  idle,
  run,
  jump,
  fall,
  hit,
  doubleJump,
  wallJump,
  appearing,
  disappearing,
}

mixin PlayerAnimationsMixin on SpriteAnimationGroupComponent {
// Скорость всех анимаций
  static const double stepTime = 0.05;

  late final SpriteAnimation doubleJump;
  late final SpriteAnimation fall;
  late final SpriteAnimation hit;
  late final SpriteAnimation idle;
  late final SpriteAnimation jump;
  late final SpriteAnimation run;
  late final SpriteAnimation wallJump;
  late final SpriteAnimation appearing;
  late final SpriteAnimation disappearing;

  void loadAllAnimations(
    LodeRunner gameRef,
  ) {
    // Базовый метод
    SpriteAnimation spriteAnimation({
      required String src,
      required int frameAmount,
    }) {
      return SpriteAnimation.fromFrameData(
        gameRef.images.fromCache(
          src,
        ),
        SpriteAnimationData.sequenced(
          amount: frameAmount,
          stepTime: stepTime,
          textureSize: Vector2.all(32),
        ),
      );
    }

    // Значения анимаций
    idle = spriteAnimation(
      src: ActorAnimations.idle,
      frameAmount: 11,
    );
    run = spriteAnimation(
      src: ActorAnimations.run,
      frameAmount: 12,
    );
    jump = spriteAnimation(
      src: ActorAnimations.jump,
      frameAmount: 1,
    );
    fall = spriteAnimation(
      src: ActorAnimations.fall,
      frameAmount: 1,
    );
    hit = spriteAnimation(
      src: ActorAnimations.hit,
      frameAmount: 7,
    )..loop = false;
    doubleJump = spriteAnimation(
      src: ActorAnimations.doubleJump,
      frameAmount: 6,
    );
    wallJump = spriteAnimation(
      src: ActorAnimations.wallJump,
      frameAmount: 5,
    );
    appearing = spriteAnimation(
      src: ActorAnimations.appearing,
      frameAmount: 7,
    );
    disappearing = spriteAnimation(
      src: ActorAnimations.disappearing,
      frameAmount: 7,
    )..loop = false;

    // Текущее значение анимации
    current = PlayerAnimationState.idle;

    // Список анимаций
    animations = <PlayerAnimationState, SpriteAnimation>{
      PlayerAnimationState.idle: idle,
      PlayerAnimationState.run: run,
      PlayerAnimationState.jump: jump,
      PlayerAnimationState.fall: fall,
      PlayerAnimationState.hit: hit,
      PlayerAnimationState.doubleJump: doubleJump,
      PlayerAnimationState.wallJump: wallJump,
      PlayerAnimationState.appearing: appearing,
      PlayerAnimationState.disappearing: disappearing,
    };
  }
}
