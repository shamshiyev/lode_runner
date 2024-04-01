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

enum PlayerDirection {
  left,
  right,
  none,
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

  // Направление передвижения игрока
  PlayerDirection playerDirection = PlayerDirection.none;

  double moveSpeed = 100;
  Vector2 velocity = Vector2.zero();
  final double stepTime = 0.05;

  bool isFacingRight = true;

  @override
  Future<void> onLoad() async {
    _loadAllAnimations();
    return super.onLoad();
  }

  @override
  bool onKeyEvent(
    RawKeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    // final leftKeyPressed = keysPressed.contains(
    //       LogicalKeyboardKey.arrowLeft,
    //     ) ||
    //     keysPressed.contains(
    //       LogicalKeyboardKey.keyA,
    //     );
    // final rightKeyPressed = keysPressed.contains(
    //       LogicalKeyboardKey.arrowRight,
    //     ) ||
    //     keysPressed.contains(
    //       LogicalKeyboardKey.keyD,
    //     );
    // if (leftKeyPressed && rightKeyPressed) {
    //   playerDirection = PlayerDirection.none;
    // } else if (leftKeyPressed) {
    //   playerDirection = PlayerDirection.left;
    // } else if (rightKeyPressed) {
    //   playerDirection = PlayerDirection.right;
    // } else {
    //   playerDirection = PlayerDirection.none;
    // }
    // return super.onKeyEvent(event, keysPressed);
    if (event is RawKeyDownEvent) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.arrowLeft || LogicalKeyboardKey.keyA:
          playerDirection = PlayerDirection.left;
          break;
        case LogicalKeyboardKey.arrowRight || LogicalKeyboardKey.keyD:
          playerDirection = PlayerDirection.right;
          break;
        // case LogicalKeyboardKey.space:
        //   if (current == PlayerState.jump) {
        //     current = PlayerState.doubleJump;
        //   } else {
        //     current = PlayerState.jump;
        //   }
        //   break;
        default:
          break;
      }
    }
    // Остановка движения при отпускании клавиши
    else if (event is RawKeyUpEvent) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.arrowLeft || LogicalKeyboardKey.keyA:
        case LogicalKeyboardKey.arrowRight || LogicalKeyboardKey.keyD:
          playerDirection = PlayerDirection.none;
          break;
        default:
          break;
      }
    }
    return true;
  }

  @override
  void update(double dt) {
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

  void _updatePlayerDirection(double dt) {
    double dirX = 0.0;
    switch (playerDirection) {
      // Перемещение игрока влево
      case PlayerDirection.left:
        if (isFacingRight) {
          flipHorizontallyAroundCenter();
          isFacingRight = false;
        }
        current = PlayerState.run;
        dirX -= moveSpeed;
        break;

      // Перемещение игрока вправо
      case PlayerDirection.right:
        if (!isFacingRight) {
          flipHorizontallyAroundCenter();
          isFacingRight = true;
        }
        current = PlayerState.run;

        dirX += moveSpeed;
        break;

      // Остановка игрока
      case PlayerDirection.none:
        current = PlayerState.idle;
        break;
    }
    velocity = Vector2(dirX, velocity.y);
    position += velocity * dt;
  }
}
