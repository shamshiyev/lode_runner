import 'dart:math';
// ignore: unused_import
import 'dart:developer' as dev;
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:flutter/services.dart';
import 'package:lode_runner/components/actors/enemies/enemy.dart';
import 'package:lode_runner/components/actors/player/bloc/player_bloc.dart';
import 'package:lode_runner/helpers/constants.dart';
import 'package:lode_runner/utilities/hitbox.dart';
import 'package:lode_runner/components/checkpoint.dart';
import 'package:lode_runner/components/collectable.dart';
import 'package:lode_runner/components/traps/saw.dart';
import 'package:lode_runner/helpers/collisions.dart';
import 'package:lode_runner/lode_runner.dart';

import '../../traps/spike.dart';
import 'animations_mixin.dart';

class Player extends SpriteAnimationGroupComponent
    with
        HasGameRef<LodeRunner>,
        KeyboardHandler,
        CollisionCallbacks,
        FlameBlocListenable<PlayerBloc, StatePlayerBloc>,
        PlayerAnimationsMixin {
  Player();

  double accumulatedTime = 0;
  List<CollisionBlock> collisionBlocks = [];
  double fixedDeltaTime = 1 / 60;
  bool hasDoubleJumped = false;
  bool hasJumped = false;
  // Хитбокс игрока
  CustomHitbox hitbox = CustomHitbox(
    offsetX: 10,
    offsetY: 4,
    width: 14,
    height: 28,
  );

  double horizontalSpeed = 0;
  bool isOnGround = true;
  bool isSliding = false;
  Vector2 velocity = Vector2.zero();

  // Коллизии с игровыми объектами
  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    if (other is Checkpoint) {
      bloc.add(const PlayerCheckpointEvent());
    }
    if (bloc.state is! PlayerReachedCheckpointState) {
      if (other is Collectable) {
        other.collidingWithPlayer();
      }
      if (other is Saw || other is Spike) {
        bloc.add(const PlayerHitEvent());
      }
      if (other is Enemy) {
        other.collidedWithPlayer();
      }
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  @override
  bool onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    bloc.add(
      PlayerKeyPressedEvent(
        keysPressed: keysPressed,
        keyEvent: event,
      ),
    );
    return false;
  }

  @override
  Future<void> onLoad() async {
    loadAllAnimations(gameRef);
    final bloc = gameRef.playerBloc;
    position = bloc.state.startingPosition;
    // Создание хитбокса
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

  @override
  void onNewState(
    StatePlayerBloc state,
  ) {
    if (state is PlayerReachedCheckpointState) {
      _reachedCheckPoint();
    }
    if (state is PlayerGotHitState) {
      _respawn();
    } else if (state is PlayerKeyPressedState) {
      horizontalSpeed = state.horizontalSpeed;
      hasJumped = state.hasJumped;
    }

    super.onNewState(state);
  }

  @override
  void update(double dt) {
    accumulatedTime += dt;
    while (accumulatedTime >= fixedDeltaTime) {
      if (bloc.state is! PlayerGotHitState &&
          bloc.state is! PlayerReachedCheckpointState) {
        _upDatePlayerAnimation();
        _updatePlayerDirection(fixedDeltaTime);
        _checkCollisionsOnX();
        _applyGravity(fixedDeltaTime);
        _checkCollisionsOnY();
      }
      accumulatedTime -= fixedDeltaTime;
    }
    super.update(dt);
  }

  void _upDatePlayerAnimation() {
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
    if (hasJumped && (isOnGround || (!hasDoubleJumped && velocity.y >= 0))) {
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
      velocity.y = min(velocity.y, Constants.wallSlideSpeed);
    }
    velocity.x = horizontalSpeed * Constants.moveSpeed;
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
    velocity.y = -Constants.jumpForce;
    position.y += velocity.y * dt;
    isOnGround = false;
    hasJumped = false;
  }

  void _checkCollisionsOnX() {
    isSliding = false;
    for (final block in collisionBlocks) {
      List<double> overlaps = checkCollisions(this, block);
      double overlapX = overlaps[0];
      double overlapY = overlaps[1];
      if (overlapX != 0 && overlapY != 0) {
        // dev.log(
        //     'Unexpected collision on Y, overlapX: $overlapX, overlapY: $overlapY');
        // Минорные случаи (при коллизии на углах)
        if (overlapX > overlapY && !block.isPlatform) {
          if (velocity.y < 0) {
            position.y -= overlapY;
          }
          return;
          // Когда overlapX < overlapY, значит коллизия происходит по оси X
        } else {
          // Скольжение только по достаточно высоким блокам
          if (velocity.y > 0 && block.height > hitbox.height * 2) {
            isSliding = true;
          }
          // Отмена скольжения при достижении нижней границы блока
          if (position.y + hitbox.height >= block.y + block.height) {
            isSliding = false;
          }
          if (!block.isPlatform) {
            if (velocity.x > 0) {
              velocity.x = 0;
              position.x = block.x - hitbox.offsetX - hitbox.width;
              break;
            }
            if (velocity.x < 0) {
              velocity.x = 0;
              position.x =
                  block.x + block.width + hitbox.width + hitbox.offsetX;
              break;
            }
          }
        }
      }
    }
  }

  void _applyGravity(double dt) {
    velocity.y += Constants.gravity;
    // Ограничение скорости падения и прыжка
    velocity.y = velocity.y.clamp(
      -Constants.jumpForce,
      Constants.terminalVelocity,
    );
    position.y += velocity.y * dt;
  }

  void _checkCollisionsOnY() {
    for (final block in collisionBlocks) {
      List<double> overlaps = checkCollisions(this, block);
      double overlapX = overlaps[0];
      double overlapY = overlaps[1];
      if (overlapX != 0 && overlapY != 0) {
        if (overlapY > overlapX && isOnGround) {
          // dev.log(
          //   'Unexpected collision on X, overlapX: $overlapX, overlapY: $overlapY',
          // );
          return;
          // Когда overlapY < overlapX, значит коллизия происходит по оси Y
        } else {
          if (block.isPlatform) {
            if (velocity.y > 0) {
              velocity.y = 0;
              position.y = block.y - hitbox.height - hitbox.offsetY;
              isOnGround = true;
              break;
            }
          } else {
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
              break;
            }
          }
        }
      }
    }
  }

  void _respawn() async {
    if (game.playSounds) {
      FlameAudio.play('hit.wav', volume: game.soundVolume);
    }
    current = PlayerAnimationState.hit;
    // Дожидаемся завершения анимаций
    await animationTicker?.completed;
    animationTicker?.reset();
    //
    scale.x = 1;
    position = bloc.state.startingPosition;
    horizontalSpeed = 0;
    velocity = Vector2.zero();
    current = PlayerAnimationState.appearing;
    //
    await animationTicker?.completed;
    animationTicker?.reset();
  }

  void _reachedCheckPoint() async {
    if (game.playSounds) {
      FlameAudio.play('disappear.wav', volume: game.soundVolume);
    }
    current = PlayerAnimationState.disappearing;
    //
    await animationTicker?.completed;
    animationTicker?.reset();
    //
    removeFromParent();
    Future.delayed(const Duration(seconds: 3), () => game.nextLevel());
  }
}
