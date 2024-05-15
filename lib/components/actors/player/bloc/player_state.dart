part of 'player_bloc.dart';

sealed class StatePlayerBloc extends Equatable {
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
}

final class PlayerInitialState extends StatePlayerBloc {
  const PlayerInitialState({
    required super.player,
    required super.startingPosition,
  });
}
