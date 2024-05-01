import 'package:flutter/material.dart';
import 'package:lode_runner/modules/game/game_page.dart';

class HomePageView extends StatelessWidget {
  const HomePageView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/home_bg.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.sizeOf(context).height * 0.8,
                    maxWidth: MediaQuery.sizeOf(context).width * 0.6,
                  ),
                  child: Image.asset('assets/title.png'),
                ),
              ),
              Flexible(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          gamePageRoute(),
                        );
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => GameWidget(
                        //       overlayBuilderMap: {
                        //         'PauseMenu': (context, game) {
                        //           return const Text('Demo Build');
                        //         },
                        //       },
                        //       game: LodeRunner(),
                        //     ),
                        //   ),
                        // );
                      },
                      child: const Text('Start Game'),
                    ),
                    const SizedBox(
                      width: 50,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => GameWidget(
                        //       overlayBuilderMap: {
                        //         'PauseMenu': (context, game) {
                        //           return const Text('Demo Build');
                        //         },
                        //       },
                        //       game: LodeRunner(),
                        //     ),
                        //   ),
                        // );
                      },
                      child: const Text('Select Level'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
