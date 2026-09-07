///|
pub fn is_prime(n : Int) -> Bool {
  if n < 2 {
    return false
  }
  if n == 2 || n == 3 || n == 5 || n == 7 {
    return true
  }
  if n % 2 == 0 || n % 3 == 0 {
    return false
  }
  true
}

///|
pub fn gcd(a : Int, b : Int) -> Int {
  let mut x = a
  let mut y = b
  if x < 0 {
    x = -x
  }
  if y < 0 {
    y = -y
  }
  while y != 0 {
    let t = y
    y = x % y
    x = t
  }
  x
}

///|
pub fn divisible_by(a : Int, b : Int) -> Bool {
  if b == 0 {
    return false
  }
  a % b == 0
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
pub fn new_cell(value : Int, locked : Bool) -> Cell {
  { value, locked, }
}

///|
pub fn new_grid() -> Grid {
  let cells : Array[Cell] = Array(capacity=grid_total_cells)
  for _i in 0..<grid_total_cells {
    cells.push(new_cell(0, false))
  }
  { size: grid_size, cells, }
}

///|
pub fn grid_get(g : Grid, row : Int, col : Int) -> Int {
  g.cells[row * g.size + col].value
}

///|
pub fn grid_set(g : Grid, row : Int, col : Int, value : Int) -> Unit {
  g.cells[row * g.size + col].value = value
}

///|
pub fn grid_is_locked(g : Grid, row : Int, col : Int) -> Bool {
  g.cells[row * g.size + col].locked
}

///|
pub fn grid_lock(g : Grid, row : Int, col : Int) -> Unit {
  g.cells[row * g.size + col].locked = true
}

///|
pub fn grid_is_full(g : Grid) -> Bool {
  for i in 0..<g.cells.length() {
    if g.cells[i].value == 0 {
      return false
    }
  }
  true
}

///|
pub fn new_constraint(kind : ConstraintKind, params : Array[Int]) -> Constraint {
  { kind, params, satisfied: false, }
}

///|
pub fn new_level_score() -> LevelScore {
  { stars: 0, best_time: 0.0, completed: false, }
}

///|
pub fn tier_color(tier : Tier) -> @raylib.Color {
  match tier {
    Primes => color_tier_primes
    Factors => color_tier_factors
    Theorem => color_tier_theorem
  }
}

///|
pub fn tier_name(tier : Tier) -> String {
  match tier {
    Primes => "Primes"
    Factors => "Factors"
    Theorem => "Theorem"
  }
}

///|
pub fn tier_level_count(tier : Tier) -> Int {
  match tier {
    Primes => tier1_count
    Factors => tier2_count
    Theorem => tier3_count
  }
}

///|
pub fn tier_start_index(tier : Tier) -> Int {
  match tier {
    Primes => 0
    Factors => tier1_count
    Theorem => tier1_count + tier2_count
  }
}

///|
pub fn constraint_kind_name(kind : ConstraintKind) -> String {
  match kind {
    RowSum => "Row Sum"
    ColProduct => "Col Product"
    Adjacent => "Adjacent"
    NoPrimePair => "No Prime Pair"
    Divisible => "Divisible"
    Unique => "Unique"
  }
}

///|
pub fn clone_grid(g : Grid) -> Grid {
  let cells : Array[Cell] = Array(capacity=g.cells.length())
  for i in 0..<g.cells.length() {
    cells.push(new_cell(g.cells[i].value, g.cells[i].locked))
  }
  { size: g.size, cells, }
}

///|
pub fn cell_candidates(
  grid : Grid,
  row : Int,
  col : Int,
  constraints : Array[Constraint],
) -> Array[Bool] {
  // Returns array of size 10 where index n is true if n is a valid candidate
  let valid : Array[Bool] = Array::make(10, true)
  valid[0] = false // 0 is never a valid number
  // Check uniqueness constraints
  for c in constraints {
    match c.kind {
      Unique => {
        let is_row = c.params[0] == 0
        let index = c.params[1]
        if (is_row && index == row) || (!is_row && index == col) {
          // Values already in this row/col are not valid candidates
          for i in 0..<grid.size {
            let v = if is_row {
              grid_get(grid, index, i)
            } else {
              grid_get(grid, i, index)
            }
            if v > 0 {
              let pos = if is_row { i } else { i }
              let my_pos = if is_row { col } else { row }
              if pos != my_pos {
                valid[v] = false
              }
            }
          }
        }
      }
      _ => ()
    }
  }
  valid
}

///|
pub fn new_game() -> Game {
  let scores : Array[LevelScore] = Array(capacity=total_levels)
  for _i in 0..<total_levels {
    scores.push(new_level_score())
  }
  {
    screen: Title,
    play_state: Editing,
    current_tier: Primes,
    current_level_index: 0,
    current_level: None,
    selected_row: -1,
    selected_col: -1,
    timer: 0.0,
    incorrect_placements: 0,
    undo_stack: [],
    scores,
    frame_count: 0,
    anim_timer: 0.0,
    message: "",
    message_timer: 0.0,
    checking_timer: 0.0,
    tier_scroll: 0,
  }
}
