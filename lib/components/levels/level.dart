import 'dart:async';
import 'dart:developer';
import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:lode_runner/components/actors/player.dart';
import 'package:lode_runner/components/checkpoint.dart';
import 'package:lode_runner/components/collectable.dart';
import 'package:lode_runner/components/traps/saw.dart';
import 'package:lode_runner/helpers/background_tile.dart';
import 'package:lode_runner/helpers/collisions.dart';
import 'package:lode_runner/lode_runner.dart';

class Level extends World with HasGameRef<LodeRunner> {
  Level({
    required this.levelName,
    required this.player,
  });
  late TiledComponent level;
  final String levelName;
  final Player player;
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
            player.scale.x = 1;
            player.position = Vector2(
              spawnPoint.x,
              spawnPoint.y,
            );
            add(player);
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
            var isVertical = spawnPoint.properties.getValue('isVertical');
            var offNeg = spawnPoint.properties.getValue('offNeg');
            var offPos = spawnPoint.properties.getValue('offPos');
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
          default:
            log('Unknown spawn point type: ${spawnPoint.type}');
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
