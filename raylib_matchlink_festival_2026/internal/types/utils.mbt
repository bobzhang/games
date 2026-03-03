///|
/// Returns the smaller of two integers.
pub fn mini(a : Int, b : Int) -> Int {
  a.min(b)
}

///|
/// Returns the larger of two integers.
pub fn maxi(a : Int, b : Int) -> Int {
  a.max(b)
}

///|
/// Clamps an integer into the inclusive range [`lo`, `hi`].
pub fn clampi(v : Int, lo : Int, hi : Int) -> Int {
  v.clamp(min=lo, max=hi)
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
/// Returns a pseudo-random float in the inclusive range [`lo`, `hi`].
pub fn randf(lo : Float, hi : Float) -> Float {
  let r : Float = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  lo + (hi - lo) * r
}

///|
/// Converts 1-based board coordinates into a flat row-major index.
pub fn cell_index(x : Int, y : Int) -> Int {
  (y - 1) * max_cols + (x - 1)
}

///|
/// Returns true when `(x, y)` is inside the active board bounds.
pub fn in_board(game : Game, x : Int, y : Int) -> Bool {
  x >= 1 && x <= game.board_w && y >= 1 && y <= game.board_h
}

///|
/// Reads a board cell value, returning `0` for out-of-bounds access.
pub fn cell_at(game : Game, x : Int, y : Int) -> Int {
  if in_board(game, x, y) {
    game.cells[cell_index(x, y)]
  } else {
    0
  }
}

///|
/// Writes a board cell value when coordinates are in bounds.
pub fn set_cell(game : Game, x : Int, y : Int, value : Int) -> Unit {
  if in_board(game, x, y) {
    game.cells[cell_index(x, y)] = value
  }
}

///|
/// Clears all board cells to empty.
pub fn clear_board(game : Game) -> Unit {
  for i in 0..<game.cells.length() {
    game.cells[i] = 0
  }
}

///|
/// Resets all spark particles to inactive.
pub fn clear_sparks(game : Game) -> Unit {
  for spark in game.sparks {
    spark.active = false
    spark.x = 0.0
    spark.y = 0.0
    spark.vx = 0.0
    spark.vy = 0.0
    spark.life = 0.0
    spark.size = 0.0
    spark.kind = 0
  }
}

///|
/// Clears the currently displayed link-path flash overlay.
pub fn clear_path_flash(game : Game) -> Unit {
  game.path_active = false
  game.path_ttl = 0.0
  game.path_points = 0
}

///|
/// Clears the currently displayed hint flash overlay.
pub fn clear_hint_flash(game : Game) -> Unit {
  game.hint_active = false
  game.hint_ttl = 0.0
}

///|
/// Computes board origin and tile size, including active shake offsets.
pub fn board_metrics(game : Game) -> (Int, Int, Int) {
  let area_x : Int = 24
  let area_y : Int = 22
  let area_w : Int = screen_w - 460
  let area_h : Int = screen_h - 44

  let safe_w : Int = maxi(1, game.board_w)
  let safe_h : Int = maxi(1, game.board_h)

  let tile_x : Int = (area_w - 24) / safe_w
  let tile_y : Int = (area_h - 24) / safe_h
  let mut tile : Int = mini(tile_x, tile_y)
  tile = clampi(tile, 36, 84)

  let mut board_x : Int = area_x + (area_w - safe_w * tile) / 2
  let mut board_y : Int = area_y + (area_h - safe_h * tile) / 2

  if game.shake_t > 0.0 {
    board_x = board_x + @raylib.get_random_value(-3, 3)
    board_y = board_y + @raylib.get_random_value(-3, 3)
  }

  (board_x, board_y, tile)
}

///|
/// Returns cell center in world space along with tile size as float.
pub fn world_center(game : Game, x : Int, y : Int) -> (Float, Float, Float) {
  let (board_x, board_y, tile) = board_metrics(game)

  let cx : Float = Float::from_int(board_x + (x - 1) * tile + tile / 2)
  let cy : Float = Float::from_int(board_y + (y - 1) * tile + tile / 2)
  (cx, cy, Float::from_int(tile))
}

///|
/// Returns cell center in world space.
pub fn world_center_ext(game : Game, x : Int, y : Int) -> (Float, Float) {
  let (board_x, board_y, tile) = board_metrics(game)

  let cx : Float = Float::from_int(board_x + (x - 1) * tile + tile / 2)
  let cy : Float = Float::from_int(board_y + (y - 1) * tile + tile / 2)
  (cx, cy)
}

///|
/// Activates one available spark particle with the provided parameters.
pub fn spawn_spark(
  game : Game,
  x : Float,
  y : Float,
  vx : Float,
  vy : Float,
  life : Float,
  size : Float,
  kind : Int,
) -> Unit {
  for spark in game.sparks {
    if spark.active {
      continue
    }

    spark.active = true
    spark.x = x
    spark.y = y
    spark.vx = vx
    spark.vy = vy
    spark.life = life
    spark.size = size
    spark.kind = kind
    break
  }
}

///|
/// Emits a burst of spark particles centered on a board cell.
pub fn burst_cell(
  game : Game,
  x : Int,
  y : Int,
  amount : Int,
  kind : Int,
) -> Unit {
  let (cx, cy, tile_f) = world_center(game, x, y)
  let spread : Float = maxf(8.0, tile_f * 0.2)

  for _i in 0..<amount {
    spawn_spark(
      game,
      cx + randf(-spread, spread),
      cy + randf(-spread, spread),
      randf(-160.0, 160.0),
      randf(-170.0, 160.0),
      randf(0.20, 0.92),
      randf(1.6, 5.5),
      kind,
    )
  }
}

///|
/// Advances spark particle simulation and lifetimes.
pub fn update_sparks(game : Game, dt : Float) -> Unit {
  for spark in game.sparks {
    if not(spark.active) {
      continue
    }

    spark.life = spark.life - dt
    if spark.life <= 0.0 {
      spark.active = false
      continue
    }

    spark.x = spark.x + spark.vx * dt
    spark.y = spark.y + spark.vy * dt
    spark.vx = spark.vx * (1.0 - dt * 1.9)
    spark.vy = spark.vy * (1.0 - dt * 1.9) + dt * 36.0
  }
}

///|
/// Shuffles an integer array in place using Fisher-Yates.
pub fn shuffle_ints(arr : Array[Int]) -> Unit {
  let mut i : Int = arr.length() - 1
  while i > 0 {
    let j : Int = @raylib.get_random_value(0, i)
    let t : Int = arr[i]
    arr[i] = arr[j]
    arr[j] = t
    i = i - 1
  }
}

///|
/// Checks if a point lies inside an axis-aligned rectangle.
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
/// Returns true if mouse/touch input currently hits a rectangle.
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
/// Returns the x origin of the side panel.
pub fn panel_x() -> Int {
  screen_w - 420
}

///|
/// Returns the x center of the touch D-pad.
pub fn dpad_center_x() -> Int {
  162
}

///|
/// Returns the y center of the touch D-pad.
pub fn dpad_center_y() -> Int {
  screen_h - 184
}

///|
/// Returns the half-size used to draw D-pad arms.
pub fn dpad_size() -> Int {
  78
}

///|
/// Returns the rectangle for the select action button.
pub fn select_button_rect() -> (Int, Int, Int, Int) {
  (panel_x() + 24, screen_h - 256, 170, 72)
}

///|
/// Returns the rectangle for the hint action button.
pub fn hint_button_rect() -> (Int, Int, Int, Int) {
  (panel_x() + 214, screen_h - 256, 170, 72)
}

///|
/// Returns the rectangle for the shuffle action button.
pub fn shuffle_button_rect() -> (Int, Int, Int, Int) {
  (panel_x() + 24, screen_h - 172, 170, 72)
}

///|
/// Returns the rectangle for the clear-selection button.
pub fn clear_button_rect() -> (Int, Int, Int, Int) {
  (panel_x() + 214, screen_h - 172, 170, 72)
}

///|
/// Returns the rectangle for resetting the current level.
pub fn reset_button_rect() -> (Int, Int, Int, Int) {
  (panel_x() + 24, screen_h - 88, 170, 72)
}

///|
/// Returns the rectangle for next/restart campaign actions in overlays.
pub fn next_button_rect() -> (Int, Int, Int, Int) {
  (panel_x() + 24, screen_h - 88, 360, 72)
}

///|
/// Returns the title-screen start button rectangle.
pub fn start_button_rect() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 230, screen_h - 158, 460, 96)
}

///|
/// Returns the indexed point from a link path description.
pub fn path_point(path : LinkPath, idx : Int) -> (Int, Int) {
  if idx == 0 {
    (path.x0, path.y0)
  } else if idx == 1 {
    (path.x1, path.y1)
  } else if idx == 2 {
    (path.x2, path.y2)
  } else {
    (path.x3, path.y3)
  }
}

///|
/// Returns the indexed point from the active path flash stored in `game`.
pub fn path_point_flash(game : Game, idx : Int) -> (Int, Int) {
  if idx == 0 {
    (game.path_x0, game.path_y0)
  } else if idx == 1 {
    (game.path_x1, game.path_y1)
  } else if idx == 2 {
    (game.path_x2, game.path_y2)
  } else {
    (game.path_x3, game.path_y3)
  }
}

///|
/// Clears active tile selection and resets cursor anchor coordinates.
pub fn clear_selection(game : Game) -> Unit {
  game.select_active = false
  game.select_x = 1
  game.select_y = 1
}
