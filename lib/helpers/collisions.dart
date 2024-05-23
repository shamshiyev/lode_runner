import 'dart:async';
import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class CollisionBlock extends PositionComponent with CollisionCallbacks {
  CollisionBlock({
    super.position,
    super.size,
    this.isPlatform = false,
  });
  bool isPlatform;

  @override
  FutureOr<void> onLoad() {
    add(
      RectangleHitbox(),
    );
    return super.onLoad();
  }
}

List<double> checkCollisions(player, block) {
  final hitbox = player.hitbox;
  final playerX = player.position.x + hitbox.offsetX;
  final playerY = player.position.y + hitbox.offsetY;
  final playerWidth = hitbox.width;
  final playerHeight = hitbox.height;

  final blockX = block.x;
  final blockY = block.y;
  final blockWidth = block.width;
  final blockHeight = block.height;

  final fixedX = player.scale.x < 0
      ? playerX - (hitbox.offsetX * 2) - playerWidth
      : playerX;
  // final fixedY = block.isPlatform ? playerY + playerHeight : playerY;

  double overlapX = max(
    0,
    min<double>(fixedX + playerWidth, blockX + blockWidth) -
        max(
          fixedX,
          blockX,
        ),
  );
  double overlapY = max(
    0,
    min<double>(playerY + playerHeight, blockY + blockHeight) -
        max(
          playerY,
          blockY,
        ),
  );

  return [
    overlapX,
    overlapY,
  ];
}
