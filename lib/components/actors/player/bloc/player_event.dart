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
