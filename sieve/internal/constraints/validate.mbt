///|
pub fn validate_constraint(
  grid : @types.Grid,
  c : @types.Constraint
) -> Bool {
  match c.kind {
    RowSum => validate_row_sum(grid, c.params)
    ColProduct => validate_col_product(grid, c.params)
    Adjacent => validate_adjacent(grid, c.params)
    NoPrimePair => validate_no_prime_pair(grid, c.params)
    Divisible => validate_divisible(grid, c.params)
    Unique => validate_unique(grid, c.params)
  }
}

///|
pub fn validate_all(
  grid : @types.Grid,
  constraints : Array[@types.Constraint]
) -> Bool {
  let mut all_sat = true
  for i in 0..<constraints.length() {
    let sat = validate_constraint(grid, constraints[i])
    constraints[i].satisfied = sat
    if !sat {
      all_sat = false
    }
  }
  all_sat
}

///|
fn validate_row_sum(grid : @types.Grid, params : Array[Int]) -> Bool {
  // params: [row, target_sum]
  let row = params[0]
  let target = params[1]
  let mut sum = 0
  let mut has_empty = false
  for col in 0..<grid.size {
    let v = @types.grid_get(grid, row, col)
    if v == 0 {
      has_empty = true
    }
    sum += v
  }
  if has_empty {
    return false
  }
  sum == target
}

///|
fn validate_col_product(grid : @types.Grid, params : Array[Int]) -> Bool {
  // params: [col, target_product]
  let col = params[0]
  let target = params[1]
  let mut product = 1
  let mut has_empty = false
  for row in 0..<grid.size {
    let v = @types.grid_get(grid, row, col)
    if v == 0 {
      has_empty = true
    } else {
      product *= v
    }
  }
  if has_empty {
    return false
  }
  product == target
}

///|
fn validate_adjacent(grid : @types.Grid, params : Array[Int]) -> Bool {
  // params: [row1, col1, row2, col2]
  let v1 = @types.grid_get(grid, params[0], params[1])
  let v2 = @types.grid_get(grid, params[2], params[3])
  if v1 == 0 || v2 == 0 {
    return false
  }
  @types.absi(v1 - v2) == 1
}

///|
fn validate_no_prime_pair(grid : @types.Grid, params : Array[Int]) -> Bool {
  // params: [row] - check entire row for adjacent primes
  let row = params[0]
  let mut has_empty = false
  for col in 0..<grid.size {
    if @types.grid_get(grid, row, col) == 0 {
      has_empty = true
    }
  }
  if has_empty {
    return false
  }
  let last_col = grid.size - 1
  for col in 0..<last_col {
    let v1 = @types.grid_get(grid, row, col)
    let v2 = @types.grid_get(grid, row, col + 1)
    if @types.is_prime(v1) && @types.is_prime(v2) {
      return false
    }
  }
  // Also check vertically within that row
  if row > 0 {
    for col in 0..<grid.size {
      let v1 = @types.grid_get(grid, row, col)
      let v2 = @types.grid_get(grid, row - 1, col)
      if v2 != 0 && @types.is_prime(v1) && @types.is_prime(v2) {
        return false
      }
    }
  }
  if row < grid.size - 1 {
    for col in 0..<grid.size {
      let v1 = @types.grid_get(grid, row, col)
      let v2 = @types.grid_get(grid, row + 1, col)
      if v2 != 0 && @types.is_prime(v1) && @types.is_prime(v2) {
        return false
      }
    }
  }
  true
}

///|
fn validate_divisible(grid : @types.Grid, params : Array[Int]) -> Bool {
  // params: [row_a, col_a, row_b, col_b] - cell A divisible by cell B
  let va = @types.grid_get(grid, params[0], params[1])
  let vb = @types.grid_get(grid, params[2], params[3])
  if va == 0 || vb == 0 {
    return false
  }
  @types.divisible_by(va, vb)
}

///|
fn validate_unique(grid : @types.Grid, params : Array[Int]) -> Bool {
  // params: [0, index] for row, [1, index] for col
  let is_row = params[0] == 0
  let index = params[1]
  let mut has_empty = false
  let seen : Array[Bool] = Array::make(10, false)
  for i in 0..<grid.size {
    let v = if is_row {
      @types.grid_get(grid, index, i)
    } else {
      @types.grid_get(grid, i, index)
    }
    if v == 0 {
      has_empty = true
    } else if seen[v] {
      return false
    } else {
      seen[v] = true
    }
  }
  if has_empty {
    return false
  }
  true
}

///|
pub fn check_cell_conflicts(
  grid : @types.Grid,
  row : Int,
  col : Int,
  constraints : Array[@types.Constraint]
) -> Bool {
  // Check if placing a value at (row,col) causes any currently-checkable conflict
  let val = @types.grid_get(grid, row, col)
  if val == 0 {
    return false
  }
  for i in 0..<constraints.length() {
    let c = constraints[i]
    match c.kind {
      Unique => {
        let is_row = c.params[0] == 0
        let index = c.params[1]
        if (is_row && index == row) || (!is_row && index == col) {
          // Check for duplicates with current value
          for j in 0..<grid.size {
            let other = if is_row {
              @types.grid_get(grid, index, j)
            } else {
              @types.grid_get(grid, j, index)
            }
            let other_pos = if is_row { j } else { j }
            let my_pos = if is_row { col } else { row }
            if other == val && other_pos != my_pos && other != 0 {
              return true
            }
          }
        }
      }
      _ => ()
    }
  }
  false
}
