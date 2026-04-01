///|
pub fn new_grid(size : Int, fill : Bool) -> Grid {
  let cells : Array[Bool] = Array::make(size * size, fill)
  { size, cells }
}

///|
pub fn grid_from_rows(size : Int, rows : Array[Array[Bool]]) -> Grid {
  let cells : Array[Bool] = Array::make(size * size, false)
  for r in 0..<size {
    for c in 0..<size {
      if r < rows.length() && c < rows[r].length() {
        cells[r * size + c] = rows[r][c]
      }
    }
  }
  { size, cells }
}

///|
pub fn clone_grid(g : Grid) -> Grid {
  let cells : Array[Bool] = Array::make(g.size * g.size, false)
  for i in 0..<(g.size * g.size) {
    cells[i] = g.cells[i]
  }
  { size: g.size, cells }
}

///|
pub fn grid_get(g : Grid, row : Int, col : Int) -> Bool {
  if row < 0 || row >= g.size || col < 0 || col >= g.size {
    false
  } else {
    g.cells[row * g.size + col]
  }
}

///|
pub fn grid_set(g : Grid, row : Int, col : Int, val : Bool) -> Unit {
  if row >= 0 && row < g.size && col >= 0 && col < g.size {
    g.cells[row * g.size + col] = val
  }
}

///|
pub fn grid_in_bounds(g : Grid, row : Int, col : Int) -> Bool {
  row >= 0 && row < g.size && col >= 0 && col < g.size
}

///|
pub fn count_empty_neighbors(g : Grid, row : Int, col : Int) -> Int {
  let mut count = 0
  // up
  if row == 0 || !grid_get(g, row - 1, col) {
    count += 1
  }
  // down
  if row == g.size - 1 || !grid_get(g, row + 1, col) {
    count += 1
  }
  // left
  if col == 0 || !grid_get(g, row, col - 1) {
    count += 1
  }
  // right
  if col == g.size - 1 || !grid_get(g, row, col + 1) {
    count += 1
  }
  count
}

///|
pub fn is_top_exposed(g : Grid, row : Int, col : Int) -> Bool {
  grid_get(g, row, col) && (row == 0 || !grid_get(g, row - 1, col))
}

///|
pub fn is_left_exposed(g : Grid, row : Int, col : Int) -> Bool {
  grid_get(g, row, col) && (col == 0 || !grid_get(g, row, col - 1))
}

///|
pub fn is_right_exposed(g : Grid, row : Int, col : Int) -> Bool {
  grid_get(g, row, col) && (col == g.size - 1 || !grid_get(g, row, col + 1))
}

///|
pub fn grids_match(a : Grid, b : Grid) -> Bool {
  if a.size != b.size {
    return false
  }
  for i in 0..<(a.size * a.size) {
    if a.cells[i] != b.cells[i] {
      return false
    }
  }
  true
}

///|
pub fn clone_budget(b : ForceBudget) -> ForceBudget {
  { water: b.water, wind: b.wind, frost: b.frost, heat: b.heat }
}

///|
pub fn force_color(kind : ForceKind) -> @raylib.Color {
  match kind {
    Water => color_water
    WindLeft => color_wind
    WindRight => color_wind
    Frost => color_frost
    Heat => color_heat
  }
}

///|
pub fn force_name(kind : ForceKind) -> String {
  match kind {
    Water => "Water"
    WindLeft => "Wind <"
    WindRight => "Wind >"
    Frost => "Frost"
    Heat => "Heat"
  }
}

///|
pub fn force_budget_remaining(budget : ForceBudget, kind : ForceKind) -> Int {
  match kind {
    Water => budget.water
    WindLeft => budget.wind
    WindRight => budget.wind
    Frost => budget.frost
    Heat => budget.heat
  }
}

///|
pub fn force_budget_spend(budget : ForceBudget, kind : ForceKind) -> Unit {
  match kind {
    Water => budget.water = budget.water - 1
    WindLeft => budget.wind = budget.wind - 1
    WindRight => budget.wind = budget.wind - 1
    Frost => budget.frost = budget.frost - 1
    Heat => budget.heat = budget.heat - 1
  }
}

///|
pub fn tier_name(tier : Tier) -> String {
  match tier {
    Clay => "Clay"
    Stone => "Stone"
    Crystal => "Crystal"
  }
}

///|
pub fn tier_color(tier : Tier) -> @raylib.Color {
  match tier {
    Clay => color_tier_clay
    Stone => color_tier_stone
    Crystal => color_tier_crystal
  }
}

///|
pub fn tier_level_range(tier : Tier) -> (Int, Int) {
  match tier {
    Clay => (0, tier1_count - 1)
    Stone => (tier1_count, tier1_count + tier2_count - 1)
    Crystal => (tier1_count + tier2_count, total_levels - 1)
  }
}

///|
pub fn new_level_scores() -> Array[LevelScore] {
  let scores : Array[LevelScore] = []
  for _i in 0..<total_levels {
    scores.push({ stars: 0, completed: false, forces_used: 0 })
  }
  scores
}

///|
pub fn new_preview_cells() -> Array[Bool] {
  Array::make(grid_size * grid_size, false)
}

///|
pub fn new_game() -> Game {
  let empty = new_grid(grid_size, false)
  {
    screen: Title,
    grid: clone_grid(empty),
    target: clone_grid(empty),
    budget: { water: 0, wind: 0, frost: 0, heat: 0 },
    history: [],
    current_level: 0,
    current_tier: Clay,
    play_state: Selecting,
    forces_used: 0,
    par_forces: 0,
    level_scores: new_level_scores(),
    preview_cells: new_preview_cells(),
    anim_timer: 0.0,
    selected_force: Water,
    frame_count: 0,
  }
}
