///|
/// Width of the game window in pixels.
pub let screen_w : Int = 1280

///|
/// Height of the game window in pixels.
pub let screen_h : Int = 720

///|
/// Target frame rate used by the game loop.
pub let target_fps : Int = 120

///|
/// Integer id representing the title screen state.
pub let state_title : Int = 0

///|
/// Integer id representing active gameplay.
pub let state_play : Int = 1

///|
/// Integer id representing the stage clear intermission.
pub let state_stage_clear : Int = 2

///|
/// Integer id representing the game over state.
pub let state_game_over : Int = 3

///|
/// Obstacle type id for rooftop vents.
pub let obstacle_vent : Int = 0

///|
/// Obstacle type id for neon sign hazards.
pub let obstacle_sign : Int = 1

///|
/// Obstacle type id for patrolling drones.
pub let obstacle_drone : Int = 2

///|
/// Obstacle type id for laser gates.
pub let obstacle_laser : Int = 3

///|
/// Maximum rooftop segments allocated in the segment pool.
pub let max_segments : Int = 96

///|
/// Maximum obstacles allocated in the obstacle pool.
pub let max_obstacles : Int = 160

///|
/// Maximum collectible chips allocated in the chip pool.
pub let max_chips : Int = 220

///|
/// Maximum grapple anchors allocated in the anchor pool.
pub let max_anchors : Int = 80

///|
/// Maximum particles allocated for visual effects.
pub let max_particles : Int = 320

///|
/// Gravity acceleration applied to the player.
pub let world_gravity : Float = 2120.0

///|
/// Initial upward velocity used for a ground jump.
pub let jump_speed : Float = -780.0

///|
/// Initial upward velocity used for an air jump.
pub let double_jump_speed : Float = -720.0

///|
/// Duration of a slide action in seconds.
pub let slide_duration : Float = 0.40

///|
/// Duration of grapple pull movement in seconds.
pub let grapple_duration : Float = 0.34

///|
/// Grace period after leaving ground where jump is still allowed.
pub let coyote_time : Float = 0.10

///|
/// Buffered jump input lifetime in seconds.
pub let jump_buffer_time : Float = 0.12

///|
/// Invulnerability duration after taking damage.
pub let invuln_time : Float = 0.70

///|
/// Flash duration used for hurt feedback.
pub let hurt_flash_time : Float = 0.24

///|
/// Intro delay at the start of each stage.
pub let stage_intro_time : Float = 1.30

///|
/// Base horizontal scroll speed for stage one.
pub let base_scroll_speed : Float = 390.0

///|
/// Additional base speed added each stage.
pub let speed_per_stage : Float = 32.0

///|
/// Per-second speed ramp while a stage is running.
pub let speed_ramp_per_second : Float = 2.6

///|
/// Distance objective required for the first stage.
pub let stage_base_goal : Float = 1650.0

///|
/// Additional stage objective distance per stage.
pub let stage_goal_growth : Float = 620.0

///|
/// Initial player X coordinate at run start.
pub let player_spawn_x : Float = 210.0

///|
/// Initial player Y coordinate at run start.
pub let player_spawn_y : Float = 390.0

///|
/// Side length of on-screen touch control buttons.
pub let ui_button_size : Float = 104.0

///|
/// Horizontal spacing between touch buttons.
pub let ui_button_gap : Float = 14.0

///|
/// Particle kind id for short spark bursts.
pub let particle_spark : Int = 0

///|
/// Particle kind id for neon glow motes.
pub let particle_glow : Int = 1

///|
/// Particle kind id for damage burst effects.
pub let particle_hurt : Int = 2

///|
/// Number of skyline parallax layers to draw.
pub let skyline_layers : Int = 3
