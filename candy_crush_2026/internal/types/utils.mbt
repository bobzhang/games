///|
/// Returns board width in pixels.
pub fn board_pixel_w() -> Int32 {
  board_cols * cell_px
}

///|
/// Returns board height in pixels.
pub fn board_pixel_h() -> Int32 {
  board_rows * cell_px
}

///|
/// Returns the x coordinate of the board origin.
pub fn board_x() -> Int32 {
  (screen_w - ui_panel_w - board_pixel_w()) / 2 - 20
}

///|
/// Returns the y coordinate of the board origin.
pub fn board_y() -> Int32 {
  (screen_h - board_pixel_h()) / 2
}

///|
/// Returns the x coordinate of the side panel origin.
pub fn panel_x() -> Int32 {
  screen_w - ui_panel_w
}

///|
/// Returns the y coordinate of the side panel origin.
pub fn panel_y() -> Int32 {
  0
}

///|
/// Computes score gained from a clear size and combo chain.
pub fn score_for_removed(cleared : Int32, chain : Int32) -> Int32 {
  cleared * (42 + chain * 18)
}

///|
/// Clamps a float into the inclusive range [`lo`, `hi`].
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
/// Returns the larger of two floating-point values.
pub fn maxf(a : Float, b : Float) -> Float {
  if a > b {
    a
  } else {
    b
  }
}

///|
/// Swaps two integer array elements in place.
pub fn swapi(xs : Array[Int32], i : Int32, j : Int32) -> Unit {
  let t = xs[i]
  xs[i] = xs[j]
  xs[j] = t
}

///|
/// Swaps two Special array elements in place.
pub fn swap_special(xs : Array[Special], i : Int32, j : Int32) -> Unit {
  let t = xs[i]
  xs[i] = xs[j]
  xs[j] = t
}

///|
/// Converts board coordinates into a flat row-major index.
pub fn idx(x : Int32, y : Int32) -> Int32 {
  y * board_cols + x
}

///|
/// Returns true when `(x, y)` is inside the board.
pub fn in_board(x : Int32, y : Int32) -> Bool {
  x >= 0 && x < board_cols && y >= 0 && y < board_rows
}

///|
/// Returns true when two cells share an edge.
pub fn is_adjacent(x0 : Int32, y0 : Int32, x1 : Int32, y1 : Int32) -> Bool {
  let dx = (x0 - x1).abs()
  let dy = (y0 - y1).abs()
  dx + dy == 1
}

///|
/// Checks if a point lies inside an axis-aligned rectangle.
pub fn inside_rect(
  px : Float,
  py : Float,
  x : Int32,
  y : Int32,
  w : Int32,
  h : Int32,
) -> Bool {
  px >= Float::from_int(x) &&
  px <= Float::from_int(x + w) &&
  py >= Float::from_int(y) &&
  py <= Float::from_int(y + h)
}

///|
/// Checks whether a mouse press or any touch point hits a rectangle.
pub fn pointer_on_rect(
  mouse_x : Float,
  mouse_y : Float,
  mouse_press : Bool,
  touch_count : Int32,
  x : Int32,
  y : Int32,
  w : Int32,
  h : Int32,
) -> Bool {
  if mouse_press && inside_rect(mouse_x, mouse_y, x, y, w, h) {
    return true
  }

  for i in 0..<touch_count {
    let p = @raylib.get_touch_position(i)
    if inside_rect(p.x, p.y, x, y, w, h) {
      return true
    }
  }

  false
}

///|
/// Returns the title overlay start button rectangle.
pub fn start_button_rect() -> (Int32, Int32, Int32, Int32) {
  (screen_w / 2 - 230, screen_h - 170, 460, 96)
}

///|
/// Returns the hint button rectangle in the side panel.
pub fn hint_button_rect() -> (Int32, Int32, Int32, Int32) {
  (panel_x() + 30, 280, ui_panel_w - 60, 70)
}

///|
/// Returns the shuffle button rectangle in the side panel.
pub fn shuffle_button_rect() -> (Int32, Int32, Int32, Int32) {
  (panel_x() + 30, 366, ui_panel_w - 60, 70)
}

///|
/// Returns the restart button rectangle in the side panel.
pub fn restart_button_rect() -> (Int32, Int32, Int32, Int32) {
  (panel_x() + 30, 452, ui_panel_w - 60, 70)
}

///|
/// Returns the action button rectangle in level-clear and game-over overlays.
pub fn result_button_rect() -> (Int32, Int32, Int32, Int32) {
  (screen_w / 2 - 220, screen_h - 180, 440, 92)
}

///|
/// Maps a candy kind id to its base display color.
pub fn candy_color(kind : Int32) -> @raylib.Color {
  if kind == 0 {
    @raylib.Color::new(246, 92, 118, 255)
  } else if kind == 1 {
    @raylib.Color::new(255, 166, 80, 255)
  } else if kind == 2 {
    @raylib.Color::new(255, 225, 104, 255)
  } else if kind == 3 {
    @raylib.Color::new(109, 220, 138, 255)
  } else if kind == 4 {
    @raylib.Color::new(104, 186, 255, 255)
  } else {
    @raylib.Color::new(188, 142, 255, 255)
  }
}

///|
/// Applies a brightness delta to a color while preserving alpha.
pub fn tint(c : @raylib.Color, delta : Int32) -> @raylib.Color {
  let r = (c.r.to_int() + delta).clamp(min=0, max=255)
  let g = (c.g.to_int() + delta).clamp(min=0, max=255)
  let b = (c.b.to_int() + delta).clamp(min=0, max=255)
  @raylib.Color::new(r, g, b, c.a.to_int())
}

///|
/// Converts active pointer input into a board cell selection when possible.
pub fn pointer_to_cell(
  mouse_x : Float,
  mouse_y : Float,
  mouse_press : Bool,
  touch_count : Int32,
) -> (Bool, Int32, Int32) {
  let bx = board_x()
  let by = board_y()
  let bw = board_pixel_w()
  let bh = board_pixel_h()

  fn to_cell(px : Float, py : Float) -> (Bool, Int32, Int32) {
    if !inside_rect(px, py, bx, by, bw, bh) {
      return (false, 0, 0)
    }

    let cx = ((px.to_int() - bx) / cell_px).clamp(min=0, max=board_cols - 1)
    let cy = ((py.to_int() - by) / cell_px).clamp(min=0, max=board_rows - 1)
    (true, cx, cy)
  }

  if mouse_press {
    let cell = to_cell(mouse_x, mouse_y)
    if cell.0 {
      return cell
    }
  }

  for i in 0..<touch_count {
    let p = @raylib.get_touch_position(i)
    let cell = to_cell(p.x, p.y)
    if cell.0 {
      return cell
    }
  }

  (false, 0, 0)
}
