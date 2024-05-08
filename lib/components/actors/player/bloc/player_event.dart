part of 'player_bloc.dart';

sealed class EventPlayerBloc extends Equatable {
  const EventPlayerBloc();

  @override
  List<Object> get props => [];
}

final class PlayerInitialEvent extends EventPlayerBloc {
  const PlayerInitialEvent(this.player);
  final Player player;
}

final class PlayerKeyPressedEvent extends EventPlayerBloc {
  const PlayerKeyPressedEvent({
    required this.keysPressed,
    required this.keyEvent,
  });
  final Set<LogicalKeyboardKey> keysPressed;
  final KeyEvent keyEvent;
}

final class PlayerUpdateDirectionEvent extends EventPlayerBloc {
  const PlayerUpdateDirectionEvent(this.dt);
  final double dt;
}

final class PlayerJumpEvent extends EventPlayerBloc {
  const PlayerJumpEvent(this.dt);
  final double dt;
}

final class PlayerApplyGravityAndCollisionsEvent extends EventPlayerBloc {
  const PlayerApplyGravityAndCollisionsEvent(this.dt);
  final double dt;
}

final class PlayerChangeAnimationEvent extends EventPlayerBloc {}
