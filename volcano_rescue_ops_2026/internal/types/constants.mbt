///|
/// Width of the game window in pixels.
pub let screen_w : Int = 1680

///|
/// Height of the game window in pixels.
pub let screen_h : Int = 960

///|
/// Target frame rate for simulation and rendering.
pub let target_fps : Int = 120

///|
/// Number of grid columns in the mission map.
pub let grid_w : Int = 15

///|
/// Number of grid rows in the mission map.
pub let grid_h : Int = 10

///|
/// Total number of map cells.
pub let max_cells : Int = grid_w * grid_h

///|
/// Maximum number of civilian sites stored in the pool.
pub let max_sites : Int = 12

///|
/// Maximum number of planned route steps.
pub let max_route_steps : Int = 96

///|
/// Number of mission levels in the campaign.
pub let level_count : Int = 3

///|
/// X-coordinate of the map origin in screen pixels.
pub let map_x : Int = 44

///|
/// Y-coordinate of the map origin in screen pixels.
pub let map_y : Int = 124

///|
/// Size of one map tile in pixels.
pub let tile_size : Int = 56

///|
/// Left edge of the mission control panel.
pub let panel_x : Int = map_x + grid_w * tile_size + 32

///|
/// Width of the mission control panel.
pub let panel_w : Int = screen_w - panel_x - 24

///|
/// Maximum number of civilians that can be carried at once.
pub let vehicle_capacity : Int = 6

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
/// Game outcome.
pub(all) enum GameResult {
  None
  Win
  Lose
} derive(Eq)

///|
/// Current game state.
pub(all) enum GameState {
  Title
  Play
  Result
} derive(Eq)

///|
/// Map tile type.
pub(all) enum Tile {
  Ground
  Rock
  Depot
  Shelter
} derive(Eq)
