///|
pub fn simulate(state : @types.LevelState) -> Unit {
  reset_energy(state)
  let grid = state.grid
  let connections = state.connections
  // Find all source cells
  for row in 0..<@types.grid_rows {
    for col in 0..<@types.grid_cols {
      if grid[row][col].kind is Source {
        propagate_from_source(state, col, row)
      }
    }
  }
  // Update temple status
  let mut all_powered = true
  let mut total_delivered : Float = 0.0
  for row in 0..<@types.grid_rows {
    for col in 0..<@types.grid_cols {
      match grid[row][col].kind {
        Temple(required) => {
          let received = grid[row][col].energy_received
          total_delivered = total_delivered + received
          if received < required {
            all_powered = false
          }
        }
        _ => ()
      }
    }
  }
  state.all_temples_powered = all_powered
  state.total_energy_delivered = total_delivered
  // Update connection flow animations
  for i in 0..<connections.length() {
    let conn = connections[i]
    if conn.energy_flow > 0.0 {
      conn.flow_anim = 1.0
    } else {
      conn.flow_anim = conn.flow_anim * 0.9
    }
  }
}

///|
fn reset_energy(state : @types.LevelState) -> Unit {
  let grid = state.grid
  let connections = state.connections
  for row in 0..<@types.grid_rows {
    for col in 0..<@types.grid_cols {
      grid[row][col].energy_received = 0.0
    }
  }
  for i in 0..<connections.length() {
    connections[i].energy_flow = 0.0
  }
}

///|
fn propagate_from_source(
  state : @types.LevelState,
  src_col : Int,
  src_row : Int
) -> Unit {
  let grid = state.grid
  let connections = state.connections
  let energy = @types.source_energy
  grid[src_row][src_col].energy_received = energy
  // BFS propagation
  let queue : Array[(Int, Int, Float)] = [(src_col, src_row, energy)]
  let visited : Array[(Int, Int)] = [(src_col, src_row)]
  for head = 0; head < queue.length(); head = head + 1 {
    let (col, row, incoming_energy) = queue[head]
    let neighbors = @types.neighbor_connections(connections, col, row)
    let num_neighbors = count_unvisited(neighbors, visited)
    if num_neighbors == 0 {
      continue head + 1
    }
    let split_energy = incoming_energy / Float::from_int(num_neighbors)
    for i in 0..<neighbors.length() {
      let (nc, nr) = neighbors[i]
      if is_visited(visited, nc, nr) {
        continue
      }
      visited.push((nc, nr))
      // Apply decay
      let decayed = split_energy * (1.0 - @types.decay_rate)
      // Apply amplifier boost
      let final_energy = if grid[nr][nc].kind is Amplifier {
        decayed * @types.amplifier_boost
      } else {
        decayed
      }
      grid[nr][nc].energy_received = grid[nr][nc].energy_received +
        final_energy
      // Set connection flow
      set_connection_flow(connections, col, row, nc, nr, split_energy)
      // Continue propagation if not a void or empty cell
      if @types.is_connectable(grid[nr][nc].kind) && final_energy > 0.1 {
        queue.push((nc, nr, final_energy))
      }
    }
  }
}

///|
fn count_unvisited(
  neighbors : Array[(Int, Int)],
  visited : Array[(Int, Int)]
) -> Int {
  let mut count = 0
  for i in 0..<neighbors.length() {
    let (c, r) = neighbors[i]
    if !(is_visited(visited, c, r)) {
      count = count + 1
    }
  }
  count
}

///|
fn is_visited(visited : Array[(Int, Int)], col : Int, row : Int) -> Bool {
  for i in 0..<visited.length() {
    let (vc, vr) = visited[i]
    if vc == col && vr == row {
      return true
    }
  }
  false
}

///|
fn set_connection_flow(
  connections : Array[@types.Connection],
  c1 : Int,
  r1 : Int,
  c2 : Int,
  r2 : Int,
  flow : Float
) -> Unit {
  for i in 0..<connections.length() {
    let conn = connections[i]
    if (conn.from_col == c1 &&
      conn.from_row == r1 &&
      conn.to_col == c2 &&
      conn.to_row == r2) ||
      (conn.from_col == c2 &&
      conn.from_row == r2 &&
      conn.to_col == c1 &&
      conn.to_row == r1) {
      conn.energy_flow = flow
      return
    }
  }
}
