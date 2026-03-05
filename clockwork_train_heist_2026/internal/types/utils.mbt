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
/// Linearly interpolates between `a` and `b` by ratio `t`.
pub fn lerpf(a : Float, b : Float, t : Float) -> Float {
  a + (b - a) * t
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
  (x1 - x0).abs() + (y1 - y0).abs()
}

///|
/// Converts a board x-index to screen x-coordinate.
pub fn board_px(x : Int) -> Int {
  board_x0 + x * cell
}

///|
/// Converts a board y-index to screen y-coordinate.
pub fn board_py(y : Int) -> Int {
  board_y0 + y * cell
}

///|
/// Converts an interpolated x-position to pixel center x.
pub fn cell_center_x(x : Float) -> Int {
  board_x0 + (x * Float::from_int(cell)).to_int() + cell / 2
}

///|
/// Converts an interpolated y-position to pixel center y.
pub fn cell_center_y(y : Float) -> Int {
  board_y0 + (y * Float::from_int(cell)).to_int() + cell / 2
}

///|
/// Returns the title-screen start button rectangle.
pub fn start_button_rect() -> (Int, Int, Int, Int) {
  (panel_x0 + 30, screen_h - 192, panel_w - 60, 72)
}

///|
/// Returns the result-screen retry button rectangle.
pub fn retry_button_rect() -> (Int, Int, Int, Int) {
  (panel_x0 + 30, screen_h - 192, panel_w - 60, 72)
}

///|
/// Returns the on-screen left movement button rectangle.
pub fn btn_left() -> (Int, Int, Int, Int) {
  let x0 : Int = 40
  let y0 : Int = screen_h - 244
  (x0, y0 + 72, 76, 76)
}

///|
/// Returns the on-screen right movement button rectangle.
pub fn btn_right() -> (Int, Int, Int, Int) {
  let x0 : Int = 40
  let y0 : Int = screen_h - 244
  (x0 + 152, y0 + 72, 76, 76)
}

///|
/// Returns the on-screen up movement button rectangle.
pub fn btn_up() -> (Int, Int, Int, Int) {
  let x0 : Int = 40
  let y0 : Int = screen_h - 244
  (x0 + 76, y0, 76, 76)
}

///|
/// Returns the on-screen down movement button rectangle.
pub fn btn_down() -> (Int, Int, Int, Int) {
  let x0 : Int = 40
  let y0 : Int = screen_h - 244
  (x0 + 76, y0 + 144, 76, 76)
}

///|
/// Returns the on-screen action button rectangle.
pub fn btn_action() -> (Int, Int, Int, Int) {
  (screen_w - 190, screen_h - 224, 126, 126)
}

///|
/// Returns the on-screen hint button rectangle.
pub fn btn_hint() -> (Int, Int, Int, Int) {
  (screen_w - 334, screen_h - 182, 116, 70)
}

///|
/// Returns the on-screen restart button rectangle.
pub fn btn_restart() -> (Int, Int, Int, Int) {
  (screen_w - 334, screen_h - 266, 116, 70)
}

///|
/// Returns the on-screen menu button rectangle.
pub fn btn_menu() -> (Int, Int, Int, Int) {
  (screen_w - 334, screen_h - 350, 116, 70)
}

///|
/// Returns contextual hint text for the given hint index.
pub fn hint_text(i : Int) -> String {
  if i == 0 {
    "Collect 6 loot pieces across train cars to unlock the escape cable."
  } else if i == 1 {
    "Guards see down clear corridors. Break sight using walls or smoke."
  } else if i == 2 {
    "Smoke pulse (Space/E/A) stuns nearby guards and blocks vision."
  } else {
    "Keycards are deep in the center cars. Plan the route before sprinting."
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
  game : Game,
  rx : Int,
  ry : Int,
  rw : Int,
  rh : Int,
) -> Bool {
  if game.mouse_hold &&
    point_in_rect(game.mouse_x, game.mouse_y, rx, ry, rw, rh) {
    return true
  }

  for i in 0..<game.touch_count {
    let p = @raylib.get_touch_position(i)
    if point_in_rect(p.x, p.y, rx, ry, rw, rh) {
      return true
    }
  }

  false
}

///|
/// Returns whether the title start button is currently hovered or pressed.
pub fn title_hover(game : Game) -> Bool {
  let b = start_button_rect()
  pointer_on_rect(game, b.0, b.1, b.2, b.3)
}

///|
/// Returns whether the retry button is currently hovered or pressed.
pub fn retry_hover(game : Game) -> Bool {
  let b = retry_button_rect()
  pointer_on_rect(game, b.0, b.1, b.2, b.3)
}
