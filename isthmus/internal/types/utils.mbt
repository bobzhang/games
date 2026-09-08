///|
pub fn new_tile(height : Int, is_settlement : Bool) -> Tile {
  { height, is_settlement, is_sand: false, }
}

///|
pub fn new_grid(width : Int, height : Int) -> Grid {
  let tiles : Array[Tile] = Array::new(capacity=width * height)
  for _i in 0..<(width * height) {
    tiles.push(new_tile(0, false))
  }
  { width, height, tiles, }
}

///|
pub fn grid_index(g : Grid, x : Int, y : Int) -> Int {
  y * g.width + x
}

///|
pub fn grid_get(g : Grid, x : Int, y : Int) -> Tile {
  g.tiles[grid_index(g, x, y)]
}

///|
pub fn grid_in_bounds(g : Grid, x : Int, y : Int) -> Bool {
  x >= 0 && x < g.width && y >= 0 && y < g.height
}

///|
pub fn tile_is_above_water(tile : Tile, sea_level : Int) -> Bool {
  tile.height > sea_level
}

///|
pub fn tile_kind(tile : Tile, sea_level : Int) -> TileKind {
  if tile.height <= sea_level {
    Water
  } else if tile.is_settlement {
    Settlement
  } else if tile.is_sand {
    Sand
  } else {
    Land
  }
}

///|
pub fn copy_grid(g : Grid) -> Grid {
  let tiles : Array[Tile] = Array::new(capacity=g.tiles.length())
  for i in 0..<g.tiles.length() {
    let t = g.tiles[i]
    tiles.push({
      height: t.height,
      is_settlement: t.is_settlement,
      is_sand: t.is_sand,
    })
  }
  { width: g.width, height: g.height, tiles, }
}

///|
pub fn snapshot_grid(
  g : Grid,
  sea_level : Int,
  sand_remaining : Int,
) -> GridSnapshot {
  let tiles : Array[Tile] = Array::new(capacity=g.tiles.length())
  for i in 0..<g.tiles.length() {
    let t = g.tiles[i]
    tiles.push({
      height: t.height,
      is_settlement: t.is_settlement,
      is_sand: t.is_sand,
    })
  }
  { tiles, sea_level, sand_remaining, }
}

///|
pub fn restore_snapshot(g : Grid, snap : GridSnapshot) -> Unit {
  for i in 0..<g.tiles.length() {
    g.tiles[i].height = snap.tiles[i].height
    g.tiles[i].is_settlement = snap.tiles[i].is_settlement
    g.tiles[i].is_sand = snap.tiles[i].is_sand
  }
}

///|
pub fn grid_from_level(level : Level) -> Grid {
  let g = new_grid(level.grid_width, level.grid_height)
  for i in 0..<level.heights.length() {
    g.tiles[i].height = level.heights[i]
  }
  for i in 0..<level.settlements.length() {
    let idx = level.settlements[i]
    g.tiles[idx].is_settlement = true
  }
  g
}

///|
pub fn maxi(a : Int, b : Int) -> Int {
  if a > b {
    a
  } else {
    b
  }
}

///|
pub fn mini(a : Int, b : Int) -> Int {
  if a < b {
    a
  } else {
    b
  }
}

///|
pub fn absi(a : Int) -> Int {
  if a < 0 {
    -a
  } else {
    a
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
pub fn new_level_scores() -> Array[LevelScore] {
  let scores : Array[LevelScore] = Array::new(capacity=total_levels)
  for _i in 0..<total_levels {
    scores.push({ completed: false, stars: 0, })
  }
  scores
}

///|
pub fn new_game() -> Game {
  {
    screen: Title,
    play_state: Placing,
    grid: new_grid(grid_cols, grid_rows),
    sea_level: 0,
    max_sea_level: 3,
    sand_remaining: 10,
    turn: 0,
    selected_tier: Shores,
    selected_level: 0,
    level_scores: new_level_scores(),
    history: [],
    never_disconnected: true,
    message: "",
    message_timer: 0.0,
    frame_count: 0,
    anim_timer: 0.0,
    hover_x: -1,
    hover_y: -1,
    rising_anim: 0.0,
    show_flood_preview: true,
  }
}

///|
pub fn set_message(game : Game, msg : String, duration : Float) -> Unit {
  game.message = msg
  game.message_timer = duration
}

///|
pub fn tier_index(tier : Tier) -> Int {
  match tier {
    Shores => 0
    Straits => 1
    Archipelago => 2
  }
}

///|
pub fn tier_from_index(i : Int) -> Tier {
  match i {
    0 => Shores
    1 => Straits
    _ => Archipelago
  }
}

///|
pub fn tier_start_level(tier : Tier) -> Int {
  match tier {
    Shores => 0
    Straits => 7
    Archipelago => 14
  }
}

///|
pub fn tier_level_count(tier : Tier) -> Int {
  match tier {
    Shores => 7
    Straits => 7
    Archipelago => 6
  }
}

///|
pub fn tier_name(tier : Tier) -> String {
  match tier {
    Shores => "Shores"
    Straits => "Straits"
    Archipelago => "Archipelago"
  }
}

///|
pub fn settlement_positions(g : Grid) -> Array[Int] {
  let result : Array[Int] = []
  for i in 0..<g.tiles.length() {
    if g.tiles[i].is_settlement {
      result.push(i)
    }
  }
  result
}

///|
pub fn index_to_xy(g : Grid, idx : Int) -> (Int, Int) {
  (idx % g.width, idx / g.width)
}

///|
pub fn lerp_color(
  a : @raylib.Color,
  b : @raylib.Color,
  t : Float,
) -> @raylib.Color {
  let t2 = clampf(t, 0.0, 1.0)
  let ar = a.r.to_int()
  let ag = a.g.to_int()
  let ab = a.b.to_int()
  let aa = a.a.to_int()
  let br = b.r.to_int()
  let bg = b.g.to_int()
  let bb = b.b.to_int()
  let ba = b.a.to_int()
  let r = ar + (Float::from_int(br - ar) * t2).to_int()
  let g = ag + (Float::from_int(bg - ag) * t2).to_int()
  let bl = ab + (Float::from_int(bb - ab) * t2).to_int()
  let a2 = aa + (Float::from_int(ba - aa) * t2).to_int()
  @raylib.Color::new(r, g, bl, a2)
}
