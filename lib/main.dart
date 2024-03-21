import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lode_runner/lode_runner.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Flame.device.fullScreen();
  Flame.device.setLandscape();
  LodeRunner game = LodeRunner();
  runApp(
    GameWidget(
      game: kDebugMode ? LodeRunner() : game,
    ),
  );
}
