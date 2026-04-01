///|
/// Build target pattern by firing a solution grid, then return the fired colors.
fn build_target(glazes : Array[@types.GlazeColor]) -> Array[@types.FiredColor] {
  let grid = @types.new_grid()
  for i in 0..<@types.mini(glazes.length(), 36) {
    grid.cells[i].glaze = glazes[i]
  }
  @kiln.fire_grid(grid)
  let result : Array[@types.FiredColor] = []
  for i in 0..<grid.cells.length() {
    result.push(grid.cells[i].fired)
  }
  result
}

///|
/// Shorthand aliases for glaze colors used in level definitions.
let r : @types.GlazeColor = Red

///|
let b : @types.GlazeColor = Blue

///|
let g : @types.GlazeColor = Green

///|
let o : @types.GlazeColor = Gold

///|
let w : @types.GlazeColor = White

///|
let k : @types.GlazeColor = Black

///|
let e : @types.GlazeColor = Empty
