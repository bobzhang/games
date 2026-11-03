///|
/// Clamps a float to the inclusive `[low, high]` range.
pub fn clampf(v : Float, low : Float, high : Float) -> Float {
  if v < low {
    low
  } else if v > high {
    high
  } else {
    v
  }
}

///|
/// Advances and returns the PRNG state.
pub fn rand_next(game : Game) -> Int32 {
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
/// Returns a random integer in `[low, high]`.
pub fn rand_range(game : Game, low : Int32, high : Int32) -> Int32 {
  if high <= low {
    low
  } else {
    low + rand_next(game) % (high - low + 1)
  }
}

///|
/// Returns a random float in `[low, high]`.
pub fn rand_rangef(game : Game, low : Float, high : Float) -> Float {
  let n = Float::from_int(rand_next(game) % 10000) / 10000.0
  low + (high - low) * n
}

///|
/// Converts tile coordinates to a linear map index.
pub fn tile_index(tx : Int32, ty : Int32) -> Int32 {
  ty * map_tiles_w + tx
}

///|
/// Returns whether tile coordinates are inside map bounds.
pub fn in_tile_bounds(tx : Int32, ty : Int32) -> Bool {
  tx >= 0 && ty >= 0 && tx < map_tiles_w && ty < map_tiles_h
}

///|
/// Reads a tile at coordinates, treating out-of-bounds as steel.
pub fn get_tile(game : Game, tx : Int32, ty : Int32) -> TileKind {
  if in_tile_bounds(tx, ty) {
    game.map_tiles[tile_index(tx, ty)]
  } else {
    Steel
  }
}

///|
/// Writes tile type and hp when coordinates are in bounds.
pub fn set_tile(
  game : Game,
  tx : Int32,
  ty : Int32,
  tile : TileKind,
  hp : Int32,
) -> Unit {
  if in_tile_bounds(tx, ty) {
    let idx = tile_index(tx, ty)
    game.map_tiles[idx] = tile
    game.map_hp[idx] = hp
  }
}

///|
/// Converts world x-coordinate to tile x index.
pub fn world_x_to_tile(x : Float) -> Int32 {
  (x / Float::from_int(tile_size)).to_int().clamp(min=0, max=map_tiles_w - 1)
}

///|
/// Converts world y-coordinate to tile y index.
pub fn world_y_to_tile(y : Float) -> Int32 {
  (y / Float::from_int(tile_size)).to_int().clamp(min=0, max=map_tiles_h - 1)
}

///|
/// Returns world x-coordinate of tile center.
pub fn tile_center_x(tx : Int32) -> Float {
  Float::from_int(tx * tile_size + tile_size / 2)
}

///|
/// Returns world y-coordinate of tile center.
pub fn tile_center_y(ty : Int32) -> Float {
  Float::from_int(ty * tile_size + tile_size / 2)
}

///|
/// Converts world x to screen x with shake offset.
pub fn world_to_screen_x(x : Float, shake_x : Float) -> Int32 {
  map_offset_x + x.to_int() + shake_x.to_int()
}

///|
/// Converts world y to screen y with shake offset.
pub fn world_to_screen_y(y : Float, shake_y : Float) -> Int32 {
  map_offset_y + y.to_int() + shake_y.to_int()
}

///|
/// Converts tile x to screen x with shake offset.
pub fn tile_to_screen_x(tx : Int32, shake_x : Float) -> Int32 {
  map_offset_x + tx * tile_size + shake_x.to_int()
}

///|
/// Converts tile y to screen y with shake offset.
pub fn tile_to_screen_y(ty : Int32, shake_y : Float) -> Int32 {
  map_offset_y + ty * tile_size + shake_y.to_int()
}

///|
/// Returns unit x direction for a direction.
pub fn dir_vector_x(dir : Dir) -> Float {
  match dir {
    Left => -1.0
    Right => 1.0
    Up | Down => 0.0
  }
}

///|
/// Returns unit y direction for a direction.
pub fn dir_vector_y(dir : Dir) -> Float {
  match dir {
    Up => -1.0
    Down => 1.0
    Left | Right => 0.0
  }
}

///|
/// Builds a tank collision rectangle at world coordinates.
pub fn tank_rect_at(x : Float, y : Float) -> @raylib.Rectangle {
  @raylib.Rectangle::new(x - tank_half, y - tank_half, tank_size, tank_size)
}

///|
/// Builds the collision rectangle for a tank.
pub fn tank_rect(tank : Tank) -> @raylib.Rectangle {
  tank_rect_at(tank.x, tank.y)
}

///|
/// Returns whether two rectangles overlap.
pub fn rects_overlap(a : @raylib.Rectangle, b : @raylib.Rectangle) -> Bool {
  @raylib.check_collision_recs(a, b)
}

///|
/// Returns squared distance between two points.
pub fn distance_sq(ax : Float, ay : Float, bx : Float, by : Float) -> Float {
  let dx = ax - bx
  let dy = ay - by
  dx * dx + dy * dy
}

///|
/// Returns whether a tile blocks tank movement.
pub fn is_tile_solid_for_tank(tile : TileKind) -> Bool {
  match tile {
    Brick | Steel | Water | Base => true
    Empty | Bush | Ice => false
  }
}

///|
/// Returns whether a tile blocks bullets.
pub fn is_tile_solid_for_bullet(tile : TileKind) -> Bool {
  match tile {
    Brick | Steel | Base => true
    Empty | Water | Bush | Ice => false
  }
}

///|
/// Returns score awarded for defeating an enemy kind.
pub fn enemy_score(kind : EnemyKind) -> Int32 {
  match kind {
    Fast => 200
    Heavy => 400
    Sniper => 300
    Basic => 100
  }
}

///|
/// Returns display color for an enemy kind.
pub fn enemy_color(kind : EnemyKind) -> @raylib.Color {
  match kind {
    Fast => @raylib.orange
    Heavy => @raylib.red
    Sniper => @raylib.purple
    Basic => @raylib.yellow
  }
}

///|
/// Draws centered text at `center_x`.
pub fn draw_centered_text(
  text : String,
  center_x : Int32,
  y : Int32,
  font_size : Int32,
  color : @raylib.Color,
) -> Unit {
  let w = @draw.measure_text(text, font_size)
  @draw.draw_text(text, center_x - w / 2, y, font_size, color)
}

///|
/// Draws text with a black shadow offset.
pub fn draw_shadow_text(
  text : String,
  x : Int32,
  y : Int32,
  size : Int32,
  color : @raylib.Color,
) -> Unit {
  @draw.draw_text(text, x + 2, y + 2, size, @raylib.black)
  @draw.draw_text(text, x, y, size, color)
}

///|
/// Returns camera shake x/y offsets for current shake state.
pub fn shake_offsets(game : Game) -> (Float, Float) {
  if game.camera_shake <= 0.0 {
    (0.0, 0.0)
  } else {
    game.camera_shake_phase += 0.12
    let sx = @math.cosf(game.camera_shake_phase)
    let sy = Float::from_double(
      @math.sin((game.camera_shake_phase * 1.8).to_double()),
    )
    (sx * game.camera_shake, sy * game.camera_shake * 0.8)
  }
}

///|
/// Decays camera shake over time.
pub fn update_camera_shake(game : Game, dt : Float) -> Unit {
  if game.camera_shake > 0.0 {
    game.camera_shake -= dt * camera_shake_decay * camera_shake_power
    if game.camera_shake < 0.0 {
      game.camera_shake = 0.0
    }
  }
}

///|
/// Adds camera shake up to configured cap.
pub fn push_camera_shake(game : Game, amount : Float) -> Unit {
  let next = game.camera_shake + amount
  if next > camera_shake_power {
    game.camera_shake = camera_shake_power
  } else {
    game.camera_shake = next
  }
}

///|
/// Returns a pulsing tint derived from `base`.
pub fn pulse_color(base : @raylib.Color, phase : Float) -> @raylib.Color {
  let p = @math.sinf(phase) * 0.5 + 0.5
  @raylib.color_lerp(base, @raylib.white, p * 0.4)
}

///|
/// Counts active bombs owned by `team`.
pub fn count_team_bombs(game : Game, team : Team) -> Int32 {
  for bomb in game.bombs; n = 0 {
    if bomb.active && bomb.owner_team == team {
      continue n + 1
    }
  } nobreak {
    n
  }
}
