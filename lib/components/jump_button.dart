import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:lode_runner/lode_runner.dart';

class JumpButton extends SpriteComponent
    with HasGameRef<LodeRunner>, TapCallbacks {
  JumpButton();

  @override
  FutureOr<void> onLoad() {
    priority = 2;
    sprite = Sprite(game.images.fromCache('hud/jump_button.png'));
    position = Vector2(
      game.size.x - 66,
      game.size.y - 72,
    );
    return super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    game.player.hasJumped = true;
    super.onTapDown(event);
  }

  @override
  void onTapUp(TapUpEvent event) {
    game.player.hasJumped = false;
    super.onTapUp(event);
  }
}
