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
    anchor = Anchor.bottomRight;

    position = Vector2(
      game.size.x - 80,
      game.size.y - 40,
    );
    return super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    gameRef.playerBloc.state.player.hasJumped = true;
    super.onTapDown(event);
  }

  @override
  void onTapUp(TapUpEvent event) {
    gameRef.playerBloc.state.player.hasJumped = false;
    super.onTapUp(event);
  }
}
