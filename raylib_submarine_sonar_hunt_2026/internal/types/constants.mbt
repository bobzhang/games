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
/// Gameplay tuning constant for arena x0.
pub let arena_x0 : Int = 78

///|
/// Gameplay tuning constant for arena y0.
pub let arena_y0 : Int = 84

///|
/// Gameplay tuning constant for arena w.
pub let arena_w : Int = 1124

///|
/// Gameplay tuning constant for arena h.
pub let arena_h : Int = 574

///|
/// Gameplay tuning constant for arena x1.
pub let arena_x1 : Int = arena_x0 + arena_w

///|
/// Gameplay tuning constant for arena y1.
pub let arena_y1 : Int = arena_y0 + arena_h

///|
/// Gameplay tuning constant for surface band h.
pub let surface_band_h : Int = 86

///|
/// World layout coordinate for surface band y.
pub let surface_band_y : Float = Float::from_int(arena_y0 + surface_band_h)

///|
/// World layout coordinate for hot zone x.
pub let hot_zone_x : Float = Float::from_int(arena_x0) +
  Float::from_int(arena_w) * 0.72

///|
/// World layout coordinate for hot zone y.
pub let hot_zone_y : Float = Float::from_int(arena_y0) +
  Float::from_int(arena_h) * 0.46

///|
/// Gameplay tuning constant for hot zone r.
pub let hot_zone_r : Float = 148.0

///|
/// Minimum or floor value used for mission min.
pub let mission_min : Int = 1

///|
/// Maximum value configured for mission max.
pub let mission_max : Int = 9

///|
/// Upper bound for max mines in gameplay systems.
pub let max_mines : Int = 54

///|
/// Upper bound for max targets in gameplay systems.
pub let max_targets : Int = 16

///|
/// Progression and scoring constant for base target goal.
pub let base_target_goal : Int = 4

///|
/// Progression and scoring constant for target goal cap.
pub let target_goal_cap : Int = 12

///|
/// Gameplay tuning constant for base mine count.
pub let base_mine_count : Int = 16

///|
/// World layout coordinate for sub start x.
pub let sub_start_x : Float = Float::from_int(arena_x0) + 126.0

///|
/// World layout coordinate for sub start y.
pub let sub_start_y : Float = Float::from_int(arena_y0) +
  Float::from_int(arena_h) * 0.62

///|
/// Gameplay tuning constant for sub r.
pub let sub_r : Float = 18.0

///|
/// Movement or scaling coefficient for sub accel.
pub let sub_accel : Float = 420.0

///|
/// Movement or scaling coefficient for sub boost accel.
pub let sub_boost_accel : Float = 760.0

///|
/// Movement or scaling coefficient for sub drag.
pub let sub_drag : Float = 4.8

///|
/// Movement or scaling coefficient for sub max speed.
pub let sub_max_speed : Float = 220.0

///|
/// Movement or scaling coefficient for sub boost max speed.
pub let sub_boost_max_speed : Float = 340.0

///|
/// Maximum value configured for oxygen max.
pub let oxygen_max : Float = 100.0

///|
/// Maximum value configured for fuel max.
pub let fuel_max : Float = 100.0

///|
/// Maximum value configured for hull max.
pub let hull_max : Float = 100.0

///|
/// Survival or damage balancing constant for oxygen base drain.
pub let oxygen_base_drain : Float = 3.2

///|
/// Survival or damage balancing constant for oxygen hot drain.
pub let oxygen_hot_drain : Float = 4.4

///|
/// Survival or damage balancing constant for oxygen boost drain.
pub let oxygen_boost_drain : Float = 1.8

///|
/// Gameplay tuning constant for oxygen surface recover.
pub let oxygen_surface_recover : Float = 10.2

///|
/// Survival or damage balancing constant for fuel idle drain.
pub let fuel_idle_drain : Float = 0.5

///|
/// Survival or damage balancing constant for fuel move drain.
pub let fuel_move_drain : Float = 3.1

///|
/// Survival or damage balancing constant for fuel boost drain.
pub let fuel_boost_drain : Float = 7.6

///|
/// Timing constant that controls sonar cd time.
pub let sonar_cd_time : Float = 1.28

///|
/// Timing constant that controls sonar pulse time.
pub let sonar_pulse_time : Float = 0.82

///|
/// Spatial tuning constant for sonar base range.
pub let sonar_base_range : Float = 192.0

///|
/// Progression and scoring constant for sonar hot bonus.
pub let sonar_hot_bonus : Float = 110.0

///|
/// Gameplay tuning constant for sonar fuel cost.
pub let sonar_fuel_cost : Float = 5.6

///|
/// Gameplay tuning constant for sonar oxygen cost.
pub let sonar_oxygen_cost : Float = 4.8

///|
/// Timing constant that controls mine reveal time.
pub let mine_reveal_time : Float = 3.0

///|
/// Survival or damage balancing constant for mine damage hull.
pub let mine_damage_hull : Float = 36.0

///|
/// Survival or damage balancing constant for mine damage oxygen.
pub let mine_damage_oxygen : Float = 18.0

///|
/// Survival or damage balancing constant for mine damage fuel.
pub let mine_damage_fuel : Float = 11.0

///|
/// Progression and scoring constant for detect oxygen reward.
pub let detect_oxygen_reward : Float = 4.8

///|
/// Progression and scoring constant for detect fuel reward.
pub let detect_fuel_reward : Float = 3.2
