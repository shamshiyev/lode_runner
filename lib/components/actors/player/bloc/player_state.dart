// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'player_bloc.dart';

class StatePlayerBloc extends Equatable {
  const StatePlayerBloc({
    required this.player,
    required this.position,
    required this.velocity,
    this.isOnGround = true,
    this.hasJumped = false,
    this.isSliding = false,
    this.hasDoubleJumped = false,
    this.gotHit = false,
    this.reachedCheckpoint = false,
    this.horizontalSpeed = 0,
  });

  final Player player;
  final Vector2 position;
  final Vector2 velocity;
  final bool isOnGround;
  final bool hasJumped;
  final bool isSliding;
  final bool hasDoubleJumped;
  final bool gotHit;
  final bool reachedCheckpoint;
  final int horizontalSpeed;

  @override
  List<Object> get props => [
        player,
        position,
        velocity,
        isOnGround,
        hasJumped,
        isSliding,
        hasDoubleJumped,
        gotHit,
        reachedCheckpoint,
        horizontalSpeed,
      ];

  StatePlayerBloc copyWith({
    Player? player,
    Vector2? position,
    Vector2? velocity,
    bool? isOnGround,
    bool? hasJumped,
    bool? isSliding,
    bool? hasDoubleJumped,
    bool? gotHit,
    bool? reachedCheckpoint,
    int? horizontalSpeed,
  }) {
    return StatePlayerBloc(
      player: player ?? this.player,
      position: position ?? this.position,
      velocity: velocity ?? this.velocity,
      isOnGround: isOnGround ?? this.isOnGround,
      hasJumped: hasJumped ?? this.hasJumped,
      isSliding: isSliding ?? this.isSliding,
      hasDoubleJumped: hasDoubleJumped ?? this.hasDoubleJumped,
      gotHit: gotHit ?? this.gotHit,
      reachedCheckpoint: reachedCheckpoint ?? this.reachedCheckpoint,
      horizontalSpeed: horizontalSpeed ?? this.horizontalSpeed,
    );
  }
}

final class PlayerInitialState extends StatePlayerBloc {
  const PlayerInitialState({
    required super.player,
    required super.position,
    required super.velocity,
  });
}

final class PlayerActiveState extends StatePlayerBloc {
  const PlayerActiveState({
    required super.player,
    required super.position,
    required super.velocity,
    required super.isOnGround,
    required super.hasJumped,
    required super.isSliding,
    required super.hasDoubleJumped,
    required super.gotHit,
    required super.reachedCheckpoint,
    required super.horizontalSpeed,
  });

  @override
  String toString() {
    return 'PlayerActiveState('
        'player: $player, '
        'position: $position, '
        'velocity: $velocity, '
        'isOnGround: $isOnGround, '
        'hasJumped: $hasJumped, '
        'isSliding: $isSliding, '
        'hasDoubleJumped: $hasDoubleJumped, '
        'gotHit: $gotHit, '
        'reachedCheckpoint: $reachedCheckpoint, '
        'horizontalSpeed: $horizontalSpeed'
        ')';
  }

  @override
  PlayerActiveState copyWith({
    Player? player,
    Vector2? position,
    Vector2? velocity,
    bool? isOnGround,
    bool? hasJumped,
    bool? isSliding,
    bool? hasDoubleJumped,
    bool? gotHit,
    bool? reachedCheckpoint,
    int? horizontalSpeed,
  }) {
    return PlayerActiveState(
      player: player ?? this.player,
      position: position ?? this.position,
      velocity: velocity ?? this.velocity,
      isOnGround: isOnGround ?? this.isOnGround,
      hasJumped: hasJumped ?? this.hasJumped,
      isSliding: isSliding ?? this.isSliding,
      hasDoubleJumped: hasDoubleJumped ?? this.hasDoubleJumped,
      gotHit: gotHit ?? this.gotHit,
      reachedCheckpoint: reachedCheckpoint ?? this.reachedCheckpoint,
      horizontalSpeed: horizontalSpeed ?? this.horizontalSpeed,
    );
  }
}
