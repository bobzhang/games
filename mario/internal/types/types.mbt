///|
/// Top-level game phase.
pub(all) enum GameState {
  Title
  LevelIntro
  Playing
  Paused
  LevelClear
  PlayerDied
  GameOver
  Victory
} derive(Eq)

///|
/// Mario's current power-up state.
pub(all) enum PowerState {
  Small
  Big
  Fire
} derive(Eq)

///|
/// Tile types that make up the level map.
pub(all) enum TileKind {
  Empty
  Ground
  BrickBlock
  QuestionCoin
  QuestionMushroom
  QuestionStar
  QuestionOneUp
  UsedBlock
  HiddenCoin
  HiddenOneUp
  PipeTopLeft
  PipeTopRight
  PipeBodyLeft
  PipeBodyRight
  Flagpole
  FlagTop
  CastleBlock
  CastleTop
  CastleDoor
} derive(Eq)

///|
/// Enemy varieties.
pub(all) enum EnemyKind {
  Goomba
  KoopaTroopa
  KoopaShell
} derive(Eq)

///|
/// Collectible item varieties.
pub(all) enum ItemKind {
  Mushroom
  FireFlower
  Star
  OneUp
  CoinPopup
} derive(Eq)

///|
/// Player character state.
pub(all) struct Player {
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut power : PowerState
  mut facing_right : Bool
  mut on_ground : Bool
  mut was_on_ground : Bool
  mut ducking : Bool
  mut invuln_timer : Float
  mut star_timer : Float
  mut dead : Bool
  mut death_timer : Float
  mut death_vy : Float
  mut anim_timer : Float
  mut anim_frame : Int
  mut grow_timer : Float
  mut shrink_timer : Float
  mut coyote_timer : Float
  mut jump_buffer : Float
  mut skid_timer : Float
  mut stomp_combo : Int
}

///|
/// Creates a new player at the given world position.
pub fn Player::new(spawn_x : Float, spawn_y : Float) -> Player {
  {
    x: spawn_x,
    y: spawn_y,
    vx: 0.0,
    vy: 0.0,
    power: Small,
    facing_right: true,
    on_ground: false,
    was_on_ground: false,
    ducking: false,
    invuln_timer: 0.0,
    star_timer: 0.0,
    dead: false,
    death_timer: 0.0,
    death_vy: 0.0,
    anim_timer: 0.0,
    anim_frame: 0,
    grow_timer: 0.0,
    shrink_timer: 0.0,
    coyote_timer: 0.0,
    jump_buffer: 0.0,
    skid_timer: 0.0,
    stomp_combo: 0,
  }
}

///|
/// Returns the current collision height based on power state and ducking.
pub fn Player::height(self : Player) -> Float {
  if self.power == Small {
    player_height_small
  } else if self.ducking {
    player_height_small
  } else {
    player_height_big
  }
}

///|
/// Enemy entity.
pub(all) struct Enemy {
  mut active : Bool
  mut kind : EnemyKind
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut on_ground : Bool
  mut dead : Bool
  mut dead_timer : Float
  mut squished : Bool
  mut anim_timer : Float
  mut anim_frame : Int
  mut shell_moving : Bool
  mut width : Float
  mut height : Float
}

///|
/// Creates a new enemy of the given kind.
pub fn Enemy::new(kind : EnemyKind, spawn_x : Float, spawn_y : Float) -> Enemy {
  let w : Float = match kind {
    Goomba => 40.0
    KoopaTroopa => 40.0
    KoopaShell => 40.0
  }
  let h : Float = match kind {
    Goomba => 40.0
    KoopaTroopa => 52.0
    KoopaShell => 36.0
  }
  let speed : Float = match kind {
    Goomba => goomba_speed
    KoopaTroopa => koopa_speed
    KoopaShell => 0.0
  }
  {
    active: true,
    kind,
    x: spawn_x,
    y: spawn_y,
    vx: -speed,
    vy: 0.0,
    on_ground: false,
    dead: false,
    dead_timer: 0.0,
    squished: false,
    anim_timer: 0.0,
    anim_frame: 0,
    shell_moving: false,
    width: w,
    height: h,
  }
}

///|
/// Collectible item entity.
pub(all) struct Item {
  mut active : Bool
  mut kind : ItemKind
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut on_ground : Bool
  mut emerging : Bool
  mut emerge_start_y : Float
  mut emerge_target_y : Float
}

///|
/// Creates a new item.
pub fn Item::new() -> Item {
  {
    active: false,
    kind: Mushroom,
    x: 0.0,
    y: 0.0,
    vx: 0.0,
    vy: 0.0,
    on_ground: false,
    emerging: false,
    emerge_start_y: 0.0,
    emerge_target_y: 0.0,
  }
}

///|
/// Player fireball projectile.
pub(all) struct Fireball {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
}

///|
/// Creates a new fireball.
pub fn Fireball::new() -> Fireball {
  { active: false, x: 0.0, y: 0.0, vx: 0.0, vy: 0.0 }
}

///|
/// Visual particle for effects (brick break, stomp poof, etc.).
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
  mut has_gravity : Bool
}

///|
/// Creates a new particle.
pub fn Particle::new() -> Particle {
  {
    active: false,
    x: 0.0,
    y: 0.0,
    vx: 0.0,
    vy: 0.0,
    life: 0.0,
    max_life: 0.0,
    size: 4.0,
    color: @raylib.Color::new(255, 255, 255, 255),
    has_gravity: true,
  }
}

///|
/// Floating score text that drifts upward and fades.
pub(all) struct ScorePopup {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vy : Float
  mut life : Float
  mut text : String
}

///|
/// Creates a new score popup.
pub fn ScorePopup::new() -> ScorePopup {
  { active: false, x: 0.0, y: 0.0, vy: 0.0, life: 0.0, text: "" }
}

///|
/// A block that bounces when hit from below.
pub(all) struct BumpedBlock {
  mut active : Bool
  mut tile_x : Int
  mut tile_y : Int
  mut offset_y : Float
  mut velocity : Float
}

///|
/// Creates a new bumped block tracker.
pub fn BumpedBlock::new() -> BumpedBlock {
  { active: false, tile_x: 0, tile_y: 0, offset_y: 0.0, velocity: 0.0 }
}

///|
/// Decorative background cloud.
pub(all) struct Cloud {
  mut x : Float
  mut y : Float
  mut w : Float
  mut speed : Float
}

///|
/// The entire game state.
pub(all) struct Game {
  // ── Phase ──
  mut state : GameState
  mut world_num : Int
  mut level_num : Int
  mut level_index : Int
  // ── Player ──
  player : Player
  // ── Entities ──
  enemies : Array[Enemy]
  items : Array[Item]
  fireballs : Array[Fireball]
  particles : Array[Particle]
  score_popups : Array[ScorePopup]
  bumped_blocks : Array[BumpedBlock]
  // ── Map ──
  mut map_tiles : Array[TileKind]
  mut map_width : Int
  mut map_height : Int
  // ── Camera ──
  mut camera_x : Float
  // ── HUD ──
  mut score : Int
  mut coins : Int
  mut lives : Int
  mut time_remaining : Float
  // ── Timers ──
  mut intro_timer : Float
  mut clear_timer : Float
  mut death_timer : Float
  mut game_over_timer : Float
  // ── Level-clear flag animation ──
  mut flag_y : Float
  mut flag_target_y : Float
  mut flag_done : Bool
  mut mario_auto : Bool
  mut mario_target_x : Float
  // ── Misc ──
  mut frame_counter : Int
  mut frame_times : Array[Float]
  mut frame_time_cursor : Int
  mut rng_state : Int
  // ── Decoration ──
  clouds : Array[Cloud]
}

///|
/// Creates a new game in title-screen state.
pub fn Game::new() -> Game {
  let default_frame_time : Float = Float::from_int(1) / Float::from_int(target_fps)
  {
    state: Title,
    world_num: 1,
    level_num: 1,
    level_index: 0,
    player: Player::new(120.0, 576.0),
    enemies: Array::makei(max_enemies, fn(_i) { Enemy::new(Goomba, 0.0, 0.0) }),
    items: Array::makei(max_items, fn(_i) { Item::new() }),
    fireballs: Array::makei(max_fireballs, fn(_i) { Fireball::new() }),
    particles: Array::makei(max_particles, fn(_i) { Particle::new() }),
    score_popups: Array::makei(max_score_popups, fn(_i) { ScorePopup::new() }),
    bumped_blocks: Array::makei(max_bumped_blocks, fn(_i) { BumpedBlock::new() }),
    // Keep the placeholder map internally consistent before the first level loads.
    map_tiles: Array::make(15, Empty),
    map_width: 1,
    map_height: 15,
    camera_x: 0.0,
    score: 0,
    coins: 0,
    lives: 3,
    time_remaining: level_time,
    intro_timer: 0.0,
    clear_timer: 0.0,
    death_timer: 0.0,
    game_over_timer: 0.0,
    flag_y: 0.0,
    flag_target_y: 0.0,
    flag_done: false,
    mario_auto: false,
    mario_target_x: 0.0,
    frame_counter: 0,
    frame_times: Array::make(120, default_frame_time),
    frame_time_cursor: 0,
    rng_state: 0x13572468,
    clouds: Array::makei(12, fn(i) {
      {
        x: Float::from_int(i * 160),
        y: Float::from_int(40 + i * 37 % 120),
        w: Float::from_int(60 + i * 23 % 80),
        speed: 8.0 + Float::from_int(i * 7 % 12),
      }
    }),
  }
}
