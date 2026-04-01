///|
pub fn can_place_sand(
  grid : @types.Grid,
  x : Int,
  y : Int,
  sea_level : Int,
) -> Bool {
  if !@types.grid_in_bounds(grid, x, y) {
    return false
  }
  let tile = @types.grid_get(grid, x, y)
  // Can only place on tiles that are currently above water or at water level
  // Must be adjacent to land or settlement
  if tile.height <= sea_level {
    // Placing on water - need adjacent land
    return has_adjacent_land(grid, x, y, sea_level)
  }
  // Already above water - raising height is fine
  true
}

///|
fn has_adjacent_land(
  grid : @types.Grid,
  x : Int,
  y : Int,
  sea_level : Int,
) -> Bool {
  let dirs : Array[(Int, Int)] = [(-1, 0), (1, 0), (0, -1), (0, 1)]
  for i in 0..<dirs.length() {
    let (dx, dy) = dirs[i]
    let nx = x + dx
    let ny = y + dy
    if @types.grid_in_bounds(grid, nx, ny) {
      let neighbor = @types.grid_get(grid, nx, ny)
      if neighbor.height > sea_level {
        return true
      }
    }
  }
  false
}

///|
pub fn place_sand(
  grid : @types.Grid,
  x : Int,
  y : Int,
  sea_level : Int,
) -> Bool {
  if !can_place_sand(grid, x, y, sea_level) {
    return false
  }
  let idx = @types.grid_index(grid, x, y)
  let tile = grid.tiles[idx]
  if tile.height <= sea_level {
    // Raise to just above current sea level
    tile.height = sea_level + 1
  } else {
    // Raise by 1
    tile.height += 1
  }
  tile.is_sand = true
  true
}

///|
pub fn valid_placements(
  grid : @types.Grid,
  sea_level : Int,
) -> Array[(Int, Int)] {
  let result : Array[(Int, Int)] = []
  for y in 0..<grid.height {
    for x in 0..<grid.width {
      if can_place_sand(grid, x, y, sea_level) {
        result.push((x, y))
      }
    }
  }
  result
}

///|
pub fn count_land_tiles(grid : @types.Grid, sea_level : Int) -> Int {
  let mut count = 0
  for i in 0..<grid.tiles.length() {
    if grid.tiles[i].height > sea_level {
      count += 1
    }
  }
  count
}
