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
pub fn lerpf(a : Float, b : Float, t : Float) -> Float {
  a + (b - a) * t
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

// RNG

///|
let rng_state : Ref[Int] = { val: 12345 }

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

///|
pub fn rng_float() -> Float {
  Float::from_int(rng_next() % 10000) / 10000.0
}

// Hex coordinate math (flat-top, odd-r offset)

///|
pub fn hex_neighbors(coord : HexCoord) -> Array[HexCoord] {
  let col = coord.col
  let row = coord.row
  let parity = row % 2
  if parity == 1 {
    // Odd row
    [
      { col: col + 1, row },
      { col, row: row - 1 },
      { col: col - 1, row: row - 1 },
      { col: col - 1, row },
      { col: col - 1, row: row + 1 },
      { col, row: row + 1 },
    ]
  } else {
    // Even row
    [
      { col: col + 1, row },
      { col: col + 1, row: row - 1 },
      { col, row: row - 1 },
      { col: col - 1, row },
      { col, row: row + 1 },
      { col: col + 1, row: row + 1 },
    ]
  }
}

///|
pub fn hex_are_adjacent(a : HexCoord, b : HexCoord) -> Bool {
  let neighbors = hex_neighbors(a)
  for i in 0..<neighbors.length() {
    if neighbors[i].col == b.col && neighbors[i].row == b.row {
      return true
    }
  }
  false
}

///|
pub fn hex_in_bounds(coord : HexCoord, width : Int, height : Int) -> Bool {
  coord.col >= 0 && coord.col < width && coord.row >= 0 && coord.row < height
}

// Convert hex coord to pixel center (flat-top, odd-r offset)

///|
pub fn hex_to_pixel(coord : HexCoord, size : Float) -> (Float, Float) {
  let col_f = Float::from_int(coord.col)
  let row_f = Float::from_int(coord.row)
  let w = size * 2.0
  let h = sqrtf(3.0) * size
  let x = map_offset_x + col_f * (w * 0.75) + size
  let y = if coord.row % 2 == 1 {
    map_offset_y + row_f * h + h / 2.0 + size * 0.866
  } else {
    map_offset_y + row_f * h + size * 0.866
  }
  (x, y)
}

// Convert pixel to hex coord (approximate, for mouse picking)

///|
pub fn pixel_to_hex(px : Float, py : Float, size : Float) -> HexCoord {
  let w = size * 2.0
  let h = sqrtf(3.0) * size
  // Approximate: find closest hex center
  let mut best_col = 0
  let mut best_row = 0
  let mut best_dist : Float = 999999.0
  for row in 0..<map_height {
    for col in 0..<map_width {
      let coord : HexCoord = { col, row }
      let (hx, hy) = hex_to_pixel(coord, size)
      let dx = px - hx
      let dy = py - hy
      let dist = dx * dx + dy * dy
      if dist < best_dist {
        best_dist = dist
        best_col = col
        best_row = row
      }
    }
    // Suppress unused variable warnings
    ignore(w)
    ignore(h)
  }
  { col: best_col, row: best_row }
}

///|
pub fn water_cost(kind : TileKind) -> Int {
  match kind {
    Sand => 1
    Dunes => 2
    Oasis => 0
    TradePost => 1
    Ruins => 0
    Sandstorm => 99
    Destination => 1
  }
}

///|
pub fn tile_name(kind : TileKind) -> String {
  match kind {
    Sand => "Sand"
    Dunes => "Dunes"
    Oasis => "Oasis"
    TradePost => "Trade Post"
    Ruins => "Ruins"
    Sandstorm => "Sandstorm"
    Destination => "Destination"
  }
}

///|
pub fn tier_name(tier : Tier) -> String {
  match tier {
    OasisTrail => "Oasis Trail"
    DuneSea => "Dune Sea"
    LostCity => "Lost City"
  }
}

///|
pub fn tier_level_range(tier : Tier) -> (Int, Int) {
  match tier {
    OasisTrail => (0, 7)
    DuneSea => (8, 16)
    LostCity => (17, 24)
  }
}

///|
pub fn level_tier(level_idx : Int) -> Tier {
  if level_idx < 8 {
    OasisTrail
  } else if level_idx < 17 {
    DuneSea
  } else {
    LostCity
  }
}

// Constructors

///|
pub fn new_hex_tile(kind : TileKind) -> HexTile {
  { kind, }
}

///|
pub fn new_hex_map(width : Int, height : Int) -> HexMap {
  let tiles : Array[Array[HexTile]] = []
  for _r in 0..<height {
    let row : Array[HexTile] = []
    for _c in 0..<width {
      row.push({ kind: Sand })
    }
    tiles.push(row)
  }
  { width, height, tiles }
}

///|
pub fn new_caravan(start : HexCoord, water : Int) -> Caravan {
  {
    pos: start,
    water,
    max_water: water,
    gold: 0,
    artifacts: 0,
    route: [],
    route_index: 0,
    move_timer: 0.0,
  }
}

///|
pub fn new_level_score() -> LevelScore {
  { stars: 0, best_gold: 0, best_artifacts: 0, completed: false }
}

///|
pub fn new_game() -> Game {
  let scores : Array[LevelScore] = []
  for _i in 0..<total_levels {
    scores.push(new_level_score())
  }
  {
    screen: Title,
    play_state: Planning,
    current_tier: OasisTrail,
    current_level: 0,
    caravan: new_caravan({ col: 0, row: 0 }, 10),
    level: None,
    route: [],
    hover_hex: None,
    scores,
    message: "",
    message_timer: 0.0,
    rng: 42,
    frame_count: 0,
    execute_timer: 0.0,
    result_gold: 0,
    result_artifacts: 0,
    result_stars: 0,
    water_preview: 0,
    anim_timer: 0.0,
  }
}

///|
pub fn set_message(game : Game, msg : String, duration : Float) -> Unit {
  game.message = msg
  game.message_timer = duration
}
