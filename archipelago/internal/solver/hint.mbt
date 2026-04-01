///|
pub fn find_forced_bridge(
  islands : Array[@types.Island],
  bridges : Array[@types.Bridge],
) -> (Int, Int) {
  // For each unsatisfied island, check if it has only enough possible
  // connections to exactly meet its requirement
  for i in 0..<islands.length() {
    let current = @types.count_bridges_for_island(bridges, i)
    let needed = islands[i].required_count - current
    if needed <= 0 {
      continue
    }
    // Find all possible neighbors for this island
    let possible : Array[(Int, Int)] = [] // (neighbor_idx, max_additional)
    for j in 0..<islands.length() {
      if i == j {
        continue
      }
      if !@types.can_connect(islands, i, j) {
        continue
      }
      if @types.has_island_between(islands, i, j) {
        continue
      }
      if @types.would_cross_existing(islands, bridges, i, j) {
        continue
      }
      let existing = @types.find_bridge(bridges, i, j)
      let current_count = if existing >= 0 {
        bridges[existing].count
      } else {
        0
      }
      let can_add = 2 - current_count
      if can_add > 0 {
        possible.push((j, can_add))
      }
    }
    // If total possible == needed, all are forced
    let mut total_possible = 0
    for p in possible {
      total_possible = total_possible + p.1
    }
    if total_possible == needed && possible.length() > 0 {
      // Return the first possible connection
      return (i, possible[0].0)
    }
    // If an island needs N and only one neighbor can provide, that's forced
    if possible.length() == 1 {
      return (i, possible[0].0)
    }
  }
  (-1, -1)
}

///|
pub fn find_hint(
  islands : Array[@types.Island],
  bridges : Array[@types.Bridge],
) -> (Int, Int) {
  // First try forced bridges
  let (a, b) = find_forced_bridge(islands, bridges)
  if a >= 0 {
    return (a, b)
  }
  // Fallback: find any unsatisfied island with a valid connection
  for i in 0..<islands.length() {
    let current = @types.count_bridges_for_island(bridges, i)
    if current >= islands[i].required_count {
      continue
    }
    for j in 0..<islands.length() {
      if i == j {
        continue
      }
      if !@types.can_connect(islands, i, j) {
        continue
      }
      if @types.has_island_between(islands, i, j) {
        continue
      }
      if @types.would_cross_existing(islands, bridges, i, j) {
        continue
      }
      let existing = @types.find_bridge(bridges, i, j)
      let current_count = if existing >= 0 {
        bridges[existing].count
      } else {
        0
      }
      if current_count < 2 {
        return (i, j)
      }
    }
  }
  (-1, -1)
}
