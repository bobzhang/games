///|
/// Check if two adjacent tiles are connected via their connection lists.
pub fn are_connected(
  game : @types.Game,
  from : @types.Pos,
  to : @types.Pos,
  dir : @types.Direction
) -> Bool {
  guard @types.get_tile(game, from) is Some(from_tile) else { return false }
  guard @types.get_tile(game, to) is Some(to_tile) else { return false }
  // Both tiles must have the connection direction
  let from_has = has_direction(from_tile.connections, dir)
  let to_has = has_direction(to_tile.connections, dir.opposite())
  from_has && to_has
}

///|
fn has_direction(connections : Array[@types.Direction], dir : @types.Direction) -> Bool {
  for d in connections {
    if d == dir {
      return true
    }
  }
  false
}

///|
/// Check if water can flow from `from` to `to` through direction `dir`.
/// Water flows from equal or higher elevation to equal or lower elevation
/// through connected aqueduct segments.
pub fn can_flow(
  game : @types.Game,
  from : @types.Pos,
  to : @types.Pos,
  dir : @types.Direction
) -> Bool {
  guard @types.get_tile(game, from) is Some(from_tile) else { return false }
  guard @types.get_tile(game, to) is Some(to_tile) else { return false }
  // Target must not be empty
  if to_tile.kind is Empty {
    return false
  }
  // Must be connected
  if !are_connected(game, from, to, dir) {
    return false
  }
  // Water flows downhill or level (from >= to elevation)
  from_tile.elevation >= to_tile.elevation
}

///|
/// Run one simulation step. Returns true if any water moved.
pub fn sim_step(game : @types.Game) -> Bool {
  let level = game.levels[game.current_level]
  let cols = level.grid_cols
  let rows = level.grid_rows
  let mut changed = false
  // Process reservoirs first: if reservoir has enough water, it releases
  for y in 0..<rows {
    for x in 0..<cols {
      let pos : @types.Pos = { x, y }
      let idx = @types.pos_to_index(pos, cols)
      let tile = game.grid[idx]
      if tile.kind is Reservoir && tile.water_level >= 3 && !tile.has_water {
        tile.has_water = true
        changed = true
      }
    }
  }
  // Propagate water from sources (springs and wet tiles)
  // Use a visited set to avoid infinite loops
  let newly_wet : Array[(@types.Pos, Int)] = []
  for y in 0..<rows {
    for x in 0..<cols {
      let pos : @types.Pos = { x, y }
      let idx = @types.pos_to_index(pos, cols)
      let tile = game.grid[idx]
      if !tile.has_water {
        continue
      }
      // Try to flow in all connected directions
      for dir in @types.all_directions {
        let nb = @types.neighbor(pos, dir)
        if !@types.in_bounds(nb, cols, rows) {
          continue
        }
        let nb_idx = @types.pos_to_index(nb, cols)
        let nb_tile = game.grid[nb_idx]
        if nb_tile.has_water {
          continue
        }
        if nb_tile.kind is Empty {
          continue
        }
        if can_flow(game, pos, nb, dir) {
          newly_wet.push((nb, tile.water_level - 1))
        }
      }
    }
  }
  for entry in newly_wet {
    let pos = entry.0
    let wl = entry.1
    let idx = @types.pos_to_index(pos, level.grid_cols)
    let tile = game.grid[idx]
    if !tile.has_water {
      if tile.kind is Reservoir {
        // Reservoir accumulates water
        tile.water_level += 1
        if tile.water_level >= 3 {
          tile.has_water = true
        }
        changed = true
      } else {
        tile.has_water = true
        tile.water_level = if wl > 0 { wl } else { 1 }
        changed = true
      }
    }
  }
  changed
}

///|
/// Run the full simulation until no more water moves or max steps reached.
pub fn run_simulation(game : @types.Game) -> Unit {
  let max_steps = 100
  for _step in 0..<max_steps {
    if !sim_step(game) {
      break
    }
  }
  // Count fountains filled
  let level = game.levels[game.current_level]
  let mut filled = 0
  for f in level.fountains {
    let idx = @types.pos_to_index(f, level.grid_cols)
    if game.grid[idx].has_water {
      filled += 1
    }
  }
  game.fountains_filled = filled
  game.total_fountains = level.fountains.length()
}

///|
/// Reset water state on all tiles (keep structure).
pub fn reset_water(game : @types.Game) -> Unit {
  let level = game.levels[game.current_level]
  for i, tile in game.grid {
    tile.has_water = false
    tile.water_level = 0
    // Re-activate springs
    let pos = @types.index_to_pos(i, level.grid_cols)
    for s in level.springs {
      if s == pos {
        tile.has_water = true
        tile.water_level = 4
      }
    }
    // Reset reservoir accumulation
    if tile.kind is Reservoir {
      tile.water_level = 0
    }
  }
  game.fountains_filled = 0
  game.sim_step = 0
}

///|
/// Calculate the star rating for the current level.
pub fn calculate_stars(game : @types.Game) -> Int {
  let level = game.levels[game.current_level]
  if game.fountains_filled < game.total_fountains {
    return 0
  }
  let segments = @types.count_segments(game)
  // 1 star: all fountains supplied
  let mut stars = 1
  // 2 stars: at or under par
  if segments <= level.par_segments {
    stars = 2
    // 3 stars: at par and no unused segments (all aqueducts carry water)
    let mut all_used = true
    for tile in game.grid {
      if tile.kind is Aqueduct && !tile.has_water {
        all_used = false
        break
      }
    }
    if all_used {
      stars = 3
    }
  }
  stars
}
