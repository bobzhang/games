///|
/// Width of the game window in pixels.
pub let screen_w : Int = 1840

///|
/// Height of the game window in pixels.
pub let screen_h : Int = 1010

///|
/// Target frame rate used by the main loop.
pub let target_fps : Int = 120

///|
/// Left edge of the board area in screen pixels.
pub let board_x0 : Int = 26

///|
/// Top edge of the board area in screen pixels.
pub let board_y0 : Int = 84

///|
/// Size of a single board cell in pixels.
pub let cell : Int = 56

///|
/// Number of cells across the subway grid.
pub let grid_w : Int = 25

///|
/// Number of cells down the subway grid.
pub let grid_h : Int = 13

///|
/// Width of the board play area in pixels.
pub let board_w : Int = grid_w * cell

///|
/// Height of the board play area in pixels.
pub let board_h : Int = grid_h * cell

///|
/// Left edge of the side control panel in pixels.
pub let panel_x0 : Int = board_x0 + board_w + 24

///|
/// Width of the side control panel in pixels.
pub let panel_w : Int = screen_w - panel_x0 - 24

///|
/// Number of horizontal train lanes that can carry traffic.
pub let train_lane_n : Int = 3

///|
/// Number of route junction columns on the board.
pub let junction_n : Int = 4

///|
/// Maximum train instances allocated in the train pool.
pub let max_trains : Int = 24

///|
/// Maximum inspector instances allocated in the inspector pool.
pub let max_inspectors : Int = 3

///|
/// Maximum particle instances allocated in the effect pool.
pub let max_particles : Int = 420

///|
/// Number of lives available at the start of a run.
pub let max_lives : Int = 3

///|
/// Required count of correctly routed trains to win.
pub let goal_routed : Int = 20

///|
/// Time limit for a play round in seconds.
pub let round_time_limit : Float = 210.0

///|
/// X coordinate where trains are considered successfully exited.
pub let train_exit_x : Float = 23.4

///|
/// X coordinate used when spawning new trains.
pub let train_spawn_x : Float = 1.0

///|
/// Duration of one player tile move in seconds.
pub let player_move_t : Float = 0.105

///|
/// Duration of one inspector tile move in seconds.
pub let inspector_move_t : Float = 0.145

///|
/// EMP energy cost consumed per EMP activation.
pub let emp_cost : Float = 35.0

///|
/// Score gained for routing a train to its target lane.
pub let score_route_ok : Int = 120

///|
/// Score penalty for routing a train to the wrong lane.
pub let score_route_bad : Int = -70

///|
/// Score gained when toggling a junction signal.
pub let score_toggle : Int = 20

///|
/// Score gained when an EMP stun hits an inspector.
pub let score_emp_hit : Int = 50

///|
/// Bonus score granted on a successful run.
pub let score_win_bonus : Int = 1000

///|
/// Player starting X cell on the board.
pub let start_x : Int = 2

///|
/// Player starting Y cell on the board.
pub let start_y : Int = 10
