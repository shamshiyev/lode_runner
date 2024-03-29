import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:lode_runner/levels/level.dart';

class LodeRunner extends FlameGame {
  @override
  Color backgroundColor() => const Color(0xFF211F30);
  late final CameraComponent cam;
  final world = Level();

  @override
  Future<void> onLoad() async {
    // Подгружаем все анимации в кэш
    await images.loadAllImages();

    cam = CameraComponent.withFixedResolution(
      world: world,
      width: 640,
      height: 360,
    );
    cam.viewfinder.anchor = Anchor.topLeft;
    addAll(
      [cam, world],
    );
    return super.onLoad();
  }
}
