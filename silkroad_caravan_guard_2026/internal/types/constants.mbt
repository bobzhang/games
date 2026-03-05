///|
/// Width of the game window in pixels.
pub let screen_w : Int = 1360

///|
/// Height of the game window in pixels.
pub let screen_h : Int = 820

///|
/// Target frame rate used by the main loop.
pub let target_fps : Int = 120

///|
/// Gameplay tuning constant for wagon count.
pub let wagon_count : Int = 3

///|
/// Gameplay tuning constant for lane count.
pub let lane_count : Int = 5

///|
/// Upper bound for max raiders in gameplay systems.
pub let max_raiders : Int = 180

///|
/// Upper bound for max bullets in gameplay systems.
pub let max_bullets : Int = 260

///|
/// Upper bound for max dust in gameplay systems.
pub let max_dust : Int = 960

///|
/// Gameplay tuning constant for checkpoint total.
pub let checkpoint_total : Int = 4

///|
/// Spatial tuning constant for checkpoint base span.
pub let checkpoint_base_span : Float = 1400.0

///|
/// Per-step progression tuning for checkpoint span step.
pub let checkpoint_span_step : Float = 220.0

///|
/// Base value before difficulty or progression scaling for caravan speed base.
pub let caravan_speed_base : Float = 132.0

///|
/// Per-step progression tuning for caravan speed step.
pub let caravan_speed_step : Float = 20.0

///|
/// Gameplay tuning constant for wagon gap.
pub let wagon_gap : Float = 148.0

///|
/// Maximum value configured for wagon hp max.
pub let wagon_hp_max : Float = 120.0

///|
/// Spatial tuning constant for player radius.
pub let player_radius : Float = 16.0

///|
/// Movement or scaling coefficient for player speed.
pub let player_speed : Float = 320.0

///|
/// Movement or scaling coefficient for player drag.
pub let player_drag : Float = 8.0

///|
/// Movement or scaling coefficient for player roll speed.
pub let player_roll_speed : Float = 760.0

///|
/// Timing constant that controls player roll time.
pub let player_roll_time : Float = 0.22

///|
/// Gameplay tuning constant for player roll cd.
pub let player_roll_cd : Float = 1.02

///|
/// Timing constant that controls player invuln time.
pub let player_invuln_time : Float = 0.72

///|
/// Gameplay tuning constant for shoot cd.
pub let shoot_cd : Float = 0.14

///|
/// Movement or scaling coefficient for bullet speed.
pub let bullet_speed : Float = 860.0

///|
/// Timing constant that controls bullet life.
pub let bullet_life : Float = 0.82

///|
/// Gameplay tuning constant for bullet dmg.
pub let bullet_dmg : Float = 28.0

///|
/// Maximum value configured for ammo max.
pub let ammo_max : Int = 42

///|
/// Base value before difficulty or progression scaling for ammo regen base.
pub let ammo_regen_base : Float = 0.58

///|
/// Spatial tuning constant for repair range.
pub let repair_range : Float = 92.0

///|
/// Gameplay tuning constant for repair heal.
pub let repair_heal : Float = 34.0

///|
/// Gameplay tuning constant for repair cd.
pub let repair_cd : Float = 0.7

///|
/// Maximum value configured for kit max.
pub let kit_max : Int = 8

///|
/// Maximum value configured for morale max.
pub let morale_max : Float = 100.0

///|
/// Per-step progression tuning for morale decay.
pub let morale_decay : Float = 1.6

///|
/// Per-step progression tuning for morale kill gain.
pub let morale_kill_gain : Float = 0.9

///|
/// Gameplay tuning constant for perimeter outer rx.
pub let perimeter_outer_rx : Float = 280.0

///|
/// Gameplay tuning constant for perimeter outer ry.
pub let perimeter_outer_ry : Float = 195.0

///|
/// Gameplay tuning constant for perimeter inner rx.
pub let perimeter_inner_rx : Float = 154.0

///|
/// Gameplay tuning constant for perimeter inner ry.
pub let perimeter_inner_ry : Float = 102.0

///|
/// Base value before difficulty or progression scaling for spawn interval base.
pub let spawn_interval_base : Float = 1.35

///|
/// Minimum or floor value used for spawn interval min.
pub let spawn_interval_min : Float = 0.34

///|
/// World layout coordinate for desert lane top.
pub let desert_lane_top : Float = 228.0

///|
/// Gameplay tuning constant for desert lane gap.
pub let desert_lane_gap : Float = 94.0

///|
/// Gameplay tuning constant for tau.
pub let tau : Float = 6.283185307179586

///|
/// World layout coordinate for caravan center x.
pub let caravan_center_x : Float = Float::from_int(screen_w) * 0.48

///|
/// World layout coordinate for caravan center y.
pub let caravan_center_y : Float = Float::from_int(screen_h) * 0.57

///|
/// Distinguishes raider archetypes with different stats.
pub(all) enum RaiderKind {
  Skirmisher
  Brute
  Rider
} derive(Eq)

///|
/// Tracks the current phase of the game session.
pub(all) enum GameState {
  Title
  Play
  Pause
  GameOver
  Victory
} derive(Eq)
