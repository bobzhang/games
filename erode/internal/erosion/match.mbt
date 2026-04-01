///|
/// Compare the current grid to the target grid.
/// Returns a MatchResult with counts of matching, over-eroded, and under-eroded cells.
pub fn compare_grids(
  current : @types.Grid,
  target : @types.Grid
) -> @types.MatchResult {
  let size = current.size
  let mut matching = 0
  let mut over_eroded = 0
  let mut under_eroded = 0
  let mut total_target_empty = 0
  let mut total_target_solid = 0
  for i in 0..<(size * size) {
    let cur = current.cells[i]
    let tgt = target.cells[i]
    if tgt {
      total_target_solid += 1
    } else {
      total_target_empty += 1
    }
    if cur == tgt {
      matching += 1
    } else if tgt && !cur {
      // Target wants solid, but we eroded it away
      over_eroded += 1
    } else {
      // Target wants empty, but it is still solid
      under_eroded += 1
    }
  }
  {
    matching,
    over_eroded,
    under_eroded,
    total_target_empty,
    total_target_solid,
  }
}

///|
/// Check if the current grid perfectly matches the target.
pub fn is_perfect_match(
  current : @types.Grid,
  target : @types.Grid
) -> Bool {
  @types.grids_match(current, target)
}

///|
/// Calculate match percentage (0-100).
pub fn match_percentage(
  current : @types.Grid,
  target : @types.Grid
) -> Int {
  let result = compare_grids(current, target)
  let total = result.matching + result.over_eroded + result.under_eroded
  if total == 0 {
    100
  } else {
    result.matching * 100 / total
  }
}

///|
/// Calculate stars for a completed level.
/// 1 star: match target
/// 2 stars: within par forces
/// 3 stars: par + no over-erosion
pub fn calculate_stars(
  current : @types.Grid,
  target : @types.Grid,
  forces_used : Int,
  par_forces : Int
) -> Int {
  let result = compare_grids(current, target)
  if result.under_eroded > 0 || result.over_eroded > 0 {
    // Not a match at all
    0
  } else if forces_used > par_forces {
    // Matched but used too many forces
    1
  } else if result.over_eroded > 0 {
    // Within par but had over-erosion
    2
  } else {
    // Perfect: matched, within par, no over-erosion
    3
  }
}

///|
/// Check if the player has used up all budget and grid does not match target.
pub fn is_stuck(
  current : @types.Grid,
  target : @types.Grid,
  budget : @types.ForceBudget
) -> Bool {
  let total_remaining = budget.water + budget.wind + budget.frost + budget.heat
  if total_remaining > 0 {
    return false
  }
  // No budget left, check if we match
  !@types.grids_match(current, target)
}
