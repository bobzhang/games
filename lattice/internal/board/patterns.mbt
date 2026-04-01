///|
/// Find all patterns for a given player on the board
pub fn find_all_patterns(
  board : @types.HexBoard,
  player : @types.Player,
) -> Array[@types.Pattern] {
  let result : Array[@types.Pattern] = []
  find_bridges(board, player, result)
  find_chains(board, player, result)
  find_triangles(board, player, result)
  find_diamonds(board, player, result)
  find_fortresses(board, player, result)
  find_rings(board, player, result)
  find_stars(board, player, result)
  find_walls(board, player, result)
  result
}

///|
/// Calculate total pattern score for a player
pub fn score_patterns(board : @types.HexBoard, player : @types.Player) -> Int {
  let patterns = find_all_patterns(board, player)
  let mut total = 0
  for i in 0..<patterns.length() {
    total = total + patterns[i].points
  }
  total
}

///|
/// Bridge: 2 stones of same color connected by exactly one empty gap
/// The gap must be a common neighbor of both stones
fn find_bridges(
  board : @types.HexBoard,
  player : @types.Player,
  result : Array[@types.Pattern],
) -> Unit {
  let found : Array[(Int, Int, Int, Int)] = []
  for r in 0..<board.size {
    for c in 0..<board.size {
      let coord : @types.HexCoord = { row: r, col: c }
      if @types.has_stone(board, coord, player) {
        let neighbors = @types.hex_neighbors_valid(coord, board.size)
        for ni in 0..<neighbors.length() {
          let n = neighbors[ni]
          if @types.get_cell(board, n) == Empty {
            // n is the gap - check if n has another neighbor with same player's stone
            let n_neighbors = @types.hex_neighbors_valid(n, board.size)
            for nni in 0..<n_neighbors.length() {
              let nn = n_neighbors[nni]
              if @types.has_stone(board, nn, player) &&
                !@types.hex_eq(nn, coord) {
                // Bridge found: coord -- gap(n) -- nn
                let r1 = @types.mini(r, nn.row) * 100 + @types.mini(c, nn.col)
                let r2 = @types.maxi(r, nn.row) * 100 + @types.maxi(c, nn.col)
                // Check for duplicate
                let mut dup = false
                for di in 0..<found.length() {
                  let (fr1, fr2, _fr3, _fr4) = found[di]
                  if fr1 == r1 && fr2 == r2 {
                    dup = true
                    break
                  }
                }
                if !dup {
                  // Also verify the two stones are NOT direct neighbors
                  let direct_neighbors = @types.hex_neighbors_valid(
                    coord,
                    board.size,
                  )
                  let mut is_direct = false
                  for di in 0..<direct_neighbors.length() {
                    if @types.hex_eq(direct_neighbors[di], nn) {
                      is_direct = true
                      break
                    }
                  }
                  if !is_direct {
                    found.push((r1, r2, n.row, n.col))
                    result.push({
                      kind: Bridge,
                      positions: [coord, nn],
                      points: @types.bridge_points,
                    })
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}

///|
/// Chain: 3+ stones in a line along one of the 3 hex axes
fn find_chains(
  board : @types.HexBoard,
  player : @types.Player,
  result : Array[@types.Pattern],
) -> Unit {
  // For odd-r hex grid, the three main axes for each cell are:
  // Direction pairs: we check 3 directions from each cell
  // Dir 0: same row, increasing col (East)
  // Dir 1: going SE (for even rows: row+1, col; for odd rows: row+1, col+1)
  // Dir 2: going NE (for even rows: row-1, col; for odd rows: row-1, col+1)
  //
  // For each direction, find maximal run starting from each cell
  let found_set : Array[String] = []
  for r in 0..<board.size {
    for c in 0..<board.size {
      let start : @types.HexCoord = { row: r, col: c }
      if @types.has_stone(board, start, player) {
        // Direction 0: East (same row, col+1)
        check_chain_dir(board, player, start, 0, result, found_set)
        // Direction 1: SE
        check_chain_dir(board, player, start, 1, result, found_set)
        // Direction 2: NE
        check_chain_dir(board, player, start, 2, result, found_set)
      }
    }
  }
}

///|
fn next_in_direction(coord : @types.HexCoord, dir : Int) -> @types.HexCoord {
  let row = coord.row
  let col = coord.col
  let parity = row % 2
  match dir {
    // East
    0 => { row, col: col + 1 }
    // SE
    1 =>
      if parity == 0 {
        { row: row + 1, col }
      } else {
        { row: row + 1, col: col + 1 }
      }
    // NE
    _ =>
      if parity == 0 {
        { row: row - 1, col }
      } else {
        { row: row - 1, col: col + 1 }
      }
  }
}

///|
fn prev_in_direction(coord : @types.HexCoord, dir : Int) -> @types.HexCoord {
  let row = coord.row
  let col = coord.col
  let parity = row % 2
  match dir {
    0 => { row, col: col - 1 }
    1 =>
      if parity == 0 {
        { row: row - 1, col: col - 1 }
      } else {
        { row: row - 1, col }
      }
    _ =>
      if parity == 0 {
        { row: row + 1, col: col - 1 }
      } else {
        { row: row + 1, col }
      }
  }
}

///|
fn check_chain_dir(
  board : @types.HexBoard,
  player : @types.Player,
  start : @types.HexCoord,
  dir : Int,
  result : Array[@types.Pattern],
  found_set : Array[String],
) -> Unit {
  // Only start a chain if there's no stone in the previous direction
  let prev = prev_in_direction(start, dir)
  if @types.in_bounds(prev, board.size) && @types.has_stone(board, prev, player) {
    return // This is not the start of a maximal chain
  }
  // Collect stones in this direction
  let stones : Array[@types.HexCoord] = [start]
  let mut cur = start
  for i in 0..<board.size {
    let _ = i
    let next = next_in_direction(cur, dir)
    if @types.in_bounds(next, board.size) &&
      @types.has_stone(board, next, player) {
      stones.push(next)
      cur = next
    } else {
      break
    }
  }
  if stones.length() >= 3 {
    // Create a key to deduplicate
    let key_buf = StringBuilder::new()
    key_buf.write_string(dir.to_string())
    for si in 0..<stones.length() {
      key_buf.write_string("_")
      key_buf.write_string(stones[si].row.to_string())
      key_buf.write_string(",")
      key_buf.write_string(stones[si].col.to_string())
    }
    let key = key_buf.to_string()
    let mut dup = false
    for fi in 0..<found_set.length() {
      if found_set[fi] == key {
        dup = true
        break
      }
    }
    if !dup {
      found_set.push(key)
      result.push({
        kind: Chain,
        positions: stones,
        points: @types.chain_points,
      })
    }
  }
}

///|
/// Triangle: 3 stones forming a triangle (each is a neighbor of the other two)
fn find_triangles(
  board : @types.HexBoard,
  player : @types.Player,
  result : Array[@types.Pattern],
) -> Unit {
  let found : Array[String] = []
  for r in 0..<board.size {
    for c in 0..<board.size {
      let a : @types.HexCoord = { row: r, col: c }
      if @types.has_stone(board, a, player) {
        let a_neighbors = @types.hex_neighbors_valid(a, board.size)
        for i in 0..<a_neighbors.length() {
          let b = a_neighbors[i]
          if @types.has_stone(board, b, player) {
            let b_neighbors = @types.hex_neighbors_valid(b, board.size)
            for j in 0..<b_neighbors.length() {
              let cc = b_neighbors[j]
              if @types.has_stone(board, cc, player) &&
                !@types.hex_eq(cc, a) &&
                !@types.hex_eq(cc, b) {
                // Check c is also neighbor of a
                let a_n2 = @types.hex_neighbors_valid(a, board.size)
                let mut c_neighbors_a = false
                for k in 0..<a_n2.length() {
                  if @types.hex_eq(a_n2[k], cc) {
                    c_neighbors_a = true
                    break
                  }
                }
                if c_neighbors_a {
                  // Sort the three coords for dedup
                  let coords = sort_three_coords(a, b, cc)
                  let key = coords.0.row.to_string() +
                    "," +
                    coords.0.col.to_string() +
                    "_" +
                    coords.1.row.to_string() +
                    "," +
                    coords.1.col.to_string() +
                    "_" +
                    coords.2.row.to_string() +
                    "," +
                    coords.2.col.to_string()
                  let mut dup = false
                  for fi in 0..<found.length() {
                    if found[fi] == key {
                      dup = true
                      break
                    }
                  }
                  if !dup {
                    found.push(key)
                    result.push({
                      kind: Triangle,
                      positions: [a, b, cc],
                      points: @types.triangle_points,
                    })
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}

///|
fn coord_key(c : @types.HexCoord) -> Int {
  c.row * 100 + c.col
}

///|
fn sort_three_coords(
  a : @types.HexCoord,
  b : @types.HexCoord,
  c : @types.HexCoord,
) -> (@types.HexCoord, @types.HexCoord, @types.HexCoord) {
  let ka = coord_key(a)
  let kb = coord_key(b)
  let kc = coord_key(c)
  if ka <= kb && ka <= kc {
    if kb <= kc {
      (a, b, c)
    } else {
      (a, c, b)
    }
  } else if kb <= ka && kb <= kc {
    if ka <= kc {
      (b, a, c)
    } else {
      (b, c, a)
    }
  } else if ka <= kb {
    (c, a, b)
  } else {
    (c, b, a)
  }
}

///|
/// Diamond: 4 stones forming a rhombus shape
/// Two triangles sharing an edge: A-B-C and A-B-D where C and D are on opposite sides
fn find_diamonds(
  board : @types.HexBoard,
  player : @types.Player,
  result : Array[@types.Pattern],
) -> Unit {
  let found : Array[String] = []
  for r in 0..<board.size {
    for c in 0..<board.size {
      let a : @types.HexCoord = { row: r, col: c }
      if @types.has_stone(board, a, player) {
        let a_nbrs = @types.hex_neighbors_valid(a, board.size)
        for i in 0..<a_nbrs.length() {
          let b = a_nbrs[i]
          if @types.has_stone(board, b, player) {
            // Find common neighbors of a and b that have stones
            let b_nbrs = @types.hex_neighbors_valid(b, board.size)
            let common : Array[@types.HexCoord] = []
            for j in 0..<a_nbrs.length() {
              let an = a_nbrs[j]
              if @types.has_stone(board, an, player) &&
                !@types.hex_eq(an, a) &&
                !@types.hex_eq(an, b) {
                for k in 0..<b_nbrs.length() {
                  if @types.hex_eq(b_nbrs[k], an) {
                    common.push(an)
                    break
                  }
                }
              }
            }
            // Need exactly 2 common neighbors to form a diamond
            if common.length() >= 2 {
              for ci in 0..<(common.length() - 1) {
                for cj in (ci + 1)..<common.length() {
                  let cc = common[ci]
                  let dd = common[cj]
                  // Verify cc and dd are NOT neighbors (diamond shape, not a clump)
                  let cc_nbrs = @types.hex_neighbors_valid(cc, board.size)
                  let mut are_neighbors = false
                  for k in 0..<cc_nbrs.length() {
                    if @types.hex_eq(cc_nbrs[k], dd) {
                      are_neighbors = true
                      break
                    }
                  }
                  if !are_neighbors {
                    let coords = sort_four_coords(a, b, cc, dd)
                    let key = coord_key(coords.0).to_string() +
                      "_" +
                      coord_key(coords.1).to_string() +
                      "_" +
                      coord_key(coords.2).to_string() +
                      "_" +
                      coord_key(coords.3).to_string()
                    let mut dup = false
                    for fi in 0..<found.length() {
                      if found[fi] == key {
                        dup = true
                        break
                      }
                    }
                    if !dup {
                      found.push(key)
                      result.push({
                        kind: Diamond,
                        positions: [a, b, cc, dd],
                        points: @types.diamond_points,
                      })
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}

///|
fn sort_four_coords(
  a : @types.HexCoord,
  b : @types.HexCoord,
  c : @types.HexCoord,
  d : @types.HexCoord,
) -> (@types.HexCoord, @types.HexCoord, @types.HexCoord, @types.HexCoord) {
  let arr : Array[@types.HexCoord] = [a, b, c, d]
  // Simple bubble sort by coord_key
  for _pass in 0..<3 {
    for i in 0..<3 {
      if coord_key(arr[i]) > coord_key(arr[i + 1]) {
        let tmp = arr[i]
        arr[i] = arr[i + 1]
        arr[i + 1] = tmp
      }
    }
  }
  (arr[0], arr[1], arr[2], arr[3])
}

///|
/// Fortress: A stone surrounded by 4+ friendly stones
fn find_fortresses(
  board : @types.HexBoard,
  player : @types.Player,
  result : Array[@types.Pattern],
) -> Unit {
  for r in 0..<board.size {
    for c in 0..<board.size {
      let center : @types.HexCoord = { row: r, col: c }
      if @types.has_stone(board, center, player) {
        let nbrs = @types.hex_neighbors_valid(center, board.size)
        let mut friendly_count = 0
        let positions : Array[@types.HexCoord] = [center]
        for i in 0..<nbrs.length() {
          if @types.has_stone(board, nbrs[i], player) {
            friendly_count = friendly_count + 1
            positions.push(nbrs[i])
          }
        }
        if friendly_count >= 4 {
          result.push({
            kind: Fortress,
            positions,
            points: @types.fortress_points,
          })
        }
      }
    }
  }
}

///|
/// Ring: 6 stones forming a hexagonal ring (all 6 neighbors of an empty center)
fn find_rings(
  board : @types.HexBoard,
  player : @types.Player,
  result : Array[@types.Pattern],
) -> Unit {
  for r in 0..<board.size {
    for c in 0..<board.size {
      let center : @types.HexCoord = { row: r, col: c }
      if @types.get_cell(board, center) == Empty {
        let nbrs = @types.hex_neighbors_valid(center, board.size)
        if nbrs.length() == 6 {
          let mut all_friendly = true
          let positions : Array[@types.HexCoord] = []
          for i in 0..<nbrs.length() {
            if @types.has_stone(board, nbrs[i], player) {
              positions.push(nbrs[i])
            } else {
              all_friendly = false
              break
            }
          }
          if all_friendly && positions.length() == 6 {
            result.push({ kind: Ring, positions, points: @types.ring_points })
          }
        }
      }
    }
  }
}

///|
/// Star: Center stone + all 6 neighbors are the same player
fn find_stars(
  board : @types.HexBoard,
  player : @types.Player,
  result : Array[@types.Pattern],
) -> Unit {
  for r in 0..<board.size {
    for c in 0..<board.size {
      let center : @types.HexCoord = { row: r, col: c }
      if @types.has_stone(board, center, player) {
        let nbrs = @types.hex_neighbors_valid(center, board.size)
        if nbrs.length() == 6 {
          let mut all_friendly = true
          let positions : Array[@types.HexCoord] = [center]
          for i in 0..<nbrs.length() {
            if @types.has_stone(board, nbrs[i], player) {
              positions.push(nbrs[i])
            } else {
              all_friendly = false
              break
            }
          }
          if all_friendly {
            result.push({ kind: Star, positions, points: @types.star_points })
          }
        }
      }
    }
  }
}

///|
/// Wall: 4+ stones along the board edge
fn find_walls(
  board : @types.HexBoard,
  player : @types.Player,
  result : Array[@types.Pattern],
) -> Unit {
  // Check each edge direction and find runs of stones
  // Top edge: row=0, all cols
  check_wall_edge(board, player, result, 0, true)
  // Bottom edge: row=size-1, all cols
  check_wall_edge(board, player, result, board.size - 1, true)
  // Left edge: col=0, all rows
  check_wall_edge_col(board, player, result, 0)
  // Right edge: col=size-1, all rows
  check_wall_edge_col(board, player, result, board.size - 1)
}

///|
fn check_wall_edge(
  board : @types.HexBoard,
  player : @types.Player,
  result : Array[@types.Pattern],
  row : Int,
  _is_row : Bool,
) -> Unit {
  let mut run : Array[@types.HexCoord] = []
  for c in 0..<board.size {
    let coord : @types.HexCoord = { row, col: c }
    if @types.has_stone(board, coord, player) {
      run.push(coord)
    } else {
      if run.length() >= 4 {
        let positions : Array[@types.HexCoord] = []
        for i in 0..<run.length() {
          positions.push(run[i])
        }
        result.push({ kind: Wall, positions, points: @types.wall_points })
      }
      run = []
    }
  }
  if run.length() >= 4 {
    result.push({ kind: Wall, positions: run, points: @types.wall_points })
  }
}

///|
fn check_wall_edge_col(
  board : @types.HexBoard,
  player : @types.Player,
  result : Array[@types.Pattern],
  col : Int,
) -> Unit {
  let mut run : Array[@types.HexCoord] = []
  for r in 0..<board.size {
    let coord : @types.HexCoord = { row: r, col }
    if @types.has_stone(board, coord, player) {
      run.push(coord)
    } else {
      if run.length() >= 4 {
        let positions : Array[@types.HexCoord] = []
        for i in 0..<run.length() {
          positions.push(run[i])
        }
        result.push({ kind: Wall, positions, points: @types.wall_points })
      }
      run = []
    }
  }
  if run.length() >= 4 {
    result.push({ kind: Wall, positions: run, points: @types.wall_points })
  }
}
