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
/// Upper bound for max entities in gameplay systems.
pub let max_entities : Int = 380

///|
/// Upper bound for max bullets in gameplay systems.
pub let max_bullets : Int = 440

///|
/// Upper bound for max sparks in gameplay systems.
pub let max_sparks : Int = 760

///|
/// Upper bound for max glow rings in gameplay systems.
pub let max_glow_rings : Int = 80

///|
/// Upper bound for max afterimages in gameplay systems.
pub let max_afterimages : Int = 220

///|
/// Gameplay tuning constant for lanes count.
pub let lanes_count : Int = 5

///|
/// Gameplay tuning constant for lane gap.
pub let lane_gap : Float = Float::from_int(92)

///|
/// Gameplay tuning constant for player w.
pub let player_w : Float = Float::from_int(42)

///|
/// Gameplay tuning constant for player h.
pub let player_h : Float = Float::from_int(74)

///|
/// World layout coordinate for player accel x.
pub let player_accel_x : Float = Float::from_int(1700)

///|
/// World layout coordinate for player accel y.
pub let player_accel_y : Float = Float::from_int(1260)

///|
/// Movement or scaling coefficient for player drag.
pub let player_drag : Float = Float::from_int(3)

///|
/// World layout coordinate for player max speed x.
pub let player_max_speed_x : Float = Float::from_int(520)

///|
/// World layout coordinate for player max speed y.
pub let player_max_speed_y : Float = Float::from_int(360)

///|
/// Movement or scaling coefficient for base scroll speed.
pub let base_scroll_speed : Float = Float::from_int(280)

///|
/// Per-step progression tuning for stage scroll gain.
pub let stage_scroll_gain : Float = Float::from_int(34)

///|
/// Base value before difficulty or progression scaling for stage distance base.
pub let stage_distance_base : Float = Float::from_int(2600)

///|
/// Per-step progression tuning for stage distance gain.
pub let stage_distance_gain : Float = Float::from_int(760)

///|
/// World layout coordinate for spawn start y.
pub let spawn_start_y : Float = -110.0

///|
/// Minimum or floor value used for spawn spacing min.
pub let spawn_spacing_min : Float = 68.0

///|
/// Maximum value configured for spawn spacing max.
pub let spawn_spacing_max : Float = 164.0

///|
/// Base value before difficulty or progression scaling for energy drain base.
pub let energy_drain_base : Float = Float::from_int(3)

///|
/// Survival or damage balancing constant for energy drain boost.
pub let energy_drain_boost : Float = Float::from_int(6)

///|
/// Gameplay tuning constant for energy pickup.
pub let energy_pickup : Float = Float::from_int(22)

///|
/// Per-step progression tuning for shield damage decay.
pub let shield_damage_decay : Float = Float::from_int(14)

///|
/// Maximum value configured for player shield max.
pub let player_shield_max : Float = Float::from_int(100)

///|
/// Maximum value configured for player energy max.
pub let player_energy_max : Float = Float::from_int(100)

///|
/// Base value before difficulty or progression scaling for fire cooldown base.
pub let fire_cooldown_base : Float = 0.145

///|
/// Movement or scaling coefficient for bullet speed.
pub let bullet_speed : Float = Float::from_int(780)

///|
/// Movement or scaling coefficient for enemy bullet speed.
pub let enemy_bullet_speed : Float = Float::from_int(390)

///|
/// Timing constant that controls bullet life.
pub let bullet_life : Float = 1.2

///|
/// Timing constant that controls boost cd time.
pub let boost_cd_time : Float = 1.55

///|
/// Timing constant that controls boost time.
pub let boost_time : Float = 0.26

///|
/// Progression and scoring constant for boost speed bonus.
pub let boost_speed_bonus : Float = Float::from_int(560)

///|
/// Timing constant that controls hack cd time.
pub let hack_cd_time : Float = 2.4

///|
/// Timing constant that controls hack time.
pub let hack_time : Float = 0.82

///|
/// Spatial tuning constant for hack radius.
pub let hack_radius : Float = Float::from_int(220)

///|
/// Gameplay tuning constant for hack pulse kill.
pub let hack_pulse_kill : Float = Float::from_int(110)

///|
/// Timing constant that controls stage clear delay.
pub let stage_clear_delay : Float = 1.85

///|
/// Survival or damage balancing constant for invuln after hit.
pub let invuln_after_hit : Float = 0.62

///|
/// Gameplay tuning constant for ui panel h.
pub let ui_panel_h : Int = 112
