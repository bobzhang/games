///|
pub fn cosf(a : Float) -> Float {
  Float::from_double(@math.cos(a.to_double()))
}

///|
pub fn sinf(a : Float) -> Float {
  Float::from_double(@math.sin(a.to_double()))
}

///|
pub fn sqrtf(a : Float) -> Float {
  Float::from_double(a.to_double().sqrt())
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
pub fn absi(v : Int) -> Int {
  if v < 0 {
    -v
  } else {
    v
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
pub fn lerpf(a : Float, b : Float, t : Float) -> Float {
  a + (b - a) * t
}

// Hex coordinate math for flat-top hexagons with odd-r offset

///|
pub fn hex_to_pixel_x(col : Int, row : Int) -> Float {
  let size = Float::from_int(hex_size)
  let x_offset = Float::from_int(grid_offset_x)
  let col_f = Float::from_int(col)
  let row_offset : Float = if row % 2 == 1 {
    size * sqrtf(3.0) / 2.0
  } else {
    0.0
  }
  x_offset + col_f * size * sqrtf(3.0) + row_offset + size
}

///|
pub fn hex_to_pixel_y(col~ : Int, row : Int) -> Float {
  ignore(col)
  let size = Float::from_int(hex_size)
  let y_offset = Float::from_int(grid_offset_y)
  let row_f = Float::from_int(row)
  y_offset + row_f * size * 1.5 + size
}

///|
pub fn pixel_to_hex(px : Float, py : Float) -> (Int, Int) {
  let size = Float::from_int(hex_size)
  // Search all tiles for closest center
  let mut best_col = -1
  let mut best_row = -1
  let mut best_dist : Float = 99999.0
  for r in 0..<grid_rows {
    for c in 0..<grid_cols {
      let cx = hex_to_pixel_x(c, r)
      let cy = hex_to_pixel_y(col=c, r)
      let dx = px - cx
      let dy = py - cy
      let dist = sqrtf(dx * dx + dy * dy)
      if dist < best_dist && dist < size * 1.2 {
        best_dist = dist
        best_col = c
        best_row = r
      }
    }
  }
  (best_col, best_row)
}

///|
pub fn hex_in_bounds(col : Int, row : Int) -> Bool {
  col >= 0 && col < grid_cols && row >= 0 && row < grid_rows
}

// Get the 6 neighbors of a hex in odd-r offset coordinates

///|
pub fn hex_neighbors(col : Int, row : Int) -> Array[(Int, Int)] {
  let result : Array[(Int, Int)] = []
  if row % 2 == 0 {
    // Even row neighbors
    result.push((col, row - 1)) // NE  -> (col, row-1) for even
    result.push((col + 1, row)) // E
    result.push((col, row + 1)) // SE
    result.push((col - 1, row + 1)) // SW
    result.push((col - 1, row)) // W
    result.push((col - 1, row - 1)) // NW
  } else {
    // Odd row neighbors
    result.push((col + 1, row - 1)) // NE
    result.push((col + 1, row)) // E
    result.push((col + 1, row + 1)) // SE
    result.push((col, row + 1)) // SW
    result.push((col - 1, row)) // W
    result.push((col, row - 1)) // NW
  }
  result
}

///|
pub fn hex_distance(c1 : Int, r1 : Int, c2 : Int, r2 : Int) -> Int {
  // Convert offset to cube coordinates
  let (x1, y1, z1) = offset_to_cube(c1, r1)
  let (x2, y2, z2) = offset_to_cube(c2, r2)
  (absi(x1 - x2) + absi(y1 - y2) + absi(z1 - z2)) / 2
}

///|
pub fn offset_to_cube(col : Int, row : Int) -> (Int, Int, Int) {
  let x = col - (row - (row & 1)) / 2
  let z = row
  let y = -x - z
  (x, y, z)
}

// RNG

///|
let rng_state : Ref[Int] = { val: 42, }

///|
pub fn seed_rng(s : Int) -> Unit {
  rng_state.val = s
}

///|
pub fn rng_next() -> Int {
  rng_state.val = rng_state.val * 1103515245 + 12345
  let v = rng_state.val / 65536
  if v < 0 {
    -v
  } else {
    v
  }
}

///|
pub fn rng_int(max : Int) -> Int {
  if max <= 0 {
    0
  } else {
    rng_next() % max
  }
}

// Constructors

///|
pub fn new_tile(kind : TileKind, height : Int) -> HexTile {
  {
    kind,
    height,
    watered: match kind {
      WaterSource | River => true
      _ => false
    },
    crop: None,
    crop_state: Seed,
    crop_turns: 0,
    has_channel: match kind {
      River => true
      _ => false
    },
  }
}

///|
pub fn new_grid(width : Int, height : Int) -> HexGrid {
  let tiles : Array[Array[HexTile]] = Array(capacity=height)
  for _r in 0..<height {
    let row : Array[HexTile] = Array(capacity=width)
    for _c in 0..<width {
      row.push(new_tile(Dirt, 0))
    }
    tiles.push(row)
  }
  { width, height, tiles, }
}

///|
pub fn new_empty_level() -> Level {
  {
    grid: new_grid(grid_cols, grid_rows),
    water_sources: [],
    turn_budget: 10,
    target_yield: 5,
    goals: [],
    par_turns: 8,
    name: "Empty",
    world: 0,
  }
}

///|
pub fn new_level_score() -> LevelScore {
  {
    yield_collected: 0,
    target_yield: 0,
    turns_used: 0,
    turn_budget: 0,
    par_turns: 0,
    goals_collected: 0,
    total_goals: 0,
    stars: 0,
  }
}

///|
pub fn new_game() -> Game {
  let level_scores : Array[Array[LevelScore?]] = Array(capacity=total_worlds)
  for _w in 0..<total_worlds {
    let world_scores : Array[LevelScore?] = Array(capacity=levels_per_world)
    for _l in 0..<levels_per_world {
      world_scores.push(None)
    }
    level_scores.push(world_scores)
  }
  {
    screen: Title,
    level: new_empty_level(),
    level_index: 0,
    world_index: 0,
    turn: 0,
    yield_collected: 0,
    goals_collected: 0,
    selected_crop: Wheat,
    place_mode: CropPlace(Wheat),
    hover_col: -1,
    hover_row: -1,
    hover_valid: false,
    score: new_level_score(),
    level_scores,
    message: "",
    message_timer: 0.0,
    frame_count: 0,
    menu_selection: 0,
    water_anim_timer: 0.0,
    newly_watered: [],
    newly_harvested: [],
    harvest_anim_timer: 0.0,
    undo_stack: [],
    level_complete: false,
    fade_timer: 0.0,
    rng: 42,
    turn_phase: Idle,
    phase_timer: 0.0,
    click_feedback_timer: 0.0,
    click_feedback_col: -1,
    click_feedback_row: -1,
  }
}

///|
pub fn crop_grow_time(kind : CropKind) -> Int {
  match kind {
    Wheat => 2
    Corn => 3
    Berry => 3
    Flower => 2
  }
}

///|
pub fn crop_base_yield(kind : CropKind) -> Int {
  match kind {
    Wheat => 1
    Corn => 2
    Berry => 2
    Flower => 1
  }
}

///|
pub fn crop_color(kind : CropKind) -> @raylib.Color {
  match kind {
    Wheat => color_wheat
    Corn => color_corn
    Berry => color_berry
    Flower => color_flower
  }
}

///|
pub fn crop_seed_color(kind : CropKind) -> @raylib.Color {
  match kind {
    Wheat => color_wheat_seed
    Corn => color_corn_seed
    Berry => color_berry_seed
    Flower => color_flower_seed
  }
}

///|
pub fn crop_name(kind : CropKind) -> String {
  match kind {
    Wheat => "Wheat"
    Corn => "Corn"
    Berry => "Berry"
    Flower => "Flower"
  }
}

///|
pub fn tile_plantable(tile : HexTile) -> Bool {
  match tile.kind {
    Dirt | Goal => tile.crop is None
    _ => false
  }
}

///|
pub fn tile_channelable(tile : HexTile) -> Bool {
  match tile.kind {
    Dirt => !tile.has_channel && tile.crop is None
    _ => false
  }
}

///|
pub fn set_message(game : Game, msg : String, duration : Float) -> Unit {
  game.message = msg
  game.message_timer = duration
}

///|
pub fn world_name(world : Int) -> String {
  match world {
    0 => "Valley"
    1 => "Hills"
    2 => "Peaks"
    _ => "Unknown"
  }
}

///|
pub fn clone_tile(t : HexTile) -> HexTile {
  {
    kind: t.kind,
    height: t.height,
    watered: t.watered,
    crop: t.crop,
    crop_state: t.crop_state,
    crop_turns: t.crop_turns,
    has_channel: t.has_channel,
  }
}

///|
pub fn clone_grid_tiles(grid : HexGrid) -> Array[Array[HexTile]] {
  let result : Array[Array[HexTile]] = Array(capacity=grid.height)
  for r in 0..<grid.height {
    let row : Array[HexTile] = Array(capacity=grid.width)
    for c in 0..<grid.width {
      row.push(clone_tile(grid.tiles[r][c]))
    }
    result.push(row)
  }
  result
}

///|
pub fn restore_grid_tiles(
  grid : HexGrid,
  saved : Array[Array[HexTile]],
) -> Unit {
  for r in 0..<grid.height {
    for c in 0..<grid.width {
      let s = saved[r][c]
      let t = grid.tiles[r][c]
      t.kind = s.kind
      t.height = s.height
      t.watered = s.watered
      t.crop = s.crop
      t.crop_state = s.crop_state
      t.crop_turns = s.crop_turns
      t.has_channel = s.has_channel
    }
  }
}

///|
pub fn height_color_mod(height : Int) -> Int {
  // Stronger contour shading - higher tiles are noticeably brighter
  match height {
    0 => -35
    1 => -10
    2 => 20
    3 => 45
    _ => 0
  }
}

///|
pub fn tile_color_with_height(
  base : @raylib.Color,
  height : Int,
) -> @raylib.Color {
  let m = height_color_mod(height)
  @raylib.Color::new(
    clampi(base.r.to_int() + m, 0, 255),
    clampi(base.g.to_int() + m, 0, 255),
    clampi(base.b.to_int() + m, 0, 255),
    base.a.to_int(),
  )
}
