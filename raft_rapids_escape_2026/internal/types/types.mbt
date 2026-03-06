///|
/// Dynamic obstacle entity in the river lane.
pub(all) struct Obstacle {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut w : Float
  mut h : Float
  mut vx : Float
  mut vy : Float
  mut kind : ObstacleKind
  mut phase : Float

  fn new() -> Obstacle
}

///|
/// Collectible pickup entity in the river lane.
pub(all) struct Pickup {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut kind : PickupKind
  mut phase : Float

  fn new() -> Pickup
}

///|
/// Generic particle used for water and collision effects.
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
/// Full mutable state for one raft run.
pub(all) struct Game {
  obstacles : Array[Obstacle]
  pickups : Array[Pickup]
  particles : Array[Particle]
  mut state : GameState
  mut raft_x : Float
  mut raft_y : Float
  mut raft_vx : Float
  mut raft_vy : Float
  mut move_x : Float
  mut move_y : Float
  mut lives : Int
  mut shield_t : Float
  mut fuel : Float
  mut boost_on : Bool
  mut score : Int
  mut best_score : Int
  mut distance : Int
  mut level : Int
  mut combo : Int
  mut combo_t : Float
  mut spawn_t : Float
  mut pickup_t : Float
  mut game_t : Float
  mut ui_t : Float
  mut hint_left : Int
  mut hint_t : Float
  mut hint_x : Float
  mut hint_y : Float
  mut msg : String
  mut msg_t : Float
  mut shake_t : Float
  mut touch_cd : Float
  mut win : Bool
  mut mouse_x : Float
  mut mouse_y : Float
  mut mouse_hold : Bool
  mut touch_count : Int

  fn new() -> Game
}

///|
/// Create an inactive obstacle slot.
#deprecated
pub fn Obstacle::new() -> Obstacle {
  {
    active: false,
    x: 0.0,
    y: 0.0,
    w: 0.0,
    h: 0.0,
    vx: 0.0,
    vy: 0.0,
    kind: Rock,
    phase: 0.0,
  }
}

///|
/// Create an inactive pickup slot.
#deprecated
pub fn Pickup::new() -> Pickup {
  { active: false, x: 0.0, y: 0.0, kind: Coin, phase: 0.0 }
}

///|
/// Create an inactive particle slot.
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
    kind: Water,
  }
}

///|
/// Build a new run in title state with empty object pools.
#deprecated
pub fn Game::new() -> Game {
  {
    obstacles: Array::makei(max_obstacles, fn(_i) { Obstacle() }),
    pickups: Array::makei(max_pickups, fn(_i) { Pickup() }),
    particles: Array::makei(max_particles, fn(_i) { Particle() }),
    state: Title,
    raft_x: Float::from_int(world_x0 + world_w / 2),
    raft_y: Float::from_int(world_y0 + world_h - 180),
    raft_vx: 0.0,
    raft_vy: 0.0,
    move_x: 0.0,
    move_y: 0.0,
    lives: 3,
    shield_t: 0.0,
    fuel: 100.0,
    boost_on: false,
    score: 0,
    best_score: 0,
    distance: 0,
    level: 1,
    combo: 0,
    combo_t: 0.0,
    spawn_t: 0.0,
    pickup_t: 0.0,
    game_t: 0.0,
    ui_t: 0.0,
    hint_left: 3,
    hint_t: 0.0,
    hint_x: 0.0,
    hint_y: 0.0,
    msg: "",
    msg_t: 0.0,
    shake_t: 0.0,
    touch_cd: 0.0,
    win: false,
    mouse_x: 0.0,
    mouse_y: 0.0,
    mouse_hold: false,
    touch_count: 0,
  }
}
