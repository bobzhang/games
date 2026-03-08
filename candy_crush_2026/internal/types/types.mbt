///|
/// High-level phase of a candy-crush session.
pub(all) enum GameState {
  Title
  Play
  LevelClear
  GameOver
} derive(Eq)

///|
/// Full mutable game state for a candy-crush session, including the board grid,
/// match/cascade logic buffers, UI overlays, input tracking, and scoring.
pub(all) struct Game {
  // ──── Board data (flat arrays indexed by `idx(x, y)`, length = board_cells) ────
  /// Candy colour index for each cell. Range `[0, candy_kinds)` for a live candy;
  /// `-1` means the cell is empty (cleared). Written by cascade/refill logic,
  /// read by match scanning, rendering, and hint search.
  kinds : Array[Int]
  /// Special-candy marker on each cell. `None` for a normal candy; `Row`, `Col`,
  /// or `Bomb` for line-clear or area-clear specials. Set when a match of 4+
  /// is resolved; consumed during `expand_special_marks`.
  specials : Array[Special]
  /// Jelly layer count per cell. `0` = no jelly; `1` = one layer remaining.
  /// Decremented when the cell is cleared; the level is won when every jelly
  /// cell reaches 0. Assigned by `assign_jelly_targets` at level start.
  jelly : Array[Int]
  /// Per-cell flash brightness used for clear/spawn animations.
  /// Set to `1.0` on clear or special spawn, decays toward `0.0` each frame.
  /// Read by the renderer to draw a white overlay on the cell.
  flash : Array[Float]
  /// Temporary per-cell flag set by `scan_and_mark_matches` to indicate which
  /// cells are part of the current match group. Cleared before each scan pass.
  marks : Array[Bool]
  /// Pending special-candy type to spawn at each cell after the current match
  /// is resolved. Written by `mark_horizontal_run` / `mark_vertical_run` for
  /// runs of 4 or 5+; consumed by `remove_marked_cells`.
  spawn_special : Array[Special]
  // ──── Core session state ────
  /// Which screen/phase the game is currently in.
  /// Possible values: `Title`, `Play`, `LevelClear`, `GameOver`.
  /// The main update loop dispatches to different input/render logic based on this.
  mut state : GameState
  /// Current level number, starting at 1. Incremented on level clear.
  /// Affects the move budget (`moves_base + (level-1) * moves_level_bonus`)
  /// and the jelly target count.
  mut level : Int
  /// Cumulative score for the current run. Increased by match cascades;
  /// the formula is `cleared * (42 + chain * 18)` per cascade step.
  mut score : Int
  /// Highest score achieved across all runs in this session.
  /// Updated whenever `score` exceeds it, displayed on the side panel
  /// and result overlay.
  mut best_score : Int
  /// Longest cascade chain achieved during the current run.
  /// Updated after each cascade step; displayed on the HUD and result screen.
  mut chain_best : Int
  /// Number of swap moves the player has left before game over.
  /// Starts at `moves_base + (level-1) * moves_level_bonus`.
  /// Decremented by 1 on each successful swap and by manual shuffles.
  mut moves_left : Int
  /// Number of jelly-covered cells still remaining on the board.
  /// The level is cleared when this reaches 0.
  /// Decremented inside `remove_marked_cells` when a jelly layer is fully removed.
  mut jelly_left : Int
  // ──── Selection and cursor ────
  /// Whether a cell is currently selected for swapping.
  /// Set to `true` on the first tap/enter; cleared after a swap attempt
  /// or when the same cell is tapped again.
  mut selected : Bool
  /// Board column (x) of the currently selected cell.
  /// Only meaningful when `selected` is `true`.
  mut sel_x : Int
  /// Board row (y) of the currently selected cell.
  /// Only meaningful when `selected` is `true`.
  mut sel_y : Int
  /// Board column (x) of the keyboard cursor highlight.
  /// Moved by arrow/WASD keys; clamped to `[0, board_cols-1]`.
  mut cursor_x : Int
  /// Board row (y) of the keyboard cursor highlight.
  /// Moved by arrow/WASD keys; clamped to `[0, board_rows-1]`.
  mut cursor_y : Int
  // ──── Hint system ────
  /// Whether a hint pair is currently being displayed on the board.
  /// Set by `find_hint`; cleared when the hint timer expires or a swap occurs.
  mut hint_active : Bool
  /// Board column of the first cell in the hint pair.
  mut hint_x0 : Int
  /// Board row of the first cell in the hint pair.
  mut hint_y0 : Int
  /// Board column of the second cell in the hint pair.
  mut hint_x1 : Int
  /// Board row of the second cell in the hint pair.
  mut hint_y1 : Int
  /// Remaining display time for the hint animation, in seconds.
  /// Initialised to `hint_ttl_max` (2.2 s); counts down each frame.
  /// Also drives the pulsing sine wave in the hint renderer.
  mut hint_t : Float
  // ──── HUD message ────
  /// Text string shown in the HUD banner above the board (e.g. "Swap did not
  /// make a match." or "Level 3 begins."). Set by `set_message`.
  mut message : String
  /// Remaining display time for the HUD message, in seconds.
  /// Initialised to `message_ttl_max` (2.4 s); counts down each frame.
  /// The renderer fades the banner alpha proportionally.
  mut message_t : Float
  // ──── Input state ────
  /// Whether touch input has been detected this session.
  /// When `true`, the renderer shows a "Touch ready" hint below the board.
  mut touch_mode : Bool
  /// Cooldown timer preventing rapid-fire touch taps, in seconds.
  /// Set to `touch_action_cooldown` (0.1 s) after each touch action;
  /// no new touch action is accepted until it reaches 0.
  mut touch_cd : Float
  // ──── Swap flash animation ────
  /// Remaining time for the white flash overlay on the two swapped cells,
  /// in seconds. Set to 0.42 s on a successful swap; decays to 0 each frame.
  mut swap_flash_t : Float
  /// Board column of the first cell in the last successful swap.
  mut swap_x0 : Int
  /// Board row of the first cell in the last successful swap.
  mut swap_y0 : Int
  /// Board column of the second cell in the last successful swap.
  mut swap_x1 : Int
  /// Board row of the second cell in the last successful swap.
  mut swap_y1 : Int
  // ──── Raw pointer state (written by main loop each frame) ────
  /// Current mouse or primary touch x position in screen pixels.
  /// Used by `pointer_on_rect` and `pointer_to_cell` for hit testing.
  mut mouse_x : Float
  /// Current mouse or primary touch y position in screen pixels.
  mut mouse_y : Float
  /// Whether the left mouse button was pressed this frame.
  /// Used together with `mouse_x/y` for click-based cell selection.
  mut mouse_press : Bool
  /// Number of active touch points this frame (0 on desktop).
  /// A value > 0 enables `touch_mode` and activates touch hit-testing.
  mut touch_count : Int

  fn new() -> Game
}

///|
/// Creates a new game state with default board buffers and counters.
#deprecated
pub fn Game::new() -> Game {
  {
    kinds: Array::make(board_cells, 0),
    specials: Array::make(board_cells, None),
    jelly: Array::make(board_cells, 0),
    flash: Array::make(board_cells, 0.0),
    marks: Array::make(board_cells, false),
    spawn_special: Array::make(board_cells, None),
    state: Title,
    level: 1,
    score: 0,
    best_score: 0,
    chain_best: 0,
    moves_left: moves_base,
    jelly_left: 0,
    selected: false,
    sel_x: 0,
    sel_y: 0,
    cursor_x: 0,
    cursor_y: 0,
    hint_active: false,
    hint_x0: 0,
    hint_y0: 0,
    hint_x1: 0,
    hint_y1: 0,
    hint_t: 0.0,
    message: "",
    message_t: 0.0,
    touch_mode: false,
    touch_cd: 0.0,
    swap_flash_t: 0.0,
    swap_x0: 0,
    swap_y0: 0,
    swap_x1: 0,
    swap_y1: 0,
    mouse_x: 0.0,
    mouse_y: 0.0,
    mouse_press: false,
    touch_count: 0,
  }
}
