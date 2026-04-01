///|
pub fn clamp_float(v : Float, lo : Float, hi : Float) -> Float {
  if v < lo {
    lo
  } else if v > hi {
    hi
  } else {
    v
  }
}

///|
pub fn abs_float(x : Float) -> Float {
  if x < 0.0 {
    0.0 - x
  } else {
    x
  }
}

///|
pub fn new_game() -> Game {
  let grid : Array[Array[CellContent]] = []
  for _r in 0..<grid_rows {
    let row : Array[CellContent] = []
    for _c in 0..<grid_cols {
      row.push(Empty)
    }
    grid.push(row)
  }
  let scores : Array[LevelScore] = []
  for _i in 0..<total_levels {
    scores.push(new_level_score())
  }
  let organisms_placed : Array[Int] = []
  for _i in 0..<num_organisms {
    organisms_placed.push(0)
  }
  {
    screen: Title,
    selected_level: 0,
    grid,
    organisms: [],
    current_turn: 0,
    current_cycle: 0,
    tide_level: 1,
    tide_phase: Low,
    play_result: None,
    selected_organism: None,
    hover_row: -1,
    hover_col: -1,
    frame_count: 0,
    message: "",
    message_timer: 0.0,
    scores,
    current_level: None,
    sim_log: [],
    sim_speed_timer: 0.0,
    organisms_placed,
    anim_timer: 0.0,
  }
}

///|
pub fn new_level_score() -> LevelScore {
  { completed: false, best_cycles_survived: 0, stars: 0 }
}

///|
pub fn clear_grid(game : Game) -> Unit {
  for r in 0..<grid_rows {
    for c in 0..<grid_cols {
      game.grid[r][c] = Empty
    }
  }
  game.organisms = []
  for i in 0..<num_organisms {
    game.organisms_placed[i] = 0
  }
}

///|
pub fn in_grid(row : Int, col : Int) -> Bool {
  row >= 0 && row < grid_rows && col >= 0 && col < grid_cols
}

///|
pub fn is_cell_rock(level : LevelDef, row : Int, col : Int) -> Bool {
  for i in 0..<level.rock_cells.length() {
    let (rr, rc) = level.rock_cells[i]
    if rr == row && rc == col {
      return true
    }
  }
  false
}

///|
pub fn get_depth_at_col(game : Game, col : Int) -> Int {
  match game.current_level {
    Some(level) =>
      if col >= 0 && col < level.depth_profile.length() {
        level.depth_profile[col]
      } else {
        0
      }
    None => 0
  }
}

///|
pub fn is_submerged(tide_level : Int, depth : Int, row : Int) -> Bool {
  let water_row = grid_rows - tide_level - depth
  row >= water_row
}

///|
pub fn get_tide_for_turn(turn : Int) -> (Int, TidePhase) {
  let phase_in_cycle = turn % cycle_length
  match phase_in_cycle {
    0 => (1, Low)
    1 => (2, Mid)
    2 => (4, High)
    _ => (2, Mid)
  }
}

///|
pub fn count_organism_on_grid(game : Game, kind : OrganismKind) -> Int {
  let mut count = 0
  for r in 0..<grid_rows {
    for c in 0..<grid_cols {
      match game.grid[r][c] {
        Organism(k) => if k == kind { count += 1 }
        _ => ()
      }
    }
  }
  count
}

///|
pub fn get_available_count(game : Game, kind : OrganismKind) -> Int {
  match game.current_level {
    None => 0
    Some(level) => {
      let idx = organism_index(kind)
      let mut avail = 0
      for i in 0..<level.available_organisms.length() {
        if level.available_organisms[i] == kind {
          avail = level.organism_counts[i]
          break
        }
      }
      let placed = game.organisms_placed[idx]
      if avail > placed {
        avail - placed
      } else {
        0
      }
    }
  }
}

///|
pub fn tier_name(tier : Tier) -> String {
  match tier {
    Shallow => "Shallow"
    Middle => "Middle"
    Deep => "Deep"
  }
}

///|
pub fn tier_color(tier : Tier) -> @raylib.Color {
  match tier {
    Shallow => color_tier1
    Middle => color_tier2
    Deep => color_tier3
  }
}

///|
pub fn compute_stars(cycles_survived : Int, total_organisms : Int) -> Int {
  if cycles_survived < total_cycles {
    0
  } else if total_organisms <= 3 {
    3
  } else if total_organisms <= 5 {
    2
  } else {
    1
  }
}

///|
pub fn total_stars(scores : Array[LevelScore]) -> Int {
  let mut total = 0
  for i in 0..<scores.length() {
    total += scores[i].stars
  }
  total
}

///|
pub fn levels_completed(scores : Array[LevelScore]) -> Int {
  let mut count = 0
  for i in 0..<scores.length() {
    if scores[i].completed {
      count += 1
    }
  }
  count
}

///|
pub fn is_level_unlocked(scores : Array[LevelScore], level_id : Int) -> Bool {
  if level_id == 0 {
    return true
  }
  if level_id < 7 {
    return scores[level_id - 1].completed
  }
  if level_id < 14 {
    if level_id == 7 {
      return levels_completed(scores) >= 4
    }
    return scores[level_id - 1].completed
  }
  if level_id == 14 {
    return levels_completed(scores) >= 10
  }
  scores[level_id - 1].completed
}
