///|
pub fn is_island_satisfied(
  islands : Array[@types.Island],
  bridges : Array[@types.Bridge],
  idx : Int,
) -> Bool {
  let count = @types.count_bridges_for_island(bridges, idx)
  count == islands[idx].required_count
}

///|
pub fn is_island_over(
  islands : Array[@types.Island],
  bridges : Array[@types.Bridge],
  idx : Int,
) -> Bool {
  let count = @types.count_bridges_for_island(bridges, idx)
  count > islands[idx].required_count
}

///|
pub fn all_islands_satisfied(
  islands : Array[@types.Island],
  bridges : Array[@types.Bridge],
) -> Bool {
  for i in 0..<islands.length() {
    if !is_island_satisfied(islands, bridges, i) {
      return false
    }
  }
  true
}

///|
pub fn has_crossing(
  islands : Array[@types.Island],
  bridges : Array[@types.Bridge],
) -> Bool {
  for i in 0..<bridges.length() {
    for j = i + 1; j < bridges.length(); j = j + 1 {
      if @types.bridges_cross(
          islands,
          bridges[i].island_a,
          bridges[i].island_b,
          bridges[j].island_a,
          bridges[j].island_b,
        ) {
        return true
      }
    }
  }
  false
}

///|
pub fn is_puzzle_solved(
  islands : Array[@types.Island],
  bridges : Array[@types.Bridge],
) -> Bool {
  if !all_islands_satisfied(islands, bridges) {
    return false
  }
  if has_crossing(islands, bridges) {
    return false
  }
  @types.is_connected(islands, bridges)
}

///|
pub fn satisfaction_counts(
  islands : Array[@types.Island],
  bridges : Array[@types.Bridge],
) -> (Int, Int) {
  let mut satisfied = 0
  let total = islands.length()
  for i in 0..<total {
    if is_island_satisfied(islands, bridges, i) {
      satisfied = satisfied + 1
    }
  }
  (satisfied, total)
}

///|
pub fn compute_stars(
  bridges : Array[@types.Bridge],
  par : Int,
  removals : Int,
) -> Int {
  let segments = @types.total_bridge_segments(bridges)
  let mut stars = 1 // Base: solved
  if segments <= par {
    stars = 2
    if removals == 0 {
      stars = 3
    }
  }
  stars
}
