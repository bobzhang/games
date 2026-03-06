///|
/// Returns the larger of two floats.
pub fn maxf(a : Float, b : Float) -> Float {
  if a > b {
    a
  } else {
    b
  }
}

///|
/// Returns a random float in `[lo, hi]`.
pub fn randf(lo : Float, hi : Float) -> Float {
  let r : Float = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  lo + (hi - lo) * r
}

///|
/// Converts board coordinates to linear storage index.
pub fn board_index(x : Int, y : Int) -> Int {
  y * board_cols + x
}

///|
/// Returns tile value at `(x, y)` or `Void` when out of bounds.
pub fn tile_at(game : Game, x : Int, y : Int) -> Tile {
  if x < 0 || x >= board_cols || y < 0 || y >= board_rows {
    Void
  } else {
    game.tiles[board_index(x, y)]
  }
}

///|
/// Writes a tile value when `(x, y)` is inside board bounds.
pub fn set_tile(game : Game, x : Int, y : Int, tile : Tile) -> Unit {
  if x < 0 || x >= board_cols || y < 0 || y >= board_rows {
    return
  }
  game.tiles[board_index(x, y)] = tile
}

///|
/// Returns whether a crate occupies `(x, y)`.
pub fn box_at(game : Game, x : Int, y : Int) -> Bool {
  if x < 0 || x >= board_cols || y < 0 || y >= board_rows {
    false
  } else {
    game.boxes[board_index(x, y)]
  }
}

///|
/// Sets crate occupancy at `(x, y)` when inside board bounds.
pub fn set_box(game : Game, x : Int, y : Int, has_box : Bool) -> Unit {
  if x < 0 || x >= board_cols || y < 0 || y >= board_rows {
    return
  }
  game.boxes[board_index(x, y)] = has_box
}

///|
/// Returns whether the player or crate can stand on this tile.
pub fn walkable_tile(tile : Tile) -> Bool {
  tile == Floor || tile == Goal
}

///|
/// Counts how many goal tiles currently hold crates.
pub fn goal_filled_count(game : Game) -> Int {
  let mut n : Int = 0
  for y in 0..<game.grid_h {
    for x in 0..<game.grid_w {
      if tile_at(game, x, y) == Goal && box_at(game, x, y) {
        n = n + 1
      }
    }
  }
  n
}

///|
/// Returns whether point `(px, py)` lies inside an integer rectangle.
pub fn inside_rect(
  px : Float,
  py : Float,
  x : Int,
  y : Int,
  w : Int,
  h : Int,
) -> Bool {
  px >= Float::from_int(x) &&
  px <= Float::from_int(x + w) &&
  py >= Float::from_int(y) &&
  py <= Float::from_int(y + h)
}

///|
/// Returns whether mouse/touch input activated a UI rectangle.
pub fn pointer_on_rect(
  mouse_x : Float,
  mouse_y : Float,
  mouse_flag : Bool,
  touch_count : Int,
  x : Int,
  y : Int,
  w : Int,
  h : Int,
) -> Bool {
  let mut hit : Bool = false

  if mouse_flag && inside_rect(mouse_x, mouse_y, x, y, w, h) {
    hit = true
  }

  if !hit {
    for i in 0..<touch_count {
      let p = @raylib.get_touch_position(i)
      if inside_rect(p.x, p.y, x, y, w, h) {
        hit = true
      }
    }
  }

  hit
}

///|
/// X center of the on-screen D-pad.
pub fn dpad_center_x() -> Int {
  160
}

///|
/// Y center of the on-screen D-pad.
pub fn dpad_center_y() -> Int {
  screen_h - 180
}

///|
/// Half-size used for D-pad button layout.
pub fn dpad_size() -> Int {
  76
}

///|
/// Left X of the right-side action button column.
pub fn action_panel_x() -> Int {
  screen_w - 300
}

///|
/// Top Y of the right-side action button column.
pub fn action_panel_y() -> Int {
  screen_h - 252
}

///|
/// Width of each action button rectangle.
pub fn action_panel_w() -> Int {
  118
}

///|
/// Height of each action button rectangle.
pub fn action_panel_h() -> Int {
  74
}

///|
/// Returns `(x, y, w, h)` for the level-advance button.
pub fn next_button_rect() -> (Int, Int, Int, Int) {
  (screen_w - 348, screen_h - 130, 310, 84)
}

///|
/// Returns `(x, y, w, h)` for the title-screen start button.
pub fn title_start_rect() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 220, screen_h - 170, 440, 92)
}
