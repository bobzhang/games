///|
/// Width of the game window in pixels.
pub let screen_w : Int32 = 1680

///|
/// Height of the game window in pixels.
pub let screen_h : Int32 = 960

///|
/// Target frame rate for simulation and rendering.
pub let target_fps : Int32 = 120

///|
/// Number of grid columns in the mission map.
pub let grid_w : Int32 = 15

///|
/// Number of grid rows in the mission map.
pub let grid_h : Int32 = 10

///|
/// Total number of map cells.
pub let max_cells : Int32 = grid_w * grid_h

///|
/// Maximum number of civilian sites stored in the pool.
pub let max_sites : Int32 = 12

///|
/// Maximum number of planned route steps.
pub let max_route_steps : Int32 = 96

///|
/// Number of mission levels in the campaign.
pub let level_count : Int32 = 3

///|
/// X-coordinate of the map origin in screen pixels.
pub let map_x : Int32 = 44

///|
/// Y-coordinate of the map origin in screen pixels.
pub let map_y : Int32 = 124

///|
/// Size of one map tile in pixels.
pub let tile_size : Int32 = 56

///|
/// Left edge of the mission control panel.
pub let panel_x : Int32 = map_x + grid_w * tile_size + 32

///|
/// Width of the mission control panel.
pub let panel_w : Int32 = screen_w - panel_x - 24

///|
/// Maximum number of civilians that can be carried at once.
pub let vehicle_capacity : Int32 = 6

///|
/// Maximum allowed vehicle heat.
pub let max_heat : Float = 100.0

///|
/// Maximum fuel capacity.
pub let max_fuel : Float = 100.0

///|
/// Maximum coolant capacity.
pub let max_coolant : Float = 100.0

///|
/// Fuel consumed per executed route step.
pub let move_fuel_cost : Float = 6.0

///|
/// Heat gained per executed route step.
pub let move_heat_gain : Float = 4.8

///|
/// Time interval between route steps, in seconds.
pub let step_interval : Float = 0.22

///|
/// Movement direction.
pub(all) enum Dir {
  None
  Up
  Down
  Left
  Right
} derive(Eq)

///|
pub extend Dir with Eq::{not_equal, equal}

///|
/// Game outcome.
pub(all) enum GameResult {
  None
  Win
  Lose
} derive(Eq)

///|
pub extend GameResult with Eq::{not_equal, equal}

///|
/// Current game state.
pub(all) enum GameState {
  Title
  Play
  Result
} derive(Eq)

///|
pub extend GameState with Eq::{not_equal, equal}

///|
/// Map tile type.
pub(all) enum Tile {
  Ground
  Rock
  Depot
  Shelter
} derive(Eq)

///|
pub extend Tile with Eq::{not_equal, equal}
