///|
/// Calculate adjacency bonus for a crop at (col, row)
/// Same-type neighbors give +1 each
/// Special combos: Wheat+Corn=+2, Berry+Flower=+3
pub fn adjacency_bonus(grid : @types.HexGrid, col : Int, row : Int) -> Int {
  let tile = grid.tiles[row][col]
  let crop_kind = match tile.crop {
    Some(k) => k
    None => return 0
  }
  let neighbors = @hex.valid_neighbors(col, row)
  let mut bonus = 0
  let mut has_wheat = false
  let mut has_corn = false
  let mut has_berry = false
  let mut has_flower = false
  for i in 0..<neighbors.length() {
    let (nc, nr) = neighbors[i]
    let ntile = grid.tiles[nr][nc]
    match ntile.crop {
      Some(nkind) => {
        // Same-type bonus
        if nkind == crop_kind {
          bonus += 1
        }
        // Track neighbor types for combo
        match nkind {
          Wheat => has_wheat = true
          Corn => has_corn = true
          Berry => has_berry = true
          Flower => has_flower = true
        }
      }
      None => ()
    }
  }
  // Combo bonuses (only if this crop is part of the combo)
  // Wheat+Corn: staple synergy (+2 each)
  // Berry+Flower: garden synergy (+2 each)
  // Corn+Berry: harvest synergy (+1 each) - rewards mixed planting
  match crop_kind {
    Wheat => if has_corn { bonus += 2 }
    Corn => {
      if has_wheat {
        bonus += 2
      }
      if has_berry {
        bonus += 1
      }
    }
    Berry => {
      if has_flower {
        bonus += 2
      }
      if has_corn {
        bonus += 1
      }
    }
    Flower => if has_berry { bonus += 2 }
  }
  bonus
}

///|
/// Tick crop growth - watered crops advance, returns list of newly matured positions
pub fn grow_crops(grid : @types.HexGrid) -> Array[@types.HexCoord] {
  let matured : Array[@types.HexCoord] = []
  for r in 0..<grid.height {
    for c in 0..<grid.width {
      let tile = grid.tiles[r][c]
      match tile.crop {
        Some(kind) =>
          if tile.watered {
            match tile.crop_state {
              Seed => {
                tile.crop_state = Growing
                tile.crop_turns = 1
              }
              Growing => {
                tile.crop_turns += 1
                if tile.crop_turns >= @types.crop_grow_time(kind) {
                  tile.crop_state = Mature
                  matured.push({ col: c, row: r })
                }
              }
              Mature | Harvested => ()
            }
          }
        None => ()
      }
    }
  }
  matured
}

///|
/// Harvest all mature crops, returning total yield with adjacency bonuses
pub fn harvest_mature(grid : @types.HexGrid) -> (Int, Array[@types.HexCoord]) {
  let mut total_yield = 0
  let harvested : Array[@types.HexCoord] = []
  for r in 0..<grid.height {
    for c in 0..<grid.width {
      let tile = grid.tiles[r][c]
      match tile.crop {
        Some(kind) =>
          if tile.crop_state == Mature {
            let base = @types.crop_base_yield(kind)
            let bonus = adjacency_bonus(grid, c, r)
            total_yield += base + bonus
            tile.crop_state = Harvested
            harvested.push({ col: c, row: r })
          }
        None => ()
      }
    }
  }
  (total_yield, harvested)
}

///|
/// Calculate projected yield if all current crops matured
pub fn projected_yield(grid : @types.HexGrid) -> Int {
  let mut total = 0
  for r in 0..<grid.height {
    for c in 0..<grid.width {
      let tile = grid.tiles[r][c]
      match tile.crop {
        Some(kind) =>
          match tile.crop_state {
            Seed | Growing | Mature => {
              let base = @types.crop_base_yield(kind)
              let bonus = adjacency_bonus(grid, c, r)
              total += base + bonus
            }
            Harvested => ()
          }
        None => ()
      }
    }
  }
  total
}

///|
/// Count crops in each state
pub fn count_crops(grid : @types.HexGrid) -> (Int, Int, Int, Int) {
  let mut seeds = 0
  let mut growing = 0
  let mut mature = 0
  let mut harvested = 0
  for r in 0..<grid.height {
    for c in 0..<grid.width {
      let tile = grid.tiles[r][c]
      match tile.crop {
        Some(_) =>
          match tile.crop_state {
            Seed => seeds += 1
            Growing => growing += 1
            Mature => mature += 1
            Harvested => harvested += 1
          }
        None => ()
      }
    }
  }
  (seeds, growing, mature, harvested)
}

///|
/// Get adjacent tiles that would boost a crop placed at (col, row) of given kind
pub fn adjacency_preview(
  grid : @types.HexGrid,
  col : Int,
  row : Int,
  kind : @types.CropKind,
) -> Array[(Int, Int)] {
  let neighbors = @hex.valid_neighbors(col, row)
  let result : Array[(Int, Int)] = []
  for i in 0..<neighbors.length() {
    let (nc, nr) = neighbors[i]
    let ntile = grid.tiles[nr][nc]
    match ntile.crop {
      Some(nkind) => {
        // Same-type gives bonus
        if nkind == kind {
          result.push((nc, nr))
        }
        // Combo check
        let is_combo = match (kind, nkind) {
          (Wheat, Corn)
          | (Corn, Wheat)
          | (Berry, Flower)
          | (Flower, Berry)
          | (Corn, Berry)
          | (Berry, Corn) => true
          _ => false
        }
        if is_combo {
          result.push((nc, nr))
        }
      }
      None => ()
    }
  }
  result
}
