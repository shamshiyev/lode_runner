part of 'player_bloc.dart';

class StatePlayerBloc extends Equatable {
  const StatePlayerBloc({
    required this.player,
    required this.startingPosition,
  });

  final Player player;
  final Vector2 startingPosition;
  @override
  List<Object> get props => [
        player,
        startingPosition,
      ];

  StatePlayerBloc copyWith({
    Player? player,
    Vector2? startingPosition,
  }) {
    return StatePlayerBloc(
      player: player ?? this.player,
      startingPosition: startingPosition ?? this.startingPosition,
    );
  }
}

final class PlayerInitialState extends StatePlayerBloc {
  const PlayerInitialState({
    required super.player,
    required super.startingPosition,
  });
}

final class PlayerKeyPressedState extends StatePlayerBloc {
  const PlayerKeyPressedState({
    required super.player,
    required super.startingPosition,
    this.horizontalSpeed = 0,
    this.hasJumped = false,
  });

  final double horizontalSpeed;
  final bool hasJumped;

  @override
  List<Object> get props => [
        player,
        startingPosition,
        horizontalSpeed,
        hasJumped,
      ];
}

final class PlayerGotHitState extends StatePlayerBloc {
  const PlayerGotHitState({
    required super.player,
    required super.startingPosition,
  });
}

final class PlayerReachedCheckpointState extends StatePlayerBloc {
  const PlayerReachedCheckpointState({
    required super.player,
    required super.startingPosition,
  });
}
