import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/services.dart';
import 'package:lode_runner/utilities/hitbox.dart';
import 'package:lode_runner/components/checkpoint.dart';
import 'package:lode_runner/components/collectable.dart';
import 'package:lode_runner/components/traps/saw.dart';
import 'package:lode_runner/utilities/animations.dart';
import 'package:lode_runner/utilities/collisions.dart';
import 'package:lode_runner/lode_runner.dart';

import '../../traps/spike.dart';
import '../enemy.dart';

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

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<LodeRunner>, KeyboardHandler, CollisionCallbacks {
  Player({
    super.position,
  });

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

  // Гравитация
  static const gravity = 9.8;
  // Сила прыжка
  static const double jumpForce = 260;
  // Предельная скорость падения
  static const double terminalVelocity = 300;
  double horizontalSpeed = 0;
  static const double moveSpeed = 100;
  // Стартовая позиция игрока
  Vector2 startingPosition = Vector2.zero();
  Vector2 velocity = Vector2.zero();
  // Скорость скольжения по стене
  static const double wallSlideSpeed = 50;

  bool isOnGround = true;
  bool hasJumped = false;
  bool isSliding = false;
  bool hasDoubleJumped = false;
  bool gotHit = false;
  bool reachedCheckpoint = false;

  List<CollisionBlock> collisionBlocks = [];
  // Хитбокс игрока
  CustomHitbox hitbox = CustomHitbox(
    offsetX: 10,
    offsetY: 4,
    width: 14,
    height: 28,
  );

  double fixedDeltaTime = 1 / 60;
  double accumulatedTime = 0;

  @override
  Future<void> onLoad() async {
    _loadAllAnimations();
    // debugMode = true;
    startingPosition = Vector2(position.x, position.y);
    // Отображение хитбокса
    add(
      RectangleHitbox(
        position: Vector2(
          hitbox.offsetX,
          hitbox.offsetY,
        ),
        size: Vector2(
          hitbox.width,
          hitbox.height,
        ),
      ),
    );
    return super.onLoad();
  }

  // TODO: Create a VModel for all keyboard events?
  @override
  bool onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    // log(bloc.state.player.toString());
    // Описываем инпуты для передвижения и остановки по горизонтали
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
    // Остановка при отпускании клавиш движения
    if (event is KeyUpEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
          event.logicalKey == LogicalKeyboardKey.arrowRight ||
          event.logicalKey == LogicalKeyboardKey.keyA ||
          event.logicalKey == LogicalKeyboardKey.keyD) {
        horizontalSpeed = 0;
      }
    }
    // Прыжок
    hasJumped = keysPressed.contains(LogicalKeyboardKey.space);

    return false;
  }

  // Коллизия с подбираемыми объектами
  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (!reachedCheckpoint) {
      if (other is Collectable) {
        other.collidingWithPlayer();
      }
      if (other is Saw || other is Spike) {
        // TODO: Add a slight kickback when player collides with a saw
        _respawn();
      }
      if (other is Checkpoint) {
        _reachedCheckPoint();
      }
      if (other is Enemy) {
        other.collidedWithPlayer();
      }
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  @override
  void update(double dt) {
    // TODO: Refactor this to use a stream
    accumulatedTime += dt;
    while (accumulatedTime >= fixedDeltaTime) {
      if (!gotHit && !reachedCheckpoint) {
        _upDatePlayerMovement();
        _updatePlayerDirection(fixedDeltaTime);
        _checkHorizontalCollisions();
        _applyGravity(fixedDeltaTime);
        _checkVerticalCollisions();
      }
      accumulatedTime -= fixedDeltaTime;
    }

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
    )..loop = false;
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

  void _upDatePlayerMovement() {
    PlayerAnimationState playerState = PlayerAnimationState.idle;

    // Поворот персонажа осуществляется за счёт прослушивания параметра scale
    if (velocity.x < 0 && scale.x > 0) {
      flipHorizontallyAroundCenter();
    } else if (velocity.x > 0 && scale.x < 0) {
      flipHorizontallyAroundCenter();
    }
    // Изменение анимаций при прыжке
    if (velocity.y < 0) {
      if (hasDoubleJumped) {
        playerState = PlayerAnimationState.doubleJump;
      } else {
        playerState = PlayerAnimationState.jump;
      }
    } else if (velocity.y > 0) {
      playerState = PlayerAnimationState.fall;
    } else if (velocity.x != 0) {
      playerState = PlayerAnimationState.run;
    }
    if (isSliding) {
      playerState = PlayerAnimationState.wallJump;
    }
    current = playerState;
  }

  void _updatePlayerDirection(double dt) {
    if (hasJumped && (isOnGround || !hasDoubleJumped)) {
      if (!isOnGround) {
        hasDoubleJumped = true;
      }
      _playerJump(dt);
    } else if (isOnGround) {
      hasDoubleJumped = false;
    }
    if (isSliding && velocity.y > 0) {
      hasJumped = false;
      hasDoubleJumped = false;
      velocity.y = min(velocity.y, wallSlideSpeed);
    }

    velocity.x = horizontalSpeed * moveSpeed;
    position.x += velocity.x * dt;
  }

  // Изменение позиции и скорости по оси Y при прыжке
  void _playerJump(double dt) {
    if (game.playSounds) {
      FlameAudio.play(
        'jump.wav',
        volume: game.soundVolume,
      );
    }
    velocity.y = -jumpForce;
    position.y += velocity.y * dt;
    isOnGround = false;
    hasJumped = false;
  }

  void _checkHorizontalCollisions() {
    isSliding = false;
    for (final block in collisionBlocks) {
      if (!block.isPlatform) {
        if (checkCollisions(this, block)) {
          if (velocity.y > 0) {
            isSliding = true;
          }
          // Коллизия и остановка при движении вправо
          if (velocity.x > 0) {
            velocity.x = 0;
            position.x = block.x - hitbox.offsetX - hitbox.width;
            break;
          }
          // Коллизия и остановка при движении влево
          if (velocity.x < 0) {
            velocity.x = 0;
            position.x = block.x + block.width + hitbox.width + hitbox.offsetX;
            break;
          }
        }
      }
    }
  }

  void _applyGravity(double dt) {
    velocity.y += gravity;
    // Ограничение скорости падения и прыжка
    velocity.y = velocity.y.clamp(
      -jumpForce,
      terminalVelocity,
    );
    position.y += velocity.y * dt;
  }

  void _checkVerticalCollisions() {
    for (final block in collisionBlocks) {
      if (block.isPlatform) {
        if (checkCollisions(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitbox.height - hitbox.offsetY;
            isOnGround = true;
            break;
          }
        }
      } else {
        if (checkCollisions(this, block)) {
          // Вычисляем коллизию при падении
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitbox.height - hitbox.offsetY;
            // При коллизии по вертикали сверху вниз мы понимаем, что "на земле"
            isOnGround = true;
            break;
          }
          // Вычисляем коллизию при прыжке
          if (velocity.y < 0) {
            // FIXME: Problem with the player's hitbox if the collision block is right above the player

            velocity.y = 0;
            position.y = block.y + block.height - hitbox.offsetY;
            break;
          }
        }
      }
    }
  }

  void _respawn() async {
    if (game.playSounds) {
      FlameAudio.play('hit.wav', volume: game.soundVolume);
    }
    const canMoveDuration = Duration(milliseconds: 400);
    gotHit = true;
    current = PlayerAnimationState.hit;
    // Дожидаемся завершения анимаций
    await animationTicker?.completed;
    animationTicker?.reset();
    //
    scale.x = 1;
    position = startingPosition;
    current = PlayerAnimationState.appearing;
    //
    await animationTicker?.completed;
    animationTicker?.reset();
    //
    velocity = Vector2.zero();
    position = startingPosition;
    _upDatePlayerMovement();
    Future.delayed(canMoveDuration, () => gotHit = false);
  }

  void _reachedCheckPoint() async {
    reachedCheckpoint = true;
    if (game.playSounds) {
      FlameAudio.play('disappear.wav', volume: game.soundVolume);
    }

    current = PlayerAnimationState.disappearing;
    //
    await animationTicker?.completed;
    animationTicker?.reset();
    //
    reachedCheckpoint = false;
    removeFromParent();
    Future.delayed(const Duration(seconds: 3), () => game.nextLevel());
  }

  void collidedWithEnemy() async {
    _respawn();
  }
}
