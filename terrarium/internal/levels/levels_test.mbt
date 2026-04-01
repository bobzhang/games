///|
test "get_level_returns_correct_id" {
  for i in 0..<@types.total_levels {
    let level = get_level(i)
    assert_eq(level.id, i)
  }
}

///|
test "level_01_basic_properties" {
  let level = level_01()
  assert_eq(level.id, 0)
  assert_eq(level.name, "First Sprout")
  assert_eq(level.tier, Beginner)
  assert_true(level.available_organisms.length() > 0)
  assert_eq(level.available_organisms.length(), level.organism_counts.length())
}

///|
test "level_08_has_locked_cells" {
  let level = level_08()
  assert_eq(level.id, 7)
  assert_eq(level.tier, Intermediate)
  assert_true(level.locked_cells.length() > 0)
}

///|
test "level_20_is_advanced" {
  let level = level_20()
  assert_eq(level.id, 19)
  assert_eq(level.tier, Advanced)
  assert_true(level.locked_cells.length() > 0)
}

///|
test "all_levels_have_valid_organisms" {
  for i in 0..<@types.total_levels {
    let level = get_level(i)
    assert_true(level.available_organisms.length() > 0)
    assert_eq(
      level.available_organisms.length(), level.organism_counts.length(),
    )
    for j in 0..<level.organism_counts.length() {
      assert_true(level.organism_counts[j] > 0)
    }
  }
}

///|
test "all_levels_have_positive_resources" {
  for i in 0..<@types.total_levels {
    let level = get_level(i)
    let r = level.initial_resources
    assert_true(r.o2 > 0.0)
    assert_true(r.co2 > 0.0)
    assert_true(r.water > 0.0)
    assert_true(r.nutrients > 0.0)
  }
}

///|
test "get_tier_for_level_beginner" {
  for i in 0..<7 {
    assert_eq(get_tier_for_level(i), Beginner)
  }
}

///|
test "get_tier_for_level_intermediate" {
  for i in 7..<14 {
    assert_eq(get_tier_for_level(i), Intermediate)
  }
}

///|
test "get_tier_for_level_advanced" {
  for i in 14..<20 {
    assert_eq(get_tier_for_level(i), Advanced)
  }
}

///|
test "get_tier_start" {
  assert_eq(get_tier_start(0), 0)
  assert_eq(get_tier_start(1), 7)
  assert_eq(get_tier_start(2), 14)
}

///|
test "get_tier_count" {
  assert_eq(get_tier_count(0), 7)
  assert_eq(get_tier_count(1), 7)
  assert_eq(get_tier_count(2), 6)
}

///|
test "tier1_levels_no_locked_cells_mostly" {
  // First 5 levels should have no locked cells (simple beginner levels)
  for i in 0..<5 {
    let level = get_level(i)
    assert_eq(level.locked_cells.length(), 0)
  }
}

///|
test "level_names_unique" {
  let names : Array[String] = []
  for i in 0..<@types.total_levels {
    let level = get_level(i)
    assert_false(names.contains(level.name))
    names.push(level.name)
  }
}

///|
test "locked_cells_within_grid" {
  for i in 0..<@types.total_levels {
    let level = get_level(i)
    for j in 0..<level.locked_cells.length() {
      let (r, c) = level.locked_cells[j]
      assert_true(@types.in_grid(r, c))
    }
  }
}

///|
test "level_difficulty_progression" {
  // Advanced levels should generally have lower initial resources
  let beginner = get_level(0)
  let advanced = get_level(19)
  let beginner_total = beginner.initial_resources.o2 + beginner.initial_resources.co2 +
    beginner.initial_resources.water + beginner.initial_resources.nutrients
  let advanced_total = advanced.initial_resources.o2 + advanced.initial_resources.co2 +
    advanced.initial_resources.water + advanced.initial_resources.nutrients
  assert_true(beginner_total > advanced_total)
}
