import 'dart:async';
import 'dart:developer';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:lode_runner/actors/player.dart';

class Level extends World {
  late TiledComponent level;

  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load(
      'level_01.tmx',
      Vector2.all(16),
    );
    add(level);
    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>('spawnpoints');
    for (final spawnPoint in spawnPointsLayer!.objects) {
      switch (spawnPoint.type) {
        case 'player':
          final player = Player(position: Vector2(spawnPoint.x, spawnPoint.y));
          // log('Player spawned at $player');
          add(player);
          break;
        default:
          log('Unknown spawn point type: ${spawnPoint.type}');
      }
    }
    return super.onLoad();
  }
}
