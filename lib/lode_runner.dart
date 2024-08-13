import 'dart:io';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:lode_runner/components/actors/player/bloc/player_bloc.dart';
import 'package:lode_runner/components/jump_button.dart';
import 'package:lode_runner/modules/levels/level.dart';

class LodeRunner extends FlameGame
    with
        HasKeyboardHandlerComponents,
        DragCallbacks,
        HasCollisionDetection,
        HasGameRef<LodeRunner>,
        TapCallbacks {
  LodeRunner({
    required this.playerBloc,
  });

  late CameraComponent cam;
  int currentLevel = 0;
  late JoystickComponent joystick;
  List<String> levelsList = [
    'level_01',
    'level_02',
    'level_03',
    'level_04',
    'level_05',
    'level_06',
    'level_07',
  ];

  bool playSounds = true;
  final PlayerBloc playerBloc;
  double soundVolume = 0.5;

  @override
  Color backgroundColor() => const Color(0xFF211F30);

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
    updateJoystick();

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
      position: Vector2(
        game.size.x - game.size.x + 80,
        game.size.y - 40,
      ),
    );
    return joystick;
  }

  void updateJoystick() {
    switch (joystick.direction) {
      case JoystickDirection.left:
      case JoystickDirection.upLeft:
      case JoystickDirection.downLeft:
        gameRef.playerBloc.state.player.horizontalSpeed = -1;
        break;
      case JoystickDirection.right:
      case JoystickDirection.upRight:
      case JoystickDirection.downRight:
        gameRef.playerBloc.state.player.horizontalSpeed = 1;
        break;
      default:
        gameRef.playerBloc.state.player.horizontalSpeed = 0;
        break;
    }
  }

  // Загрузка следующего уровня
  void nextLevel() {
    currentLevel++;
    if (currentLevel >= levelsList.length) {
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
    if (Platform.isAndroid || Platform.isIOS) {
      // Создание джойстика
      joystick = addjoystick();
      cam.viewport.addAll(
        [
          joystick,
          JumpButton(),
        ],
      );
    }
    addAll(
      [
        world,
        cam,
      ],
    );
  }
}
