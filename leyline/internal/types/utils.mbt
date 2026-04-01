///|
pub fn new_cell(kind : CellKind) -> Cell {
  { kind, energy_received: 0.0, glow_anim: 0.0 }
}

///|
pub fn new_connection(
  from_col : Int,
  from_row : Int,
  to_col : Int,
  to_row : Int
) -> Connection {
  { from_col, from_row, to_col, to_row, energy_flow: 0.0, flow_anim: 0.0 }
}

///|
pub fn new_game() -> Game {
  let progress : Array[LevelProgress] = []
  for _i in 0..<total_levels {
    progress.push(
      { completed: false, stars: None, best_waystones: 0, best_energy: 0.0 },
    )
  }
  {
    screen: Title,
    current_level: 0,
    level_def: None,
    level_state: None,
    progress,
    anim_timer: 0.0,
    message: "",
    message_timer: 0.0,
    scroll_offset: 0,
    frame_count: 0,
    tool: PlaceWaystone,
    energy_phase: 0.0,
  }
}

///|
pub fn make_grid(def : LevelDef) -> Array[Array[Cell]] {
  let grid : Array[Array[Cell]] = []
  for row in 0..<grid_rows {
    let row_arr : Array[Cell] = []
    for col in 0..<grid_cols {
      let kind = if row < def.grid.length() && col < def.grid[row].length() {
        def.grid[row][col]
      } else {
        Empty
      }
      row_arr.push(new_cell(kind))
    }
    grid.push(row_arr)
  }
  grid
}

///|
pub fn init_level_state(def : LevelDef) -> LevelState {
  {
    grid: make_grid(def),
    connections: [],
    waystones_placed: 0,
    waystone_budget: def.waystone_budget,
    all_temples_powered: false,
    total_energy_delivered: 0.0,
    cursor_col: -1,
    cursor_row: -1,
    hover_valid: false,
    draw_start_col: -1,
    draw_start_row: -1,
    is_drawing_line: false,
  }
}

///|
pub fn cell_screen_x(col : Int) -> Int {
  grid_offset_x + col * cell_size
}

///|
pub fn cell_screen_y(row : Int) -> Int {
  grid_offset_y + row * cell_size
}

///|
pub fn cell_center_x(col : Int) -> Float {
  Float::from_int(grid_offset_x + col * cell_size + cell_size / 2)
}

///|
pub fn cell_center_y(row : Int) -> Float {
  Float::from_int(grid_offset_y + row * cell_size + cell_size / 2)
}

///|
pub fn is_adjacent(c1 : Int, r1 : Int, c2 : Int, r2 : Int) -> Bool {
  let dc = if c1 > c2 { c1 - c2 } else { c2 - c1 }
  let dr = if r1 > r2 { r1 - r2 } else { r2 - r1 }
  (dc == 1 && dr == 0) || (dc == 0 && dr == 1)
}

///|
pub fn is_connectable(kind : CellKind) -> Bool {
  match kind {
    Source | Temple(_) | Waystone | Amplifier => true
    Empty | Void => false
  }
}

///|
pub fn in_grid(col : Int, row : Int) -> Bool {
  col >= 0 && col < grid_cols && row >= 0 && row < grid_rows
}

///|
pub fn connection_exists(
  connections : Array[Connection],
  c1 : Int,
  r1 : Int,
  c2 : Int,
  r2 : Int
) -> Bool {
  for i in 0..<connections.length() {
    let conn = connections[i]
    if (conn.from_col == c1 &&
      conn.from_row == r1 &&
      conn.to_col == c2 &&
      conn.to_row == r2) ||
      (conn.from_col == c2 &&
      conn.from_row == r2 &&
      conn.to_col == c1 &&
      conn.to_row == r1) {
      return true
    }
  }
  false
}

///|
pub fn tier_for_level(level_id : Int) -> Int {
  if level_id < tier1_count {
    1
  } else if level_id < tier1_count + tier2_count {
    2
  } else {
    3
  }
}

///|
pub fn level_unlocked(progress : Array[LevelProgress], level_id : Int) -> Bool {
  if level_id == 0 {
    return true
  }
  if level_id > 0 && level_id < progress.length() {
    progress[level_id - 1].completed
  } else {
    false
  }
}

///|
pub fn neighbor_connections(
  connections : Array[Connection],
  col : Int,
  row : Int
) -> Array[(Int, Int)] {
  let neighbors : Array[(Int, Int)] = []
  for i in 0..<connections.length() {
    let c = connections[i]
    if c.from_col == col && c.from_row == row {
      neighbors.push((c.to_col, c.to_row))
    } else if c.to_col == col && c.to_row == row {
      neighbors.push((c.from_col, c.from_row))
    }
  }
  neighbors
}

///|
pub fn temple_required(kind : CellKind) -> Float {
  match kind {
    Temple(req) => req
    _ => 0.0
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
