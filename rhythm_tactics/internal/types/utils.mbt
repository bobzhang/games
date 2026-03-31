///|
pub fn grid_index(x : Int, y : Int, width : Int) -> Int {
  y * width + x
}

///|
pub fn in_bounds(x : Int, y : Int, w : Int, h : Int) -> Bool {
  x >= 0 && y >= 0 && x < w && y < h
}

///|
pub fn grid_get(grid : Grid, x : Int, y : Int) -> Tile? {
  if in_bounds(x, y, grid.width, grid.height) {
    Some(grid.tiles[grid_index(x, y, grid.width)])
  } else {
    None
  }
}

///|
pub fn grid_set_kind(grid : Grid, x : Int, y : Int, kind : TileKind) -> Unit {
  if in_bounds(x, y, grid.width, grid.height) {
    grid.tiles[grid_index(x, y, grid.width)].kind = kind
  }
}

///|
pub fn grid_is_walkable(grid : Grid, x : Int, y : Int) -> Bool {
  match grid_get(grid, x, y) {
    Some(tile) =>
      match tile.kind {
        Floor | Ice | Exit | Spike => true
        Wall | Pit => false
      }
    None => false
  }
}

///|
pub fn dir_dx(dir : Direction) -> Int {
  match dir {
    East => 1
    West => -1
    North | South => 0
  }
}

///|
pub fn dir_dy(dir : Direction) -> Int {
  match dir {
    South => 1
    North => -1
    East | West => 0
  }
}

///|
pub fn opposite_dir(dir : Direction) -> Direction {
  match dir {
    North => South
    South => North
    East => West
    West => East
  }
}

///|
pub fn rand_next(state : Ref[Int]) -> Int {
  let mut x = state.val
  x = x ^ (x << 13)
  x = x ^ (x >> 17)
  x = x ^ (x << 5)
  if x < 0 {
    x = -x
  }
  state.val = x
  x
}

///|
pub fn rand_range(state : Ref[Int], lo : Int, hi : Int) -> Int {
  if hi <= lo {
    lo
  } else {
    lo + rand_next(state) % (hi - lo + 1)
  }
}

///|
pub fn minf(a : Float, b : Float) -> Float {
  if a < b {
    a
  } else {
    b
  }
}

///|
pub fn maxf(a : Float, b : Float) -> Float {
  if a > b {
    a
  } else {
    b
  }
}

///|
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
pub fn absf(v : Float) -> Float {
  if v < 0.0 {
    -v
  } else {
    v
  }
}

///|
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
pub fn tile_screen_x(gx : Int) -> Int {
  grid_offset_x + gx * tile_size
}

///|
pub fn tile_screen_y(gy : Int) -> Int {
  grid_offset_y + gy * tile_size
}

///|
pub fn manhattan_dist(x1 : Int, y1 : Int, x2 : Int, y2 : Int) -> Int {
  let dx = x1 - x2
  let dy = y1 - y2
  (if dx < 0 { -dx } else { dx }) + (if dy < 0 { -dy } else { dy })
}

///|
pub fn direction_from_to(
  fx : Int,
  fy : Int,
  tx : Int,
  ty : Int,
) -> Direction {
  let dx = tx - fx
  let dy = ty - fy
  let adx = if dx < 0 { -dx } else { dx }
  let ady = if dy < 0 { -dy } else { dy }
  if adx >= ady {
    if dx > 0 {
      East
    } else {
      West
    }
  } else if dy > 0 {
    South
  } else {
    North
  }
}

///|
pub fn has_enemy_at(enemies : Array[Enemy], x : Int, y : Int) -> Bool {
  for e in enemies {
    if e.active && e.x == x && e.y == y {
      return true
    }
  }
  false
}

///|
pub fn find_enemy_at(enemies : Array[Enemy], x : Int, y : Int) -> Int {
  for i, e in enemies {
    if e.active && e.x == x && e.y == y {
      return i
    }
  }
  -1
}

///|
pub fn game_rng(game : Game) -> Ref[Int] {
  let r : Ref[Int] = { val: game.rng_state }
  r
}

///|
pub fn sync_rng(game : Game, r : Ref[Int]) -> Unit {
  game.rng_state = r.val
}

///|
pub fn set_message(game : Game, text : String) -> Unit {
  game.message_text = text
  game.message_timer = message_duration
}

///|
pub fn tile_color(kind : TileKind) -> @raylib.Color {
  match kind {
    Floor => color_floor_base
    Wall => color_wall
    Pit => color_pit
    Spike => color_spike
    Ice => color_ice
    Exit => color_exit
  }
}

///|
pub fn enemy_color(kind : EnemyKind) -> @raylib.Color {
  match kind {
    Slime => @raylib.Color::new(100, 220, 80, 255)
    Skeleton => @raylib.Color::new(220, 220, 200, 255)
    Bat => @raylib.Color::new(160, 80, 200, 255)
    Dragon => @raylib.Color::new(255, 120, 40, 255)
    Mimic => @raylib.Color::new(200, 180, 50, 255)
    Golem => @raylib.Color::new(140, 140, 160, 255)
    Wraith => @raylib.Color::new(100, 180, 255, 255)
    Boss => @raylib.Color::new(255, 40, 40, 255)
  }
}

///|
pub fn rating_color(rating : BeatRating) -> @raylib.Color {
  match rating {
    Perfect => color_perfect
    Good => color_good
    Miss => color_miss
  }
}

///|
pub fn rating_text(rating : BeatRating) -> String {
  match rating {
    Perfect => "PERFECT!"
    Good => "GOOD"
    Miss => "MISS"
  }
}
