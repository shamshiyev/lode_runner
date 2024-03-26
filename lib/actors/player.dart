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
  Player({super.position});

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
    return super.onLoad();
  }

  void _loadAllAnimations() {
    // Базовый метод
    SpriteAnimation spriteAnimation(String animationSrc, int frameAmount) {
      return SpriteAnimation.fromFrameData(
        gameRef.images.fromCache(
          animationSrc,
        ),
        SpriteAnimationData.sequenced(
          amount: frameAmount,
          stepTime: stepTime,
          textureSize: Vector2.all(32),
        ),
      );
    }

    // Значения анимаций
    idle = spriteAnimation(PlayerAnimations.idle, 11);
    run = spriteAnimation(PlayerAnimations.run, 12);
    jump = spriteAnimation(PlayerAnimations.jump, 1);
    fall = spriteAnimation(PlayerAnimations.fall, 1);
    hit = spriteAnimation(PlayerAnimations.hit, 7);
    doubleJump = spriteAnimation(PlayerAnimations.doubleJump, 6);
    wallJump = spriteAnimation(PlayerAnimations.wallJump, 5);

    // Текущее значение анимации
    current = PlayerState.run;

    // Список анимаций
    animations = <PlayerState, SpriteAnimation>{
      PlayerState.idle: idle,
      PlayerState.run: run,
      PlayerState.jump: jump,
      PlayerState.fall: fall,
      PlayerState.hit: hit,
      PlayerState.doubleJump: doubleJump,
      PlayerState.wallJump: wallJump,
    };
  }
}
