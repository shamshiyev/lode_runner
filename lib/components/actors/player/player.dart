import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:flutter/services.dart';
import 'package:lode_runner/components/actors/player/bloc/player_bloc.dart';
import 'package:lode_runner/components/collectable.dart';
import 'package:lode_runner/utilities/animations.dart';
import 'package:lode_runner/utilities/collisions.dart';
import 'package:lode_runner/lode_runner.dart';

import '../../../utilities/hitbox.dart';

enum PlayerAnimationState {
  idle,
  run,
  jump,
  fall,
  hit,
  doubleJump,
  wallJump,
  appearing,
  disappearing,
}

class Player extends SpriteAnimationGroupComponent
    with
        HasGameRef<LodeRunner>,
        KeyboardHandler,
        CollisionCallbacks,
        FlameBlocListenable<PlayerBloc, StatePlayerBloc> {
  Player({
    super.position,
  });

  // Скорость всех анимаций
  static const double stepTime = 0.05;

  late final SpriteAnimation doubleJump;
  late final SpriteAnimation fall;
  late final SpriteAnimation hit;
  late final SpriteAnimation idle;
  late final SpriteAnimation jump;
  late final SpriteAnimation run;
  late final SpriteAnimation wallJump;
  late final SpriteAnimation appearing;
  late final SpriteAnimation disappearing;

  Vector2 velocity = Vector2.zero();
  // Скорость скольжения по стене

  bool isOnGround = true;
  bool hasJumped = false;
  bool isSliding = false;
  bool hasDoubleJumped = false;
  bool gotHit = false;
  bool reachedCheckpoint = false;

  List<CollisionBlock> collisionBlocks = [];
  // Хитбокс игрока
  CustomHitbox hitbox = CustomHitbox(
    offsetX: 10,
    // This sets the hitbox bottom
    offsetY: 4,
    width: 14,
    height: 28,
  );
  double fixedDeltaTime = 1 / 60;
  double accumulatedTime = 0;

  @override
  Future<void> onLoad() async {
    // Finding out this parameter'importancy cost me 4 days of my life
    // anchor = Anchor.topCenter;
    _loadAllAnimations();
    // Отображение хитбокса
    debugColor = const Color(0xFFFF0000).withOpacity(0.0);
    add(
      RectangleHitbox(
        priority: 100,
        size: Vector2(hitbox.width, hitbox.height),
        position: Vector2(hitbox.offsetX, hitbox.offsetY),
      ),
    );
    debugMode = true;
    return super.onLoad();
  }

  @override
  onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    bloc.add(
      PlayerKeyPressedEvent(keysPressed: keysPressed, keyEvent: event),
    );
    return false;
  }

  @override
  void onNewState(StatePlayerBloc state) {
    position = state.position;
    velocity = state.velocity;
    super.onNewState(state);
  }

  @override
  void onCollision(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    if (other is CollisionBlock) {
      bloc.add(PlayerCollisionEvent(other));
    }
    super.onCollision(intersectionPoints, other);
  }

  // Коллизия с подбираемыми объектами
  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (!reachedCheckpoint) {
      if (other is Collectable) {
        other.collidingWithPlayer();
      }
      // if (other is Saw || other is Spike) {
      //   _respawn();
      // }
      // if (other is Checkpoint) {
      //   _reachedCheckPoint();
      // }
      // if (other is Enemy) {
      //   other.collidedWithPlayer();
      // }
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  @override
  void update(double dt) {
    accumulatedTime += dt;
    while (accumulatedTime >= fixedDeltaTime) {
      if (!gotHit && !reachedCheckpoint) {
        bloc.add(PlayerChangeAnimationEvent());
        bloc.add(PlayerUpdateDirectionEvent(deltaTime: fixedDeltaTime));
        // _checkHorizontalCollisions();
        // bloc.add(PlayerApplyGravityEvent(deltaTime: fixedDeltaTime));
        // _checkVerticalCollisions();
      }
      accumulatedTime -= fixedDeltaTime;
    }

    super.update(dt);
  }

  void _loadAllAnimations() {
    // Базовый метод
    SpriteAnimation spriteAnimation({
      required String src,
      required int frameAmount,
    }) {
      return SpriteAnimation.fromFrameData(
        gameRef.images.fromCache(
          src,
        ),
        SpriteAnimationData.sequenced(
          amount: frameAmount,
          stepTime: stepTime,
          textureSize: Vector2.all(32),
        ),
      );
    }

    // Значения анимаций
    idle = spriteAnimation(
      src: ActorAnimations.idle,
      frameAmount: 11,
    );
    run = spriteAnimation(
      src: ActorAnimations.run,
      frameAmount: 12,
    );
    jump = spriteAnimation(
      src: ActorAnimations.jump,
      frameAmount: 1,
    );
    fall = spriteAnimation(
      src: ActorAnimations.fall,
      frameAmount: 1,
    );
    hit = spriteAnimation(
      src: ActorAnimations.hit,
      frameAmount: 7,
    )..loop = false;
    doubleJump = spriteAnimation(
      src: ActorAnimations.doubleJump,
      frameAmount: 6,
    );
    wallJump = spriteAnimation(
      src: ActorAnimations.wallJump,
      frameAmount: 5,
    );
    appearing = spriteAnimation(
      src: ActorAnimations.appearing,
      frameAmount: 7,
    )..loop = false;
    disappearing = spriteAnimation(
      src: ActorAnimations.disappearing,
      frameAmount: 7,
    )..loop = false;

    // Список анимаций
    animations = <PlayerAnimationState, SpriteAnimation>{
      PlayerAnimationState.idle: idle,
      PlayerAnimationState.run: run,
      PlayerAnimationState.jump: jump,
      PlayerAnimationState.fall: fall,
      PlayerAnimationState.hit: hit,
      PlayerAnimationState.doubleJump: doubleJump,
      PlayerAnimationState.wallJump: wallJump,
      PlayerAnimationState.appearing: appearing,
      PlayerAnimationState.disappearing: disappearing,
    };
  }

  // void _respawn() async {
  //   if (game.playSounds) {
  //     FlameAudio.play('hit.wav', volume: game.soundVolume);
  //   }
  //   const canMoveDuration = Duration(milliseconds: 400);
  //   gotHit = true;
  //   current = PlayerAnimationState.hit;
  //   // Дожидаемся завершения анимаций
  //   await animationTicker?.completed;
  //   animationTicker?.reset();
  //   //
  //   scale.x = 1;
  //   position = startingPosition;
  //   current = PlayerAnimationState.appearing;
  //   //
  //   await animationTicker?.completed;
  //   animationTicker?.reset();
  //   //
  //   velocity = Vector2.zero();
  //   position = startingPosition;
  //   _upDatePlayerMovement();
  //   Future.delayed(canMoveDuration, () => gotHit = false);
  // }

  // void _reachedCheckPoint() async {
  //   reachedCheckpoint = true;
  //   if (game.playSounds) {
  //     FlameAudio.play('disappear.wav', volume: game.soundVolume);
  //   }

  //   current = PlayerAnimationState.disappearing;
  //   //
  //   await animationTicker?.completed;
  //   animationTicker?.reset();
  //   //
  //   reachedCheckpoint = false;
  //   removeFromParent();
  //   Future.delayed(const Duration(seconds: 3), () => game.nextLevel());
  // }

  // void collidedWithEnemy() async {
  //   _respawn();
  // }
}
