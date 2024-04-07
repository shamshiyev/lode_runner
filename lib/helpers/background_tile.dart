import 'package:flame/components.dart';
import 'package:lode_runner/lode_runner.dart';

class BackGroundTile extends SpriteComponent with HasGameRef<LodeRunner> {
  final String color;
  BackGroundTile({
    super.position,
    this.color = 'Gray',
  });

  final double scrollSpeed = 0.8;

  @override
  Future<void> onLoad() async {
    // Размещаем фон на заднем плане
    priority = -1;
    size = Vector2.all(64.6);
    sprite = Sprite(game.images.fromCache('Background/$color.png'));
    return super.onLoad();
  }

  @override
  void update(double dt) {
    position.y += scrollSpeed;
    // TODO: Maybe add diagonal scrolling
    double tileSize = 64;
    int scrollHeight = (game.size.y / tileSize).floor();
    if (position.y > tileSize * scrollHeight) {
      position.y = -tileSize;
    }
    super.update(dt);
  }
}
