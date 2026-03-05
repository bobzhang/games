///|
/// Width of the game window in pixels.
pub let screen_w : Int = 1780

///|
/// Height of the game window in pixels.
pub let screen_h : Int = 1000

///|
/// Target frame rate used by the simulation loop.
pub let target_fps : Int = 120

///|
/// Left edge of the board area in pixels.
pub let board_x0 : Int = 28

///|
/// Top edge of the board area in pixels.
pub let board_y0 : Int = 86

///|
/// Size of one grid cell in pixels.
pub let cell : Int = 60

///|
/// Number of grid columns on the board.
pub let grid_w : Int = 23

///|
/// Number of grid rows on the board.
pub let grid_h : Int = 13

///|
/// Width of the playable board area in pixels.
pub let board_w : Int = grid_w * cell

///|
/// Height of the playable board area in pixels.
pub let board_h : Int = grid_h * cell

///|
/// Left edge of the side panel in pixels.
pub let panel_x0 : Int = board_x0 + board_w + 24

///|
/// Width of the side panel in pixels.
pub let panel_w : Int = screen_w - panel_x0 - 24

///|
/// Integer id for the title screen state.
pub let state_title : Int = 0

///|
/// Integer id for active gameplay.
pub let state_play : Int = 1

///|
/// Integer id for the result screen state.
pub let state_result : Int = 2

///|
/// Tile id for an impassable wall cell.
pub let tile_wall : Int = 0

///|
/// Tile id for normal walkable floor.
pub let tile_floor : Int = 1

///|
/// Tile id for the extraction exit cell.
pub let tile_exit : Int = 2

///|
/// Drone mode id for patrol behavior.
pub let drone_patrol : Int = 0

///|
/// Drone mode id for chase behavior.
pub let drone_hunt : Int = 1

///|
/// Drone mode id for temporary stun behavior.
pub let drone_stunned : Int = 2

///|
/// Maximum drones allocated in the drone pool.
pub let max_drones : Int = 5

///|
/// Maximum portal cores allocated in the core pool.
pub let max_cores : Int = 8

///|
/// Maximum active flare devices allocated.
pub let max_flares : Int = 6

///|
/// Maximum particles allocated for visual effects.
pub let max_particles : Int = 420

///|
/// Number of cores required to activate the exit.
pub let core_need : Int = 6

///|
/// Number of lives available at run start.
pub let max_lives : Int = 3

///|
/// Time limit for one blackout round in seconds.
pub let round_time_limit : Float = 210.0

///|
/// Player start cell X coordinate.
pub let start_x : Int = 2

///|
/// Player start cell Y coordinate.
pub let start_y : Int = 11

///|
/// Exit cell X coordinate.
pub let exit_x : Int = 21

///|
/// Exit cell Y coordinate.
pub let exit_y : Int = 1

///|
/// Portal A cell X coordinate.
pub let portal_ax : Int = 4

///|
/// Portal A cell Y coordinate.
pub let portal_ay : Int = 10

///|
/// Portal B cell X coordinate.
pub let portal_bx : Int = 18

///|
/// Portal B cell Y coordinate.
pub let portal_by : Int = 3

///|
/// Duration of one player tile move in seconds.
pub let player_move_t : Float = 0.105

///|
/// Duration of one drone tile move in seconds.
pub let drone_move_t : Float = 0.150

///|
/// Lifetime of an active flare in seconds.
pub let flare_ttl : Float = 4.2

///|
/// Flare energy cost consumed per activation.
pub let flare_cost : Float = 34.0

///|
/// Stun duration applied by a flare pulse.
pub let flare_stun_t : Float = 2.3

///|
/// Score gained when collecting one core.
pub let score_core : Int = 180

///|
/// Score gained when using a portal teleport.
pub let score_teleport : Int = 90

///|
/// Score gained when stunning a drone.
pub let score_stun : Int = 60

///|
/// Bonus score granted on successful escape.
pub let score_win : Int = 1100
