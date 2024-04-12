import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:lode_runner/components/actors/hitbox.dart';
import 'package:lode_runner/components/checkpoint.dart';
import 'package:lode_runner/components/collectable.dart';
import 'package:lode_runner/components/traps/saw.dart';
import 'package:lode_runner/helpers/animations.dart';
import 'package:lode_runner/helpers/collisions.dart';
import 'package:lode_runner/lode_runner.dart';

enum PlayerState {
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

  bool isOnGround = false;
  bool hasJumped = false;
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
    RawKeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
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
    if (event is RawKeyUpEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
          event.logicalKey == LogicalKeyboardKey.arrowRight ||
          event.logicalKey == LogicalKeyboardKey.keyA ||
          event.logicalKey == LogicalKeyboardKey.keyD) {
        horizontalSpeed = 0;
      }
    }
    // Прыжок
    hasJumped = keysPressed.contains(LogicalKeyboardKey.space);
    return super.onKeyEvent(event, keysPressed);
  }

  // Коллизия с подбираемыми объектами
  @override
  void onCollision(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    if (!reachedCheckpoint) {
      if (other is Collectable) {
        other.collidingWithPlayer();
      }
      if (other is Saw) {
        // TODO: Add a slight kickback when player collides with a saw
        _respawn();
      }
      if (other is Checkpoint) {
        _reachedCheckPoint();
      }
    }

    super.onCollision(intersectionPoints, other);
  }

  @override
  void update(double dt) {
    if (!gotHit && !reachedCheckpoint) {
      _updatePlayerAnimation();
      _updatePlayerDirection(dt);
      _checkHorizontalCollisions();
      _applyGravity(dt);
      _checkVerticalCollisions();
    }
    super.update(dt);
  }

  void _loadAllAnimations() {
    // Базовый метод
    SpriteAnimation spriteAnimation({
      required String src,
      required int frameAmount,
      double? textureSize,
    }) {
      return SpriteAnimation.fromFrameData(
        gameRef.images.fromCache(
          src,
        ),
        SpriteAnimationData.sequenced(
          amount: frameAmount,
          stepTime: stepTime,
          textureSize: Vector2.all(textureSize ?? 32),
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
    )..loop = false;
    doubleJump = spriteAnimation(
      src: PlayerAnimations.doubleJump,
      frameAmount: 6,
    );
    wallJump = spriteAnimation(
      src: PlayerAnimations.wallJump,
      frameAmount: 5,
    );
    appearing = spriteAnimation(
      src: PlayerAnimations.appearing,
      frameAmount: 7,
      textureSize: 96,
    )..loop = false;
    disappearing = spriteAnimation(
      src: PlayerAnimations.disappearing,
      frameAmount: 7,
      textureSize: 96,
    )..loop = false;

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
      PlayerState.appearing: appearing,
      PlayerState.disappearing: disappearing,
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
    if (hasJumped && isOnGround) {
      _playerJump(dt);
    }

    if (velocity.y > gravity) {
      isOnGround = false;
    }
    velocity.x = horizontalSpeed * moveSpeed;
    position.x += velocity.x * dt;
  }

  // Изменение позиции и скорости по оси Y при прыжке
  void _playerJump(double dt) {
    velocity.y = -jumpForce;
    position.y += velocity.y * dt;
    isOnGround = false;
    hasJumped = false;
  }

  void _checkHorizontalCollisions() {
    for (final block in collisionBlocks) {
      if (!block.isPlatform) {
        if (checkCollisions(this, block)) {
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
            velocity.y = 0;
            position.y = block.y + block.height - hitbox.offsetY;
          }
        }
      }
    }
  }

  void _respawn() {
    const hitDuration = Duration(
      milliseconds: 350,
    );
    gotHit = true;
    current = PlayerState.hit;
    Future.delayed(
      hitDuration,
      () async {
        scale.x = 1;
        position = startingPosition - Vector2.all(32);
        current = PlayerState.appearing;
        await Future.delayed(hitDuration);
        velocity = Vector2.zero();
        position = startingPosition;
        _updatePlayerAnimation();
        gotHit = false;
      },
    );
  }

  void _reachedCheckPoint() {
    reachedCheckpoint = true;
    if (scale.x > 0) {
      position = position - Vector2.all(32);
    } else if (scale.x < 0) {
      position = position + Vector2(32, -32);
    }
    current = PlayerState.disappearing;
    Future.delayed(
      const Duration(milliseconds: 350),
      () async {
        reachedCheckpoint = false;
        removeFromParent();
        await Future.delayed(const Duration(seconds: 3));
        game.nextLevel();
      },
    );
  }
}
