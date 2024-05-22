import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:lode_runner/components/actors/enemies/types/pig.dart';
import '../../../lode_runner.dart';
import '../player/player.dart';
import 'types/blue_bird.dart';
import 'types/plant.dart';

abstract class Enemy extends SpriteAnimationGroupComponent
    with HasGameRef<LodeRunner>, CollisionCallbacks {
  Enemy({
    required super.position,
    required super.size,
    this.offNeg,
    this.offPos,
  });

  final double? offNeg;
  final double? offPos;

  Vector2 get textureSize;
  double get moveSpeed;
  late final Player player;

  SpriteAnimation spriteAnimation(String src, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache(
        src,
      ),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: Enemy.stepTime,
        textureSize: textureSize,
      ),
    );
  }

  static const double stepTime = 0.05;
  static const tileSize = 16;

  void loadAllAnimations();
  void updateAnimation();
  void collidedWithPlayer();
  void updateEnemyState(double dt);
  void removeOffScreen();
}

class EnemyFactory {
  static Enemy createEnemy(
    String type, {
    required Vector2 position,
    required Vector2 size,
    double? offNeg,
    double? offPos,
    bool? reversed,
  }) {
    switch (type) {
      case 'pig':
        return Pig(
          position: position,
          size: size,
          offNeg: offNeg,
          offPos: offPos,
        );
      case 'bluebird':
        return BlueBird(
          position: position,
          size: size,
          offNeg: offNeg,
          offPos: offPos,
        );
      case 'plant':
        return Plant(
          position: position,
          size: size,
          reversed: reversed ?? false,
        );
      // case 'RedEnemy':
      //   return RedEnemy(position: position, size: size);
      default:
        throw Exception('Invalid enemy type: $type');
    }
  }
}
