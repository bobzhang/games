///|
/// Enumerates high-level states in the game flow.
pub(all) enum GameState {
  Title
  Play
  StageClear
  GameOver
} derive(Eq)

///|
/// Enumerates EntityKind variants used by runtime state.
pub(all) enum EntityKind {
  FoeBike
  FoeDrone
  FoeTruck
  FoeLaser
  ItemCredit
  ItemBattery
  ItemHackcell
} derive(Eq)

///|
/// Stores runtime data for Entity.
pub(all) struct Entity {
  mut active : Bool
  mut kind : EntityKind
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut w : Float
  mut h : Float
  mut hp : Float
  mut shot_cd : Float
  mut spin : Float
  mut cloak : Bool
  mut reward : Int

  fn new() -> Entity
}

///|
/// Stores runtime data for Bullet.
pub(all) struct Bullet {
  mut active : Bool
  mut from_player : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut life : Float
  mut dmg : Float
  mut kind : Int

  fn new() -> Bullet
}

///|
/// Stores runtime data for Spark.
pub(all) struct Spark {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut life : Float
  mut size : Float
  mut kind : Int

  fn new() -> Spark
}

///|
/// Stores runtime data for GlowRing.
pub(all) struct GlowRing {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut r : Float
  mut life : Float
  mut kind : Int

  fn new() -> GlowRing
}

///|
/// Stores runtime data for Afterimage.
pub(all) struct Afterimage {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut w : Float
  mut h : Float
  mut rot : Float
  mut life : Float
  mut kind : Int

  fn new() -> Afterimage
}

///|
/// Stores runtime data for Player.
pub(all) struct Player {
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut w : Float
  mut h : Float
  mut heading : Float
  mut invuln : Float
  mut hurt_t : Float
  mut muzzle_t : Float
  mut engine_t : Float

  fn new() -> Player
}

///|
/// Aggregates all mutable state needed to run one game session.
pub(all) struct Game {
  entities : Array[Entity]
  bullets : Array[Bullet]
  sparks : Array[Spark]
  rings : Array[GlowRing]
  images : Array[Afterimage]
  hero : Player
  mut state : GameState
  mut stage : Int
  mut distance : Float
  mut stage_goal : Float
  mut score : Int
  mut best_score : Int
  mut credits : Int
  mut kills : Int
  mut combo : Int
  mut combo_t : Float
  mut shield : Float
  mut energy : Float
  mut fire_cd : Float
  mut boost_cd : Float
  mut boost_t : Float
  mut hack_cd : Float
  mut hack_t : Float
  mut time_s : Float
  mut flash_t : Float
  mut shake_t : Float
  mut result_t : Float
  mut hint_t : Float
  mut scroll_speed : Float
  mut next_spawn_y : Float
  mut input_x : Float
  mut input_y : Float
  mut input_fire_hold : Bool
  mut input_boost_press : Bool
  mut input_hack_press : Bool
  mut input_restart_press : Bool
  mut touch_mode : Bool
  mut touch_boost_prev : Bool
  mut touch_hack_prev : Bool
  mut touch_restart_prev : Bool
  mut mouse_x : Float
  mut mouse_y : Float
  mut mouse_hold : Bool
  mut touch_count : Int

  fn new() -> Game
}

///|
/// Creates a default Entity value for a new session.
#deprecated
pub fn Entity::new() -> Entity {
  {
    active: false,
    kind: FoeBike,
    x: 0.0,
    y: 0.0,
    vx: 0.0,
    vy: 0.0,
    w: 0.0,
    h: 0.0,
    hp: 0.0,
    shot_cd: 0.0,
    spin: 0.0,
    cloak: false,
    reward: 0,
  }
}

///|
/// Creates a default Bullet value for a new session.
#deprecated
pub fn Bullet::new() -> Bullet {
  {
    active: false,
    from_player: true,
    x: 0.0,
    y: 0.0,
    vx: 0.0,
    vy: 0.0,
    life: 0.0,
    dmg: 0.0,
    kind: 0,
  }
}

///|
/// Creates a default Spark value for a new session.
#deprecated
pub fn Spark::new() -> Spark {
  {
    active: false,
    x: 0.0,
    y: 0.0,
    vx: 0.0,
    vy: 0.0,
    life: 0.0,
    size: 0.0,
    kind: 0,
  }
}

///|
/// Creates a default GlowRing value for a new session.
#deprecated
pub fn GlowRing::new() -> GlowRing {
  { active: false, x: 0.0, y: 0.0, r: 0.0, life: 0.0, kind: 0 }
}

///|
/// Creates a default Afterimage value for a new session.
#deprecated
pub fn Afterimage::new() -> Afterimage {
  {
    active: false,
    x: 0.0,
    y: 0.0,
    w: 0.0,
    h: 0.0,
    rot: 0.0,
    life: 0.0,
    kind: 0,
  }
}

///|
/// Creates a default Player value for a new session.
#deprecated
pub fn Player::new() -> Player {
  {
    x: Float::from_int(screen_w / 2),
    y: Float::from_int(screen_h) * 0.76,
    vx: 0.0,
    vy: 0.0,
    w: player_w,
    h: player_h,
    heading: 0.0,
    invuln: 0.0,
    hurt_t: 0.0,
    muzzle_t: 0.0,
    engine_t: 0.0,
  }
}

///|
/// Creates a default Game value for a new session.
#deprecated
pub fn Game::new() -> Game {
  {
    entities: Array::makei(max_entities, fn(_i) { Entity() }),
    bullets: Array::makei(max_bullets, fn(_i) { Bullet() }),
    sparks: Array::makei(max_sparks, fn(_i) { Spark() }),
    rings: Array::makei(max_glow_rings, fn(_i) { GlowRing() }),
    images: Array::makei(max_afterimages, fn(_i) { Afterimage() }),
    hero: Player(),
    state: Title,
    stage: 1,
    distance: 0.0,
    stage_goal: stage_distance_base,
    score: 0,
    best_score: 0,
    credits: 0,
    kills: 0,
    combo: 0,
    combo_t: 0.0,
    shield: player_shield_max,
    energy: player_energy_max,
    fire_cd: 0.0,
    boost_cd: 0.0,
    boost_t: 0.0,
    hack_cd: 0.0,
    hack_t: 0.0,
    time_s: 0.0,
    flash_t: 0.0,
    shake_t: 0.0,
    result_t: 0.0,
    hint_t: 0.0,
    scroll_speed: base_scroll_speed,
    next_spawn_y: spawn_start_y,
    input_x: 0.0,
    input_y: 0.0,
    input_fire_hold: false,
    input_boost_press: false,
    input_hack_press: false,
    input_restart_press: false,
    touch_mode: false,
    touch_boost_prev: false,
    touch_hack_prev: false,
    touch_restart_prev: false,
    mouse_x: 0.0,
    mouse_y: 0.0,
    mouse_hold: false,
    touch_count: 0,
  }
}
