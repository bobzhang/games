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
#deprecated
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
/// Entire runtime state for one 2048 session, including the board grid,
/// score tracking, undo history, animation progress, and UI messages.
pub(all) struct Game {
  // ──── Board state ────
  /// 4x4 board stored as a flat 16-element array in row-major order.
  /// Index = row * grid_size + col. Each `Tile` holds a power-of-two value
  /// (0 means empty) plus per-tile animation fields.
  /// Read by the renderer; written by `try_move` and `spawn_tile`.
  tiles : Array[Tile]
  /// Snapshot of every tile's `.value` taken just before the last move.
  /// Used by `undo` to restore the board. Length is always `cell_count` (16).
  prev_values : Array[Int]
  // ──── Core state ────
  /// Which screen/phase the game is currently in.
  /// Possible values: `Title`, `Play`, `Won`, `Over`.
  /// The main update loop dispatches to different input/render logic based
  /// on this value.
  mut state : GameState
  /// Points earned in the current session from merging tiles.
  /// Increases by the merged tile's new value on each merge.
  /// Displayed in the score card; compared against `best_score` after moves.
  mut score : Int
  /// Highest score ever reached across all sessions (not persisted to disk).
  /// Updated after every successful move when `score` exceeds it.
  mut best_score : Int
  /// Score snapshot taken alongside `prev_values` before the last move.
  /// Restored by `undo` to revert the score together with the board.
  mut prev_score : Int
  /// Whether an undo operation is available (true after a successful move,
  /// cleared after undoing). Guards the `undo` action in input handling.
  mut can_undo : Bool
  // ──── Animation ────
  /// True while any tile's slide position or pop scale has not yet reached
  /// its target. While true, `handle_play_input` blocks new moves so
  /// animations finish before the next slide begins.
  mut animating : Bool
  // ──── UI messages ────
  /// Temporary status message shown to the player (e.g. "Undo").
  /// Set by `undo`; cleared when `msg_t` expires.
  mut msg : String
  /// Seconds remaining before `msg` is cleared.
  /// Decremented each frame in `update_animations`; when it reaches 0,
  /// `msg` is set to the empty string.
  mut msg_t : Float
  // ──── Win continuation ────
  /// When true the player has chosen to continue playing after reaching
  /// the 2048 tile. Prevents the `Won` state from re-triggering and lets
  /// the player keep merging toward higher tiles.
  mut keep_playing : Bool

  fn new() -> Game
}

///|
/// Allocates a fresh game state with cleared board and score counters.
#deprecated
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
