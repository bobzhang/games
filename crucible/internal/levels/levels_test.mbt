///|
test "all 25 levels are valid" {
  for i in 0..<25 {
    let level = get_level(i)
    // Target should be a non-base element (except for some apprentice levels
    // where base combos produce compound elements)
    let _target = @types.element_name(level.target)
    // Par steps should be positive
    assert_true(level.par_steps > 0)
    // Hint should not be empty
    assert_true(level.hint.length() > 0)
  }
}

///|
test "tier levels have correct count" {
  let apprentice = get_tier_levels(@types.Apprentice)
  assert_eq(apprentice.length(), 8)
  let journeyman = get_tier_levels(@types.Journeyman)
  assert_eq(journeyman.length(), 9)
  let master = get_tier_levels(@types.Master)
  assert_eq(master.length(), 8)
}

///|
test "apprentice levels have tier Apprentice" {
  for i in 0..<8 {
    let level = get_level(i)
    assert_eq(level.tier, @types.Apprentice)
  }
}

///|
test "journeyman levels have tier Journeyman" {
  for i in 8..<17 {
    let level = get_level(i)
    assert_eq(level.tier, @types.Journeyman)
  }
}

///|
test "master levels have tier Master" {
  for i in 17..<25 {
    let level = get_level(i)
    assert_eq(level.tier, @types.Master)
  }
}

///|
test "first tier always unlocked" {
  let scores : Array[@types.LevelScore] = []
  for _i in 0..<25 {
    scores.push(@types.new_level_score())
  }
  assert_eq(is_tier_unlocked(@types.Apprentice, scores), true)
  assert_eq(is_tier_unlocked(@types.Journeyman, scores), false)
  assert_eq(is_tier_unlocked(@types.Master, scores), false)
}

///|
test "journeyman unlocks after 5 apprentice levels" {
  let scores : Array[@types.LevelScore] = []
  for _i in 0..<25 {
    scores.push(@types.new_level_score())
  }
  // Complete 5 apprentice levels
  for i in 0..<5 {
    scores[i].completed = true
  }
  assert_eq(is_tier_unlocked(@types.Journeyman, scores), true)
}

///|
test "all 25 levels have non-base target elements" {
  // Targets should be compound elements (not Fire/Water/Earth/Air/Light/Shadow)
  for i in 0..<25 {
    let level = get_level(i)
    inspect(@types.is_base_element(level.target), content="false")
  }
}

///|
test "all 25 levels have positive budget totals" {
  for i in 0..<25 {
    let level = get_level(i)
    let total = level.budget.fire + level.budget.water + level.budget.earth +
      level.budget.air + level.budget.light + level.budget.shadow
    assert_true(total > 0)
  }
}

///|
test "all budgets have non-negative values" {
  for i in 0..<25 {
    let level = get_level(i)
    assert_true(level.budget.fire >= 0)
    assert_true(level.budget.water >= 0)
    assert_true(level.budget.earth >= 0)
    assert_true(level.budget.air >= 0)
    assert_true(level.budget.light >= 0)
    assert_true(level.budget.shadow >= 0)
  }
}

///|
test "par steps at least 2 for all levels" {
  for i in 0..<25 {
    let level = get_level(i)
    assert_true(level.par_steps >= 2)
  }
}

///|
test "budget provides enough elements for par steps" {
  // Budget total should be >= par_steps (need at least 1 element per step)
  for i in 0..<25 {
    let level = get_level(i)
    let total = level.budget.fire + level.budget.water + level.budget.earth +
      level.budget.air + level.budget.light + level.budget.shadow
    assert_true(total >= level.par_steps)
  }
}

///|
test "steam targets have fire and water in budget" {
  for i in 0..<25 {
    let level = get_level(i)
    if level.target == @types.Steam {
      // Steam needs Fire+Water or Ice+Fire (Ice needs Air+Water)
      let has_fire = level.budget.fire > 0
      let has_water = level.budget.water > 0
      let has_air = level.budget.air > 0
      // Direct path: fire + water, or indirect: air+water->ice, ice+fire->steam
      assert_true(
        (has_fire && has_water) || (has_fire && has_air && has_water),
      )
    }
  }
}

///|
test "void targets have light and shadow in budget" {
  for i in 0..<25 {
    let level = get_level(i)
    if level.target == @types.Void {
      assert_true(level.budget.light > 0)
      assert_true(level.budget.shadow > 0)
    }
  }
}

///|
test "storm targets have required elements in budget" {
  for i in 0..<25 {
    let level = get_level(i)
    if level.target == @types.Storm {
      // Storm = Lightning + Water; Lightning = Fire + Air
      assert_true(level.budget.fire > 0)
      assert_true(level.budget.water > 0)
      assert_true(level.budget.air > 0)
    }
  }
}

///|
test "clay targets have required elements in budget" {
  for i in 0..<25 {
    let level = get_level(i)
    if level.target == @types.Clay {
      // Clay = Steam + Earth; Steam = Fire + Water
      assert_true(level.budget.fire > 0)
      assert_true(level.budget.water > 0)
      assert_true(level.budget.earth > 0)
    }
  }
}

///|
test "obsidian targets have required elements in budget" {
  for i in 0..<25 {
    let level = get_level(i)
    if level.target == @types.Obsidian {
      // Obsidian = Magma + Water; Magma = Fire + Earth
      assert_true(level.budget.fire > 0)
      assert_true(level.budget.water > 0)
      assert_true(level.budget.earth > 0)
    }
  }
}

///|
test "total levels constant matches actual count" {
  inspect(@types.total_levels, content="25")
  // Verify tier counts sum to total
  let sum = @types.tier_level_count(@types.Apprentice) +
    @types.tier_level_count(@types.Journeyman) +
    @types.tier_level_count(@types.Master)
  inspect(sum, content="25")
}

///|
test "master unlocks after 6 journeyman levels" {
  let scores : Array[@types.LevelScore] = []
  for _i in 0..<25 {
    scores.push(@types.new_level_score())
  }
  // Complete 5 apprentice (unlock journeyman) + 6 journeyman
  for i in 0..<5 {
    scores[i].completed = true
  }
  for i in 8..<14 {
    scores[i].completed = true
  }
  assert_eq(is_tier_unlocked(@types.Master, scores), true)
}

///|
test "master stays locked with only 5 journeyman levels" {
  let scores : Array[@types.LevelScore] = []
  for _i in 0..<25 {
    scores.push(@types.new_level_score())
  }
  for i in 8..<13 {
    scores[i].completed = true
  }
  assert_eq(is_tier_unlocked(@types.Master, scores), false)
}
