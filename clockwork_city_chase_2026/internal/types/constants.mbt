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
/// Upper bound for max objs in gameplay systems.
pub let max_objs : Int = 420

///|
/// Upper bound for max shots in gameplay systems.
pub let max_shots : Int = 480

///|
/// Upper bound for max sparks in gameplay systems.
pub let max_sparks : Int = 760

///|
/// Upper bound for max shock rings in gameplay systems.
pub let max_shock_rings : Int = 84

///|
/// Upper bound for max ghosts in gameplay systems.
pub let max_ghosts : Int = 240

///|
/// Gameplay tuning constant for lane count.
pub let lane_count : Int = 5

///|
/// Gameplay tuning constant for lane gap.
pub let lane_gap : Float = Float::from_int(90)

///|
/// Gameplay tuning constant for car w.
pub let car_w : Float = Float::from_int(44)

///|
/// Gameplay tuning constant for car h.
pub let car_h : Float = Float::from_int(76)

///|
/// World layout coordinate for accel x.
pub let accel_x : Float = Float::from_int(1620)

///|
/// World layout coordinate for accel y.
pub let accel_y : Float = Float::from_int(1180)

///|
/// Movement or scaling coefficient for car drag.
pub let car_drag : Float = Float::from_int(3)

///|
/// Upper bound for max speed x in gameplay systems.
pub let max_speed_x : Float = Float::from_int(500)

///|
/// Upper bound for max speed y in gameplay systems.
pub let max_speed_y : Float = Float::from_int(340)

///|
/// Gameplay tuning constant for base scroll.
pub let base_scroll : Float = Float::from_int(270)

///|
/// Progression and scoring constant for stage scroll bonus.
pub let stage_scroll_bonus : Float = Float::from_int(36)

///|
/// Base value before difficulty or progression scaling for stage goal base.
pub let stage_goal_base : Float = Float::from_int(2500)

///|
/// Progression and scoring constant for stage goal bonus.
pub let stage_goal_bonus : Float = Float::from_int(780)

///|
/// World layout coordinate for spawn start y.
pub let spawn_start_y : Float = -120.0

///|
/// Minimum or floor value used for spawn gap min.
pub let spawn_gap_min : Float = 64.0

///|
/// Maximum value configured for spawn gap max.
pub let spawn_gap_max : Float = 164.0

///|
/// Maximum value configured for armor max.
pub let armor_max : Float = Float::from_int(100)

///|
/// Maximum value configured for heat max.
pub let heat_max : Float = Float::from_int(100)

///|
/// Base value before difficulty or progression scaling for heat drain base.
pub let heat_drain_base : Float = Float::from_int(3)

///|
/// Survival or damage balancing constant for heat drain dash.
pub let heat_drain_dash : Float = Float::from_int(6)

///|
/// Gameplay tuning constant for heat pickup.
pub let heat_pickup : Float = Float::from_int(23)

///|
/// Survival or damage balancing constant for armor drain passive.
pub let armor_drain_passive : Float = 0.45

///|
/// Base value before difficulty or progression scaling for shot cd base.
pub let shot_cd_base : Float = 0.148

///|
/// Movement or scaling coefficient for shot speed.
pub let shot_speed : Float = Float::from_int(760)

///|
/// Movement or scaling coefficient for enemy shot speed.
pub let enemy_shot_speed : Float = Float::from_int(380)

///|
/// Timing constant that controls shot life.
pub let shot_life : Float = 1.24

///|
/// Timing constant that controls dash cd time.
pub let dash_cd_time : Float = 1.62

///|
/// Timing constant that controls dash time.
pub let dash_time : Float = 0.25

///|
/// Gameplay tuning constant for dash boost.
pub let dash_boost : Float = Float::from_int(540)

///|
/// Timing constant that controls emp cd time.
pub let emp_cd_time : Float = 2.46

///|
/// Timing constant that controls emp time.
pub let emp_time : Float = 0.82

///|
/// Spatial tuning constant for emp radius.
pub let emp_radius : Float = Float::from_int(220)

///|
/// Spatial tuning constant for emp kill radius.
pub let emp_kill_radius : Float = Float::from_int(108)

///|
/// Gameplay tuning constant for stage clear wait.
pub let stage_clear_wait : Float = 1.9

///|
/// Timing constant that controls invuln time.
pub let invuln_time : Float = 0.64

///|
/// Gameplay tuning constant for hud h.
pub let hud_h : Int = 112
