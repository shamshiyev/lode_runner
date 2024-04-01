import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:lode_runner/actors/player.dart';
import 'package:lode_runner/levels/level.dart';

class LodeRunner extends FlameGame with HasKeyboardHandlerComponents {
  @override
  Color backgroundColor() => const Color(0xFF211F30);
  late final CameraComponent cam;
  late JoystickComponent joystick;

  @override
  Future<void> onLoad() async {
    // Загрузка анимаций в кэш
    await images.loadAllImages();
    // Создание игрового мира
    final world = Level(
      levelName: 'level_02',
      player: Player(),
    );
    // Создание камеры
    cam = CameraComponent.withFixedResolution(
      world: world,
      width: 640,
      height: 360,
    );
    cam.viewfinder.anchor = Anchor.topLeft;
    // Добавление камеры и мира в игру
    addAll(
      [cam, world],
    );

    void addjoystick() {}
    joystick = JoystickComponent();
    return super.onLoad();
  }
}
