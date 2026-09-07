///|
pub fn pos_to_index(p : Pos, cols : Int) -> Int {
  p.y * cols + p.x
}

///|
pub fn index_to_pos(i : Int, cols : Int) -> Pos {
  { x: i % cols, y: i / cols, }
}

///|
pub fn in_bounds(p : Pos, cols : Int, rows : Int) -> Bool {
  p.x >= 0 && p.x < cols && p.y >= 0 && p.y < rows
}

///|
pub fn neighbor(p : Pos, d : Direction) -> Pos {
  { x: p.x + d.dx(), y: p.y + d.dy(), }
}

///|
pub fn get_tile(game : Game, p : Pos) -> Tile? {
  let level = game.levels[game.current_level]
  if in_bounds(p, level.grid_cols, level.grid_rows) {
    Some(game.grid[pos_to_index(p, level.grid_cols)])
  } else {
    None
  }
}

///|
pub fn new_tile(elevation : Int) -> Tile {
  { kind: Empty, elevation, has_water: false, water_level: 0, connections: [], }
}

///|
pub fn new_level_score() -> LevelScore {
  { completed: false, stars: 0, segments_used: 0, }
}

///|
pub fn new_game(levels : Array[Level]) -> Game {
  let scores : Array[LevelScore] = Array::make(levels.length(), {
    completed: false,
    stars: 0,
    segments_used: 0,
  })
  {
    screen: Title,
    play_state: Placing,
    current_tier: Tier1,
    current_level: 0,
    hover_cell: None,
    selected_tool: Aqueduct,
    levels,
    scores,
    grid: [],
    segments_placed: 0,
    undo_stack: [],
    frame_count: 0,
    message: "",
    message_timer: 0.0,
    sim_timer: 0.0,
    sim_step: 0,
    fountains_filled: 0,
    total_fountains: 0,
    anim_timer: 0.0,
    water_sources: [],
  }
}

///|
pub fn init_grid(game : Game) -> Unit {
  let level = game.levels[game.current_level]
  let total = level.grid_cols * level.grid_rows
  let grid : Array[Tile] = []
  for i in 0..<total {
    grid.push(new_tile(level.elevations[i]))
  }
  for s in level.springs {
    let idx = pos_to_index(s, level.grid_cols)
    grid[idx].kind = Spring
    grid[idx].has_water = true
    grid[idx].water_level = 4
    grid[idx].connections = all_directions.copy()
  }
  for f in level.fountains {
    let idx = pos_to_index(f, level.grid_cols)
    grid[idx].kind = Fountain
    grid[idx].connections = all_directions.copy()
  }
  for r in level.reservoirs {
    let idx = pos_to_index(r, level.grid_cols)
    grid[idx].kind = Reservoir
    grid[idx].connections = all_directions.copy()
  }
  for entry in level.dams {
    let pos = entry.0
    let dir = entry.1
    let idx = pos_to_index(pos, level.grid_cols)
    grid[idx].kind = Dam
    // Dam blocks dir, connects all others
    let conns : Array[Direction] = []
    for d in all_directions {
      if d != dir {
        conns.push(d)
      }
    }
    grid[idx].connections = conns
  }
  game.grid = grid
  game.segments_placed = 0
  game.undo_stack = []
  game.play_state = Placing
  game.sim_timer = 0.0
  game.sim_step = 0
  game.fountains_filled = 0
  game.total_fountains = level.fountains.length()
  game.water_sources = []
}

///|
pub fn can_place_at(game : Game, p : Pos) -> Bool {
  guard get_tile(game, p) is Some(tile) else { return false }
  tile.kind is Empty
}

///|
pub fn tier_levels(levels : Array[Level], t : Tier) -> Array[Int] {
  let result : Array[Int] = []
  for i, lv in levels {
    if lv.tier == t {
      result.push(i)
    }
  }
  result
}

///|
pub fn screen_to_grid(mx : Int, my : Int) -> Pos? {
  let gx = (mx - grid_offset_x) / cell_size
  let gy = (my - grid_offset_y) / cell_size
  if gx >= 0 && gx < grid_cols && gy >= 0 && gy < grid_rows {
    Some({ x: gx, y: gy, })
  } else {
    None
  }
}

///|
pub fn grid_to_screen(p : Pos) -> (Int, Int) {
  (grid_offset_x + p.x * cell_size, grid_offset_y + p.y * cell_size)
}

///|
pub fn count_segments(game : Game) -> Int {
  let mut count = 0
  for tile in game.grid {
    if tile.kind is Aqueduct {
      count += 1
    }
  }
  count
}
