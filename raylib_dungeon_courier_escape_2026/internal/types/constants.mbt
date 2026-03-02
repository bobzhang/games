///|
/// Width of the game window in pixels.
pub let screen_w : Int = 1440

///|
/// Height of the game window in pixels.
pub let screen_h : Int = 900

///|
/// Target frame rate used by the main loop.
pub let target_fps : Int = 120

///|
/// Upper bound for max parcels in gameplay systems.
pub let max_parcels : Int = 12

///|
/// Upper bound for max exits in gameplay systems.
pub let max_exits : Int = 3

///|
/// Upper bound for max guards in gameplay systems.
pub let max_guards : Int = 16

///|
/// Upper bound for max traps in gameplay systems.
pub let max_traps : Int = 28

///|
/// Upper bound for max smokes in gameplay systems.
pub let max_smokes : Int = 8

///|
/// Gameplay tuning constant for hud h.
pub let hud_h : Float = 92.0

///|
/// World layout coordinate for world left.
pub let world_left : Float = 46.0

///|
/// World layout coordinate for world top.
pub let world_top : Float = 108.0

///|
/// World layout coordinate for world right.
pub let world_right : Float = Float::from_int(screen_w) - 46.0

///|
/// World layout coordinate for world bottom.
pub let world_bottom : Float = Float::from_int(screen_h) - 46.0

///|
/// Spatial tuning constant for player radius.
pub let player_radius : Float = 14.0

///|
/// Movement or scaling coefficient for player base speed.
pub let player_base_speed : Float = 210.0

///|
/// Movement or scaling coefficient for player sprint mult.
pub let player_sprint_mult : Float = 1.62

///|
/// Movement or scaling coefficient for player carry speed mult.
pub let player_carry_speed_mult : Float = 0.83

///|
/// Maximum value configured for player health max.
pub let player_health_max : Float = 100.0

///|
/// Maximum value configured for player stealth max.
pub let player_stealth_max : Float = 100.0

///|
/// Survival or damage balancing constant for stealth recovery per sec.
pub let stealth_recovery_per_sec : Float = 16.0

///|
/// Survival or damage balancing constant for stealth break damage per sec.
pub let stealth_break_damage_per_sec : Float = 19.0

///|
/// Gameplay tuning constant for sprint noise pressure.
pub let sprint_noise_pressure : Float = 10.0

///|
/// Gameplay tuning constant for sprint stealth burn.
pub let sprint_stealth_burn : Float = 8.0

///|
/// Spatial tuning constant for interaction range.
pub let interaction_range : Float = 36.0

///|
/// Spatial tuning constant for parcel spawn margin.
pub let parcel_spawn_margin : Float = 84.0

///|
/// Spatial tuning constant for exit radius.
pub let exit_radius : Float = 34.0

///|
/// Base value before difficulty or progression scaling for guard speed base.
pub let guard_speed_base : Float = 96.0

///|
/// Per-step progression tuning for guard speed wave gain.
pub let guard_speed_wave_gain : Float = 8.0

///|
/// Movement or scaling coefficient for guard alert speed mult.
pub let guard_alert_speed_mult : Float = 1.35

///|
/// Base value before difficulty or progression scaling for guard cone range base.
pub let guard_cone_range_base : Float = 214.0

///|
/// Per-step progression tuning for guard cone range wave gain.
pub let guard_cone_range_wave_gain : Float = 8.0

///|
/// Base value before difficulty or progression scaling for guard cone half angle base.
pub let guard_cone_half_angle_base : Float = 27.0

///|
/// Base value before difficulty or progression scaling for guard detection base.
pub let guard_detection_base : Float = 14.0

///|
/// Gameplay tuning constant for guard detection peak.
pub let guard_detection_peak : Float = 52.0

///|
/// Timing constant that controls guard alert hold.
pub let guard_alert_hold : Float = 1.5

///|
/// Spatial tuning constant for guard smoke lure range.
pub let guard_smoke_lure_range : Float = 250.0

///|
/// Timing constant that controls guard investigate hold.
pub let guard_investigate_hold : Float = 1.4

///|
/// Spatial tuning constant for guard spawn margin.
pub let guard_spawn_margin : Float = 90.0

///|
/// Base value before difficulty or progression scaling for trap radius base.
pub let trap_radius_base : Float = 18.0

///|
/// Base value before difficulty or progression scaling for trap damage base.
pub let trap_damage_base : Float = 16.0

///|
/// Per-step progression tuning for trap damage wave gain.
pub let trap_damage_wave_gain : Float = 2.5

///|
/// Timing constant that controls trap trigger cooldown.
pub let trap_trigger_cooldown : Float = 1.15

///|
/// Gameplay tuning constant for trap pressure.
pub let trap_pressure : Float = 12.0

///|
/// Spatial tuning constant for trap spawn margin.
pub let trap_spawn_margin : Float = 72.0

///|
/// Base value before difficulty or progression scaling for smoke radius base.
pub let smoke_radius_base : Float = 154.0

///|
/// Timing constant that controls smoke life secs.
pub let smoke_life_secs : Float = 4.8

///|
/// Movement or scaling coefficient for smoke cover factor.
pub let smoke_cover_factor : Float = 0.38

///|
/// Base value before difficulty or progression scaling for smoke stock base.
pub let smoke_stock_base : Int = 2

///|
/// Base value before difficulty or progression scaling for wave target base.
pub let wave_target_base : Int = 2

///|
/// Upper bound for max delivery target in gameplay systems.
pub let max_delivery_target : Int = 7

///|
/// Base value before difficulty or progression scaling for wave time base.
pub let wave_time_base : Float = 74.0

///|
/// Per-step progression tuning for wave time decay.
pub let wave_time_decay : Float = 4.2

///|
/// Timing constant that controls wave min time.
pub let wave_min_time : Float = 35.0

///|
/// Survival or damage balancing constant for wave clear health recover.
pub let wave_clear_health_recover : Float = 12.0

///|
/// Base value before difficulty or progression scaling for wave clear score base.
pub let wave_clear_score_base : Int = 160

///|
/// Progression and scoring constant for wave clear score wave bonus.
pub let wave_clear_score_wave_bonus : Int = 38

///|
/// Movement or scaling coefficient for wave clear time score mult.
pub let wave_clear_time_score_mult : Float = 4.0

///|
/// Mathematical constant pi used for angle calculations.
pub let pi : Float = 3.141592653589793

///|
/// Multiplier that converts degrees into radians.
pub let deg_to_rad : Float = pi / 180.0

///|
/// Multiplier that converts radians into degrees.
pub let rad_to_deg : Float = 180.0 / pi
