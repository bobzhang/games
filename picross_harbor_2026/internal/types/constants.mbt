///|
/// Window width in pixels.
pub let screen_w : Int32 = 1720

///|
/// Window height in pixels.
pub let screen_h : Int32 = 980

///|
/// Fixed update/render target frequency.
pub let target_fps : Int32 = 120

///|
/// Maximum supported puzzle width/height.
pub let max_board : Int32 = 12

///|
/// Maximum number of cells in a puzzle grid.
pub let max_cells : Int32 = max_board * max_board

///|
/// Active tool the player is using to interact with cells.
#derive(Eq)
pub(all) enum ToolKind {
  ToolFill
  ToolCross
}

///|
pub extend ToolKind with Eq::{not_equal, equal}

///|
/// Cell state in the puzzle grid.
#derive(Eq)
pub(all) enum Cell {
  Unknown
  Fill
  Cross
}

///|
pub extend Cell with Eq::{not_equal, equal}

///|
/// Visual spark particle category.
#derive(Eq)
pub(all) enum SparkKind {
  Hint
  Fill
  Error
  Mark
}

///|
pub extend SparkKind with Eq::{not_equal, equal}

///|
/// Direction for cursor movement.
#derive(Eq)
pub(all) enum Dir {
  None
  Left
  Right
  Up
  Down
}

///|
pub extend Dir with Eq::{not_equal, equal}

///|
/// Top-level game/campaign state.
#derive(Eq)
pub(all) enum GameState {
  Title
  Play
  LevelClear
  CampaignClear
  LevelFail
}

///|
pub extend GameState with Eq::{not_equal, equal}
