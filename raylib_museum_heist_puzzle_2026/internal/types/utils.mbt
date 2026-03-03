///|
/// Returns absolute value of an integer.
pub fn absi(v : Int) -> Int {
  if v < 0 {
    -v
  } else {
    v
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
/// Converts `(x, y)` to a linear board index.
pub fn cell_index(x : Int, y : Int) -> Int {
  y * board_cols + x
}

///|
/// Returns x-coordinate for a linear board index.
pub fn cell_x(idx : Int) -> Int {
  idx % board_cols
}

///|
/// Returns y-coordinate for a linear board index.
pub fn cell_y(idx : Int) -> Int {
  idx / board_cols
}

///|
/// Returns whether `(x, y)` lies inside board bounds.
pub fn in_bounds(x : Int, y : Int) -> Bool {
  x >= 0 && x < board_cols && y >= 0 && y < board_rows
}

///|
/// Returns tile kind at `(x, y)`, defaulting to `Wall` when out of bounds.
pub fn tile_at(game : Game, x : Int, y : Int) -> TileKind {
  if in_bounds(x, y) {
    game.tiles[cell_index(x, y)]
  } else {
    Wall
  }
}

///|
/// Sets tile kind at `(x, y)` when the coordinate is in bounds.
pub fn set_tile(game : Game, x : Int, y : Int, tile : TileKind) -> Unit {
  if in_bounds(x, y) {
    game.tiles[cell_index(x, y)] = tile
  }
}

///|
/// Returns whether `(x, y)` is walkable floor.
pub fn walkable(game : Game, x : Int, y : Int) -> Bool {
  tile_at(game, x, y) == Floor
}

///|
/// Fills the full board with `Floor` tiles.
pub fn fill_board_floor(game : Game) -> Unit {
  for i in 0..<game.tiles.length() {
    game.tiles[i] = Floor
  }
}

///|
/// Fills a rectangular region with `Wall` tiles.
pub fn add_wall_rect(game : Game, x : Int, y : Int, w : Int, h : Int) -> Unit {
  for yy in y..<(y + h) {
    for xx in x..<(x + w) {
      set_tile(game, xx, yy, Wall)
    }
  }
}

///|
/// Carves a rectangular region back to `Floor` tiles.
pub fn carve_floor_rect(
  game : Game,
  x : Int,
  y : Int,
  w : Int,
  h : Int,
) -> Unit {
  for yy in y..<(y + h) {
    for xx in x..<(x + w) {
      set_tile(game, xx, yy, Floor)
    }
  }
}

///|
/// Adds an outer wall border around the board.
pub fn add_border_walls(game : Game) -> Unit {
  add_wall_rect(game, 0, 0, board_cols, 1)
  add_wall_rect(game, 0, board_rows - 1, board_cols, 1)
  add_wall_rect(game, 0, 0, 1, board_rows)
  add_wall_rect(game, board_cols - 1, 0, 1, board_rows)
}

///|
/// Clears all spawned artifacts and guards.
pub fn clear_entities(game : Game) -> Unit {
  game.artifacts = []
  game.guards = []
  game.artifacts_total = 0
  game.artifacts_collected = 0
}

///|
/// Spawns one artifact at `(x, y)` when the tile is walkable.
pub fn spawn_artifact(game : Game, x : Int, y : Int) -> Unit {
  if tile_at(game, x, y) != Floor {
    return
  }

  game.artifacts.push({ x, y, taken: false })
  game.artifacts_total = game.artifacts_total + 1
}

///|
/// Spawns one guard with a patrol path and view range.
pub fn spawn_guard(
  game : Game,
  path : Array[Int],
  view_range : Int,
  phase : Float,
) -> Unit {
  if path.length() == 0 {
    return
  }

  let first = path[0]
  let gx = cell_x(first)
  let gy = cell_y(first)

  let mut dir_x : Int = 1
  let mut dir_y : Int = 0
  let mut next_idx : Int = 0

  if path.length() > 1 {
    next_idx = 1
    let nx = cell_x(path[1])
    let ny = cell_y(path[1])
    if nx > gx {
      dir_x = 1
      dir_y = 0
    } else if nx < gx {
      dir_x = -1
      dir_y = 0
    } else if ny > gy {
      dir_x = 0
      dir_y = 1
    } else if ny < gy {
      dir_x = 0
      dir_y = -1
    }
  }

  game.guards.push({
    x: gx,
    y: gy,
    dir_x,
    dir_y,
    view_range,
    path,
    path_index: next_idx,
    step_timer: phase,
  })
}

///|
/// Convenience alias for `cell_index`.
pub fn pc(x : Int, y : Int) -> Int {
  cell_index(x, y)
}

///|
/// Converts a direction to `(dx, dy)` movement delta.
pub fn dir_delta(dir : Direction) -> (Int, Int) {
  match dir {
    DirNone => (0, 0)
    Left => (-1, 0)
    Right => (1, 0)
    Up => (0, -1)
    Down => (0, 1)
  }
}

///|
/// Returns whether two cells have unobstructed line of sight.
pub fn has_line_of_sight(
  game : Game,
  from_x : Int,
  from_y : Int,
  to_x : Int,
  to_y : Int,
) -> Bool {
  let mut x = from_x
  let mut y = from_y
  let dx = absi(to_x - from_x)
  let sx = if from_x < to_x { 1 } else if from_x > to_x { -1 } else { 0 }
  let dy = -absi(to_y - from_y)
  let sy = if from_y < to_y { 1 } else if from_y > to_y { -1 } else { 0 }
  let mut err = dx + dy

  while true {
    if x == to_x && y == to_y {
      break
    }

    let e2 = 2 * err
    if e2 >= dy {
      err = err + dy
      x = x + sx
    }
    if e2 <= dx {
      err = err + dx
      y = y + sy
    }

    if x == to_x && y == to_y {
      break
    }
    if tile_at(game, x, y) == Wall {
      return false
    }
  }

  true
}

///|
/// Returns whether a target delta lies inside the guard forward cone.
pub fn in_guard_front(g : Guard, dx : Int, dy : Int) -> Bool {
  let adx = absi(dx)
  let ady = absi(dy)

  if g.dir_x > 0 {
    dx >= 0 && ady <= dx
  } else if g.dir_x < 0 {
    dx <= 0 && ady <= -dx
  } else if g.dir_y > 0 {
    dy >= 0 && adx <= dy
  } else if g.dir_y < 0 {
    dy <= 0 && adx <= -dy
  } else {
    true
  }
}

///|
/// Returns whether guard `g` can currently see cell `(cx, cy)`.
pub fn guard_sees_cell(game : Game, g : Guard, cx : Int, cy : Int) -> Bool {
  if not(in_bounds(cx, cy)) {
    return false
  }
  if tile_at(game, cx, cy) == Wall {
    return false
  }
  if cx == g.x && cy == g.y {
    return true
  }

  let dx = cx - g.x
  let dy = cy - g.y
  let dist = maxi(absi(dx), absi(dy))
  if dist > g.view_range {
    return false
  }
  if not(in_guard_front(g, dx, dy)) {
    return false
  }

  has_line_of_sight(game, g.x, g.y, cx, cy)
}

///|
/// Returns whether any guard occupies cell `(cx, cy)`.
pub fn any_guard_on_cell(game : Game, cx : Int, cy : Int) -> Bool {
  for guard_val in game.guards {
    if guard_val.x == cx && guard_val.y == cy {
      return true
    }
  }
  false
}

///|
/// Returns whether the level exit is unlocked.
pub fn exit_unlocked(game : Game) -> Bool {
  game.artifacts_total > 0 && game.artifacts_collected >= game.artifacts_total
}

///|
/// Returns whether the player is currently spotted by any guard.
pub fn player_spotted(game : Game) -> Bool {
  if any_guard_on_cell(game, game.player_x, game.player_y) {
    return true
  }

  for guard_val in game.guards {
    if guard_sees_cell(game, guard_val, game.player_x, game.player_y) {
      return true
    }
  }
  false
}

///|
/// Converts board x-coordinate to pixel x-coordinate.
pub fn cell_px(x : Int) -> Int {
  board_origin_x + x * tile_size
}

///|
/// Converts board y-coordinate to pixel y-coordinate.
pub fn cell_py(y : Int) -> Int {
  board_origin_y + y * tile_size
}

///|
/// Returns the board right edge in pixels.
pub fn board_right() -> Int {
  board_origin_x + board_cols * tile_size
}

///|
/// Returns the board bottom edge in pixels.
pub fn board_bottom() -> Int {
  board_origin_y + board_rows * tile_size
}

///|
/// Tests whether a point is inside an integer rectangle.
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
/// Tests whether mouse hold or any touch point is inside a rectangle.
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
  let mut hit = false
  if mouse_flag && inside_rect(mouse_x, mouse_y, x, y, w, h) {
    hit = true
  }

  if not(hit) {
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
/// Returns center x-position of the on-screen d-pad.
pub fn dpad_center_x() -> Int {
  162
}

///|
/// Returns center y-position of the on-screen d-pad.
pub fn dpad_center_y() -> Int {
  screen_h - 122
}

///|
/// Returns size of each square d-pad button.
pub fn dpad_button_size() -> Int {
  68
}

///|
/// Returns rectangle for the d-pad left button.
pub fn dpad_left_rect() -> (Int, Int, Int, Int) {
  let s = dpad_button_size()
  let cx = dpad_center_x()
  let cy = dpad_center_y()
  (cx - s - 20, cy - s / 2, s, s)
}

///|
/// Returns rectangle for the d-pad right button.
pub fn dpad_right_rect() -> (Int, Int, Int, Int) {
  let s = dpad_button_size()
  let cx = dpad_center_x()
  let cy = dpad_center_y()
  (cx + 20, cy - s / 2, s, s)
}

///|
/// Returns rectangle for the d-pad up button.
pub fn dpad_up_rect() -> (Int, Int, Int, Int) {
  let s = dpad_button_size()
  let cx = dpad_center_x()
  let cy = dpad_center_y()
  (cx - s / 2, cy - s - 20, s, s)
}

///|
/// Returns rectangle for the d-pad down button.
pub fn dpad_down_rect() -> (Int, Int, Int, Int) {
  let s = dpad_button_size()
  let cx = dpad_center_x()
  let cy = dpad_center_y()
  (cx - s / 2, cy + 20, s, s)
}

///|
/// Returns rectangle for the title start button.
pub fn start_button_rect() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 190, screen_h - 250, 380, 80)
}

///|
/// Returns rectangle for the next-level button.
pub fn next_button_rect() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 190, screen_h - 154, 380, 80)
}

///|
/// Returns rectangle for the retry-level button.
pub fn retry_button_rect() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 190, screen_h - 250, 380, 80)
}

///|
/// Returns rectangle for the in-game restart button.
pub fn restart_button_rect() -> (Int, Int, Int, Int) {
  (panel_x + 20, screen_h - 122, panel_w - 40, 72)
}
