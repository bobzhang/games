///|
/// Aggregated input state for one frame.
pub(all) struct Input {
  move_left : Bool
  move_right : Bool
  jump_pressed : Bool
  jump_held : Bool
  accept : Bool
  restart : Bool
}

///|
/// Mutable player runtime state.
pub(all) struct Player {
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut facing : Int
  mut on_ground : Bool
  mut coyote_t : Float
  mut jump_buf_t : Float
  mut invuln_t : Float
  mut lives : Int
  mut coins : Int
  mut score : Int
  mut reached_flag : Bool
  mut flag_phase : Int
}

///|
/// Creates a player with default movement and score state.
pub fn Player::new() -> Player {
  {
    x: player_start_x,
    y: 0.0,
    vx: 0.0,
    vy: 0.0,
    facing: 1,
    on_ground: false,
    coyote_t: 0.0,
    jump_buf_t: 0.0,
    invuln_t: 0.0,
    lives: 3,
    coins: 0,
    score: 0,
    reached_flag: false,
    flag_phase: 0,
  }
}

///|
/// Runtime enemy record.
pub(all) struct Enemy {
  mut active : Bool
  mut squashed : Bool
  mut squash_t : Float
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut dir : Int
}

///|
/// Creates an inactive enemy slot.
pub fn Enemy::inactive() -> Enemy {
  {
    active: false,
    squashed: false,
    squash_t: 0.0,
    x: 0.0,
    y: 0.0,
    vx: 0.0,
    vy: 0.0,
    dir: -1,
  }
}

///|
/// Creates an active enemy at position `x,y` moving in `dir`.
pub fn Enemy::spawn(x : Float, y : Float, dir : Int) -> Enemy {
  {
    active: true,
    squashed: false,
    squash_t: 0.0,
    x,
    y,
    vx: enemy_speed * Float::from_int(dir),
    vy: 0.0,
    dir,
  }
}

///|
/// Runtime coin record.
pub(all) struct Coin {
  mut active : Bool
  x : Float
  mut y : Float
  base_y : Float
  mut phase : Float
}

///|
/// Creates an inactive coin slot.
pub fn Coin::inactive() -> Coin {
  { active: false, x: 0.0, y: 0.0, base_y: 0.0, phase: 0.0 }
}

///|
/// Creates an active coin with initial bobbing phase.
pub fn Coin::spawn(x : Float, y : Float, phase : Float) -> Coin {
  { active: true, x, y, base_y: y, phase }
}

///|
/// Runtime particle record used by simple burst effects.
pub(all) struct Particle {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut life : Float
  mut max_life : Float
  mut size : Float
  mut color : @raylib.Color
}

///|
/// Creates an inactive particle slot.
pub fn Particle::inactive() -> Particle {
  {
    active: false,
    x: 0.0,
    y: 0.0,
    vx: 0.0,
    vy: 0.0,
    life: 0.0,
    max_life: 1.0,
    size: 1.0,
    color: @raylib.white,
  }
}

///|
/// Global mutable game state for the Mario-lite loop.
pub(all) struct Game {
  mut state : GameState
  mut elapsed : Float
  mut time_accum : Float
  mut time_left : Int
  mut camera_x : Float
  mut flag_x : Float
  mut flag_top_y : Float
  mut flag_bottom_y : Float
  mut castle_x : Float
  mut start_y : Float
  mut shake_t : Float
  tiles : Array[Tile]
  player : Player
  enemies : Array[Enemy]
  coins : Array[Coin]
  particles : Array[Particle]
}

///|
/// Creates a fresh game state with allocated tile/entity pools.
pub fn Game::new() -> Game {
  {
    state: Title,
    elapsed: 0.0,
    time_accum: 0.0,
    time_left: start_time_seconds,
    camera_x: 0.0,
    flag_x: 0.0,
    flag_top_y: 0.0,
    flag_bottom_y: 0.0,
    castle_x: 0.0,
    start_y: 0.0,
    shake_t: 0.0,
    tiles: Array::make(world_tiles_w * world_tiles_h, Empty),
    player: Player::new(),
    enemies: Array::makei(max_enemies, fn(_i) { Enemy::inactive() }),
    coins: Array::makei(max_coins, fn(_i) { Coin::inactive() }),
    particles: Array::makei(max_particles, fn(_i) { Particle::inactive() }),
  }
}
