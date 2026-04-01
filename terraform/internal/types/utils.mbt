///|
pub fn sinf(a : Float) -> Float {
  Float::from_double(@math.sin(a.to_double()))
}

///|
pub fn cosf(a : Float) -> Float {
  Float::from_double(@math.cos(a.to_double()))
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

// Hex coordinate math using odd-r offset coordinates.
// In odd-r: odd rows are shifted right by half a hex width.

///|
pub fn hex_to_pixel(col : Int, row : Int) -> (Float, Float) {
  let w = hex_size * sqrtf(3.0)
  let h = hex_size * 2.0
  let x_offset = if row % 2 == 1 { w / 2.0 } else { 0.0 }
  let px = grid_offset_x + Float::from_int(col) * w + x_offset + w / 2.0
  let py = grid_offset_y + Float::from_int(row) * (h * 0.75) + h / 2.0
  (px, py)
}

///|
pub fn pixel_to_hex(px : Float, py : Float, grid_width : Int, grid_height : Int) -> (Int, Int) {
  let w = hex_size * sqrtf(3.0)
  let h = hex_size * 2.0
  // Rough row estimate
  let approx_row = ((py - grid_offset_y - h / 2.0) / (h * 0.75)).to_int()
  let mut best_col = -1
  let mut best_row = -1
  let mut best_dist : Float = 99999.0
  // Search nearby cells
  let r_lo = maxi(0, approx_row - 1)
  let r_hi = mini(grid_height - 1, approx_row + 1)
  for r in r_lo..=r_hi {
    let x_offset = if r % 2 == 1 { w / 2.0 } else { 0.0 }
    for c in 0..<grid_width {
      let cx = grid_offset_x + Float::from_int(c) * w + x_offset + w / 2.0
      let cy = grid_offset_y + Float::from_int(r) * (h * 0.75) + h / 2.0
      let dx = px - cx
      let dy = py - cy
      let dist = dx * dx + dy * dy
      if dist < best_dist {
        best_dist = dist
        best_col = c
        best_row = r
      }
    }
  }
  // Only accept if close enough
  if best_dist < hex_size * hex_size * 3.0 {
    (best_col, best_row)
  } else {
    (-1, -1)
  }
}

// Get the 6 neighbors of a hex in odd-r offset coordinates,
// with optional horizontal wrapping.

///|
pub fn hex_neighbors(
  col : Int,
  row : Int,
  width : Int,
  height : Int,
  wrap_h : Bool
) -> Array[(Int, Int)] {
  let result : Array[(Int, Int)] = []
  // odd-r neighbor offsets
  // Even row neighbors:
  // (-1,-1),(0,-1),(-1,0),(1,0),(-1,1),(0,1)
  // Odd row neighbors:
  // (0,-1),(1,-1),(-1,0),(1,0),(0,1),(1,1)
  let dirs = if row % 2 == 0 {
    [(-1, -1), (0, -1), (-1, 0), (1, 0), (-1, 1), (0, 1)]
  } else {
    [(0, -1), (1, -1), (-1, 0), (1, 0), (0, 1), (1, 1)]
  }
  for i in 0..<dirs.length() {
    let (dc, dr) = dirs[i]
    let mut nc = col + dc
    let nr = row + dr
    if nr < 0 || nr >= height {
      continue
    }
    if wrap_h {
      if nc < 0 {
        nc = nc + width
      } else if nc >= width {
        nc = nc - width
      }
    } else {
      if nc < 0 || nc >= width {
        continue
      }
    }
    result.push((nc, nr))
  }
  result
}

// Grid helpers

///|
pub fn grid_index(col : Int, row : Int, width : Int) -> Int {
  row * width + col
}

///|
pub fn new_grid(width : Int, height : Int, wrap_h : Bool) -> HexGrid {
  let tiles : Array[HexTile] = []
  for _i in 0..<(width * height) {
    tiles.push({ biome: Barren, locked: false })
  }
  { width, height, tiles, wraps_horizontal: wrap_h }
}

///|
pub fn get_tile(grid : HexGrid, col : Int, row : Int) -> HexTile {
  grid.tiles[grid_index(col, row, grid.width)]
}

///|
pub fn set_biome(grid : HexGrid, col : Int, row : Int, biome : BiomeKind) -> Unit {
  grid.tiles[grid_index(col, row, grid.width)].biome = biome
}

///|
pub fn count_biome(grid : HexGrid, biome : BiomeKind) -> Int {
  let mut count = 0
  for i in 0..<grid.tiles.length() {
    if grid.tiles[i].biome == biome {
      count += 1
    }
  }
  count
}

///|
pub fn count_neighbor_biome(
  grid : HexGrid,
  col : Int,
  row : Int,
  biome : BiomeKind
) -> Int {
  let neighbors = hex_neighbors(
    col, row, grid.width, grid.height, grid.wraps_horizontal,
  )
  let mut count = 0
  for i in 0..<neighbors.length() {
    let (nc, nr) = neighbors[i]
    if get_tile(grid, nc, nr).biome == biome {
      count += 1
    }
  }
  count
}

///|
pub fn biome_ratio(grid : HexGrid, biome : BiomeKind) -> Float {
  let total = Float::from_int(grid.tiles.length())
  if total <= 0.0 {
    return 0.0
  }
  Float::from_int(count_biome(grid, biome)) / total
}

///|
pub fn biome_color(biome : BiomeKind) -> @raylib.Color {
  match biome {
    Barren => color_barren
    Forest => color_forest
    Ocean => color_ocean
    Desert => color_desert
  }
}

///|
pub fn biome_color_light(biome : BiomeKind) -> @raylib.Color {
  match biome {
    Barren => color_barren
    Forest => color_forest_light
    Ocean => color_ocean_light
    Desert => color_desert_light
  }
}

///|
pub fn biome_name(biome : BiomeKind) -> String {
  match biome {
    Barren => "Barren"
    Forest => "Forest"
    Ocean => "Ocean"
    Desert => "Desert"
  }
}

///|
pub fn tier_name(tier : Tier) -> String {
  match tier {
    Seeds => "Seeds"
    Balance => "Balance"
    Harmony => "Harmony"
  }
}

///|
pub fn tier_color(tier : Tier) -> @raylib.Color {
  match tier {
    Seeds => color_tier_seeds
    Balance => color_tier_balance
    Harmony => color_tier_harmony
  }
}

///|
pub fn tier_level_range(tier : Tier) -> (Int, Int) {
  match tier {
    Seeds => (0, tier1_count)
    Balance => (tier1_count, tier1_count + tier2_count)
    Harmony => (tier1_count + tier2_count, total_levels)
  }
}

///|
pub fn level_name(index : Int) -> String {
  match index {
    0 => "First Growth"
    1 => "Oasis"
    2 => "Coastline"
    3 => "Green Belt"
    4 => "Desert Halt"
    5 => "Twin Lakes"
    6 => "Wrap Around"
    7 => "Equator"
    8 => "Drought Line"
    9 => "Island Chain"
    10 => "Polar Caps"
    11 => "Continental Divide"
    12 => "Desert Planet"
    13 => "Ring World"
    14 => "Locked Shores"
    15 => "Archipelago"
    16 => "Crosswinds"
    17 => "Pangaea"
    18 => "Desertification"
    19 => "Terraformer"
    20 => "Frozen World"
    21 => "Biome War"
    22 => "Planet Wrap"
    23 => "Equilibrium"
    24 => "Perfect World"
    _ => "Unknown"
  }
}

///|
pub fn clone_grid(grid : HexGrid) -> HexGrid {
  let tiles : Array[HexTile] = []
  for i in 0..<grid.tiles.length() {
    tiles.push({ biome: grid.tiles[i].biome, locked: grid.tiles[i].locked })
  }
  { width: grid.width, height: grid.height, tiles, wraps_horizontal: grid.wraps_horizontal }
}

///|
pub fn snapshot_biomes(grid : HexGrid) -> Array[BiomeKind] {
  let snap : Array[BiomeKind] = []
  for i in 0..<grid.tiles.length() {
    snap.push(grid.tiles[i].biome)
  }
  snap
}

///|
pub fn new_resolve_snapshot(
  grid : HexGrid,
  budget : PaintBudget,
  turn : Int
) -> ResolveSnapshot {
  {
    biomes: snapshot_biomes(grid),
    budget_forest: budget.forest,
    budget_ocean: budget.ocean,
    budget_desert: budget.desert,
    turn,
  }
}

///|
pub fn new_budget(forest : Int, ocean : Int, desert : Int) -> PaintBudget {
  { forest, ocean, desert }
}

///|
pub fn new_targets(
  f_min : Float,
  f_max : Float,
  o_min : Float,
  o_max : Float,
  d_min : Float,
  d_max : Float
) -> TargetRatio {
  {
    forest_min: f_min,
    forest_max: f_max,
    ocean_min: o_min,
    ocean_max: o_max,
    desert_min: d_min,
    desert_max: d_max,
  }
}

///|
pub fn new_level_score() -> LevelScore {
  { stars: 0, completed: false, best_turns: 999 }
}

///|
pub fn budget_remaining(budget : PaintBudget, biome : BiomeKind) -> Int {
  match biome {
    Forest => budget.forest
    Ocean => budget.ocean
    Desert => budget.desert
    Barren => 999
  }
}

///|
pub fn deduct_budget(budget : PaintBudget, biome : BiomeKind) -> Unit {
  match biome {
    Forest => budget.forest -= 1
    Ocean => budget.ocean -= 1
    Desert => budget.desert -= 1
    Barren => ()
  }
}

///|
pub fn add_budget(budget : PaintBudget, biome : BiomeKind) -> Unit {
  match biome {
    Forest => budget.forest += 1
    Ocean => budget.ocean += 1
    Desert => budget.desert += 1
    Barren => ()
  }
}

///|
pub fn total_budget(budget : PaintBudget) -> Int {
  budget.forest + budget.ocean + budget.desert
}

///|
pub fn new_game() -> Game {
  let scores : Array[LevelScore] = []
  for _i in 0..<total_levels {
    scores.push(new_level_score())
  }
  {
    screen: Title,
    play_state: Painting,
    grid: new_grid(default_grid_width, default_grid_height, true),
    budget: new_budget(0, 0, 0),
    targets: new_targets(0.0, 1.0, 0.0, 1.0, 0.0, 1.0),
    par_turns: 20,
    current_turn: 0,
    selected_biome: Forest,
    hover_col: -1,
    hover_row: -1,
    current_level: 0,
    current_tier: Seeds,
    tier_page: 0,
    level_scores: scores,
    undo_stack: [],
    resolve_timer: 0.0,
    resolve_step: 0,
    anim_timer: 0.0,
    message: "",
    message_timer: 0.0,
    frame_count: 0,
    prev_snapshot: [],
    changed_tiles: [],
    resolve_undo_stack: [],
    spread_queue: [],
    spread_index: 0,
    spread_timer: 0.0,
    show_preview: false,
    preview_tiles: [],
    transition_tiles: [],
    transition_timer: 0.0,
    ratio_pulse_timer: 0.0,
    ratio_just_entered: [false, false, false],
  }
}
