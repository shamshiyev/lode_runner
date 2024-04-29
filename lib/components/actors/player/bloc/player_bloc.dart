import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lode_runner/components/actors/player/player.dart';

part 'player_event.dart';
part 'player_state.dart';

class PlayerBloc extends Bloc<EventPlayerBloc, StatePlayerBloc> {
  PlayerBloc() : super(PlayerInitialState(Player())) {
    on<PlayerInitialEvent>((event, emit) {
      emit(PlayerInitialState(event.player));
    });
  }
}
