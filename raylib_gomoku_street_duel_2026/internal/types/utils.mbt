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
/// Converts board coordinates to linear index.
pub fn board_index(x : Int, y : Int) -> Int {
  y * board_n + x
}

///|
/// Returns whether `(x, y)` lies inside the gomoku board.
pub fn in_board(x : Int, y : Int) -> Bool {
  x >= 0 && x < board_n && y >= 0 && y < board_n
}

///|
/// Reads cell occupant at `(x, y)` or `Empty` when out of bounds.
pub fn cell_at(game : Game, x : Int, y : Int) -> Player {
  if in_board(x, y) {
    game.board[board_index(x, y)]
  } else {
    Empty
  }
}

///|
/// Writes cell occupant when `(x, y)` is inside the board.
pub fn set_cell(game : Game, x : Int, y : Int, p : Player) -> Unit {
  if in_board(x, y) {
    game.board[board_index(x, y)] = p
  }
}

///|
/// Updates transient message text and its time-to-live.
pub fn set_message(game : Game, msg : String, ttl : Float) -> Unit {
  game.message = msg
  game.message_t = ttl
}

///|
/// Clears current hint marker and timer.
pub fn clear_hint(game : Game) -> Unit {
  game.hint_active = false
  game.hint_ttl = 0.0
  game.hint_x = 0
  game.hint_y = 0
}

///|
/// Spawns one spark particle in the shared spark pool.
pub fn spawn_spark(
  game : Game,
  x : Float,
  y : Float,
  vx : Float,
  vy : Float,
  life : Float,
  size : Float,
  kind : SparkKind,
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
/// Calculates board placement metrics `(x, y, tile_size)` for rendering.
pub fn board_metrics(game : Game) -> (Int, Int, Int) {
  let area_x : Int = 24
  let area_y : Int = 22
  let area_w : Int = screen_w - 460
  let area_h : Int = screen_h - 44

  let tile_x : Int = (area_w - 24) / board_n
  let tile_y : Int = (area_h - 24) / board_n

  let mut tile : Int = tile_x.min(tile_y)
  tile = tile.clamp(min=42, max=72)

  let mut board_x : Int = area_x + (area_w - board_n * tile) / 2
  let mut board_y : Int = area_y + (area_h - board_n * tile) / 2

  if game.shake_t > 0.0 {
    board_x = board_x + @raylib.get_random_value(-3, 3)
    board_y = board_y + @raylib.get_random_value(-3, 3)
  }

  (board_x, board_y, tile)
}

///|
/// Returns world-space center and tile size for a board cell.
pub fn world_center(game : Game, x : Int, y : Int) -> (Float, Float, Float) {
  let (bx, by, tile) = board_metrics(game)
  let cx : Float = Float::from_int(bx + x * tile + tile / 2)
  let cy : Float = Float::from_int(by + y * tile + tile / 2)
  (cx, cy, Float::from_int(tile))
}

///|
/// Emits a burst of move-feedback sparks at board coordinates.
pub fn burst_move(
  game : Game,
  x : Int,
  y : Int,
  amount : Int,
  kind : SparkKind,
) -> Unit {
  let (cx, cy, tilef) = world_center(game, x, y)
  let spread : Float = maxf(8.0, tilef * 0.22)

  for _i in 0..<amount {
    spawn_spark(
      game,
      cx + randf(-spread, spread),
      cy + randf(-spread, spread),
      randf(-150.0, 150.0),
      randf(-160.0, 150.0),
      randf(0.2, 0.9),
      randf(1.6, 5.4),
      kind,
    )
  }
}

///|
/// Returns whether point `(px, py)` is inside a rectangle.
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
/// Returns whether mouse/touch input activated a rectangle.
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
/// Left X coordinate of the side panel.
pub fn panel_x() -> Int {
  screen_w - 420
}

///|
/// X center of the mobile D-pad.
pub fn dpad_center_x() -> Int {
  162
}

///|
/// Y center of the mobile D-pad.
pub fn dpad_center_y() -> Int {
  screen_h - 184
}

///|
/// Radius-like size unit for D-pad buttons.
pub fn dpad_size() -> Int {
  78
}

///|
/// Returns `(x, y, w, h)` for the place button.
pub fn place_button_rect() -> (Int, Int, Int, Int) {
  (panel_x() + 24, screen_h - 256, 170, 72)
}

///|
/// Returns `(x, y, w, h)` for the hint button.
pub fn hint_button_rect() -> (Int, Int, Int, Int) {
  (panel_x() + 214, screen_h - 256, 170, 72)
}

///|
/// Returns `(x, y, w, h)` for the undo button.
pub fn undo_button_rect() -> (Int, Int, Int, Int) {
  (panel_x() + 24, screen_h - 172, 170, 72)
}

///|
/// Returns `(x, y, w, h)` for the clear-hint button.
pub fn clear_button_rect() -> (Int, Int, Int, Int) {
  (panel_x() + 214, screen_h - 172, 170, 72)
}

///|
/// Returns `(x, y, w, h)` for the reset button.
pub fn reset_button_rect() -> (Int, Int, Int, Int) {
  (panel_x() + 24, screen_h - 88, 170, 72)
}

///|
/// Returns `(x, y, w, h)` for the next-round button.
pub fn next_button_rect() -> (Int, Int, Int, Int) {
  (panel_x() + 24, screen_h - 88, 360, 72)
}

///|
/// Returns `(x, y, w, h)` for the title start button.
pub fn start_button_rect() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 230, screen_h - 158, 460, 96)
}
