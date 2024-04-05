import 'dart:async';
import 'dart:developer';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:lode_runner/components/actors/player.dart';
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

  // Добавление точек спавна
  void _spawningObjects() {
    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>('spawnpoints');
    if (spawnPointsLayer != null) {
      for (final spawnPoint in spawnPointsLayer.objects) {
        switch (spawnPoint.type) {
          case 'player':
            player.position = Vector2(
              spawnPoint.x,
              spawnPoint.y,
            );
            add(player);
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

  void _scrollingBackground() {
    final backgroundLayer = level.tileMap.getLayer<TileLayer>('background');
    const tileSize = 64;
    final numTilesY = (game.size.y / tileSize).floor();
    final numTilesX = (game.size.x / tileSize).floor();
    if (backgroundLayer != null) {
      final backgroundColor =
          backgroundLayer.properties.getValue('backgroundColor');
      for (double y = 0; y < numTilesY; y++) {
        for (double x = 0; x < numTilesX; x++) {
          final backgroundTile = BackGroundTile(
            color: backgroundColor ?? 'Gray',
            position: Vector2(
              x * tileSize,
              y * tileSize - tileSize,
            ),
          );
          add(backgroundTile);
        }
      }
    }
  }
}
