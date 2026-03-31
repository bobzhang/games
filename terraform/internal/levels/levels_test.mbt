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
