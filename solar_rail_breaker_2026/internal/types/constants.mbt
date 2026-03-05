///|
/// Width of the game window in pixels.
pub let screen_w : Int = 1280

///|
/// Height of the game window in pixels.
pub let screen_h : Int = 720

///|
/// Target frame rate used by the main loop.
pub let target_fps : Int = 120

///|
/// Gameplay tuning constant for ring count.
pub let ring_count : Int = 4

///|
/// Upper bound for max enemies in gameplay systems.
pub let max_enemies : Int = 160

///|
/// Upper bound for max bullets in gameplay systems.
pub let max_bullets : Int = 240

///|
/// Upper bound for max enemy bullets in gameplay systems.
pub let max_enemy_bullets : Int = 260

///|
/// Upper bound for max flares in gameplay systems.
pub let max_flares : Int = 24

///|
/// Upper bound for max particles in gameplay systems.
pub let max_particles : Int = 520

///|
/// Upper bound for max shocks in gameplay systems.
pub let max_shocks : Int = 180

///|
/// Spatial tuning constant for base radius.
pub let base_radius : Float = Float::from_int(120)

///|
/// Gameplay tuning constant for ring gap.
pub let ring_gap : Float = Float::from_int(62)

///|
/// Survival or damage balancing constant for player hit r.
pub let player_hit_r : Float = Float::from_int(20)

///|
/// Movement or scaling coefficient for player turn speed.
pub let player_turn_speed : Float = 2.9

///|
/// Gameplay tuning constant for player switch cd.
pub let player_switch_cd : Float = 0.17

///|
/// Gameplay tuning constant for player shot cd.
pub let player_shot_cd : Float = 0.15

///|
/// Gameplay tuning constant for player beam cd.
pub let player_beam_cd : Float = 1.2

///|
/// Maximum value configured for player phase max.
pub let player_phase_max : Float = Float::from_int(100)

///|
/// Survival or damage balancing constant for phase drain.
pub let phase_drain : Float = Float::from_int(24)

///|
/// Gameplay tuning constant for phase recover.
pub let phase_recover : Float = Float::from_int(16)

///|
/// Gameplay tuning constant for player invuln t.
pub let player_invuln_t : Float = 0.66

///|
/// Movement or scaling coefficient for enemy base speed.
pub let enemy_base_speed : Float = 1.1

///|
/// Gameplay tuning constant for enemy speed stage.
pub let enemy_speed_stage : Float = 0.08

///|
/// Base value before difficulty or progression scaling for enemy fire base.
pub let enemy_fire_base : Float = 1.2

///|
/// Timing constant that controls stage time.
pub let stage_time : Float = Float::from_int(36)

///|
/// Timing constant that controls stage clear delay.
pub let stage_clear_delay : Float = 1.8

///|
/// Mathematical constant pi used for angle calculations.
pub let pi : Float = 3.14159265

///|
/// Gameplay tuning constant for tau.
pub let tau : Float = 6.28318530

///|
/// Represents the current phase of the game lifecycle.
pub(all) enum GameState {
  Title
  Play
  StageClear
  GameOver
} derive(Eq)

///|
/// Classifies enemy behavior and visual style.
pub(all) enum EnemyKind {
  /// Basic enemy: square shape, standard chase, moderate fire rate.
  Basic
  /// Heavy enemy: large circle, faster chase, higher damage bullets.
  Heavy
  /// Orbiter enemy: pulsing mine, offset orbit, contact damage.
  Orbiter
} derive(Eq)

///|
/// Classifies player bullet visual and behavior style.
pub(all) enum BulletKind {
  /// Standard player bullet with cyan trail.
  Standard
} derive(Eq)

///|
/// Classifies enemy bullet visual style based on firing enemy type.
pub(all) enum EnemyBulletKind {
  /// Pink bullet fired by basic enemies.
  BasicShot
  /// Orange bullet fired by heavy enemies.
  HeavyShot
  /// Green bullet fired by orbiter enemies.
  OrbiterShot
} derive(Eq)

///|
/// Classifies particle visual style by color.
pub(all) enum ParticleKind {
  /// Cyan spark from player fire.
  Spark
  /// Orange flash from kills and beam.
  Flash
  /// Pink burst from damage.
  Damage
} derive(Eq)
