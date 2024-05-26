import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/painting.dart';

class BackGroundTile extends ParallaxComponent {
  BackGroundTile({
    super.position,
    this.color = 'Gray',
  });

  final String color;
  final double scrollSpeed = 40;

  @override
  Future<void> onLoad() async {
    // Размещаем фон на заднем плане
    priority = -10;
    size = Vector2.all(64);
    parallax = await game.loadParallax(
      [ParallaxImageData('Background/$color.png')],
      baseVelocity: Vector2(-scrollSpeed, -scrollSpeed / 2),
      repeat: ImageRepeat.repeat,
      fill: LayerFill.none,
    );
    return super.onLoad();
  }
}
