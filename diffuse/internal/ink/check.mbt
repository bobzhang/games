///|
pub fn all_targets_satisfied(grid : @types.Grid) -> Bool {
  for row in 0..<grid.height {
    for col in 0..<grid.width {
      let tile = @types.grid_get(grid, col, row)
      if tile.kind == Target {
        if !@types.ink_equals(tile.ink, tile.target_color) {
          return false
        }
      }
    }
  }
  true
}

///|
pub fn count_targets_satisfied(grid : @types.Grid) -> (Int, Int) {
  // Returns (satisfied, total)
  let mut satisfied = 0
  let mut total = 0
  for row in 0..<grid.height {
    for col in 0..<grid.width {
      let tile = @types.grid_get(grid, col, row)
      if tile.kind == Target {
        total = total + 1
        if @types.ink_equals(tile.ink, tile.target_color) {
          satisfied = satisfied + 1
        }
      }
    }
  }
  (satisfied, total)
}

///|
pub fn count_waste(grid : @types.Grid) -> Int {
  // Count non-target tiles that have ink on them
  let mut waste = 0
  for row in 0..<grid.height {
    for col in 0..<grid.width {
      let tile = @types.grid_get(grid, col, row)
      if tile.kind == Paper && !@types.ink_is_empty(tile.ink) {
        waste = waste + 1
      }
    }
  }
  waste
}

///|
pub fn compute_stars(
  grid : @types.Grid,
  drops_used : Int,
  par_drops : Int
) -> @types.StarRating {
  if !all_targets_satisfied(grid) {
    return Zero
  }
  let waste = count_waste(grid)
  if drops_used <= par_drops && waste == 0 {
    Three
  } else if drops_used <= par_drops {
    Two
  } else {
    One
  }
}

///|
pub fn has_any_ink(grid : @types.Grid) -> Bool {
  for i in 0..<grid.tiles.length() {
    if !@types.ink_is_empty(grid.tiles[i].ink) {
      return true
    }
  }
  false
}

///|
pub fn any_target_wrong_color(grid : @types.Grid) -> Bool {
  // Check if any target has ink but wrong color (potential fail state)
  for row in 0..<grid.height {
    for col in 0..<grid.width {
      let tile = @types.grid_get(grid, col, row)
      if tile.kind == Target &&
        !@types.ink_is_empty(tile.ink) &&
        !@types.ink_equals(tile.ink, tile.target_color) {
        // Check if this target's ink has channels the target doesn't need
        // meaning it can never become the right color (only additive mixing)
        let has_extra_c = tile.ink.c && !tile.target_color.c
        let has_extra_m = tile.ink.m && !tile.target_color.m
        let has_extra_y = tile.ink.y && !tile.target_color.y
        if has_extra_c || has_extra_m || has_extra_y {
          return true
        }
      }
    }
  }
  false
}
