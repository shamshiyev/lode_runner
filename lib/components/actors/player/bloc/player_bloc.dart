import 'dart:developer' as dev;
import 'package:equatable/equatable.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flame_tiled/flame_tiled.dart';
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
    on<HandleHorizontalCollisionEvent>(
      (event, emit) {
        _handleHorisontalCollision(
          event,
          emit,
        );
      },
    );
    on<HandleVerticalCollisionEvent>(
      (event, emit) {
        _handleVerticalCollision(
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
    // if (state.hasJumped && (state.isOnGround || !state.hasDoubleJumped)) {
    //   if (!state.isOnGround) {
    //     emit(state.copyWith(hasDoubleJumped: true));
    //   }
    //   add(PlayerJumpEvent(deltaTime: dt));
    // } else if (state.isOnGround) {
    //   emit(state.copyWith(hasDoubleJumped: false));
    // }
    // if (state.isSliding && state.velocity.y > 0) {
    //   emit(
    //     state.copyWith(
    //       hasJumped: false,
    //       hasDoubleJumped: false,
    //       velocity: Vector2(
    //         state.velocity.x,
    //         min(
    //           state.velocity.y,
    //           Constants.wallSlideSpeed,
    //         ),
    //       ),
    //     ),
    //   );
    // }

    var newVelocityX = state.horizontalSpeed * Constants.moveSpeed;
    var newPositionX = state.position.x + newVelocityX * event.deltaTime;
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
    final dt = event.deltaTime;
    final double updatedVelocityY = state.velocity.y + Constants.gravity;
    emit(
      state.copyWith(
        velocity: Vector2(
          // Ограничение скорости падения и прыжка
          state.velocity.x,
          updatedVelocityY.clamp(
            -Constants.jumpForce,
            Constants.terminalVelocity,
          ),
        ),
        position: Vector2(
          state.position.x,
          state.position.y + state.velocity.y * dt,
        ),
      ),
    );
  }

  void _changePlayerAnimation(
    PlayerChangeAnimationEvent event,
    Emitter<StatePlayerBloc> emit,
  ) {
    if (state.velocity.x < 0 && state.player.scale.x > 0) {
      // TODO: Not sure about this
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
    } else if (state.velocity.y > 0) {
      // Изменение анимаций при падении
      state.player.current = PlayerAnimationState.fall;
    } else if (state.velocity.x != 0) {
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
    final playerX = state.player.position.x + state.player.hitbox.offsetX;
    final playerWidth = state.player.hitbox.width;
    final fixedX = state.player.scale.x > 0
        ? playerX
        : playerX - (state.player.hitbox.offsetX * 2);
    // final playerLeft = state.player.position.x + state.player.hitbox.offsetX;
    final blockX = block.x;
    final blockWidth = block.width;
    final isCollisionOnX =
        (fixedX < blockX + blockWidth && fixedX + playerWidth > blockX);

    if (isCollisionOnX) {
      add(
        HandleHorizontalCollisionEvent(
          block,
        ),
      );
    }

    // double playerLeft = state.player.position.x;
    // double playerRight = playerLeft + state.player.width;

    // double blockLeft = block.x;
    // double blockRight = blockLeft + block.width;
    // bool isCollisionOnY = (playerLeft < blockRight && playerRight > blockLeft);
    // if (isCollisionOnY) {
    //   dev.log('Collision on Y axis');
    // }
  }

  void _handleHorisontalCollision(
    HandleHorizontalCollisionEvent event,
    Emitter<StatePlayerBloc> emit,
  ) {
    final block = event.collisionBlock;
    if (!block.isPlatform) {
      if (state.velocity.y > 0) {
        emit(
          state.copyWith(
            isSliding: true,
          ),
        );
      }
      // Коллизия и остановка при движении вправо
      if (state.velocity.x > 0) {
        emit(
          PlayerCollidedState(
            player: state.player,
            position: Vector2(
              block.x - state.player.hitbox.width / 2,
              state.position.y,
            ),
            velocity: Vector2(
              0,
              state.velocity.y,
            ),
            isOnGround: state.isOnGround,
            hasJumped: state.hasJumped,
            isSliding: state.isSliding,
            hasDoubleJumped: state.hasDoubleJumped,
            gotHit: state.gotHit,
            reachedCheckpoint: state.reachedCheckpoint,
            horizontalSpeed: state.horizontalSpeed,
          ),
        );
        return;
      }
      // Коллизия и остановка при движении влево
      if (state.velocity.x < 0) {
        emit(
          PlayerCollidedState(
            player: state.player,
            position: Vector2(
              block.x + block.width + state.player.hitbox.offsetX,
              state.position.y,
            ),
            velocity: Vector2(
              0,
              state.velocity.y,
            ),
            isOnGround: state.isOnGround,
            hasJumped: state.hasJumped,
            isSliding: state.isSliding,
            hasDoubleJumped: state.hasDoubleJumped,
            gotHit: state.gotHit,
            reachedCheckpoint: state.reachedCheckpoint,
            horizontalSpeed: state.horizontalSpeed,
          ),
        );
        return;
      }
    }
  }

  // TODO: Some shit with naming
  void _handleVerticalCollision(
    HandleVerticalCollisionEvent event,
    Emitter<StatePlayerBloc> emit,
  ) {
    // final block = event.collisionBlock;
    // if (block.isPlatform) {
    //   if (state.velocity.y > 0) {
    //     emit(
    //       state.copyWith(
    //         isOnGround: true,
    //         position: Vector2(
    //             state.player.position.x,
    //             block.y -
    //                 state.player.hitbox.height -
    //                 state.player.hitbox.offsetY),
    //       ),
    //     );
    //     return;
    //   }
    // } else {
    //   // Вычисляем коллизию при падении
    //   if (state.velocity.y > 0) {
    //     // При коллизии по вертикали сверху вниз мы понимаем, что "на земле"
    //     emit(state.copyWith(
    //       velocity: Vector2(
    //         state.velocity.x,
    //         0,
    //       ),
    //       position: Vector2(
    //         state.player.position.x,
    //         block.y - state.player.hitbox.height - state.player.hitbox.offsetY,
    //       ),
    //       isOnGround: true,
    //     ));
    //     return;
    //   }
    //   // Вычисляем коллизию при прыжке
    //   if (state.velocity.y < 0) {
    //     emit(state.copyWith(
    //       velocity: Vector2(
    //         state.velocity.x,
    //         0,
    //       ),
    //       position: Vector2(
    //         state.player.position.x,
    //         block.y + block.height - state.player.hitbox.offsetY,
    //       ),
    //     ));
    //     return;
    //   }
    // }
  }
}
