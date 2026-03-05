///|
/// Width of the game window in pixels.
pub let screen_w : Int = 1600

///|
/// Height of the game window in pixels.
pub let screen_h : Int = 960

///|
/// Target frame rate used by the game loop.
pub let target_fps : Int = 120

///|
/// Threat id for fast firecracker projectiles.
pub let threat_firecracker : Int = 0

///|
/// Threat id for heavier street incidents.
pub let threat_incident : Int = 1

///|
/// Number of parade lanes.
pub let lane_count : Int = 6

///|
/// Top pixel coordinate of the first lane.
pub let lane_top : Int = 170

///|
/// Vertical spacing between lane centers in pixels.
pub let lane_gap : Int = 108

///|
/// Visual lane height in pixels.
pub let lane_height : Int = 70

///|
/// Left boundary of the defended street.
pub let street_left : Int = 120

///|
/// Right boundary of the defended street.
pub let street_right : Int = 1480

///|
/// Width of the lion troupe hitbox.
pub let troupe_w : Float = 96.0

///|
/// Horizontal movement speed of the troupe.
pub let troupe_move_speed : Float = 620.0

///|
/// Initial lane index for the troupe.
pub let troupe_start_lane : Int = 2

///|
/// Maximum concurrent threats allocated in the pool.
pub let max_threats : Int = 96

///|
/// Initial spawn interval at the beginning of a run.
pub let spawn_time_start : Float = 1.00

///|
/// Minimum spawn interval at high difficulty.
pub let spawn_time_floor : Float = 0.24

///|
/// Spawn interval reduction per second of elapsed time.
pub let spawn_difficulty_ramp : Float = 0.010

///|
/// Base speed for firecracker threats.
pub let firecracker_speed_base : Float = 350.0

///|
/// Base speed for incident threats.
pub let incident_speed_base : Float = 260.0

///|
/// Maximum bonus applied to threat speed scaling.
pub let speed_scale_max_bonus : Float = 240.0

///|
/// Strike action radius around the troupe.
pub let strike_radius : Float = 132.0

///|
/// Cooldown duration for strike action.
pub let strike_cd_time : Float = 0.24

///|
/// Visual effect duration for strike action.
pub let strike_fx_time : Float = 0.15

///|
/// Guard action radius around the troupe.
pub let guard_radius : Float = 150.0

///|
/// Cooldown duration for guard action.
pub let guard_cd_time : Float = 0.72

///|
/// Hold duration while guard stance is active.
pub let guard_hold_time : Float = 0.40

///|
/// Stun duration applied by successful guard.
pub let guard_stun_time : Float = 1.80

///|
/// Hype resource cost for burst action.
pub let burst_cost : Float = 62.0

///|
/// Active duration of burst action.
pub let burst_duration : Float = 0.92

///|
/// Radius of burst action effect.
pub let burst_radius : Float = 320.0

///|
/// Cooldown duration after using burst.
pub let burst_cd_time : Float = 6.2

///|
/// Maximum hype meter value.
pub let hype_max : Float = 100.0

///|
/// Maximum morale meter value.
pub let morale_max : Float = 100.0

///|
/// Maximum crowd-order meter value.
pub let order_max : Float = 100.0

///|
/// Starting morale at the beginning of a run.
pub let morale_start : Float = 82.0

///|
/// Starting crowd-order at the beginning of a run.
pub let order_start : Float = 84.0

///|
/// Time window to keep combo chain active.
pub let combo_keep_time : Float = 2.6

///|
/// Crowd-order gain when clearing a threat.
pub let order_gain_on_clear : Float = 2.0

///|
/// Passive crowd-order recovery per second.
pub let order_recover_rate : Float = 2.2

///|
/// Order threshold below which pressure drain starts.
pub let order_pressure_threshold : Float = 42.0

///|
/// Additional order drain rate under pressure.
pub let order_pressure_drain_rate : Float = 0.29

///|
/// Crowd-order loss when a firecracker breaches defense.
pub let breach_order_loss_firecracker : Float = 11.0

///|
/// Crowd-order loss when an incident breaches defense.
pub let breach_order_loss_incident : Float = 16.0

///|
/// Morale loss when a firecracker breaches defense.
pub let breach_morale_loss_firecracker : Float = 7.0

///|
/// Morale loss when an incident breaches defense.
pub let breach_morale_loss_incident : Float = 10.0

///|
/// Morale loss when colliding with a firecracker.
pub let collision_morale_loss_firecracker : Float = 8.0

///|
/// Morale loss when colliding with an incident.
pub let collision_morale_loss_incident : Float = 11.0

///|
/// Score awarded for clearing a firecracker.
pub let score_firecracker : Int = 120

///|
/// Score awarded for clearing an incident.
pub let score_incident : Int = 170

///|
/// Bonus score for stunning via guard.
pub let score_guard_stun : Int = 24

///|
/// Hype gained when clearing a firecracker.
pub let hype_gain_firecracker : Float = 8.0

///|
/// Hype gained when clearing an incident.
pub let hype_gain_incident : Float = 12.0

///|
/// Hype gained when a guard stun lands.
pub let hype_gain_guard_stun : Float = 4.0

///|
/// Additional hype gained per combo step.
pub let hype_gain_combo_step : Float = 1.6

///|
/// Lifetime of transient HUD messages in seconds.
pub let msg_ttl : Float = 1.6
