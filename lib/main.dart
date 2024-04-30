import 'package:flame/flame.dart';
import 'package:flutter/material.dart';

import 'modules/home/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  runApp(
    const MaterialApp(
      home: HomePage(),
    ),
  );
  // runApp(
  //   GameWidget(
  //     overlayBuilderMap: {
  //       'PauseMenu': (context, game) {
  //         return Container(
  //           color: const Color(0xFF000000),
  //           child: const Text('Demo Build'),
  //         );
  //       },
  //     },
  //     game: LodeRunner(),
  //   ),
  // );
}
