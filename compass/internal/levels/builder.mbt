///|
pub fn make_ocean_grid() -> Array[Array[@types.Tile]] {
  let grid : Array[Array[@types.Tile]] = []
  for _y in 0..<@types.grid_rows {
    let row : Array[@types.Tile] = Array::make(@types.grid_cols, Ocean)
    grid.push(row)
  }
  grid
}

///|
pub fn set_tile(
  grid : Array[Array[@types.Tile]],
  x : Int,
  y : Int,
  tile : @types.Tile,
) -> Unit {
  grid[y][x] = tile
}

///|
pub fn set_land_rect(
  grid : Array[Array[@types.Tile]],
  x : Int,
  y : Int,
  w : Int,
  h : Int,
) -> Unit {
  for dy in 0..<h {
    for dx in 0..<w {
      grid[y + dy][x + dx] = Land
    }
  }
}

///|
pub fn count_landmarks(grid : Array[Array[@types.Tile]]) -> Int {
  let mut count = 0
  for row in grid {
    for tile in row {
      if tile is Landmark {
        count += 1
      }
    }
  }
  count
}
