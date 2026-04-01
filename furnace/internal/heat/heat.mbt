///|
pub fn simulate_step(grid : @types.Grid) -> Unit {
  let size = grid.size
  // Build a snapshot of current temperatures
  let old_temps : Array[Array[Float]] = []
  for r in 0..<size {
    let row : Array[Float] = []
    for c in 0..<size {
      row.push(grid.tiles[r][c].temperature)
    }
    old_temps.push(row)
  }
  // First, heat sources emit their heat
  for r in 0..<size {
    for c in 0..<size {
      match grid.tiles[r][c].kind {
        HeatSource(heat) => {
          grid.tiles[r][c].temperature = heat
          old_temps[r][c] = heat
        }
        _ => ()
      }
    }
  }
  // Calculate new temperatures based on heat conduction
  for r in 0..<size {
    for c in 0..<size {
      let tile = grid.tiles[r][c]
      if is_heat_source(tile) {
        continue
      }
      let my_cond = @types.conductivity(tile.material)
      let zero : Float = 0.0
      if my_cond <= zero {
        continue
      }
      let is_glass = tile.material == Glass
      let mut heat_sum : Float = 0.0
      let mut weight_sum : Float = 0.0
      let neighbors = get_neighbors(r, c, size)
      for n = 0; n < neighbors.length(); n = n + 1 {
        let nr = neighbors[n].0
        let nc = neighbors[n].1
        let neighbor = grid.tiles[nr][nc]
        let n_cond = @types.conductivity(neighbor.material)
        let effective_cond : Float = if is_glass {
          my_cond * 0.5
        } else {
          let min_c : Float = if n_cond > zero { n_cond } else { my_cond }
          @types.minf(my_cond, min_c)
        }
        if effective_cond > zero {
          let temp_diff : Float = old_temps[nr][nc] - old_temps[r][c]
          heat_sum = heat_sum +
            temp_diff * effective_cond * @types.heat_spread_rate
          weight_sum = weight_sum + effective_cond
        }
      }
      if weight_sum > zero {
        let new_temp : Float = old_temps[r][c] + heat_sum
        tile.temperature = @types.clampf(new_temp, 0.0, 999.0)
      }
    }
  }
  propagate_glass(grid, old_temps)
}

///|
fn is_heat_source(tile : @types.Tile) -> Bool {
  match tile.kind {
    HeatSource(_) => true
    _ => false
  }
}

///|
fn is_heat_source_or_conductor(tile : @types.Tile) -> Bool {
  match tile.kind {
    HeatSource(_) => true
    _ => @types.conductivity(tile.material) > 0.0
  }
}

///|
fn propagate_glass(
  grid : @types.Grid,
  _old_temps : Array[Array[Float]],
) -> Unit {
  let size = grid.size
  for r in 0..<size {
    for c in 0..<size {
      let tile = grid.tiles[r][c]
      if tile.material != Glass {
        continue
      }
      if is_heat_source(tile) {
        continue
      }
      let neighbors = get_neighbors(r, c, size)
      let mut max_neighbor_temp : Float = tile.temperature
      for n = 0; n < neighbors.length(); n = n + 1 {
        let nr = neighbors[n].0
        let nc = neighbors[n].1
        let nt = grid.tiles[nr][nc].temperature
        if nt > max_neighbor_temp {
          max_neighbor_temp = nt
        }
      }
      let glass_rate : Float = @types.conductivity(Glass) *
        @types.heat_spread_rate
      let diff : Float = max_neighbor_temp - tile.temperature
      let threshold : Float = 0.5
      if diff > threshold {
        tile.temperature = tile.temperature + diff * glass_rate
      }
    }
  }
}

///|
pub fn get_neighbors(r : Int, c : Int, size : Int) -> Array[(Int, Int)] {
  let result : Array[(Int, Int)] = []
  if r > 0 {
    result.push((r - 1, c))
  }
  if r < size - 1 {
    result.push((r + 1, c))
  }
  if c > 0 {
    result.push((r, c - 1))
  }
  if c < size - 1 {
    result.push((r, c + 1))
  }
  result
}

///|
pub fn is_stable(grid : @types.Grid, threshold : Float) -> Bool {
  let size = grid.size
  let zero : Float = 0.0
  for r in 0..<size {
    for c in 0..<size {
      let tile = grid.tiles[r][c]
      if is_heat_source(tile) {
        continue
      }
      let cond = @types.conductivity(tile.material)
      if cond <= zero {
        continue
      }
      let neighbors = get_neighbors(r, c, size)
      for n = 0; n < neighbors.length(); n = n + 1 {
        let nr = neighbors[n].0
        let nc = neighbors[n].1
        let neighbor = grid.tiles[nr][nc]
        if is_heat_source_or_conductor(neighbor) {
          let diff = @types.absf(tile.temperature - neighbor.temperature)
          if diff > threshold {
            return false
          }
        }
      }
    }
  }
  true
}

///|
pub fn run_simulation(grid : @types.Grid, max_turns : Int) -> Int {
  let stability_threshold : Float = 0.5
  for turn in 1..<=max_turns {
    simulate_step(grid)
    if is_stable(grid, stability_threshold) {
      return turn
    }
  }
  max_turns
}
