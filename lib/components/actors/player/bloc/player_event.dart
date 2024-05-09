part of 'player_bloc.dart';

sealed class EventPlayerBloc extends Equatable {
  const EventPlayerBloc();

  @override
  List<Object> get props => [];
}

final class PlayerInitialEvent extends EventPlayerBloc {
  const PlayerInitialEvent({
    required this.player,
    required this.startingPosition,
  });
  final Player player;
  final Vector2 startingPosition;
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

final class PlayerApplyGravityEvent extends EventPlayerBloc {
  const PlayerApplyGravityEvent(this.dt);
  final double dt;
}

final class PlayerCheckHorizontalCollisionsEvent extends EventPlayerBloc {
  final List<CollisionBlock> collisionBlocks;
  const PlayerCheckHorizontalCollisionsEvent(this.collisionBlocks);
}

final class PlayerCheckVerticalCollisionsEvent extends EventPlayerBloc {
  final List<CollisionBlock> collisionBlocks;
  const PlayerCheckVerticalCollisionsEvent(this.collisionBlocks);
}

final class PlayerChangeAnimationEvent extends EventPlayerBloc {}
