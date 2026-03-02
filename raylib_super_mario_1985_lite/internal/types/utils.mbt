///|
/// Clamps an integer to the inclusive `[lo, hi]` range.
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
/// Returns the absolute value of `v`.
pub fn absf(v : Float) -> Float {
  if v < 0.0 {
    -v
  } else {
    v
  }
}

///|
/// Returns the sign of `v` as `-1`, `0`, or `1`.
pub fn signf(v : Float) -> Int {
  if v < 0.0 {
    -1
  } else if v > 0.0 {
    1
  } else {
    0
  }
}

///|
/// Converts tile coordinates to a linear tile array index.
pub fn tile_index(tx : Int, ty : Int) -> Int {
  ty * world_tiles_w + tx
}

///|
/// Returns the world x-coordinate of a tile's left edge.
pub fn tile_left(tx : Int) -> Float {
  Float::from_int(tx * tile_size)
}

///|
/// Returns the world y-coordinate of a tile's top edge.
pub fn tile_top(ty : Int) -> Float {
  Float::from_int(ty * tile_size)
}

///|
/// Returns the world x-coordinate of a tile center.
pub fn tile_center_x(tx : Int) -> Float {
  tile_left(tx) + tile_size_f * 0.5
}

///|
/// Returns the world y-coordinate of a tile center.
pub fn tile_center_y(ty : Int) -> Float {
  tile_top(ty) + tile_size_f * 0.5
}

///|
/// Converts world x to a clamped tile x index.
pub fn world_to_tile_x(x : Float) -> Int {
  if x <= 0.0 {
    0
  } else {
    clampi((x / tile_size_f).to_int(), 0, world_tiles_w - 1)
  }
}

///|
/// Converts world y to a clamped tile y index.
pub fn world_to_tile_y(y : Float) -> Int {
  if y <= 0.0 {
    0
  } else {
    clampi((y / tile_size_f).to_int(), 0, world_tiles_h - 1)
  }
}

///|
/// Writes a tile value if coordinates are inside bounds.
pub fn set_tile(game : Game, tx : Int, ty : Int, tile : Int) -> Unit {
  if tx < 0 || tx >= world_tiles_w || ty < 0 || ty >= world_tiles_h {
    return
  }
  game.tiles[tile_index(tx, ty)] = tile
}

///|
/// Reads a tile value with out-of-bounds defaults.
pub fn get_tile(game : Game, tx : Int, ty : Int) -> Int {
  if tx < 0 || tx >= world_tiles_w {
    return tile_ground
  }
  if ty < 0 {
    return tile_empty
  }
  if ty >= world_tiles_h {
    return tile_ground
  }
  game.tiles[tile_index(tx, ty)]
}

///|
/// Fills a tile rectangle with a tile id.
pub fn fill_rect_tile(
  game : Game,
  tx0 : Int,
  ty0 : Int,
  tw : Int,
  th : Int,
  tile : Int,
) -> Unit {
  for y in ty0..<(ty0 + th) {
    for x in tx0..<(tx0 + tw) {
      set_tile(game, x, y, tile)
    }
  }
}

///|
/// Resets all tiles in the level to empty.
pub fn clear_tiles(game : Game) -> Unit {
  for i in 0..<game.tiles.length() {
    game.tiles[i] = tile_empty
  }
}

///|
/// Returns whether a tile id should block movement.
pub fn tile_is_solid(tile : Int) -> Bool {
  tile == tile_ground ||
  tile == tile_brick ||
  tile == tile_question ||
  tile == tile_used ||
  tile == tile_pipe ||
  tile == tile_castle
}

///|
/// Returns whether two axis-aligned rectangles overlap.
pub fn rects_overlap(
  ax0 : Float,
  ay0 : Float,
  ax1 : Float,
  ay1 : Float,
  bx0 : Float,
  by0 : Float,
  bx1 : Float,
  by1 : Float,
) -> Bool {
  ax0 < bx1 && ax1 > bx0 && ay0 < by1 && ay1 > by0
}

///|
/// Converts world x to screen x using camera offset.
pub fn world_to_screen_x(world_x : Float, camera_x : Float) -> Float {
  world_x - camera_x
}

///|
/// Returns half of player width.
pub fn player_half_w() -> Float {
  player_w * 0.5
}

///|
/// Returns half of player height.
pub fn player_half_h() -> Float {
  player_h * 0.5
}

///|
/// Returns half of enemy width.
pub fn enemy_half_w() -> Float {
  enemy_w * 0.5
}

///|
/// Returns half of enemy height.
pub fn enemy_half_h() -> Float {
  enemy_h * 0.5
}

///|
/// Returns a random float in `[minv, maxv]`.
pub fn randf(minv : Float, maxv : Float) -> Float {
  let r = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  minv + (maxv - minv) * r
}

///|
/// Counts active coins remaining in the level.
pub fn remaining_coins(game : Game) -> Int {
  let mut count = 0
  for coin in game.coins {
    if coin.active {
      count += 1
    }
  }
  count
}

///|
/// Counts active enemies in the level.
pub fn active_enemy_count(game : Game) -> Int {
  let mut count = 0
  for enemy in game.enemies {
    if enemy.active {
      count += 1
    }
  }
  count
}
