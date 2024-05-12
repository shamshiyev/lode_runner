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
    required this.startingVelocity,
  });
  final Player player;
  final Vector2 startingPosition;
  final Vector2 startingVelocity;
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
  const PlayerUpdateDirectionEvent({
    required this.deltaTime,
  });
  final double deltaTime;
}

final class PlayerJumpEvent extends EventPlayerBloc {
  const PlayerJumpEvent({
    required this.deltaTime,
  });
  final double deltaTime;
}

final class PlayerApplyGravityEvent extends EventPlayerBloc {
  const PlayerApplyGravityEvent({
    required this.deltaTime,
  });
  final double deltaTime;
}

final class PlayerHorizontalCollisionsEvent extends EventPlayerBloc {
  const PlayerHorizontalCollisionsEvent(this.collisionBlocks);
  final List<CollisionBlock> collisionBlocks;
}

final class PlayerVerticalCollisionsEvent extends EventPlayerBloc {
  const PlayerVerticalCollisionsEvent(this.collisionBlocks);
  final List<CollisionBlock> collisionBlocks;
}
