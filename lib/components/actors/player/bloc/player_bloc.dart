import 'package:equatable/equatable.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

    on<PlayerChangeAnimationEvent>(
      (event, emit) {},
    );
    on<PlayerJumpEvent>(
      (event, emit) {},
    );
  }

  void _buttonPressed(
    PlayerKeyPressedEvent event,
    Emitter<StatePlayerBloc> emit,
  ) {
    //   final keysPressed = event.keysPressed;
    //   final logicalKey = event.keyEvent.logicalKey;
    //   int horizontalSpeed = 0;
    //   emit(
    //     PlayerActiveState(
    //       player: state.player,
    //       position: state.player.position,
    //       velocity: state.velocity,
    //       isOnGround: state.isOnGround,
    //       hasJumped: state.hasJumped,
    //       isSliding: state.isSliding,
    //       hasDoubleJumped: state.hasDoubleJumped,
    //       gotHit: state.gotHit,
    //       reachedCheckpoint: state.reachedCheckpoint,
    //       horizontalSpeed: state.horizontalSpeed,
    //     ),
    //   );
    //   // Описываем инпуты для передвижения и остановки по горизонтали
    //   final leftKeyPressed = keysPressed.contains(
    //         LogicalKeyboardKey.arrowLeft,
    //       ) ||
    //       keysPressed.contains(
    //         LogicalKeyboardKey.keyA,
    //       );
    //   final rightKeyPressed = keysPressed.contains(
    //         LogicalKeyboardKey.arrowRight,
    //       ) ||
    //       keysPressed.contains(
    //         LogicalKeyboardKey.keyD,
    //       );
    //   horizontalSpeed += leftKeyPressed ? -1 : 0;
    //   horizontalSpeed += rightKeyPressed ? 1 : 0;
    //   if (leftKeyPressed && rightKeyPressed) {
    //     horizontalSpeed = 0;
    //   }
    //   // Остановка при отпускании клавиш движения
    //   if (event is KeyUpEvent) {
    //     if (logicalKey == LogicalKeyboardKey.arrowLeft ||
    //         logicalKey == LogicalKeyboardKey.arrowRight ||
    //         logicalKey == LogicalKeyboardKey.keyA ||
    //         logicalKey == LogicalKeyboardKey.keyD) {
    //       horizontalSpeed = 0;
    //     }
    //   }
    //   // Прыжок
    //   bool hasJumped = keysPressed.contains(LogicalKeyboardKey.space);
    //   emit(
    //     state.copyWith(
    //       player: state.player,
    //       hasJumped: hasJumped,
    //       horizontalSpeed: horizontalSpeed,
    //     ),
    //   );
    // }
  }
}
