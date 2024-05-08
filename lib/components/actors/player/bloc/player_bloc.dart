import 'dart:math';
import 'package:equatable/equatable.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lode_runner/components/actors/player/player.dart';

import '../../../../utilities/collisions.dart';

part 'player_event.dart';
part 'player_state.dart';

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

class PlayerBloc extends Bloc<EventPlayerBloc, StatePlayerBloc> {
  PlayerBloc()
      : super(PlayerInitialState(
          Player(),
        )) {
    on<PlayerInitialEvent>(
      (
        event,
        emit,
      ) {
        emit(
          PlayerInitialState(
            event.player,
          ),
        );
      },
    );
    on<PlayerKeyPressedEvent>(
      (event, emit) {
        _playerKeyPressedEvent(
          event.keysPressed,
          event.keyEvent,
        );
      },
    );
    on<PlayerUpdateDirectionEvent>(
      (event, emit) {
        _updateDirection(
          event.dt,
        );
      },
    );
    on<PlayerChangeAnimationEvent>(
      (event, emit) {
        _changePlayerAnimation(
          event,
          emit,
        );
      },
    );
    on<PlayerApplyGravityAndCollisionsEvent>(
      (event, emit) {
        _applyGravityAndCollisions(
          event.dt,
        );
      },
    );
    on<PlayerJumpEvent>(
      (event, emit) {
        _playerJump(
          event.dt,
        );
      },
    );
  }

  double horizontalSpeed = 0;
  Vector2 startingPosition = Vector2.zero();
  Vector2 velocity = Vector2.zero();
  bool hasJumped = false;
  bool isOnGround = true;
  bool isSliding = false;
  bool hasDoubleJumped = false;
  bool gotHit = false;
  bool reachedCheckpoint = false;
  static const double jumpForce = 260;
  static const double wallSlideSpeed = 80;
  static const double moveSpeed = 140;

  static const gravity = 9.8;
  // Сила прыжка
  // Предельная скорость падения
  static const double terminalVelocity = 300;

  void _playerKeyPressedEvent(
    Set<LogicalKeyboardKey> keysPressed,
    KeyEvent event,
  ) {
    // TODO: Может добавлять ивенты прямо здесь через add?
    // log(state.player.toString());
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
  }

  void _playerJump(double dt) {
    if (state.player.gameRef.game.playSounds) {
      FlameAudio.play(
        'jump.wav',
        volume: state.player.gameRef.game.soundVolume,
      );
    }
    velocity.y = -jumpForce;
    state.player.position.y += velocity.y * dt;
    isOnGround = false;
    hasJumped = false;
  }

  void _changePlayerAnimation(
    PlayerChangeAnimationEvent event,
    Emitter<StatePlayerBloc> emit,
  ) {
    if (velocity.x < 0 && state.player.scale.x > 0) {
      state.player.flipHorizontallyAroundCenter();
    } else if (velocity.x > 0 && state.player.scale.x < 0) {
      state.player.flipHorizontallyAroundCenter();
    }
    // Изменение анимаций при прыжке
    if (velocity.y < 0) {
      if (hasDoubleJumped) {
        state.player.current = PlayerAnimationState.doubleJump;
      } else {
        state.player.current = PlayerAnimationState.jump;
      }
    } else if (velocity.y > 0) {
      state.player.current = PlayerAnimationState.fall;
    } else if (velocity.x != 0) {
      state.player.current = PlayerAnimationState.run;
    } else {
      state.player.current = PlayerAnimationState.idle;
    }

    if (isSliding) {
      state.player.current = PlayerAnimationState.wallJump;
    }
  }

  void _updateDirection(double dt) {
    if (hasJumped && (isOnGround || !hasDoubleJumped)) {
      if (!isOnGround) {
        hasDoubleJumped = true;
      }
      add(PlayerJumpEvent(dt));
    } else if (isOnGround) {
      hasDoubleJumped = false;
    }
    if (isSliding && velocity.y > 0) {
      hasJumped = false;
      hasDoubleJumped = false;
      velocity.y = min(velocity.y, wallSlideSpeed);
    }
    velocity.x = horizontalSpeed * moveSpeed;
    state.player.position.x += velocity.x * dt;
    velocity.y += gravity;
    // Ограничение скорости падения и прыжка
    velocity.y = velocity.y.clamp(
      -jumpForce,
      terminalVelocity,
    );
    state.player.position.y += velocity.y * dt;
  }

  void _applyGravityAndCollisions(double dt) {
    // _checkHorizontalCollisions();
    _applyGravity(dt);
    _checkVerticalCollisions();
  }

  void _checkHorizontalCollisions() {
    isSliding = false;
    for (final block in state.player.collisionBlocks) {
      if (checkCollisions(state.player, block)) {
        if (block.isPlatform) {
          if (velocity.x > 0) {
            state.player.position.x = block.x -
                state.player.hitbox.width -
                state.player.hitbox.offsetX;
          } else if (velocity.x < 0) {
            state.player.position.x = block.x + block.width;
          }
        } else {
          if (velocity.x > 0) {
            state.player.position.x = block.x -
                state.player.hitbox.width -
                state.player.hitbox.offsetX;
          } else if (velocity.x < 0) {
            state.player.position.x = block.x + block.width;
          }
          isSliding = true;
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
    state.player.position.y += velocity.y * dt;
  }

  void _checkVerticalCollisions() {
    for (final block in state.player.collisionBlocks) {
      if (block.isPlatform) {
        if (checkCollisions(
          state.player,
          block,
        )) {
          if (velocity.y > 0) {
            velocity.y = 0;
            state.player.position.y = block.y -
                state.player.hitbox.height -
                state.player.hitbox.offsetY;
            isOnGround = true;
            break;
          }
        }
      } else {
        if (checkCollisions(state.player, block)) {
          // Вычисляем коллизию при падении
          if (velocity.y > 0) {
            velocity.y = 0;
            state.player.position.y = block.y -
                state.player.hitbox.height -
                state.player.hitbox.offsetY;
            // При коллизии по вертикали сверху вниз мы понимаем, что "на земле"
            isOnGround = true;
            break;
          }
          // Вычисляем коллизию при прыжке
          if (velocity.y < 0) {
            velocity.y = 0;
            state.player.position.y =
                block.y + block.height - state.player.hitbox.offsetY;
            break;
          }
        }
      }
    }
  }
}
