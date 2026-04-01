///|
/// Resolve one ecosystem step. Takes a snapshot of the grid, then applies
/// all biome rules simultaneously based on the snapshot, writing results
/// to the actual grid. Returns an array of bools indicating which tiles changed.
pub fn resolve_ecosystem(grid : @types.HexGrid) -> Array[Bool] {
  let w = grid.width
  let h = grid.height
  let total = w * h
  // Take snapshot of current state
  let snapshot = @types.snapshot_biomes(grid)
  let changed : Array[Bool] = Array::make(total, false)
  for row in 0..<h {
    for col in 0..<w {
      let idx = @types.grid_index(col, row, w)
      let tile = grid.tiles[idx]
      if tile.locked {
        continue
      }
      let current = snapshot[idx]
      let neighbors = @types.hex_neighbors(
        col, row, w, h, grid.wraps_horizontal,
      )
      // Count neighbors by biome from snapshot
      let mut ocean_n = 0
      let mut desert_n = 0
      let mut forest_n = 0
      let mut barren_n = 0
      for i in 0..<neighbors.length() {
        let (nc, nr) = neighbors[i]
        let ni = @types.grid_index(nc, nr, w)
        match snapshot[ni] {
          Ocean => ocean_n += 1
          Desert => desert_n += 1
          Forest => forest_n += 1
          Barren => barren_n += 1
        }
      }
      let new_biome = apply_rules(
        current, ocean_n, desert_n, forest_n, barren_n,
      )
      if new_biome != current {
        tile.biome = new_biome
        changed[idx] = true
      }
    }
  }
  changed
}

///|
fn apply_rules(
  current : @types.BiomeKind,
  ocean_n : Int,
  desert_n : Int,
  forest_n : Int,
  barren_n : Int
) -> @types.BiomeKind {
  ignore(barren_n)
  match current {
    Barren => {
      // Desert spreads to barren with 0 ocean neighbors
      // Forest spreads to barren with at least 1 ocean neighbor AND at least 1 forest neighbor
      if forest_n >= 1 && ocean_n >= 1 {
        Forest
      } else if desert_n >= 1 && ocean_n == 0 {
        Desert
      } else {
        Barren
      }
    }
    Forest => {
      // Dies if surrounded by 3+ desert
      if desert_n >= 3 {
        Barren
      } else {
        Forest
      }
    }
    Ocean => {
      // Stable, never changes
      Ocean
    }
    Desert => {
      // Retreats if 2+ ocean neighbors
      if ocean_n >= 2 {
        Barren
      } else {
        Desert
      }
    }
  }
}

///|
/// Run multiple resolution steps, returning the changed tiles from the last step.
pub fn resolve_n_steps(grid : @types.HexGrid, steps : Int) -> Array[Bool] {
  let mut last_changed : Array[Bool] = Array::make(
    grid.width * grid.height, false,
  )
  for _s in 0..<steps {
    last_changed = resolve_ecosystem(grid)
  }
  last_changed
}

///|
/// Check if the ecosystem has reached a stable state (no more changes possible).
pub fn is_stable(grid : @types.HexGrid) -> Bool {
  let test_grid = @types.clone_grid(grid)
  let changed = resolve_ecosystem(test_grid)
  for i in 0..<changed.length() {
    if changed[i] {
      return false
    }
  }
  true
}

///|
/// Count how many tiles would change in the next ecosystem step.
pub fn count_pending_changes(grid : @types.HexGrid) -> Int {
  let test_grid = @types.clone_grid(grid)
  let changed = resolve_ecosystem(test_grid)
  let mut count = 0
  for i in 0..<changed.length() {
    if changed[i] {
      count += 1
    }
  }
  count
}

///|
/// Predict the final state of the grid by resolving until stable.
/// Returns the number of steps taken and the final changed tiles.
pub fn resolve_until_stable(
  grid : @types.HexGrid,
  max_steps : Int
) -> (Int, Array[Bool]) {
  let mut steps = 0
  let mut last_changed : Array[Bool] = Array::make(
    grid.width * grid.height, false,
  )
  for _s in 0..<max_steps {
    let changed = resolve_ecosystem(grid)
    let mut any = false
    for i in 0..<changed.length() {
      if changed[i] {
        any = true
        last_changed = changed
        break
      }
    }
    if !any {
      break
    }
    steps += 1
  }
  (steps, last_changed)
}

///|
/// Get per-tile predictions for the next ecosystem step.
/// Returns an array of (grid_index, new_biome) for tiles that will change.
pub fn preview_tile_changes(grid : @types.HexGrid) -> Array[(Int, @types.BiomeKind)] {
  let w = grid.width
  let h = grid.height
  let snapshot = @types.snapshot_biomes(grid)
  let result : Array[(Int, @types.BiomeKind)] = []
  for row in 0..<h {
    for col in 0..<w {
      let idx = @types.grid_index(col, row, w)
      if grid.tiles[idx].locked {
        continue
      }
      let current = snapshot[idx]
      let neighbors = @types.hex_neighbors(
        col, row, w, h, grid.wraps_horizontal,
      )
      let mut ocean_n = 0
      let mut desert_n = 0
      let mut forest_n = 0
      let mut barren_n = 0
      for i in 0..<neighbors.length() {
        let (nc, nr) = neighbors[i]
        let ni = @types.grid_index(nc, nr, w)
        match snapshot[ni] {
          Ocean => ocean_n += 1
          Desert => desert_n += 1
          Forest => forest_n += 1
          Barren => barren_n += 1
        }
      }
      let new_biome = apply_rules(current, ocean_n, desert_n, forest_n, barren_n)
      if new_biome != current {
        result.push((idx, new_biome))
      }
    }
  }
  result
}

///|
/// Get a summary of what would happen in the next step.
/// Returns (tiles_gaining_forest, tiles_losing_forest, tiles_gaining_desert,
///          tiles_losing_desert).
pub fn preview_next_step(grid : @types.HexGrid) -> (Int, Int, Int, Int) {
  let w = grid.width
  let h = grid.height
  let snapshot = @types.snapshot_biomes(grid)
  let mut gain_forest = 0
  let mut lose_forest = 0
  let mut gain_desert = 0
  let mut lose_desert = 0
  for row in 0..<h {
    for col in 0..<w {
      let idx = @types.grid_index(col, row, w)
      if grid.tiles[idx].locked {
        continue
      }
      let current = snapshot[idx]
      let neighbors = @types.hex_neighbors(
        col, row, w, h, grid.wraps_horizontal,
      )
      let mut ocean_n = 0
      let mut desert_n = 0
      let mut forest_n = 0
      let mut barren_n = 0
      for i in 0..<neighbors.length() {
        let (nc, nr) = neighbors[i]
        let ni = @types.grid_index(nc, nr, w)
        match snapshot[ni] {
          Ocean => ocean_n += 1
          Desert => desert_n += 1
          Forest => forest_n += 1
          Barren => barren_n += 1
        }
      }
      let new_biome = apply_rules(current, ocean_n, desert_n, forest_n, barren_n)
      if new_biome != current {
        match new_biome {
          Forest => gain_forest += 1
          Desert => gain_desert += 1
          _ => ()
        }
        match current {
          Forest => lose_forest += 1
          Desert => lose_desert += 1
          _ => ()
        }
      }
    }
  }
  (gain_forest, lose_forest, gain_desert, lose_desert)
}
