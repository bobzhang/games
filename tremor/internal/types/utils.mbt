///|
pub fn sqrtf(a : Float) -> Float {
  Float::from_double(a.to_double().sqrt())
}

///|
pub fn cosf(a : Float) -> Float {
  Float::from_double(@math.cos(a.to_double()))
}

///|
pub fn sinf(a : Float) -> Float {
  Float::from_double(@math.sin(a.to_double()))
}

///|
pub fn atan2f(y : Float, x : Float) -> Float {
  Float::from_double(@math.atan2(y.to_double(), x.to_double()))
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
pub fn dist_i(a : Vec2i, b : Vec2i) -> Float {
  let dx = Float::from_int(a.x - b.x)
  let dy = Float::from_int(a.y - b.y)
  sqrtf(dx * dx + dy * dy)
}

///|
pub fn vec2i(x : Int, y : Int) -> Vec2i {
  { x, y }
}

///|
pub fn tile_center_x(col : Int) -> Float {
  Float::from_int(grid_offset_x + col * cell_size + cell_size / 2)
}

///|
pub fn tile_center_y(row : Int) -> Float {
  Float::from_int(grid_offset_y + row * cell_size + cell_size / 2)
}

///|
pub fn pixel_to_tile(px : Int, py : Int) -> Vec2i? {
  let col = (px - grid_offset_x) / cell_size
  let row = (py - grid_offset_y) / cell_size
  if col >= 0 && col < grid_cols && row >= 0 && row < grid_rows {
    Some(vec2i(col, row))
  } else {
    None
  }
}

///|
pub fn sensor_cost(kind : SensorKind) -> Int {
  match kind {
    Broad => broad_cost
    Precise => precise_cost
    Directional => directional_cost
  }
}

///|
pub fn sensor_range(kind : SensorKind) -> Float {
  match kind {
    Broad => broad_range
    Precise => precise_range
    Directional => directional_range
  }
}

///|
pub fn sensor_uncertainty(kind : SensorKind) -> Float {
  match kind {
    Broad => broad_uncertainty
    Precise => precise_uncertainty
    Directional => directional_uncertainty
  }
}

///|
pub fn sensor_color(kind : SensorKind) -> @raylib.Color {
  match kind {
    Broad => color_sensor_broad
    Precise => color_sensor_precise
    Directional => color_sensor_dir
  }
}

///|
pub fn ring_color(kind : SensorKind) -> @raylib.Color {
  match kind {
    Broad => color_ring_broad
    Precise => color_ring_precise
    Directional => color_ring_dir
  }
}

///|
pub fn new_tile(kind : TileKind) -> TileInfo {
  { kind, }
}

///|
pub fn new_epicenter(x : Int, y : Int) -> Epicenter {
  { pos: vec2i(x, y), found: false }
}

///|
pub fn new_level_score() -> LevelScore {
  { stars: 0, completed: false, best_budget_used: 99, best_guesses: 99 }
}

///|
pub fn make_grid(rows : Int, cols : Int) -> Array[Array[TileInfo]] {
  let grid : Array[Array[TileInfo]] = []
  for _r in 0..<rows {
    let row : Array[TileInfo] = []
    for _c in 0..<cols {
      row.push(new_tile(Empty))
    }
    grid.push(row)
  }
  grid
}

///|
pub fn compass_angle(dir : CompassDir) -> Float {
  match dir {
    North => -pi / 2.0
    East => 0.0
    South => pi / 2.0
    West => pi
  }
}

///|
pub fn next_compass(dir : CompassDir) -> CompassDir {
  match dir {
    North => East
    East => South
    South => West
    West => North
  }
}

///|
let rng_state : Ref[Int] = { val: 42 }

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

///|
pub fn new_game() -> Game {
  let scores : Array[LevelScore] = []
  for _i in 0..<total_levels {
    scores.push(new_level_score())
  }
  {
    screen: Title,
    play_state: Placing,
    current_tier: Detection,
    current_level_index: 0,
    level: None,
    sensors: [],
    readings: [],
    selected_sensor: Broad,
    selected_direction: North,
    budget_used: 0,
    guess_pos: None,
    guess_count: 0,
    sensor_place_count: 0,
    hover_tile: None,
    message: "",
    message_timer: 0.0,
    frame_count: 0,
    level_scores: scores,
    anim_timer: 0.0,
    show_overlap: true,
    rng: 42,
  }
}

///|
pub fn tier_start_index(tier : Tier) -> Int {
  match tier {
    Detection => 0
    Precision => tier1_count
    Crisis => tier1_count + tier2_count
  }
}

///|
pub fn tier_level_count(tier : Tier) -> Int {
  match tier {
    Detection => tier1_count
    Precision => tier2_count
    Crisis => tier3_count
  }
}

///|
pub fn tier_name(tier : Tier) -> String {
  match tier {
    Detection => "Detection"
    Precision => "Precision"
    Crisis => "Crisis"
  }
}

///|
pub fn tier_unlocked(game : Game, tier : Tier) -> Bool {
  match tier {
    Detection => true
    Precision => {
      let mut completed = 0
      for i in 0..<tier1_count {
        if game.level_scores[i].completed {
          completed += 1
        }
      }
      completed >= 4
    }
    Crisis => {
      let start = tier1_count
      let mut completed = 0
      for i in start..<(start + tier2_count) {
        if game.level_scores[i].completed {
          completed += 1
        }
      }
      completed >= 5
    }
  }
}

///|
pub fn level_unlocked(game : Game, index : Int) -> Bool {
  if index == 0 {
    return true
  }
  // First level of each tier
  if index == tier1_count {
    return tier_unlocked(game, Precision)
  }
  if index == tier1_count + tier2_count {
    return tier_unlocked(game, Crisis)
  }
  // Otherwise previous level must be completed
  game.level_scores[index - 1].completed
}
