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
/// Clamps an integer into the inclusive range [`lo`, `hi`].
pub fn clampi(v : Int, lo : Int, hi : Int) -> Int {
  if v < lo {
    lo
  } else if v > hi {
    hi
  } else {
    v
  }
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
/// Returns a pseudo-random float in the inclusive range [`lo`, `hi`].
pub fn randf(lo : Float, hi : Float) -> Float {
  let r : Float = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  lo + (hi - lo) * r
}

///|
/// Converts board coordinates into a flat row-major index.
pub fn idx(x : Int, y : Int) -> Int {
  y * board_n + x
}

///|
/// Returns true when a board coordinate lies inside the grid.
pub fn in_board(x : Int, y : Int) -> Bool {
  x >= 0 && x < board_n && y >= 0 && y < board_n
}

///|
/// Computes board origin and tile size, including active screen-shake offsets.
pub fn board_metrics(game : Game) -> (Int, Int, Int) {
  let area_x : Int = board_area_x()
  let area_y : Int = board_area_y()
  let area_w : Int = board_area_w()
  let area_h : Int = board_area_h()

  let tile_x : Int = area_w / board_n
  let tile_y : Int = area_h / board_n

  let mut tile : Int = mini(tile_x, tile_y)
  tile = clampi(tile, 120, 170)

  let mut bx : Int = area_x + (area_w - board_n * tile) / 2
  let mut by : Int = area_y + (area_h - board_n * tile) / 2

  if game.shake_t > 0.0 {
    bx = bx + @raylib.get_random_value(-3, 3)
    by = by + @raylib.get_random_value(-3, 3)
  }

  (bx, by, tile)
}

///|
/// Returns the world-space center of a board cell.
pub fn cell_world_center(game : Game, x : Int, y : Int) -> (Float, Float) {
  let (bx, by, tile) = board_metrics(game)
  (
    Float::from_int(bx + x * tile + tile / 2),
    Float::from_int(by + y * tile + tile / 2),
  )
}

///|
/// Sets the transient HUD message and its remaining lifetime.
pub fn set_msg(game : Game, msg : String, ttl : Float) -> Unit {
  game.msg = msg
  game.msg_t = ttl
}

///|
/// Checks whether an active pointer is currently inside a rectangle.
pub fn pointer_on_rect(
  x : Float,
  y : Float,
  hold : Bool,
  touch_count : Int,
  rx : Int,
  ry : Int,
  rw : Int,
  rh : Int,
) -> Bool {
  if not(hold) && touch_count <= 0 {
    return false
  }

  let x0 : Float = Float::from_int(rx)
  let y0 : Float = Float::from_int(ry)
  let x1 : Float = Float::from_int(rx + rw)
  let y1 : Float = Float::from_int(ry + rh)

  x >= x0 && x <= x1 && y >= y0 && y <= y1
}

///|
/// Converts pointer position to a board cell if the pointer is on the board.
pub fn pointer_cell(game : Game, mx : Float, my : Float) -> (Bool, Int, Int) {
  let (bx, by, tile) = board_metrics(game)

  let x : Int = (mx.to_int() - bx) / tile
  let y : Int = (my.to_int() - by) / tile

  if in_board(x, y) {
    (true, x, y)
  } else {
    (false, 0, 0)
  }
}

///|
/// Returns zap charge gained by merging a tile of value `v`.
pub fn charge_for_merge(v : Int) -> Int {
  if v >= 1024 {
    40
  } else if v >= 512 {
    28
  } else if v >= 256 {
    20
  } else if v >= 128 {
    14
  } else if v >= 64 {
    10
  } else {
    6
  }
}

///|
/// Returns bonus score for merge chains longer than one merge.
pub fn bonus_for_chain(chain : Int) -> Int {
  if chain <= 1 {
    0
  } else if chain == 2 {
    24
  } else if chain == 3 {
    56
  } else {
    56 + (chain - 3) * 34
  }
}

///|
/// Maps tile value to an integer progression rank.
pub fn tile_rank(v : Int) -> Int {
  if v <= 0 {
    0
  } else if v == 2 {
    1
  } else if v == 4 {
    2
  } else if v == 8 {
    3
  } else if v == 16 {
    4
  } else if v == 32 {
    5
  } else if v == 64 {
    6
  } else if v == 128 {
    7
  } else if v == 256 {
    8
  } else if v == 512 {
    9
  } else if v == 1024 {
    10
  } else if v == 2048 {
    11
  } else if v == 4096 {
    12
  } else if v == 8192 {
    13
  } else {
    14
  }
}

///|
/// Returns the display rank title for a computed tile rank.
pub fn rank_name(rank : Int) -> String {
  if rank >= 13 {
    "Storm God"
  } else if rank >= 12 {
    "Quantum Master"
  } else if rank >= 11 {
    "Neon Legend"
  } else if rank >= 10 {
    "City Pro"
  } else if rank >= 9 {
    "Street Expert"
  } else if rank >= 8 {
    "Rising Player"
  } else {
    "Rookie"
  }
}

///|
/// Returns the final letter grade from max tile and score.
pub fn final_grade(game : Game) -> String {
  let rank : Int = tile_rank(game.max_tile)
  let score : Int = game.score

  if rank >= 12 || score >= 18000 {
    "S"
  } else if rank >= 11 || score >= 12000 {
    "A"
  } else if rank >= 9 || score >= 7600 {
    "B"
  } else if rank >= 7 || score >= 4200 {
    "C"
  } else {
    "D"
  }
}
