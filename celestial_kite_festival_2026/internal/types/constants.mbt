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
/// Gameplay tuning constant for hud h.
pub let hud_h : Int = 110

///|
/// World layout coordinate for play top.
pub let play_top : Float = Float::from_int(hud_h) + 14.0

///|
/// World layout coordinate for play bottom.
pub let play_bottom : Float = Float::from_int(screen_h) - 26.0

///|
/// World layout coordinate for play left.
pub let play_left : Float = 42.0

///|
/// World layout coordinate for play right.
pub let play_right : Float = Float::from_int(screen_w) - 42.0

///|
/// Upper bound for max objs in gameplay systems.
pub let max_objs : Int = 360

///|
/// Upper bound for max sparks in gameplay systems.
pub let max_sparks : Int = 900

///|
/// Upper bound for max halos in gameplay systems.
pub let max_halos : Int = 90

///|
/// Upper bound for max trails in gameplay systems.
pub let max_trails : Int = 320

///|
/// Gameplay tuning constant for kite w.
pub let kite_w : Float = 54.0

///|
/// Gameplay tuning constant for kite h.
pub let kite_h : Float = 64.0

///|
/// Movement or scaling coefficient for kite accel.
pub let kite_accel : Float = 1040.0

///|
/// Movement or scaling coefficient for kite drag.
pub let kite_drag : Float = 2.8

///|
/// Movement or scaling coefficient for kite max speed.
pub let kite_max_speed : Float = 540.0

///|
/// Minimum or floor value used for kite rope len min.
pub let kite_rope_len_min : Float = 150.0

///|
/// Maximum value configured for kite rope len max.
pub let kite_rope_len_max : Float = 360.0

///|
/// Gameplay tuning constant for kite rope spring.
pub let kite_rope_spring : Float = 9.0

///|
/// Gameplay tuning constant for kite rope damp.
pub let kite_rope_damp : Float = 0.94

///|
/// Timing constant that controls burst cd time.
pub let burst_cd_time : Float = 1.8

///|
/// Spatial tuning constant for burst radius.
pub let burst_radius : Float = 150.0

///|
/// Gameplay tuning constant for burst cost.
pub let burst_cost : Float = 24.0

///|
/// Gameplay tuning constant for reel energy cost.
pub let reel_energy_cost : Float = 22.0

///|
/// Gameplay tuning constant for reel rate.
pub let reel_rate : Float = 120.0

///|
/// Gameplay tuning constant for rope recover rate.
pub let rope_recover_rate : Float = 52.0

///|
/// Base value before difficulty or progression scaling for stage time base.
pub let stage_time_base : Float = 62.0

///|
/// Progression and scoring constant for stage time bonus.
pub let stage_time_bonus : Float = 12.0

///|
/// Base value before difficulty or progression scaling for stage goal base.
pub let stage_goal_base : Int = 1300

///|
/// Progression and scoring constant for stage goal bonus.
pub let stage_goal_bonus : Int = 720

///|
/// Maximum value configured for calm max.
pub let calm_max : Float = 100.0

///|
/// Maximum value configured for energy max.
pub let energy_max : Float = 100.0

///|
/// Per-step progression tuning for calm decay.
pub let calm_decay : Float = 3.2

///|
/// Survival or damage balancing constant for energy regen.
pub let energy_regen : Float = 16.0

///|
/// Base value before difficulty or progression scaling for wind base.
pub let wind_base : Float = 48.0

///|
/// Progression and scoring constant for wind stage bonus.
pub let wind_stage_bonus : Float = 22.0

///|
/// Gameplay tuning constant for stage clear wait.
pub let stage_clear_wait : Float = 2.0
