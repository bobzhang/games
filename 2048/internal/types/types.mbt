///|
/// High-level phase of a 2048 run.
pub(all) enum GameState {
  Title
  Play
  Won
  Over
} derive(Eq)

///|
/// Mutable tile data used for value storage and render animation.
pub(all) struct Tile {
  mut value : Int
  mut anim_x : Float
  mut anim_y : Float
  mut target_x : Float
  mut target_y : Float
  mut scale : Float
  mut is_new : Bool
  mut is_merged : Bool

  fn new() -> Tile
}

///|
/// Creates an empty tile with neutral animation state.
pub fn Tile::new() -> Tile {
  {
    value: 0,
    anim_x: 0.0,
    anim_y: 0.0,
    target_x: 0.0,
    target_y: 0.0,
    scale: 1.0,
    is_new: false,
    is_merged: false,
  }
}

///|
/// Entire runtime state for one 2048 session.
pub(all) struct Game {
  /// 4x4 board stored as a flat 16-element array (row-major order).
  tiles : Array[Tile]
  /// Snapshot of tile values before the last move, used for undo.
  prev_values : Array[Int]
  /// Current phase of the game (title screen, playing, won, or game over).
  mut state : GameState
  /// Points earned in the current session from merging tiles.
  mut score : Int
  /// Highest score ever reached across all sessions.
  mut best_score : Int
  /// Score before the last move, restored on undo.
  mut prev_score : Int
  /// Whether an undo operation is available.
  mut can_undo : Bool
  /// True while tile slide/pop animations are still interpolating.
  mut animating : Bool
  /// Temporary status message shown to the player (e.g. "Undo").
  mut msg : String
  /// Seconds remaining before the status message fades out.
  mut msg_t : Float
  /// When true the player continues after reaching 2048.
  mut keep_playing : Bool

  fn new() -> Game
}

///|
/// Allocates a fresh game state with cleared board and score counters.
pub fn Game::new() -> Game {
  let g : Game = {
    tiles: Array::makei(cell_count, _i => Tile()),
    prev_values: Array::make(cell_count, 0),
    state: Title,
    score: 0,
    best_score: 0,
    prev_score: 0,
    can_undo: false,
    animating: false,
    msg: "",
    msg_t: 0.0,
    keep_playing: false,
  }
  g
}
