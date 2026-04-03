///|
pub fn find_enclosures(grid : @types.Grid) -> Array[@types.Enclosure] {
  let visited : Array[Array[Bool]] = []
  for _r in 0..<grid.rows {
    let row : Array[Bool] = []
    for _c in 0..<grid.cols {
      row.push(false)
    }
    visited.push(row)
  }
  let enclosures : Array[@types.Enclosure] = []
  let mut next_id = 0
  for r in 0..<grid.rows {
    for c in 0..<grid.cols {
      if visited[r][c] == false {
        let cells : Array[(Int, Int)] = []
        flood_fill(grid, c, r, visited, cells)
        if cells.length() > 0 {
          let enc : @types.Enclosure = { id: next_id, cells, species: None }
          next_id += 1
          enclosures.push(enc)
        }
      }
    }
  }
  enclosures
}

///|
fn flood_fill(
  grid : @types.Grid,
  col : Int,
  row : Int,
  visited : Array[Array[Bool]],
  cells : Array[(Int, Int)],
) -> Unit {
  if col < 0 || col >= grid.cols || row < 0 || row >= grid.rows {
    return
  }
  if visited[row][col] {
    return
  }
  visited[row][col] = true
  cells.push((col, row))
  // Check up: can go up if current cell has no fence_top
  if row > 0 && grid.cells[row][col].fence_top == false {
    flood_fill(grid, col, row - 1, visited, cells)
  }
  // Check down: can go down if cell below has no fence_top
  if row + 1 < grid.rows && grid.cells[row + 1][col].fence_top == false {
    flood_fill(grid, col, row + 1, visited, cells)
  }
  // Check left: can go left if current cell has no fence_left
  if col > 0 && grid.cells[row][col].fence_left == false {
    flood_fill(grid, col - 1, row, visited, cells)
  }
  // Check right: can go right if cell to right has no fence_left
  if col + 1 < grid.cols && grid.cells[row][col + 1].fence_left == false {
    flood_fill(grid, col + 1, row, visited, cells)
  }
}

///|
pub fn assign_animals_to_enclosures(
  grid : @types.Grid,
  enclosures : Array[@types.Enclosure],
) -> Unit {
  for enc in enclosures {
    enc.species = None
    for cell in enc.cells {
      let (c, r) = cell
      match grid.get(c, r) {
        Some({ animal: Some(sp), .. }) => {
          enc.species = Some(sp)
          break
        }
        _ => ()
      }
    }
  }
}

///|
pub fn find_enclosure_at(
  enclosures : Array[@types.Enclosure],
  col : Int,
  row : Int,
) -> @types.Enclosure? {
  for enc in enclosures {
    for cell in enc.cells {
      if cell.0 == col && cell.1 == row {
        return Some(enc)
      }
    }
  }
  None
}

///|
pub fn count_terrain_in_enclosure(
  grid : @types.Grid,
  enc : @types.Enclosure,
  terrain : @types.Terrain,
) -> Int {
  let mut count = 0
  for cell in enc.cells {
    let (c, r) = cell
    match grid.get(c, r) {
      Some({ terrain: Some(t), .. }) => if t == terrain { count += 1 }
      _ => ()
    }
  }
  count
}

///|
pub fn count_water_adjacent(grid : @types.Grid, enc : @types.Enclosure) -> Int {
  let mut count = 0
  for cell in enc.cells {
    let (c, r) = cell
    match grid.get(c, r) {
      Some({ terrain: Some(Water), .. }) => continue
      _ => ()
    }
    if has_adjacent_water(grid, c, r) {
      count += 1
    }
  }
  count
}

///|
fn has_adjacent_water(grid : @types.Grid, col : Int, row : Int) -> Bool {
  let neighbors = [
    (col - 1, row),
    (col + 1, row),
    (col, row - 1),
    (col, row + 1),
  ]
  for n in neighbors {
    match grid.get(n.0, n.1) {
      Some({ terrain: Some(Water), .. }) => return true
      _ => ()
    }
  }
  false
}

///|
pub fn count_tiles_used(grid : @types.Grid) -> Int {
  let mut count = 0
  for r in 0..<grid.rows {
    for c in 0..<grid.cols {
      match grid.cells[r][c].terrain {
        Some(_) => count += 1
        None => ()
      }
    }
  }
  count
}

///|
pub fn count_fences_used(grid : @types.Grid) -> Int {
  let mut count = 0
  for r in 0..<grid.rows {
    for c in 0..<grid.cols {
      if grid.cells[r][c].fence_top {
        count += 1
      }
      if grid.cells[r][c].fence_left {
        count += 1
      }
    }
  }
  count
}
