import 'dart:io';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:lode_runner/components/actors/player.dart';
import 'package:lode_runner/components/jump_button.dart';
import 'package:lode_runner/components/levels/level.dart';

class LodeRunner extends FlameGame
    with
        HasKeyboardHandlerComponents,
        DragCallbacks,
        HasCollisionDetection,
        HasGameRef<LodeRunner>,
        TapCallbacks {
  @override
  Color backgroundColor() => const Color(0xFF211F30);
  late CameraComponent cam;

  /// Creating player here is not correct, it should be created in the level
  Player player = Player();
  late JoystickComponent joystick;
  bool playSounds = true;
  double soundVolume = 0.5;

  List<String> levelsList = [
    'level_01',
    'level_02',
  ];

  int currentLevel = 0;

  @override
  Future<void> onLoad() async {
    // Загрузка анимаций в кэш
    await images.loadAllImages();
    _loadLevel();
    game.overlays.add('PauseMenu');
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
      priority: 2,
      anchor: Anchor.bottomLeft,
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
        left: 2,
        bottom: 8,
      ),
    );
    return joystick;
  }

  void updateJoystick() {
    switch (joystick.direction) {
      case JoystickDirection.left:
      case JoystickDirection.upLeft:
      case JoystickDirection.downLeft:
        player.horizontalSpeed = -1;
        break;
      case JoystickDirection.right:
      case JoystickDirection.upRight:
      case JoystickDirection.downRight:
        player.horizontalSpeed = 1;
        break;
      default:
        player.horizontalSpeed = 0;
        break;
    }
  }

  // Загрузка следующего уровня
  void nextLevel() {
    currentLevel++;
    if (currentLevel >= levelsList.length) {
      // TODO: Show game over screen
      currentLevel = 0;
    }
    _loadLevel();
  }

  void _loadLevel() async {
    // Удаление всех компонентов предыдущего уровня
    removeWhere((component) => component is Level);
    // Создание игрового мира
    Level world = Level(
      levelName: levelsList[currentLevel],
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
      add(JumpButton());
      add(joystick);
    }
    // Добавление камеры и мира в игру
    addAll(
      [
        cam,
        world,
      ],
    );
  }
}
