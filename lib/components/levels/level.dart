import 'dart:async';
import 'dart:developer' as dev;
import 'package:flame/components.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:lode_runner/components/actors/player/bloc/player_bloc.dart';
import 'package:lode_runner/components/traps/chain.dart';
import 'package:lode_runner/components/traps/spike.dart';

import '../../utilities/background_tile.dart';
import '../../utilities/collisions.dart';
import '../../lode_runner.dart';
import '../actors/enemy.dart';
import '../actors/player/player.dart';
import '../checkpoint.dart';
import '../collectable.dart';
import '../traps/saw.dart';

class GameWorld extends World with HasGameRef<LodeRunner> {
  GameWorld({
    required this.levelName,
  });
  late TiledComponent level;
  final String levelName;
  late final Player player;
  List<CollisionBlock> collisionBlocks = [];
  late final Checkpoint checkPoint;

  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load(
      '$levelName.tmx',
      Vector2.all(16),
    );
    add(level);
    _scrollingBackground();
    _spawningObjects();
    _addCollisions();
    return super.onLoad();
  }

  @override
  void update(double dt) {
    var collectableCount = Collectable.collectableCount;
    if (collectableCount == 0) {
      add(checkPoint);
    }
    super.update(dt);
  }

  // Добавление точек спавна
  void _spawningObjects() async {
    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>('spawnpoints');

    if (spawnPointsLayer != null) {
      for (final spawnPoint in spawnPointsLayer.objects) {
        switch (spawnPoint.type) {
          case 'player':
            player = Player();
            gameRef.playerBloc.add(
              PlayerInitialEvent(
                player: player,
                startingPosition: Vector2(
                  spawnPoint.x,
                  spawnPoint.y,
                ),
                startingVelocity: Vector2.zero(),
              ),
            );
            await add(
              FlameBlocProvider<PlayerBloc, StatePlayerBloc>.value(
                value: gameRef.playerBloc,
                children: [
                  player,
                ],
              ),
            );
            break;
          case 'collectable':
            final collectable = Collectable(
              type: spawnPoint.name,
              position: Vector2(
                spawnPoint.x,
                spawnPoint.y,
              ),
              size: Vector2(
                spawnPoint.width,
                spawnPoint.height,
              ),
            );
            add(collectable);
            break;
          case 'saw':
            final isVertical = spawnPoint.properties.getValue('isVertical');
            final offNeg = spawnPoint.properties.getValue('offNeg');
            final offPos = spawnPoint.properties.getValue('offPos');
            final saw = Saw(
              isVertical: isVertical,
              offNeg: offNeg,
              offPos: offPos,
              position: Vector2(
                spawnPoint.x,
                spawnPoint.y,
              ),
              size: Vector2(
                spawnPoint.width,
                spawnPoint.height,
              ),
            );
            add(saw);
            break;
          case 'checkpoint':
            checkPoint = Checkpoint(
              position: Vector2(
                spawnPoint.x,
                spawnPoint.y,
              ),
              size: Vector2(
                spawnPoint.width,
                spawnPoint.height,
              ),
            );
            break;
          case 'enemy':
            final offNeg = spawnPoint.properties.getValue('offNeg');
            final offPos = spawnPoint.properties.getValue('offPos');
            final enemy = Enemy(
              position: Vector2(
                spawnPoint.x,
                spawnPoint.y,
              ),
              size: Vector2(
                spawnPoint.width,
                spawnPoint.height,
              ),
              offNeg: offNeg,
              offPos: offPos,
            );
            await add(
              FlameBlocProvider<PlayerBloc, StatePlayerBloc>.value(
                value: gameRef.playerBloc,
                children: [
                  enemy,
                ],
              ),
            );
            break;
          case 'sprite':
            final sprite = Chain(
              position: Vector2(
                spawnPoint.x,
                spawnPoint.y,
              ),
              size: Vector2(
                spawnPoint.width,
                spawnPoint.height,
              ),
            );
            add(sprite);
            break;
          case 'spikes':
            final direction = spawnPoint.properties.getValue('direction');
            final spike = Spike(
              direction: direction,
              position: Vector2(
                spawnPoint.x,
                spawnPoint.y,
              ),
              size: Vector2(
                spawnPoint.width,
                spawnPoint.height,
              ),
            );
            add(spike);
            break;
          default:
            dev.log('Unknown spawn point type: ${spawnPoint.type}');
        }
      }
    }
  }

  // Добавление слоя коллизий
  void _addCollisions() {
    final collisionsLayer = level.tileMap.getLayer<ObjectGroup>('collisions');
    if (collisionsLayer != null) {
      for (final collision in collisionsLayer.objects) {
        switch (collision.class_) {
          case 'platform':
            final platform = CollisionBlock(
              position: Vector2(
                collision.x,
                collision.y,
              ),
              size: Vector2(
                collision.width,
                collision.height,
              ),
              isPlatform: true,
            );
            collisionBlocks.add(platform);
            add(platform);
            break;
          default:
            final block = CollisionBlock(
              position: Vector2(
                collision.x,
                collision.y,
              ),
              size: Vector2(
                collision.width,
                collision.height,
              ),
            );
            collisionBlocks.add(block);
            add(block);
        }
      }
    }
    player.collisionBlocks = collisionBlocks;
  }

  // Добавление скроллящегося фона
  void _scrollingBackground() {
    final backgroundLayer = level.tileMap.getLayer<TileLayer>('background');

    if (backgroundLayer != null) {
      final backgroundColor =
          backgroundLayer.properties.getValue('backgroundColor');
      final backgroundTile = BackGroundTile(
        color: backgroundColor ?? 'Blue',
        position: Vector2(
          0,
          0,
        ),
      );
      add(backgroundTile);
    }
  }
}
