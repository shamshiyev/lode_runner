import 'package:flame/components.dart';

class Chain extends SpriteComponent {
  Chain({
    super.position,
    super.size,
  });

  @override
  Future<void> onLoad() async {
    priority = -10;
    sprite = await Sprite.load('Traps/Saw/Chain.png');
    return super.onLoad();
  }
}
