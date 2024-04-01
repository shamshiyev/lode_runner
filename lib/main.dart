import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lode_runner/lode_runner.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  await Flame.device.fullScreen();
  LodeRunner game = LodeRunner();
  runApp(
    GameWidget(
      game: kDebugMode ? LodeRunner() : game,
    ),
  );
}
