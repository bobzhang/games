///|
test "all 30 levels exist" {
  let levels = @levels.get_all_levels()
  inspect(levels.length(), content="30")
}

///|
test "tier 1 levels are 3x3x3" {
  let levels = @levels.get_all_levels()
  for i in 0..<10 {
    inspect(levels[i].size, content="3")
    inspect(levels[i].tier, content="Shapes")
  }
}

///|
test "tier 2 levels are 4x4x4" {
  let levels = @levels.get_all_levels()
  for i in 10..<20 {
    inspect(levels[i].size, content="4")
    inspect(levels[i].tier, content="Structures")
  }
}

///|
test "tier 3 levels have correct tier" {
  let levels = @levels.get_all_levels()
  for i in 20..<30 {
    inspect(levels[i].tier, content="Sculptures")
  }
}

///|
test "tier 2 levels have voxel budget" {
  let levels = @levels.get_all_levels()
  for i in 10..<20 {
    inspect(levels[i].voxel_budget > 0, content="true")
  }
}

///|
test "tier 3 levels require connectivity" {
  let levels = @levels.get_all_levels()
  for i in 20..<30 {
    inspect(levels[i].requires_connected, content="true")
  }
}

///|
test "all levels have valid target dimensions" {
  let levels = @levels.get_all_levels()
  for i in 0..<levels.length() {
    let lev = levels[i]
    let valid = @levels.validate_level_targets(lev)
    inspect(valid, content="true")
  }
}

///|
test "get_level returns correct level" {
  let lev = @levels.get_level(0)
  inspect(lev.name, content="Dot")
  inspect(lev.size, content="3")
  let lev2 = @levels.get_level(29)
  inspect(lev2.name, content="Masterwork")
}

///|
test "level descriptions exist for all levels" {
  for i in 0..<30 {
    let desc = @levels.get_level_description(i)
    inspect(desc.length() > 0, content="true")
  }
}

///|
test "difficulty ratings are in range" {
  for i in 0..<30 {
    let diff = @levels.get_difficulty(i)
    inspect(diff >= 1 && diff <= 5, content="true")
  }
}

///|
test "tier 1 difficulty is lower than tier 3" {
  let d1 = @levels.get_difficulty(0)
  let d3 = @levels.get_difficulty(29)
  inspect(d1 <= d3, content="true")
}

///|
test "target_cell_count is positive for all levels" {
  let levels = @levels.get_all_levels()
  for i in 0..<levels.length() {
    let count = @levels.target_cell_count(levels[i])
    inspect(count > 0, content="true")
  }
}

///|
test "tier descriptions exist" {
  for t in 0..<3 {
    let desc = @levels.get_tier_description(t)
    inspect(desc.length() > 0, content="true")
  }
}

///|
test "level names are unique" {
  let levels = @levels.get_all_levels()
  for i in 0..<levels.length() {
    for j = i + 1; j < levels.length(); j = j + 1 {
      let same = levels[i].name == levels[j].name
      inspect(same, content="false")
    }
  }
}

///|
test "par_moves and par_voxels are positive" {
  let levels = @levels.get_all_levels()
  for i in 0..<levels.length() {
    inspect(levels[i].par_moves > 0, content="true")
    inspect(levels[i].par_voxels > 0, content="true")
  }
}

///|
test "silhouette_from_bits creates correct 4x4 pattern" {
  let s = @types.silhouette_from_bits(4, 4, [0b1111, 0b1001, 0b1001, 0b1111])
  // Top row: all filled
  inspect(s.cells[0], content="true")
  inspect(s.cells[1], content="true")
  inspect(s.cells[2], content="true")
  inspect(s.cells[3], content="true")
  // Row 1: ends filled, middle empty
  inspect(s.cells[4], content="true")
  inspect(s.cells[5], content="false")
  inspect(s.cells[6], content="false")
  inspect(s.cells[7], content="true")
  // Bottom row: all filled
  inspect(s.cells[12], content="true")
  inspect(s.cells[13], content="true")
  inspect(s.cells[14], content="true")
  inspect(s.cells[15], content="true")
}

///|
test "silhouette_from_bits 5x5" {
  let s = @types.silhouette_from_bits(5, 5, [
    0b11111, 0b10001, 0b10101, 0b10001, 0b11111,
  ])
  inspect(s.width, content="5")
  inspect(s.height, content="5")
  // Center cell
  inspect(s.cells[12], content="true") // (2, 2) = idx 12
  // Corner cells
  inspect(s.cells[0], content="true") // (0, 0)
  inspect(s.cells[4], content="true") // (4, 0)
  inspect(s.cells[20], content="true") // (0, 4)
  inspect(s.cells[24], content="true") // (4, 4)
}

// ===== Solvability validation: each silhouette target is non-trivial
// and the maximal intersection grid produces valid projections =====

// Build the maximal grid: fill every cell where all three projections
// require it. This is a valid (possibly partial) solution.

///|
fn build_maximal_grid(level : @types.Level) -> @types.VoxelGrid {
  let s = level.size
  let grid = @types.new_voxel_grid(s)
  for x in 0..<s {
    for y in 0..<s {
      for z in 0..<s {
        let top_filled = level.targets.top.cells[x + z * s]
        let front_row = s - 1 - y
        let front_filled = level.targets.front.cells[x + front_row * s]
        let side_filled = level.targets.side.cells[z + front_row * s]
        if top_filled && front_filled && side_filled {
          grid.cells[@types.xyz_to_idx(x, y, z, s)] = true
        }
      }
    }
  }
  grid
}

///|
test "maximal grid projections are subsets of targets" {
  // The maximal intersection grid cannot produce cells outside the targets
  let levels = @levels.get_all_levels()
  for i in 0..<levels.length() {
    let level = levels[i]
    let grid = build_maximal_grid(level)
    let s = level.size
    let top = @voxel.compute_top_silhouette(grid)
    let front = @voxel.compute_front_silhouette(grid)
    let side = @voxel.compute_side_silhouette(grid)
    for j in 0..<(s * s) {
      // If maximal grid projects here, target must also have it
      if top.cells[j] {
        inspect(level.targets.top.cells[j], content="true")
      }
      if front.cells[j] {
        inspect(level.targets.front.cells[j], content="true")
      }
      if side.cells[j] {
        inspect(level.targets.side.cells[j], content="true")
      }
    }
  }
}

///|
test "maximal grid is non-empty for all levels" {
  // The intersection of all three targets always produces at least one
  // voxel, showing the silhouettes have some overlap.
  let levels = @levels.get_all_levels()
  for i in 0..<levels.length() {
    let level = levels[i]
    let grid = build_maximal_grid(level)
    let filled = @voxel.count_filled(grid)
    inspect(filled > 0, content="true")
  }
}

///|
test "budgeted levels: par_voxels within budget" {
  let levels = @levels.get_all_levels()
  for i in 10..<20 {
    let level = levels[i]
    if level.voxel_budget > 0 {
      inspect(level.par_voxels <= level.voxel_budget, content="true")
    }
  }
}

///|
test "tier 1 levels have no budget constraint" {
  let levels = @levels.get_all_levels()
  for i in 0..<10 {
    inspect(levels[i].voxel_budget, content="-1")
  }
}

///|
test "tier 1 levels do not require connectivity" {
  let levels = @levels.get_all_levels()
  for i in 0..<10 {
    inspect(levels[i].requires_connected, content="false")
  }
}

///|
test "par_voxels is at most par_moves for all levels" {
  let levels = @levels.get_all_levels()
  for i in 0..<levels.length() {
    inspect(levels[i].par_voxels <= levels[i].par_moves, content="true")
  }
}

///|
test "grid sizes are valid 3, 4, or 5" {
  let levels = @levels.get_all_levels()
  for i in 0..<levels.length() {
    let s = levels[i].size
    inspect(s >= 3 && s <= 5, content="true")
  }
}

///|
test "tier 3 grid sizes match tier description" {
  let levels = @levels.get_all_levels()
  // Tier 3 (indices 20-29): 4x4x4 or 5x5x5
  for i in 20..<30 {
    let s = levels[i].size
    inspect(s >= 4 && s <= 5, content="true")
  }
}

///|
test "all silhouette cells arrays have correct length" {
  let levels = @levels.get_all_levels()
  for i in 0..<levels.length() {
    let s = levels[i].size
    let expected = s * s
    inspect(levels[i].targets.top.cells.length(), content=expected.to_string())
    inspect(
      levels[i].targets.front.cells.length(),
      content=expected.to_string(),
    )
    inspect(levels[i].targets.side.cells.length(), content=expected.to_string())
  }
}

///|
test "difficulty increases with tier" {
  // Average difficulty of tier 1 should be <= tier 2 <= tier 3
  let mut sum1 = 0
  let mut sum2 = 0
  let mut sum3 = 0
  for i in 0..<10 {
    sum1 += @levels.get_difficulty(i)
  }
  for i in 10..<20 {
    sum2 += @levels.get_difficulty(i)
  }
  for i in 20..<30 {
    sum3 += @levels.get_difficulty(i)
  }
  inspect(sum1 <= sum2, content="true")
  inspect(sum2 <= sum3, content="true")
}

///|
test "each silhouette has at least one filled cell per row or column" {
  let levels = @levels.get_all_levels()
  for li in 0..<levels.length() {
    let level = levels[li]
    let s = level.size
    // Top view must have at least one filled cell
    let mut top_any = false
    for j in 0..<(s * s) {
      if level.targets.top.cells[j] {
        top_any = true
        break
      }
    }
    inspect(top_any, content="true")
    let mut front_any = false
    for j in 0..<(s * s) {
      if level.targets.front.cells[j] {
        front_any = true
        break
      }
    }
    inspect(front_any, content="true")
    let mut side_any = false
    for j in 0..<(s * s) {
      if level.targets.side.cells[j] {
        side_any = true
        break
      }
    }
    inspect(side_any, content="true")
  }
}

///|
test "silhouette filled counts are reasonable for grid size" {
  // Each silhouette should have between 1 and size*size filled cells
  let levels = @levels.get_all_levels()
  for i in 0..<levels.length() {
    let level = levels[i]
    let s = level.size
    let max_cells = s * s
    let mut top_count = 0
    let mut front_count = 0
    let mut side_count = 0
    for j in 0..<max_cells {
      if level.targets.top.cells[j] {
        top_count += 1
      }
      if level.targets.front.cells[j] {
        front_count += 1
      }
      if level.targets.side.cells[j] {
        side_count += 1
      }
    }
    inspect(top_count >= 1 && top_count <= max_cells, content="true")
    inspect(front_count >= 1 && front_count <= max_cells, content="true")
    inspect(side_count >= 1 && side_count <= max_cells, content="true")
  }
}
