///|
/// Width of the game window in pixels.
pub let screen_w : Int32 = 1820

///|
/// Height of the game window in pixels.
pub let screen_h : Int32 = 1000

///|
/// Target frame rate for simulation and rendering.
pub let target_fps : Int32 = 120

///|
/// Left edge of the train board in screen pixels.
pub let board_x0 : Int32 = 28

///|
/// Top edge of the train board in screen pixels.
pub let board_y0 : Int32 = 86

///|
/// Size of one board cell in pixels.
pub let cell : Int32 = 58

///|
/// Number of board columns.
pub let grid_w : Int32 = 27

///|
/// Number of board rows.
pub let grid_h : Int32 = 13

///|
/// Total board width in pixels.
pub let board_w : Int32 = grid_w * cell

///|
/// Total board height in pixels.
pub let board_h : Int32 = grid_h * cell

///|
/// Left edge of the information panel.
pub let panel_x0 : Int32 = board_x0 + board_w + 20

///|
/// Width of the information panel.
pub let panel_w : Int32 = screen_w - panel_x0 - 20

///|
/// Maximum guard count allocated in the guard pool.
pub let max_guards : Int32 = 6

///|
/// Maximum loot item count allocated in the loot pool.
pub let max_loot : Int32 = 8

///|
/// Maximum number of active smoke clouds.
pub let max_smokes : Int32 = 5

///|
/// Maximum number of particles allocated in the effect pool.
pub let max_particles : Int32 = 420

///|
/// Number of loot items required to unlock extraction.
pub let loot_need : Int32 = 6

///|
/// Starting tile x-coordinate for the player.
pub let start_x : Int32 = 2

///|
/// Starting tile y-coordinate for the player.
pub let start_y : Int32 = 6

///|
/// Exit tile x-coordinate.
pub let exit_x : Int32 = grid_w - 2

///|
/// Exit tile y-coordinate.
pub let exit_y : Int32 = 6

///|
/// Seconds needed to complete one player tile move.
pub let player_move_t : Float = 0.11

///|
/// Seconds needed to complete one guard tile move.
pub let guard_move_t : Float = 0.15

///|
/// Lifetime of a deployed smoke cloud, in seconds.
pub let smoke_ttl : Float = 4.8

///|
/// Maximum run duration before automatic failure, in seconds.
pub let run_time_limit : Float = 210.0

///|
/// Smoke energy cost for each smoke deployment.
pub let smoke_cost : Float = 34.0

///|
/// Score awarded for collecting a blueprint.
pub let score_blueprint : Int32 = 280

///|
/// Score awarded for collecting a keycard.
pub let score_keycard : Int32 = 360

///|
/// Score awarded for collecting gold.
pub let score_gold : Int32 = 180

///|
/// Score awarded when escaping successfully.
pub let score_escape : Int32 = 1200
