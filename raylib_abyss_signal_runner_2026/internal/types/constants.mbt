///|
/// Width of the game window in pixels.
pub let screen_w : Int = 1280

///|
/// Height of the game window in pixels.
pub let screen_h : Int = 720

///|
/// Target frame rate used by the simulation loop.
pub let target_fps : Int = 120

///|
/// Maximum world objects allocated in the object pool.
pub let max_objs : Int = 420

///|
/// Maximum particles allocated in the particle pool.
pub let max_particles : Int = 560

///|
/// Maximum sonar ripple effects allocated.
pub let max_ripples : Int = 64

///|
/// Maximum trail segments allocated for movement streaks.
pub let max_trails : Int = 180

///|
/// Collision radius of the player submarine.
pub let player_r : Float = Float::from_int(22)

///|
/// Baseline forward scroll speed for stage one.
pub let base_scroll : Float = Float::from_int(210)

///|
/// Additional scroll speed added per cleared stage.
pub let stage_scroll_gain : Float = Float::from_int(24)

///|
/// Player acceleration magnitude in world units per second squared.
pub let player_accel : Float = Float::from_int(920)

///|
/// Drag coefficient applied to player velocity each frame.
pub let player_drag : Float = Float::from_int(2)

///|
/// Maximum clamped player speed magnitude.
pub let player_max_speed : Float = Float::from_int(360)

///|
/// Oxygen depletion rate per second during normal play.
pub let oxygen_drain : Float = Float::from_int(3)

///|
/// Oxygen restored when collecting one data shard.
pub let oxygen_data_bonus : Float = Float::from_int(2)

///|
/// Oxygen restored when collecting one oxygen pickup.
pub let oxygen_pickup : Float = Float::from_int(24)

///|
/// Cooldown duration between sonar casts.
pub let sonar_cd_time : Float = 2.1

///|
/// Active duration of the sonar pulse effect.
pub let sonar_time : Float = 0.76

///|
/// Reveal radius used by sonar for cloaked hazards.
pub let sonar_reveal_r : Float = Float::from_int(220)

///|
/// Destruction radius used by sonar against nearby hazards.
pub let sonar_destroy_r : Float = Float::from_int(70)

///|
/// Cooldown duration between dash activations.
pub let dash_cd_time : Float = 1.3

///|
/// Active duration of the dash state.
pub let dash_time : Float = 0.19

///|
/// Velocity override while dash is active.
pub let dash_speed : Float = Float::from_int(560)

///|
/// Temporary invulnerability duration after taking damage.
pub let invuln_time : Float = 0.62

///|
/// Distance target required to clear the first stage.
pub let stage_base_goal : Float = Float::from_int(1900)

///|
/// Additional stage distance goal added per stage.
pub let stage_goal_gain : Float = Float::from_int(620)

///|
/// Delay before transitioning after a stage clear.
pub let stage_clear_delay : Float = 1.8

///|
/// Initial Y depth used by the spawn scheduler.
pub let spawn_start_y : Float = -120.0

///|
/// Minimum spacing between spawned objects in depth units.
pub let spawn_spacing_min : Float = 70.0

///|
/// Maximum spacing between spawned objects in depth units.
pub let spawn_spacing_max : Float = 170.0

///|
/// Minimum half-width allowed for the cave corridor.
pub let cave_min_half : Float = Float::from_int(150)

///|
/// Maximum half-width allowed for the cave corridor.
pub let cave_max_half : Float = Float::from_int(290)

///|
/// Horizontal safety margin from the screen edges for cave walls.
pub let cave_x_margin : Float = Float::from_int(84)
