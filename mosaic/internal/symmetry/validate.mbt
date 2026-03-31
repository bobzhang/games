///|
pub fn validate_placement(
  grid : @types.MosaicGrid,
  pos : @types.Vec2i,
  tile : @types.Tile,
  sym : @types.SymmetryKind
) -> Bool {
  match sym {
    Rotate4 => {
      match get_expected_for_rotate4(grid, pos) {
        Some(expected) => @types.tile_eq(tile, expected)
        None => true
      }
    }
    _ => {
      match expected_tile_at(grid, pos, sym) {
        Some(expected) => @types.tile_eq(tile, expected)
        None => true
      }
    }
  }
}

///|
pub fn compute_solution_tile(
  grid : @types.MosaicGrid,
  hole : @types.Vec2i,
  sym : @types.SymmetryKind
) -> @types.Tile? {
  match sym {
    Rotate4 => get_expected_for_rotate4(grid, hole)
    _ => expected_tile_at(grid, hole, sym)
  }
}

///|
pub fn check_all_holes_filled(grid : @types.MosaicGrid) -> Bool {
  for i in 0..<grid.holes.length() {
    let h = grid.holes[i]
    match @types.get_tile(grid, h.x, h.y) {
      None => return false
      Some(_) => continue
    }
  }
  true
}

///|
pub fn check_all_correct(
  grid : @types.MosaicGrid,
  placed : Array[(@types.Vec2i, @types.Tile)],
  sym : @types.SymmetryKind
) -> Bool {
  for i in 0..<placed.length() {
    let (pos, tile) = placed[i]
    if !validate_placement(grid, pos, tile, sym) {
      return false
    }
  }
  true
}

///|
pub fn count_correct_placements(
  grid : @types.MosaicGrid,
  placed : Array[(@types.Vec2i, @types.Tile)],
  sym : @types.SymmetryKind
) -> Int {
  let mut correct = 0
  for i in 0..<placed.length() {
    let (pos, tile) = placed[i]
    if validate_placement(grid, pos, tile, sym) {
      correct = correct + 1
    }
  }
  correct
}
