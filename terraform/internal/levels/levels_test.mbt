///|
test "all 25 levels load without error" {
  for i in 0..<25 {
    let level = @levels.get_level(i)
    inspect(level.width > 0, content="true")
    inspect(level.height > 0, content="true")
    inspect(level.par_turns > 0, content="true")
  }
}

///|
test "tier 1 levels have correct tier" {
  for i in 0..<8 {
    let level = @levels.get_level(i)
    inspect(level.tier, content="Seeds")
    inspect(level.tier_index, content=i.to_string())
  }
}

///|
test "tier 2 levels have correct tier" {
  for i in 8..<17 {
    let level = @levels.get_level(i)
    inspect(level.tier, content="Balance")
  }
}

///|
test "tier 3 levels have correct tier" {
  for i in 17..<25 {
    let level = @levels.get_level(i)
    inspect(level.tier, content="Harmony")
  }
}

///|
test "all levels have valid starting tiles" {
  for i in 0..<25 {
    let level = @levels.get_level(i)
    for j in 0..<level.starting_tiles.length() {
      let (col, row, _biome, _locked) = level.starting_tiles[j]
      inspect(col >= 0 && col < level.width, content="true")
      inspect(row >= 0 && row < level.height, content="true")
    }
  }
}

///|
test "all levels have non-trivial budgets" {
  for i in 0..<25 {
    let level = @levels.get_level(i)
    let total = level.budget.forest + level.budget.ocean + level.budget.desert
    inspect(total > 0, content="true")
  }
}

///|
test "all levels have valid target ranges" {
  for i in 0..<25 {
    let level = @levels.get_level(i)
    let t = level.targets
    inspect(t.forest_min <= t.forest_max, content="true")
    inspect(t.ocean_min <= t.ocean_max, content="true")
    inspect(t.desert_min <= t.desert_max, content="true")
    inspect(t.forest_min >= 0.0, content="true")
    inspect(t.forest_max <= 1.0, content="true")
    inspect(t.ocean_min >= 0.0, content="true")
    inspect(t.ocean_max <= 1.0, content="true")
    inspect(t.desert_min >= 0.0, content="true")
    inspect(t.desert_max <= 1.0, content="true")
  }
}

///|
test "init_grid_from_level produces correct grid" {
  let level = @levels.get_level(0)
  let grid = @levels.init_grid_from_level(level)
  inspect(grid.width, content=level.width.to_string())
  inspect(grid.height, content=level.height.to_string())
  inspect(grid.wraps_horizontal, content="true")
  // Check that starting tiles are placed
  for j in 0..<level.starting_tiles.length() {
    let (col, row, biome, locked) = level.starting_tiles[j]
    let tile = @types.get_tile(grid, col, row)
    inspect(tile.biome == biome, content="true")
    inspect(tile.locked == locked, content="true")
  }
}

///|
test "tier 1 levels use smaller grids" {
  for i in 0..<8 {
    let level = @levels.get_level(i)
    // Tier 1 grids should be <= 12 wide and <= 6 tall
    inspect(level.width <= 12, content="true")
    inspect(level.height <= 6, content="true")
  }
}

///|
test "all level hints are non-empty" {
  for i in 0..<25 {
    let hint = @levels.get_level_hint(i)
    inspect(hint.length() > 0, content="true")
  }
}

///|
test "all level descriptions are non-empty" {
  for i in 0..<25 {
    let desc = @levels.get_level_description(i)
    inspect(desc.length() > 0, content="true")
  }
}

///|
test "level 0 starting state is correct" {
  let level = @levels.get_level(0)
  let grid = @levels.init_grid_from_level(level)
  // Level 0 starts with one ocean at (3,2)
  let tile = @types.get_tile(grid, 3, 2)
  inspect(tile.biome, content="Ocean")
  inspect(tile.locked, content="true")
  // Rest should be barren
  let barren = @types.count_biome(grid, Barren)
  inspect(barren, content="39") // 8*5 - 1 = 39
}

///|
test "locked tiles stay locked after grid init" {
  // Level 14 has locked desert tiles
  let level = @levels.get_level(14)
  let grid = @levels.init_grid_from_level(level)
  // Check a known locked tile
  for j in 0..<level.starting_tiles.length() {
    let (col, row, _biome, locked) = level.starting_tiles[j]
    let tile = @types.get_tile(grid, col, row)
    inspect(tile.locked == locked, content="true")
  }
}

// ============================================================
// Level balance verification tests
// ============================================================

///|
test "budget should not exceed grid size for any level" {
  for i in 0..<25 {
    let level = @levels.get_level(i)
    let total_cells = level.width * level.height
    let total_budget = level.budget.forest + level.budget.ocean + level.budget.desert
    // Budget should be less than grid size (you can't paint more tiles than exist)
    inspect(total_budget < total_cells, content="true")
  }
}

///|
test "difficulty progression: tier 1 budgets are more generous per cell" {
  // Tier 1 should have higher budget-to-cell ratios than tier 3
  let mut tier1_ratio : Float = 0.0
  for i in 0..<8 {
    let level = @levels.get_level(i)
    let total_cells = level.width * level.height
    let total_budget = level.budget.forest + level.budget.ocean + level.budget.desert
    tier1_ratio = tier1_ratio + Float::from_int(total_budget) / Float::from_int(
        total_cells,
      )
  }
  tier1_ratio = tier1_ratio / 8.0
  let mut tier3_ratio : Float = 0.0
  for i in 17..<25 {
    let level = @levels.get_level(i)
    let total_cells = level.width * level.height
    let total_budget = level.budget.forest + level.budget.ocean + level.budget.desert
    tier3_ratio = tier3_ratio + Float::from_int(total_budget) / Float::from_int(
        total_cells,
      )
  }
  tier3_ratio = tier3_ratio / 8.0
  // Tier 1 should have more generous budgets per cell than tier 3
  inspect(tier1_ratio > tier3_ratio, content="true")
}

///|
test "difficulty progression: tier 3 targets are tighter than tier 1" {
  // Tier 3 target ranges should be narrower on average
  let mut tier1_range : Float = 0.0
  for i in 0..<8 {
    let level = @levels.get_level(i)
    let t = level.targets
    tier1_range = tier1_range + (t.forest_max - t.forest_min) + (t.ocean_max -
      t.ocean_min) + (t.desert_max - t.desert_min)
  }
  tier1_range = tier1_range / 8.0
  let mut tier3_range : Float = 0.0
  for i in 17..<25 {
    let level = @levels.get_level(i)
    let t = level.targets
    tier3_range = tier3_range + (t.forest_max - t.forest_min) + (t.ocean_max -
      t.ocean_min) + (t.desert_max - t.desert_min)
  }
  tier3_range = tier3_range / 8.0
  // Tier 1 average target range should be wider
  inspect(tier1_range > tier3_range, content="true")
}

///|
test "difficulty progression: tier 2 grids are larger than tier 1" {
  let mut tier1_size = 0
  for i in 0..<8 {
    let level = @levels.get_level(i)
    tier1_size += level.width * level.height
  }
  let mut tier2_size = 0
  for i in 8..<17 {
    let level = @levels.get_level(i)
    tier2_size += level.width * level.height
  }
  // Tier 2 average grid size should be >= tier 1
  inspect(tier2_size / 9 >= tier1_size / 8, content="true")
}

///|
test "par turns scale with grid complexity" {
  // Larger grids with more starting obstacles should have more par turns
  for i in 0..<25 {
    let level = @levels.get_level(i)
    let total_budget = level.budget.forest + level.budget.ocean + level.budget.desert
    // Par turns should be >= total budget (you need at least 1 turn per paint)
    inspect(level.par_turns >= total_budget, content="true")
  }
}

///|
test "target ranges have achievable middle ground" {
  // For each level, the target range should not be impossibly narrow
  // (min+max)/2 should leave some room
  for i in 0..<25 {
    let level = @levels.get_level(i)
    let t = level.targets
    let forest_range = t.forest_max - t.forest_min
    let ocean_range = t.ocean_max - t.ocean_min
    let desert_range = t.desert_max - t.desert_min
    // Each range should be at least 4% (0.04) wide
    inspect(forest_range >= 0.04, content="true")
    inspect(ocean_range >= 0.04, content="true")
    inspect(desert_range >= 0.04, content="true")
  }
}

///|
test "starting tiles don't overlap" {
  for i in 0..<25 {
    let level = @levels.get_level(i)
    // Check no two starting tiles share the same position
    for j in 0..<level.starting_tiles.length() {
      let (c1, r1, _, _) = level.starting_tiles[j]
      for k in (j + 1)..<level.starting_tiles.length() {
        let (c2, r2, _, _) = level.starting_tiles[k]
        let same = c1 == c2 && r1 == r2
        inspect(same, content="false")
      }
    }
  }
}

///|
test "combined target mins do not exceed 100%" {
  for i in 0..<25 {
    let level = @levels.get_level(i)
    let t = level.targets
    // The sum of all minimum ratios should not exceed 1.0
    // (since barren fills the rest)
    let total_min = t.forest_min + t.ocean_min + t.desert_min
    inspect(total_min <= 1.0, content="true")
  }
}
