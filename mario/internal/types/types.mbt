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
  LevelTally
  BonusRoom
} derive(Eq)

///|
pub extend GameState with Eq::{not_equal, equal}

///|
/// Mario's current power-up state.
pub(all) enum PowerState {
  Small
  Big
  Fire
} derive(Eq)

///|
pub extend PowerState with Eq::{not_equal, equal}

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
  CoinTile
  PipeEntrance
  Checkpoint
  HiddenBonusCoin
  HiddenBonusOneUp
  BridgeTile
} derive(Eq)

///|
pub extend TileKind with Eq::{not_equal, equal}

///|
/// Enemy varieties.
pub(all) enum EnemyKind {
  Goomba
  KoopaTroopa
  KoopaShell
  PiranhaPlant
  BuzzyBeetle
  Firebar
  BowserLite
} derive(Eq)

///|
pub extend EnemyKind with Eq::{not_equal, equal}

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
pub extend ItemKind with Eq::{not_equal, equal}

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
  mut pipe_timer : Float
  mut extended : Bool
  mut hop_timer : Float
  mut firebar_angle : Float
  mut firebar_segments : Int
  mut boss_hp : Int
  mut fire_cooldown : Float
  mut patrol_left : Float
  mut patrol_right : Float
  mut flash_timer : Float
}

///|
/// Creates a new enemy of the given kind.
pub fn Enemy::new(kind : EnemyKind, spawn_x : Float, spawn_y : Float) -> Enemy {
  let w : Float = match kind {
    Goomba => 40.0
    KoopaTroopa => 40.0
    KoopaShell => 40.0
    PiranhaPlant => 40.0
    BuzzyBeetle => 40.0
    Firebar => 16.0
    BowserLite => 64.0
  }
  let h : Float = match kind {
    Goomba => 40.0
    KoopaTroopa => 52.0
    KoopaShell => 36.0
    PiranhaPlant => 48.0
    BuzzyBeetle => 40.0
    Firebar => 16.0
    BowserLite => 72.0
  }
  let speed : Float = match kind {
    Goomba => goomba_speed
    KoopaTroopa => koopa_speed
    KoopaShell => 0.0
    PiranhaPlant => 0.0
    BuzzyBeetle => buzzy_beetle_speed
    Firebar => 0.0
    BowserLite => bowser_speed
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
    pipe_timer: 0.0,
    extended: false,
    hop_timer: 0.0,
    firebar_angle: 0.0,
    firebar_segments: match kind {
      Firebar => firebar_num_segments
      _ => 0
    },
    boss_hp: match kind {
      BowserLite => bowser_hp
      _ => 0
    },
    fire_cooldown: match kind {
      BowserLite => bowser_fire_rate
      _ => 0.0
    },
    patrol_left: spawn_x - bowser_patrol_range,
    patrol_right: spawn_x + bowser_patrol_range,
    flash_timer: 0.0,
  }
}

///|
/// Clone an enemy (snapshot all mutable fields).
pub fn Enemy::clone(self : Enemy) -> Enemy {
  {
    active: self.active,
    kind: self.kind,
    x: self.x,
    y: self.y,
    vx: self.vx,
    vy: self.vy,
    on_ground: self.on_ground,
    dead: self.dead,
    dead_timer: self.dead_timer,
    squished: self.squished,
    anim_timer: self.anim_timer,
    anim_frame: self.anim_frame,
    shell_moving: self.shell_moving,
    width: self.width,
    height: self.height,
    pipe_timer: self.pipe_timer,
    extended: self.extended,
    hop_timer: self.hop_timer,
    firebar_angle: self.firebar_angle,
    firebar_segments: self.firebar_segments,
    boss_hp: self.boss_hp,
    fire_cooldown: self.fire_cooldown,
    patrol_left: self.patrol_left,
    patrol_right: self.patrol_right,
    flash_timer: self.flash_timer,
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
/// Clone an item (snapshot all mutable fields).
pub fn Item::clone(self : Item) -> Item {
  {
    active: self.active,
    kind: self.kind,
    x: self.x,
    y: self.y,
    vx: self.vx,
    vy: self.vy,
    on_ground: self.on_ground,
    emerging: self.emerging,
    emerge_start_y: self.emerge_start_y,
    emerge_target_y: self.emerge_target_y,
  }
}

///|
/// Bowser fire breath projectile.
pub(all) struct BowserFireball {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
}

///|
/// Creates a new Bowser fireball.
pub fn BowserFireball::new() -> BowserFireball {
  { active: false, x: 0.0, y: 0.0, vx: 0.0, }
}

///|
/// Clone a Bowser fireball.
pub fn BowserFireball::clone(self : BowserFireball) -> BowserFireball {
  { active: self.active, x: self.x, y: self.y, vx: self.vx, }
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
  { active: false, x: 0.0, y: 0.0, vx: 0.0, vy: 0.0, }
}

///|
/// Clone a player fireball.
pub fn Fireball::clone(self : Fireball) -> Fireball {
  { active: self.active, x: self.x, y: self.y, vx: self.vx, vy: self.vy, }
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
  { active: false, x: 0.0, y: 0.0, vy: 0.0, life: 0.0, text: "", }
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
  { active: false, tile_x: 0, tile_y: 0, offset_y: 0.0, velocity: 0.0, }
}

///|
/// Bridge tile state for collapsing bridge segments.
pub(all) enum BridgePhase {
  Stable
  Shaking
  Falling
  Gone
} derive(Eq)

///|
pub extend BridgePhase with Eq::{not_equal, equal}

///|
/// Tracks a bridge tile that can collapse.
pub(all) struct BridgeState {
  mut active : Bool
  mut tile_x : Int
  mut tile_y : Int
  mut phase : BridgePhase
  mut timer : Float
  mut fall_y : Float
}

///|
/// Creates a new bridge state tracker.
pub fn BridgeState::new() -> BridgeState {
  {
    active: false,
    tile_x: 0,
    tile_y: 0,
    phase: Stable,
    timer: 0.0,
    fall_y: 0.0,
  }
}

///|
/// Moving platform that travels between two points.
pub(all) struct MovingPlatform {
  mut active : Bool
  mut x : Float
  mut y : Float
  width : Float
  mut start_x : Float
  mut start_y : Float
  mut end_x : Float
  mut end_y : Float
  mut speed : Float
  mut progress : Float
  mut direction : Int
  mut prev_x : Float
  mut prev_y : Float
}

///|
/// Creates a new moving platform.
pub fn MovingPlatform::new() -> MovingPlatform {
  {
    active: false,
    x: 0.0,
    y: 0.0,
    width: 96.0,
    start_x: 0.0,
    start_y: 0.0,
    end_x: 0.0,
    end_y: 0.0,
    speed: 0.5,
    progress: 0.0,
    direction: 1,
    prev_x: 0.0,
    prev_y: 0.0,
  }
}

///|
/// Lift platform that rises when Mario stands on it.
pub(all) struct LiftPlatform {
  mut active : Bool
  mut x : Float
  mut y : Float
  width : Float
  mut target_y : Float
  mut speed : Float
  mut triggered : Bool
  mut prev_y : Float
}

///|
/// Creates a new lift platform.
pub fn LiftPlatform::new() -> LiftPlatform {
  {
    active: false,
    x: 0.0,
    y: 0.0,
    width: 96.0,
    target_y: 0.0,
    speed: 120.0,
    triggered: false,
    prev_y: 0.0,
  }
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
  bowser_fireballs : Array[BowserFireball]
  particles : Array[Particle]
  score_popups : Array[ScorePopup]
  bumped_blocks : Array[BumpedBlock]
  // ── Platforms ──
  platforms : Array[MovingPlatform]
  lifts : Array[LiftPlatform]
  bridges : Array[BridgeState]
  // ── Boss ──
  mut boss_defeated : Bool
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
  mut rng_state : Int
  // ── Decoration ──
  clouds : Array[Cloud]
  // ── Checkpoint ──
  mut checkpoint_x : Float
  mut checkpoint_y : Float
  mut checkpoint_active : Bool
  // ── Power-up persistence ──
  mut saved_power : PowerState
  // ── Level tally ──
  mut tally_timer : Float
  mut tally_phase : Int
  mut tally_time_bonus : Int
  mut tally_coin_bonus : Int
  mut tally_enemy_bonus : Int
  mut tally_height_bonus : Int
  mut tally_rank : String
  mut enemies_defeated : Int
  mut level_coins_collected : Int
  mut level_total_coins : Int
  mut level_deaths : Int
  // ── Flagpole height fraction ──
  mut flag_height_frac : Float
  // ── Bonus room ──
  mut in_bonus_room : Bool
  mut bonus_return_x : Float
  mut bonus_return_y : Float
  mut bonus_return_level : Int
  mut bonus_saved_tiles : Array[TileKind]
  mut bonus_saved_width : Int
  mut bonus_saved_height : Int
  mut bonus_saved_enemies : Array[Enemy]
  mut bonus_saved_items : Array[Item]
  mut bonus_saved_fireballs : Array[Fireball]
  mut bonus_fade_timer : Float
  mut bonus_fade_in : Bool
  // ── Game feel ──
  mut hitstop_timer : Float
  mut shake_timer : Float
  mut shake_intensity : Float
  mut slowmo_timer : Float
}

///|
/// Creates a new game in title-screen state.
pub fn Game::new() -> Game {
  {
    state: Title,
    world_num: 1,
    level_num: 1,
    level_index: 0,
    player: Player::new(120.0, 576.0),
    enemies: Array::makei(max_enemies, fn(_i) { Enemy::new(Goomba, 0.0, 0.0) }),
    items: Array::makei(max_items, fn(_i) { Item::new() }),
    fireballs: Array::makei(max_fireballs, fn(_i) { Fireball::new() }),
    bowser_fireballs: Array::makei(max_bowser_fireballs, fn(_i) {
      BowserFireball::new()
    }),
    particles: Array::makei(max_particles, fn(_i) { Particle::new() }),
    score_popups: Array::makei(max_score_popups, fn(_i) { ScorePopup::new() }),
    bumped_blocks: Array::makei(max_bumped_blocks, fn(_i) { BumpedBlock::new() }),
    platforms: Array::makei(max_platforms, fn(_i) { MovingPlatform::new() }),
    lifts: Array::makei(max_lifts, fn(_i) { LiftPlatform::new() }),
    bridges: Array::makei(max_bridges, fn(_i) { BridgeState::new() }),
    boss_defeated: false,
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
    rng_state: 0x13572468,
    clouds: Array::makei(12, fn(i) {
      {
        x: Float::from_int(i * 160),
        y: Float::from_int(40 + i * 37 % 120),
        w: Float::from_int(60 + i * 23 % 80),
        speed: 8.0 + Float::from_int(i * 7 % 12),
      }
    }),
    checkpoint_x: 0.0,
    checkpoint_y: 0.0,
    checkpoint_active: false,
    saved_power: Small,
    tally_timer: 0.0,
    tally_phase: 0,
    tally_time_bonus: 0,
    tally_coin_bonus: 0,
    tally_enemy_bonus: 0,
    tally_height_bonus: 0,
    tally_rank: "",
    enemies_defeated: 0,
    level_coins_collected: 0,
    level_total_coins: 0,
    level_deaths: 0,
    flag_height_frac: 1.0,
    in_bonus_room: false,
    bonus_return_x: 0.0,
    bonus_return_y: 0.0,
    bonus_return_level: 0,
    bonus_saved_tiles: [],
    bonus_saved_width: 0,
    bonus_saved_height: 0,
    bonus_saved_enemies: [],
    bonus_saved_items: [],
    bonus_saved_fireballs: [],
    bonus_fade_timer: 0.0,
    bonus_fade_in: false,
    hitstop_timer: 0.0,
    shake_timer: 0.0,
    shake_intensity: 0.0,
    slowmo_timer: 0.0,
  }
}
