import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:lode_runner/components/actors/enemies/types/pig.dart';

import '../../../lode_runner.dart';
import '../player/bloc/player_bloc.dart';
import 'types/blue_bird.dart';

abstract class Enemy extends SpriteAnimationGroupComponent
    with
        HasGameRef<LodeRunner>,
        CollisionCallbacks,
        FlameBlocListenable<PlayerBloc, StatePlayerBloc> {
  Enemy({
    required super.position,
    required super.size,
    this.offNeg,
    this.offPos,
  });

  final double? offNeg;
  final double? offPos;

  double get moveSpeed;

  static const double stepTime = 0.05;
  static const tileSize = 16;

  void loadAllAnimations();
  void updateAnimation();
  void collidedWithPlayer();
  void move(double dt);
}

class EnemyFactory {
  static Enemy createEnemy(
    String type, {
    required Vector2 position,
    required Vector2 size,
    double? offNeg,
    double? offPos,
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
      // case 'RedEnemy':
      //   return RedEnemy(position: position, size: size);
      default:
        throw Exception('Invalid enemy type: $type');
    }
  }
}
