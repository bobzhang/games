///|
/// Check if signal can travel from (fc,fr) to (tc,tr) without being blocked
/// by mountains. Uses step-by-step traversal along cardinal direction.
pub fn line_of_sight(
  grid : Array[Array[@types.Tile]],
  fc : Int,
  fr : Int,
  tc : Int,
  tr : Int,
) -> Bool {
  let dc = if tc > fc { 1 } else if tc < fc { -1 } else { 0 }
  let dr = if tr > fr { 1 } else if tr < fr { -1 } else { 0 }
  let mut cc = fc + dc
  let mut cr = fr + dr
  while cc != tc || cr != tr {
    if !@types.in_grid(cc, cr) {
      return false
    }
    if grid[cr][cc].kind == Mountain {
      return false
    }
    cc += dc
    cr += dr
  }
  true
}

///|
/// Check if a tile at (col,row) can receive signal from source at (sc,sr)
/// given the source's range.
pub fn can_reach(
  grid : Array[Array[@types.Tile]],
  sc : Int,
  sr : Int,
  tc : Int,
  tr : Int,
  range : Int,
) -> Bool {
  // Must be along cardinal direction
  if sc != tc && sr != tr {
    return false
  }
  let dist = @types.maxi(
    if sc > tc {
      sc - tc
    } else {
      tc - sc
    },
    if sr > tr {
      sr - tr
    } else {
      tr - sr
    },
  )
  if dist > range || dist == 0 {
    return false
  }
  line_of_sight(grid, sc, sr, tc, tr)
}

///|
/// Propagate signals from all transmitters and towers, using BFS.
/// Returns: (all_receivers_lit, max_relay_chain_length, signal_paths)
pub fn propagate(
  state : @types.LevelState,
  data : @types.LevelData,
) -> (Bool, Int, Array[@types.SignalPath]) {
  let grid = state.grid
  // Reset signal state
  for r in 0..<@types.grid_rows {
    for c in 0..<@types.grid_cols {
      grid[r][c].has_signal = false
    }
  }
  // BFS queue: (col, row, chain_depth)
  let queue : Array[(Int, Int, Int)] = []
  let visited : Array[Array[Bool]] = []
  for _r in 0..<@types.grid_rows {
    let row : Array[Bool] = []
    for _c in 0..<@types.grid_cols {
      row.push(false)
    }
    visited.push(row)
  }
  let paths : Array[@types.SignalPath] = []
  // Seed: find all transmitters
  for r in 0..<@types.grid_rows {
    for c in 0..<@types.grid_cols {
      if grid[r][c].kind == Transmitter {
        grid[r][c].has_signal = true
        visited[r][c] = true
        queue.push((c, r, 0))
      }
    }
  }
  let mut max_chain = 0
  let mut head = 0
  while head < queue.length() {
    let (sc, sr, depth) = queue[head]
    head += 1
    let elev = data.elevations[sr][sc]
    let range = @types.tower_range(elev)
    // Check all 4 cardinal directions
    let dirs : Array[(Int, Int)] = [(0, -1), (0, 1), (-1, 0), (1, 0)]
    for d in 0..<dirs.length() {
      let (dc, dr) = dirs[d]
      // Scan tiles in this direction up to range
      for dist in 1..<=range {
        let tc = sc + dc * dist
        let tr = sr + dr * dist
        if !@types.in_grid(tc, tr) {
          break
        }
        let tile = grid[tr][tc]
        // Mountains block further propagation in this direction
        if tile.kind == Mountain {
          break
        }
        // Can we reach this tile?
        let target_kind = tile.kind
        match target_kind {
          Receiver =>
            if !tile.has_signal {
              tile.has_signal = true
              paths.push(@types.new_signal_path(sc, sr, tc, tr))
            }
          Tower =>
            if !visited[tr][tc] {
              visited[tr][tc] = true
              tile.has_signal = true
              let new_depth = depth + 1
              if new_depth > max_chain {
                max_chain = new_depth
              }
              queue.push((tc, tr, new_depth))
              paths.push(@types.new_signal_path(sc, sr, tc, tr))
            }
          _ => ()
        }
      }
    }
  }
  // Check if all receivers are lit
  let mut all_lit = true
  let mut has_receiver = false
  for r in 0..<@types.grid_rows {
    for c in 0..<@types.grid_cols {
      if grid[r][c].kind == Receiver {
        has_receiver = true
        if !grid[r][c].has_signal {
          all_lit = false
        }
      }
    }
  }
  if !has_receiver {
    all_lit = false
  }
  (all_lit, max_chain, paths)
}

///|
/// Compute star rating for a completed level
pub fn compute_stars(
  towers_placed : Int,
  chain_length : Int,
  par_towers : Int,
  par_chain : Int,
) -> @types.StarRating {
  if towers_placed <= par_towers && chain_length <= par_chain {
    Three
  } else if towers_placed <= par_towers {
    Two
  } else {
    One
  }
}
