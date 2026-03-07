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
/// Advances the xorshift RNG and returns the next non-negative random integer.
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
/// Returns a random integer in the inclusive `[low, high]` range.
pub fn rand_range(game : Game, low : Int, high : Int) -> Int {
  if high <= low {
    low
  } else {
    low + rand_next(game) % (high - low + 1)
  }
}

///|
/// Returns a random float in the `[low, high]` range.
pub fn rand_rangef(game : Game, low : Float, high : Float) -> Float {
  let n = Float::from_int(rand_next(game) % 10000) / 10000.0
  low + (high - low) * n
}

///|
/// Returns a random direction.
pub fn rand_dir(game : Game) -> Dir {
  Dir::from_int(rand_range(game, 0, 3))
}

///|
/// Converts tile coordinates to a linear map index.
pub fn tile_index(tx : Int, ty : Int) -> Int {
  ty * map_tiles_w + tx
}

///|
/// Returns whether the tile coordinates are within the map bounds.
pub fn in_tile_bounds(tx : Int, ty : Int) -> Bool {
  tx >= 0 && ty >= 0 && tx < map_tiles_w && ty < map_tiles_h
}

///|
/// Returns the tile type at the given tile coordinates, or steel if out of bounds.
pub fn Game::get_tile(game : Game, tx : Int, ty : Int) -> Tile {
  if in_tile_bounds(tx, ty) {
    game.map_tiles[tile_index(tx, ty)]
  } else {
    Steel
  }
}

///|
/// Sets the tile type and hit points at the given tile coordinates.
pub fn Game::set_tile(game : Game, tx : Int, ty : Int, tile : Tile, hp : Int) -> Unit {
  if in_tile_bounds(tx, ty) {
    let idx = tile_index(tx, ty)
    game.map_tiles[idx] = tile
    game.map_hp[idx] = hp
  }
}

///|
/// Converts a world X coordinate to the corresponding tile column.
pub fn world_x_to_tile(x : Float) -> Int {
  (x / Float::from_int(tile_size)).to_int().clamp(min=0, max=map_tiles_w - 1)
}

///|
/// Converts a world Y coordinate to the corresponding tile row.
pub fn world_y_to_tile(y : Float) -> Int {
  (y / Float::from_int(tile_size)).to_int().clamp(min=0, max=map_tiles_h - 1)
}

///|
/// Returns the world X center of a tile column.
pub fn tile_center_x(tx : Int) -> Float {
  Float::from_int(tx * tile_size + tile_size / 2)
}

///|
/// Returns the world Y center of a tile row.
pub fn tile_center_y(ty : Int) -> Float {
  Float::from_int(ty * tile_size + tile_size / 2)
}

///|
/// Converts a world X coordinate to a screen X coordinate with camera shake.
pub fn world_to_screen_x(x : Float, shake_x : Float) -> Int {
  map_offset_x + x.to_int() + shake_x.to_int()
}

///|
/// Converts a world Y coordinate to a screen Y coordinate with camera shake.
pub fn world_to_screen_y(y : Float, shake_y : Float) -> Int {
  map_offset_y + y.to_int() + shake_y.to_int()
}

///|
/// Converts a tile column to a screen X coordinate with camera shake.
pub fn tile_to_screen_x(tx : Int, shake_x : Float) -> Int {
  map_offset_x + tx * tile_size + shake_x.to_int()
}

///|
/// Converts a tile row to a screen Y coordinate with camera shake.
pub fn tile_to_screen_y(ty : Int, shake_y : Float) -> Int {
  map_offset_y + ty * tile_size + shake_y.to_int()
}

///|
/// Returns the X component of a unit direction vector.
pub fn dir_vector_x(dir : Dir) -> Float {
  match dir {
    Left => -1.0
    Right => 1.0
    _ => 0.0
  }
}

///|
/// Returns the Y component of a unit direction vector.
pub fn dir_vector_y(dir : Dir) -> Float {
  match dir {
    Up => -1.0
    Down => 1.0
    _ => 0.0
  }
}

///|
/// Returns the axis-aligned bounding rectangle for a tank centered at `(x, y)`.
pub fn tank_rect_at(x : Float, y : Float) -> @raylib.Rectangle {
  @raylib.Rectangle::new(x - tank_half, y - tank_half, tank_size, tank_size)
}

///|
/// Returns the axis-aligned bounding rectangle for the given `tank`.
pub fn tank_rect(tank : Tank) -> @raylib.Rectangle {
  tank_rect_at(tank.x, tank.y)
}

///|
/// Returns whether two rectangles overlap.
pub fn rects_overlap(a : @raylib.Rectangle, b : @raylib.Rectangle) -> Bool {
  @raylib.check_collision_recs(a, b)
}

///|
/// Returns the squared distance between two points.
pub fn distance_sq(ax : Float, ay : Float, bx : Float, by : Float) -> Float {
  let dx = ax - bx
  let dy = ay - by
  dx * dx + dy * dy
}

///|
/// Returns whether the tile type blocks tank movement.
pub fn is_tile_solid_for_tank(tile : Tile) -> Bool {
  match tile {
    Brick | Steel | Water | Base => true
    _ => false
  }
}

///|
/// Returns whether the tile type blocks bullets.
pub fn is_tile_solid_for_bullet(tile : Tile) -> Bool {
  match tile {
    Brick | Steel | Base => true
    _ => false
  }
}

///|
/// Returns the score value awarded for destroying an enemy of the given `kind`.
pub fn enemy_score(kind : EnemyKind) -> Int {
  match kind {
    Fast => 200
    Heavy => 400
    Sniper => 300
    Basic => 100
  }
}

///|
/// Returns the display color for an enemy of the given `kind`.
pub fn enemy_color(kind : EnemyKind) -> @raylib.Color {
  match kind {
    Fast => @raylib.orange
    Heavy => @raylib.red
    Sniper => @raylib.purple
    Basic => @raylib.yellow
  }
}

///|
/// Returns the team identifier for the given player `index`.
pub fn team_of_player(index : Int) -> Team {
  if index == 0 {
    Player1
  } else {
    Player2
  }
}

///|
/// Draws text horizontally centered at `center_x` with a given `y` position.
pub fn draw_centered_text(
  text : String,
  center_x : Int,
  y : Int,
  font_size : Int,
  color : @raylib.Color,
) -> Unit {
  let w = @raylib.measure_text(text, font_size)
  @raylib.draw_text(text, center_x - w / 2, y, font_size, color)
}

///|
/// Draws text with a black drop shadow offset by two pixels.
pub fn draw_shadow_text(
  text : String,
  x : Int,
  y : Int,
  size : Int,
  color : @raylib.Color,
) -> Unit {
  @raylib.draw_text(text, x + 2, y + 2, size, @raylib.black)
  @raylib.draw_text(text, x, y, size, color)
}

///|
/// Returns the current camera shake X and Y offsets.
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
/// Updates the camera shake intensity, decaying it over time.
pub fn update_camera_shake(game : Game, dt : Float) -> Unit {
  if game.camera_shake > 0.0 {
    game.camera_shake -= dt * camera_shake_decay * camera_shake_power
    if game.camera_shake < 0.0 {
      game.camera_shake = 0.0
    }
  }
}

///|
/// Applies additional camera shake up to the maximum power.
pub fn push_camera_shake(game : Game, amount : Float) -> Unit {
  let next = game.camera_shake + amount
  if next > camera_shake_power {
    game.camera_shake = camera_shake_power
  } else {
    game.camera_shake = next
  }
}

///|
/// Returns a color that pulses between `base` and white based on `phase`.
pub fn pulse_color(base : @raylib.Color, phase : Float) -> @raylib.Color {
  let p = @math.sinf(phase) * 0.5 + 0.5
  @raylib.color_lerp(base, @raylib.white, p * 0.4)
}

///|
/// Returns the display color for a powerup of the given `kind`.
pub fn powerup_color(kind : PowerupKind) -> @raylib.Color {
  match kind {
    Shield => @raylib.skyblue
    Star => @raylib.gold
    Grenade => @raylib.red
    Clock => @raylib.lime
    Shovel => @raylib.brown
    Tank => @raylib.orange
  }
}

///|
/// Returns the single-character label for a powerup of the given `kind`.
pub fn powerup_text(kind : PowerupKind) -> String {
  match kind {
    Shield => "S"
    Star => "*"
    Grenade => "G"
    Clock => "C"
    Shovel => "H"
    Tank => "+"
  }
}

///|
/// Returns the collision radius for a powerup of the given `kind`.
pub fn powerup_radius(kind : PowerupKind) -> Float {
  match kind {
    Shield => 11.0
    Star => 10.0
    Grenade => 12.0
    Clock => 11.0
    Shovel => 11.0
    Tank => 12.0
  }
}
