///|
/// Window width in pixels.
pub let screen_w : Int = 1720

///|
/// Window height in pixels.
pub let screen_h : Int = 980

///|
/// Fixed update/render target frequency.
pub let target_fps : Int = 120

///|
/// Maximum supported puzzle width/height.
pub let max_board : Int = 12

///|
/// Maximum number of cells in a puzzle grid.
pub let max_cells : Int = max_board * max_board

///|
/// Active tool the player is using to interact with cells.
pub(all) enum ToolKind {
  ToolFill
  ToolCross
} derive(Eq)


///|
/// Cell state in the puzzle grid.
pub(all) enum Cell {
  Unknown
  Fill
  Cross
} derive(Eq)

///|
/// Direction for cursor movement.
pub(all) enum Dir {
  None
  Left
  Right
  Up
  Down
} derive(Eq)

///|
/// Top-level game/campaign state.
pub(all) enum GameState {
  Title
  Play
  LevelClear
  CampaignClear
  LevelFail
} derive(Eq)
