import 'dart:io';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:lode_runner/components/actors/player.dart';
import 'package:lode_runner/components/levels/level.dart';

class LodeRunner extends FlameGame
    with HasKeyboardHandlerComponents, DragCallbacks, HasCollisionDetection {
  @override
  Color backgroundColor() => const Color(0xFF211F30);
  late final CameraComponent cam;
  late JoystickComponent joystick;
  Player player = Player();

  @override
  Future<void> onLoad() async {
    // Загрузка анимаций в кэш
    await images.loadAllImages();
    // Создание игрового мира
    final world = Level(
      levelName: 'level_02',
      player: player,
    );
    // Создание камеры
    cam = CameraComponent.withFixedResolution(
      world: world,
      width: 640,
      height: 360,
    );
    cam.viewfinder.anchor = Anchor.topLeft;
    // Создание джойстика
    if (Platform.isAndroid || Platform.isIOS) {
      joystick = addjoystick();
    }
    // Добавление камеры и мира в игру
    addAll(
      [
        cam,
        world,
        // joystick,
      ],
    );
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (Platform.isAndroid || Platform.isIOS) {
      updateJoystick();
    }
    super.update(dt);
  }

  JoystickComponent addjoystick() {
    joystick = JoystickComponent(
      background: SpriteComponent(
        sprite: Sprite(
          images.fromCache(
            'hud/joystick.png',
          ),
        ),
      ),
      knob: SpriteComponent(
        sprite: Sprite(
          images.fromCache(
            'hud/knob.png',
          ),
        ),
      ),
      margin: const EdgeInsets.only(
        left: 16,
        bottom: 8,
      ),
    );
    return joystick;
  }

  void updateJoystick() {
    switch (joystick.direction) {
      case JoystickDirection.left:
        // player.playerDirection = PlayerDirection.left;
        break;
      case JoystickDirection.right:
        // player.playerDirection = PlayerDirection.right;
        break;

      default:
      // player.playerDirection = PlayerDirection.none;
    }
  }
}
