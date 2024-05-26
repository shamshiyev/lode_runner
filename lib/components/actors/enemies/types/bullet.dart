import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:lode_runner/components/actors/player/player.dart';
import 'package:lode_runner/helpers/collisions.dart';

import '../../player/bloc/player_bloc.dart';

class Bullet extends SpriteComponent with CollisionCallbacks {
  Bullet({
    super.position,
    super.size,
    required this.speed,
    required this.bulletSprite,
    required this.playerBloc,
    this.directionRight = false,
  });

  final Sprite bulletSprite;
  final bool directionRight;
  final PlayerBloc playerBloc;
  final double speed;

  @override
  void onCollision(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    if (other is CollisionBlock) {
      // TODO: In future some particle effects would be nice here
      removeFromParent();
    }
    if (other is Player) {
      playerBloc.add(const PlayerHitEvent());
      removeFromParent();
    }
    super.onCollision(intersectionPoints, other);
  }

  @override
  FutureOr<void> onLoad() {
    add(
      CircleHitbox(
        position: Vector2.all(4),
        radius: 4,
      ),
    );
    sprite = bulletSprite;
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (directionRight) {
      position.x += speed * dt;
    } else {
      position.x -= speed * dt;
    }
    super.update(dt);
  }
}
