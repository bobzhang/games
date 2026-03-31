///|
/// Check if all targets on the grid are satisfied.
/// Updates target_satisfied field on each target tile.
/// Returns true if ALL targets are satisfied.
pub fn check_targets(grid : @types.WaveGrid) -> Bool {
  let mut all_ok = true
  for y in 0..<grid.height {
    for x in 0..<grid.width {
      let tile = @types.grid_get(grid, x, y)
      if tile.is_target {
        let amp_ok = tile.amplitude >= tile.target_min &&
          tile.amplitude <= tile.target_max
        let phase_ok = tile.target_phase < 0 ||
          tile.target_phase == tile.phase
        tile.target_satisfied = amp_ok && phase_ok
        if !tile.target_satisfied {
          all_ok = false
        }
      }
    }
  }
  all_ok
}

///|
/// Count total targets and how many are satisfied
pub fn count_targets(grid : @types.WaveGrid) -> (Int, Int) {
  let mut total = 0
  let mut satisfied = 0
  for y in 0..<grid.height {
    for x in 0..<grid.width {
      let tile = @types.grid_get(grid, x, y)
      if tile.is_target {
        total += 1
        if tile.target_satisfied {
          satisfied += 1
        }
      }
    }
  }
  (total, satisfied)
}
