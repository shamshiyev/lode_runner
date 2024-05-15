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
    add(
      RectangleHitbox(
        priority: 100,
      ),
    );
    return super.onLoad();
  }
}



// bool isCollisionOnX = (
//   fixedX < blockX + blockWidth &&
//   fixedX + playerWidth > blockX);

// bool isCollisionOnY = (
//   playerY < blockY + blockHeight &&
//   playerY + playerHeight > blockY);

// if (isCollisionOnX && isCollisionOnY) {
//   // Both x and y collisions detected, determine which happened first
//   double overlapX = min(
//     fixedX + playerWidth - blockX,
//     blockX + blockWidth - fixedX);
//   double overlapY = min(
//     playerY + playerHeight - blockY,
//     blockY + blockHeight - playerY);

//   if (overlapX < overlapY) {
//     // X collision happened first
//     // Handle x collision
//   } else {
//     // Y collision happened first
//     // Handle y collision
//   }
// } else if (isCollisionOnX) {
//   // Only x collision detected
//   // Handle x collision
// } else if (isCollisionOnY) {
//   // Only y collision detected
//   // Handle y collision
// }