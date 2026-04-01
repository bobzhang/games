///|
/// Get all neighbors that are in-bounds
pub fn valid_neighbors(col : Int, row : Int) -> Array[(Int, Int)] {
  let all = @types.hex_neighbors(col, row)
  let result : Array[(Int, Int)] = []
  for i in 0..<all.length() {
    let (c, r) = all[i]
    if @types.hex_in_bounds(c, r) {
      result.push((c, r))
    }
  }
  result
}

///|
/// Get a ring of hexes at a given distance
pub fn hex_ring(
  center_col : Int,
  center_row : Int,
  radius : Int,
) -> Array[(Int, Int)] {
  let result : Array[(Int, Int)] = []
  if radius == 0 {
    result.push((center_col, center_row))
    return result
  }
  for r in 0..<@types.grid_rows {
    for c in 0..<@types.grid_cols {
      if @types.hex_distance(center_col, center_row, c, r) == radius {
        result.push((c, r))
      }
    }
  }
  result
}

///|
/// Check if a hex coordinate is adjacent to another
pub fn is_adjacent(c1 : Int, r1 : Int, c2 : Int, r2 : Int) -> Bool {
  @types.hex_distance(c1, r1, c2, r2) == 1
}

///|
/// Get all tiles adjacent to given tile that match a predicate
pub fn adjacent_matching(
  grid : @types.HexGrid,
  col : Int,
  row : Int,
  pred : (@types.HexTile) -> Bool,
) -> Array[(Int, Int)] {
  let neighbors = valid_neighbors(col, row)
  let result : Array[(Int, Int)] = []
  for i in 0..<neighbors.length() {
    let (c, r) = neighbors[i]
    if pred(grid.tiles[r][c]) {
      result.push((c, r))
    }
  }
  result
}

///|
/// Count adjacent tiles matching a predicate
pub fn count_adjacent_matching(
  grid : @types.HexGrid,
  col : Int,
  row : Int,
  pred : (@types.HexTile) -> Bool,
) -> Int {
  adjacent_matching(grid, col, row, pred).length()
}

///|
/// Get all tiles that can receive water flow from a source tile
/// Water flows to neighbors with lower or equal height (equal only with channel)
pub fn water_flow_targets(
  grid : @types.HexGrid,
  col : Int,
  row : Int,
) -> Array[(Int, Int)] {
  let src = grid.tiles[row][col]
  let neighbors = valid_neighbors(col, row)
  let result : Array[(Int, Int)] = []
  for i in 0..<neighbors.length() {
    let (c, r) = neighbors[i]
    let dst = grid.tiles[r][c]
    match dst.kind {
      Rock => ()
      _ =>
        if dst.height < src.height {
          result.push((c, r))
        } else if dst.height == src.height &&
          (dst.has_channel || src.has_channel) {
          result.push((c, r))
        }
    }
  }
  result
}

///|
/// Get screen position for drawing hex center
pub fn hex_screen_pos(col : Int, row : Int) -> (Float, Float) {
  (@types.hex_to_pixel_x(col, row), @types.hex_to_pixel_y(col~, row))
}

///|
/// Hit test - which hex is the mouse over?
pub fn hex_at_screen(px : Float, py : Float) -> (Int, Int) {
  @types.pixel_to_hex(px, py)
}

///|
/// Get the 6 corner points of a flat-top hexagon centered at (cx, cy)
pub fn hex_corners(
  cx : Float,
  cy : Float,
  size : Float,
) -> Array[(Float, Float)] {
  let corners : Array[(Float, Float)] = Array::new(capacity=6)
  for i in 0..<6 {
    let angle = @types.pi / 3.0 * Float::from_int(i) + @types.pi / 6.0
    let px = cx + size * @types.cosf(angle)
    let py = cy + size * @types.sinf(angle)
    corners.push((px, py))
  }
  corners
}
