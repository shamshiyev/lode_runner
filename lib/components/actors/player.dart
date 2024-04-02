import 'package:flame/components.dart';
import 'package:flutter/services.dart';
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

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<LodeRunner>, KeyboardHandler {
  Player({
    super.position,
  });

  late final SpriteAnimation doubleJump;
  late final SpriteAnimation fall;
  late final SpriteAnimation hit;
  late final SpriteAnimation idle;
  late final SpriteAnimation jump;
  late final SpriteAnimation run;
  late final SpriteAnimation wallJump;

  double horizontalSpeed = 0;
  double moveSpeed = 100;
  Vector2 velocity = Vector2.zero();
  final double stepTime = 0.05;

  @override
  Future<void> onLoad() async {
    _loadAllAnimations();
    return super.onLoad();
  }

  // TODO: Create a VModel for all keyboard events?
  @override
  bool onKeyEvent(
    RawKeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    horizontalSpeed = 0;
    final leftKeyPressed = keysPressed.contains(
          LogicalKeyboardKey.arrowLeft,
        ) ||
        keysPressed.contains(
          LogicalKeyboardKey.keyA,
        );
    final rightKeyPressed = keysPressed.contains(
          LogicalKeyboardKey.arrowRight,
        ) ||
        keysPressed.contains(
          LogicalKeyboardKey.keyD,
        );
    horizontalSpeed += leftKeyPressed ? -1 : 0;
    horizontalSpeed += rightKeyPressed ? 1 : 0;
    if (leftKeyPressed && rightKeyPressed) {
      horizontalSpeed = 0;
    }
    if (event is RawKeyUpEvent) {
      horizontalSpeed = 0;
    }

    return true;
  }

  @override
  void update(double dt) {
    _updatePlayerAnimation();
    _updatePlayerDirection(dt);
    super.update(dt);
  }

  void _loadAllAnimations() {
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
      src: PlayerAnimations.idle,
      frameAmount: 11,
    );
    run = spriteAnimation(
      src: PlayerAnimations.run,
      frameAmount: 12,
    );
    jump = spriteAnimation(
      src: PlayerAnimations.jump,
      frameAmount: 1,
    );
    fall = spriteAnimation(
      src: PlayerAnimations.fall,
      frameAmount: 1,
    );
    hit = spriteAnimation(
      src: PlayerAnimations.hit,
      frameAmount: 7,
    );
    doubleJump = spriteAnimation(
      src: PlayerAnimations.doubleJump,
      frameAmount: 6,
    );
    wallJump = spriteAnimation(
      src: PlayerAnimations.wallJump,
      frameAmount: 5,
    );

    // TODO: Maybe transform it into stream with RXDart
    // Текущее значение анимации
    current = PlayerState.idle;

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

  void _updatePlayerAnimation() {
    PlayerState playerState = PlayerState.idle;

    // Поворот персонажа осуществляется за счёт прослушивания параметра scale
    if (velocity.x < 0 && scale.x > 0) {
      flipHorizontallyAroundCenter();
    } else if (velocity.x > 0 && scale.x < 0) {
      flipHorizontallyAroundCenter();
    }
    if (velocity.y < 0) {
      playerState = PlayerState.jump;
    } else if (velocity.y > 0) {
      playerState = PlayerState.fall;
    } else if (velocity.x != 0) {
      playerState = PlayerState.run;
    }
    current = playerState;
  }

  void _updatePlayerDirection(double dt) {
    velocity.x = horizontalSpeed * moveSpeed;
    position.x += velocity.x * dt;
  }
}
