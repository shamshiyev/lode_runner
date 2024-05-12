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
      add(PlayerJumpEvent(deltaTime: event.deltaTime));
    }
    // TODO: Implement double jump
    // final dt = event.deltaTime;
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

    emit(
      state.copyWith(
        velocity: Vector2(
          state.horizontalSpeed * Constants.moveSpeed,
          state.velocity.y,
        ),
        position: Vector2(
          state.position.x + state.velocity.x * event.deltaTime,
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
    //  velocity.y += gravity;
    // velocity.y = velocity.y.clamp(
    //   -jumpForce,
    //   terminalVelocity,
    // );
    // position.y += velocity.y * dt;
  }
}
