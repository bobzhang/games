///|
/// Brute-force solver: tries all possible placements of remaining features.
/// Returns all valid solutions (complete grids where all clues are satisfied).
/// Stops early after finding `max_solutions` to avoid exhaustive search.
pub fn solve(
  grid : Array[@types.FeatureKind?],
  size : Int,
  features_to_place : Array[@types.FeatureKind],
  clues : Array[@types.Clue],
  max_solutions~ : Int = 2
) -> Array[Array[@types.FeatureKind?]] {
  let solutions : Array[Array[@types.FeatureKind?]] = []
  let needed = get_needed_features(grid, features_to_place)
  if needed.length() == 0 {
    // All placed, check if all clues satisfied
    validate_all_clues(clues, grid, size)
    if all_clues_satisfied(clues) {
      let copy : Array[@types.FeatureKind?] = Array::make(grid.length(), None)
      for i in 0..<grid.length() {
        copy[i] = grid[i]
      }
      solutions.push(copy)
    }
    return solutions
  }
  solve_recursive(grid, size, needed, 0, clues, solutions, max_solutions)
  solutions
}

///|
fn solve_recursive(
  grid : Array[@types.FeatureKind?],
  size : Int,
  needed : Array[@types.FeatureKind],
  idx : Int,
  clues : Array[@types.Clue],
  solutions : Array[Array[@types.FeatureKind?]],
  max_solutions : Int
) -> Unit {
  if solutions.length() >= max_solutions {
    return
  }
  if idx >= needed.length() {
    // All features placed, check clues
    validate_all_clues(clues, grid, size)
    if all_clues_satisfied(clues) {
      let copy : Array[@types.FeatureKind?] = Array::make(grid.length(), None)
      for i in 0..<grid.length() {
        copy[i] = grid[i]
      }
      solutions.push(copy)
    }
    return
  }
  let feature = needed[idx]
  for cell in 0..<(size * size) {
    if solutions.length() >= max_solutions {
      return
    }
    match grid[cell] {
      Some(_) => continue
      None => {
        let pos = @types.index_to_pos(cell, size)
        if check_placement_consistent(grid, size, clues, pos, feature) {
          grid[cell] = Some(feature)
          solve_recursive(
            grid, size, needed, idx + 1, clues, solutions, max_solutions,
          )
          grid[cell] = None
        }
      }
    }
  }
}

///|
/// Count the number of valid solutions for a level (up to max_solutions).
pub fn count_solutions(
  size : Int,
  features_to_place : Array[@types.FeatureKind],
  clues : Array[@types.Clue],
  max_solutions~ : Int = 2
) -> Int {
  let grid : Array[@types.FeatureKind?] = Array::make(size * size, None)
  let solutions = solve(
    grid, size, features_to_place, clues, max_solutions~,
  )
  // Reset clue statuses
  for i in 0..<clues.length() {
    clues[i].status = Pending
  }
  solutions.length()
}
