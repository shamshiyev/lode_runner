part of 'player_bloc.dart';

sealed class StatePlayerBloc extends Equatable {
  const StatePlayerBloc(this.player);

  final Player player;
  @override
  List<Object> get props => [player];
}

final class PlayerInitialState extends StatePlayerBloc {
  const PlayerInitialState(super.player);
}
