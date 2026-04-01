///|
/// Water erosion: removes solid cells that are top-exposed
/// (no solid cell directly above, or on the top row).
/// Returns a new grid with affected cells removed.
pub fn apply_water(grid : @types.Grid) -> @types.Grid {
  let result = @types.clone_grid(grid)
  let size = grid.size
  for r in 0..<size {
    for c in 0..<size {
      if @types.is_top_exposed(grid, r, c) {
        @types.grid_set(result, r, c, false)
      }
    }
  }
  result
}

///|
/// Wind from left: removes solid cells that are left-exposed
/// (no solid cell to the left, or on the leftmost column).
/// Returns a new grid with affected cells removed.
pub fn apply_wind_left(grid : @types.Grid) -> @types.Grid {
  let result = @types.clone_grid(grid)
  let size = grid.size
  for r in 0..<size {
    for c in 0..<size {
      if @types.is_left_exposed(grid, r, c) {
        @types.grid_set(result, r, c, false)
      }
    }
  }
  result
}

///|
/// Wind from right: removes solid cells that are right-exposed
/// (no solid cell to the right, or on the rightmost column).
/// Returns a new grid with affected cells removed.
pub fn apply_wind_right(grid : @types.Grid) -> @types.Grid {
  let result = @types.clone_grid(grid)
  let size = grid.size
  for r in 0..<size {
    for c in 0..<size {
      if @types.is_right_exposed(grid, r, c) {
        @types.grid_set(result, r, c, false)
      }
    }
  }
  result
}

///|
/// Frost: removes solid cells that have 3 or more empty orthogonal neighbors.
/// Exposed corners and edges crumble away.
/// Returns a new grid with affected cells removed.
pub fn apply_frost(grid : @types.Grid) -> @types.Grid {
  let result = @types.clone_grid(grid)
  let size = grid.size
  for r in 0..<size {
    for c in 0..<size {
      if @types.grid_get(grid, r, c) {
        let empty_count = @types.count_empty_neighbors(grid, r, c)
        if empty_count >= 3 {
          @types.grid_set(result, r, c, false)
        }
      }
    }
  }
  result
}

///|
/// Heat: removes solid cells that are adjacent to empty space on 2 or more
/// orthogonal sides. Thin walls and protrusions melt away.
/// Returns a new grid with affected cells removed.
pub fn apply_heat(grid : @types.Grid) -> @types.Grid {
  let result = @types.clone_grid(grid)
  let size = grid.size
  for r in 0..<size {
    for c in 0..<size {
      if @types.grid_get(grid, r, c) {
        let empty_count = @types.count_empty_neighbors(grid, r, c)
        if empty_count >= 2 {
          @types.grid_set(result, r, c, false)
        }
      }
    }
  }
  result
}

///|
/// Apply a force to a grid, returning the new grid.
pub fn apply_force(grid : @types.Grid, kind : @types.ForceKind) -> @types.Grid {
  match kind {
    Water => apply_water(grid)
    WindLeft => apply_wind_left(grid)
    WindRight => apply_wind_right(grid)
    Frost => apply_frost(grid)
    Heat => apply_heat(grid)
  }
}

///|
/// Get which cells would be removed by a given force.
/// Returns an array of booleans where true means that cell would be removed.
pub fn preview_force(
  grid : @types.Grid,
  kind : @types.ForceKind,
) -> Array[Bool] {
  let new_grid = apply_force(grid, kind)
  let size = grid.size
  let preview : Array[Bool] = Array::make(size * size, false)
  for i in 0..<(size * size) {
    // Cell was solid but is now empty = it would be removed
    preview[i] = grid.cells[i] && !new_grid.cells[i]
  }
  preview
}
