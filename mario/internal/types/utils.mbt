///|
/// Convert tile column to world-pixel X (left edge of tile).
pub fn tile_to_world_x(tx : Int) -> Float {
  Float::from_int(tx * tile_size)
}

///|
/// Convert tile row to world-pixel Y (top edge of tile).
pub fn tile_to_world_y(ty : Int) -> Float {
  Float::from_int(ty * tile_size)
}

///|
/// Convert world X to tile column.
pub fn world_to_tile_x(wx : Float) -> Int {
  let i = (wx / tile_sizef).to_int()
  if wx < 0.0 {
    i - 1
  } else {
    i
  }
}

///|
/// Convert world Y to tile row.
pub fn world_to_tile_y(wy : Float) -> Int {
  let i = (wy / tile_sizef).to_int()
  if wy < 0.0 {
    i - 1
  } else {
    i
  }
}

///|
/// Returns true if the tile kind blocks movement.
pub fn is_solid(tile : TileKind) -> Bool {
  match tile {
    Ground
    | BrickBlock
    | QuestionCoin
    | QuestionMushroom
    | QuestionStar
    | QuestionOneUp
    | UsedBlock
    | PipeTopLeft
    | PipeTopRight
    | PipeBodyLeft
    | PipeBodyRight
    | CastleBlock
    | CastleTop => true
    _ => false
  }
}

///|
/// Returns true if Mario can bump this block from below.
pub fn is_bumpable(tile : TileKind) -> Bool {
  match tile {
    BrickBlock
    | QuestionCoin
    | QuestionMushroom
    | QuestionStar
    | QuestionOneUp
    | HiddenCoin
    | HiddenOneUp => true
    _ => false
  }
}

///|
/// Get tile at (tx, ty) from the game map, returning Empty for out-of-bounds.
pub fn get_tile(game : Game, tx : Int, ty : Int) -> TileKind {
  if tx < 0 || tx >= game.map_width || ty < 0 || ty >= game.map_height {
    Empty
  } else {
    game.map_tiles[ty * game.map_width + tx]
  }
}

///|
/// Set tile at (tx, ty).
pub fn set_tile(game : Game, tx : Int, ty : Int, tile : TileKind) -> Unit {
  if tx >= 0 && tx < game.map_width && ty >= 0 && ty < game.map_height {
    game.map_tiles[ty * game.map_width + tx] = tile
  }
}

///|
/// Deterministic xorshift PRNG — returns a non-negative Int.
pub fn rand_next(game : Game) -> Int {
  let mut x = game.rng_state
  x = x ^ (x << 13)
  x = x ^ (x >> 17)
  x = x ^ (x << 5)
  if x < 0 {
    x = -x
  }
  game.rng_state = x
  x
}

///|
/// Random integer in [low, high] inclusive.
pub fn rand_range(game : Game, low : Int, high : Int) -> Int {
  if high <= low {
    low
  } else {
    low + rand_next(game) % (high - low + 1)
  }
}

///|
/// Random float in [low, high].
pub fn rand_rangef(game : Game, low : Float, high : Float) -> Float {
  let n = Float::from_int(rand_next(game) % 10000) / 10000.0
  low + (high - low) * n
}
