///|
pub fn new_resources(
  o2 : Float,
  co2 : Float,
  water : Float,
  nutrients : Float,
) -> Resources {
  { o2, co2, water, nutrients }
}

///|
pub fn clone_resources(r : Resources) -> Resources {
  { o2: r.o2, co2: r.co2, water: r.water, nutrients: r.nutrients }
}

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
pub fn clamp_resources(r : Resources) -> Unit {
  r.o2 = clamp_float(r.o2, 0.0, max_resource)
  r.co2 = clamp_float(r.co2, 0.0, max_resource)
  r.water = clamp_float(r.water, 0.0, max_resource)
  r.nutrients = clamp_float(r.nutrients, 0.0, max_resource)
}

///|
pub fn new_game() -> Game {
  let grid : Array[Array[CellContent]] = []
  for _r in 0..<grid_size {
    let row : Array[CellContent] = []
    for _c in 0..<grid_size {
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
    resources: new_resources(50.0, 50.0, 50.0, 50.0),
    organisms: [],
    current_turn: 0,
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
  { completed: false, best_turns_survived: 0, stars: 0 }
}

///|
pub fn clear_grid(game : Game) -> Unit {
  for r in 0..<grid_size {
    for c in 0..<grid_size {
      game.grid[r][c] = Empty
    }
  }
  game.organisms = []
  for i in 0..<num_organisms {
    game.organisms_placed[i] = 0
  }
}

///|
pub fn is_cell_locked(level : LevelDef, row : Int, col : Int) -> Bool {
  for i in 0..<level.locked_cells.length() {
    let (lr, lc) = level.locked_cells[i]
    if lr == row && lc == col {
      return true
    }
  }
  false
}

///|
pub fn in_grid(row : Int, col : Int) -> Bool {
  row >= 0 && row < grid_size && col >= 0 && col < grid_size
}

///|
pub fn count_organism_on_grid(game : Game, kind : OrganismKind) -> Int {
  let mut count = 0
  for r in 0..<grid_size {
    for c in 0..<grid_size {
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
    Beginner => "Beginner"
    Intermediate => "Intermediate"
    Advanced => "Advanced"
  }
}

///|
pub fn tier_color(tier : Tier) -> @raylib.Color {
  match tier {
    Beginner => color_tier1
    Intermediate => color_tier2
    Advanced => color_tier3
  }
}

///|
pub fn compute_stars(turns_survived : Int, par : Int) -> Int {
  if turns_survived < max_turns {
    0
  } else if turns_survived >= max_turns && par > 0 {
    let placed_count = par
    if placed_count <= 3 {
      3
    } else if placed_count <= 5 {
      2
    } else {
      1
    }
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
    return level_id == 0 || scores[level_id - 1].completed
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

///|
pub fn abs_float(x : Float) -> Float {
  if x < 0.0 {
    0.0 - x
  } else {
    x
  }
}
