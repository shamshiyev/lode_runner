import 'dart:io';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:lode_runner/components/actors/player/bloc/player_bloc.dart';
import 'package:lode_runner/components/jump_button.dart';
import 'package:lode_runner/components/levels/level.dart';

class LodeRunner extends FlameGame
    with
        HasKeyboardHandlerComponents,
        DragCallbacks,
        HasCollisionDetection,
        HasGameRef<LodeRunner>,
        TapCallbacks {
  final PlayerBloc playerBloc;

  LodeRunner({
    required this.playerBloc,
  });

  @override
  Color backgroundColor() => const Color(0xFF211F30);

  late CameraComponent cam;

  late JoystickComponent joystick;
  bool playSounds = false;
  double soundVolume = 0.5;

  List<String> levelsList = [
    'level_01',
    'level_02',
    'level_03',
  ];

  int currentLevel = 2;

  @override
  Future<void> onLoad() async {
    // Загрузка анимаций в кэш
    await images.loadAllImages();
    _loadLevel();
    game.overlays.add('PauseMenu');
    return super.onLoad();
  }

  // @override
  // void update(double dt) {
  //   if (Platform.isAndroid || Platform.isIOS) {
  //     updateJoystick();
  //   }
  //   super.update(dt);
  // }

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

  // void updateJoystick() {
  //   switch (joystick.direction) {
  //     case JoystickDirection.left:
  //     case JoystickDirection.upLeft:
  //     case JoystickDirection.downLeft:
  //       player.horizontalSpeed = -1;
  //       break;
  //     case JoystickDirection.right:
  //     case JoystickDirection.upRight:
  //     case JoystickDirection.downRight:
  //       player.horizontalSpeed = 1;
  //       break;
  //     default:
  //       player.horizontalSpeed = 0;
  //       break;
  //   }
  // }

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
    removeWhere((component) => component is GameWorld);

    // Создание игрового мира
    GameWorld world = GameWorld(
      levelName: levelsList[currentLevel],
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
    addAll(
      [
        world,
        cam,
      ],
    );
  }
}
