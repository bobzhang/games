///|
/// Reset all simulation state on cells
pub fn reset_simulation(state : @types.LevelState) -> Unit {
  for r in 0..<@types.grid_rows {
    for c in 0..<@types.grid_cols {
      let cell = state.cells[r][c]
      cell.powered = false
      cell.field_lines = 0
      cell.wattage = 0.0
    }
  }
  state.devices_satisfied = 0
  state.total_power = 0.0
  state.field_lines = []
  state.simulated = false
}

///|
/// Connect two adjacent cells bidirectionally
pub fn connect_cells(
  state : @types.LevelState,
  c1 : Int,
  r1 : Int,
  c2 : Int,
  r2 : Int,
) -> Unit {
  if !@types.in_bounds(c1, r1) || !@types.in_bounds(c2, r2) {
    return
  }
  let dc = c2 - c1
  let dr = r2 - r1
  if @types.absf(Float::from_int(dc)) + @types.absf(Float::from_int(dr)) != 1.0 {
    return
  }
  let cell1 = state.cells[r1][c1]
  let cell2 = state.cells[r2][c2]
  if !@types.is_connectable(cell1.component) ||
    !@types.is_connectable(cell2.component) {
    return
  }
  if dr == -1 {
    cell1.connections[0] = true
    cell2.connections[1] = true
  } else if dr == 1 {
    cell1.connections[1] = true
    cell2.connections[0] = true
  } else if dc == -1 {
    cell1.connections[2] = true
    cell2.connections[3] = true
  } else if dc == 1 {
    cell1.connections[3] = true
    cell2.connections[2] = true
  }
}

///|
/// Disconnect two adjacent cells bidirectionally
pub fn disconnect_cells(
  state : @types.LevelState,
  c1 : Int,
  r1 : Int,
  c2 : Int,
  r2 : Int,
) -> Unit {
  if !@types.in_bounds(c1, r1) || !@types.in_bounds(c2, r2) {
    return
  }
  let dc = c2 - c1
  let dr = r2 - r1
  let cell1 = state.cells[r1][c1]
  let cell2 = state.cells[r2][c2]
  if dr == -1 {
    cell1.connections[0] = false
    cell2.connections[1] = false
  } else if dr == 1 {
    cell1.connections[1] = false
    cell2.connections[0] = false
  } else if dc == -1 {
    cell1.connections[2] = false
    cell2.connections[3] = false
  } else if dc == 1 {
    cell1.connections[3] = false
    cell2.connections[2] = false
  }
}

///|
/// Auto-connect a placed component to all adjacent connectable components
pub fn auto_connect(state : @types.LevelState, col : Int, row : Int) -> Unit {
  let dirs = @types.all_directions()
  for i in 0..<dirs.length() {
    let (dc, dr) = @types.direction_delta(dirs[i])
    let nc = col + dc
    let nr = row + dr
    if @types.in_bounds(nc, nr) &&
      @types.is_connectable(state.cells[nr][nc].component) {
      connect_cells(state, col, row, nc, nr)
    }
  }
}

///|
/// Remove all connections from a cell
pub fn disconnect_all(state : @types.LevelState, col : Int, row : Int) -> Unit {
  let dirs = @types.all_directions()
  for i in 0..<dirs.length() {
    let (dc, dr) = @types.direction_delta(dirs[i])
    let nc = col + dc
    let nr = row + dr
    if @types.in_bounds(nc, nr) {
      disconnect_cells(state, col, row, nc, nr)
    }
  }
}

///|
/// Compute field lines from all magnets to coils.
/// Each magnet emits field lines in 4 cardinal directions.
/// Field lines travel straight until they hit a coil or leave the grid.
/// A coil captures a field line, generating power proportional to captured lines.
fn compute_field_lines(state : @types.LevelState) -> Unit {
  state.field_lines = []
  for r in 0..<@types.grid_rows {
    for c in 0..<@types.grid_cols {
      if @types.is_magnet(state.cells[r][c].component) {
        emit_field_lines(state, c, r)
      }
    }
  }
}

///|
/// Emit field lines from a magnet in all 4 directions
fn emit_field_lines(state : @types.LevelState, col : Int, row : Int) -> Unit {
  let dirs = @types.all_directions()
  for i in 0..<dirs.length() {
    let (dc, dr) = @types.direction_delta(dirs[i])
    let mut nc = col + dc
    let mut nr = row + dr
    let mut strength = @types.field_strength
    let mut captured = false
    let mut end_c = col
    let mut end_r = row
    // Field line travels in a straight line, losing strength over distance
    while @types.in_bounds(nc, nr) && strength > 0.1 {
      end_c = nc
      end_r = nr
      let target = state.cells[nr][nc]
      if @types.is_coil(target.component) {
        // Coil captures the field line
        target.field_lines = target.field_lines + 1
        captured = true
        break
      }
      if @types.is_magnet(target.component) {
        // Another magnet blocks the field line
        break
      }
      // Field strength decreases with distance
      strength = strength - 0.15
      nc = nc + dc
      nr = nr + dr
    }
    if end_c != col || end_r != row {
      let fl : @types.FieldLine = {
        start_col: col,
        start_row: row,
        end_col: end_c,
        end_row: end_r,
        strength,
        captured,
      }
      state.field_lines.push(fl)
    }
  }
}

///|
/// Find all cells connected to a starting cell via wire/coil/device connections
fn flood_fill(
  state : @types.LevelState,
  start_c : Int,
  start_r : Int,
  visited : Array[Array[Bool]],
) -> Array[(Int, Int)] {
  let result : Array[(Int, Int)] = []
  let stack : Array[(Int, Int)] = [(start_c, start_r)]
  visited[start_r][start_c] = true
  while stack.length() > 0 {
    let (c, r) = stack.pop().unwrap()
    result.push((c, r))
    let cell = state.cells[r][c]
    if !@types.is_conductor(cell.component) {
      continue
    }
    let dirs = @types.all_directions()
    for i in 0..<dirs.length() {
      let di = @types.direction_index(dirs[i])
      if !cell.connections[di] {
        continue
      }
      let (dc, dr) = @types.direction_delta(dirs[i])
      let nc = c + dc
      let nr = r + dr
      if @types.in_bounds(nc, nr) && !visited[nr][nc] {
        let neighbor = state.cells[nr][nc]
        if @types.is_conductor(neighbor.component) {
          visited[nr][nc] = true
          stack.push((nc, nr))
        }
      }
    }
  }
  result
}

///|
/// Main simulation: compute field lines, power generation, and device satisfaction
pub fn simulate(state : @types.LevelState) -> Unit {
  reset_simulation(state)
  // Step 1: Count devices
  let mut device_count = 0
  for r in 0..<@types.grid_rows {
    for c in 0..<@types.grid_cols {
      match state.cells[r][c].component {
        Device(_) => device_count += 1
        _ => ()
      }
    }
  }
  state.devices_total = device_count
  // Step 2: Compute field lines from magnets to coils
  compute_field_lines(state)
  // Step 3: Compute wattage generated by each coil
  for r in 0..<@types.grid_rows {
    for c in 0..<@types.grid_cols {
      let cell = state.cells[r][c]
      if @types.is_coil(cell.component) && cell.field_lines > 0 {
        cell.wattage = Float::from_int(cell.field_lines) * @types.watt_per_line
        cell.powered = true
      }
    }
  }
  // Step 4: Distribute power through wire networks
  let visited : Array[Array[Bool]] = []
  for _r in 0..<@types.grid_rows {
    let row : Array[Bool] = []
    for _c in 0..<@types.grid_cols {
      row.push(false)
    }
    visited.push(row)
  }
  // Find connected networks and sum coil power within each
  for r in 0..<@types.grid_rows {
    for c in 0..<@types.grid_cols {
      if !visited[r][c] && @types.is_conductor(state.cells[r][c].component) {
        let cells = flood_fill(state, c, r, visited)
        // Sum all coil wattage in this network
        let mut network_watts : Float = 0.0
        for j in 0..<cells.length() {
          let (cc, cr) = cells[j]
          let cell = state.cells[cr][cc]
          if @types.is_coil(cell.component) {
            network_watts = network_watts + cell.wattage
          }
        }
        // Distribute network power to devices and mark powered
        if network_watts > 0.0 {
          // Count devices in network
          let device_positions : Array[(Int, Int)] = []
          for j in 0..<cells.length() {
            let (cc, cr) = cells[j]
            match state.cells[cr][cc].component {
              Device(_) => device_positions.push((cc, cr))
              _ => ()
            }
          }
          // Each device in the network gets the full network power
          // (parallel distribution - all devices on same bus)
          for j in 0..<device_positions.length() {
            let (dc, dr) = device_positions[j]
            let dev_cell = state.cells[dr][dc]
            dev_cell.wattage = network_watts
            dev_cell.powered = true
          }
          // Mark all cells in powered network
          for j in 0..<cells.length() {
            let (cc, cr) = cells[j]
            state.cells[cr][cc].powered = true
          }
        }
      }
    }
  }
  // Step 5: Check device satisfaction
  let mut satisfied = 0
  let mut total_power : Float = 0.0
  for r in 0..<@types.grid_rows {
    for c in 0..<@types.grid_cols {
      match state.cells[r][c].component {
        Device(target) => {
          let actual = state.cells[r][c].wattage
          if @types.absf(actual - target) <= @types.wattage_tolerance {
            satisfied += 1
          }
          total_power = total_power + actual
        }
        _ => ()
      }
    }
  }
  state.devices_satisfied = satisfied
  state.total_power = total_power
  state.simulated = true
}

///|
/// Evaluate level result after simulation
pub fn evaluate_level(state : @types.LevelState) -> @types.LevelResult {
  if !state.simulated {
    simulate(state)
  }
  let all_satisfied = state.devices_satisfied == state.devices_total &&
    state.devices_total > 0
  let mut stars = 0
  if all_satisfied {
    stars = 1
    if state.magnets_used <= state.par_magnets {
      stars = 2
      // 3 stars: par magnets AND minimal coils (coils used <= devices)
      if state.coils_used <= state.devices_total {
        stars = 3
      }
    }
  }
  {
    stars,
    completed: all_satisfied,
    devices_powered: state.devices_satisfied,
    devices_total: state.devices_total,
    magnets_used: state.magnets_used,
    total_watts: state.total_power,
  }
}

///|
/// Check if a component can be placed at the given cell
pub fn can_place(
  state : @types.LevelState,
  col : Int,
  row : Int,
  comp : @types.ComponentKind,
) -> Bool {
  if !@types.in_bounds(col, row) {
    return false
  }
  let cell = state.cells[row][col]
  if cell.fixed {
    return false
  }
  match comp {
    Magnet(_) =>
      match cell.component {
        Empty => state.magnets_used < state.magnet_budget
        _ => false
      }
    Coil =>
      match cell.component {
        Empty => state.coils_used < state.coil_budget
        _ => false
      }
    Wire =>
      match cell.component {
        Empty => true
        _ => false
      }
    _ => false
  }
}

///|
/// Place a component on the grid
pub fn place_component(
  state : @types.LevelState,
  col : Int,
  row : Int,
  comp : @types.ComponentKind,
) -> Bool {
  if !can_place(state, col, row, comp) {
    return false
  }
  state.cells[row][col].component = comp
  match comp {
    Magnet(_) => state.magnets_used += 1
    Coil => state.coils_used += 1
    _ => ()
  }
  auto_connect(state, col, row)
  true
}

///|
/// Remove a non-fixed component from the grid
pub fn remove_component(
  state : @types.LevelState,
  col : Int,
  row : Int,
) -> Bool {
  if !@types.in_bounds(col, row) {
    return false
  }
  let cell = state.cells[row][col]
  if cell.fixed {
    return false
  }
  match cell.component {
    Empty => return false
    Magnet(_) => state.magnets_used -= 1
    Coil => state.coils_used -= 1
    _ => ()
  }
  cell.component = Empty
  disconnect_all(state, col, row)
  true
}

///|
/// Count field lines passing through a specific cell position
pub fn count_field_lines_at(
  state : @types.LevelState,
  col : Int,
  row : Int,
) -> Int {
  let mut count = 0
  for i in 0..<state.field_lines.length() {
    let fl = state.field_lines[i]
    // Check if cell is on the path of this field line
    if fl.start_col == fl.end_col && fl.start_col == col {
      // Vertical line
      let min_r = @types.mini(fl.start_row, fl.end_row)
      let max_r = @types.maxi(fl.start_row, fl.end_row)
      if row >= min_r && row <= max_r {
        count += 1
      }
    } else if fl.start_row == fl.end_row && fl.start_row == row {
      // Horizontal line
      let min_c = @types.mini(fl.start_col, fl.end_col)
      let max_c = @types.maxi(fl.start_col, fl.end_col)
      if col >= min_c && col <= max_c {
        count += 1
      }
    }
  }
  count
}
