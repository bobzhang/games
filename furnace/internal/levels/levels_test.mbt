///|
test "get_level returns valid levels" {
  for i in 0..<@types.total_levels {
    let level = @levels.get_level(i)
    assert_eq(level.id, i)
    assert_true(level.tier >= 1 && level.tier <= 3)
    assert_true(level.par_materials > 0)
    assert_true(level.par_turns > 0)
    assert_true(level.sources.length() > 0)
    assert_true(level.targets.length() > 0)
    assert_true(level.available_materials.length() > 0)
  }
}

///|
test "tier 1 levels use metal and stone" {
  for i in 0..<@types.tier1_count {
    let level = @levels.get_level(i)
    assert_eq(level.tier, 1)
    // Tier 1 should only have Metal and Stone
    for m = 0; m < level.available_materials.length(); m = m + 1 {
      let mat = level.available_materials[m]
      assert_true(mat == Metal || mat == Stone)
    }
  }
}

///|
test "tier 2 levels include wood and insulator" {
  let t1 = @types.tier1_count
  let t2 = @types.tier2_count
  for i = t1; i < t1 + t2; i = i + 1 {
    let level = @levels.get_level(i)
    assert_eq(level.tier, 2)
    assert_true(level.available_materials.length() >= 3)
  }
}

///|
test "tier 3 levels include glass" {
  let start = @types.tier1_count + @types.tier2_count
  let end = start + @types.tier3_count
  for i = start; i < end; i = i + 1 {
    let level = @levels.get_level(i)
    assert_eq(level.tier, 3)
    // Should include glass
    let mut has_glass = false
    for m = 0; m < level.available_materials.length(); m = m + 1 {
      if level.available_materials[m] == Glass {
        has_glass = true
      }
    }
    assert_true(has_glass)
  }
}

///|
test "load_level sets up grid correctly" {
  let game = @types.new_game()
  @levels.load_level(game, 0)
  // Level 1: source at (0,0), target at (0,3)
  let source = game.grid.tiles[0][0]
  assert_true(
    match source.kind {
      HeatSource(_) => true
      _ => false
    },
  )
  assert_eq(source.locked, true)
  assert_eq(source.material, Metal)
  let target = game.grid.tiles[0][3]
  assert_true(
    match target.kind {
      Target(_, _) => true
      _ => false
    },
  )
}

///|
test "load_level resets grid first" {
  let game = @types.new_game()
  // Dirty the grid
  game.grid.tiles[5][5].material = Metal
  game.grid.tiles[5][5].temperature = 999.0
  @levels.load_level(game, 0)
  // Should be reset
  assert_eq(game.grid.tiles[5][5].material, Empty)
  assert_eq(game.grid.tiles[5][5].temperature, @types.ambient_temp)
}

///|
test "sources and targets within grid bounds" {
  for i in 0..<@types.total_levels {
    let level = @levels.get_level(i)
    for s = 0; s < level.sources.length(); s = s + 1 {
      assert_true(
        level.sources[s].0 >= 0 && level.sources[s].0 < @types.grid_size,
      )
      assert_true(
        level.sources[s].1 >= 0 && level.sources[s].1 < @types.grid_size,
      )
    }
    for t = 0; t < level.targets.length(); t = t + 1 {
      assert_true(
        level.targets[t].0 >= 0 && level.targets[t].0 < @types.grid_size,
      )
      assert_true(
        level.targets[t].1 >= 0 && level.targets[t].1 < @types.grid_size,
      )
    }
  }
}

///|
test "target temperature ranges are valid" {
  for i in 0..<@types.total_levels {
    let level = @levels.get_level(i)
    for t = 0; t < level.targets.length(); t = t + 1 {
      let lo = level.targets[t].2
      let hi = level.targets[t].3
      assert_true(lo < hi)
      assert_true(lo >= 0.0)
    }
  }
}

///|
test "level names are unique" {
  let names : Array[String] = []
  for i in 0..<@types.total_levels {
    let level = @levels.get_level(i)
    for n = 0; n < names.length(); n = n + 1 {
      assert_true(names[n] != level.name)
    }
    names.push(level.name)
  }
}
