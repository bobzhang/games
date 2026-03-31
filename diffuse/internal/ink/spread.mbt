///|
let dir_dx : Array[Int] = [0, 0, -1, 1]

///|
let dir_dy : Array[Int] = [-1, 1, 0, 0]

///|
pub fn spread_once(grid : @types.Grid) -> @types.Grid {
  let w = grid.width
  let h = grid.height
  // Clone current state
  let new_tiles = @types.clone_tiles(grid.tiles)
  // For each tile, if it has ink, spread to adjacent paper/target tiles
  for row in 0..<h {
    for col in 0..<w {
      let src = @types.grid_get(grid, col, row)
      if @types.ink_is_empty(src.ink) {
        continue
      }
      // Spread to 4 neighbors
      for d in 0..<4 {
        let nc = col + dir_dx[d]
        let nr = row + dir_dy[d]
        if !@types.grid_in_bounds(grid, nc, nr) {
          continue
        }
        let neighbor = @types.grid_get(grid, nc, nr)
        if neighbor.kind == Barrier {
          continue
        }
        // Mix ink into neighbor in the new grid
        let ni = @types.grid_index(grid, nc, nr)
        let dest = new_tiles[ni]
        let mixed = @types.ink_mix(dest.ink, src.ink)
        dest.ink = { c: mixed.c, m: mixed.m, y: mixed.y }
      }
    }
  }
  { width: w, height: h, tiles: new_tiles }
}

///|
pub fn spread_n_turns(grid : @types.Grid, turns : Int) -> @types.Grid {
  let mut current = grid
  for i = 0; i < turns; i = i + 1 {
    current = spread_once(current)
  }
  current
}

///|
pub fn compute_preview(grid : @types.Grid) -> Array[Bool] {
  // Returns array of bools - which tiles would gain new ink or changed ink after 1 spread
  let next = spread_once(grid)
  let result : Array[Bool] = Array::make(grid.width * grid.height, false)
  for i in 0..<grid.tiles.length() {
    let old_ink = grid.tiles[i].ink
    let new_ink = next.tiles[i].ink
    if !@types.ink_equals(old_ink, new_ink) {
      result[i] = true
    }
  }
  result
}
