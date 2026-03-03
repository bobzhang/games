///|
/// Width of the game window in pixels.
pub let screen_w : Int = 1760

///|
/// Height of the game window in pixels.
pub let screen_h : Int = 980

///|
/// Target frame rate for simulation and rendering.
pub let target_fps : Int = 120

///|
/// Left edge of the puzzle board in screen pixels.
pub let board_x0 : Int = 30

///|
/// Top edge of the puzzle board in screen pixels.
pub let board_y0 : Int = 84

///|
/// Size of one board cell in pixels.
pub let cell : Int = 60

///|
/// Number of board columns.
pub let grid_w : Int = 21

///|
/// Number of board rows.
pub let grid_h : Int = 13

///|
/// Total board width in pixels.
pub let board_w : Int = grid_w * cell

///|
/// Total board height in pixels.
pub let board_h : Int = grid_h * cell

///|
/// Left edge of the side information panel.
pub let panel_x0 : Int = board_x0 + board_w + 24

///|
/// Width of the side information panel.
pub let panel_w : Int = screen_w - panel_x0 - 24

///|
/// Maximum number of movable shelves in a layout.
pub let max_shelves : Int = 32

///|
/// Number of collectible pages in a run.
pub let max_pages : Int = 5

///|
/// Maximum number of active ghosts.
pub let max_ghosts : Int = 5

///|
/// Number of seals required to unlock the exit gate.
pub let seal_need : Int = 3

///|
/// Maximum number of particles in the effect pool.
pub let max_particles : Int = 360

///|
/// Seconds needed to complete one player tile move.
pub let player_move_time : Float = 0.115

///|
/// Base seconds needed for one ghost tile move.
pub let ghost_move_time : Float = 0.165

///|
/// Score awarded for each recovered page.
pub let page_score : Int = 350

///|
/// Score awarded for activating each seal.
pub let seal_score : Int = 220

///|
/// Score bonus granted on successful escape.
pub let escape_score : Int = 1000

///|
/// Starting tile x-coordinate for the player.
pub let start_x : Int = 1

///|
/// Starting tile y-coordinate for the player.
pub let start_y : Int = 1

///|
/// Exit tile x-coordinate.
pub let exit_x : Int = grid_w - 2

///|
/// Exit tile y-coordinate.
pub let exit_y : Int = grid_h - 2

///|
/// Returns the smaller of two integers.
pub fn mini(a : Int, b : Int) -> Int {
  if a < b {
    a
  } else {
    b
  }
}

///|
/// Returns the larger of two integers.
pub fn maxi(a : Int, b : Int) -> Int {
  if a > b {
    a
  } else {
    b
  }
}

///|
/// Clamps an integer to the inclusive `[lo, hi]` range.
pub fn clampi(v : Int, lo : Int, hi : Int) -> Int {
  v.clamp(min=lo, max=hi)
}

///|
/// Clamps a float to the inclusive `[lo, hi]` range.
pub fn clampf(v : Float, lo : Float, hi : Float) -> Float {
  if v < lo {
    lo
  } else if v > hi {
    hi
  } else {
    v
  }
}

///|
/// Returns the absolute value of an integer.
pub fn absi(v : Int) -> Int {
  if v < 0 {
    -v
  } else {
    v
  }
}

///|
/// Linearly interpolates between `a` and `b` by ratio `t`.
pub fn lerpf(a : Float, b : Float, t : Float) -> Float {
  a + (b - a) * t
}

///|
/// Computes sine using the core math backend.
pub fn sinf(v : Float) -> Float {
  @math.sinf(v)
}

///|
/// Returns a random float sampled uniformly from `[lo, hi]`.
pub fn randf(lo : Float, hi : Float) -> Float {
  let r : Float = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  lo + (hi - lo) * r
}

///|
/// Returns Manhattan distance between two grid cells.
pub fn manhattan(x0 : Int, y0 : Int, x1 : Int, y1 : Int) -> Int {
  absi(x1 - x0) + absi(y1 - y0)
}

///|
/// Converts a board x-index to pixel x-coordinate.
pub fn board_px(x : Int) -> Int {
  board_x0 + x * cell
}

///|
/// Converts a board y-index to pixel y-coordinate.
pub fn board_py(y : Int) -> Int {
  board_y0 + y * cell
}

///|
/// Converts an interpolated x-position to cell center x.
pub fn cell_center_x(x : Float) -> Int {
  board_x0 + (x * Float::from_int(cell)).to_int() + cell / 2
}

///|
/// Converts an interpolated y-position to cell center y.
pub fn cell_center_y(y : Float) -> Int {
  board_y0 + (y * Float::from_int(cell)).to_int() + cell / 2
}

///|
/// Returns the title-screen start button rectangle.
pub fn start_button_rect() -> (Int, Int, Int, Int) {
  (panel_x0 + 36, screen_h - 196, panel_w - 72, 70)
}

///|
/// Returns the result-screen retry button rectangle.
pub fn retry_button_rect() -> (Int, Int, Int, Int) {
  (panel_x0 + 36, screen_h - 188, panel_w - 72, 70)
}

///|
/// Returns the on-screen left movement button rectangle.
pub fn btn_left() -> (Int, Int, Int, Int) {
  let x0 : Int = 44
  let y0 : Int = screen_h - 238
  (x0, y0 + 70, 74, 74)
}

///|
/// Returns the on-screen right movement button rectangle.
pub fn btn_right() -> (Int, Int, Int, Int) {
  let x0 : Int = 44
  let y0 : Int = screen_h - 238
  (x0 + 148, y0 + 70, 74, 74)
}

///|
/// Returns the on-screen up movement button rectangle.
pub fn btn_up() -> (Int, Int, Int, Int) {
  let x0 : Int = 44
  let y0 : Int = screen_h - 238
  (x0 + 74, y0, 74, 74)
}

///|
/// Returns the on-screen down movement button rectangle.
pub fn btn_down() -> (Int, Int, Int, Int) {
  let x0 : Int = 44
  let y0 : Int = screen_h - 238
  (x0 + 74, y0 + 140, 74, 74)
}

///|
/// Returns the on-screen action button rectangle.
pub fn btn_action() -> (Int, Int, Int, Int) {
  (screen_w - 190, screen_h - 224, 128, 128)
}

///|
/// Returns the on-screen hint button rectangle.
pub fn btn_hint() -> (Int, Int, Int, Int) {
  (screen_w - 334, screen_h - 182, 120, 70)
}

///|
/// Returns the on-screen restart button rectangle.
pub fn btn_restart() -> (Int, Int, Int, Int) {
  (screen_w - 334, screen_h - 266, 120, 70)
}

///|
/// Returns the on-screen menu button rectangle.
pub fn btn_menu() -> (Int, Int, Int, Int) {
  (screen_w - 334, screen_h - 350, 120, 70)
}

///|
/// Returns the grid position of the seal indexed by `i`.
pub fn seal_pos(i : Int) -> (Int, Int) {
  if i == 0 {
    (6, 9)
  } else if i == 1 {
    (11, 5)
  } else {
    (16, 9)
  }
}

///|
/// Returns hint text for the current hint index.
pub fn seal_hint(i : Int) -> String {
  if i == 0 {
    "Press shelves onto glowing circles to break arcane locks."
  } else if i == 1 {
    "Stun pulse: Space/E or touch A. It burns lantern energy."
  } else if i == 2 {
    "Collect all lost pages, then escape through the south gate."
  } else {
    "Ghosts hunt in straight lines. Break line-of-sight around stacks."
  }
}

///|
/// Tests whether a point lies inside an integer rectangle.
pub fn point_in_rect(
  x : Float,
  y : Float,
  rx : Int,
  ry : Int,
  rw : Int,
  rh : Int,
) -> Bool {
  let x0 : Float = Float::from_int(rx)
  let y0 : Float = Float::from_int(ry)
  let x1 : Float = Float::from_int(rx + rw)
  let y1 : Float = Float::from_int(ry + rh)
  x >= x0 && x <= x1 && y >= y0 && y <= y1
}

///|
/// Tests whether mouse hold or any touch point is inside a rectangle.
pub fn pointer_on_rect(
  mx : Float,
  my : Float,
  hold : Bool,
  touch_count : Int,
  rx : Int,
  ry : Int,
  rw : Int,
  rh : Int,
) -> Bool {
  if hold && point_in_rect(mx, my, rx, ry, rw, rh) {
    return true
  }

  for i in 0..<touch_count {
    let p = @raylib.get_touch_position(i)
    if point_in_rect(p.x, p.y, rx, ry, rw, rh) {
      return true
    }
  }

  false
}

///|
/// Returns whether the title start button is hovered or pressed.
pub fn title_hover(
  mx : Float,
  my : Float,
  hold : Bool,
  touch_count : Int,
) -> Bool {
  let b = start_button_rect()
  pointer_on_rect(mx, my, hold, touch_count, b.0, b.1, b.2, b.3)
}

///|
/// Returns whether the retry button is hovered or pressed.
pub fn retry_hover(
  mx : Float,
  my : Float,
  hold : Bool,
  touch_count : Int,
) -> Bool {
  let b = retry_button_rect()
  pointer_on_rect(mx, my, hold, touch_count, b.0, b.1, b.2, b.3)
}
