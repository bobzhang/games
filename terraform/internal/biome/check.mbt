///|
/// Check if current biome ratios meet the target ratios.
pub fn check_targets(
  grid : @types.HexGrid,
  targets : @types.TargetRatio,
) -> Bool {
  let forest_r = @types.biome_ratio(grid, Forest)
  let ocean_r = @types.biome_ratio(grid, Ocean)
  let desert_r = @types.biome_ratio(grid, Desert)
  forest_r >= targets.forest_min &&
  forest_r <= targets.forest_max &&
  ocean_r >= targets.ocean_min &&
  ocean_r <= targets.ocean_max &&
  desert_r >= targets.desert_min &&
  desert_r <= targets.desert_max
}

///|
/// Get ratio status for each biome: -1 = below min, 0 = in range, 1 = above max.
pub fn ratio_status(
  grid : @types.HexGrid,
  targets : @types.TargetRatio,
) -> (Int, Int, Int) {
  let forest_r = @types.biome_ratio(grid, Forest)
  let ocean_r = @types.biome_ratio(grid, Ocean)
  let desert_r = @types.biome_ratio(grid, Desert)
  let fs = if forest_r < targets.forest_min {
    -1
  } else if forest_r > targets.forest_max {
    1
  } else {
    0
  }
  let os = if ocean_r < targets.ocean_min {
    -1
  } else if ocean_r > targets.ocean_max {
    1
  } else {
    0
  }
  let ds = if desert_r < targets.desert_min {
    -1
  } else if desert_r > targets.desert_max {
    1
  } else {
    0
  }
  (fs, os, ds)
}

///|
/// Check if the player has failed (no budget remaining and targets not met,
/// and no more ecosystem changes possible).
pub fn check_failure(
  grid : @types.HexGrid,
  budget : @types.PaintBudget,
  targets : @types.TargetRatio,
) -> Bool {
  if check_targets(grid, targets) {
    return false
  }
  // If budget remains, not failed yet
  if @types.total_budget(budget) > 0 {
    return false
  }
  // Try one more resolve to see if anything changes
  let test_grid = @types.clone_grid(grid)
  let changed = resolve_ecosystem(test_grid)
  let mut any_change = false
  for i in 0..<changed.length() {
    if changed[i] {
      any_change = true
      break
    }
  }
  // If ecosystem still changing, not failed
  if any_change {
    return false
  }
  // No budget, no changes, targets not met = fail
  true
}

///|
/// Calculate star rating:
/// 1 star: achieved targets
/// 2 stars: achieved within par turns
/// 3 stars: achieved with paints remaining
pub fn calculate_stars(
  grid : @types.HexGrid,
  targets : @types.TargetRatio,
  budget : @types.PaintBudget,
  turns : Int,
  par : Int,
) -> Int {
  if !check_targets(grid, targets) {
    return 0
  }
  let mut stars = 1
  if turns <= par {
    stars = 2
  }
  if @types.total_budget(budget) > 0 && turns <= par {
    stars = 3
  }
  stars
}
