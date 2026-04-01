///|
/// Simulate one step of water flow. Water spreads from sources and
/// already-watered tiles to adjacent lower-or-equal-height tiles.
/// Returns list of newly watered hex coordinates for animation.
pub fn flow_water(grid : @types.HexGrid) -> Array[@types.HexCoord] {
  let newly_watered : Array[@types.HexCoord] = []
  // First, ensure water sources are always watered
  for r in 0..<grid.height {
    for c in 0..<grid.width {
      let tile = grid.tiles[r][c]
      match tile.kind {
        WaterSource | River => tile.watered = true
        _ => ()
      }
    }
  }
  // Collect all currently watered tiles
  let watered_tiles : Array[(Int, Int)] = []
  for r in 0..<grid.height {
    for c in 0..<grid.width {
      if grid.tiles[r][c].watered {
        watered_tiles.push((c, r))
      }
    }
  }
  // Spread water from watered tiles to valid flow targets
  for i in 0..<watered_tiles.length() {
    let (col, row) = watered_tiles[i]
    let targets = @hex.water_flow_targets(grid, col, row)
    for j in 0..<targets.length() {
      let (tc, tr) = targets[j]
      let target_tile = grid.tiles[tr][tc]
      if !target_tile.watered {
        target_tile.watered = true
        newly_watered.push({ col: tc, row: tr })
      }
    }
  }
  newly_watered
}

///|
/// Preview where water would flow next turn (without modifying state)
pub fn preview_water_flow(grid : @types.HexGrid) -> Array[@types.HexCoord] {
  let preview : Array[@types.HexCoord] = []
  // Find all currently watered tiles
  for r in 0..<grid.height {
    for c in 0..<grid.width {
      if grid.tiles[r][c].watered {
        let targets = @hex.water_flow_targets(grid, c, r)
        for j in 0..<targets.length() {
          let (tc, tr) = targets[j]
          if !grid.tiles[tr][tc].watered {
            // Check not already in preview
            let mut found = false
            for k in 0..<preview.length() {
              if preview[k].col == tc && preview[k].row == tr {
                found = true
                break
              }
            }
            if !found {
              preview.push({ col: tc, row: tr })
            }
          }
        }
      }
    }
  }
  preview
}

///|
/// Check if a tile would be watered if a channel were placed at (col, row)
pub fn would_channel_bring_water(
  grid : @types.HexGrid,
  col : Int,
  row : Int,
) -> Bool {
  let tile = grid.tiles[row][col]
  // Check if any neighbor is watered and at higher or equal height
  let neighbors = @hex.valid_neighbors(col, row)
  for i in 0..<neighbors.length() {
    let (nc, nr) = neighbors[i]
    let ntile = grid.tiles[nr][nc]
    if ntile.watered {
      if ntile.height > tile.height {
        return true
      }
      if ntile.height == tile.height && (ntile.has_channel || true) {
        // Channel at current tile would allow same-height flow
        return true
      }
    }
  }
  false
}

///|
/// Count how many tiles are currently watered
pub fn count_watered(grid : @types.HexGrid) -> Int {
  let mut count = 0
  for r in 0..<grid.height {
    for c in 0..<grid.width {
      if grid.tiles[r][c].watered {
        count += 1
      }
    }
  }
  count
}
