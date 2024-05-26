import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lode_runner/components/actors/player/bloc/player_bloc.dart';
import 'package:lode_runner/lode_runner.dart';

class GamePageView extends StatefulWidget {
  const GamePageView({super.key});

  @override
  State<GamePageView> createState() => _GamePageViewState();
}

class _GamePageViewState extends State<GamePageView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: MouseRegion(
              onHover: (_) {},
              child: GameWidget(
                overlayBuilderMap: {
                  'PauseMenu': (context, game) {
                    return Container(
                      color: const Color(0xFF000000),
                      child: const Text('Demo Build'),
                    );
                  },
                },
                game: LodeRunner(
                  playerBloc: context.read<PlayerBloc>(),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
