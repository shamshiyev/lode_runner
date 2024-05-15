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
    debugColor = Colors.amber;
  }
  bool isPlatform;
}

bool checkCollisions(
  player,
  block,
) {
  final hitbox = player.hitbox;
  // Позиция персонажа по оси X
  final playerX = player.position.x + hitbox.offsetX;
  // Верхняя точка игрока
  final playerY = player.position.y + hitbox.offsetY;
  final playerWidth = hitbox.width;
  final playerHeight = hitbox.height;

  // Позиция блока по оси X
  final blockX = block.x;
  // Верхняя точка блока
  final blockY = block.y;
  final blockWidth = block.width;
  final blockHeight = block.height;

  // Проверяем развернута ли модель влево
  final fixedX = player.scale.x < 0
      ? playerX - (hitbox.offsetX * 2) - playerWidth
      : playerX;

  // Коллизия с платформой при учёте высоты модели
  final fixedY = block.isPlatform ? playerY + playerHeight : playerY;

  return (
      // Коллизия по оси Y (верхняя и нижняя точка игрока и блока пересекаются)
      fixedY < blockY + blockHeight &&
          playerY + playerHeight > blockY &&
          // Коллизия по оси X
          fixedX < blockX + blockWidth &&
          fixedX + playerWidth > blockX);
}
