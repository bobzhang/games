///|
/// Window width in pixels.
pub let screen_width : Int = 1280

///|
/// Window height in pixels.
pub let screen_height : Int = 720

///|
/// HUD band height in pixels.
pub let hud_height : Int = 84

///|
/// Size of one tile in pixels.
pub let tile_size : Int = 32

///|
/// Size of one tile as a float value.
pub let tile_size_f : Float = 32.0

///|
/// Number of horizontal tiles in the level.
pub let world_tiles_w : Int = 236

///|
/// Number of vertical tiles in the level.
pub let world_tiles_h : Int = 22

///|
/// Total level width in pixels.
pub let world_width_px : Float = Float::from_int(world_tiles_w * tile_size)

///|
/// Total level height in pixels.
pub let world_height_px : Float = Float::from_int(world_tiles_h * tile_size)

///|
/// Tile row index used for baseline ground.
pub let ground_row : Int = 17

///|
/// Player collision width.
pub let player_w : Float = 24.0

///|
/// Player collision height.
pub let player_h : Float = 30.0

///|
/// Player spawn x-coordinate at run start.
pub let player_start_x : Float = 3.0 * tile_size_f

///|
/// Downward acceleration applied each frame.
pub let gravity : Float = 2150.0

///|
/// Horizontal acceleration while grounded.
pub let run_accel_ground : Float = 2300.0

///|
/// Horizontal acceleration while airborne.
pub let run_accel_air : Float = 1500.0

///|
/// Ground friction deceleration.
pub let run_friction : Float = 2700.0

///|
/// Maximum horizontal running speed.
pub let max_run_speed : Float = 270.0

///|
/// Maximum downward velocity.
pub let max_fall_speed : Float = 950.0

///|
/// Initial jump velocity.
pub let jump_speed : Float = 760.0

///|
/// Vertical bounce velocity after stomping an enemy.
pub let stomp_bounce_speed : Float = 510.0

///|
/// Coyote-time window after leaving ground.
pub let coyote_time : Float = 0.09

///|
/// Jump-input buffering window.
pub let jump_buffer_time : Float = 0.11

///|
/// Gravity multiplier when jump is released early.
pub let jump_cut_multiplier : Float = 0.52

///|
/// Invulnerability duration after taking damage.
pub let player_invuln_time : Float = 1.3

///|
/// Starting level timer value in seconds.
pub let start_time_seconds : Int = 400

///|
/// Sliding speed down the flagpole.
pub let flag_slide_speed : Float = 210.0

///|
/// Auto-walk speed toward the castle after flag clear.
pub let castle_walk_speed : Float = 130.0

///|
/// Camera follow smoothing factor.
pub let camera_lerp : Float = 9.0

///|
/// Horizontal camera look-ahead distance.
pub let camera_lead_px : Float = 165.0

///|
/// Enemy collision width.
pub let enemy_w : Float = 24.0

///|
/// Enemy collision height.
pub let enemy_h : Float = 22.0

///|
/// Default enemy walk speed.
pub let enemy_speed : Float = 88.0

///|
/// Maximum enemies tracked in the pool.
pub let max_enemies : Int = 56

///|
/// Maximum coin entities tracked in the pool.
pub let max_coins : Int = 256

///|
/// Maximum particles tracked in the pool.
pub let max_particles : Int = 720

///|
/// Score gained when collecting a coin.
pub let coin_collect_score : Int = 200

///|
/// Score gained when stomping an enemy.
pub let stomp_score : Int = 400

///|
/// Score gained when hitting a block.
pub let block_hit_score : Int = 50

///|
/// Game state machine phases.
pub(all) enum GameState {
  Title
  Playing
  Win
  GameOver
} derive(Eq, Show)

///|
/// Tile types used in the level grid.
pub(all) enum Tile {
  Empty
  Ground
  Brick
  Question
  Used
  Pipe
  FlagPole
  Castle
} derive(Eq)
