import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lode_runner/components/actors/player/bloc/player_bloc.dart';
import 'package:lode_runner/modules/game/game_page_view.dart';

MaterialPageRoute gamePageRoute() {
  return MaterialPageRoute(
    builder: (context) {
      return MultiBlocProvider(
        providers: [
          BlocProvider<PlayerBloc>(create: (context) => PlayerBloc())
        ],
        child: const GamePageView(),
      );
    },
  );
}
