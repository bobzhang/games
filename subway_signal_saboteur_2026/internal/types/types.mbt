///|
/// High-level phase of the game loop.
pub(all) enum GameState {
  Title
  Play
  Result
} derive(Eq)

///|
/// Tile type stored in the subway board grid.
pub(all) enum Tile {
  Void
  Floor
  Track
  Wall
} derive(Eq)

///|
/// Current AI behavior mode for an inspector.
pub(all) enum InspectorMode {
  Patrol
  Hunt
  Stunned
} derive(Eq)

///|
/// Visual effect category for pooled particles.
pub(all) enum ParticleKind {
  Spark
  Gold
  Smoke
} derive(Eq)

///|
/// Lane color tag used by trains and route goals.
pub(all) enum TrainColor {
  Red
  Blue
  Green
} derive(Eq)

///|
/// Grid actor with tile coordinates and interpolation state.
pub(all) struct Actor {
  mut x : Int
  mut y : Int
  mut from_x : Int
  mut from_y : Int
  mut to_x : Int
  mut to_y : Int
  mut fx : Float
  mut fy : Float
  mut t : Float
  mut moving : Bool

  fn new() -> Actor
}

///|
/// Moving train instance tracked on a lane and junction path.
pub(all) struct Train {
  mut active : Bool
  mut x : Float
  mut prev_x : Float
  mut lane : Int
  mut target_lane : Int
  mut speed : Float
  mut passed_junction : Int
  mut color_id : TrainColor

  fn new() -> Train
}

///|
/// Inspector entity that patrols and can be stunned by EMP.
pub(all) struct Inspector {
  mut active : Bool
  body : Actor
  mut mode : InspectorMode
  mut move_cd : Float
  mut dir_x : Int
  mut path_y : Int
  mut path_min_x : Int
  mut path_max_x : Int
  mut stun_t : Float
  mut seed : Int
  mut alert_t : Float

  fn new() -> Inspector
}

///|
/// Particle instance used for score, spark, and smoke effects.
pub(all) struct Particle {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut life : Float
  mut size : Float
  mut kind : ParticleKind

  fn new() -> Particle
}

///|
/// Complete mutable game state for one subway run.
pub(all) struct Game {
  map : Array[Tile]
  switch_state : Array[Int]
  trains : Array[Train]
  inspectors : Array[Inspector]
  particles : Array[Particle]
  mut state : GameState
  player : Actor
  mut lives : Int
  mut score : Int
  mut best_score : Int
  mut routed_ok : Int
  mut routed_bad : Int
  mut collisions : Int
  mut spawn_t : Float
  mut slow_t : Float
  mut time_left : Float
  mut req_dx : Int
  mut req_dy : Int
  mut action_down : Bool
  mut action_pressed : Bool
  mut move_cd : Float
  mut action_cd : Float
  mut emp_energy : Float
  mut touch_cd : Float
  mut msg : String
  mut msg_t : Float
  mut flash_t : Float
  mut shake_t : Float
  mut time_s : Float
  mut hint_i : Int
  mut win : Bool
  mut loss_reason : String
  mut mouse_x : Float
  mut mouse_y : Float
  mut mouse_hold : Bool
  mut touch_count : Int

  fn new() -> Game
}

///|
/// Creates a player actor initialized at the configured start cell.
#deprecated
pub fn Actor::new() -> Actor {
  {
    x: start_x,
    y: start_y,
    from_x: start_x,
    from_y: start_y,
    to_x: start_x,
    to_y: start_y,
    fx: Float::from_int(start_x),
    fy: Float::from_int(start_y),
    t: 1.0,
    moving: false,
  }
}

///|
/// Creates an inactive train entry for the train object pool.
#deprecated
pub fn Train::new() -> Train {
  {
    active: false,
    x: 0.0,
    prev_x: 0.0,
    lane: 0,
    target_lane: 0,
    speed: 0.0,
    passed_junction: -1,
    color_id: Red,
  }
}

///|
/// Creates an inactive inspector with default patrol parameters.
#deprecated
pub fn Inspector::new() -> Inspector {
  {
    active: false,
    body: Actor(),
    mode: Patrol,
    move_cd: 0.0,
    dir_x: 1,
    path_y: 2,
    path_min_x: 1,
    path_max_x: 1,
    stun_t: 0.0,
    seed: 1,
    alert_t: 0.0,
  }
}

///|
/// Creates an inactive particle entry for the particle pool.
#deprecated
pub fn Particle::new() -> Particle {
  {
    active: false,
    x: 0.0,
    y: 0.0,
    vx: 0.0,
    vy: 0.0,
    life: 0.0,
    size: 0.0,
    kind: Spark,
  }
}

///|
/// Creates a new game state with initialized pools and counters.
#deprecated
pub fn Game::new() -> Game {
  {
    map: Array::make(grid_w * grid_h, Void),
    switch_state: Array::make(junction_n, 0),
    trains: Array::makei(max_trains, fn(_i) { Train() }),
    inspectors: Array::makei(max_inspectors, fn(_i) { Inspector() }),
    particles: Array::makei(max_particles, fn(_i) { Particle() }),
    state: Title,
    player: Actor(),
    lives: max_lives,
    score: 0,
    best_score: 0,
    routed_ok: 0,
    routed_bad: 0,
    collisions: 0,
    spawn_t: 0.0,
    slow_t: 0.0,
    time_left: round_time_limit,
    req_dx: 0,
    req_dy: 0,
    action_down: false,
    action_pressed: false,
    move_cd: 0.0,
    action_cd: 0.0,
    emp_energy: 100.0,
    touch_cd: 0.0,
    msg: "",
    msg_t: 0.0,
    flash_t: 0.0,
    shake_t: 0.0,
    time_s: 0.0,
    hint_i: 0,
    win: false,
    loss_reason: "",
    mouse_x: 0.0,
    mouse_y: 0.0,
    mouse_hold: false,
    touch_count: 0,
  }
}
