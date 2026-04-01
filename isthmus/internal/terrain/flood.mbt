///|
pub fn is_tile_flooded(tile : @types.Tile, sea_level : Int) -> Bool {
  tile.height <= sea_level
}

///|
pub fn count_flooded_tiles(grid : @types.Grid, sea_level : Int) -> Int {
  let mut count = 0
  for i in 0..<grid.tiles.length() {
    if is_tile_flooded(grid.tiles[i], sea_level) {
      count += 1
    }
  }
  count
}

///|
pub fn any_settlement_flooded(grid : @types.Grid, sea_level : Int) -> Bool {
  for i in 0..<grid.tiles.length() {
    if grid.tiles[i].is_settlement && is_tile_flooded(grid.tiles[i], sea_level) {
      return true
    }
  }
  false
}

///|
pub fn will_settlement_flood_next(grid : @types.Grid, sea_level : Int) -> Bool {
  let next_level = sea_level + 1
  for i in 0..<grid.tiles.length() {
    if grid.tiles[i].is_settlement && grid.tiles[i].height <= next_level {
      return true
    }
  }
  false
}

///|
pub fn tiles_flooding_next(grid : @types.Grid, sea_level : Int) -> Array[Int] {
  let result : Array[Int] = []
  let next_level = sea_level + 1
  for i in 0..<grid.tiles.length() {
    let tile = grid.tiles[i]
    if tile.height > sea_level && tile.height <= next_level {
      result.push(i)
    }
  }
  result
}

///|
fn neighbors(grid : @types.Grid, x : Int, y : Int) -> Array[(Int, Int)] {
  let result : Array[(Int, Int)] = []
  if x > 0 {
    result.push((x - 1, y))
  }
  if x < grid.width - 1 {
    result.push((x + 1, y))
  }
  if y > 0 {
    result.push((x, y - 1))
  }
  if y < grid.height - 1 {
    result.push((x, y + 1))
  }
  result
}

///|
pub fn bfs_connected(
  grid : @types.Grid,
  start_idx : Int,
  sea_level : Int,
) -> Array[Bool] {
  let visited : Array[Bool] = Array::new(capacity=grid.tiles.length())
  for _i in 0..<grid.tiles.length() {
    visited.push(false)
  }
  let queue : Array[Int] = [start_idx]
  visited[start_idx] = true
  let mut head = 0
  while head < queue.length() {
    let idx = queue[head]
    head += 1
    let (cx, cy) = @types.index_to_xy(grid, idx)
    let nbrs = neighbors(grid, cx, cy)
    for i in 0..<nbrs.length() {
      let (nx, ny) = nbrs[i]
      let nidx = @types.grid_index(grid, nx, ny)
      if !visited[nidx] && grid.tiles[nidx].height > sea_level {
        visited[nidx] = true
        queue.push(nidx)
      }
    }
  }
  visited
}

///|
pub fn all_settlements_connected(grid : @types.Grid, sea_level : Int) -> Bool {
  let settlements = @types.settlement_positions(grid)
  if settlements.length() <= 1 {
    return true
  }
  // Find first non-flooded settlement
  let mut start = -1
  for i in 0..<settlements.length() {
    if grid.tiles[settlements[i]].height > sea_level {
      start = settlements[i]
      break
    }
  }
  if start == -1 {
    return false
  }
  let visited = bfs_connected(grid, start, sea_level)
  for i in 0..<settlements.length() {
    let sidx = settlements[i]
    if grid.tiles[sidx].height > sea_level && !visited[sidx] {
      return false
    }
  }
  true
}

///|
pub fn count_connected_settlements(
  grid : @types.Grid,
  sea_level : Int,
) -> (Int, Int) {
  let settlements = @types.settlement_positions(grid)
  if settlements.length() == 0 {
    return (0, 0)
  }
  let mut first_above = -1
  for i in 0..<settlements.length() {
    if grid.tiles[settlements[i]].height > sea_level {
      if first_above == -1 {
        first_above = settlements[i]
      }
    }
  }
  if first_above == -1 {
    return (0, settlements.length())
  }
  let visited = bfs_connected(grid, first_above, sea_level)
  let mut connected = 0
  for i in 0..<settlements.length() {
    let sidx = settlements[i]
    if grid.tiles[sidx].height > sea_level && visited[sidx] {
      connected += 1
    }
  }
  (connected, settlements.length())
}

///|
pub fn settlement_safety_margin(grid : @types.Grid, sea_level : Int) -> Int {
  let mut min_margin = 100
  for i in 0..<grid.tiles.length() {
    if grid.tiles[i].is_settlement {
      let margin = grid.tiles[i].height - sea_level
      if margin < min_margin {
        min_margin = margin
      }
    }
  }
  min_margin
}
