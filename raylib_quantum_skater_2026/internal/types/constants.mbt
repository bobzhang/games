///|
/// Window width in pixels.
pub let screen_w : Int = 1366

///|
/// Window height in pixels.
pub let screen_h : Int = 768

///|
/// Fixed update/render target frequency.
pub let target_fps : Int = 120

///|
/// Title screen state id.
pub let state_title : Int = 0

///|
/// Active gameplay state id.
pub let state_play : Int = 1

///|
/// Stage-clear transition state id.
pub let state_stage_clear : Int = 2

///|
/// Failure/result state id.
pub let state_game_over : Int = 3

///|
/// Track obstacle type for solid walls.
pub let obj_wall : Int = 0

///|
/// Track collectible type for score orbs.
pub let obj_orb : Int = 1

///|
/// One-way gate that permits only alpha phase.
pub let obj_gate_alpha : Int = 2

///|
/// One-way gate that permits only beta phase.
pub let obj_gate_beta : Int = 3

///|
/// Temporary speed pickup type.
pub let obj_boost : Int = 4

///|
/// Jump assist bar obstacle type.
pub let obj_jump_bar : Int = 5

///|
/// Number of lateral lanes on the track.
pub let lane_count : Int = 5

///|
/// Capacity of active track objects.
pub let max_objs : Int = 360

///|
/// Capacity of particle effects.
pub let max_particles : Int = 460

///|
/// Capacity of after-image trail segments.
pub let max_trails : Int = 180

///|
/// Base forward speed in world units per second.
pub let base_speed : Float = 680.0

///|
/// Additional base speed per stage.
pub let speed_stage_gain : Float = 70.0

///|
/// Initial upward velocity when jumping.
pub let player_jump_speed : Float = 860.0

///|
/// Gravity acceleration applied to the skater.
pub let player_gravity : Float = 2550.0

///|
/// Stage 1 completion distance.
pub let stage_base_distance : Float = 5200.0

///|
/// Extra required distance for each later stage.
pub let stage_distance_growth : Float = 1800.0

///|
/// Phase energy loss per second while phased.
pub let phase_drain_per_sec : Float = 21.0

///|
/// Phase energy recovery per second while unphased.
pub let phase_recover_per_sec : Float = 18.0

///|
/// Cooldown after toggling phase mode.
pub let phase_switch_cd : Float = 0.24

///|
/// Damage invulnerability duration in seconds.
pub let invuln_time : Float = 0.65

///|
/// Time before combo count starts decaying.
pub let combo_decay_time : Float = 3.8
