///|
pub fn conductivity(mat : Material) -> Float {
  match mat {
    Empty => 0.0
    Metal => 0.9
    Stone => 0.5
    Wood => 0.2
    Insulator => 0.0
    Glass => 0.4
  }
}

///|
pub fn material_name(mat : Material) -> String {
  match mat {
    Empty => "Empty"
    Metal => "Metal"
    Stone => "Stone"
    Wood => "Wood"
    Insulator => "Insulator"
    Glass => "Glass"
  }
}

///|
pub fn material_color(mat : Material) -> @raylib.Color {
  match mat {
    Empty => color_empty
    Metal => color_metal
    Stone => color_stone
    Wood => color_wood
    Insulator => color_insulator
    Glass => color_glass
  }
}

///|
pub fn new_tile() -> Tile {
  { material: Empty, kind: Normal, temperature: ambient_temp, locked: false }
}

///|
pub fn new_grid() -> Grid {
  let tiles : Array[Array[Tile]] = []
  for _r in 0..<grid_size {
    let row : Array[Tile] = []
    for _c in 0..<grid_size {
      row.push(new_tile())
    }
    tiles.push(row)
  }
  { tiles, size: grid_size }
}

///|
pub fn reset_grid(grid : Grid) -> Unit {
  for r in 0..<grid.size {
    for c in 0..<grid.size {
      let tile = grid.tiles[r][c]
      tile.material = Empty
      tile.kind = Normal
      tile.temperature = ambient_temp
      tile.locked = false
    }
  }
}

///|
pub fn reset_temperatures(grid : Grid) -> Unit {
  for r in 0..<grid.size {
    for c in 0..<grid.size {
      grid.tiles[r][c].temperature = ambient_temp
    }
  }
}

///|
pub fn count_placed_materials(grid : Grid) -> Int {
  let mut count = 0
  for r in 0..<grid.size {
    for c in 0..<grid.size {
      let tile = grid.tiles[r][c]
      if !tile.locked && tile.material != Empty {
        count += 1
      }
    }
  }
  count
}

///|
pub fn new_level_result() -> LevelResult {
  { stars: Zero, materials_used: 0, turns_taken: 0, all_targets_met: false }
}

///|
pub fn new_level_progress() -> LevelProgress {
  { best_stars: Zero, completed: false }
}

///|
pub fn star_count(rating : StarRating) -> Int {
  match rating {
    Zero => 0
    One => 1
    Two => 2
    Three => 3
  }
}

///|
pub fn new_game() -> Game {
  let progress : Array[LevelProgress] = []
  for _i in 0..<total_levels {
    progress.push(new_level_progress())
  }
  {
    screen: Title,
    grid: new_grid(),
    current_level: 0,
    tool_mode: Place(Metal),
    sim_turn: 0,
    sim_timer: 0.0,
    sim_running: false,
    level_progress: progress,
    result: new_level_result(),
    frame_count: 0,
    hover_row: -1,
    hover_col: -1,
    message: "",
    message_timer: 0.0,
    total_stars: 0,
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
pub fn absf(v : Float) -> Float {
  if v < 0.0 {
    -v
  } else {
    v
  }
}

///|
pub fn sinf(a : Float) -> Float {
  Float::from_double(@math.sin(a.to_double()))
}

///|
pub fn is_level_unlocked(game : Game, level : Int) -> Bool {
  if level == 0 {
    true
  } else {
    game.level_progress[level - 1].completed
  }
}

///|
pub fn set_message(game : Game, msg : String, duration : Float) -> Unit {
  game.message = msg
  game.message_timer = duration
}

///|
pub fn check_all_targets(grid : Grid) -> Bool {
  let mut all_met = true
  for r in 0..<grid.size {
    for c in 0..<grid.size {
      match grid.tiles[r][c].kind {
        Target(lo, hi) => {
          let temp = grid.tiles[r][c].temperature
          if temp < lo || temp > hi {
            all_met = false
          }
        }
        _ => ()
      }
    }
  }
  all_met
}

///|
pub fn calculate_stars(
  all_met : Bool,
  materials_used : Int,
  turns : Int,
  par_materials : Int,
  par_turns : Int,
) -> StarRating {
  if !all_met {
    Zero
  } else if materials_used <= par_materials && turns <= par_turns {
    Three
  } else if materials_used <= par_materials {
    Two
  } else {
    One
  }
}

///|
pub fn recalculate_total_stars(game : Game) -> Unit {
  let mut total = 0
  for i in 0..<total_levels {
    total += star_count(game.level_progress[i].best_stars)
  }
  game.total_stars = total
}
