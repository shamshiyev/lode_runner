import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class CollisionBlock extends PositionComponent with CollisionCallbacks {
  CollisionBlock({
    super.position,
    super.size,
    this.isPlatform = false,
  }) {
    // Дебагмод для отображения координат блоков
    debugMode = true;
    debugColor = Colors.amber.withOpacity(0.0);
  }
  bool isPlatform;
  @override
  FutureOr<void> onLoad() {
    // TODO: Maybe add a relative hitbox with enlarged Y?
    /// With this constructor you define the [RectangleHitbox] in relation to
    /// the [parentSize]. For example having [relation] as of (0.8, 0.5) would
    /// create a rectangle that fills 80% of the width and 50% of the height of
    /// [parentSize].
    // RectangleHitbox.relative(
    add(
      RectangleHitbox(
        priority: 100,
      ),
    );
    return super.onLoad();
  }
}
