///|
pub fn new_tile(kind : TileKind, elevation : Int32) -> Tile {
  { kind, elevation, has_signal: false, signal_anim: 0.0, }
}

///|
pub fn new_signal_path(
  from_col : Int32,
  from_row : Int32,
  to_col : Int32,
  to_row : Int32,
) -> SignalPath {
  { from_col, from_row, to_col, to_row, progress: 0.0, active: true, }
}

///|
pub fn new_level_state(data : LevelData) -> LevelState {
  let grid : Array[Array[Tile]] = []
  for r in 0..<grid_rows {
    let row : Array[Tile] = []
    for c in 0..<grid_cols {
      let kind = data.grid[r][c]
      let elev = data.elevations[r][c]
      row.push(new_tile(kind, elev))
    }
    grid.push(row)
  }
  {
    grid,
    towers_placed: 0,
    budget: data.budget,
    all_receivers_lit: false,
    relay_chain_length: 0,
    signal_paths: [],
    cursor_col: -1,
    cursor_row: -1,
    hover_valid: false,
  }
}

///|
pub fn new_level_progress() -> LevelProgress {
  { completed: false, stars: None, best_towers: 999, best_chain: 999, }
}

///|
pub fn new_game() -> Game {
  let progress : Array[LevelProgress] = []
  for _i in 0..<total_levels {
    progress.push(new_level_progress())
  }
  {
    screen: Title,
    current_level: 0,
    level_data: None,
    level_state: None,
    progress,
    anim_timer: 0.0,
    message: "",
    message_timer: 0.0,
    scroll_offset: 0,
    frame_count: 0,
    signal_phase: 0.0,
  }
}

///|
pub fn tile_screen_x(col : Int32) -> Int32 {
  grid_offset_x + col * tile_size
}

///|
pub fn tile_screen_y(row : Int32) -> Int32 {
  grid_offset_y + row * tile_size
}

///|
pub fn tile_center_x(col : Int32) -> Float {
  Float::from_int(tile_screen_x(col)) + Float::from_int(tile_size) / 2.0
}

///|
pub fn tile_center_y(row : Int32) -> Float {
  Float::from_int(tile_screen_y(row)) + Float::from_int(tile_size) / 2.0
}

///|
pub fn screen_to_grid_col(x : Int32) -> Int32 {
  (x - grid_offset_x) / tile_size
}

///|
pub fn screen_to_grid_row(y : Int32) -> Int32 {
  (y - grid_offset_y) / tile_size
}

///|
pub fn in_grid(col : Int32, row : Int32) -> Bool {
  col >= 0 && col < grid_cols && row >= 0 && row < grid_rows
}

///|
pub fn tower_range(elevation : Int32) -> Int32 {
  base_range + elevation
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
pub fn maxf(a : Float, b : Float) -> Float {
  if a > b {
    a
  } else {
    b
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
pub fn maxi(a : Int32, b : Int32) -> Int32 {
  if a > b {
    a
  } else {
    b
  }
}

///|
pub fn mini(a : Int32, b : Int32) -> Int32 {
  if a < b {
    a
  } else {
    b
  }
}

///|
pub fn sinf(a : Float) -> Float {
  Float::from_double(@math.sin(a.to_double()))
}

///|
pub fn cosf(a : Float) -> Float {
  Float::from_double(@math.cos(a.to_double()))
}

///|
pub fn set_message(game : Game, msg : String, duration : Float) -> Unit {
  game.message = msg
  game.message_timer = duration
}

///|
pub fn star_count(rating : StarRating) -> Int32 {
  match rating {
    None => 0
    One => 1
    Two => 2
    Three => 3
  }
}
