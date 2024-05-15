// ignore: unused_import
import 'dart:developer' as dev;
import 'dart:math';
import 'package:equatable/equatable.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../utilities/collisions.dart';
import '../../../../utilities/constants.dart';
import '../player.dart';

part 'player_event.dart';
part 'player_state.dart';

class PlayerBloc extends Bloc<EventPlayerBloc, StatePlayerBloc> {
  PlayerBloc()
      : super(
          PlayerInitialState(
            player: Player(),
            position: Vector2.zero(),
            velocity: Vector2.zero(),
          ),
        ) {
    on<PlayerInitialEvent>(
      (event, emit) {
        emit(
          PlayerInitialState(
            player: event.player,
            position: event.startingPosition,
            velocity: event.startingVelocity,
          ),
        );
      },
    );
    on<PlayerKeyPressedEvent>(
      (event, emit) {
        _buttonPressed(
          event,
          emit,
        );
      },
    );
    on<PlayerUpdateDirectionEvent>(
      (event, emit) {
        _updateDirection(
          event,
          emit,
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
    on<PlayerJumpEvent>(
      (event, emit) {
        _playerJump(
          event,
          emit,
        );
      },
    );
    on<PlayerApplyGravityEvent>(
      (event, emit) {
        _applyGravity(
          event,
          emit,
        );
      },
    );
    on<PlayerCollisionEvent>(
      (event, emit) {
        _resolveCollisions(
          event,
          emit,
        );
      },
    );
  }

  void _buttonPressed(
    PlayerKeyPressedEvent event,
    Emitter<StatePlayerBloc> emit,
  ) {
    final keysPressed = event.keysPressed;
    final logicalKey = event.keyEvent.logicalKey;
    int horizontalSpeed = 0;
    emit(
      PlayerActiveState(
        player: state.player,
        position: state.player.position,
        velocity: state.velocity,
        isOnGround: state.isOnGround,
        hasJumped: state.hasJumped,
        isSliding: state.isSliding,
        hasDoubleJumped: state.hasDoubleJumped,
        gotHit: state.gotHit,
        reachedCheckpoint: state.reachedCheckpoint,
        horizontalSpeed: state.horizontalSpeed,
      ),
    );
    // Описываем инпуты для передвижения и остановки по горизонтали
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
      if (logicalKey == LogicalKeyboardKey.arrowLeft ||
          logicalKey == LogicalKeyboardKey.arrowRight ||
          logicalKey == LogicalKeyboardKey.keyA ||
          logicalKey == LogicalKeyboardKey.keyD) {
        horizontalSpeed = 0;
      }
    }

    // Прыжок
    bool hasJumped = keysPressed.contains(LogicalKeyboardKey.space);
    emit(
      state.copyWith(
        player: state.player,
        hasJumped: hasJumped,
        horizontalSpeed: horizontalSpeed,
      ),
    );
  }

  void _updateDirection(
    PlayerUpdateDirectionEvent event,
    Emitter<StatePlayerBloc> emit,
  ) {
    if (state.hasJumped) {
      add(
        PlayerJumpEvent(
          deltaTime: event.deltaTime,
        ),
      );
    }
    // TODO: Implement double jump
    if (state.hasJumped && (state.isOnGround || !state.hasDoubleJumped)) {
      if (!state.isOnGround) {
        emit(state.copyWith(hasDoubleJumped: true));
      }
      add(PlayerJumpEvent(deltaTime: event.deltaTime));
    } else if (state.isOnGround) {
      emit(state.copyWith(hasDoubleJumped: false));
    }
    if (state.isSliding && state.velocity.y > 0) {
      emit(
        state.copyWith(
          hasJumped: false,
          hasDoubleJumped: false,
          velocity: Vector2(
            state.velocity.x,
            min(
              state.velocity.y,
              Constants.wallSlideSpeed,
            ),
          ),
        ),
      );
    }

    var newVelocityX = state.horizontalSpeed * Constants.moveSpeed;
    var newPositionX = state.position.x + newVelocityX * event.deltaTime;
    // if (newVelocityX < 0) {
    //   if (state.canMoveLeft) {
    //     emit(
    //       state.copyWith(
    //         velocity: Vector2(
    //           newVelocityX,
    //           state.velocity.y,
    //         ),
    //         position: Vector2(
    //           newPositionX,
    //           state.player.position.y,
    //         ),
    //         canMoveRight: true,
    //       ),
    //     );
    //   }
    // } else if (newVelocityX > 0) {
    //   if (state.canMoveRight) {
    //     emit(
    //       state.copyWith(
    //         velocity: Vector2(
    //           newVelocityX,
    //           state.velocity.y,
    //         ),
    //         position: Vector2(
    //           newPositionX,
    //           state.player.position.y,
    //         ),
    //         canMoveLeft: true,
    //       ),
    //     );
    //   }
    // }

    emit(
      state.copyWith(
        velocity: Vector2(
          newVelocityX,
          state.velocity.y,
        ),
        position: Vector2(
          newPositionX,
          state.player.position.y,
        ),
      ),
    );
  }

  void _playerJump(
    PlayerJumpEvent event,
    Emitter<StatePlayerBloc> emit,
  ) {
    if (state.player.gameRef.playSounds) {
      FlameAudio.play(
        'jump.wav',
        volume: state.player.gameRef.soundVolume,
      );
    }
    emit(
      state.copyWith(
        velocity: Vector2(
          state.velocity.x,
          -Constants.jumpForce,
        ),
        position: Vector2(
          state.position.x,
          state.position.y + state.velocity.y * event.deltaTime,
        ),
        isOnGround: false,
        hasJumped: false,
      ),
    );
  }

  void _applyGravity(
    PlayerApplyGravityEvent event,
    Emitter<StatePlayerBloc> emit,
  ) {
    emit(
      state.copyWith(
        velocity: Vector2(
          // Ограничение скорости падения и прыжка
          state.velocity.x,
          (state.velocity.y + Constants.gravity).clamp(
            -Constants.jumpForce,
            Constants.terminalVelocity,
          ),
        ),
        position: Vector2(
          state.position.x,
          state.position.y + state.velocity.y * event.deltaTime,
        ),
      ),
    );
  }

  void _changePlayerAnimation(
    PlayerChangeAnimationEvent event,
    Emitter<StatePlayerBloc> emit,
  ) {
    if (state.velocity.x < 0 && state.player.scale.x > 0) {
      state.player.anchor = Anchor.topCenter;
      state.player.flipHorizontallyAroundCenter();
    } else if (state.velocity.x > 0 && state.player.scale.x < 0) {
      state.player.anchor = Anchor.topCenter;
      state.player.flipHorizontallyAroundCenter();
    }
    // Изменение анимаций при прыжке
    if (state.velocity.y < 0) {
      if (state.hasDoubleJumped) {
        state.player.current = PlayerAnimationState.doubleJump;
      } else {
        state.player.current = PlayerAnimationState.jump;
      }
    } else if (state.velocity.y > 20 && !state.isOnGround) {
      // Изменение анимаций при падении
      state.player.current = PlayerAnimationState.fall;
    } else if (state.horizontalSpeed != 0) {
      // Изменение анимаций при движении
      state.player.current = PlayerAnimationState.run;
    } else {
      //  Изменение анимаций при стоянии
      state.player.current = PlayerAnimationState.idle;
    }
    if (state.isSliding) {
      // Изменение анимаций при скольжении
      state.player.current = PlayerAnimationState.wallJump;
    }
    emit(
      state.copyWith(
        player: state.player,
      ),
    );
  }

  void _resolveCollisions(
    PlayerCollisionEvent event,
    Emitter<StatePlayerBloc> emit,
  ) {
    final block = event.collisionBlock;
    final hitbox = state.player.hitbox;
    // Позиция персонажа по оси X
    final playerX = state.player.position.x;
    final playerWidth = hitbox.width;
    // Позиция блока по оси X
    final blockX = block.x;
    final blockWidth = block.width;
    // Проверяем развернута ли модель влево

    // Верхняя точка игрока
    final playerY = state.player.position.y + hitbox.offsetY;
    // Верхняя точка блока
    final blockY = block.y;
    final playerHeight = hitbox.height;
    final blockHeight = block.height;

    //! Важно, не удалять
    bool isOnGround = playerY + playerHeight == blockY;

    bool isCollisionOnX =
        (playerX + playerWidth >= blockX && playerX <= blockX + blockWidth);

    bool isCollisionOnY =
        (playerY + playerHeight >= blockY && playerY <= blockY + blockHeight);

    // TODO: При самой первой коллизии с платформой, игрок должен остановиться

    if (isCollisionOnX) {}

    if (isCollisionOnY && isCollisionOnX) {
      double overlapX = max(
          0,
          min(playerX + playerWidth, blockX + blockWidth) -
              max(playerX, blockX));
      double overlapY = max(
        0,
        min(playerY + playerHeight, blockY + blockHeight) -
            max(
              playerY,
              blockY,
            ),
      );

      // dev.log('OverlapX: $overlapX, OverlapY: $overlapY');

      if (overlapX == 0) {
        _handleVerticalCollision(block, emit);
      }

      //!  Когда overlaY больше overlapX, значит коллизия произошла по оси X
      if (overlapX != 0 && overlapY != 0) {
        if (overlapX >= overlapY) {
          _handleVerticalCollision(block, emit);
        } else {
          _handleHorizontalCollision(block, emit);
        }
      } else {
        emit(
          state.copyWith(
            isOnGround: false,
          ),
        );
      }
    }
  }

  void _handleVerticalCollision(
    CollisionBlock block,
    Emitter<StatePlayerBloc> emit,
  ) {
    // Проверяем, является ли блок платформой
    // final block = event.collisionBlock;
    if (block.isPlatform) {
      if (state.velocity.y > 0) {
        emit(
          state.copyWith(
            isOnGround: true,
            position: Vector2(
              state.player.position.x,
              block.y -
                  state.player.hitbox.height -
                  state.player.hitbox.offsetY,
            ),
          ),
        );
      }
    } else {
      if (state.velocity.y > 0) {
        // При запрыгивании и коллизии по вертикали сверху вниз мы понимаем, что "на земле"
        emit(
          state.copyWith(
            velocity: Vector2(
              state.velocity.x,
              0,
            ),
            position: Vector2(
              state.player.position.x,
              block.y -
                  state.player.hitbox.height -
                  state.player.hitbox.offsetY,
            ),
            isOnGround: true,
          ),
        );
      }
      // Вычисляем коллизию при прыжке
      if (state.velocity.y < 0) {
        emit(
          state.copyWith(
            velocity: Vector2(
              state.velocity.x,
              0,
            ),
            position: Vector2(
              state.player.position.x,
              block.y + block.height + state.player.hitbox.offsetY,
            ),
          ),
        );
      }
    }
  }

  void _handleHorizontalCollision(
      CollisionBlock block, Emitter<StatePlayerBloc> emit) {
    if (!block.isPlatform) {
      // if (state.velocity.y > 0) {
      //   emit(
      //     state.copyWith(
      //       isSliding: true,
      //     ),
      //   );
      // }
      emit(
        state.copyWith(
          horizontalSpeed: 0,
          velocity: Vector2(
            0,
            state.velocity.y,
          ),
          position: Vector2(
            state.player.scale.x > 0
                ? block.x - state.player.hitbox.offsetX
                : block.x + block.width + state.player.hitbox.offsetX,
            state.position.y,
          ),
        ),
      );
    }
  }
}
