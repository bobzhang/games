///|
/// Convert a single glaze color to its basic fired result.
pub fn glaze_to_fired(g : @types.GlazeColor) -> @types.FiredColor {
  match g {
    Red => FRed
    Blue => FBlue
    Green => FGreen
    Gold => FGold
    White => FWhite
    Black => FBlack
    Empty => FEmpty
  }
}

///|
/// Deepen a fired color (when adjacent same-color glazes merge).
pub fn deepen(f : @types.FiredColor) -> @types.FiredColor {
  match f {
    FRed => FDeepRed
    FBlue => FDeepBlue
    FGreen => FDeepGreen
    FGold => FDeepGold
    FWhite => FDeepWhite
    FBlack => FDeepBlack
    _ => f
  }
}

///|
/// Check if two glaze colors are blend-compatible (Red+Blue->Purple).
fn is_blend_pair(
  a : @types.GlazeColor,
  b : @types.GlazeColor
) -> @types.FiredColor? {
  match (a, b) {
    (Red, Blue) | (Blue, Red) => Some(FPurple)
    _ => None
  }
}

///|
/// Get the 4-connected neighbors of a cell.
fn neighbors(row : Int, col : Int) -> Array[(Int, Int)] {
  let result : Array[(Int, Int)] = []
  if row > 0 {
    result.push((row - 1, col))
  }
  if row < @types.grid_rows - 1 {
    result.push((row + 1, col))
  }
  if col > 0 {
    result.push((row, col - 1))
  }
  if col < @types.grid_cols - 1 {
    result.push((row, col + 1))
  }
  result
}

///|
/// Count how many neighbors have the same glaze color.
fn count_same_neighbors(
  grid : @types.Grid,
  row : Int,
  col : Int
) -> Int {
  let g = @types.get_cell(grid, row, col).glaze
  if g is Empty {
    return 0
  }
  let nbrs = neighbors(row, col)
  let mut count = 0
  for i in 0..<nbrs.length() {
    let (r, c) = nbrs[i]
    if @types.get_cell(grid, r, c).glaze == g {
      count = count + 1
    }
  }
  count
}

///|
/// Check if any neighbor is incompatible (causes cracking).
fn has_incompatible_neighbor(
  grid : @types.Grid,
  row : Int,
  col : Int
) -> Bool {
  let g = @types.get_cell(grid, row, col).glaze
  if g is Empty {
    return false
  }
  let nbrs = neighbors(row, col)
  for i in 0..<nbrs.length() {
    let (r, c) = nbrs[i]
    let ng = @types.get_cell(grid, r, c).glaze
    if ng is Empty {
      continue
    }
    if @types.is_incompatible(g, ng) {
      return true
    }
  }
  false
}

///|
/// Check if any neighbor forms a blend pair.
fn find_blend_neighbor(
  grid : @types.Grid,
  row : Int,
  col : Int
) -> @types.FiredColor? {
  let g = @types.get_cell(grid, row, col).glaze
  if g is Empty {
    return None
  }
  let nbrs = neighbors(row, col)
  for i in 0..<nbrs.length() {
    let (r, c) = nbrs[i]
    let ng = @types.get_cell(grid, r, c).glaze
    if ng is Empty {
      continue
    }
    let result = is_blend_pair(g, ng)
    if result is Some(_) {
      return result
    }
  }
  None
}

///|
/// Fire the entire grid: apply glaze interaction rules and set fired colors.
/// Rules applied in priority order:
/// 1. Incompatible adjacent glazes -> FCracked
/// 2. Adjacent same color merge -> deepened shade
/// 3. Red+Blue adjacent -> both become Purple
/// 4. Otherwise -> basic fired color
pub fn fire_grid(grid : @types.Grid) -> Unit {
  for row in 0..<@types.grid_rows {
    for col in 0..<@types.grid_cols {
      let cell = @types.get_cell(grid, row, col)
      if cell.glaze is Empty {
        cell.fired = FEmpty
        continue
      }
      // Priority 1: incompatible neighbors cause cracking
      if has_incompatible_neighbor(grid, row, col) {
        cell.fired = FCracked
        continue
      }
      // Priority 2: same-color adjacent merge
      let same_count = count_same_neighbors(grid, row, col)
      if same_count > 0 {
        let base = glaze_to_fired(cell.glaze)
        cell.fired = deepen(base)
        continue
      }
      // Priority 3: blend pairs
      let blend = find_blend_neighbor(grid, row, col)
      if blend is Some(f) {
        cell.fired = f
        continue
      }
      // Default: simple firing
      cell.fired = glaze_to_fired(cell.glaze)
    }
  }
}

///|
/// Count how many cells match the target pattern.
pub fn count_matches(
  grid : @types.Grid,
  target : Array[@types.FiredColor]
) -> Int {
  let mut count = 0
  for i in 0..<@types.mini(grid.cells.length(), target.length()) {
    if grid.cells[i].fired == target[i] {
      count = count + 1
    }
  }
  count
}

///|
/// Count cracked cells after firing.
pub fn count_cracked(grid : @types.Grid) -> Int {
  let mut count = 0
  for i in 0..<grid.cells.length() {
    if grid.cells[i].fired is FCracked {
      count = count + 1
    }
  }
  count
}

///|
/// Calculate score for a fired grid vs target.
pub fn calculate_score(
  grid : @types.Grid,
  target : Array[@types.FiredColor],
  moves_used : Int,
  par_moves : Int
) -> @types.LevelScore {
  let total = @types.grid_cols * @types.grid_rows
  let matched = count_matches(grid, target)
  let cracked = count_cracked(grid)
  // Stars: 3 if perfect match under par, 2 if all match, 1 if >80%
  let stars = if matched == total && cracked == 0 && moves_used <= par_moves {
    3
  } else if matched == total && cracked == 0 {
    2
  } else if matched * 100 / total >= 80 {
    1
  } else {
    0
  }
  {
    stars,
    matched_cells: matched,
    cracked_cells: cracked,
    total_cells: total,
    moves_used,
  }
}
