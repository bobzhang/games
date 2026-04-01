///|
/// Reset all simulation state on cells
pub fn reset_simulation(state : @types.LevelState) -> Unit {
  for r in 0..<@types.grid_rows {
    for c in 0..<@types.grid_cols {
      let cell = state.cells[r][c]
      cell.powered = false
      cell.voltage = 0.0
      cell.current = 0.0
    }
  }
  state.devices_satisfied = 0
  state.any_fuse_blown = false
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
  // Must be adjacent
  if @types.absf(Float::from_int(dc)) + @types.absf(Float::from_int(dr)) != 1.0 {
    return
  }
  let cell1 = state.cells[r1][c1]
  let cell2 = state.cells[r2][c2]
  if !@types.is_connectable(cell1.component) ||
    !@types.is_connectable(cell2.component) {
    return
  }
  // Determine direction from cell1 to cell2
  if dr == -1 {
    // Up
    cell1.connections[0] = true
    cell2.connections[1] = true
  } else if dr == 1 {
    // Down
    cell1.connections[1] = true
    cell2.connections[0] = true
  } else if dc == -1 {
    // Left
    cell1.connections[2] = true
    cell2.connections[3] = true
  } else if dc == 1 {
    // Right
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
/// Find all connected components (graph traversal) reachable from a starting cell
/// Returns array of (col, row) pairs
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
/// Main simulation: trace circuits from batteries to devices
pub fn simulate(state : @types.LevelState) -> Unit {
  reset_simulation(state)
  // Count devices
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
  // For each battery, find its connected network
  let visited : Array[Array[Bool]] = []
  for _r in 0..<@types.grid_rows {
    let row : Array[Bool] = []
    for _c in 0..<@types.grid_cols {
      row.push(false)
    }
    visited.push(row)
  }
  // Track which network each cell belongs to, and per-network battery count
  let network_id : Array[Array[Int]] = []
  for _r in 0..<@types.grid_rows {
    let row : Array[Int] = []
    for _c in 0..<@types.grid_cols {
      row.push(-1)
    }
    network_id.push(row)
  }
  let network_batteries : Array[Int] = []
  let network_cells : Array[Array[(Int, Int)]] = []
  let mut net_count = 0
  // Find all connected networks
  for r in 0..<@types.grid_rows {
    for c in 0..<@types.grid_cols {
      if !visited[r][c] && @types.is_conductor(state.cells[r][c].component) {
        let cells = flood_fill(state, c, r, visited)
        let mut bat_count = 0
        for j in 0..<cells.length() {
          let (cc, cr) = cells[j]
          network_id[cr][cc] = net_count
          match state.cells[cr][cc].component {
            Battery => bat_count += 1
            _ => ()
          }
        }
        network_batteries.push(bat_count)
        network_cells.push(cells)
        net_count += 1
      }
    }
  }
  // For each network, compute voltage seen by devices
  // Series: batteries in a linear path add voltages
  // We use a simplified model: trace paths from each battery to each device
  // and sum voltages along series paths
  for net in 0..<net_count {
    let cells = network_cells[net]
    let bats = network_batteries[net]
    if bats == 0 {
      continue
    }
    // Find batteries and devices in this network
    let battery_positions : Array[(Int, Int)] = []
    let device_positions : Array[(Int, Int)] = []
    for j in 0..<cells.length() {
      let (cc, cr) = cells[j]
      match state.cells[cr][cc].component {
        Battery => battery_positions.push((cc, cr))
        Device(_) => device_positions.push((cc, cr))
        _ => ()
      }
    }
    // For each device, find the voltage it receives
    // Use BFS from device to find all reachable batteries, counting series chains
    for d in 0..<device_positions.length() {
      let (dc, dr) = device_positions[d]
      let voltage = compute_device_voltage(state, dc, dr)
      let device_cell = state.cells[dr][dc]
      device_cell.voltage = voltage
      device_cell.powered = voltage > 0.0
      // Check satisfaction
      match device_cell.component {
        Device(target) =>
          if @types.absf(voltage - target) <= @types.voltage_tolerance {
            device_cell.powered = true
          }
        _ => ()
      }
    }
    // Mark all cells in powered network
    if bats > 0 {
      for j in 0..<cells.length() {
        let (cc, cr) = cells[j]
        state.cells[cr][cc].powered = true
      }
    }
  }
  // Check fuses
  check_fuses(state)
  // Count satisfied devices
  let mut satisfied = 0
  for r in 0..<@types.grid_rows {
    for c in 0..<@types.grid_cols {
      match state.cells[r][c].component {
        Device(target) =>
          if @types.absf(state.cells[r][c].voltage - target) <=
            @types.voltage_tolerance {
            satisfied += 1
          }
        _ => ()
      }
    }
  }
  state.devices_satisfied = satisfied
  state.simulated = true
}

///|
/// Compute voltage reaching a device by tracing paths from it to batteries.
/// Batteries in series (connected in a chain) add their voltages.
/// Parallel paths don't increase voltage, just the first path's voltage is used.
fn compute_device_voltage(
  state : @types.LevelState,
  dev_col : Int,
  dev_row : Int,
) -> Float {
  // BFS/DFS to find all batteries reachable from this device
  // For series detection: count batteries along the longest chain path
  let visited : Array[Array[Bool]] = []
  for _r in 0..<@types.grid_rows {
    let row : Array[Bool] = []
    for _c in 0..<@types.grid_cols {
      row.push(false)
    }
    visited.push(row)
  }
  // Use DFS to find max voltage path (series chain of batteries)
  let max_voltage = dfs_voltage(state, dev_col, dev_row, visited)
  max_voltage
}

///|
/// DFS to find the maximum voltage reachable from current position.
/// Each battery encountered adds 1.5V to the path voltage.
fn dfs_voltage(
  state : @types.LevelState,
  col : Int,
  row : Int,
  visited : Array[Array[Bool]],
) -> Float {
  visited[row][col] = true
  let cell = state.cells[row][col]
  let my_voltage : Float = match cell.component {
    Battery => @types.battery_voltage
    _ => 0.0
  }
  if !@types.is_conductor(cell.component) {
    visited[row][col] = false
    return my_voltage
  }
  let mut best_neighbor_voltage : Float = 0.0
  let dirs = @types.all_directions()
  for i in 0..<dirs.length() {
    let di = @types.direction_index(dirs[i])
    if !cell.connections[di] {
      continue
    }
    let (dc, dr) = @types.direction_delta(dirs[i])
    let nc = col + dc
    let nr = row + dr
    if @types.in_bounds(nc, nr) && !visited[nr][nc] {
      let neighbor = state.cells[nr][nc]
      if @types.is_conductor(neighbor.component) {
        let v = dfs_voltage(state, nc, nr, visited)
        if v > best_neighbor_voltage {
          best_neighbor_voltage = v
        }
      }
    }
  }
  visited[row][col] = false
  my_voltage + best_neighbor_voltage
}

///|
/// Check fuses: if current through fuse exceeds its rating * blow_multiplier, blow it
fn check_fuses(state : @types.LevelState) -> Unit {
  for r in 0..<@types.grid_rows {
    for c in 0..<@types.grid_cols {
      match state.cells[r][c].component {
        Fuse(rating) => {
          if !state.cells[r][c].powered {
            continue
          }
          // Count connected batteries as a proxy for current
          let voltage = state.cells[r][c].voltage
          let current = voltage / @types.maxf(rating, 0.1)
          state.cells[r][c].current = current
          if current > @types.fuse_blow_multiplier {
            // Blow the fuse - set rating to 0 indicating blown
            state.cells[r][c].component = Fuse(0.0)
            state.any_fuse_blown = true
          }
        }
        _ => ()
      }
    }
  }
}

///|
/// Evaluate level result after simulation
pub fn evaluate_level(state : @types.LevelState) -> @types.LevelResult {
  if !state.simulated {
    simulate(state)
  }
  let mut fuses_blown = 0
  for r in 0..<@types.grid_rows {
    for c in 0..<@types.grid_cols {
      match state.cells[r][c].component {
        Fuse(rating) => if rating == 0.0 { fuses_blown += 1 }
        _ => ()
      }
    }
  }
  let all_satisfied = state.devices_satisfied == state.devices_total &&
    state.devices_total > 0
  let mut stars = 0
  if all_satisfied {
    stars = 1
    if state.batteries_used <= state.par_batteries {
      stars = 2
      if fuses_blown == 0 {
        stars = 3
      }
    }
  }
  {
    stars,
    completed: all_satisfied,
    devices_powered: state.devices_satisfied,
    devices_total: state.devices_total,
    batteries_used: state.batteries_used,
    fuses_blown,
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
    Battery =>
      match cell.component {
        Empty => state.batteries_used < state.battery_budget
        _ => false
      }
    Wire =>
      match cell.component {
        Empty => true
        _ => false
      }
    Fuse(_) =>
      match cell.component {
        Empty => state.fuses_used < state.fuse_budget
        _ => false
      }
    Switch(_) =>
      match cell.component {
        Empty => state.switches_used < state.switch_budget
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
    Battery => state.batteries_used += 1
    Fuse(_) => state.fuses_used += 1
    Switch(_) => state.switches_used += 1
    _ => ()
  }
  // Auto-connect to neighbors
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
    Battery => state.batteries_used -= 1
    Fuse(_) => state.fuses_used -= 1
    Switch(_) => state.switches_used -= 1
    _ => ()
  }
  cell.component = Empty
  disconnect_all(state, col, row)
  true
}

///|
/// Toggle a switch component
pub fn toggle_switch(state : @types.LevelState, col : Int, row : Int) -> Bool {
  if !@types.in_bounds(col, row) {
    return false
  }
  match state.cells[row][col].component {
    Switch(on) => {
      state.cells[row][col].component = Switch(!on)
      true
    }
    _ => false
  }
}
